*** Settings ***
Documentation   CreateClusterInst - gcp failures 

Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT} 

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${operator_name_gcp}  gcp 
${cloudlet_name_gcp_fake}  automationCentralCloudlet 

*** Test Cases ***
CreateClusterInst - create a clusterinst with nummasters=1 numnodes=0 for gcp should fail
    [Documentation]
    ...  create a cluster instance with nummasters=1 numnodes-0 for gcp 
    ...  verify correct error occurs 

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp_fake}  number_masters=1  number_nodes=0 

    ${code}=  Response Status Code
    ${body}=  Response Body

    Should Be Equal As Numbers  ${code}  400 
    Should Be Equal             ${body}  {"message":"NumNodes cannot be 0 for Azure or GCP"} 

CreateClusterInst - create a clusterinst with nummasters=0 numnodes=0 for gcp should fail
    [Documentation]
    ...  create a cluster instance with nummasters=0 numnodes-0 for gcp 
    ...  verify correct error occurs

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  number_masters=0  number_nodes=0

    ${code}=  Response Status Code
    ${body}=  Response Body

    Should Be Equal As Numbers  ${code}  400
    Should Be Equal             ${body}  {"message":"NumNodes cannot be 0 for Azure or GCP"}

CreateClusterInst - create a clusterinst with numnodes=0 for gcp should fail
    [Documentation]
    ...  create a cluster instance with numnodes=0 for gcp 
    ...  verify correct error occurs

    ${token}=  Get Token
    ${cluster}=  Get Default Cluster Name
    ${developer}=  Get Default Developer Name

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  cluster_name=${cluster}  developer_name=${developer}  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  number_nodes=0  token=${token}  use_defaults=${False}

    ${code}=  Response Status Code
    ${body}=  Response Body

    Should Be Equal As Numbers  ${code}  400
    Should Be Equal             ${body}  {"message":"NumNodes cannot be 0 for Azure or GCP"}

*** Keywords ***
Setup
    Create Flavor  region=US

