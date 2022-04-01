*** Settings ***
Documentation  Delete ClusterInst after stack has been deleted 

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_shared}     automationBuckhornCloudlet
${operator_name_openstack}            GDDT 
${mobiledgex_domain}  mobiledgex-qa.net

${test_timeout_crm}  15 min
	
*** Test Cases ***
ClusterInst shall be deleted with IpAccessShared/k8s on openstack when no stack exists
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deploymenttype=k8s
   ...  verify it creates lb only

#   Create Flavor          ram=1024  vcpus=1  disk=1

   ${cluster_name}=  Get Default Cluster Name
   ${developer_name}=  Get Default Developer Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  #no_auto_delete={$True}
   Log to Console  DONE creating cluster instance

   ${openstack_stack_name}=    Catenate  SEPARATOR=-  ${cloudlet_lowercase_shared}  ${cluster_name}  ${developer_name} 

   Delete Stack  ${openstack_stack_name}

   #Delete Cluster Instance

ClusterInst shall be deleted with IpAccessShared/docker on openstack when no stack exists
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deploymenttype=docker
   ...  verify it creates lb only

   ${cluster_name}=  Get Default Cluster Name
   ${developer_name}=  Get Default Developer Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker  #no_auto_delete={$True}
   Log to Console  DONE creating cluster instance

   ${openstack_stack_name}=    Catenate  SEPARATOR=-  ${cloudlet_lowercase_shared}  ${cluster_name}  ${developer_name}

   Delete Stack  ${openstack_stack_name}

   #Delete Cluster Instance

*** Keywords ***
Setup
    Create Flavor          ram=1024  vcpus=1  disk=1

    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase_shared}=  Convert to Lowercase  ${cloudlet_name_openstack_shared}

    Set Suite Variable  ${cloudlet_lowercase_shared}
