*** Settings ***
Documentation  CreateCloudletPoolAccess Invitation/Confirmation failures

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
# ECQ-3299
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access invitation with missing parms
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation with various missging args
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Region not specified"}')  Create Cloudlet Pool Access Invitation  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Create Cloudlet Pool Access Invitation  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool name not specified"}')  Create Cloudlet Pool Access Invitation  token=${token}  region=${region}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool organization not specified"}')  Create Cloudlet Pool Access Invitation  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Organization name not specified"}')  Create Cloudlet Pool Access Invitation  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  use_defaults=False

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Region not specified"}')  Delete Cloudlet Pool Access Invitation  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Delete Cloudlet Pool Access Invitation  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool name not specified"}')  Delete Cloudlet Pool Access Invitation  token=${token}  region=${region}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool organization not specified"}')  Delete Cloudlet Pool Access Invitation  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Organization name not specified"}')  Delete Cloudlet Pool Access Invitation  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  use_defaults=False

# ECQ-3311
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access invitation without matching region
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation with wrong region
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Run Keyword and Expect Error  ('code=400', 'error={"message":"region \\\\"xx\\\\" not found"}')  Create Cloudlet Pool Access Invitation  region=xx  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"invitation not found"}')  Delete Cloudlet Pool Access Invitation  region=xx  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

# ECQ-3312
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access invitation without matching cloudletpool 
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation with wrong cloudetpool
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Specified CloudletPool pool1${epoch} org GDDT for region ${region} not found"}')  Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool1${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization} 
   Run Keyword and Expect Error  ('code=400', 'error={"message":"invitation not found"}')  Delete Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool1${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

# ECQ-3313
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access invitation without matching org
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation with wrong org
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Specified Organization xx does not exist"}')  Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=xx
   Run Keyword and Expect Error  ('code=400', 'error={"message":"invitation not found"}')  Delete Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=xx

# ECQ-3314
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access confirmation with missing parms
   [Documentation]
   ...  - send CreateCloudletPoolAccessConfirmation with various missging args
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Region not specified"}')  Create Cloudlet Pool Access Confirmation  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Create Cloudlet Pool Access Confirmation  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool name not specified"}')  Create Cloudlet Pool Access Confirmation  token=${token}  region=${region}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool organization not specified"}')  Create Cloudlet Pool Access Confirmation  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Organization name not specified"}')  Create Cloudlet Pool Access Confirmation  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  use_defaults=False

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Region not specified"}')  Delete Cloudlet Pool Access Confirmation  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Delete Cloudlet Pool Access Confirmation  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool name not specified"}')  Delete Cloudlet Pool Access Confirmation  token=${token}  region=${region}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool organization not specified"}')  Delete Cloudlet Pool Access Confirmation  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Organization name not specified"}')  Delete Cloudlet Pool Access Confirmation  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  use_defaults=False

# ECQ-3315
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access confirmation without matching region
   [Documentation]
   ...  - send CreateCloudletPoolAccessConfirmation with bad region
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No invitation for specified cloudlet pool access"}')  Create Cloudlet Pool Access Confirmation  region=xx  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"confirmation not found"}')  Delete Cloudlet Pool Access Confirmation  region=xx  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

# ECQ-3316
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access confirmation without matching invitation 
   [Documentation]
   ...  - send CreateCloudletPoolAccessConfirmation without matching invitation
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No invitation for specified cloudlet pool access"}')  Create Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=pool1${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"confirmation not found"}')  Delete Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=pool1${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

# ECQ-3317
CreateCloudletPoolAccess - shall not be able to create same cloudlet pool access invitation twice
   [Documentation]
   ...  - send same CreateCloudletPoolAccessInvitation twice
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool invitation for org ${organization}, region ${region}, pool pool${epoch} poolorg ${operator_organization} already exists"}')  Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

# ECQ-3318
CreateCloudletPoolAccess - shall not be able to create same cloudlet pool access confirmation twice
   [Documentation]
   ...  - send same CreateCloudletPoolAccessConfirmation twice
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Create Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool confirmation for org ${organization}, region ${region}, pool pool${epoch} poolorg ${operator_organization} already exists"}')  Create Cloudlet Pool Access Confirmation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   ${epoch}=  Get Current Date  result_format=epoch
   ${epoch}=  Convert To String  ${epoch}
   ${long_name}=  Generate Random String  length=100

   Set Suite Variable  ${long_name}
   Set Suite Variable  ${token}
   Set Suite Variable  ${epoch}
