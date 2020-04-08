*** Settings ***
Documentation   K8s Dedicated App CPU/Memory/Disk/Network/Connections Metrics

Resource  ../metrics_app_library.robot
	      
Test Setup       Setup
#Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBonnCloudlet
${operator}=                       TDG
${clustername_k8shared}=   cluster1574731678-0317152-k8sdedicated
${developer_name}=  developer1574731678-0317152 

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  mextester06
${password}=  mextester06123
${orgname}=   metricsorg

${test_timeout_crm}=  32mins

*** Test Cases ***
AppMetrics - Shall be able to get the last 5 k8s dedicated cluster CPU/Network/Connections/Mem/Disk metrics on openstack
   [Documentation]
   ...  request app metrics with all selectors
   ...  verify info is correct

   ${metrics}=  Get the last 5 app metrics on openstack for multiple selectors     ${appname}  ${pod}  ${clustername_k8dedicated}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  cpu,mem,disk,network,connections

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}
   Disk Should Be In Range  ${metrics}
   Memory Should Be In Range  ${metrics}
   Network Should Be In Range  ${metrics}
   Connections Should Be In Range  ${metrics}

AppMetrics - Shall be able to get the last 5 k8s dedicated cluster wildcard metrics on openstack
   [Documentation]
   ...  request app metrics with wildcard selector 
   ...  verify info is correct

   ${metrics}=  Get the last 5 app metrics on openstack for multiple selectors   ${appname}  ${pod}  ${clustername_k8dedicated}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  * 

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
   ${app_name}=  Get Default App Name
   ${clustername_k8dedicated}=  Get Default Cluster Name
   #${clustername_k8dedicated}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -k8sdedicated

#   ${app_name}=  Set Variable  MyAppK8s1583266405-4298859k8s 
#   ${pod}=  Set Variable  myappk8s1583266405-4298859k8s-deployment-7b6dd85b46-52qc8 
#   ${clustername_k8dedicated}=   Set Variable  cluster-1583266405-4298859-k8sdedicated 
   #${developer_name}=  Set Variable  mobiledgex 

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name}
   ${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${clustername_k8dedicated}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${pod}
 
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

