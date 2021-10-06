*** Settings ***
Documentation  ratelimitsettings delete failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-4045
DeleteRateLimitFlow - delete without region shall return error
   [Documentation]
   ...  - send DeleteRateLimitFlow without region
   ...  - verify error is returned

   [Tags]  RateLimit 

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Delete Rate Limit Flow  token=${token}  use_defaults=${False}

# ECQ-4046
DeleteRateLimitMaxRequests - delete without region shall return error
   [Documentation]
   ...  - send DeleteRateLimitMaxRequests without region
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Delete Rate Limit Max Requests  token=${token}  use_defaults=${False}

# ECQ-4047
DeleteRateLimitFlow - delete without token shall return error
   [Documentation]
   ...  - send DeleteRateLimitFlow without token
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Delete Rate Limit Flow  region=${region}  use_defaults=${False}

# ECQ-4048
DeleteRateLimitMaxRequests - delete without token shall return error
   [Documentation]
   ...  - send DeleteRateLimitMaxRequests without token
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Delete Rate Limit Max Requests  region=${region}  use_defaults=${False}

# ECQ-4049
DeleteRateLimitFlow - delete flow with missing parms shall return error
   [Documentation]
   ...  - send DeleteRateLimitFlow with various missing parms 
   ...  - verify error is returned 

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid FlowSettingsName"}')  Delete Rate Limit Flow  region=${region}  token=${token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ApiName"}')  Delete Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid RateLimitTarget"}')  Delete Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ApiEndpointType"}')  Delete Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  use_defaults=${False}

# ECQ-4050
DeleteRateLimitFlow - delete with invalid parms shall return error 
   [Documentation]
   ...  - send DeleteRateLimitFlow with various invalid parms
   ...  - verify error is returned

   [Tags]  RateLimit

   # fixed - EDGECLOUD-5481 ratelimitsettings with invalid flowalgorithm,apiendpointtype and ratelimittarget need better error message
   # invalid rate limit target
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid RateLimitTarget value \\\\"AllRequest\\\\""}')  Delete Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequest  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5  use_defaults=${False}

   # invalid api_endpoint_type
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid ApiEndpointType value \\\\"Dm\\\\""}')  Delete Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dm  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5  use_defaults=${False}

# ECQ-4051
DeleteRateLimitMaxRequests - delete with invalid parms shall return error
   [Documentation]
   ...  - send DeleteRateLimitMaxRequests with various invalid parms
   ...  - verify error is returned

   [Tags]  RateLimit

   # fixed - EDGECLOUD-5481 ratelimitsettings with invalid flowalgorithm,apiendpointtype and ratelimittarget need better error message
   # invalid rate limit target
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid RateLimitTarget value \\\\"AllRequest\\\\""}')  Delete Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequest  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=1m

   # invalid api_endpoint_type
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid ApiEndpointType value \\\\"Dm\\\\""}')  Delete Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dm  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=1m

# ECQ-4052
DeleteRateLimitFlow - delete with non-existent flow shall return error
   [Documentation]
   ...  - send DeleteRateLimitFlow on flow that doesnt exist
   ...  - verify error is returned

   [Tags]  RateLimit

   ${flow_name}=  Get Default Rate Limiting Flow Name

   ${error}=  Run Keyword and Expect Error  *  Delete Rate Limit Flow  region=${region}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme 
   Should Be Equal  ${error}  ('code=400', 'error={"message":"FlowRateLimitSettings key {\\\\"flow_settings_name\\\\":\\\\"${flow_name}\\\\",\\\\"rate_limit_key\\\\":{\\\\"api_name\\\\":\\\\"yy\\\\",\\\\"api_endpoint_type\\\\":1,\\\\"rate_limit_target\\\\":1}} not found"}')

# ECQ-4053
DeleteRateLimitMaxRequests - delete with non-existent max requests shall return error
   [Documentation]
   ...  - send  DeleteRateLimitMaxRequests on max requests that doesnt exist
   ...  - verify error is returned

   [Tags]  RateLimit

   ${flow_name}=  Get Default Rate Limiting Max Requests Name

   ${error}=  Run Keyword and Expect Error  *  Delete Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme
   Should Be Equal  ${error}  ('code=400', 'error={"message":"MaxReqsRateLimitSettings key {\\\\"max_reqs_settings_name\\\\":\\\\"xx\\\\",\\\\"rate_limit_key\\\\":{\\\\"api_name\\\\":\\\\"yy\\\\",\\\\"api_endpoint_type\\\\":1,\\\\"rate_limit_target\\\\":1}} not found"}')

# ECQ-4054
DeleteRateLimitMaxRequests - delete with missing parms shall return error
   [Documentation]
   ...  - send DeleteRateLimitMaxRequests with various missing parms
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid MaxReqsSettingsName"}')  Delete Rate Limit Max Requests  region=${region}  token=${token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ApiName"}')  Delete Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid RateLimitTarget"}')  Delete Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ApiEndpointType"}')  Delete Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  use_defaults=${False}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
