*** Settings ***
Documentation  DeleteTrustPolicyException fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${operator_name_fake}=  dmuus
${cloudlet_name_fake}=  tmocloud-1

*** Test Cases ***
# ECQ-4178
DeleteTrustPolicyException - delete exception without region shall return error
   [Documentation]
   ...  - send DeleteTrustPolicyException without region
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Delete Trust Policy Exception  token=${token}  use_defaults=${False}

# ECQ-4179
DeleteTrustPolicyException- delete exception without token shall return error
   [Documentation]
   ...  - send DeleteTrustPolicyException without token
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Delete Trust Policy Exception  region=${region}  use_defaults=${False}

# ECQ-4180
DeleteTrustPolicyException - delete exception without parms shall return error
   [Documentation]
   ...  - send DeleteTrustPolicyException with no parms 
   ...  - verify error is returned 

   [Tags]  TrustPolicyException

   Run Keyword and Expect Error  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{},\\\\"cloudlet_pool_key\\\\":{}} not found"}')  Delete Trust Policy Exception  region=${region}  token=${token}  use_defaults=${False}

# ECQ-4181
DeleteTrustPolicyException - delete exception without policy name shall return error
   [Documentation]
   ...  - send DeleteTrustPolicyException with no policy name 
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}

   ${error}=  Run Keyword and Expect Error  *  Delete Trust Policy Exception  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}  use_defaults=${False}

   Should Be Equal  ${error}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"}} not found"}')

# ECQ-4182
DeleteTrustPolicyException - delete exception with unknown args shall return error
   [Documentation]
   ...  - send DeleteTrustPolicyException with various unknown args
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   @{rulelist}=  Create List  ${rule1}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}

   ${exception}=  Create Trust Policy Exception  region=${region}   app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']} region=${region}  cloudlet_pool_org_name=${operator_name_fake}  rule_list=${rulelist}  token=${token}

   # unknown app org
   ${error1}=   Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=x  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}  rule_list=${rulelist}

   # unknown app name
   ${error2}=   Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=x  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}  rule_list=${rulelist}

   # unknown app version
   ${error3}=   Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=${app_name_automation_trusted}  app_version=x  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}  rule_list=${rulelist}

   # unknown cloudletpool name
   ${error4}=   Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=x  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}  rule_list=${rulelist}

   # unknown cloudletpool org name
   ${error5}=   Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=x  region=${region}  token=${token}  rule_list=${rulelist}

    Should Be Equal  ${error1}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"x\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')
    Should Be Equal  ${error3}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"x\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')
    Should Be Equal  ${error4}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"x\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')
    Should Be Equal  ${error5}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')

# ECQ-4183
DeleteTrustPolicyException - delete exception with missing args shall return error
   [Documentation]
   ...  - send DeleteTrustPolicyException with various missing args
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   @{rulelist}=  Create List  ${rule1}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}

   ${exception}=  Create Trust Policy Exception  region=${region}   app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  rule_list=${rulelist}  token=${token}

   # missing app org
   ${error1}=  Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}   rule_list=${rulelist}  use_defaults=${False}

   # missing app name 
   ${error2}=  Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  developer_org_name=${developer_org_name_automation}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}   rule_list=${rulelist}  use_defaults=${False}

   # missing app vers
   ${error3}=  Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=${app_name_automation_trusted}  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}   rule_list=${rulelist}  use_defaults=${False}

   # missing cloudletpool name
   ${error4}=  Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=${app_name_automation_trusted}  developer_org_name=${developer_org_name_automation}  app_version=1.0  cloudlet_pool_org_name=${pool['data']['key']['organization']}  region=${region}  token=${token}   rule_list=${rulelist}  use_defaults=${False}

   # missing cloudletpool org
   ${error5}=  Run Keyword and Expect Error  *  Delete Trust Policy Exception  policy_name=${exception['data']['key']['name']}  app_name=${app_name_automation_trusted}  developer_org_name=${developer_org_name_automation}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  region=${region}  token=${token}   rule_list=${rulelist}  use_defaults=${False}

   Should Be Equal  ${error1}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')
   Should Be Equal  ${error3}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')
   Should Be Equal  ${error4}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')
   Should Be Equal  ${error5}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${exception['data']['key']['name']}\\\\"} not found"}')

# ECQ-4184
DeleteTrustPolicyException - delete exception with policy not found shall return error
   [Documentation]
   ...  - send DeleteTrustPolicyException with a policy that does not exist 
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   ${name}=  Get Default Trust Policy Name
   ${dev}=   Get Default Operator Name

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   ${error}=  Run Keyword and Expect Error  *  Delete Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Should Be Equal  ${error}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${name}\\\\"} not found"}')

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
