*** Settings ***
Documentation   CreateClusterInst - anthos failures 

Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT} 

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***

*** Test Cases ***
# ECQ-4098
CreateClusterInst - create a clusterinst with numnodes=1 for anthos should fail
    [Documentation]
    ...  - create a cluster instance with nummasters=1 numnodes-1 for anthos
    ...  - verify correct error occurs 

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  number_masters=1  number_nodes=1 

    Should Be Equal  ${error}  ('code=400', 'error={"message":"NumNodes must be 0 for PLATFORM_TYPE_K8S_BARE_METAL"}')

# ECQ-4099
CreateClusterInst - create a clusterinst with deployment=docker for anthos should fail
    [Documentation]
    ...  - create a cluster instance with deployment=docker for anthos
    ...  - verify correct error occurs

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  deployment=docker

    Should Be Equal  ${error}  ('code=400', 'error={"message":"Platform PLATFORM_TYPE_K8S_BARE_METAL only supports kubernetes-based deployments"}')

# ECQ-4102
CreateClusterInst - create a clusterinst with shared volume mounts for anthos should fail
    [Documentation]
    ...  - create a cluster instance with shared volume mounts for anthos
    ...  - verify correct error occurs

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  deployment=kubernetes  shared_volume_size=1

    Should Be Equal  ${error}  ('code=400', 'error={"message":"Shared volumes not supported on PLATFORM_TYPE_K8S_BARE_METAL"}')

*** Keywords ***
Setup
    Create Flavor  region=US

