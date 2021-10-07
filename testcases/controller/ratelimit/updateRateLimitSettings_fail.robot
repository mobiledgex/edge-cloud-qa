*** Settings ***
Documentation  ratelimitsettings update failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-4055
UpdateRateLimitFlow - update without region shall return error
   [Documentation]
   ...  - send UpdateRateLimitFlow without region
   ...  - verify error is returned

   [Tags]  RateLimit 

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Update Rate Limit Flow  token=${token}  use_defaults=${False}

# ECQ-4056
UpdateRateLimitMaxRequests - update without region shall return error
   [Documentation]
   ...  - send UpdateRateLimitMaxRequests without region
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Update Rate Limit Max Requests  token=${token}  use_defaults=${False}

# ECQ-4057
UpdateRateLimitFlow - update without token shall return error
   [Documentation]
   ...  - send UpdateRateLimitFlow without token
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Update Rate Limit Flow  region=${region}  use_defaults=${False}

# ECQ-4058
UpdateRateLimitMaxRequests - update without token shall return error
   [Documentation]
   ...  - send UpdateRateLimitMaxRequests without token
   ...  - verify error is returned

   [Tags]  RateLimit

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Update Rate Limit Max Requests  region=${region}  use_defaults=${False}

# ECQ-4059
UpdateRateLimitFlow - update with missing parms shall return error
   [Documentation]
   ...  - send UpdateRateLimitFlow with various missing parms 
   ...  - verify error is returned 

   [Tags]  RateLimit

   [Template]  Update Flow Fail

      Invalid FlowSettingsName  use_defaults=${False}
      Invalid ApiName           flow_settings_name=${flow_name}  use_defaults=${False}
      Invalid RateLimitTarget   flow_settings_name=${flow_name}  api_name=yy  use_defaults=${False}
      Invalid ApiEndpointType   flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequests  use_defaults=${False}

# ECQ-4060
UpdateRateLimitFlow - update with invalid parms shall return error 
   [Documentation]
   ...  - send UpdateRateLimitFlow with various invalid parms
   ...  - verify error is returned

   [Tags]  RateLimit

   [Template]  Update Flow Fail

   # create with LeakyBucket and burstsize
   # fixed - EDGECLOUD-5465  able to create/update ratelimitsettings flow with flowalgorithm=LeakyBucketAlgorithm and burstsize=2
   BurstSize does not apply for the leaky bucket algorithm  flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=5  burst_size=5  use_defaults=${False}

   # negative requests per second
   Invalid ReqsPerSecond -5.000000, must be greater than 0  flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=-5  burst_size=5  use_defaults=${False}

   # negative burst size
   Invalid BurstSize -5, must be greater than 0  flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=-5  use_defaults=${False}

   # decimal burst size
   Invalid JSON data: Unmarshal error: expected int64, but got number 5.1 for field \\\\"FlowRateLimitSettings.settings.burst_size\\\\" at offset  flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5.1  use_defaults=${False}

   # fixed - EDGECLOUD-5481 ratelimitsettings with invalid flowalgorithm,apiendpointtype and ratelimittarget need better error message
   # invalid rate limit target
   Invalid JSON data: Invalid RateLimitTarget value \\\\"AllRequest\\\\"  flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequest  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5  use_defaults=${False}

   # invalid api_endpoint_type
   Invalid JSON data: Invalid ApiEndpointType value \\\\"Dm\\\\"  flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dm  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5  use_defaults=${False}

   # invalid flow algor
   Invalid JSON data: Invalid FlowRateLimitAlgorithm value \\\\"xxx\\\\""  flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=xxx  requests_per_second=5  burst_size=5  use_defaults=${False}
   Invalid JSON data: Invalid FlowRateLimitAlgorithm value 99  flow_settings_name=${flow_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=${99}  requests_per_second=5  burst_size=5  use_defaults=${False}

# ECQ-4061
UpdateRateLimitMaxRequests - update with invalid parms shall return error
   [Documentation]
   ...  - send UpdateRateLimitMaxRequests with various invalid parms
   ...  - verify error is returned

   [Tags]  RateLimit

   [Template]  Update Max Requests Fail

   # negative maxrequests
   Invalid MaxRequests -11, must be greater than 0  max_requests_settings_name=${max_requests_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=-11  interval=1m

   # decimal maxrequests
   Invalid JSON data: Unmarshal error: expected int64, but got number 11.5 for field \\\\"MaxReqsRateLimitSettings.settings.max_requests\\\\" at offset  max_requests_settings_name=${max_requests_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11.5  interval=1m

   # fixed - EDGECLOUD-5481 ratelimitsettings with invalid flowalgorithm,apiendpointtype and ratelimittarget need better error message
   # invalid rate limit target
   Invalid JSON data: Invalid RateLimitTarget value \\\\"AllRequest\\\\"  max_requests_settings_name=${max_requests_name}  api_name=yy  rate_limit_target=AllRequest  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=1m

   # invalid api_endpoint_type
   Invalid JSON data: Invalid ApiEndpointType value \\\\"Dm\\\\"  max_requests_settings_name=${max_requests_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dm  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=1m

   # invalid interval
   Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc  max_requests_settings_name=${max_requests_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=1
   Invalid JSON data: Unmarshal duration \\\\"m\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc  max_requests_settings_name=${max_requests_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=m
   Invalid Interval -1000000000, must be greater than 0                                                    max_requests_settings_name=${max_requests_name}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=11  interval=-1s

# ECQ-4062
UpdateRateLimitFlow - update with non-existent flow shall return error
   [Documentation]
   ...  - send UpdateRateLimitFlow for flow that doesnt exist 
   ...  - verify error is returned

   [Tags]  RateLimit

   # EDGECLOUD-5487  ratelimitsettings updateflow gives wrong error when key not found 

   ${error}=  Run Keyword and Expect Error  *  Update Rate Limit Flow  region=${region}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=5
   Should Be Equal  ${error}  ('code=400', 'error={"message":"FlowRateLimitSettings key {\\\\"flow_settings_name\\\\":\\\\"${flow_name}\\\\",\\\\"rate_limit_key\\\\":{\\\\"api_name\\\\":\\\\"yy\\\\",\\\\"api_endpoint_type\\\\":1,\\\\"rate_limit_target\\\\":1}} not found"}')

# ECQ-4063
UpdateRateLimitMaxRequests - update with non-existent flow shall return error
   [Documentation]
   ...  - send UpdateRateLimitMaxRequests for flow that doesnt exist
   ...  - verify error is returned

   [Tags]  RateLimit

   # EDGECLOUD-5685 - ratelimitsettings updatemaxreqs gives wrong error when key not found 

   ${error}=  Run Keyword and Expect Error  *  Update Rate Limit Max Requests  region=${region}  token=${token}  max_requests_settings_name=xx  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=1  interval=1m
   Should Be Equal  ${error}  ('code=400', 'error={"message":"FlowRateLimitSettings key {\\\\"max_reqs_settings_name\\\\":\\\\"xx\\\\",\\\\"rate_limit_key\\\\":{\\\\"api_name\\\\":\\\\"yy\\\\",\\\\"api_endpoint_type\\\\":1,\\\\"rate_limit_target\\\\":1}} not found"}')

# ECQ-4064
UpdateRateLimitMaxRequests - update with missing parms shall return error
   [Documentation]
   ...  - send UpdateRateLimitMaxRequests with various missing parms
   ...  - verify error is returned

   [Tags]  RateLimit

   [Template]  Update Max Requests Fail

   Invalid MaxReqsSettingsName                    use_defaults=${False}
   Invalid ApiName                                max_requests_settings_name=${max_requests_name}  use_defaults=${False}
   Invalid RateLimitTarget                        max_requests_settings_name=${max_requests_name}  api_name=yy  use_defaults=${False}
   Invalid ApiEndpointType                        max_requests_settings_name=${max_requests_name}  api_name=yy  rate_limit_target=AllRequests  use_defaults=${False}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${flow_name}=  Get Default Rate Limiting Flow Name
   Set Suite Variable  ${flow_name}

   ${max_requests_name}=  Get Default Rate Limiting Max Requests Name
   Set Suite Variable  ${max_requests_name}

Update Flow Fail
   [Arguments]  ${message}  &{parms}

   [Teardown]  Cleanup Provisioning

   Create Rate Limit Flow  region=${region}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=${5}  burst_size=${5}

   ${error}=  Run Keyword and Expect Error  *  Update Rate Limit Flow  region=${region}  token=${token}  &{parms}
   Should Contain  ${error}  ('code=400', 'error={"message":"${message}

Update Max Requests Fail
   [Arguments]  ${message}  &{parms}

   [Teardown]  Cleanup Provisioning

   Create Rate Limit Max Requests  region=${region}  api_name=yy  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=${5}  interval=5s

   ${error}=  Run Keyword and Expect Error  *  Update Rate Limit Max Requests  region=${region}  token=${token}  &{parms}
   Should Contain  ${error}  ('code=400', 'error={"message":"${message}


