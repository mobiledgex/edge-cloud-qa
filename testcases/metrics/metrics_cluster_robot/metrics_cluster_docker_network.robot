*** Settings ***
Documentation   Docker Cluster Network Metrics

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
ClusterMetrics - Shall be able to get the last docker cluster Network metric on openstack
   [Documentation]
   ...  request docker cluster Network metrics with last=1 
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last cluster metric on openstack   ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}
	
   Metrics Headings Should Be Correct  ${metrics}
	
   Network Should Be In Range  ${metrics}
   
	
ClusterMetrics - Shall be able to get the last 5 docker cluster Network metrics on openstack
   [Documentation]
   ...  request docker cluster Network metrics with last=5
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 5 cluster metrics on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get the last 10 docker cluster Network metrics on openstack
   [Documentation]
   ...  request docker cluster Network metrics with last=10
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 10 cluster metrics on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get all docker cluster Network metrics on openstack
   [Documentation]
   ...  request all docker cluster Network metrics
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get all cluster metrics on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to request more docker cluster Network metrics than exist on openstack
   [Documentation]
   ...  request docker cluster Network metrics with last=<greater than total number of metrics>
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get more cluster metrics than exist on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get docker cluster Network metrics with starttime on openstack
   [Documentation]
   ...  request docker cluster Network metrics with starttime 
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with starttime on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get docker cluster Network metrics with endtime on openstack
   [Documentation]
   ...  request docker cluster Network metrics with endtime 
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with endtime on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Headings Should Be Correct  ${metrics}  

   Network Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get the docker cluster Network metrics with starttime=lastrecord on openstack
   [Documentation]
   ...  request docker cluster Network metrics with starttime=lastrecord 
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get cluster metrics with starttime=lastrecord on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get the docker cluster Network metrics with starttime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime in the future
   ...  verify empty list is returned

   Get cluster metrics with starttime > lastrecord on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

ClusterMetrics - Shall be able to get the docker cluster Network metrics with endtime=lastrecord on openstack
   [Documentation]
   ...  request docker cluster Network metrics with endtime=lastrecord
   ...  verify info is correct

   EDGECLOUD-1648 Metrics - requesting metrics with endtime=lastrecord does not return the last record

   ${metrics}=  Get cluster metrics with endtime=lastrecord on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Headings Should Be Correct  ${metrics}

   Network Should be in Range  ${metrics}

ClusterMetrics - Shall be able to get the docker cluster Network metrics with endtime = firstrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with endtime = firstrecord 
   ...  verify empty list is returned

   Get cluster metrics with endtime = firstrecord on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

ClusterMetrics - Shall be able to get the docker cluster Network metrics with starttime > endtime on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime > endtime
   ...  verify empty list is returned

   Get cluster metrics with starttime > endtime on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

ClusterMetrics - Shall be able to get the docker cluster Network metrics with starttime and endtime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime/endtime in the future
   ...  verify empty list is returned

   Get cluster metrics with starttime and endtime > lastrecord on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network
	
ClusterMetrics - Shall be able to get the docker cluster Network metrics with starttime and endtime on openstack
   [Documentation]
   ...  request docker cluster Network metrics with starttime and endtime on openstack
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with starttime and endtime on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Headings Should Be Correct  ${metrics}

   Network Should be in Range  ${metrics}

ClusterMetrics - Shall be able to get the docker cluster Network metrics with starttime and endtime and last on openstack
   [Documentation]
   ...  request all docker cluster Network metrics with starttime and endtime and last on openstack
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with starttime and endtime and last on openstack     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Headings Should Be Correct  ${metrics}

   Network Should be in Range  ${metrics}

ClusterMetrics - DeveloperManager shall be able to get docker cluster Network metrics
   [Documentation]
   ...  request the docker cluster Network metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperManager shall be able to get cluster metrics  ${username}  ${password}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should be in Range  ${metrics}

ClusterMetrics - DeveloperContributor shall be able to get docker cluster Network metrics
   [Documentation]
   ...  request the docker cluster Network metrics as DeveloperContributor
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperContributor shall be able to get cluster metrics  ${username}  ${password}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should be in Range  ${metrics}

ClusterMetrics - DeveloperViewer shall be able to get docker cluster Network metrics
   [Documentation]
   ...  request the docker cluster Network metrics as DeveloperViewer
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperViewer shall be able to get cluster metrics  ${username}  ${password}  ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should be in Range  ${metrics}

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

   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-network
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  dev
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  operator 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  recvBytes
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  sendBytes

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
	
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[5]} > 0 and ${reading[6]} > 0

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

   ${metrics_length}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   ${influx_length}=   Get Length  ${metrics_influx_t}
   Should Be Equal  ${metrics_length}  ${influx_length}

   #Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][0]}' != '${metrics_influx[0]['time']}'  Remove From List  ${metrics_influx}  0  #remove 1st item if newer than ws
   #...  ELSE  Remove From List  ${metrics_influx}  -1  #remove last item
   #log to console  ${metrics_influx}

   ${index}=  Set Variable  0
   : FOR  ${reading}  IN  @{metrics_influx_t}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][5]}  ${reading['recvBytes']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][6]}  ${reading['sendBytes']}

   \  ${index}=  Evaluate  ${index}+1
