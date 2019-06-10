*** Settings ***
Documentation  Create AppInst/ClusterInst stats

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
Library  DateTime
	
#Test Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout  40 minutes
	
*** Variables ***
${cloudlet_name_openstack}  automationBuckhornCloudlet
${operator_name}  GDDT

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

#${cloudlet_name_azure}      automationAzureCentralCloudlet
#${operator_name_azure}      azure

${cluster_name}=  cl1556576686
${CurrentDate}=   2019-04-29
*** Test Cases ***
AppInst and ClusterInst Stats shall be created on openstack
    [Documentation]
    ...  create a clusterInst and appInst on openstack
    ...  verify app and cluster stats are generated

   Log To Console  Creating Cluster Instance
#   Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}
   Log To Console  Done Creating Cluster Instance

   Log To Console  Creating App Instance
#   Create App  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  command=${docker_command}  #app_template=${apptemplate}  #default_flavor_name=${cluster_flavor_name}
#   Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  cluster_instance_name=${cluster_name}
#   ${app_name}=  Get Default App Name
   Log To Console  Done Creating App Instance

   Log To Console  Waiting for stats
#   Sleep  10 minutes

   ${cluster_values}=  Get Cluster Stats  cluster_name=${cluster_name}
   ${app_values}=      Get AppInst Stats  cluster_name=${cluster_name}

   ${num_stats_cluster}=  Get Length  ${cluster_values}
   ${num_stats_app}=      Get Length  ${app_values}
   Should Be True  ${num_stats_cluster} > 0
   Should Be True  ${num_stats_app} > 0

   : FOR  ${x}  IN RANGE  0  ${num_stats_cluster}
   \  Log To Console  ${cluster_values[${x}]}
   \  Should Be Equal  ${cluster_values[${x}]['cloudlet']}   ${cloudlet_name_openstack}
   \  Should Be Equal  ${cluster_values[${x}]['cluster']}    ${cluster_name}
   \  Should Be Equal  ${cluster_values[${x}]['operator']}   ${operator_name}
#   \  Should Be True   ${cluster_values[${x}]['cpu']} > 0 
#   \  Should Be True   ${cluster_values[${x}]['disk']} > 0
#   \  Should Be True   ${cluster_values[${x}]['mem']} > 0
#   \  Should Be True   ${cluster_values[${x}]['recvBytes']} > 0   
#   \  Should Be True   ${cluster_values[${x}]['sendBytes']} > 0
#   \  Should Be True   ${cluster_values[${x}]['tcpConns']} > 0
#   \  Should Be True   ${cluster_values[${x}]['tcpRetrans']} == 0
#   \  Should Be True   ${cluster_values[${x}]['udpRecv']} > 0            
#   \  Should Be True   ${cluster_values[${x}]['udpRecvErr']} == 0            
#   \  Should Be True   ${cluster_values[${x}]['udpSend']} > 0
   \  Should Contain   ${cluster_values[${x}]['time']}  ${CurrentDate}

   : FOR  ${x}  IN RANGE  0  ${num_stats_app}
   \  Log To Console  ${app_values[${x}]['app']}
#   \  Should Be Equal  ${app_values[${x}]['app']}        ${cloudlet_name_openstack}
   \  Should Be Equal  ${app_values[${x}]['cloudlet']}   ${cloudlet_name_openstack}
   \  Should Be Equal  ${app_values[${x}]['cluster']}    ${cluster_name}
   \  Should Be Equal  ${app_values[${x}]['operator']}   ${operator_name}
   #\  Should Be True   ${app_values[${x}]['cpu']} > 0 
   #\  Should Be True   ${app_values[${x}]['disk']} > 0
   #\  Should Be True   ${app_values[${x}]['mem']} > 0
   #\  Should Be True   ${app_values[${x}]['recvBytes']} > 0   
   #\  Should Be True   ${app_values[${x}]['sendBytes']} > 0
#   \  Should Be True   ${app_values[${x}]['tcpConns']} > 0
#   \  Should Be True   ${app_values[${x}]['tcpRetrans']} == 0
#   \  Should Be True   ${app_values[${x}]['udpRecv']} > 0            
#   \  Should Be True   ${app_values[${x}]['udpRecvErr']} == 0            
#   \  Should Be True   ${app_values[${x}]['udpSend']} > 0
   \  Should Contain   ${app_values[${x}]['time']}  ${CurrentDate}


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
