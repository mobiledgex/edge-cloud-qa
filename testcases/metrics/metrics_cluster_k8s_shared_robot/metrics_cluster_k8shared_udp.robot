*** Settings ***
Documentation   K8s Shared Cluster UDP Metrics

#Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
#Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
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
${clustername_k8shared}=   cluster1574731678-0317152-k8sshared
${developer_name}=  developer1574731678-0317152 

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  ${mextester06_gmail_password}
${orgname}=   metricsorg
	
*** Test Cases ***
ClusterMetrics - Shall be able to get the last k8s shared cluster UDP metric on openstack
   [Documentation]
   ...  request cluster UDP metrics with last=1 
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last cluster metric on openstack   ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp 

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}
	
   Metrics Headings Should Be Correct  ${metrics}
	
   UDP Should Be In Range  ${metrics}
   
	
ClusterMetrics - Shall be able to get the last 5 k8s shared cluster UDP metrics on openstack
   [Documentation]
   ...  request cluster UDP metrics with last=5
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 5 cluster metrics on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get the last 10 k8s shared cluster UDP metrics on openstack
   [Documentation]
   ...  request cluster UDP metrics with last=10
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 10 cluster metrics on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get all k8s shared cluster UDP metrics on openstack
   [Documentation]
   ...  request all cluster UDP metrics
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get all cluster metrics on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to request more k8s shared cluster UDP metrics than exist on openstack
   [Documentation]
   ...  request cluster UDP metrics with last=<greater than total number of metrics>
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get more cluster metrics than exist on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get k8s shared cluster UDP metrics with starttime on openstack
   [Documentation]
   ...  request cluster UDP metrics with starttime 
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with starttime on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get k8s shared cluster UDP metrics with endtime on openstack
   [Documentation]
   ...  request cluster UDP metrics with endtime 
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with endtime on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Headings Should Be Correct  ${metrics}  

   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get the k8s shared cluster UDP metrics with starttime=lastrecord on openstack
   [Documentation]
   ...  request cluster UDP metrics with starttime=lastrecord 
   ...  verify info is correct

   #edgecloud-1338 Metrics - requesting cloudlet metrics with starttime=<time> does not return the reading with that time

   ${metrics}  ${metrics_influx}=  Get cluster metrics with starttime=lastrecord on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics} 

# errors when starttime is in the future
#ClusterMetrics - Shall be able to get the k8s shared cluster UDP metrics with starttime > lastrecord on openstack
#   [Documentation]
#   ...  request cloudlet metrics with starttime in the future
#   ...  verify empty list is returned
#
#   Get cluster metrics with starttime > lastrecord on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

ClusterMetrics - Shall be able to get the k8s shared cluster UDP metrics with endtime=lastrecord on openstack
   [Documentation]
   ...  request cluster UDP metrics with endtime=lastrecord
   ...  verify info is correct

   #EDGECLOUD-1648 Metrics - requesting metrics with endtime=lastrecord does not return the last record

   ${metrics}=  Get cluster metrics with endtime=lastrecord on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get the k8s shared cluster UDP metrics with endtime = firstrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with endtime = firstrecord 
   ...  verify empty list is returned

   Get cluster metrics with endtime = firstrecord on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

ClusterMetrics - Shall be able to get the k8s shared cluster UDP metrics with starttime > endtime on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime > endtime
   ...  verify empty list is returned

   Get cluster metrics with starttime > endtime on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

ClusterMetrics - Shall be able to get the k8s shared cluster UDP metrics with starttime and endtime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime/endtime in the future
   ...  verify empty list is returned

   Get cluster metrics with starttime and endtime > lastrecord on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

ClusterMetrics - Shall be able to get the k8s shared cluster UDP metrics with starttime and endtime on openstack
   [Documentation]
   ...  request cluster UDP metrics with starttime and endtime on openstack
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with starttime and endtime on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get the k8s shared cluster UDP metrics with starttime and endtime and last on openstack
   [Documentation]
   ...  request all cluster UDP metrics with starttime and endtime and last on openstack
   ...  verify info is correct

   ${metrics}=  Get cluster metrics with starttime and endtime and last on openstack     ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - DeveloperManager shall be able to get k8s shared cluster UDP metrics
   [Documentation]
   ...  request the cluster UDP metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperManager shall be able to get cluster metrics  ${username}  ${password}  ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - DeveloperContributor shall be able to get k8s shared cluster UDP metrics
   [Documentation]
   ...  request the cluster UDP metrics as DeveloperContributor
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperContributor shall be able to get cluster metrics  ${username}  ${password}  ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

ClusterMetrics - DeveloperViewer shall be able to get k8s shared cluster UDP metrics
   [Documentation]
   ...  request the cluster UDP metrics as DeveloperViewer
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperViewer shall be able to get cluster metrics  ${username}  ${password}  ${clustername_k8shared}  ${cloudlet_name_openstack_metrics}  ${operator_name_openstack}  ${developer_name}  udp

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

*** Keywords ***
Setup
   #${limits}=  Get Openstack limits
   #Set Suite Variable  ${limits}
   
   ${timestamp}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   #${clustername}=  Get Default Cluster Name
   ${clustername_k8shared}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -k8sshared

   #${clustername_k8shared}=   Set Variable  andycluster 
   #${developer_name}=  Set Variable  automation_api 

   Set Suite Variable  ${clustername_k8shared}
   Set Suite Variable  ${developer_name}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-udp
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  udpSent
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  udpRecv
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  udpRecvErr


UDP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
	
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[5]} >= 0 and ${reading[6]} >= 0 and ${reading[7]} >= 0
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
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][5]}  ${reading['udpRecv']}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][6]}  ${reading['udpRecvErr']}
   FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
      Should Be Equal  ${metrics_influx_t[${index}]['udpSent']}   ${reading[5]}
      Should Be Equal  ${metrics_influx_t[${index}]['udpRecv']}   ${reading[6]}
      Should Be Equal  ${metrics_influx_t[${index}]['udpRecvErr']}   ${reading[7]}

      ${index}=  Evaluate  ${index}+1
   END
