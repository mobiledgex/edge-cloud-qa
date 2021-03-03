*** Settings ***
Documentation   Docker App Autocluster Connections Metrics

Resource  ../metrics_app_library.robot
	      
Suite Setup       Setup
#Test Teardown    Cleanup provisioning

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudlet
${operator_name_openstack}=                       TDG
${clustername_docker}=   cluster1574731678-0317152-docker
${developer_name}=  developer1574731678-0317152 
${app_name}=  xxx

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  ${mextester06_gmail_password}
${orgname}=   metricsorg

${port}=  2015

${region}=  EU
	
*** Test Cases ***
AppMetrics - Shall be able to get all docker autocluster app Connections metrics
   [Documentation]
   ...  - request all docker autocluster Connections metrics
   ...  - verify info is correct

   [Tags]  ReservableCluster

   ${metrics}  ${metrics_influx}=  Get all app metrics on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Connections Should Be In Range  ${metrics}

   Metrics Should Match Connected App  ${metrics}

*** Keywords ***
Setup
   ${t}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   ${clustername_docker}=  Get Default Cluster Name 
   ${app_name}=    Get Default App Name 

   #${clustername_docker}=  Catenate  SEPARATOR=-  cluster  ${t}  docker 
   #${app_name}=     Catenate  SEPARATOR=  ${app_name}  k8s

#   ${app_name}=  Set Variable  app1582050962-662911k8s 
#   ${clustername_docker}=   Set Variable  cluster-1582050962-662911-docker 
#   ${developer_name}=  Set Variable  mobiledgex 

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name}
   ${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${app_name_influx}
   #Set Suite Variable  ${pod}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        appinst-connections
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
 
   #Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][0]}' != '${metrics_influx[0]['time']}'  Remove From List  ${metrics_influx}  0  #remove 1st item if newer than ws
   #...  ELSE  Remove From List  ${metrics_influx}  -1  #remove last item
   log to console  ${metrics_influx_t}

   ${index}=  Set Variable  0
#   : FOR  ${reading}  IN  @{metrics_influx_t}
   FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
#   \  Log to console  ${metrics_influx_t[${index}]}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
#   \  Should Be Equal  ${metrics_influx_t[${index}]['app']}  ${reading[1]}
#   \  Should Be Equal  ${metrics_influx_t[${index}]['cluster']}  ${reading[2]}
#   \  Should Be Equal  ${metrics_influx_t[${index}]['dev']}  ${reading[3]}
#   \  Should Be Equal  ${metrics_influx_t[${index}]['cloudlet']}  ${reading[4]}
#   \  Should Be Equal  ${metrics_influx_t[${index}]['operator']}  ${reading[5]}
#   \  Should Be Equal  ${metrics_influx_t[${index}]['port']}  ${reading[6]}
      Should Be Equal  ${metrics_influx_t[${index}]['active']}  ${reading[9]}
      Should Be Equal  ${metrics_influx_t[${index}]['handled']}  ${reading[10]}
      Should Be Equal  ${metrics_influx_t[${index}]['accepts']}  ${reading[11]}
      Should Be Equal  ${metrics_influx_t[${index}]['bytesSent']}  ${reading[12]}
      Should Be Equal  ${metrics_influx_t[${index}]['bytesRecvd']}  ${reading[13]}
      Should Be Equal  ${metrics_influx_t[${index}]['P0']}  ${reading[14]}
      Should Be Equal  ${metrics_influx_t[${index}]['P25']}  ${reading[15]}
      Should Be Equal  ${metrics_influx_t[${index}]['P50']}  ${reading[16]}
      Should Be Equal  ${metrics_influx_t[${index}]['P75']}  ${reading[17]}
      Should Be Equal  ${metrics_influx_t[${index}]['P90']}  ${reading[18]}
      Should Be Equal  ${metrics_influx_t[${index}]['P95']}  ${reading[19]}
      Should Be Equal  ${metrics_influx_t[${index}]['P99']}  ${reading[20]}
      Should Be Equal  ${metrics_influx_t[${index}]['P99.5']}  ${reading[21]}
      Should Be Equal  ${metrics_influx_t[${index}]['P99.9']}  ${reading[22]}
      Should Be Equal  ${metrics_influx_t[${index}]['P100']}  ${reading[23]}

      ${index}=  Evaluate  ${index}+1
   END

Metrics Should Match Connected App 
   [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   ${found_connection}=  Set Variable  ${False}
   ${found_histogram}=   Set Variable  ${False}

   # verify values
   FOR  ${reading}  IN  @{values}
   #\  @{datesplit}=  Split String  ${reading[0]}  .
      ${found_connection}=  Run Keyword If  '${reading[8]}' == '${port}' and '${reading[9]}' == '1' and '${reading[10]}' == '1' and '${reading[11]}' == '1' and '${reading[12]}' > '0' and '${reading[13]}' > '0'  Set Variable  ${True}
      ...                                 ELSE  Set Variable  ${found_connection}
      ${found_histogram}=  Run Keyword If  '${reading[13]}' > '0' and '${reading[14]}' > '0' and '${reading[15]}' > '0' and '${reading[16]}' > '0' and '${reading[17]}' > '0' and '${reading[18]}' > '0' and '${reading[19]}' > '0' and '${reading[20]}' > '0' and '${reading[21]}' > '0' and '${reading[22]}' > '0'  Set Variable  ${True}
      ...                                 ELSE  Set Variable  ${found_histogram}
   END

   Should Be True  ${found_connection}  Didnot find connected app 
   Should Be True  ${found_histogram}   Didnot find histogram app

