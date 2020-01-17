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
${cloudlet_name_openstack}  automationFrankfurtCloudlet
${operator_name_openstack}  TDG 
${mobiledgex_domain}  mobiledgex.net

${test_timeout_crm}  15 min
	
*** Test Cases ***
ClusterInst shall create with IpAccessDedicated and num_nodes=1 on openstack
	[Documentation]
	...  create a cluster on openstack with IpAccessDedicated and num_nodes=1
	...  verify it creates 1 lb and 1 node and 1 master

	${flavor_name}=   Set Variable    flavor${x}

	Create Flavor       flavor_name=${flavor_name}   ram=1024  vcpus=1  disk=20
	
	${cluster_name}=  Get Default Cluster Name


	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
	Log to Console  START creating cluster instance
	${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessDedicated
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

	#Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
	Should Be Equal As Numbers  ${cluster_inst.num_masters}   1
	Should Be Equal As Numbers  ${cluster_inst.num_nodes}     1
	Should Be Equal As Numbers  ${cluster_inst.ip_access}     1  #IpAccessDedicated

	Sleep  120 seconds  #wait for metrics apps to build before can delete

ClusterInst shall create with IpAccessDedicated and num_nodes=2 on openstack
	[Documentation]
	...  create a cluster on openstack with IpAccessDedicated and num_nodes=2
	...  verify it creates 1 lb and 3 nodes and 1 master

	${x}   Catenate  SEPARATOR=   ${x}   1
	${flavor_name}=   Set Variable    flavor${x}

	Create Flavor       flavor_name=${flavor_name}   ram=1024  vcpus=1  disk=20

	${cluster_name}=  Get Default Cluster Name

	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}

	Log to Console  START creating cluster instance
	${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  number_nodes=2  number_masters=1  ip_access=IpAccessDedicated
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

	#Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small
	#Should Contain    ${server_info_master[0]['Image']}   mobiledgex
	#AShould Be Equal   ${server_info_master[0]['Status']}  ACTIVE

	#Should Be Equal   ${server_info_lb[0]['Flavor']}  m4.small
	#Should Contain    ${server_info_lb[0]['Image']}   mobiledgex
	#Should Be Equal   ${server_info_lb[0]['Status']}  ACTIVE
	
	#${num_servers_node}=     Get Length  ${server_info_node}
	#${num_servers_master}=   Get Length  ${server_info_master}
	#${num_servers_lb}=       Get Length  ${server_info_lb}
	#Should Be Equal As Numbers  ${num_servers_node}    3   # 3 nodes
	#Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
	#Should Be Equal As Numbers  ${num_servers_lb}      1   # 1 lb

	#Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
	Should Be Equal As Numbers  ${cluster_inst.num_masters}   1
	Should Be Equal As Numbers  ${cluster_inst.num_nodes}     3
	Should Be Equal As Numbers  ${cluster_inst.ip_access}     1  #IpAccessDedicated

	Sleep  120 seconds  #wait for metrics apps to build before can delete


*** Keywords ***
Setup
	${epoch_time}=  Get Time  epoch
	${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack}
	${x}=  Evaluate    random.randint(2,20000)   random
	${x}=  Convert To String  ${x}	
	
	Set Suite Variable  ${cloudlet_lowercase}
	Set Suite Variable  ${x}

	${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
	${rootlb}=  Convert To Lowercase  ${rootlb}

	Set Suite Variable  ${rootlb}
