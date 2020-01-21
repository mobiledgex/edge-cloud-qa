*** Settings ***
Documentation   Cluster Disk Metrics with no cluster name

#Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
#LIbrary  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
#Library  DateTime
#Library  String
#Library  Collections
Resource  metrics_cluster_library.robot
			      
Test Setup       Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBonnCloudlet
${operator}=                       TDG
#${clustername_docker}=  cluster1573768282-436812 
#${developer_name}=   developer1573768282-436812

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  mextester06
${password}=  mextester06123
${orgname}=   metricsorg
	
*** Test Cases ***
ClusterMetrics - Shall be able to get the cluster Disk metrics with cloudlet/operator/developer only 
   [Documentation]
   ...  request all cluster Disk metrics with cloudlet/operator/developer on openstack
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with cloudlet/operator/developer only  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  disk

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be in Range  ${metrics}

   Metrics Should Match Different Cluster Names  ${metrics}

ClusterMetrics - Shall be able to get the cluster Disk metrics with cloudlet/developer only
   [Documentation]
   ...  request all cluster Disk metrics with cloudlet/developer on openstack
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with cloudlet/developer only  ${cloudlet_name_openstack_metrics}  ${developer_name}  disk

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be in Range  ${metrics}

   Metrics Should Match Different Cluster Names  ${metrics}

ClusterMetrics - Shall be able to get the cluster Disk metrics with operator/developer only
   [Documentation]
   ...  request all cluster Disk metrics with operator/developer only
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with operator/developer only  ${operator}  ${developer_name}  disk

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should be in Range  ${metrics}

   Metrics Should Match Different Cluster Names  ${metrics}

*** Keywords ***
Setup
   #${limits}=  Get Openstack limits
   #Set Suite Variable  ${limits}
  
   ${timestamp}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   #${clustername}=  Get Default Cluster Name
   ${clustername_docker}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -docker

   #${clustername_docker}=   Set Variable  cluster1574811700-5411682-k8sshared
   #${developer_name}=  Set Variable  developer1574811700-5411682
   #${clustername_docker}=   Set Variable  cluster1574873355-539982-k8sshared
   #${developer_name}=  Set Variable  developer1574873355-539982

   #${clustername_docker}=   Set Variable  cluster1575473566-0417001-docker
   #${developer_name}=  Set Variable  developer1575473566-0417001

   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-disk
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  dev
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  disk
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  operator

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
	
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[4]} > 0 and ${reading[4]} <= 100

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

   #Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][0]}' != '${metrics_influx[0]['time']}'  Remove From List  ${metrics_influx}  0  #remove 1st item if newer than ws
   #...  ELSE  Remove From List  ${metrics_influx}  -1  #remove last item
   #log to console  ${metrics_influx}

   ${index}=  Set Variable  0
   : FOR  ${reading}  IN  @{metrics_influx_t}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][4]}  ${reading['disk']}
   \  ${index}=  Evaluate  ${index}+1

Metrics Should Match Different Cluster Names
   [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   log to console  @{datesplit}
   ${epochlast}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   ${found_own_cluster}=  Set Variable  ${False}
   ${found_other_cluster}=  Set Variable  ${False}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  @{datesplit}=  Split String  ${reading[0]}  .
   \  ${epoch}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   \  Should Be True               ${epoch} <= ${epochlast}
   \  Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   \  ${found_own_cluster}=  Run Keyword If  '${reading[2]}' == '${clustername_docker}'   Set Variable  ${True}
   \  ...                                 ELSE  Set Variable  ${found_own_cluster}
   \  ${found_other_cluster}=  Run Keyword If  '${reading[2]}' != '${clustername_docker}'   Set Variable  ${True}
   \  ...                                 ELSE  Set Variable  ${found_other_cluster}
   \  ${epochlast}=  Set Variable  ${epoch}

   Should Be True  ${found_own_cluster}  Didnot find own cluster
   Should Be True  ${found_other_cluster}  Didnot find other cluster

