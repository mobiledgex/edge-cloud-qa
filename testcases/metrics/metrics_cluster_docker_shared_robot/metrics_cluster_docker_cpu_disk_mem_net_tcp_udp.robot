*** Settings ***
Documentation   Docker Cluster CPU/Memory/Disk/Network/UDP/TCP Metrics

Resource  ../metrics_cluster_library.robot
	      
Test Setup       Setup
#Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBuckhornCloudlet
${operator}=                       GDDT
${clustername_docker}=   cluster1574731678-0317152-k8sdedicated
${developer_name}=  developer1574731678-0317152 

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  ${mextester06_gmail_password}
${orgname}=   metricsorg

*** Test Cases ***
ClusterMetrics - Shall be able to get the last 5 docker cluster CPU/Network/TCP/UDP/Mem/Disk metrics on openstack
   [Documentation]
   ...  request cluster CPU metrics with all selectors
   ...  verify info is correct

   ${metrics}=  Get the last 5 cluster metrics on openstack for multiple selectors     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  cpu,network,tcp,udp,mem,disk

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}
   Disk Should Be In Range  ${metrics}
   Memory Should Be In Range  ${metrics}
   Network Should Be In Range  ${metrics}
   TCP Should Be In Range  ${metrics}
   UDP Should Be In Range  ${metrics}

ClusterMetrics - Shall be able to get the last 5 docker cluster wildcard metrics on openstack
   [Documentation]
   ...  request cluster CPU metrics with wildcard selector 
   ...  verify info is correct

   ${metrics}=  Get the last 5 cluster metrics on openstack for multiple selectors     ${clustername_docker}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  cpu,network,tcp,udp,mem,disk

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}
   Disk Should Be In Range  ${metrics}
   Memory Should Be In Range  ${metrics}
   Network Should Be In Range  ${metrics}
   TCP Should Be In Range  ${metrics}
   UDP Should Be In Range  ${metrics}

*** Keywords ***
Setup
   #${limits}=  Get Openstack limits
   #Set Suite Variable  ${limits}
   
   ${timestamp}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   ${clustername_docker}=  Get Default Cluster Name
   #${clustername_k8dedicated}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -k8sdedicated

   #${clustername_k8dedicated}=   Set Variable  cluster1582840989-090443-k8sdedicated 
   #${developer_name}=  Set Variable  mobiledgex 

   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${developer_name}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-udp
   Should Be Equal  ${metrics['data'][0]['Series'][1]['name']}        cluster-tcp
   Should Be Equal  ${metrics['data'][0]['Series'][2]['name']}        cluster-network
   Should Be Equal  ${metrics['data'][0]['Series'][3]['name']}        cluster-mem
   Should Be Equal  ${metrics['data'][0]['Series'][4]['name']}        cluster-disk
   Should Be Equal  ${metrics['data'][0]['Series'][5]['name']}        cluster-cpu

   FOR  ${i}  IN RANGE  0  6
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][0]}  time
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][1]}  cluster
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][2]}  clusterorg 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][3]}  cloudlet
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][4]}  cloudletorg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][5]}  cpu
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][6]}  sendBytes 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][7]}  recvBytes 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][8]}  tcpConns 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][9]}  tcpRetrans 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][10]}  udpSent 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][11]}  udpRecv
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][12]}  udpRecvErr
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][13]}  mem
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][14]}  disk 
   END 

CPU Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be True               ${reading[5]} >= 0 and ${reading[5]} <= 100
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[5]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[5]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[5]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[5]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[5]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be True               ${reading[14]} > 0 and ${reading[14]} <= 100
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[14]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[14]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[14]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[14]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[14]}  ${None}
   END

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be True               ${reading[13]} > 0 and ${reading[13]} <= 100
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[13]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[13]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[13]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[13]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[13]}  ${None}
   END

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be True               ${reading[6]} > 0 and ${reading[7]} > 0
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[6]}  ${None}
       Should Be Equal               ${reading[7]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[6]}  ${None}
       Should Be Equal               ${reading[7]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[6]}  ${None}
       Should Be Equal               ${reading[7]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[6]}  ${None}
       Should Be Equal               ${reading[7]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[7]}  ${None}
       Should Be Equal               ${reading[6]}  ${None}
   END

TCP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be True               ${reading[8]} >= 0 and ${reading[9]} >= 0
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[8]}  ${None}
       Should Be Equal               ${reading[9]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[8]}  ${None}
       Should Be Equal               ${reading[9]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[8]}  ${None}
       Should Be Equal               ${reading[9]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[8]}  ${None}
       Should Be Equal               ${reading[9]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be Equal               ${reading[8]}  ${None}
       Should Be Equal               ${reading[9]}  ${None}
   END

UDP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   FOR  ${reading}  IN  @{values}
       Should Be True               ${reading[10]} >= 0 and ${reading[11]} >= 0 and ${reading[12]} >= 0
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END


