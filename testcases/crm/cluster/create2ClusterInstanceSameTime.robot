*** Settings ***
Documentation   Start 2 cluster instances at the same time on openstack

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String
#Library         runKeywordAsync

Test Teardown	Cleanup provisioning

Test Timeout     ${test_timeout_crm}
	
*** Variables ***
${cloudlet_name_openstack}  automationHamburgCloudlet   #has to match crm process startup parms
${operator_name_openstack}  TDG
${flavor_name}	  x1.medium
${test_timeout_crm}   15 min

*** Test Cases ***
CRM shall be able to Create 2 cluster instances at the same time on openstack
    [Documentation]
    ...  Create 2 clusters and cluster instances at the same time on openstack
    ...  Verify both are created successfully

    ${epoch_time}=  Get Time  epoch

    ${cluster_name_1}=  Catenate  SEPARATOR=  cl  ${epoch_time}  
    ${cluster_name_2}=  Catenate  SEPARATOR=  ${cluster_name_1}  2

    Create Cluster		cluster_name=${cluster_name_1}  default_flavor_name=${flavor_name}
    Create Cluster		cluster_name=${cluster_name_2}  default_flavor_name=${flavor_name}

    # start 2 at the same time
    ${handle1}=  Create Cluster Instance	cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_name=${cluster_name_1}  flavor_name=${flavor_name}  use_thread=${True}
    ${handle2}=  Create Cluster Instance	cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_name=${cluster_name_2}  flavor_name=${flavor_name}  use_thread=${True}

    # wait for them to finish
    Wait For Replies  ${handle1}

#    sleep  120   #wait for prometheus to finish creating before deleting. bug for this already
	
#*** Keywords ***
#Setup
    #Create Developer
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  

