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

# ECQ-2015
*** Test Cases ***
# connections not supported for VM non-LB
#AppMetrics - Shall be able to get Docker app Connections metrics by version
#   [Documentation]
#   ...  request the cluster Connections metrics by version
#   ...  verify metrics are returned
#
#   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack     ${app_name}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections
#
#   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections 
#   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections
#
#   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
#
#   Metrics Headings Should Be Correct  ${metrics1}
#
#   Connections Should Be In Range  ${metrics1}

AppMetrics - Shall be able to get VM app CPU metrics by version
   [Documentation]
   ...  request the cluster CPU metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last app metric on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  cpu
   ${metrics2}   ${metrics_influx2}=  Get the last app metric on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  cpu

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}  appinst-cpu
   Metrics Headings Should Be Correct  ${metrics2}  appinst-cpu

   CPU Should Be In Range  ${metrics1}
   CPU Should Be In Range  ${metrics2}

AppMetrics - Shall be able to get VM disk metrics by version
   [Documentation]
   ...  request the cluster disk metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last app metric on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk
   ${metrics2}   ${metrics_influx2}=  Get the last app metric on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}  appinst-disk
   Metrics Headings Should Be Correct  ${metrics2}  appinst-disk

   Disk Should Be In Range  ${metrics1}
   Disk Should Be In Range  ${metrics2}

AppMetrics - Shall be able to get VM memory metrics by version
   [Documentation]
   ...  request the cluster memory metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last app metric on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  mem
   ${metrics2}   ${metrics_influx2}=  Get the last app metric on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  mem

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}  appinst-mem
   Metrics Headings Should Be Correct  ${metrics2}  appinst-mem

   Memory Should Be In Range  ${metrics1}
   Memory Should Be In Range  ${metrics2}

AppMetrics - Shall be able to get VM network metrics by version
   [Documentation]
   ...  request the cluster network metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last app metric on openstack with version     ${app_name}  ${app_version}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  network
   ${metrics2}   ${metrics_influx2}=  Get the last app metric on openstack with version     ${app_name}  ${app_version2}  ${app_name_influx}  ${cluster_name}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}
   Metrics Should Match Influxdb  metrics=${metrics2}  metrics_influx=${metrics_influx2}

   Metrics Headings Should Be Correct  ${metrics1}  appinst-network
   Metrics Headings Should Be Correct  ${metrics2}  appinst-network

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
   ${cluster_name}=  Get Default Cluster Name
   #${clustername_kdedicated}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -k8sdedicated

   #${app_name}=  Set Variable  MyAppK8s1585261834-0104609k8s
   #${clustername_k8dedicated}=   Set Variable  cluster-1585261834-0104609-k8sdedicated
   #${flavor_name}=  Set Variable  flavor1585261834-0104609

   Create Flavor  region=${region}  flavor_name=${flavorname}  disk=80

   Create App  region=${region}  app_name=${app_name}  app_version=${app_version}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  developer_org_name=${developer_name}
   ${app_inst1}=  Create App Instance  region=${region}  app_name=${app_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}

   Create App  region=${region}  app_name=${app_name}  app_version=${app_version2}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  developer_org_name=${developer_name}
   ${app_inst2}=  Create App Instance  region=${region}  app_name=${app_name}  app_version=${app_version2}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}

   #Log to Console  Wait and connect to TCP/UDP ports
   #Sleep  7 mins
   #UDP Port Should Be Alive  ${appinst1['data']['uri']}  ${appinst1['data']['mapped_ports'][1]['public_port']}
   #TCP Port Should Be Alive  ${appinst1['data']['uri']}  ${appinst1['data']['mapped_ports'][0]['public_port']}  wait_time=20
   #UDP Port Should Be Alive  ${appinst2['data']['uri']}  ${appinst2['data']['mapped_ports'][1]['public_port']}
   #TCP Port Should Be Alive  ${appinst2['data']['uri']}  ${appinst2['data']['mapped_ports'][0]['public_port']}  wait_time=20

   Log to Console  Waiting for metrics to be collected
   Sleep  20 mins

   #${app_name}=  Set Variable  app1607983661-66944
   #${cluster_name}=  Set Variable  cluster1607983661-66944
   #${appinst}=  Show App Instances  region=${region}  app_name=${app_name}
   #{pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${app_name_influx}
   Set Suite Variable  ${app_version}
   Set Suite Variable  ${app_version2}
   Set Suite Variable  ${cluster_name}
   Set Suite Variable  ${developer_name}

Metrics Should Match Influxdb
   [Arguments]  ${metrics}  ${metrics_influx}

   ${metrics_influx_t}=  Set Variable  ${metrics_influx}
   ${index}=  Set Variable  0
   FOR  ${reading}  IN  @{metrics_influx}
      @{datesplit1}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][${index}]}  Z
      ${metricsepoch}=  Convert Date  ${datesplit1[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      @{datesplit2}=  Split String  ${reading['time']}  Z
      ${influxepoch}=  Convert Date  ${datesplit2[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      Run Keyword If  '${metricsepoch}' < '${influxepoch}'  Remove From List  ${metrics_influx_t}  ${index}
      ...  ELSE  Exit For Loop
   END

   log to console  ${metrics_influx_t}

   ${index}=  Set Variable  0
   FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
      #Should Be Equal  ${metrics_influx_t[${index}]['cpu']}  ${reading[9]}

      ${index}=  Evaluate  ${index}+1
   END

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
      Should Be True               ${reading[10]} > 0 and ${reading[10]} <= 1000000
   END

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 0   #and ${reading[9]} <= 100000000
   END

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 0 and ${reading[10]} >= 0
   END

