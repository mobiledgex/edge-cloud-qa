*** Settings ***
Documentation   k8s Cluster Network Metrics

#Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
#LIbrary  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
#Library  DateTime
#Library  String
#Library  Collections
Resource  ../metrics_cluster_library.robot

Test Setup       Setup
#Test Teardown    Cleanup provisioning
#Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   packetcloudlet
${operator}=                       packet
${clustername_k8dedicated}=   k8sdedicated
${developer_name}=  testmonitor

#${username_admin}=  testuser
#${password_admin}=  mexadmin123

${username}=  testuser
${password}=  testuser
${orgname}=   testmonitor

${region}=  US

*** Test Cases ***
ClusterMetrics - k8s Dedicated Cluster NETWORK metric on openstack
   [Documentation]
   ...  request k8s cluster Network metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last cluster metric on openstack   ${clustername_k8dedicated}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   log  ${metrics}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}


ClusterMetrics - last 5 k8s Dedicated Cluster NETWORK metric on openstack
   [Documentation]
   ...  request k8s cluster Network metrics with last=5
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 5 cluster metrics on openstack     ${clustername_k8dedicated}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  network

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   log  ${metrics}

   Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

*** Keywords ***
Setup
   #${limits}=  Get Openstack limits
   #Set Suite Variable  ${limits}

   ${timestamp}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   #${clustername}=  Get Default Cluster Name
   ${clustername_k8dedicated}=  set variable  k8sdedicated
   ${developer_name}=  Set Variable  testmonitor

   #${clustername_k8dedicated}=   Set Variable  cluster1574811700-5411682-k8sshared
   #${developer_name}=  Set Variable  developer1574811700-5411682

   #${clustername_k8dedicated}=   Set Variable  cluster1574873355-539982-k8sshared
   #${developer_name}=  Set Variable  developer1574873355-539982

   Set Suite Variable  ${clustername_k8dedicated}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${timestamp}

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-network
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  sendBytes
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  recvBytes

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
    FOR  ${reading}  IN  @{values}
     Should Be True               ${reading[5]} > 0 and ${reading[6]} > 0
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
   #${metrics_length}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   #${influx_length}=   Get Length  ${metrics_influx_t}
   #Should Be Equal  ${metrics_length}  ${influx_length}

   #Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][0]}' != '${metrics_influx[0]['time']}'  Remove From List  ${metrics_influx}  0  #remove 1st item if newer than ws
   #...  ELSE  Remove From List  ${metrics_influx}  -1  #remove last item
   #log to console  ${metrics_influx}

   ${index}=  Set Variable  0
#   : FOR  ${reading}  IN  @{metrics_influx_t}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][6]}  ${reading['recvBytes']}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][5]}  ${reading['sendBytes']}
#   \  ${index}=  Evaluate  ${index}+1
    FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
     Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
     Should Be Equal  ${metrics_influx_t[${index}]['sendBytes']}   ${reading[5]}
     Should Be Equal  ${metrics_influx_t[${index}]['recvBytes']}   ${reading[6]}
     ${index}=  Evaluate  ${index}+1
   END
