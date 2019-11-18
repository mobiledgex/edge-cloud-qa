*** Settings ***
Documentation  Cluster size for openstack with IpAccessDedicated and Docker

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet
${operator_name_openstack}  TDG 
${mobiledgex_domain}  mobiledgex.net

${test_timeout_crm}  15 min
	
*** Test Cases ***
ClusterInst shall create with IpAccessDedicated/docker on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and deploymenttype=docker
   ...  verify it creates lb only

   Create Flavor          ram=1024  vcpus=1  disk=1
   #Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_name=${operator_name_openstack}  number_nodes=0  number_masters=0  ip_access=IpAccessDedicated  deployment=docker
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Server List  name=${openstack_node_master}
   ${server_info_lb}=      Get Server List  name=${clusterlb}

   Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.small
   Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
   Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE

   ${num_servers_node}=     Get Length  ${server_info_node}
   ${num_servers_master}=   Get Length  ${server_info_master}
   ${num_servers_lb}=       Get Length  ${server_info_lb}
   Should Be Equal As Numbers  ${num_servers_node}    0   # 0 nodes
   Should Be Equal As Numbers  ${num_servers_master}  0   # 0 master
   Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

   Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal             ${cluster_inst.node_flavor}   m4.small
   Should Be Equal As Numbers  ${cluster_inst.num_masters}   0
   Should Be Equal As Numbers  ${cluster_inst.num_nodes}     0
   Should Be Equal As Numbers  ${cluster_inst.ip_access}     1  #IpAccessDedicated
   Should Be Equal             ${cluster_inst.deployment}    docker

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}

    Set Suite Variable  ${cloudlet_lowercase}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}
