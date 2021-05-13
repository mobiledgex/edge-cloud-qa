*** Settings ***
Documentation  ShowCloudletPoolAccessPending/Granted

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  DateTime
     
Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US
${operator_organization}=  GDDT
${organization}=  ${developer_org_name_automation}

*** Test Cases ***
# ECQ-3308
CreateCloudletPoolAccess - shall be able to show the pending/granted invitations/responses
   [Documentation]
   ...  - Create a cloudlet pool
   ...  - send CreateCloudletPoolAccessInvitation and response
   ...  - verify it shows in granted/pending list
   ...  - delete the invitation/responsse
   ...  - verify it is removed from the granted/pending list

   [Tags]  CloudletPoolAccess

   ${granted_pre}=  Show Cloudlet Pool Access Granted  token=${token}
   ${granted_pre_length}=  Get Length  ${granted_pre}
   ${pending_pre}=  Show Cloudlet Pool Access Pending  token=${token}
   ${pending_pre_length}=  Get Length  ${pending_pre}

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  auto_delete=False
   ${granted_1}=  Show Cloudlet Pool Access Granted  token=${token}
   Length Should Be  ${granted_1}  ${granted_pre_length}
   ${pending_1}=  Show Cloudlet Pool Access Pending  token=${token}
   Length Should Be  ${pending_1}  ${pendingpre_length+1}

   ${pending_added}=  Show Cloudlet Pool Access Pending  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Should Be Equal  ${pending_added[0]['CloudletPool']}  pool${epoch}
   Should Be Equal  ${pending_added[0]['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${pending_added[0]['Org']}  ${organization}
   Should Be Equal  ${pending_added[0]['Region']}  ${region}

   Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=accept  auto_delete=False
   ${granted_2}=  Show Cloudlet Pool Access Granted  token=${token}
   Length Should Be  ${granted_2}  ${granted_pre_length+1}
   ${pending_2}=  Show Cloudlet Pool Access Pending  token=${token}
   Length Should Be  ${pending_2}  ${pending_pre_length}

   ${granted_added}=  Show Cloudlet Pool Access Granted  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Should Be Equal  ${granted_added[0]['CloudletPool']}  pool${epoch}
   Should Be Equal  ${granted_added[0]['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${granted_added[0]['Org']}  ${organization}
   Should Be Equal  ${granted_added[0]['Region']}  ${region}

   Delete Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   ${granted_3}=  Show Cloudlet Pool Access Granted  token=${token}
   Length Should Be  ${granted_3}  ${granted_pre_length}
   ${pending_3}=  Show Cloudlet Pool Access Pending  token=${token}
   Length Should Be  ${pending_3}  ${pending_pre_length+1}

   ${granted_added2}=  Show Cloudlet Pool Access Granted  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Length Should Be  ${granted_added2}  0
   ${pending_added2}=  Show Cloudlet Pool Access Pending  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Should Be Equal  ${pending_added2[0]['CloudletPool']}  pool${epoch}
   Should Be Equal  ${pending_added2[0]['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${pending_added2[0]['Org']}  ${organization}
   Should Be Equal  ${pending_added2[0]['Region']}  ${region}

   Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=accept  auto_delete=False

   ${granted_21}=  Show Cloudlet Pool Access Granted  token=${token}
   Length Should Be  ${granted_21}  ${granted_pre_length+1}
   ${pending_21}=  Show Cloudlet Pool Access Pending  token=${token}
   Length Should Be  ${pending_21}  ${pending_pre_length}

   ${granted_added1}=  Show Cloudlet Pool Access Granted  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Should Be Equal  ${granted_added1[0]['CloudletPool']}  pool${epoch}
   Should Be Equal  ${granted_added1[0]['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${granted_added1[0]['Org']}  ${organization}
   Should Be Equal  ${granted_added1[0]['Region']}  ${region}
   ${pending_added1}=  Show Cloudlet Pool Access Pending  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Length Should Be  ${pending_added1}  0

   Delete Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   ${granted_31}=  Show Cloudlet Pool Access Granted  token=${token}
   Length Should Be  ${granted_31}  ${granted_pre_length}
   ${pending_31}=  Show Cloudlet Pool Access Pending  token=${token}
   Length Should Be  ${pending_31}  ${pending_pre_length}

# response is now deleted when invitation is deleted
#   Delete Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
#   ${granted_32}=  Show Cloudlet Pool Access Granted  token=${token}
#   Length Should Be  ${granted_32}  ${granted_pre_length}
#   ${pending_32}=  Show Cloudlet Pool Access Pending  token=${token}
#   Length Should Be  ${pending_32}  ${pending_pre_length}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   ${epoch}=  Get Current Date  result_format=epoch
   ${epoch}=  Convert To String  ${epoch}
   ${long_name}=  Generate Random String  length=100

   Set Suite Variable  ${long_name}
   Set Suite Variable  ${token}
   Set Suite Variable  ${epoch}

Teardown
   Cleanup Provisioning

   Run Keyword and Ignore Error  Delete Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Ignore Error  Delete Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False

