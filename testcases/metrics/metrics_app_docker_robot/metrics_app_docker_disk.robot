*** Settings ***
Documentation   Docker App Disk Metrics

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
AppMetrics - Shall be able to get the last docker app Disk metric on openstack
   [Documentation]
   ...  request app Disk metrics with last=1 
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}
	
   Metrics Headings Should Be Correct  ${metrics}
	
   Disk Should Be In Range  ${metrics}
   
	
AppMetrics - Shall be able to get the last 5 docker app Disk metrics on openstack
   [Documentation]
   ...  request app Disk metrics with last=5
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 5 app metrics on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

AppMetrics - Shall be able to get the last 10 docker app Disk metrics on openstack
   [Documentation]
   ...  request cluster Disk metrics with last=10
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 10 app metrics on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

AppMetrics - Shall be able to get all docker app Disk metrics on openstack
   [Documentation]
   ...  request all cluster Disk metrics
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get all app metrics on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

AppMetrics - Shall be able to request more docker app Disk metrics than exist on openstack
   [Documentation]
   ...  request cluster Disk metrics with last=<greater than total number of metrics>
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get more app metrics than exist on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

AppMetrics - Shall be able to get docker app Disk metrics with starttime on openstack
   [Documentation]
   ...  request cluster Disk metrics with starttime 
   ...  verify info is correct

   ${metrics}=  Get app metrics with starttime on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

AppMetrics - Shall be able to get docker app Disk metrics with endtime on openstack
   [Documentation]
   ...  request cluster Disk metrics with endtime 
   ...  verify info is correct

   ${metrics}=  Get app metrics with endtime on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Headings Should Be Correct  ${metrics}  

   Disk Should Be In Range  ${metrics}

AppMetrics - Shall be able to get the docker app Disk metrics with starttime=lastrecord on openstack
   [Documentation]
   ...  request cluster Disk metrics with starttime=lastrecord 
   ...  verify info is correct

   #edgecloud-1338 Metrics - requesting cloudlet metrics with starttime=<time> does not return the reading with that time

   ${metrics}  ${metrics_influx}=  Get app metrics with starttime=lastrecord on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics} 

AppMetrics - Shall be able to get the docker app Disk metrics with starttime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime in the future
   ...  verify empty list is returned

   Get app metrics with starttime > lastrecord on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

AppMetrics - Shall be able to get the docker app Disk metrics with endtime=lastrecord on openstack
   [Documentation]
   ...  request cluster Disk metrics with endtime=lastrecord
   ...  verify info is correct

   #EDGECLOUD-1648 Metrics - requesting metrics with endtime=lastrecord does not return the last record

   ${metrics}=  Get app metrics with endtime=lastrecord on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be In Range  ${metrics}

AppMetrics - Shall be able to get the docker app Disk metrics with endtime = firstrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with endtime = firstrecord 
   ...  verify empty list is returned

   Get app metrics with endtime = firstrecord on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

AppMetrics - Shall be able to get the docker app Disk metrics with starttime > endtime on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime > endtime
   ...  verify empty list is returned

   Get app metrics with starttime > endtime on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

AppMetrics - Shall be able to get the docker app Disk metrics with starttime and endtime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime/endtime in the future
   ...  verify empty list is returned

   Get app metrics with starttime and endtime > lastrecord on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

AppMetrics - Shall be able to get the docker app Disk metrics with starttime and endtime on openstack
   [Documentation]
   ...  request cluster Disk metrics with starttime and endtime on openstack
   ...  verify info is correct

   ${metrics}=  Get app metrics with starttime and endtime on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be In Range  ${metrics}

AppMetrics - Shall be able to get the docker app Disk metrics with starttime and endtime and last on openstack
   [Documentation]
   ...  request all cluster Disk metrics with starttime and endtime and last on openstack
   ...  verify info is correct

   ${metrics}=  Get app metrics with starttime and endtime and last on openstack     ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be In Range  ${metrics}

AppMetrics - DeveloperManager shall be able to get docker app Disk metrics
   [Documentation]
   ...  request the cluster Disk metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperManager shall be able to get app metrics  ${username}  ${password}  ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be In Range  ${metrics}

AppMetrics - DeveloperContributor shall be able to get docker app Disk metrics
   [Documentation]
   ...  request the cluster Disk metrics as DeveloperContributor
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperContributor shall be able to get app metrics  ${username}  ${password}  ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be In Range  ${metrics}

AppMetrics - DeveloperViewer shall be able to get docker app Disk metrics
   [Documentation]
   ...  request the cluster Disk metrics as DeveloperViewer
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperViewer shall be able to get app metrics  ${username}  ${password}  ${app_name}  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be In Range  ${metrics}

AppMetrics - Shall be able to get Docker app Disk metrics by version
   [Documentation]
   ...  request the cluster Disk metrics by version
   ...  verify metrics are returned

   ${metrics1}   ${metrics_influx1}=  Get the last 5 app metrics on openstack with version     ${app_name}  1.0  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk
   ${metrics2}   ${metrics_influx2}=  Get the last 5 app metrics on openstack with version     ${app_name}  2.0  ${app_name_influx}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics1}  metrics_influx=${metrics_influx1}

   Metrics Headings Should Be Correct  ${metrics1}

   Disk Should Be In Range  ${metrics1}

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
   #${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}

   log to console  ${appinst} ${app_name_influx}

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${app_name_influx}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        appinst-disk
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

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
	
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} > 0    #and ${reading[9]} <= 1000000
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
      Should Be Equal  ${metrics_influx_t[${index}]['disk']}  ${reading[9]}
      ${index}=  Evaluate  ${index}+1
   END
