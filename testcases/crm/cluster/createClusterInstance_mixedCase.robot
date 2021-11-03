*** Settings ***
Documentation   Create cluster instances with mixed case clustername 

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
CRM shall be able to create a cluster instances with mixed case clustername
    [Documentation]
    ...  - Create a clusters and cluster instances with a clustername of MyCluster  on openstack
    ...  - Verify created successfully

    ${epoch_time}=  Get Time  epoch

    ${cluster_name_1}=  Catenate  SEPARATOR=  MyCluster  ${epoch_time}  

    Create Cluster Instance    cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_1}  number_nodes=${numnodes}  #flavor_name=${flavor_name}

*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${numnodes}=  Set Variable  1
    Set Suite Variable  ${numnodes}

   Create Flavor
