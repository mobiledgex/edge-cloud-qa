*** Settings ***
Documentation  Rate Limit Settings MC for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3620
RateLimitSettingsMC - developer/operator shall not be able to create a flow
   [Documentation]
   ...  - send ratelimitsettingsmc as developer and operators
   ...  - verify proper error is received

   [Template]  Create MC Ratelimit Fail

   ${dev_manager_user_automation}  ${dev_manager_password_automation}
   ${dev_contributor_user_automation}  ${dev_contributor_password_automation}
   ${dev_viewer_user_automation}  ${dev_viewer_password_automation}

   ${op_manager_user_automation}  ${op_manager_password_automation}
   ${op_contributor_user_automation}  ${op_contributor_password_automation}
   ${op_viewer_user_automation}  ${op_viewer_password_automation}


*** Keywords ***
Create MC Ratelimit Fail
   [Arguments]  ${username}  ${password}

   ${user_token}=  Login  username=${username}  password=${dev_manager_password_automation}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create MC Ratelimit Flow  token=${user_token}  api_name=RegisterClient  rate_limit_target=1  flow_algorithm=TokenBucketAlgorithm  requests_per_second=1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show MC Ratelimit Flow  token=${user_token}  api_name=RegisterClient  rate_limit_target=1  flow_algorithm=TokenBucketAlgorithm  requests_per_second=1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete MC Ratelimit Flow  token=${user_token}  api_name=RegisterClient  rate_limit_target=1  flow_algorithm=TokenBucketAlgorithm  requests_per_second=1

