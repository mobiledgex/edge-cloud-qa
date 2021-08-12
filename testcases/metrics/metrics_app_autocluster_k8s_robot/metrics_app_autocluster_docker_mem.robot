*** Settings ***
Documentation   Docker App Autocluster Memory Metrics

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

${region}=  EU
	
*** Test Cases ***
AppMetrics - Shall be able to get all docker autocluster app Memory metrics
   [Documentation]
   ...  - request all docker autocluster Memory metrics
   ...  - verify info is correct

   ${metrics}  ${metrics_influx}=  Get all app metrics on openstack     ${app_name}  ${app_name_influx}  ${realclustername_k8s}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  mem

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

*** Keywords ***
Setup
   ${t}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   ${app_name}=  Get Default App Name
   ${clustername_docker}=  Get Default Cluster Name

   #${clustername_docker}=  Catenate  SEPARATOR=-  cluster  ${t}  docker 
   #${app_name}=     Catenate  SEPARATOR=  ${app_name}  k8s

   #${app_name}=  Set Variable  app1582226010-873146k8s 
   #${clustername_docker}=   Set Variable  cluster-1582226010-873146-docker
   #${developer_name}=  Set Variable  mobiledgex

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name}
   ${realclustername_k8s}=  Set Variable  ${appinst[0]['data']['real_cluster_name']}
   #${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}

   log to console  ${appinst} ${app_name_influx}

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${app_name_influx}
   Set Suite Variable  ${realclustername_k8s}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        appinst-mem
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

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
	
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 0 and ${reading[9]} <= 100000000
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
   FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
      Should Be Equal  ${metrics_influx_t[${index}]['mem']}  ${reading[9]}
      ${index}=  Evaluate  ${index}+1
   END

