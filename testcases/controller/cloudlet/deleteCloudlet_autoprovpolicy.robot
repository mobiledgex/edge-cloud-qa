*** Settings ***
Documentation   DeleteCloudlet Autoprov Policy

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup	Setup
Test Teardown   Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3836
DeleteCloudlet - shall not be able to delete cloudlet with autoprov policy
   [Documentation]
   ...  - create a cloudlet
   ...  - create an autprov policy with the cloudlet
   ...  - delete the cloudlet
   ...  - verify error is received

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake} 

   &{cloudlet_dict}=  Create Dictionary  name=${cloudlet['data']['key']['name']}  organization=${cloudlet['data']['key']['organization']}
   @{cloudlet_list}=  Create List  ${cloudlet_dict}
   ${policy}=  Create Auto Provisioning Policy  region=${region}  deploy_client_count=2  min_active_instances=1  cloudlet_list=${cloudlet_list}

   ${error}=  Run Keyword and Expect Error  *  Delete Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Cloudlet in use by AutoProvPolicy {\\\\"organization\\\\":\\\\"${policy['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${policy['data']['key']['name']}\\\\"}"}')
