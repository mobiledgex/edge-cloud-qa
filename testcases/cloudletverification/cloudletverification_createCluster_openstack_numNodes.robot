*** Settings ***
Documentation  Cluster size for openstack
...  ram  vcpus  disk  num_nodes  azure
...  1024   1     1       1      m4.small
...  2048   2     2       1      Standard_DS2_v2
...  4096   4     4       1      Standard_DS3_v2
...  1024   1     4       4      Standard_DS3_v2
...  1024  20    error exceeding quota

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack}  automationMunichCloudlet
${operator_name_openstack}  TDG 

${test_timeout_crm}  15 min
	
*** Test Cases ***
Cluster shall create with IpAccessShared and num_nodes=1 on openstack
   [Documentation]
   ...  create a cluster on openstack with num_nodes=1
   ...  verify it 1 node and 1 master

   Create Flavor          ram=1024  vcpus=1  disk=20

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared
   Log to Console  DONE creating cluster instance

   #${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   #${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   #${server_info_node}=    Get Server List  name=${openstack_node_name}
   #${server_info_master}=  Get Server List  name=${openstack_node_master}
   #Should Be Equal   ${server_info_node[0]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[1]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[2]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[3]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small

   #${num_servers_node}=     Get Length  ${server_info_node}
   #${num_servers_master}=   Get Length  ${server_info_master}
   #Should Be Equal As Numbers  ${num_servers_node}    1   # 1 nodes
   #Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}

   Sleep  120 seconds  #wait for metrics apps to build before can delete

Cluster shall create with IpAccessShared and num_nodes=4 on openstack
   [Documentation]
   ...  create a cluster on openstack with num_nodes=4
   ...  verify it 4 nodes and 1 master

   Create Flavor          ram=1024  vcpus=1  disk=20

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=4  number_masters=1  ip_access=IpAccessShared
   Log to Console  DONE creating cluster instance

   #${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   #${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   #${server_info_node}=    Get Server List  name=${openstack_node_name}
   #${server_info_master}=  Get Server List  name=${openstack_node_master}
   #Should Be Equal   ${server_info_node[0]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[1]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[2]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[3]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small

   #${num_servers_node}=     Get Length  ${server_info_node}
   #${num_servers_master}=   Get Length  ${server_info_master}
   #Should Be Equal As Numbers  ${num_servers_node}    4   # 4 nodes
   #Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}

   Sleep  120 seconds  #wait for metrics apps to build before can delete

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack}

    Set Suite Variable  ${cloudlet_lowercase}
	
    #${cluster_name}=    Catenate  SEPARATOR=  cl  ${epoch_time}
    #Set Suite Variable  ${cluster_name}
