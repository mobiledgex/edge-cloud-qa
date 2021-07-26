*** Settings ***
Documentation  Rate Limit Settings for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3619
RateLimitSettings - developer/operator shall not be able to create a flow
   [Documentation]
   ...  - send ratelimitsettings as developer and operator
   ...  - verify proper error is received

   [Template]  Create Ratelimit Fail

   ${dev_manager_user_automation}  ${dev_manager_password_automation}
   ${dev_contributor_user_automation}  ${dev_contributor_password_automation}
   ${dev_viewer_user_automation}  ${dev_viewer_password_automation}

   ${op_manager_user_automation}  ${op_manager_password_automation}
   ${op_contributor_user_automation}  ${op_contributor_password_automation}
   ${op_viewer_user_automation}  ${op_viewer_password_automation}

*** Keywords ***
Create Ratelimit Fail
   [Arguments]  ${username}  ${password}

   ${user_token}=  Login  username=${username}  password=${dev_manager_password_automation}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Rate Limit Settings  token=${user_token}  region=${region}  api_endpoint_type=dme  api_name=RegisterClient  rate_limit_target=1  flow_algorithm=TokenBucketAlgorithm  requests_per_second=1

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Rate limit Flow  token=${user_token}  region=${region}  api_endpoint_type=dme  api_name=RegisterClient  rate_limit_target=1  flow_algorithm=TokenBucketAlgorithm  requests_per_second=1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Rate limit Flow  token=${user_token}  region=${region}  api_endpoint_type=dme  api_name=RegisterClient  rate_limit_target=1  flow_algorithm=TokenBucketAlgorithm  requests_per_second=1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Rate limit Flow  token=${user_token}  region=${region}  api_endpoint_type=dme  api_name=RegisterClient  rate_limit_target=1  flow_algorithm=TokenBucketAlgorithm  requests_per_second=1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Rate limit Flow  token=${user_token}  region=${region}  api_endpoint_type=dme  api_name=RegisterClient  rate_limit_target=1  flow_algorithm=TokenBucketAlgorithm  requests_per_second=1

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Rate limit Max Requests  token=${user_token}  region=${region}  api_endpoint_type=dme  api_name=RegisterClient  rate_limit_target=1  max_requests_algorithm=FixedWindowAlgorithm  max_requests=1

