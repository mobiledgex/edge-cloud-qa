*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         String

Test Setup     Setup
Test Teardown  Cleanup provisioning

*** Variables ***
${region}  US
${operator_name_fake}=  tmus

*** Test Cases ***
# ECQ-3963
AddAllianceOrg - shall be able to add alliance orgs to a cloudlet
   [Documentation]
   ...  - send CreateCloudlet without allianceorgs
   ...  - send AddAllianceOrg to add orgs
   ...  - verify the cloudlet has the orgs defined
   ...  - send RemoveAllianceOrg to remove the orgs
   ...  - verify the orgs are removed from the cloudlet

   [Tags]  AllianceOrg

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}

   Add Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=tmus

   @{alliance_list}=  Create List  tmus
   ${cloudlet_show}=  Show Cloudlets  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  use_defaults=${False}  token=${token}
   Should Be Equal  ${cloudlet_show[0]['data']['alliance_orgs']}  ${alliance_list}

   Add Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=TDG
   Add Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=packet

   @{alliance_list}=  Create List  tmus  TDG  packet
   ${cloudlet_show}=  Show Cloudlets  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  use_defaults=${False}  token=${token}
   Should Be Equal  ${cloudlet_show[0]['data']['alliance_orgs']}  ${alliance_list}

   @{alliance_list}=  Create List  tmus  packet
   Remove Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=TDG
   ${cloudlet_show}=  Show Cloudlets  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  use_defaults=${False}  token=${token}
   Should Be Equal  ${cloudlet_show[0]['data']['alliance_orgs']}  ${alliance_list}

** Keywords **
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

