*** Settings ***
Documentation  App Update on CRM

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${region}  EU

${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-4445
User shall be able to update app replicas
    [Documentation]
    ...  - deploy k8s app with replicas=1
    ...  - update the app to replicas=3
    ...  - refresh the appinst
    ...  - verify new pods start

    Log To Console  Creating App and App Instance
    Create App  region=${region}  deployment_manifest=${server_ping_threaded_manifest}  access_ports=tcp:2016 
    ${appinst1}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    # should have 1 replica
    Length Should Be  ${appinst1['data']['runtime_info']['container_ids']}  1

    Update App  region=${region}  deployment_manifest=${server_ping_threaded_replicas_manifest}
    ${appinst2}=  Refresh App Instance  region=${region}

    # should have 3 replicas after update
    Length Should Be  ${appinst2['data']['runtime_info']['container_ids']}  3

*** Keywords ***
Setup
    ${cluster_name_default}=  Get Default Cluster Name

    Create Flavor     region=${region}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    Set Suite Variable  ${cluster_name_default}
