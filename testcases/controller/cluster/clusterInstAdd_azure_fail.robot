*** Settings ***
Documentation   CreateClusterInst - azure failures 

Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT} 

#Test Setup      Setup
#Test Teardown   Cleanup provisioning

*** Variables ***
${operator_name_azure}  azure 
${cloudlet_name_azure}  automationCentralCloudlet 

*** Test Cases ***
# ECQ-1596
CreateClusterInst - create a clusterinst with nummasters=1 numnodes=0 for azure should fail
    [Documentation]
    ...  create a cluster instance with nummasters=1 numnodes-0 for azure 
    ...  verify correct error occurs 

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  number_masters=1  number_nodes=0 

    Should Be Equal  ${error}  ('code=400', 'error={"message":"NumNodes cannot be 0 for PLATFORM_TYPE_AZURE"}')

#    ${code}=  Response Status Code
#    ${body}=  Response Body
#
#    Should Be Equal As Numbers  ${code}  400 
#    Should Be Equal             ${body}  {"message":"NumNodes cannot be 0 for PLATFORM_TYPE_AZURE"} 

# ECQ-1597
CreateClusterInst - create a clusterinst with nummasters=0 numnodes=0 for azure should fail
    [Documentation]
    ...  create a cluster instance with nummasters=0 numnodes-0 for azure
    ...  verify correct error occurs

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  number_masters=0  number_nodes=0

    Should Be Equal  ${error}  ('code=400', 'error={"message":"NumNodes cannot be 0 for PLATFORM_TYPE_AZURE"}')

#    ${code}=  Response Status Code
#    ${body}=  Response Body

#    Should Be Equal As Numbers  ${code}  400
#    Should Be Equal             ${body}  {"message":"NumNodes cannot be 0 for PLATFORM_TYPE_AZURE"}

# ECQ-1598
CreateClusterInst - create a clusterinst with numnodes=0 for azure should fail
    [Documentation]
    ...  create a cluster instance with numnodes=0 for azure
    ...  verify correct error occurs

    ${token}=  Get Token
    ${cluster}=  Get Default Cluster Name
    ${developer}=  Get Default Developer Name

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  cluster_name=${cluster}  developer_org_name=${developer}  operator_org_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  number_nodes=0  token=${token}  use_defaults=${False}

    Should Be Equal  ${error}  ('code=400', 'error={"message":"NumNodes cannot be 0 for PLATFORM_TYPE_AZURE"}')

#    ${code}=  Response Status Code
#    ${body}=  Response Body
#
#    Should Be Equal As Numbers  ${code}  400
#    Should Be Equal             ${body}  {"message":"NumNodes cannot be 0 for PLATFORM_TYPE_AZURE"}
