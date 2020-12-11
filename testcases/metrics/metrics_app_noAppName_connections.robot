*** Settings ***
Documentation   App Connections Metrics with no app name

#Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
#Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
#Library  DateTime
#Library  String
#Library  Collections
Resource  metrics_app_library.robot
	      
Test Setup       Setup
#Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBuckhornCloudlet
${operator_name_openstack}=                       GDDT
${clustername_docker}=   cluster1574731678-0317152-k8sshared
${developer_name}=  developer1574731678-0317152 

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  mextester06123
${orgname}=   metricsorg
	
*** Test Cases ***
# ECQ-1969
AppMetrics - Shall be able to get the app Connections metrics with cloudlet/operator/developer only
   [Documentation]
   ...  request all app Connections metrics with cloudlet/operator/developer on openstack
   ...  verify info is correct

   ${metrics}=  Get app metrics with cloudlet/operator/developer only  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  connections 

   Metrics Headings Should Be Correct  ${metrics}

   Connections Should be in Range  ${metrics}

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   # removed since it is often the only cluster
   #Metrics Should Match Different Cluster Names  ${metrics}

# ECQ-1970
AppMetrics - Shall be able to get the app Connections metrics with cloudlet/developer only
   [Documentation]
   ...  request all app Connections metrics with cloudlet/developer on openstack
   ...  verify info is correct

   ${metrics}=  Get app metrics with cloudlet/developer only  ${cloudlet_name_openstack_metrics}  ${developer_name}  connections 

   Metrics Headings Should Be Correct  ${metrics}

   Connections Should be in Range  ${metrics}

   #Metrics Should Match Different Cluster Names  ${metrics}

# ECQ-1971
AppMetrics - Shall be able to get the app Connections metrics with operator/developer only
   [Documentation]
   ...  request all app Connections metrics with operator/developer only
   ...  verify info is correct

   ${metrics}=  Get app metrics with operator/developer only  ${operator_name_openstack}  ${developer_name}  connections 

   Metrics Headings Should Be Correct  ${metrics}

   Connections Should be in Range  ${metrics}

   #Metrics Should Match Different Cluster Names  ${metrics}

# ECQ-1972
AppMetrics - Shall be able to get the app Connections metrics with developer only
   [Documentation]
   ...  request all app Connections metrics with developer only
   ...  verify info is correct

   ${metrics}=  Get app metrics with developer only  ${developer_name}  connections

   Metrics Headings Should Be Correct  ${metrics}

   Connections Should be in Range  ${metrics}

# ECQ-2040
AppMetrics - Shall be able to get all app Connections metrics with developer only
   [Documentation]
   ...  request all app connections metrics with developer only
   ...  verify info is correct and only returns 2000 metrics

   [Teardown]  Config Teardown

   ${num_metrics}    Generate Random String    4    0123456789

   Set Max Metrics Data Points Config  ${num_metrics} 
   ${metrics}=  Get all app metrics with developer only  ${developer_name}  connections  ${num_metrics}

   Metrics Headings Should Be Correct  ${metrics}

   Connections Should be in Range  ${metrics}

   Set Max Metrics Data Points Config   10000

   ${metrics}=  Get all app metrics with developer only  ${developer_name}  connections  10000

   Metrics Headings Should Be Correct  ${metrics}

   Connections Should be in Range  ${metrics}

*** Keywords ***
Setup
   #${limits}=  Get Openstack limits
   #Set Suite Variable  ${limits}
   
   ${timestamp}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   #${clustername}=  Get Default Cluster Name
   ${clustername_docker}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -docker

   #${clustername_docker}=   Set Variable  cluster1575473566-0417001-docker 
   #${developer_name}=  Set Variable  developer1575473566-0417001 

   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}

Config Teardown
   Set Max Metrics Data Points Config   10000
 
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
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][3]}  ${reading['connections']}
#   \  ${index}=  Evaluate  ${index}+1
   FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
      Should Be Equal  ${metrics_influx_t[${index}]['active']}  ${reading[10]}
      Should Be Equal  ${metrics_influx_t[${index}]['handled']}  ${reading[11]}
      Should Be Equal  ${metrics_influx_t[${index}]['accepts']}  ${reading[12]}
      Should Be Equal  ${metrics_influx_t[${index}]['bytesSent']}  ${reading[13]}
      Should Be Equal  ${metrics_influx_t[${index}]['bytesRecvd']}  ${reading[14]}
      Should Be Equal  ${metrics_influx_t[${index}]['P0']}  ${reading[15]}
      Should Be Equal  ${metrics_influx_t[${index}]['P25']}  ${reading[16]}
      Should Be Equal  ${metrics_influx_t[${index}]['P50']}  ${reading[17]}
      Should Be Equal  ${metrics_influx_t[${index}]['P75']}  ${reading[18]}
      Should Be Equal  ${metrics_influx_t[${index}]['P90']}  ${reading[19]}
      Should Be Equal  ${metrics_influx_t[${index}]['P95']}  ${reading[20]}
      Should Be Equal  ${metrics_influx_t[${index}]['P99']}  ${reading[21]}
      Should Be Equal  ${metrics_influx_t[${index}]['P99.5']}  ${reading[22]}
      Should Be Equal  ${metrics_influx_t[${index}]['P99.9']}  ${reading[23]}
      Should Be Equal  ${metrics_influx_t[${index}]['P100']}  ${reading[24}
      ${index}=  Evaluate  ${index}+1
   END

Metrics Should Match Different Cluster Names
   [Arguments]  ${metrics}  

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   log to console  @{datesplit}
   ${epochlast}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   ${found_own_cluster}=  Set Variable  ${False}
   ${found_other_cluster}=  Set Variable  ${False}

   # verify values
   FOR  ${reading}  IN  @{values}
      @{datesplit}=  Split String  ${reading[0]}  .
      ${epoch}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      Should Be True               ${epoch} <= ${epochlast}
      Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
      ${found_own_cluster}=  Run Keyword If  '${reading[1]}' == '${clustername_docker}'   Set Variable  ${True}
      ...                                 ELSE  Set Variable  ${found_own_cluster}
      ${found_other_cluster}=  Run Keyword If  '${reading[1]}' != '${clustername_docker}'   Set Variable  ${True}
      ...                                 ELSE  Set Variable  ${found_other_cluster}
      ${epochlast}=  Set Variable  ${epoch}
   END

   Should Be True  ${found_own_cluster}  Didnot find own cluster
   Should Be True  ${found_other_cluster}  Didnot find other cluster

