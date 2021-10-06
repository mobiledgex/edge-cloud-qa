*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup     Setup
Suite Teardown  Cleanup provisioning

*** Variables ***
${region}  US
${operator_name_fake}=  tmus
${alliance_org}=  packet

*** Test Cases ***
# ECQ-3967
AddAllianceOrg - OperatorManager shall be able to add/remove alliance org
   [Documentation]
   ...  - login as operator manager 
   ...  - send AddAllianceOrg and RemoveAllianceOrg
   ...  - verify success

   [Tags]  AllianceOrg

   ${user_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   Add Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=${alliance_org}  token=${user_token}
   Remove Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=${alliance_org}  token=${user_token}

# ECQ-3968
AddAllianceOrg - OperatorContributor shall be able to add/remove alliance org
   [Documentation]
   ...  - login as operator contributor
   ...  - send AddAllianceOrg and RemoveAllianceOrg
   ...  - verify success

   [Tags]  AllianceOrg

   ${user_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

   Add Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=${alliance_org}  token=${user_token}
   Remove Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=${alliance_org}  token=${user_token}

# ECQ-3969
AddAllianceOrg - OperatorViewer shall not be able to add/remove alliance org
   [Documentation]
   ...  - login as operator viewer
   ...  - send AddAllianceOrg and RemoveAllianceOrg
   ...  - verify forbidden is returned

   [Tags]  AllianceOrg

   [Template]  Forbidden Add/Remove Alliance Org

   ${op_viewer_user_automation}       ${op_viewer_password_automation}

# ECQ-3970
AddAllianceOrg - Developer shall not be able to add/remove alliance org
   [Documentation]
   ...  - login as developer manager/contributor/viewer
   ...  - send AddAllianceOrg and RemoveAllianceOrg
   ...  - verify forbidden is returned

   [Tags]  AllianceOrg

   [Template]  Forbidden Add/Remove Alliance Org

   ${dev_manager_user_automation}      ${dev_manager_password_automation}
   ${dev_contributor_user_automation}  ${dev_contributor_password_automation}
   ${dev_viewer_user_automation}       ${dev_viewer_password_automation}

** Keywords **
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  token=${token}

   Set Suite Variable  ${cloudlet}

Forbidden Add/Remove Alliance Org 
   [Arguments]  ${username}  ${password}

   ${user_token}=  Login  username=${username}  password=${dev_manager_password_automation}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Add Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=tmus  token=${user_token}
   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Remove Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_fake}  alliance_org_name=tmus  token=${user_token}

