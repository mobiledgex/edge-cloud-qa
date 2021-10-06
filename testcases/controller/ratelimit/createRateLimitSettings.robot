# -*- coding: robot -*-

*** Settings ***
Documentation  ratelimitsettings create

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3730
CreateRateLimitFlow - shall be able to create with LeakyBucketAlgorithm
   [Documentation]
   ...  - send CreateRateLimitFlow with LeakyBucketAlgorithm
   ...  - verify create is successful

   [Tags]  RateLimit 

   [Template]  Flow Shall Be Created

   flow_settings_name=${flow_name}  api_name=RegisterClient  rate_limit_target=AllRequests    api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=${5}
   flow_settings_name=${flow_name}  api_name=Global          rate_limit_target=PerIp          api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=${5}
   flow_settings_name=${flow_name}  api_name=FindCloudlet    rate_limit_target=PerUser        api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=${5}

# ECQ-3731
CreateRateLimitFlow - shall be able to create with TokenBucketAlgorithm
   [Documentation]
   ...  - send CreateRateLimitFlow with TokenBucketAlgorithm
   ...  - verify create is successful

   [Tags]  RateLimit

   [Template]  Flow Shall Be Created

   flow_settings_name=${flow_name}  api_name=RegisterClient  rate_limit_target=AllRequests    api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=${5}  burst_size=${1}
   flow_settings_name=${flow_name}  api_name=Global          rate_limit_target=PerIp          api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=${5}  burst_size=${1}
   flow_settings_name=${flow_name}  api_name=FindCloudlet    rate_limit_target=PerUser        api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=${5}  burst_size=${100}

# ECQ-3732
CreateRateLimitFlow - shall be able to create max num per ip rate limiters
   [Documentation]
   ...  - send CreateRateLimitFlows greater than settings.maxnumperipratelimiters
   ...  - verify only maxnumperipratelimiters flows are created

   [Tags]  RateLimit

   # EDGECLOUD-5494  able to add more rate limit flows than maxnumperipratelimiters 

   ${flow_limit}=  Set Variable  100
   ${flow_add}=  Evaluate  ${flow_limit} + 10

   ${max}=  Update Settings  region=${region}  rate_limit_max_tracked_ips=${flow_limit}

#   FOR  ${x}  IN RANGE  ${max['max_num_per_ip_rate_limiters']+1}
   FOR  ${x}  IN RANGE  ${flow_add}
       Flow Shall Be Created  flow_settings_name=${flow_name}${x}  api_name=RegisterClient  rate_limit_target=PerIp  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=${5}  burst_size=${1}
   END

   ${show2}=  Show Rate Limit Settings  region=${region}  api_name=RegisterClient  api_endpoint_type=Dme  rate_limit_target=PerIp

   Length Should Be  ${show2[0]['data']['flow_settings']}  ${flow_limit}

# ECQ-3733
CreateRateLimitFlow - shall be able to create multiple TokenBucket/AllRequests flows
   [Documentation]
   ...  - send mulitple CreateRateLimitFlow with TokenBucketAlgorithm and AllRequests
   ...  - verify all flows are created

   [Tags]  RateLimit

   ${flow_limit}=  Set Variable  150

   ${max}=  Update Settings  region=${region}  rate_limit_max_tracked_ips=100

   FOR  ${x}  IN RANGE  ${flow_limit}
       Flow Shall Be Created  flow_settings_name=${flow_name}${x}  api_name=RegisterClient  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=${5}  burst_size=${1}
   END

   ${show2}=  Show Rate Limit Settings  region=${region}  api_name=RegisterClient  api_endpoint_type=Dme  rate_limit_target=AllRequests

   Length Should Be  ${show2[0]['data']['flow_settings']}  ${flow_limit}

# ECQ-3734
CreateRateLimitFlow - shall be able to create multiple LeakyBucket/PerUser flows
   [Documentation]
   ...  - send multiple CreateRateLimitFlow with LeakyBucketAlgorithm and PerUser
   ...  - verify error is returned

   [Tags]  RateLimit

   ${flow_limit}=  Set Variable  150

   ${max}=  Update Settings  region=${region}  rate_limit_max_tracked_ips=100

   FOR  ${x}  IN RANGE  ${flow_limit}
       Flow Shall Be Created  flow_settings_name=${flow_name}${x}  api_name=RegisterClient  rate_limit_target=PerUser  api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=${5}
   END

   ${show2}=  Show Rate Limit Settings  region=${region}  api_name=RegisterClient  api_endpoint_type=Dme  rate_limit_target=PerUser

   Length Should Be  ${show2[0]['data']['flow_settings']}  ${flow_limit}

# ECQ-3735
CreateRateLimitMaxRequests - shall be able to create with FixedWindowAlgorithm
   [Documentation]
   ...  - send CreateRateLimitMaxRequests with FixedWindowAlgorithm
   ...  - verify max requests is created successfully

   [Tags]  RateLimit

   [Template]  Max Requests Shall Be Created

   max_requests_settings_name=${max_reqs_name}  api_name=yy2  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=${1}  interval=1m0s
   max_requests_settings_name=${max_reqs_name}  api_name=yy2  rate_limit_target=PerIp        api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=${1}  interval=1h0m0s
   max_requests_settings_name=${max_reqs_name}  api_name=yy2  rate_limit_target=PerUser      api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=${1}  interval=1s

# ECQ-3736
CreateRateLimitMaxRequests - shall be able to create with FixedWindowAlgorithm and existing flow
   [Documentation]
   ...  - send CreateRateLimitMaxRequests with an existing flow
   ...  - verify max requests is created successfully

   [Tags]  RateLimit

   Create Rate Limit Flow  region=${region}  flow_settings_name=${flow_name}  api_name=RegisterClient2  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=${5}
   Create Rate Limit Max Requests  region=${region}  max_requests_settings_name=${max_reqs_name}  api_name=RegisterClient2  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=${1}  interval=1m

   ${show2}=  Show Rate Limit Settings  region=${region}  api_name=RegisterClient2  api_endpoint_type=Dme  rate_limit_target=AllRequests

   Should Be Equal             ${show2[0]['data']['key']['api_name']}           RegisterClient2
   Should Be Equal As Numbers  ${show2[0]['data']['key']['api_endpoint_type']}  1
   Should Be Equal As Numbers  ${show2[0]['data']['key']['rate_limit_target']}  1

   Should Be Equal As Numbers  ${show2[0]['data']['max_reqs_settings']['${max_reqs_name}']['max_reqs_algorithm']}  1
   Should Be Equal             ${show2[0]['data']['max_reqs_settings']['${max_reqs_name}']['interval']}  1m0s
   Should Be Equal As Numbers  ${show2[0]['data']['max_reqs_settings']['${max_reqs_name}']['max_requests']}  1

   Should Be Equal As Numbers  ${show2[0]['data']['flow_settings']['${flow_name}']['flow_algorithm']}  2
   Should Be Equal As Numbers  ${show2[0]['data']['flow_settings']['${flow_name}']['reqs_per_second']}  5

   Length Should Be  ${show2}  1

# ECQ-3737
CreateRateLimitFlow - shall be able to create with existing max requests
   [Documentation]
   ...  - send CreateRateLimitFlow with an existing max request
   ...  - verify flow is created successfully

   [Tags]  RateLimit

   Create Rate Limit Max Requests  region=${region}  max_requests_settings_name=${max_reqs_name}  api_name=RegisterClient2  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=${1}  interval=1m

   Create Rate Limit Flow  region=${region}  flow_settings_name=${flow_name}  api_name=RegisterClient2  rate_limit_target=AllRequests  api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=${5}

   ${show2}=  Show Rate Limit Settings  region=${region}  api_name=RegisterClient2  api_endpoint_type=Dme  rate_limit_target=AllRequests

   Should Be Equal             ${show2[0]['data']['key']['api_name']}           RegisterClient2
   Should Be Equal As Numbers  ${show2[0]['data']['key']['api_endpoint_type']}  1
   Should Be Equal As Numbers  ${show2[0]['data']['key']['rate_limit_target']}  1

   Should Be Equal As Numbers  ${show2[0]['data']['max_reqs_settings']['${max_reqs_name}']['max_reqs_algorithm']}  1
   Should Be Equal             ${show2[0]['data']['max_reqs_settings']['${max_reqs_name}']['interval']}  1m0s
   Should Be Equal As Numbers  ${show2[0]['data']['max_reqs_settings']['${max_reqs_name}']['max_requests']}  1

   Should Be Equal As Numbers  ${show2[0]['data']['flow_settings']['${flow_name}']['flow_algorithm']}  2
   Should Be Equal As Numbers  ${show2[0]['data']['flow_settings']['${flow_name}']['reqs_per_second']}  5

   Length Should Be  ${show2}  1

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${flow_name}=  Get Default Rate Limiting Flow Name
   Set Suite Variable  ${flow_name}

   ${max_reqs_name}=  Get Default Rate Limiting Max Requests Name
   Set Suite Variable  ${max_reqs_name}

Flow Shall Be Created
   [Arguments]  &{parms}

   ${show}=  Create Rate Limit Flow  region=${region}  &{parms}

   ${rate_limit_target_num}=  Set Variable  ${0}
   ${algorithm_num}=  Set Variable  ${0}

   Should Be Equal  ${show['data']['key']['rate_limit_key']['api_name']}  ${parms['api_name']}
   Should Be Equal  ${show['data']['key']['flow_settings_name']}  ${parms['flow_settings_name']}
   Should Be Equal As Numbers   ${show['data']['settings']['reqs_per_second']}  ${parms['requests_per_second']}

   IF  '${parms['rate_limit_target']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show['data']['key']['rate_limit_key']['rate_limit_target']}  1
      ${rate_limit_target_num}=  Set Variable  ${1}
   ELSE IF  '${parms['rate_limit_target']}' == 'PerIp'
      Should Be Equal As Numbers   ${show['data']['key']['rate_limit_key']['rate_limit_target']}  2
      ${rate_limit_target_num}=  Set Variable  ${2}
   ELSE IF  '${parms['rate_limit_target']}' == 'PerUser'
      Should Be Equal As Numbers   ${show['data']['key']['rate_limit_key']['rate_limit_target']}  3
      ${rate_limit_target_num}=  Set Variable  ${3}
   ELSE
      Fail  rate_limit_targe unknown
   END

   Should Be Equal As Numbers   ${show['data']['key']['rate_limit_key']['api_endpoint_type']}  1

   IF  'burst_size' in ${parms}
      Should Be Equal As Numbers   ${show['data']['settings']['burst_size']}  ${parms['burst_size']}
   END

#   IF  'requests_per_second' in ${parms}
#      Should Be Equal As Numbers   ${show['data']['settings']['reqs_per_second']}  ${parms['requests_per_second']}
#   END

   IF  '${parms['flow_algorithm']}' == 'TokenBucketAlgorithm'
      Should Be Equal As Numbers   ${show['data']['settings']['flow_algorithm']}  1
      ${algorithm_num}=  Set Variable  ${1}
   ELSE
      Should Be Equal As Numbers   ${show['data']['settings']['flow_algorithm']}  2
      ${algorithm_num}=  Set Variable  ${2}
   END

   ${show2}=  Show Rate Limit Settings  region=${region}  api_name=${parms['api_name']}  api_endpoint_type=${parms['api_endpoint_type']}  rate_limit_target=${parms['rate_limit_target']}

   Should Be Equal             ${show2[0]['data']['key']['api_name']}           ${parms['api_name']}
   Should Be Equal As Numbers  ${show2[0]['data']['key']['api_endpoint_type']}  1
   Should Be Equal As Numbers  ${show2[0]['data']['key']['rate_limit_target']}  ${rate_limit_target_num}

   Should Be Equal As Numbers  ${show2[0]['data']['flow_settings']['${parms['flow_settings_name']}']['flow_algorithm']}  ${algorithm_num}
   Should Be Equal As Numbers  ${show2[0]['data']['flow_settings']['${parms['flow_settings_name']}']['reqs_per_second']}  ${parms['requests_per_second']}

   IF  'burst_size' in ${parms}
      Should Be Equal As Numbers   ${show2[0]['data']['flow_settings']['${parms['flow_settings_name']}']['burst_size']}  ${parms['burst_size']}
   END

   Length Should Be  ${show2}  1

Max Requests Shall Be Created
   [Arguments]  &{parms}

   ${rate_limit_target_num}=  Set Variable  ${0}

   ${show}=  Create Rate Limit Max Requests  region=${region}  &{parms}  

   Should Be Equal  ${show['data']['key']['rate_limit_key']['api_name']}  ${parms['api_name']}
   Should Be Equal  ${show['data']['key']['max_reqs_settings_name']}  ${parms['max_requests_settings_name']}
   Should Be Equal As Numbers   ${show['data']['key']['rate_limit_key']['api_endpoint_type']}  1

   IF  '${parms['rate_limit_target']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show['data']['key']['rate_limit_key']['rate_limit_target']}  1
      ${rate_limit_target_num}=  Set Variable  ${1}
   ELSE IF  '${parms['rate_limit_target']}' == 'PerIp'
      Should Be Equal As Numbers   ${show['data']['key']['rate_limit_key']['rate_limit_target']}  2
      ${rate_limit_target_num}=  Set Variable  ${2}
   ELSE IF  '${parms['rate_limit_target']}' == 'PerUser'
      Should Be Equal As Numbers   ${show['data']['key']['rate_limit_key']['rate_limit_target']}  3
      ${rate_limit_target_num}=  Set Variable  ${3}
   ELSE
      Fail  rate_limit_targe unknown
   END

   Should Be Equal              ${show['data']['settings']['interval']}  ${parms['interval']}
   Should Be Equal As Numbers   ${show['data']['settings']['max_requests']}  ${parms['max_requests']}
   Should Be Equal As Numbers   ${show['data']['settings']['max_reqs_algorithm']}  1

   ${show2}=  Show Rate Limit Settings  region=${region}  api_name=${parms['api_name']}  api_endpoint_type=${parms['api_endpoint_type']}  rate_limit_target=${parms['rate_limit_target']}

   Should Be Equal             ${show2[0]['data']['key']['api_name']}           ${parms['api_name']}
   Should Be Equal As Numbers  ${show2[0]['data']['key']['api_endpoint_type']}  1
   Should Be Equal As Numbers  ${show2[0]['data']['key']['rate_limit_target']}  ${rate_limit_target_num}

   Should Be Equal As Numbers  ${show2[0]['data']['max_reqs_settings']['${parms['max_requests_settings_name']}']['max_reqs_algorithm']}  1
   Should Be Equal             ${show2[0]['data']['max_reqs_settings']['${parms['max_requests_settings_name']}']['interval']}  ${parms['interval']}
   Should Be Equal As Numbers  ${show2[0]['data']['max_reqs_settings']['${parms['max_requests_settings_name']}']['max_requests']}  ${parms['max_requests']}

   Length Should Be  ${show2}  1
