*** Settings ***
Documentation  Update Cluster Instance with invalid arguments

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm}

*** Variables ***

${cloudlet_name_openstack_shared}  automationFrankfurtCloudlet
${operator_name_openstack}  TDG
${region}  EU
${test_timeout_crm}  15 min

*** Test Cases ***
Controller shall throw error when trying UpdateClusterInst with invalid cluster name
    [Documentation]
    ...  UpdateClusterInst with invalid cluster name 

    ${cluster_name_default}=  Get Default Cluster Name
    ${cluster_name}=  Catenate  SEPARATOR=  test  ${cluster_name_default}

    ${error_msg}=  Run Keyword and Expect Error  *    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  number_nodes=2  cluster_name=${cluster_name}
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"ClusterInst key {\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"${cluster_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"TDG\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_openstack_shared}\\\\"},\\\\"organization\\\\":\\\\"MobiledgeX\\\\"} not found"}')


Controller shall throw error when trying UpdateClusterInst with invalid auto scale policy
    [Documentation]
    ...  UpdateClusterInst with invalid auto scale policy

    #EDGECLOUD-3294 - UpdateClusterInst does not fail when trying to map an invalid autoscale policy
    ${policy_name_default}=  Get Default Autoscale Policy Name
    ${policy_name}=  Catenate  SEPARATOR=  test  ${policy_name_default}
    ${cluster_name_default}=  Get Default Cluster Name

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    ${error_msg}=  Run Keyword and Expect Error  *   Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name}
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"AutoScalePolicy ${policy_name} for developer MobiledgeX not found"}')


*** Keywords ***
Setup    
    Create Flavor     region=${region}
