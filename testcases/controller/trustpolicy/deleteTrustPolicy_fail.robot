*** Settings ***
Documentation  DeleteTrustPolicy fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${operator_name_fake}=  tmus
${cloudlet_name_fake}=  tmocloud-1

*** Test Cases ***
# ECQ-2996
DeleteTrustPolicy - delete without region shall return error
   [Documentation]
   ...  - send DeleteTrustPolicy without region
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no region specified"}')  Delete Trust Policy  token=${token}  use_defaults=${False}

# ECQ-2997
DeleteTrustPolicy - delete without token shall return error
   [Documentation]
   ...  - send DeleteTrustPolicy without token
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Delete Trust Policy  region=${region}  use_defaults=${False}

# ECQ-2998
DeleteTrustPolicy - delete without parms shall return error
   [Documentation]
   ...  - send DeleteTrustPolicy with no parms 
   ...  - verify error is returned 

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {} not found"}')  Delete Trust Policy  region=${region}  token=${token}  use_defaults=${False}

# ECQ-2999
DeleteTrustPolicy - delete without policy name shall return error
   [Documentation]
   ...  - send DeleteTrustPolicy with no policy name 
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"mobiledgex\\\\"} not found"}')  Delete Trust Policy  operator_org_name=mobiledgex  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3000
DeleteTrustPolicy - delete with unknown org name shall return error
   [Documentation]
   ...  - send DeleteTrustPolicy with unknown org name
   ...  - verify error is returned

   [Tags]  TrustPolicy

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"xxxx\\\\"} not found"}')  Delete Trust Policy  operator_org_name=xxxx  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3001
DeleteTrustPolicy - delete without org name shall return error
   [Documentation]
   ...  - send DeleteTrustPolicy with no org name
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"name\\\\":\\\\"x\\\\"} not found"}')  Delete Trust Policy  policy_name=x  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3002
DeleteTrustPolicy - delete with policy not found shall return error
   [Documentation]
   ...  - send DeleteTrustPolicy with a policy that does not exist 
   ...  - verify error is returned

   [Tags]  TrustPolicy

   ${name}=  Get Default Trust Policy Name
   ${dev}=   Get Default Operator Name

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"${dev}\\\\",\\\\"name\\\\":\\\\"${name}\\\\"} not found"}')  Delete Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

# ECQ-3003
DeleteTrustPolicy - delete policy in use by cloudlet shall retun error
   [Documentation]
   ...  - send DeleteTrustPolicy with policy in use by a cloudlet
   ...  - verify proper error is returned 

   [Tags]  TrustPolicy
   
   Create Flavor  region=${region}

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_fake}

   Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${policy_return['data']['key']['name']}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy in use by Cloudlet"}')  Delete Trust Policy  region=${region}  token=${token}  operator_org_name=${operator_name_fake}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

