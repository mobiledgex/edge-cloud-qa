*** Settings ***
Documentation  ratelimitsettings failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3718
CreateRateLimitFlow- create without region shall return error
   [Documentation]
   ...  - send CreateRateLimitFlow without region
   ...  - verify error is returned

   [Tags]  RateLimit 

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Create Rate Limit Flow  token=${token}  use_defaults=${False}

# ECQ-3719
CreateRateLimitMaxRequests- create without region shall return error
   [Documentation]
   ...  - send CreateRateLimitMaxRequests without region
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Create Rate Limit Max Requests  token=${token}  use_defaults=${False}

# ECQ-3720
CreateRateLimitFlow - create without token shall return error
   [Documentation]
   ...  - send CreateRateLimitFlow without token
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Create Rate Limit Flow  region=${region}  use_defaults=${False}

# ECQ-3721
CreateRateLimitMaxRequests - create without token shall return error
   [Documentation]
   ...  - send CreateRateLimitMaxRequests without token
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Create Rate Limit Max Requests  region=${region}  use_defaults=${False}

# ECQ-3722
CreateRateLimitFlow - createflow with missing parms shall return error
   [Documentation]
   ...  - send CreateRateLimitFlow with various missing parms 
   ...  - verify error is returned 

   [Tags]  RateLimit

   # EDGECLOUD-5480 CreateFlowRateLimitSettings api call without flowalgorithm gives wrong error

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid FlowSettingsName"}')  Create Rate Limit Flow  region=${region}  token=${token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ApiName"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid RateLimitTarget"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ApiEndpointType"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid FlowAlgorithm"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ReqsPerSecond 0.000000, must be greater than 0"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ReqsPerSecond 0.000000, must be greater than 0"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid BurstSize 0, must be greater than 0"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  use_defaults=${False}

# ECQ-3723
CreateRateLimitFlow - create with invalid parms shall return error 
   [Documentation]
   ...  - send CreateRateLimitFlow with various invalid parms
   ...  - verify error is returned

   [Tags]  RateLimit

   # create with LeakyBucket and burstsize
   # EDGECLOUD-5465  able to create/update ratelimitsettings flow with flowalgorithm=LeakyBucketAlgorithm and burstsize=2
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid BurstSize 0, must be greater than 0"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=5  burst_size=5  use_defaults=${False}

   # negative requests per second
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ReqsPerSecond -5.000000, must be greater than 0"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=-5  burst_size=5  use_defaults=${False}

   # negative burst size
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid BurstSize -5, must be greater than 0"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=-5  use_defaults=${False}

   # decimal burst size
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int64, but got number 5.1 for field \\\\"FlowRateLimitSettings.settings.burst_size\\\\" at offset 235"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5.1  use_defaults=${False}

   # fixed - EDGECLOUD-5481 ratelimitsettings with invalid flowalgorithm,apiendpointtype and ratelimittarget need better error message
   # invalid rate limit target
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid RateLimitTarget value \\\\"AllRequest\\\\""}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequest  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5  use_defaults=${False}

   # invalid api_endpoint_type
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid ApiEndpointType value \\\\"Dm\\\\""}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dm  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5  use_defaults=${False}

   # invalid flow algor
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid FlowRateLimitAlgorithm value \\\\"xxx\\\\""}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=xxx  requests_per_second=5  burst_size=5  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid FlowRateLimitAlgorithm value 99"}')  Create Rate Limit Flow  region=${region}  token=${token}  flow_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=${99}  requests_per_second=5  burst_size=5  use_defaults=${False}

# ECQ-3724
CreateRateLimitMaxRequests - create with invalid parms shall return error
   [Documentation]
   ...  - send CreateRateLimitMaxRequests with various invalid parms
   ...  - verify error is returned

   [Tags]  RateLimit

   # negative maxrequests
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid MaxRequests -11, must be greater than 0"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=-11  interval=1m

   # decimal maxrequests
   ${error}=  Run Keyword and Expect Error  *  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11.5  interval=1m
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int64, but got number 11.5 for field \\\\"MaxReqsRateLimitSettings.settings.max_requests\\\\" at offset

   # fixed - EDGECLOUD-5481 ratelimitsettings with invalid flowalgorithm,apiendpointtype and ratelimittarget need better error message
   # invalid rate limit target
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid RateLimitTarget value \\\\"AllRequest\\\\""}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequest  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=1m

   # invalid api_endpoint_type
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Invalid ApiEndpointType value \\\\"Dm\\\\""}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dm  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=1m

   # invalid interval
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=1
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"m\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=m

# ECQ-3725
CreateRateLimitFlow - create with duplicate shall return error
   [Documentation]
   ...  - send same CreateRateLimitFlow twice 
   ...  - verify error is returned

   [Tags]  RateLimit

   ${flow_name}=  Get Default Rate Limiting Flow Name

   Create Rate Limit Flow  region=${region}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5

   ${error}=  Run Keyword and Expect Error  *  Create Rate Limit Flow  region=${region}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5
   Should Be Equal  ${error}  ('code=400', 'error={"message":"FlowRateLimitSettings key {\\\\"flow_settings_name\\\\":\\\\"${flow_name}\\\\",\\\\"rate_limit_key\\\\":{\\\\"api_name\\\\":\\\\"yy\\\\",\\\\"api_endpoint_type\\\\":1,\\\\"rate_limit_target\\\\":1}} already exists"}')

# ECQ-3726
CreateRateLimitMaxRequests - create with duplicate shall return error
   [Documentation]
   ...  - send same CreateRateLimitMaxRequests twice
   ...  - verify error is returned

   [Tags]  RateLimit

   ${flow_name}=  Get Default Rate Limiting Flow Name

   Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=1  interval=1m

   ${error}=  Run Keyword and Expect Error  *  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=1  interval=1m
   Should Be Equal  ${error}  ('code=400', 'error={"message":"MaxReqsRateLimitSettings key {\\\\"max_reqs_settings_name\\\\":\\\\"xx\\\\",\\\\"rate_limit_key\\\\":{\\\\"api_name\\\\":\\\\"yy\\\\",\\\\"api_endpoint_type\\\\":1,\\\\"rate_limit_target\\\\":1}} already exists"}')

# ECQ-3727
CreateRateLimitMaxRequests - create with missing parms shall return error
   [Documentation]
   ...  - send CreateRateLimitMaxRequests with various missing parms
   ...  - verify error is returned

   [Tags]  RateLimit

   # EDGECLOUD-5480 CreateFlowRateLimitSettings api call without flowalgorithm gives wrong error

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid MaxReqsSettingsName"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ApiName"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid RateLimitTarget"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid ApiEndpointType"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid MaxReqsAlgorithm"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid MaxRequests 0, must be greater than 0"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid Interval 0, must be greater than 0"}')  Create Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=1  use_defaults=${False}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
