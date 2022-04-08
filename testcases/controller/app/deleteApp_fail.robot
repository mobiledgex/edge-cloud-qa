*** Settings ***
Documentation  DeleteApp fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

*** Test Cases ***
# ECQ-4448
DeleteApp - delete app assigned to a trustpolicy exception shall return error
   [Documentation]
   ...  - create TrustPolicyException and assign to an app
   ...  - delete the app
   ...  - verify proper error is returned

   [Tags]  TrustPolicyException

   Create Flavor  region=${region}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}

   ${app}=  Create App  region=${region}  trusted=${True}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}   app_name=${app['data']['key']['name']}  app_version=1.0  developer_org_name=${app['data']['key']['organization']}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']} region=${region}  cloudlet_pool_org_name=${operator_name_fake}  rule_list=${rulelist}

   ${error}=  Run Keyword and Expect Error  *  Delete App  region=${region}   #app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}

   Should Be Equal  ${error}  ('code=400', 'error={"message":"Application in use by Trust Policy Exception {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${app['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${app['data']['key']['name']}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_return['data']['key']['name']}\\\\"}"}')

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

