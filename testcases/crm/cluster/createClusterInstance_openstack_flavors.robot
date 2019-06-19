*** Settings ***
Documentation  Cluster size for openstack
...  ram  vcpus  disk  num_nodes  azure
...  1024   1     1       1      m4.small
...  2048   2     2       1      m4.small
...  4096   4     4       1      sdwan-ESC
...  1024  20    error exceeding quota
...  512    1     1              error toosmall
...  8192   4    40              m4.large
...  16384  8   160              m4.xlarge
...  8192   1     1              sdwan-ESC
...  1024   1   160
...  master and node different flavor
		
Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack}  automationBonnCloudlet
${operator_name_openstack}  TDG 
#${cluster_name}=  cluster1556727500-74324

${test_timeout_crm}  15 min
	
*** Test Cases ***
Cluster with flavor less than 20g on openstack shall fail with size too small
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=512  vcpus=1  disk=1
   ...  verify fails since it maps size=m4.tiny on openstack which has a disk of 10g. Must be at least 20g

   Create Flavor  ram=512  vcpus=1  disk=1
   #Create Cluster  #cluster_name=${cluster_name}

   ${cluster_name}=  Get Default Cluster Name

   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "Encountered failures: Create failed: Insufficient disk size, please specify a flavor with at least 20gb"

Cluster with vcpus=1 and ram=1024 on openstack shall be m4.small
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=1024  vcpus=1  disk=1
   ...  verify it allocates size=m4.small on openstack

   Create Flavor  ram=1024  vcpus=1  disk=1
   #Create Cluster  #cluster_name=${cluster_name}

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}
   Log to Console  DONE creating cluster instance

   ${server_info}=  Get Openstack Server List  name=${cluster_name}
   Should Be Equal   ${server_info[0]['Flavor']}  m4.small
   Should Be Equal   ${server_info[1]['Flavor']}  m4.small 

   ${num_servers}=   Get Length  ${server_info}
   Should Be Equal As Numbers  ${num_servers}  2   # master + 1 nodes

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal  ${cluster_inst.node_flavor}   m4.small 
	
   #Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=2 and ram=2048 on openstack shall be m4.small
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=2048  vcpus=2  disk=2
   ...  verify it allocates size=m4.small on openstack

   Create Flavor  ram=2048  vcpus=2  disk=2
   #Create Cluster  

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}
   Log to Console  DONE creating cluster instance

   ${server_info}=  Get Openstack Server List  name=${cluster_name}
   Should Be Equal   ${server_info[0]['Flavor']}  m4.small
   Should Be Equal   ${server_info[1]['Flavor']}  m4.small

   ${num_servers}=   Get Length  ${server_info}
   Should Be Equal As Numbers  ${num_servers}  2   # master + 1 nodes

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal  ${cluster_inst.node_flavor}   m4.small

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=4 and ram=4096 on openstack shall be sdwan-ESC
   [Documentation]
   ...  create a cluster on azure with flavor of ram=4096  vcpus=4  disk=4
   ...  verify it allocates size=sdwan-ESC on openstack

   Create Flavor  ram=4096  vcpus=4  disk=4
   #Create Cluster  

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}
   Log to Console  DONE creating cluster instance

   ${server_info}=  Get Openstack Server List  name=${cluster_name}
   Should Be Equal   ${server_info[0]['Flavor']}  flavor_ESC_ESC
   Should Be Equal   ${server_info[0]['Flavor']}  flavor_ESC_ESC

   ${num_servers}=   Get Length  ${server_info}
   Should Be Equal As Numbers  ${num_servers}  2   # master + 1 nodes

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal  ${cluster_inst.node_flavor}   flavor_ESC_ESC 

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=4 and ram=8192 and disk=40 on openstack shall be m4.large
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=8192  vcpus=4  disk=40
   ...  verify it allocates size=m4.large on openstack

   Create Flavor  ram=8192  vcpus=4  disk=40
   #Create Cluster  #cluster_name=${cluster_name}

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}
   Log to Console  DONE creating cluster instance

   ${server_info}=  Get Openstack Server List  name=${cluster_name}
   Should Be Equal   ${server_info[0]['Flavor']}  m4.large
   Should Be Equal   ${server_info[1]['Flavor']}  m4.large 

   ${num_servers}=   Get Length  ${server_info}
   Should Be Equal As Numbers  ${num_servers}  2   # master + 1 nodes

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal  ${cluster_inst.node_flavor}     m4.large
	
   #Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=8 and ram=16384 and disk=160 on openstack shall be m4.xlarge
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=16384  vcpus=8  disk=160
   ...  verify it allocates size=m4.xlarge on openstack

   Create Flavor  ram=16384  vcpus=8  disk=160
   #Create Cluster  #cluster_name=${cluster_name}

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}
   Log to Console  DONE creating cluster instance

   ${server_info}=  Get Openstack Server List  name=${cluster_name}
   Should Be Equal   ${server_info[0]['Flavor']}  m4.xlarge
   Should Be Equal   ${server_info[1]['Flavor']}  m4.xlarge 

   ${num_servers}=   Get Length  ${server_info}
   Should Be Equal As Numbers  ${num_servers}  2   # master + 1 nodes

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal  ${cluster_inst.node_flavor}     m4.xlarge
	
   #Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=1 and ram=8192 and disk=1 on openstack shall be sdwan-ESC
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=8192  vcpus=1  disk=1
   ...  verify it allocates size=sdwan-ESC on openstack

   Create Flavor  ram=8192  vcpus=1  disk=1
   #Create Cluster  #cluster_name=${cluster_name}

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}
   Log to Console  DONE creating cluster instance

   ${server_info}=  Get Openstack Server List  name=${cluster_name}
   Should Be Equal   ${server_info[0]['Flavor']}  flavor_ESC_ESC
   Should Be Equal   ${server_info[1]['Flavor']}  flavor_ESC_ESC 

   ${num_servers}=   Get Length  ${server_info}
   Should Be Equal As Numbers  ${num_servers}  2   # master + 1 nodes

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal  ${cluster_inst.node_flavor}   flavor_ESC_ESC
	
   #Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=1 and ram=1024 and disk=160 on openstack shall be m4.xlarge
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=1024  vcpus=1  disk=160
   ...  verify it allocates size=sdwan-ESC on openstack

   Create Flavor  ram=1024  vcpus=1  disk=160
   #Create Cluster  #cluster_name=${cluster_name}

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}
   Log to Console  DONE creating cluster instance

   ${server_info}=  Get Openstack Server List  name=${cluster_name}
   Should Be Equal   ${server_info[0]['Flavor']}  m4.xlarge
   Should Be Equal   ${server_info[1]['Flavor']}  m4.xlarge 

   ${num_servers}=   Get Length  ${server_info}
   Should Be Equal As Numbers  ${num_servers}  2   # master + 1 nodes

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal  ${cluster_inst.node_flavor}     m4.xlarge
	
   #Sleep  120 seconds  #wait for metrics apps to build before can delete

#Cluster shall create with different master and node flavors on openstack
#   [Documentation]
#   ...  create a cluster on openstack with different node and maste flavors
#   ...  verify it allocates different flavors for mastor and nodes
#
#   ${epoch_time}=  Get Time  epoch
#   ${flavor_name_1}=    Catenate  SEPARATOR=  flavor  ${epoch_time}  _1
#   ${flavor_name_2}=    Catenate  SEPARATOR=  flavor  ${epoch_time}  _2
#	
#   Create Flavor          flavor_name=${flavor_name_1}  ram=1024  vcpus=1  disk=1
#   Create Flavor          flavor_name=${flavor_name_2}  ram=4096  vcpus=4  disk=4
#   Create Cluster Flavor  number_nodes=4  node_flavor_name=${flavor_name_1}  master_flavor_name=${flavor_name_2}
#   Create Cluster        
#
#   ${cluster_name}=  Get Default Cluster Name
#
#   Log to Console  START creating cluster instance
#   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  
#   Log to Console  DONE creating cluster instance
#
#   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
#   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}
#
#   ${server_info_node}=    Get Openstack Server List  name=${openstack_node_name}
#   ${server_info_master}=  Get Openstack Server List  name=${openstack_node_master}
#   Should Be Equal   ${server_info_node[0]['Flavor']}    m4.small
#   Should Be Equal   ${server_info_node[1]['Flavor']}    m4.small
#   Should Be Equal   ${server_info_node[2]['Flavor']}    m4.small
#   Should Be Equal   ${server_info_node[3]['Flavor']}    m4.small
#   Should Be Equal   ${server_info_master[0]['Flavor']}  sdwan-ESC
#   
#   ${num_servers_node}=     Get Length  ${server_info_node}
#   ${num_servers_master}=   Get Length  ${server_info_master}
#   Should Be Equal As Numbers  ${num_servers_node}    4   # 4 nodes
#   Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
#
#   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
#   Should Be Equal  ${cluster_inst.node_flavor}    m4.small
#
#   Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster with vcpus=20 and ram=4096 on openstack shall fail with no flavor found
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=4096  vcpus=20  disk=4
   ...  verify it fails since it cannot find a suitable flavor

   Create Flavor  ram=4096  vcpus=30  disk=4
   #Create Cluster  

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}

   Cluster Instance Should Not Exist  cluster_name=${cluster_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   ${flavor_msg}=  Catenate  SEPARATOR=  no suitable platform flavor found for  ${SPACE}  ${flavor_name}  , please try a smaller flavor
   Should Contain  ${error_msg}   ${flavor_msg}

Cluster with vcpus=1 and ram=40960 on openstack shall fail with no flavor found
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=40960  vcpus=  disk=1
   ...  verify it fails since it cannot find a suitable flavor

   Create Flavor  ram=40960  vcpus=1  disk=1
   #Create Cluster  

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}

   Cluster Instance Should Not Exist  cluster_name=${cluster_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   ${flavor_msg}=  Catenate  SEPARATOR=  no suitable platform flavor found for  ${SPACE}  ${flavor_name}  , please try a smaller flavor
   Should Contain  ${error_msg}   ${flavor_msg}

Cluster with vcpus=1 and ram=1024 and disk=1000 on openstack shall fail with no flavor found
   [Documentation]
   ...  create a cluster on openstack with flavor of ram=1024  vcpus=1  disk=1000
   ...  verify it fails since it cannot find a suitable flavor

   Create Flavor  ram=1024  vcpus=1  disk=1000
   #Create Cluster  

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}

   Cluster Instance Should Not Exist  cluster_name=${cluster_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   ${flavor_msg}=  Catenate  SEPARATOR=  no suitable platform flavor found for  ${SPACE}  ${flavor_name}  , please try a smaller flavor
   Should Contain  ${error_msg}   ${flavor_msg}

*** Keywords ***
Setup
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack}
    Set Suite Variable  ${cloudlet_lowercase}
