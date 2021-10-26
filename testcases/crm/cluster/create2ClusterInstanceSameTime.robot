*** Settings ***
Documentation   Start 2 cluster instances at the same time

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String
#Library         runKeywordAsync

Test Setup      Setup
Test Teardown	Cleanup provisioning

Test Timeout     ${test_timeout_crm}
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationHamburgCloudlet   #has to match crm process startup parms
${operator_name_openstack}  TDG
${flavor_name}	  x1.medium
${test_timeout_crm}   15 min

*** Test Cases ***
# ECQ-1196
CRM shall be able to Create 2 cluster instances at the same time 
    [Documentation]
    ...  - Create 2 clusters and cluster instances at the same time
    ...  - Verify both are created successfully

    ${epoch_time}=  Get Time  epoch

    ${cluster_name_1}=  Catenate  SEPARATOR=  cl  ${epoch_time}  
    ${cluster_name_2}=  Catenate  SEPARATOR=  ${cluster_name_1}  2

    # start 2 at the same time
    ${handle1}=  Create Cluster Instance	cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_1}  number_nodes=${numnodes}  use_thread=${True}
    ${handle2}=  Create Cluster Instance	cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_2}  number_nodes=${numnodes}  use_thread=${True}

    # wait for them to finish
    Wait For Replies  ${handle1}  ${handle2}

*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    IF  '${platform_type}' == 'K8SBareMetal'
        ${numnodes}=  Set Variable  0
    ELSE
        ${numnodes}=  Set Variable  1
    END

    Create Flavor 

    Set Suite Variable  ${numnodes}
