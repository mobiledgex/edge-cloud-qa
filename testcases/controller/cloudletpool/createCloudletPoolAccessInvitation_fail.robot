*** Settings ***
Documentation  CreateCloudletPoolAccess Invitation/Response failures

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

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Specified CloudletPool pool1${epoch} org TDG for region ${region} not found"}')  Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool1${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization} 
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
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access response with missing parms
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse with various missging args
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Region not specified"}')  Create Cloudlet Pool Access Response  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Create Cloudlet Pool Access Response  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool name not specified"}')  Create Cloudlet Pool Access Response  token=${token}  region=${region}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool organization not specified"}')  Create Cloudlet Pool Access Response  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Organization name not specified"}')  Create Cloudlet Pool Access Response  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Decision must be either accept or reject"}')  Create Cloudlet Pool Access Response  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False 

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Region not specified"}')  Delete Cloudlet Pool Access Response  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Delete Cloudlet Pool Access Response  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool name not specified"}')  Delete Cloudlet Pool Access Response  token=${token}  region=${region}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool organization not specified"}')  Delete Cloudlet Pool Access Response  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  developer_org_name=${organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Organization name not specified"}')  Delete Cloudlet Pool Access Response  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"response not found"}')  Delete Cloudlet Pool Access Response  token=${token}  region=${region}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  use_defaults=False

# ECQ-3315
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access response without matching region
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse with bad region
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No invitation for specified cloudlet pool access"}')  Create Cloudlet Pool Access Response  region=xx  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=accept
   Run Keyword and Expect Error  ('code=400', 'error={"message":"No invitation for specified cloudlet pool access"}')  Create Cloudlet Pool Access Response  region=xx  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=reject
   Run Keyword and Expect Error  ('code=400', 'error={"message":"response not found"}')  Delete Cloudlet Pool Access Response  region=xx  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

# ECQ-3316
CreateCloudletPoolAccess - shall not be able to create/delete a cloudlet pool access response without matching invitation 
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse without matching invitation
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No invitation for specified cloudlet pool access"}')  Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool1${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=accept
   Run Keyword and Expect Error  ('code=400', 'error={"message":"No invitation for specified cloudlet pool access"}')  Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool1${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=reject

   Run Keyword and Expect Error  ('code=400', 'error={"message":"response not found"}')  Delete Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool1${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

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
CreateCloudletPoolAccess - shall not be able to create same cloudlet pool access response twice
   [Documentation]
   ...  - send same CreateCloudletPoolAccessResponse twice
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=accept

   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool response for org ${organization}, region ${region}, pool pool${epoch} poolorg ${operator_organization} already exists"}')  Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=accept

# ECQ-3354
CreateCloudletPoolAccess - shall not be able to accept cloudlet pool access invitation after reject
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse with decision=accept
   ...  - send another with reject
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=accept

   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool response for org ${organization}, region ${region}, pool pool${epoch} poolorg ${operator_organization} already exists"}')  Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=reject

# ECQ-3355
CreateCloudletPoolAccess - shall not be able to reject cloudlet pool access invitation after accept
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse with decision=reject
   ...  - send another with accept
   ...  - verify error is created

   [Tags]  CloudletPoolAccess

   Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  operator_org_name=${operator_organization}  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}

   Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=reject

   Run Keyword and Expect Error  ('code=400', 'error={"message":"CloudletPool response for org ${organization}, region ${region}, pool pool${epoch} poolorg ${operator_organization} already exists"}')  Create Cloudlet Pool Access Response  region=${region}  token=${token}  cloudlet_pool_name=pool${epoch}  cloudlet_pool_org_name=${operator_organization}  developer_org_name=${organization}  decision=accept

*** Keywords ***
Setup
   ${token}=  Get Super Token
   ${epoch}=  Get Current Date  result_format=epoch
   ${epoch}=  Convert To String  ${epoch}
   ${long_name}=  Generate Random String  length=100

   Set Suite Variable  ${long_name}
   Set Suite Variable  ${token}
   Set Suite Variable  ${epoch}
