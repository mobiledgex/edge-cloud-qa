*** Settings ***
Documentation  Create ClusterInst stats

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
Library  DateTime
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  40 minutes
	
*** Variables ***
#${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationBonnCloudlet
${operator_name}  TDG

#${cloudlet_name_azure}      automationAzureCentralCloudlet
#${operator_name_azure}      azure

#${cluster_name}=  cluster1556230478-498355
*** Test Cases ***
ClusterInst Stats shall be created on openstack
    [Documentation]
    ...  create a clusterInst on azure
    ...  verify cluster stats are generated

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}
   Log To Console  Done Creating Cluster Instance

   Sleep  30 minutes

   ${values}=  Get Cluster Stats  cluster_name=${cluster_name}

   ${num_stats}=  Get Length  ${values}
   Should Be True  ${num_stats} > 0

   : FOR  ${x}  IN RANGE  0  ${num_stats}
   \  Log To Console  ${values[${x}]}
   \  Should Be Equal  ${values[${x}]['cloudlet']}   ${cloudlet_name_openstack}
   \  Should Be Equal  ${values[${x}]['cluster']}    ${cluster_name}
   \  Should Be Equal  ${values[${x}]['operator']}   ${operator_name}
   \  Should Be True   ${values[${x}]['cpu']} > 0 
   \  Should Be True   ${values[${x}]['disk']} > 0
   \  Should Be True   ${values[${x}]['mem']} > 0
   \  Should Be True   ${values[${x}]['recvBytes']} > 0   
   \  Should Be True   ${values[${x}]['sendBytes']} > 0
   \  Should Be True   ${values[${x}]['tcpConns']} > 0
   \  Should Be True   ${values[${x}]['tcpRetrans']} == 0
   \  Should Be True   ${values[${x}]['udpRecv']} > 0            
   \  Should Be True   ${values[${x}]['udpRecvErr']} == 0            
   \  Should Be True   ${values[${x}]['udpSend']} > 0
   \  Should Contain   ${values[${x}]['time']}  ${CurrentDate}

Cluster Stats shall be created on azure
    [Documentation]
    ...  create a clusterInst on azure
    ...  verify cluster stats are generated

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name_azure}
   #Create Cluster Instance  cloudlet_name=localtest  operator_name=mexdev
   Log To Console  Done Creating Cluster Instance

   Sleep  3 minutes

   #${columns}  ${values}=  Get Cluster Stats  cluster_name=${cluster_name}
   ${values}=  Get Cluster Stats  cluster_name=${cluster_name}
   #Log To Console  ${columns[2]}
   #Log To Console  ${values}

   ${num_stats}=  Get Length  ${values}
   Should Be True  ${num_stats} > 0

   : FOR  ${x}  IN RANGE  0  ${num_stats}
   \  Log To Console  ${values[${x}]}
   \  Should Be Equal  ${values[${x}]['cloudlet']}   ${cloudlet_name_openstack}
   \  Should Be Equal  ${values[${x}]['cluster']}    ${cluster_name}
   \  Should Be Equal  ${values[${x}]['operator']}   ${operator_name}
   \  Should Be True   ${values[${x}]['cpu']} > 0 
   \  Should Be True   ${values[${x}]['disk']} > 0
   \  Should Be True   ${values[${x}]['mem']} > 0
   \  Should Be True   ${values[${x}]['recvBytes']} > 0   
   \  Should Be True   ${values[${x}]['sendBytes']} > 0
   \  Should Be True   ${values[${x}]['tcpConns']} > 0
   \  Should Be True   ${values[${x}]['tcpRetrans']} == 0
   \  Should Be True   ${values[${x}]['udpRecv']} > 0            
   \  Should Be True   ${values[${x}]['udpRecvErr']} == 0            
   \  Should Be True   ${values[${x}]['udpSend']} > 0
   \  Should Contain   ${values[${x}]['time']}  ${CurrentDate}
	            

*** Keywords ***
Setup
   ${epoch_time}=  Get Time  epoch
   ${cluster_name}=    Catenate  SEPARATOR=  cl  ${epoch_time}

   Create Flavor
   Create Cluster Flavor
   #Create Cluster  cluster_name=${cluster_name} 

   ${cluster_name}=  Get Default Cluster Name
   Set Suite Variable  ${cluster_name}

   ${CurrentDate}=  Get Current Date  result_format=%Y-%m-%d

   ${datetime} =	Convert Date  ${CurrentDate}  datetime
   Set Suite Variable  ${datetime}
   Set Suite Variable  ${CurrentDate}
   Log  ${datetime.year}	
   Log	 ${datetime.month}
