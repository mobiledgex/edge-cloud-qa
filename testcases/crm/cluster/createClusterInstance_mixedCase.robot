*** Settings ***
Documentation   Create cluster instances with mixed case clustername on openstack

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationHamburgCloudlet   #has to match crm process startup parms
${operator_name_openstack}  TDG
${flavor_name}	  x1.medium

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-1199
CRM shall be able to create a cluster instances with mixed case clustername for openstack
    [Documentation]
    ...  Create a clusters and cluster instances with a clustername of MyCluster  on openstack
    ...  Verify created successfully

    ${epoch_time}=  Get Time  epoch

    ${cluster_name_1}=  Catenate  SEPARATOR=  MyCluster  ${epoch_time}  

    #Create Cluster		cluster_name=${cluster_name_1}  default_flavor_name=${flavor_name}
    #Create Cluster Instance	cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_name=${cluster_name_1}  #flavor_name=${flavor_name}
    Create Cluster Instance    cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_1}  #flavor_name=${flavor_name}

    #sleep  120   #wait for prometheus to finish creating before deleting. bug for this already

*** Keywords ***
Setup
   Create Flavor
