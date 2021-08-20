# -*- coding: robot -*-

*** Settings ***
Documentation  ratelimitsettings update

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3728
UpdateRateLimitFlow - shall be able to update flow
   [Documentation]
   ...  - send UpdateRateLimitFlow with various parms
   ...  - verify update is successful

   [Tags]  RateLimit 

   [Template]  Flow Shall Be Updated

   flow_settings_name=${flow_name}  api_name=RegisterClient  rate_limit_target=AllRequests    api_endpoint_type=Dme  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=15
   flow_settings_name=${flow_name}  api_name=Global          rate_limit_target=PerIp          api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=5  burst_size=10
   flow_settings_name=${flow_name}  api_name=Global          rate_limit_target=PerUser        api_endpoint_type=Dme  flow_algorithm=TokenBucketAlgorithm  requests_per_second=25  burst_size=20

# ECQ-3729
UpdateRateLimitMaxRequests - shall be able to update maxreqs
   [Documentation]
   ...  - send UpdateRateLimitMaxRequests with various parms
   ...  - verify update is successful

   [Tags]  RateLimit

   [Template]  Max Requests Shall Be Updated

   max_requests_settings_name=${max_reqs_name}  api_name=yy2  rate_limit_target=AllRequests  api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=2  interval=2m0s
   max_requests_settings_name=${max_reqs_name}  api_name=yy2  rate_limit_target=PerIp        api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=31  interval=2h0m0s
   max_requests_settings_name=${max_reqs_name}  api_name=yy2  rate_limit_target=PerUser      api_endpoint_type=Dme  max_requests_algorithm=FixedWindowAlgorithm  max_requests=41  interval=2s

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${flow_name}=  Get Default Rate Limiting Flow Name
   Set Suite Variable  ${flow_name}

   ${max_reqs_name}=  Get Default Rate Limiting Max Requests Name
   Set Suite Variable  ${max_reqs_name}

Flow Shall Be Updated
   [Arguments]  &{parms}

   ${showc}=  Create Rate Limit Flow  region=${region}  flow_settings_name=${parms['flow_settings_name']}  api_name=${parms['api_name']}  rate_limit_target=${parms['rate_limit_target']}  api_endpoint_type=${parms['api_endpoint_type']}  flow_algorithm=LeakyBucketAlgorithm  requests_per_second=5 

   ${show}=  Update Rate Limit Flow  region=${region}  &{parms}

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

Max Requests Shall Be Updated
   [Arguments]  &{parms}

   ${rate_limit_target_num}=  Set Variable  ${0}

   Create Rate Limit Max Requests  region=${region}  max_requests_settings_name=${parms['max_requests_settings_name']}  api_name=${parms['api_name']}  rate_limit_target=${parms['rate_limit_target']}  api_endpoint_type=${parms['api_endpoint_type']}  max_requests_algorithm=FixedWindowAlgorithm  max_requests=1  interval=1m0s

   ${show}=  Update Rate Limit Max Requests  region=${region}  &{parms}  

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
