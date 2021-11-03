*** Settings ***
Documentation   Create 2 cluster instances with 1 name a substring of the other

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup      Setup
Test Teardown	Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet   #has to match crm process startup parms
${operator_name_openstack}  GDDT
${flavor_name}	  x1.medium
${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-1112
CRM shall be able to create 2 clusterInst with one name a substring of the other
    [Documentation]
    ...  Create 2 cluster instances such as cluster12345 and cluster1234
    ...  Verify both are created
    ...  Delete both
    ...  Verify both are deleted

    # EDGECLOUD-420 - fixed

    ${cluster_name_2}=  Catenate  SEPARATOR=  ${cluster_name_default}  2
    #${cluster_name_2}=  Get Substring  ${cluster_name_2}  0  18           # reduce string to bypass problem with 64char instance names

    #Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}

    #Create Cluster		default_flavor_name=${flavor_name}
    #Create Cluster		cluster_name=${cluster_name_2}  default_flavor_name=${flavor_name}
    Create Cluster Instance	cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_default}  number_nodes=${numnodes}  #flavor_name=${flavor_name}
    Create Cluster Instance	cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_2}   number_nodes=${numnodes}      #flavor_name=${flavor_name}

*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${numnodes}=  Set Variable  1
    
    Create Flavor
    #Create Developer
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  

    Set Suite Variable  ${numnodes}

