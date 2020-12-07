*** Settings ***
Documentation   VM App Metrics

Library  MexApp

Resource  metrics_app_library.robot
	      
Suite Setup       Setup
#Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBonnCloudlet
${operator_name_openstack}=                       TDG
${cluster_name}=   cluster1574731678-0317152-k8sdedicated
${developer_name}=  developer1574731678-0317152 

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  mextester06123
${orgname}=   metricsorg

${test_timeout_crm}=  32mins

# this needs to be fixed once EDGECLOUD-2375 is fixed

*** Test Cases ***
AppMetrics - Shall be able to get Docker app Connections metrics by version
   [Documentation]
   ...  request the cluster Connections metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack     ${app_name}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections 
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}

   Metrics Headings Should Be Correct  ${metrics1}

   Connections Should Be In Range  ${metrics1}

AppMetrics - Shall be able to get Docker app CPU metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack     ${app_name}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  cpu

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  cpu
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  cpu

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}

   Metrics Headings Should Be Correct  ${metrics1}

   CPU Should Be In Range  ${metrics}

AppMetrics - Shall be able to get Docker disk CPU metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}

   Metrics Headings Should Be Correct  ${metrics1}

   Disk Should Be In Range  ${metrics}

AppMetrics - Shall be able to get Docker memory CPU metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  mem
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  mem

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}

   Metrics Headings Should Be Correct  ${metrics1}

   Memory Should Be In Range  ${metrics}

AppMetrics - Shall be able to get Docker networ CPU metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  network
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}

   Metrics Headings Should Be Correct  ${metrics1}

   Network Should Be In Range  ${metrics}

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
   ${cluster_name}=  Get Default Cluster Name
   #${clustername_kdedicated}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -k8sdedicated

   #${app_name}=  Set Variable  MyAppK8s1585261834-0104609k8s
   #${clustername_k8dedicated}=   Set Variable  cluster-1585261834-0104609-k8sdedicated
   #${flavor_name}=  Set Variable  flavor1585261834-0104609

   Create Flavor  region=${region}  flavor_name=${flavorname}  disk=80

   Create App  region=${region}  app_name=${app_name}  app_version=${app_version}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  developer_org_name=mobiledgex
   ${app_inst1}=  Create App Instance  region=${region}  app_name=${app_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}

   Create App  region=${region}  app_name=${app_name}  app_version=${app_version2}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  developer_org_name=mobiledgex
   ${app_inst2}=  Create App Instance  region=${region}  app_name=${app_name}  app_version=${app_version2}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}

   Log to Console  Wait and connect to TCP/UDP ports
   Sleep  7 mins
   UDP Port Should Be Alive  ${appinst1['data']['uri']}  ${appinst1['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${appinst1['data']['uri']}  ${appinst1['data']['mapped_ports'][0]['public_port']}  wait_time=20
   UDP Port Should Be Alive  ${appinst2['data']['uri']}  ${appinst2['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${appinst2['data']['uri']}  ${appinst2['data']['mapped_ports'][0]['public_port']}  wait_time=20
   UDP Port Should Be Alive  mobiledgexapp1585696665-92696810.automationdusseldorfcloudlet.tdg.mobiledgex.net  2015 
   TCP Port Should Be Alive  mobiledgexapp1585696665-92696810.automationdusseldorfcloudlet.tdg.mobiledgex.net  2016  wait_time=20
   UDP Port Should Be Alive  mobiledgexapp1585696665-92696820.automationdusseldorfcloudlet.tdg.mobiledgex.net  2015 
   TCP Port Should Be Alive  mobiledgexapp1585696665-92696820.automationdusseldorfcloudlet.tdg.mobiledgex.net   2016  wait_time=20

   Log to Console  Waiting for metrics to be collected
   #Sleep  3 mins

   ${app_name}=  Set Variable  app1585696665-926968
   ${cluster_name}=  Set Variable  cluster1585696665-926968 
   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name}
   ${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}
   
   Set Suite Variable  ${app_name}
   Set Suite Variable  ${app_name_influx}
   Set Suite Variable  ${app_version}
   Set Suite Variable  ${app_version2}
   Set Suite Variable  ${cluster_name}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${pod}

Metrics Should Match Influxdb
   [Arguments]  ${metrics}  ${metrics_influx}

   ${metrics_influx_t}=  Set Variable  ${metrics_influx}
   ${index}=  Set Variable  0
   : FOR  ${reading}  IN  @{metrics_influx}
   \  @{datesplit1}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][${index}]}  .
   \  ${metricsepoch}=  Convert Date  ${datesplit1[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   \  @{datesplit2}=  Split String  ${reading['time']}  .
   \  ${influxepoch}=  Convert Date  ${datesplit2[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   \  Run Keyword If  '${metricsepoch}' < '${influxepoch}'  Remove From List  ${metrics_influx_t}  ${index}
   \  ...  ELSE  Exit For Loop

   log to console  ${metrics_influx_t}

   ${index}=  Set Variable  0
   : FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
   \  Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
   \  Should Be Equal  ${metrics_influx_t[${index}]['cpu']}  ${reading[9]}

   \  ${index}=  Evaluate  ${index}+1
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}       appinst-network 
   Should Be Equal  ${metrics['data'][0]['Series'][1]['name']}       appinst-mem
   Should Be Equal  ${metrics['data'][0]['Series'][2]['name']}       appinst-disk 
   Should Be Equal  ${metrics['data'][0]['Series'][3]['name']}       appinst-cpu 
   Should Be Equal  ${metrics['data'][0]['Series'][4]['name']}       appinst-connections

   FOR  ${i}  IN RANGE  0  5
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][0]}  time
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][1]}  app 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][2]}  ver
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][3]}  pod
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][4]}  cluster
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][5]}  clusterorg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][6]}  cloudlet
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][7]}  cloudletorg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][8]}  apporg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][9]}  cpu
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][10]}  mem
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][11]}  disk
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][12]}  sendBytes 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][13]}  recvBytes 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][14]}  port 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][15]}  active 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][16]}  handled 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][17]}  accepts
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][18]}  bytesSent
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][19]}  bytesRecvd
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][20]}  P0
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][21]}  P25
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][22]}  P50
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][23]}  P75
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][24]}  P90
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][25]}  P95
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][26]}  P99
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][27]}  P99.5
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][28]}  P99.9
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][29]}  P100
   END 

CPU Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[8]} > 0 and ${reading[8]} <= 100

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[10]} > 0 and ${reading[10]} <= 1000000

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[10]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[10]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[10]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[10]}  ${None}

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[9]} >= 0 and ${reading[9]} <= 100000000

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[9]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[9]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[9]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[9]}  ${None}

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[11]} >= 0 and ${reading[12]} >= 0

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[11]}  ${None}
   \  Should Be Equal               ${reading[12]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[11]}  ${None}
   \  Should Be Equal               ${reading[12]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[11]}  ${None}
   \  Should Be Equal               ${reading[12]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[11]}  ${None}
   \  Should Be Equal               ${reading[12]}  ${None}

Connections Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[13]} >= 0
   \  Should Be True               ${reading[14]} >= 0
   \  Should Be True               ${reading[15]} >= 0
   \  Should Be True               ${reading[16]} >= 0
   \  Should Be True               ${reading[17]} >= 0
   \  Should Be True               ${reading[16]} >= 0
   \  Should Be True               ${reading[19]} >= 0
   \  Should Be True               ${reading[20]} >= 0
   \  Should Be True               ${reading[21]} >= 0
   \  Should Be True               ${reading[22]} >= 0
   \  Should Be True               ${reading[23]} >= 0
   \  Should Be True               ${reading[24]} >= 0
   \  Should Be True               ${reading[25]} >= 0
   \  Should Be True               ${reading[26]} >= 0
   \  Should Be True               ${reading[27]} >= 0
   \  Should Be True               ${reading[28]} >= 0

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal  ${reading[13]}  ${None} 
   \  Should Be Equal  ${reading[14]}  ${None} 
   \  Should Be Equal  ${reading[15]}  ${None} 
   \  Should Be Equal  ${reading[16]}  ${None}
   \  Should Be Equal  ${reading[17]}  ${None} 
   \  Should Be Equal  ${reading[18]}  ${None} 
   \  Should Be Equal  ${reading[19]}  ${None} 
   \  Should Be Equal  ${reading[20]}  ${None} 
   \  Should Be Equal  ${reading[21]}  ${None} 
   \  Should Be Equal  ${reading[22]}  ${None} 
   \  Should Be Equal  ${reading[23]}  ${None} 
   \  Should Be Equal  ${reading[24]}  ${None} 
   \  Should Be Equal  ${reading[25]}  ${None} 
   \  Should Be Equal  ${reading[26]}  ${None} 
   \  Should Be Equal  ${reading[27]}  ${None} 
   \  Should Be Equal  ${reading[28]}  ${None} 

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal  ${reading[13]}  ${None}
   \  Should Be Equal  ${reading[14]}  ${None}
   \  Should Be Equal  ${reading[15]}  ${None}
   \  Should Be Equal  ${reading[16]}  ${None}
   \  Should Be Equal  ${reading[17]}  ${None}
   \  Should Be Equal  ${reading[18]}  ${None}
   \  Should Be Equal  ${reading[19]}  ${None}
   \  Should Be Equal  ${reading[20]}  ${None}
   \  Should Be Equal  ${reading[21]}  ${None}
   \  Should Be Equal  ${reading[22]}  ${None}
   \  Should Be Equal  ${reading[23]}  ${None}
   \  Should Be Equal  ${reading[24]}  ${None}
   \  Should Be Equal  ${reading[25]}  ${None}
   \  Should Be Equal  ${reading[26]}  ${None}
   \  Should Be Equal  ${reading[27]}  ${None}
   \  Should Be Equal  ${reading[28]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal  ${reading[13]}  ${None}
   \  Should Be Equal  ${reading[14]}  ${None}
   \  Should Be Equal  ${reading[15]}  ${None}
   \  Should Be Equal  ${reading[16]}  ${None}
   \  Should Be Equal  ${reading[17]}  ${None}
   \  Should Be Equal  ${reading[18]}  ${None}
   \  Should Be Equal  ${reading[19]}  ${None}
   \  Should Be Equal  ${reading[20]}  ${None}
   \  Should Be Equal  ${reading[21]}  ${None}
   \  Should Be Equal  ${reading[22]}  ${None}
   \  Should Be Equal  ${reading[23]}  ${None}
   \  Should Be Equal  ${reading[24]}  ${None}
   \  Should Be Equal  ${reading[25]}  ${None}
   \  Should Be Equal  ${reading[26]}  ${None}
   \  Should Be Equal  ${reading[27]}  ${None}
   \  Should Be Equal  ${reading[28]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal  ${reading[13]}  ${None}
   \  Should Be Equal  ${reading[14]}  ${None}
   \  Should Be Equal  ${reading[15]}  ${None}
   \  Should Be Equal  ${reading[16]}  ${None}
   \  Should Be Equal  ${reading[17]}  ${None}
   \  Should Be Equal  ${reading[18]}  ${None}
   \  Should Be Equal  ${reading[19]}  ${None}
   \  Should Be Equal  ${reading[20]}  ${None}
   \  Should Be Equal  ${reading[21]}  ${None}
   \  Should Be Equal  ${reading[22]}  ${None}
   \  Should Be Equal  ${reading[23]}  ${None}
   \  Should Be Equal  ${reading[24]}  ${None}
   \  Should Be Equal  ${reading[25]}  ${None}
   \  Should Be Equal  ${reading[26]}  ${None}
   \  Should Be Equal  ${reading[27]}  ${None}
   \  Should Be Equal  ${reading[28]}  ${None}

