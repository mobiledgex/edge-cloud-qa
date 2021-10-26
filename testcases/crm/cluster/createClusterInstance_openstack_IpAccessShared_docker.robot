*** Settings ***
Documentation  Cluster size for CRM with IpAccessShared and Docker

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationBonnCloudlet
${operator_name_openstack}  TDG 
${mobiledgex_domain}  mobiledgex.net

${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-2016
ClusterInst shall create with IpAccessShared/docker on CRM 
   [Documentation]
   ...  create a cluster on CRM with IpAccessShared and deploymenttype=docker
   ...  verify it creates docker vm on local address

   Create Flavor          ram=1024  vcpus=1  disk=1

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=IpAccessShared  deployment=docker
   Log to Console  DONE creating cluster instance

   IF  '${platform_type}' == 'Openstack'
      ${openstack_node_name}=    Catenate  SEPARATOR=-  docker  vm  ${cloudlet_lowercase}  ${cluster_name}

      ${server_info_node}=    Get Server List  name=${openstack_node_name}

      Should Contain  ${server_info_node[0]["Networks"]}  mex-k8s-net
      Should Be Equal  ${server_info_node[0]["Status"]}  ACTIVE

      ${num_servers_node}=     Get Length  ${server_info_node}
      Should Be Equal As Numbers  ${num_servers_node}    1   # 1 nodes
   END

   Should Be Equal             ${cluster_inst.flavor.name}   ${flavor_name}
   Should Contain              ${cluster_inst.node_flavor}   .small
   Should Be Equal As Numbers  ${cluster_inst.num_masters}   0
   Should Be Equal As Numbers  ${cluster_inst.num_nodes}     0
   Should Be Equal As Numbers  ${cluster_inst.ip_access}     3  #IpAccessShared
   Should Be Equal             ${cluster_inst.deployment}    docker

*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    Set Suite Variable  ${platform_type}

    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_crm}

    Set Suite Variable  ${cloudlet_lowercase}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}
