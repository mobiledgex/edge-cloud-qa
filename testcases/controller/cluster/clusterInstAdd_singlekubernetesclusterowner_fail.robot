*** Settings ***
Documentation   Create ClusterInst with singlekubernetesclusterowner 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${app_counter}=  ${0}

${region}=  US
${operator_name_fake}=  tmus

*** Test Cases ***
# ECQ-4372
CreateClusterInst - Error shall be received for cloudlet with singlekubernetesclusterowner
   [Documentation]
   ...  - create clusterinst on cloudlet with singlekubernetesclusterowner
   ...  - verify clusterInst fails with error

   [Tags]  SingleKubernetesClusterOwner

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Single kubernetes cluster platform PLATFORM_TYPE_FAKE_SINGLE_CLUSTER only supports AppInst creates"}')   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake} 

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch

   Create Flavor  region=${region}
 
   ${cloudlet_name}=  Set Variable  cloudlet${epoch}
   ${cluster_name}=  Get Default Cluster Name

   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  platform_type=FakeSingleCluster  single_kubernetes_cluster_owner=${developer_org_name_automation}

   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}
