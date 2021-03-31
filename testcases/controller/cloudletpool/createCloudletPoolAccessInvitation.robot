*** Settings ***
Documentation  CreateCloudletPoolAccess Invitation/Confirmation

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
# ECQ-3306
CreateCloudletPoolAccess - shall be able to create a cloudlet pool access invitation
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation with various names
   ...  - verify invitation is created 

   [Template]  Create Invitation

   cloudlet_pool_name=${long_name}
   cloudlet_pool_name=x
   cloudlet_pool_name=1
   cloudlet_pool_name=my_pool${epoch}
   cloudlet_pool_name=${epoch}
   cloudlet_pool_name=my-pool${epoch}
   cloudlet_pool_name=my.pool${epoch}
   cloudlet_pool_name=MyPool${epoch}

# ECQ-3307
CreateCloudletPoolAccess - shall be able to create a cloudlet pool access confirmation
   [Documentation]
   ...  - send CreateCloudletPoolAccessConfirmation with various names
   ...  - verify pool is created

   [Template]  Create Confirmation

   cloudlet_pool_name=${long_name}
   cloudlet_pool_name=x
   cloudlet_pool_name=1
   cloudlet_pool_name=my_pool${epoch}
   cloudlet_pool_name=${epoch}
   cloudlet_pool_name=my-pool${epoch}
   cloudlet_pool_name=my.pool${epoch}
   cloudlet_pool_name=MyPool${epoch}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   ${epoch}=  Get Current Date  result_format=epoch
   ${epoch}=  Convert To String  ${epoch}
   ${long_name}=  Generate Random String  length=100

   Set Suite Variable  ${long_name}
   Set Suite Variable  ${token}
   Set Suite Variable  ${epoch}

Create Invitation
   [Arguments]   ${cloudlet_pool_name}

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=${cloudlet_pool_name}  operator_org_name=${operator_organization}  use_defaults=False

   ${invite_return}=  Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=${cloudlet_pool_name}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False

   Should Be Equal  ${invite_return['CloudletPool']}  ${cloudlet_pool_name}

   Should Be Equal  ${invite_return['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${invite_return['Org']}   ${organization}
   Should Be Equal  ${invite_return['Region']}  ${region}

Create Confirmation
   [Arguments]   ${cloudlet_pool_name}

   Create Invitation  cloudlet_pool_name=${cloudlet_pool_name}

   ${invite_return}=  Create Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=${cloudlet_pool_name}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False

   Should Be Equal  ${invite_return['CloudletPool']}  ${cloudlet_pool_name}

   Should Be Equal  ${invite_return['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${invite_return['Org']}   ${organization}
   Should Be Equal  ${invite_return['Region']}  ${region}

