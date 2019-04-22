*** Settings ***
Documentation  Cluster size for azure
...  ram  vcpus  disk  num_nodes  azure
...  1024   1     1       1      Standard_DS1_v2
...  2048   2     2       1      Standard_DS2_v2
...  4096   4     4       1      Standard_DS3_v2
...  1024   1     4       4      Standard_DS3_v2
...  1024  20    error exceeding quota

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexAzure

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  15 minutes
	
*** Variables ***
${cloudlet_name_azure}  automationAzureCentralCloudlet
${operator_name}        azure
	
*** Test Cases ***
Cluster with vcpus=1 and ram=1024 on azure shall be Standard_DS1_v2
   [Documentation]
   ...  create a cluster on azure with flavor of ram=1024  vcpus=1  disk=1
   ...  verify it allocates size=Standard_DS1_v2 on azure

   Create Flavor  ram=1024  vcpus=1  disk=1
   Create Cluster Flavor 
   Create Cluster  cluster_name=${cluster_name}

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}
   Log to Console  DONE creating cluster instance

   ${cluster_info}=  Get Azure Cluster Info  cloudlet=${cloudlet_name_azure}  cluster=${cluster_name}
   Should Be Equal             ${cluster_info['properties']['agentPoolProfiles'][0]['vmSize']}  Standard_DS1_v2
   Should Be Equal As Numbers  ${cluster_info['properties']['agentPoolProfiles'][0]['count']}   1
	
   Should Be Equal  ${cluster_inst.node_flavor}     Standard_DS1_v2
   Should Be Equal  ${cluster_inst.master_flavor}   Standard_DS1_v2
	
   Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=2 and ram=2048 on azure shall be Standard_DS2_v2
   [Documentation]
   ...  create a cluster on azure with flavor of ram=2048  vcpus=2  disk=2
   ...  verify it allocates size=Standard_DS2_v2 on azure

   Create Flavor  ram=2048  vcpus=2  disk=2
   Create Cluster Flavor 
   Create Cluster  cluster_name=${cluster_name}

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}
   Log to Console  DONE creating cluster instance

   ${cluster_info}=  Get Azure Cluster Info  cloudlet=${cloudlet_name_azure}  cluster=${cluster_name}
   Should Be Equal             ${cluster_info['properties']['agentPoolProfiles'][0]['vmSize']}  Standard_DS2_v2
   Should Be Equal As Numbers  ${cluster_info['properties']['agentPoolProfiles'][0]['count']}   1
	
   Should Be Equal  ${cluster_inst.node_flavor}     Standard_DS2_v2
   Should Be Equal  ${cluster_inst.master_flavor}   Standard_DS2_v2

   Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=4 and ram=4096 on azure shall be Standard_DS3_v2
   [Documentation]
   ...  create a cluster on azure with flavor of ram=4096  vcpus=4  disk=4
   ...  verify it allocates size=Standard_DS3_v2 on azure

   Create Flavor  ram=4096  vcpus=4  disk=4
   Create Cluster Flavor 
   Create Cluster  cluster_name=${cluster_name}

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}
   Log to Console  DONE creating cluster instance

   ${cluster_info}=  Get Azure Cluster Info  cloudlet=${cloudlet_name_azure}  cluster=${cluster_name}
   Should Be Equal             ${cluster_info['properties']['agentPoolProfiles'][0]['vmSize']}  Standard_DS3_v2
   Should Be Equal As Numbers  ${cluster_info['properties']['agentPoolProfiles'][0]['count']}   1
	
   Should Be Equal  ${cluster_inst.node_flavor}     Standard_DS3_v2
   Should Be Equal  ${cluster_inst.master_flavor}   Standard_DS3_v2
	
   Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=1 and num_nodes=4 on azure shall be Standard_DS1_v2
   [Documentation]
   ...  create a cluster on azure with flavor of ram=1024  vcpus=4  disk=4 and num_nodes=4
   ...  verify it allocates size=Standard_DS3_v2 on azure

   Create Flavor          ram=1024  vcpus=1  disk=1
   Create Cluster Flavor  number_nodes=4
   Create Cluster         cluster_name=${cluster_name}

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}
   Log to Console  DONE creating cluster instance

   ${cluster_info}=  Get Azure Cluster Info  cloudlet=${cloudlet_name_azure}  cluster=${cluster_name}
   Should Be Equal             ${cluster_info['properties']['agentPoolProfiles'][0]['vmSize']}  Standard_DS1_v2
   Should Be Equal As Numbers  ${cluster_info['properties']['agentPoolProfiles'][0]['count']}   4

   Log to console   ${cluster_inst} 
   Should Be Equal  ${cluster_inst.node_flavor}     Standard_DS1_v2
   Should Be Equal  ${cluster_inst.master_flavor}   Standard_DS1_v2
	
   Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=20 and ram=4096 on azure shall fail with quota limit
   [Documentation]
   ...  create a cluster on azure with flavor of ram=4096  vcpus=20  disk=4
   ...  verify it fails since not it exceeds cpu quota

   Create Flavor  ram=4096  vcpus=20  disk=4
   Create Cluster Flavor 
   Create Cluster  cluster_name=${cluster_name}

   Log to Console  START creating cluster instance
   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}

   Cluster Instance Should Not Exist  cluster_name=${cluster_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   Operation results in exceeding quota limits of Core

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${cluster_name}=    Catenate  SEPARATOR=  cl  ${epoch_time}

    Set Suite Variable  ${cluster_name}
