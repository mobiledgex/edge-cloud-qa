*** Settings ***
Documentation   K8s Dedicated App CPU/Memory/Disk/Network/Connections Metrics

Resource  ../metrics_app_library.robot
	      
Test Setup       Setup
#Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBonnCloudlet
${operator_name_openstack}=                       TDG
${clustername_k8shared}=   cluster1574731678-0317152-k8sdedicated
${developer_name}=  developer1574731678-0317152 
${app_version}=  1.0

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  mextester06
${password}=  mextester06123
${orgname}=   metricsorg

${test_timeout_crm}=  32mins

*** Test Cases ***
AppMetrics - Shall be able to get k8s dedicated app Connections metrics by version
   [Documentation]
   ...  request the cluster Connections metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${clustername_k8dedicated}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${clustername_k8dedicated}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}

   Metrics Headings Should Be Correct  ${metrics1}

   CPU Should Be In Range  ${metrics1}
   Disk Should Be In Range  ${metrics1}
   Memory Should Be In Range  ${metrics1}
   Network Should Be In Range  ${metrics1}
   Connections Should Be In Range  ${metrics1}

AppMetrics - Shall be able to get the last 5 k8s dedicated cluster wildcard metrics on openstack
   [Documentation]
   ...  request app metrics with wildcard selector 
   ...  verify info is correct

   ${metrics}=  Get the last 5 app metrics on openstack for multiple selectors   ${appname}  ${pod}  ${clustername_k8dedicated}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  * 

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}
   Disk Should Be In Range  ${metrics}
   Memory Should Be In Range  ${metrics}
   Network Should Be In Range  ${metrics}
   Connections Should Be In Range  ${metrics}

*** Keywords ***
Setup
   #${limits}=  Get Openstack limits
   #Set Suite Variable  ${limits}
   
   ${timestamp}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   ${flavor_name}=  Get Default Flavor Name
   ${app_name}=  Get Default App Name
   ${app_version}=  Set Variable  1.0
   ${app_version2}=  Set Variable  2.0
   ${app_name2}=  Catenate  SEPARATOR=  ${app_name}  2
   ${clustername_k8dedicated}=  Get Default Cluster Name
   #${clustername_kdedicated}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -k8sdedicated

   #${app_name}=  Set Variable  MyAppK8s1615333128-322516k8s 
   #${clustername_k8dedicated}=   Set Variable  cluster-1585261834-0104609-k8sdedicated
   #${flavor_name}=  Set Variable  flavor1585261834-0104609

   Create App  region=${region}  app_name=${app_name2}  app_version=${app_version2}  default_flavor_name=${flavor_name}  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2016,udp:2016
   Create App Instance  region=${region}  app_name=${app_name2}  app_version=${app_version2}  cluster_instance_name=${clustername_k8dedicated}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  #autocluster_ip_access=IpAccessDedicated

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name}
   ${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}
   ${app_name_influx2}=  Convert To Lowercase  ${app_name2}

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${app_name_influx}
   Set Suite Variable  ${app_name2}
   Set Suite Variable  ${app_name_influx2}
   Set Suite Variable  ${clustername_k8dedicated}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${pod}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}       appinst-udp
   Should Be Equal  ${metrics['data'][0]['Series'][1]['name']}       appinst-network 
   Should Be Equal  ${metrics['data'][0]['Series'][2]['name']}       appinst-mem
   Should Be Equal  ${metrics['data'][0]['Series'][3]['name']}       appinst-disk 
   Should Be Equal  ${metrics['data'][0]['Series'][4]['name']}       appinst-cpu 
   Should Be Equal  ${metrics['data'][0]['Series'][5]['name']}       appinst-connections

   FOR  ${i}  IN RANGE  0  5
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][0]}  time
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][1]}  app 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][2]}  ver
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][3]}  cluster
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][4]}  clusterorg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][5]}  cloudlet
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][6]}  cloudletorg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][7]}  apporg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][8]}  pod
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][9]}  bytesSent_1
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][10]}  bytesRecvd_1
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][11]}  datagramsSent
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][12]}  datagramsRecvd
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][13]}  sentErrs
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][14]}  recvErrs
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][15]}  missed
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][16]}  cpu
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][17]}  mem
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][18]}  disk
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][19]}  sendBytes 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][20]}  recvBytes 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][21]}  port_1
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][22]}  active 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][23]}  handled 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][24]}  accepts
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][25]}  bytesSent_1
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][26]}  bytesRecvd_1
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][27]}  P0
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][28]}  P25
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][29]}  P50
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][30]}  P75
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][31]}  P90
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][32]}  P95
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][33]}  P99
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][34]}  P99.5
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][35]}  P99.9
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][36]}  P100
   END 

CPU Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[8]} > 0 and ${reading[8]} <= 100
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[8]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[8]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[8]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[8]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[10]} > 0 and ${reading[10]} <= 1000000
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
   END

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 0 and ${reading[9]} <= 100000000
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[9]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[9]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[9]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[9]}  ${None}
   END

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[11]} >= 0 and ${reading[12]} >= 0
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

Connections Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[13]} >= 0
      Should Be True               ${reading[14]} >= 0
      Should Be True               ${reading[15]} >= 0
      Should Be True               ${reading[16]} >= 0
      Should Be True               ${reading[17]} >= 0
      Should Be True               ${reading[16]} >= 0
      Should Be True               ${reading[19]} >= 0
      Should Be True               ${reading[20]} >= 0
      Should Be True               ${reading[21]} >= 0
      Should Be True               ${reading[22]} >= 0
      Should Be True               ${reading[23]} >= 0
      Should Be True               ${reading[24]} >= 0
      Should Be True               ${reading[25]} >= 0
      Should Be True               ${reading[26]} >= 0
      Should Be True               ${reading[27]} >= 0
      Should Be True               ${reading[28]} >= 0
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal  ${reading[13]}  ${None} 
      Should Be Equal  ${reading[14]}  ${None} 
      Should Be Equal  ${reading[15]}  ${None} 
      Should Be Equal  ${reading[16]}  ${None}
      Should Be Equal  ${reading[17]}  ${None} 
      Should Be Equal  ${reading[18]}  ${None} 
      Should Be Equal  ${reading[19]}  ${None} 
      Should Be Equal  ${reading[20]}  ${None} 
      Should Be Equal  ${reading[21]}  ${None} 
      Should Be Equal  ${reading[22]}  ${None} 
      Should Be Equal  ${reading[23]}  ${None} 
      Should Be Equal  ${reading[24]}  ${None} 
      Should Be Equal  ${reading[25]}  ${None} 
      Should Be Equal  ${reading[26]}  ${None} 
      Should Be Equal  ${reading[27]}  ${None} 
      Should Be Equal  ${reading[28]}  ${None} 
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal  ${reading[13]}  ${None}
      Should Be Equal  ${reading[14]}  ${None}
      Should Be Equal  ${reading[15]}  ${None}
      Should Be Equal  ${reading[16]}  ${None}
      Should Be Equal  ${reading[17]}  ${None}
      Should Be Equal  ${reading[18]}  ${None}
      Should Be Equal  ${reading[19]}  ${None}
      Should Be Equal  ${reading[20]}  ${None}
      Should Be Equal  ${reading[21]}  ${None}
      Should Be Equal  ${reading[22]}  ${None}
      Should Be Equal  ${reading[23]}  ${None}
      Should Be Equal  ${reading[24]}  ${None}
      Should Be Equal  ${reading[25]}  ${None}
      Should Be Equal  ${reading[26]}  ${None}
      Should Be Equal  ${reading[27]}  ${None}
      Should Be Equal  ${reading[28]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal  ${reading[13]}  ${None}
      Should Be Equal  ${reading[14]}  ${None}
      Should Be Equal  ${reading[15]}  ${None}
      Should Be Equal  ${reading[16]}  ${None}
      Should Be Equal  ${reading[17]}  ${None}
      Should Be Equal  ${reading[18]}  ${None}
      Should Be Equal  ${reading[19]}  ${None}
      Should Be Equal  ${reading[20]}  ${None}
      Should Be Equal  ${reading[21]}  ${None}
      Should Be Equal  ${reading[22]}  ${None}
      Should Be Equal  ${reading[23]}  ${None}
      Should Be Equal  ${reading[24]}  ${None}
      Should Be Equal  ${reading[25]}  ${None}
      Should Be Equal  ${reading[26]}  ${None}
      Should Be Equal  ${reading[27]}  ${None}
      Should Be Equal  ${reading[28]}  ${None}
   END
 
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal  ${reading[13]}  ${None}
      Should Be Equal  ${reading[14]}  ${None}
      Should Be Equal  ${reading[15]}  ${None}
      Should Be Equal  ${reading[16]}  ${None}
      Should Be Equal  ${reading[17]}  ${None}
      Should Be Equal  ${reading[18]}  ${None}
      Should Be Equal  ${reading[19]}  ${None}
      Should Be Equal  ${reading[20]}  ${None}
      Should Be Equal  ${reading[21]}  ${None}
      Should Be Equal  ${reading[22]}  ${None}
      Should Be Equal  ${reading[23]}  ${None}
      Should Be Equal  ${reading[24]}  ${None}
      Should Be Equal  ${reading[25]}  ${None}
      Should Be Equal  ${reading[26]}  ${None}
      Should Be Equal  ${reading[27]}  ${None}
      Should Be Equal  ${reading[28]}  ${None}
   END

