*** Settings ***
Documentation   CreateClusterInst with no org

Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

#Test Setup      Setup
#Test Teardown   Cleanup provisioning

*** Variables ***
${operator_name_fake}   dmuus 
${cloudlet_name_fake}  tmocloudlet-1

*** Test Cases ***
# ECQ-1876
CreateClusterInst - create a clusterinst with org that doesnot exist should fail
    [Documentation]
    ...  create a cluster instance with an org that does not exist
    ...  verify correct error occurs

    ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=notexist  number_masters=1  number_nodes=0

#    ${code}=  Response Status Code
#    ${body}=  Response Body

    Should Contain  ${error}  code=400
    Should Contain  ${error}  error={"message":"org notexist not found"} 

