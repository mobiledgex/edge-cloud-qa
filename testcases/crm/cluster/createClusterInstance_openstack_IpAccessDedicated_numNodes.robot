*** Settings ***
Documentation  Cluster size for openstack with IpAccessDedicated
...  ram  vcpus  disk  num_nodes  azure
...  1024   1     1       1      m4.small
...  2048   2     2       1      Standard_DS2_v2
...  4096   4     4       1      Standard_DS3_v2
...  1024   1     4       4      Standard_DS3_v2
...  1024  20    error exceeding quota

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  15 minutes
	
*** Variables ***
${cloudlet_name_openstack}  automationBonnCloudlet
${operator_name_openstack}  TDG 
${mobiledgex_domain}  mobiledgex.net
#${cluster_name}=  cluster1556727500-74324
	
*** Test Cases ***
ClusterInst shall create with IpAccessDedicated and num_nodes=1 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master

   Create Flavor          ram=1024  vcpus=1  disk=1
   Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Openstack Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Openstack Server List  name=${openstack_node_master}
   ${server_info_lb}=      Get Openstack Server List  name=${clusterlb}

   Should Be Equal   ${server_info_node[0]['Flavor']}   m4.small
   Should Contain    ${server_info_node[0]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[0]['Status']}   ACTIVE
	
   Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small
   Should Contain    ${server_info_master[0]['Image']}   mobiledgex
   Should Be Equal   ${server_info_master[0]['Status']}  ACTIVE

   Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.small
   Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
   Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE

   ${num_servers_node}=     Get Length  ${server_info_node}
   ${num_servers_master}=   Get Length  ${server_info_master}
   ${num_servers_lb}=       Get Length  ${server_info_lb}
   Should Be Equal As Numbers  ${num_servers_node}    1   # 3 nodes
   Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
   Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

   Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal             ${cluster_inst.node_flavor}   m4.small
   Should Be Equal As Numbers  ${cluster_inst.num_masters}   1
   Should Be Equal As Numbers  ${cluster_inst.num_nodes}     1
   Should Be Equal As Numbers  ${cluster_inst.ip_access}     1  #IpAccessDedicated

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

ClusterInst shall create with IpAccessDedicated and num_nodes=3 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and num_nodes=3
   ...  verify it creates 1 lb and 3 nodes and 1 master

   Create Flavor          ram=1024  vcpus=1  disk=1
   Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=3  number_masters=1  ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Openstack Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Openstack Server List  name=${openstack_node_master}
   ${server_info_lb}=      Get Openstack Server List  name=${clusterlb}

   Should Be Equal   ${server_info_node[0]['Flavor']}   m4.small
   Should Contain    ${server_info_node[0]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[0]['Status']}   ACTIVE
	
   Should Be Equal   ${server_info_node[1]['Flavor']}   m4.small
   Should Contain    ${server_info_node[1]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[1]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[2]['Flavor']}   m4.small
   Should Contain    ${server_info_node[2]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[2]['Status']}   ACTIVE

   Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small
   Should Contain    ${server_info_master[0]['Image']}   mobiledgex
   Should Be Equal   ${server_info_master[0]['Status']}  ACTIVE

   Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.small
   Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
   Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE

   ${num_servers_node}=     Get Length  ${server_info_node}
   ${num_servers_master}=   Get Length  ${server_info_master}
   ${num_servers_lb}=       Get Length  ${server_info_lb}
   Should Be Equal As Numbers  ${num_servers_node}    3   # 3 nodes
   Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
   Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

   Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal             ${cluster_inst.node_flavor}   m4.small
   Should Be Equal As Numbers  ${cluster_inst.num_masters}   1
   Should Be Equal As Numbers  ${cluster_inst.num_nodes}     3
   Should Be Equal As Numbers  ${cluster_inst.ip_access}     1  #IpAccessDedicated

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

ClusterInst shall create with IpAccessDedicated and num_nodes=12 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and num_nodes=12
   ...  verify it creates 1 lb and 12 nodes and 1 master

   Create Flavor          ram=8192  vcpus=4  disk=40
   Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=12  number_masters=1  ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  "node  \\d+  ${cloudlet_lowercase}  ${cluster_name}"
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Openstack Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Openstack Server List  name=${openstack_node_master}
   ${server_info_lb}=      Get Openstack Server List  name=${clusterlb}

   Should Be Equal   ${server_info_node[0]['Flavor']}   m4.large
   Should Contain    ${server_info_node[0]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[0]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[1]['Flavor']}   m4.large
   Should Contain    ${server_info_node[1]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[1]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[2]['Flavor']}   m4.large
   Should Contain    ${server_info_node[2]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[2]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[3]['Flavor']}   m4.large
   Should Contain    ${server_info_node[3]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[3]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[4]['Flavor']}   m4.large
   Should Contain    ${server_info_node[4]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[4]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[5]['Flavor']}   m4.large
   Should Contain    ${server_info_node[5]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[5]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[6]['Flavor']}   m4.large
   Should Contain    ${server_info_node[6]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[6]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[7]['Flavor']}   m4.large
   Should Contain    ${server_info_node[7]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[7]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[8]['Flavor']}   m4.large
   Should Contain    ${server_info_node[8]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[8]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[9]['Flavor']}   m4.large
   Should Contain    ${server_info_node[9]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[9]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[10]['Flavor']}   m4.large
   Should Contain    ${server_info_node[10]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[10]['Status']}   ACTIVE

   Should Be Equal   ${server_info_node[11]['Flavor']}   m4.large
   Should Contain    ${server_info_node[11]['Image']}    mobiledgex
   Should Be Equal   ${server_info_node[11]['Status']}   ACTIVE

   Should Be Equal   ${server_info_master[0]['Flavor']}  m4.large

   Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.large
   Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
   Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE

   ${num_servers_node}=     Get Length  ${server_info_node}
   ${num_servers_master}=   Get Length  ${server_info_master}
   ${num_servers_lb}=       Get Length  ${server_info_lb}
   Should Be Equal As Numbers  ${num_servers_node}    12   # 12 nodes
   Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
   Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

   Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal             ${cluster_inst.node_flavor}   m4.large
   Should Be Equal As Numbers  ${cluster_inst.num_masters}   1
   Should Be Equal As Numbers  ${cluster_inst.num_nodes}     12
   Should Be Equal As Numbers  ${cluster_inst.ip_access}     1  #IpAccessDedicated

   #Sleep  120 seconds  #wait for metrics apps to build before can delete


ClusterInst shall not create with IpAccessDedicated and multiple masters
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and multiple masters
   ...  verify error is received

   Create Flavor          ram=1024  vcpus=1  disk=1
   Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   #${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=4  number_masters=2
   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=4  number_masters=2  ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   NumMasters cannot be greater than 1

   #${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   #${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   #${server_info_node}=    Get Openstack Server List  name=${openstack_node_name}
   #${server_info_master}=  Get Openstack Server List  name=${openstack_node_master}
   #Should Be Equal   ${server_info_node[0]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[1]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[2]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[3]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small
   #Should Be Equal   ${server_info_master[1]['Flavor']}  m4.small
   
   #${num_servers_node}=     Get Length  ${server_info_node}
   #${num_servers_master}=   Get Length  ${server_info_master}
   #Should Be Equal As Numbers  ${num_servers_node}    4   # 4 nodes
   #Should Be Equal As Numbers  ${num_servers_master}  2   # 2 master

   #Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   #Should Be Equal  ${cluster_inst.node_flavor}    m4.small

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

ClusterInst shall create clusterInst with IpAccessDedicated and 0 masters and 4 nodes
   [Documentation]
   ...  create a clusterInst on openstack with IpAccessDedicated and 0 masters and 1 node
   ...  verify clusterInst is created with 1 master

   #  EDGECLOUD-641 - Should not be able to do CreateClusterInst with IpAccessDedicated and num_masters=0 and num_nodes=1
   Create Flavor          ram=1024  vcpus=1  disk=1
   Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=4  number_masters=0  ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Openstack Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Openstack Server List  name=${openstack_node_master}
   ${server_info_lb}=      Get Openstack Server List  name=${clusterlb}

   Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.small
   Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
   Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE

   ${num_servers_node}=     Get Length  ${server_info_node}
   ${num_servers_master}=   Get Length  ${server_info_master}
   ${num_servers_lb}=       Get Length  ${server_info_lb}
   Should Be Equal As Numbers  ${num_servers_node}    4   # 4 nodes
   Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
   Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

   Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal             ${cluster_inst.node_flavor}   m4.small
   Should Be Equal As Numbers  ${cluster_inst.num_masters}   1
   Should Be Equal As Numbers  ${cluster_inst.num_nodes}     4  
   Should Be Equal As Numbers  ${cluster_inst.ip_access}     1  #IpAccessDedicated

ClusterInst shall create with IpAccessDedicated and num_masters=0 num_nodes=0 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated andd num_masters=0 and num_nodes=0
   ...  verify it creates lb only

   Create Flavor          ram=1024  vcpus=1  disk=1
   Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
   Log to Console  START creating cluster instance
   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=0  number_masters=0  ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   Zero NumNodes not supported yet

   #${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   #${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   #${server_info_node}=    Get Openstack Server List  name=${openstack_node_name}
   #${server_info_master}=  Get Openstack Server List  name=${openstack_node_master}
   #${server_info_lb}=      Get Openstack Server List  name=${clusterlb}

   #Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.small
   #Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
   #Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE

   #${num_servers_node}=     Get Length  ${server_info_node}
   #${num_servers_master}=   Get Length  ${server_info_master}
   #${num_servers_lb}=       Get Length  ${server_info_lb}
   #Should Be Equal As Numbers  ${num_servers_node}    0   # 0 nodes
   #Should Be Equal As Numbers  ${num_servers_master}  0   # 0 master
   #Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

   #Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   #Should Be Equal             ${cluster_inst.node_flavor}   m4.small
   #Should Be Equal As Numbers  ${cluster_inst.num_masters}   0
   #Should Be Equal As Numbers  ${cluster_inst.num_nodes}     0  
   #Should Be Equal As Numbers  ${cluster_inst.ip_access}     1  #IpAccessDedicated

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack}

    Set Suite Variable  ${cloudlet_lowercase}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}

    #${cluster_name}=    Catenate  SEPARATOR=  cl  ${epoch_time}
    #Set Suite Variable  ${cluster_name}
