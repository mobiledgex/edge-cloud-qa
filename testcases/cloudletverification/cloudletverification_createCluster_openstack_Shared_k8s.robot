*** Settings ***
Documentation  Cluster size for openstack with IpAccessDedicated
...  ram  vcpus  disk  num_nodes  azure
...  1024   1     1       1      m4.small
...  2048   2     2       1      Standard_DS2_v2
...  4096   4     4       1      Standard_DS3_v2
...  1024   1     4       4      Standard_DS3_v2
...  1024  20    error exceeding quota

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack}  automationMunichCloudlet
${operator_name_openstack}  TDG 
${mobiledgex_domain}  mobiledgex.net

${test_timeout_crm}  32 min
	
*** Test Cases ***
ClusterInst shall create with IpAccessShared/K8s and num_masters=1 and num_nodes=1 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deploymenttype=k8s and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master

   Create Flavor          ram=1024  vcpus=1  disk=20    

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes
   Log to Console  DONE creating cluster instance

   #${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   #${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   #${server_info_node}=    Get Server List  name=${openstack_node_name}
   #${server_info_master}=  Get Server List  name=${openstack_node_master}
   #${server_info_lb}=      Get Server List  name=${clusterlb}

   #Should Be Equal   ${server_info_node[0]['Flavor']}   m4.small
   #Should Contain    ${server_info_node[0]['Image']}    mobiledgex
   #Should Be Equal   ${server_info_node[0]['Status']}   ACTIVE
	
   #Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small
   #Should Contain    ${server_info_master[0]['Image']}   mobiledgex
   #Should Be Equal   ${server_info_master[0]['Status']}  ACTIVE

   #Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.small
   #Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
   #Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE

   #${num_servers_node}=     Get Length  ${server_info_node}
   #${num_servers_master}=   Get Length  ${server_info_master}
   #${num_servers_lb}=       Get Length  ${server_info_lb}
   #Should Be Equal As Numbers  ${num_servers_node}    1   # 3 nodes
   #Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
   #Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

   Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal             ${cluster_inst.node_flavor}   m4.small
   Should Be Equal As Numbers  ${cluster_inst.num_masters}   1
   Should Be Equal As Numbers  ${cluster_inst.num_nodes}     1
   Should Be Equal As Numbers  ${cluster_inst.ip_access}     3  #IpAccessShared
   Should Be Equal             ${cluster_inst.deployment}    kubernetes

ClusterInst shall create with IpAccessShared/k8s and num_masters=1 and num_nodes=5 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and kubernetes and masters=1 and num_nodes=5
   ...  verify it creates 1 lb and 5 nodes and 1 master

   Create Flavor          ram=1024  vcpus=1  disk=20

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=5  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes
   Log to Console  DONE creating cluster instance

   #${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   #${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   #${server_info_node}=    Get Server List  name=${openstack_node_name}
   #${server_info_master}=  Get Server List  name=${openstack_node_master}
   #${server_info_lb}=      Get Server List  name=${clusterlb}

   #Should Be Equal   ${server_info_node[0]['Flavor']}   m4.small
   #Should Contain    ${server_info_node[0]['Image']}    mobiledgex
   #Should Be Equal   ${server_info_node[0]['Status']}   ACTIVE
	
   #Should Be Equal   ${server_info_node[1]['Flavor']}   m4.small
   #Should Contain    ${server_info_node[1]['Image']}    mobiledgex
   #Should Be Equal   ${server_info_node[1]['Status']}   ACTIVE

   #Should Be Equal   ${server_info_node[2]['Flavor']}   m4.small
   #Should Contain    ${server_info_node[2]['Image']}    mobiledgex
   #Should Be Equal   ${server_info_node[2]['Status']}   ACTIVE

   #Should Be Equal   ${server_info_node[3]['Flavor']}  m4.small
   #Should Contain    ${server_info_node[3]['Image']}   mobiledgex
   #Should Be Equal   ${server_info_node[3]['Status']}  ACTIVE

   #Should Be Equal   ${server_info_node[4]['Flavor']}  m4.small
   #Should Contain    ${server_info_node[4]['Image']}   mobiledgex
   #Should Be Equal   ${server_info_node[4]['Status']}  ACTIVE

   #Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small
   #Should Contain    ${server_info_master[0]['Image']}   mobiledgex
   #Should Be Equal   ${server_info_master[0]['Status']}  ACTIVE

   #Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.small
   #Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
   #Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE

   #${num_servers_node}=     Get Length  ${server_info_node}
   #${num_servers_master}=   Get Length  ${server_info_master}
   #${num_servers_lb}=       Get Length  ${server_info_lb}
   #Should Be Equal As Numbers  ${num_servers_node}    5   # 5 nodes
   #Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
   #Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

   Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal             ${cluster_inst.node_flavor}   m4.small
   Should Be Equal As Numbers  ${cluster_inst.num_masters}   1
   Should Be Equal As Numbers  ${cluster_inst.num_nodes}     5
   Should Be Equal As Numbers  ${cluster_inst.ip_access}     3  #IpAccessShared
   Should Be Equal             ${cluster_inst.deployment}    kubernetes


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
