*** Settings ***
Documentation   K8s Dedicated App CPU/Memory/Disk/Network/Connections Metrics

Library  MexApp

Resource  metrics_app_library.robot
	      
Suite Setup       Setup
Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBonnCloudlet
${operator_name_openstack}=                       TDG
${clustername_docker}=   cluster1574731678-0317152-k8sdedicated
${developer_name}=  developer1574731678-0317152 

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  mextester06123
${orgname}=   metricsorg

${test_timeout_crm}=  32mins

# this is blocked by EDGECLOUD-2371

*** Test Cases ***
AppMetrics - Shall be able to get Docker app Connections metrics by version
   [Documentation]
   ...  request the cluster Connections metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections 
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}  appinst-connections
   Metrics Headings Should Be Correct  ${metrics2}  appinst-connections

   Connections Should Be In Range  ${metrics1}
   Connections Should Be In Range  ${metrics2}

AppMetrics - Shall be able to get Docker app CPU metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  cpu
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  cpu

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}   appinst-cpu
   Metrics Headings Should Be Correct  ${metrics2}   appinst-cpu

   CPU Should Be In Range  ${metrics1}
   CPU Should Be In Range  ${metrics2}

AppMetrics - Shall be able to get Docker disk CPU metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}   appinst-disk
   Metrics Headings Should Be Correct  ${metrics2}   appinst-disk

   Disk Should Be In Range  ${metrics1}
   Disk Should Be In Range  ${metrics2}

AppMetrics - Shall be able to get Docker memory CPU metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  mem
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  mem

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}   appinst-mem
   Metrics Headings Should Be Correct  ${metrics2}   appinst-mem

   Memory Should Be In Range  ${metrics1}
   Memory Should Be In Range  ${metrics2}

AppMetrics - Shall be able to get Docker network metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  network
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}   appinst-network
   Metrics Headings Should Be Correct  ${metrics2}   appinst-network

   Network Should Be In Range  ${metrics1}
   Network Should Be In Range  ${metrics2}

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
   ${clustername_docker}=  Get Default Cluster Name
   #${clustername_kdedicated}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -k8sdedicated

   #${app_name}=  Set Variable  MyAppK8s1585261834-0104609k8s
   #${clustername_k8dedicated}=   Set Variable  cluster-1585261834-0104609-k8sdedicated
   #${flavor_name}=  Set Variable  flavor1585261834-0104609

   Create Flavor  region=${region}

   Create Cluster Instance  region=${region}  cluster_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  number_nodes=1  ip_access=IpAccessShared

   Create App  region=${region}  app_name=${app_name}  app_version=${app_version}  default_flavor_name=${flavor_name}  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2015,udp:2016
   ${appinst1}=  Create App Instance  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  #autocluster_ip_access=IpAccessDedicated

   Create App  region=${region}  app_name=${app_name}  app_version=${app_version2}  default_flavor_name=${flavor_name}  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2016,udp:2015
   ${appinst2}=  Create App Instance  region=${region}  app_name=${app_name}  app_version=${app_version2}  cluster_instance_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  #autocluster_ip_access=IpAccessDedicated

   Log to Console  Wait and connect to TCP/UDP ports
   Sleep  7 mins
   UDP Port Should Be Alive  ${appinst1['data']['uri']}  ${appinst1['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${appinst1['data']['uri']}  ${appinst1['data']['mapped_ports'][0]['public_port']}  wait_time=20
   UDP Port Should Be Alive  ${appinst2['data']['uri']}  ${appinst2['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${appinst2['data']['uri']}  ${appinst2['data']['mapped_ports'][0]['public_port']}  wait_time=20

   Log to Console  Waiting for metrics to be collected
   Sleep  10 mins
 
   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name}
   ${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${app_name_influx}
   Set Suite Variable  ${app_version}
   Set Suite Variable  ${app_version2}
   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${pod}

Metrics Should Match Influxdb
   [Arguments]  ${metrics}  ${metrics_influx}

   ${metrics_influx_t}=  Set Variable  ${metrics_influx}
   ${index}=  Set Variable  0
   FOR  ${reading}  IN  @{metrics_influx}
      @{datesplit1}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][${index}]}  .
      ${metricsepoch}=  Convert Date  ${datesplit1[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      @{datesplit2}=  Split String  ${reading['time']}  .
      ${influxepoch}=  Convert Date  ${datesplit2[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      Run Keyword If  '${metricsepoch}' < '${influxepoch}'  Remove From List  ${metrics_influx_t}  ${index}
      ...  ELSE  Exit For Loop
   END

   log to console  ${metrics_influx_t}

   ${index}=  Set Variable  0
   FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
   #\  Should Be Equal  ${metrics_influx_t[${index}]['cpu']}  ${reading[9]}

      ${index}=  Evaluate  ${index}+1
   END

Appinst Connections Headings
  [Arguments]  ${metrics}
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  port
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  active
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  handled
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][11]}  accepts
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][12]}  bytesSent
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][13]}  bytesRecvd
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][14]}  P0
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][15]}  P25
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][16]}  P50
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][17]}  P75
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][18]}  P90
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][19]}  P95
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][20]}  P99
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][21]}  P99.5
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][22]}  P99.9
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][23]}  P100

Appinst Cpu Headings
  [Arguments]  ${metrics}
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  pod
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  cpu

Appinst Disk Headings
  [Arguments]  ${metrics}
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  pod
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  disk

Appinst Mem Headings
  [Arguments]  ${metrics}
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  pod
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  mem

Appinst Network Headings
  [Arguments]  ${metrics}
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  pod
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  sendBytes
    Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  recvBytes

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}  ${metrics_type}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}       ${metrics_type}

   #FOR  ${i}  IN RANGE  0  5
   Run Keyword If   '${metrics_type}' == 'appinst-connections'  Appinst Connections Headings  ${metrics}
   ...  ELSE IF  '${metrics_type}' == 'appinst-cpu'  Appinst Cpu Headings  ${metrics}
   ...  ELSE IF  '${metrics_type}' == 'appinst-disk'  Appinst Disk Headings   ${metrics}
   ...  ELSE IF  '${metrics_type}' == 'appinst-mem'   Appinst Mem Headings   ${metrics}
   ...  ELSE  Appinst Network Headings  ${metrics}

CPU Should Be In Range
  [Arguments]  ${metrics}

  ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} > 0 and ${reading[9]} <= 100
   END

Disk Should Be In Range
  [Arguments]  ${metrics}

  ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} > 0
   END

Memory Should Be In Range
  [Arguments]  ${metrics}

  ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 0 and ${reading[9]} <= 100000000
   END

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 0 and ${reading[10]} >= 0
   END

Connections Should Be In Range
  [Arguments]  ${metrics}

  ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 0
      Should Be True               ${reading[10]} >= 0
      Should Be True               ${reading[11]} >= 0
      Should Be True               ${reading[12]} >= 0
      Should Be True               ${reading[13]} >= 0
      Should Be True               ${reading[14]} >= 0
      Should Be True               ${reading[15]} >= 0
      Should Be True               ${reading[16]} >= 0
      Should Be True               ${reading[17]} >= 0
      Should Be True               ${reading[18]} >= 0
      Should Be True               ${reading[19]} >= 0
      Should Be True               ${reading[20]} >= 0
      Should Be True               ${reading[21]} >= 0
      Should Be True               ${reading[22]} >= 0
      Should Be True               ${reading[23]} >= 0
   END
