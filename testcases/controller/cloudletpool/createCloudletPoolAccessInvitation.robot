*** Settings ***
Documentation  CreateCloudletPoolAccess Invitation/Response

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  DateTime
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${operator_organization}=  TDG
${organization}=  tmus

*** Test Cases ***
# ECQ-3306
CreateCloudletPoolAccess - shall be able to create a cloudlet pool access invitation
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation with various names
   ...  - verify invitation is created 

   [Tags]  CloudletPoolAccess

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
CreateCloudletPoolAccess - shall be able to create a cloudlet pool access response
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse with various names
   ...  - verify pool is created

   [Tags]  CloudletPoolAccess

   [Template]  Create Response

   cloudlet_pool_name=${long_name}  decision=accept
   cloudlet_pool_name=x  decision=accept
   cloudlet_pool_name=1  decision=accept
   cloudlet_pool_name=my_pool${epoch}  decision=accept
   cloudlet_pool_name=${epoch}  decision=accept
   cloudlet_pool_name=my-pool${epoch}  decision=accept
   cloudlet_pool_name=my.pool${epoch}  decision=accept
   cloudlet_pool_name=MyPool${epoch}  decision=accept

   cloudlet_pool_name=${long_name}2  decision=reject
   cloudlet_pool_name=y  decision=reject
   cloudlet_pool_name=2  decision=reject
   cloudlet_pool_name=my_pool${epoch}2  decision=reject
   cloudlet_pool_name=${epoch}2  decision=reject
   cloudlet_pool_name=my-pool${epoch}2  decision=reject
   cloudlet_pool_name=my.pool${epoch}2  decision=reject
   cloudlet_pool_name=MyPool${epoch}2  decision=reject

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

Create Response
   [Arguments]   ${cloudlet_pool_name}  ${decision}

   Create Invitation  cloudlet_pool_name=${cloudlet_pool_name}

   ${invite_return}=  Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=${cloudlet_pool_name}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=${decision}

   Should Be Equal  ${invite_return['CloudletPool']}  ${cloudlet_pool_name}

   Should Be Equal  ${invite_return['CloudletPoolOrg']}  ${operator_organization}
   Should Be Equal  ${invite_return['Org']}   ${organization}
   Should Be Equal  ${invite_return['Region']}  ${region}
   Should Be Equal  ${invite_return['Decision']}  ${decision}

