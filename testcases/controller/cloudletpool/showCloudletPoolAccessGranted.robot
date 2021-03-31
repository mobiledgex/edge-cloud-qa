*** Settings ***
Documentation  ShowCloudletPoolAccessGranted

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  DateTime
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${operator_organization}=  GDDT
${organization}=  dmuus

*** Test Cases ***
# ECQ-3308
CreateCloudletPoolAccess - shall be able to show the granted invitations/confirmations
   [Documentation]
   ...  - Create a cloudlet pool
   ...  - send CreateCloudletPoolAccessInvitation and confirmation
   ...  - verify it shows in granted list
   ...  - delete the invitation/confirmation
   ...  - verify it is removed from the granted list

   [Tags]  CloudletPoolAccess

   ${granted_pre}=  Show Cloudlet Pool Access Granted
   ${granted_pre_length}=  Get Length  ${granted_pre}

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   ${granted_1}=  Show Cloudlet Pool Access Granted
   Length Should Be  ${granted_1}  ${granted_pre_length}

   Create Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   ${granted_2}=  Show Cloudlet Pool Access Granted
   Length Should Be  ${granted_2}  ${granted_pre_length+1}

   ${granted_added}=  Show Cloudlet Pool Access Granted  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Should Be Equal  ${granted_added[0]['CloudletPool']}  pool${epoch}
   Should Be Equal  ${granted_added[0]['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${granted_added[0]['Org']}  ${organization}
   Should Be Equal  ${granted_added[0]['Region']}  ${region}

   Delete Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   ${granted_3}=  Show Cloudlet Pool Access Granted
   Length Should Be  ${granted_3}  ${granted_pre_length}

   ${granted_added2}=  Show Cloudlet Pool Access Granted  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Length Should Be  ${granted_added2}  0

   Create Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False

   ${granted_21}=  Show Cloudlet Pool Access Granted
   Length Should Be  ${granted_21}  ${granted_pre_length+1}

   ${granted_added1}=  Show Cloudlet Pool Access Granted  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Should Be Equal  ${granted_added1[0]['CloudletPool']}  pool${epoch}
   Should Be Equal  ${granted_added1[0]['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${granted_added1[0]['Org']}  ${organization}
   Should Be Equal  ${granted_added1[0]['Region']}  ${region}

   Delete Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   ${granted_31}=  Show Cloudlet Pool Access Granted
   Length Should Be  ${granted_31}  ${granted_pre_length}

   Delete Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   ${granted_32}=  Show Cloudlet Pool Access Granted
   Length Should Be  ${granted_32}  ${granted_pre_length}
 
*** Keywords ***
Setup
   ${token}=  Get Super Token
   ${epoch}=  Get Current Date  result_format=epoch
   ${epoch}=  Convert To String  ${epoch}
   ${long_name}=  Generate Random String  length=100

   Set Suite Variable  ${long_name}
   Set Suite Variable  ${token}
   Set Suite Variable  ${epoch}
