*** Settings ***
Documentation   Create cluster instances with long name on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         String

Test Timeout     ${test_timeout_crm}

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_shared}  automationFrankfurtCloudlet
${operator_name_openstack}  TDG
${region}  US
${flavor_name}    x1.medium
${cluster_name_long}=  longnameeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

${test_timeout_crm}  15 min

*** Test Cases ***
Controller shall return error while creating kubernetes based cluster and IpAccessShared with name greater than 40 characters
    [Documentation]
    ...  Create a cluster instance on openstack with a long name 
    ...  Verify that creation fails

    ${cluster_name_openstack_length}=  Get Length   ${cluster_name_long}
    log to console   Length of cluster name=${cluster_name_openstack_length}

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_name=${cluster_name_long}  deployment=kubernetes  ip_access=IpAccessShared  number_nodes=1
    Should be equal  ${error}  ('code=400', 'error={"message":"Cluster name limited to 40 characters"}')


*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    Create Flavor  region=${region} 

