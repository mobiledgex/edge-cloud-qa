*** Settings ***
Documentation   Create 2 cluster instances with 1 name a substring of the other

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
#${crm_api_address}  127.0.0.1:65100
${cloudlet_name_openstack}  automationHamburgCloudlet   #has to match crm process startup parms
${operator_name_openstack}  TDG
#${latitude}	  32
#${longitude}	  -90
${flavor_name}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${test_timeout_crm}  15 min

*** Test Cases ***
CRM shall be able to create 2 clusterInst with one name a substring of the other
    [Documentation]
    ...  Create 2 cluster instances such as cluster12345 and cluster1234
    ...  Verify both are created
    ...  Delete both
    ...  Verify both are deleted

    Delete Cluster Instance	cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_name=xxxx  flavor_name=${flavor_name}

	
*** Keywords ***
Setup
    #Create Developer
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  

