*** Settings ***
Documentation  CreateCloudletPoolAccess Invitation/Response for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  dmuus
${region}=  US

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3300
CreateCloudletPoolAccess - DeveloperManager shall be able to create a cloudletpool response but not invitation and show response/invite/granted/pending
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation for DeveloperManager user
   ...  - verify proper error is received
   ...  - send CreateCloudletPoolAccessResponse for DeveloperManager user
   ...  - verify success
   ...  - send ShowResponse/Invitatation/Granted/Pending and verify success

   [Tags]  CloudletPoolAccess

   ${user_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation} 
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}

   Create Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}  decision=accept

   ${granted}=  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
   ${glen}=  Get Length  ${granted}
   Should Be True  ${glen} > 0

   ${pending}=  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
   ${plen}=  Get Length  ${pending}
   Should Be True  ${plen} >= 0

   ${invite}=  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
   ${confirm}=  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}
   ${ilen}=  Get Length  ${invite}
   ${clen}=  Get Length  ${confirm}
   Should Be True  ${ilen} > 0
   Should Be True  ${clen} > 0

# ECQ-3301
CreateCloudletPoolAccess - DeveloperContributor shall not be able to create a cloudletpool invitation or response and show response/invite/granted/pending
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation and CreateCloudletPoolAccessResponse for DeveloperContributor user
   ...  - verify proper error is received
   ...  - send ShowResponse/Invitatation/Granted/Pending and verify success

   [Tags]  CloudletPoolAccess

   ${user_token}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}  decision=accept
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation} 
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
#
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}

   ${granted}=  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
   ${glen}=  Get Length  ${granted}
   Should Be True  ${glen} >= 0

   ${pending}=  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
   ${plen}=  Get Length  ${pending}
   Should Be True  ${plen} >= 0

   ${invite}=  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
   ${confirm}=  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}
   ${ilen}=  Get Length  ${invite}
   ${clen}=  Get Length  ${confirm}
   Should Be True  ${ilen} >= 0
   Should Be True  ${clen} >= 0

# ECQ-3302
CreateCloudletPoolAccess - DeveloperViewer shall not be able to create a cloudletpool invitation or response and show response/invite/granted/pending
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse and CreateCloudletPoolAccessInvitation DeveloperViewer user
   ...  - verify proper error is received
   ...  - send ShowResponse/Invitatation/Granted/Pending and verify success

   [Tags]  CloudletPoolAccess

   ${user_token}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}  decision=accept
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
#
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}

   ${granted}=  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
   ${glen}=  Get Length  ${granted}
   Should Be True  ${glen} >= 0

   ${pending}=  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
   ${plen}=  Get Length  ${pending}
   Should Be True  ${plen} >= 0

   ${invite}=  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
   ${confirm}=  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}
   ${ilen}=  Get Length  ${invite}
   ${clen}=  Get Length  ${confirm}
   Should Be True  ${ilen} >= 0
   Should Be True  ${clen} >= 0

# ECQ-3303
CreateCloudletPoolAccess - OperatorManager shall be able to create a cloudletpool invitation but not response and show response/invite/granted/pending
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation for OperatorManager user
   ...  - verify success
   ...  - send CreateCloudletPoolAccessResponse for OperatorManager user
   ...  - verify proper error is received
   ...  - send ShowResponse/Invitation/Granted/Pending and verify success

   [Tags]  CloudletPoolAccess

   ${user_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}  decision=accept
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${granted}=  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
   ${glen}=  Get Length  ${granted}
   Should Be True  ${glen} >= 0

   ${pending}=  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
   ${plen}=  Get Length  ${pending}
   Should Be True  ${plen} > 0

   ${invite}=  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
   ${confirm}=  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}
   ${ilen}=  Get Length  ${invite}
   ${clen}=  Get Length  ${confirm}
   Should Be True  ${ilen} > 0
   Should Be True  ${clen} >= 0

# ECQ-3304
CreateCloudletPoolAccess - OperatorContributor shall be able to create a cloudletpool invitation but not response and show response/invite/granted/pending
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation for OperatorContributor user
   ...  - verify success
   ...  - send CreateCloudletPoolAccessResponse for OperatorContributor user
   ...  - verify proper error is received
   ...  - send ShowResponse/Invitatation/Granted/Pending and verify success

   [Tags]  CloudletPoolAccess

   ${user_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}  decision=accept
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}
  
   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${granted}=  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
   ${glen}=  Get Length  ${granted}
   Should Be True  ${glen} >= 0

   ${pending}=  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
   ${plen}=  Get Length  ${pending}
   Should Be True  ${plen} >= 0

   ${invite}=  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
   ${confirm}=  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}
   ${ilen}=  Get Length  ${invite}
   ${clen}=  Get Length  ${confirm}
   Should Be True  ${ilen} > 0
   Should Be True  ${clen} >= 0

# ECQ-3305
CreateCloudletPoolAccess - OperatorViewer shall not be able to create a cloudletpool invitation or response and show response/invite/granted/pending
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse and CreateCloudletPoolAccessInvitation for OperatorViewer user
   ...  - verify proper error is received
   ...  - send ShowResponse/Invitatation/Granted/Pending and verify success

   [Tags]  CloudletPoolAccess

   ${user_token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Invitation  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}  decision=accept
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool Access Response  region=${region}  token=${user_token}  cloudlet_pool_name=${poolname}  cloudlet_pool_org_name=${organization}  developer_org_name=${developer_org_name_automation}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
#
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
#   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}

   ${granted}=  Show Cloudlet Pool Access Granted  region=${region}  token=${user_token}
   ${glen}=  Get Length  ${granted}
   Should Be True  ${glen} >= 0

   ${pending}=  Show Cloudlet Pool Access Pending  region=${region}  token=${user_token}
   ${plen}=  Get Length  ${pending}
   Should Be True  ${plen} >= 0

   ${invite}=  Show Cloudlet Pool Access Invitation  region=${region}  token=${user_token}
   ${confirm}=  Show Cloudlet Pool Access Response  region=${region}  token=${user_token}
   ${ilen}=  Get Length  ${invite}
   ${clen}=  Get Length  ${confirm}
   Should Be True  ${ilen} >= 0
   Should Be True  ${clen} >= 0

*** Keywords ***
Setup
   ${super_token}=  Get Super Token

   ${pool_name}=  Get Default Cloudlet Pool Name
 
   Create Cloudlet Pool  region=${region}  token=${super_token}  operator_org_name=${organization}

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${pool_name}
