*** Settings ***
Documentation   CreateClusterInst - anthos failures 

Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT} 

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***

*** Test Cases ***
# ECQ-4126
CreateClusterInst - create a clusterinst for anthos should fail
    [Documentation]
    ...  - create a cluster instance with various args for anthos
    ...  - verify correct error occurs

    # EDGECLOUD-5953 CreateClusterInst on anthos gives inconsistent error message

    [Template]  Create Cluster Instance shall return proper error

    region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  number_masters=1  number_nodes=1
    region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  number_masters=1  number_nodes=0
    region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  number_masters=0  number_nodes=0
    region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  number_masters=1  number_nodes=1  autoscale_policy_name=x
    region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  deployment=docker
    region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  deployment=helm
    region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  deployment=kubernetes  shared_volume_size=1

# removed since error message changed
## ECQ-4098
#CreateClusterInst - create a clusterinst with numnodes=1 for anthos should fail
#    [Documentation]
#    ...  - create a cluster instance with nummasters=1 numnodes-1 for anthos
#    ...  - verify correct error occurs 
#
#    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  number_masters=1  number_nodes=1 
#
#    Should Be Equal  ${error}  ('code=400', 'error={"message":"Single kubernetes cluster platform PLATFORM_TYPE_K8S_BARE_METAL only supports AppInst creates"}')
#
## ECQ-4099
#CreateClusterInst - create a clusterinst with deployment=docker for anthos should fail
#    [Documentation]
#    ...  - create a cluster instance with deployment=docker for anthos
#    ...  - verify correct error occurs
#
#    # EDGECLOUD-5919 clusterinst create for docker on anthos needs better error message
#
#    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  deployment=docker
#
#    Should Be Equal  ${error}  ('code=400', 'error={"message":"Platform PLATFORM_TYPE_K8S_BARE_METAL only supports kubernetes-based deploymentsxxx"}')
#
## ECQ-4102
#CreateClusterInst - create a clusterinst with shared volume mounts for anthos should fail
#    [Documentation]
#    ...  - create a cluster instance with shared volume mounts for anthos
##    ...  - verify correct error occurs
#
#    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  deployment=kubernetes  shared_volume_size=1
#
#    Should Be Equal  ${error}  ('code=400', 'error={"message":"Shared volumes not supported on PLATFORM_TYPE_K8S_BARE_METAL"}')

*** Keywords ***
Setup
    Create Flavor  region=US

Create Cluster Instance shall return proper error
    [Arguments]  &{args}

    ${error1}=  Run Keyword and Expect Error  *  Create Cluster Instance  &{args}

    Should Be Equal  ${error1}  ('code=400', 'error={"message":"Single kubernetes cluster platform PLATFORM_TYPE_K8S_BARE_METAL only supports AppInst creates"}')

