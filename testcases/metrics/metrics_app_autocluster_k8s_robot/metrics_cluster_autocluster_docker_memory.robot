*** Settings ***
Documentation   Docker Cluster Autocluster Memory Metrics

#Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
#LIbrary  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
#Library  DateTime
#Library  String
#Library  Collections
Resource  ../metrics_cluster_library.robot
			      
Test Setup       Setup
#Test Teardown    Cleanup provisioning
Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBuckhornCloudlet
${operator_name_openstack}=                       GDDT
#${clustername_docker}=  cluster1573768282-436812 
#${developer_name}=   developer1573768282-436812

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  ${mextester06_gmail_password}
${orgname}=   metricsorg

${test_timeout}=  32 min
	
*** Test Cases ***
ClusterMetrics - Shall be able to get all docker cluster autocluster Memory metrics on openstack
   [Documentation]
   ...  - request all cluster autocluster Memory metrics
   ...  - verify info is correct

   [Tags]  ReservableCluster

   ${metrics}  ${metrics_influx}=  Get all cluster metrics on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  mem

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

*** Keywords ***
Setup
   #${limits}=  Get Openstack limits
   #Set Suite Variable  ${limits}
  
   ${timestamp}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name 
   #${clustername}=  Get Default Cluster Name
   ${clustername_docker}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -docker

   #${clustername_docker}=   Set Variable  cluster1575388979-827483-k8sshared 
   #${developer_name}=  Set Variable  developer1575388979-827483 

   #${clustername_docker}=   Set Variable  cluster1574873355-539982-k8sshared
   #${developer_name}=  Set Variable  developer1574873355-539982

   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${timestamp}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-mem
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  mem

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
	
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[5]} > 0 and ${reading[5]} <= 100
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
    #\  log to console  ${metrics['data'][0]['Series'][0]['values'][0][${index}]} ${reading['time']} ${epochpre1} ${epochpre2}
    #\  Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][${index}]}' != '${reading['time']}'  Remove From List  ${metrics_influx_t}  ${index}
      Run Keyword If  '${metricsepoch}' < '${influxepoch}'  Remove From List  ${metrics_influx_t}  ${index}
      ...  ELSE  Exit For Loop
   END

   #${metrics_length}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   #${influx_length}=   Get Length  ${metrics_influx_t}
   #Should Be Equal  ${metrics_length}  ${influx_length}
	
   #Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][0]}' != '${metrics_influx[0]['time']}'  Remove From List  ${metrics_influx}  0  #remove 1st item if newer than ws
   #...  ELSE  Remove From List  ${metrics_influx}  -1  #remove last item
   #log to console  ${metrics_influx}

   ${index}=  Set Variable  0
#   : FOR  ${reading}  IN  @{metrics_influx_t}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][5]}  ${reading['mem']}
#   \  ${index}=  Evaluate  ${index}+1
   FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
      Should Be Equal  ${metrics_influx_t[${index}]['mem']}   ${reading[5]}
      ${index}=  Evaluate  ${index}+1
   END
