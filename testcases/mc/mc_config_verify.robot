*** Settings ***
Documentation   MasterController Org Create as Admin
	
Library		MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${username}=    mextester06
${password}=    H31m8@W8maSfg
${adminuser}=   mextester06admin
${adminpass}=   mexadminfastedgecloudinfra
	
*** Test Cases ***
# ECQ-2772
MC - Admin shall be able to show the config
	[Documentation]
	...  pull the mc config using the admin token  
	...  verify the config items are returned

	${config}=   Show Config    token=${adminToken}
	Should Contain   ${config}   SkipVerifyEmail
	Should Contain   ${config}   LockNewAccounts
	Should Contain   ${config}   NotifyEmailAddress
	Should Contain   ${config}   PasswordMinCrackTimeSec
	Should Contain   ${config}   AdminPasswordMinCrackTimeSec
        Should Contain   ${config}   MaxMetricsDataPoints
	Should Contain   ${config}   UserApiKeyCreateLimit
	Should Contain   ${config}   RateLimitMaxTrackedIps
	Should Contain   ${config}   RateLimitMaxTrackedUsers
	Should Contain   ${config}   FailedLoginLockoutThreshold1
	Should Contain   ${config}   FailedLoginLockoutTimeSec1
	Should Contain   ${config}   FailedLoginLockoutThreshold2
	Should Contain   ${config}   FailedLoginLockoutTimeSec2
        Should Contain   ${config}   UserLoginTokenValidDuration
        Should Contain   ${config}   ApiKeyLoginTokenValidDuration
        Should Contain   ${config}   WebsocketTokenValidDuration

# ECQ-2773
MC - Admin shall be able to set the SkipVerifyEmail config item
	[Documentation]
	...  change SkipVerifyEmail to False using the admin token
	...  verify SkipVerifyEmail is set to False
	...  then change SkipVerifyEmail to True  
	...  verify SkipVerifyEmail is set to True

	Set Skip Verify Email  skip_verify_email=False 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['SkipVerifyEmail']}   ${False}

	Set Skip Verify Email  skip_verify_email=True 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['SkipVerifyEmail']}   ${True}


# ECQ-2774	
MC - Admin shall be able to set the LockNewAccouts config item
	[Documentation]
	...  change LockNewAccounts to False using the admin token
	...  verify LockNewAccounts is set to False
	...  then change LockNewAccounts to True  
	...  verify LockNewAccounts is set to True
	
	Set Lock Accounts Config  lock_accounts=False 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['LockNewAccounts']}   ${False}

	Set Lock Accounts Config  lock_accounts=True 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['LockNewAccounts']}   ${True}


# ECQ-2775
MC - Admin shal be able to set the NotifyEmailAddress config item
	[Documentation]
	...  change NotifyEmailAddress to someaddress@123.com  using the admin token
	...  verify NotifyEmailAddress is set someaddress@123.com
	...  then change NotifyEmailAddress back to the QA Default of mexcontester@gmail.com
	...  verify NotifyEmailAddress is set to the QA Default

	Set Notify Email Config   notify_email=someaddress@123.com
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Strings   ${config['NotifyEmailAddress']}   someaddress@123.com

	Set Notify Email Config   notify_email=mexcontester@gmail.com
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Strings   ${config['NotifyEmailAddress']}   mexcontester@gmail.com


# ECQ-2776
MC - Admin shal be able to set the User and Admin Password strength config items
	[Documentation]
	...  change PasswordMinCrackTimeSec to 2 using the admin token
	...  change AdminPasswordMinCrackTimeSec to 3 using the admin token
	...  verify the User and Admin password strengths are changed
	...  then change User and Admin password strengths back to the QA Defauls 
	...  verify User and Admin password strengths are set to the QA Defaults
	...  QA Defaultes User 2592000, Admin 63072000}

        ${level}=   Convert To Integer  2 
	Set User Pass Strength Config   user_pass=${level}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['PasswordMinCrackTimeSec']}   ${level}

        ${level}=   Convert To Integer  3 
        Set Admin Pass Strength Config   admin_pass=${level}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['AdminPasswordMinCrackTimeSec']}   ${level}

        Set Admin Pass Strength Config   admin_pass=${admindefaultlvl}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['AdminPasswordMinCrackTimeSec']}   ${admindefaultlvl}

	Set User Pass Strength Config   user_pass=${userdefaultlvl}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['PasswordMinCrackTimeSec']}   ${userdefaultlvl}

# ECQ-2779
MC - Verify Admin Password strength can not be set lower than User Password strength
	[Documentation]
	...  the user password strength should be at the default of 2592000
	...  change AdminPasswordMinCrackTimeSec to 4 using the admin token
	...  verify Admin password strength fails to set
	...  QA Defaultes User 2592000, Admin 63072000}
	
	${level}=   Convert To Integer  4 
	${error}=    Run Keyword and Expect Error  *   Set Admin Pass Strength Config   admin_pass=${level}
	Should Contain  ${error}    400
	Should Contain  ${error}    {"message":"Admin password min crack time must be greater than password min crack time"}


# ECQ-2780
MC - Verify User Password strength can not be set higher than Admin Password strength
	[Documentation]
	...  change PasswordMinCrackTimeSec to 1 higher than the default admin pass strength using the admin token
	...  verify the user password strength fails to set
	...  QA Defaultes User 2592000, Admin 63072000}
	
	${level}=   Convert To Integer  63072001 
	${error}=   Run Keyword and Expect Error  *   Set User Pass Strength Config   user_pass=${level}
	Should Contain  ${error}    code=400
	Should Contain  ${error}    {"message":"Admin password min crack time must be greater than password min crack time"}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['PasswordMinCrackTimeSec']}   ${userdefaultlvl}

# ECQ-2927
MC - Admin shall be able to set the MaxMetricsDataPoints config item
        [Documentation]
        ...  - change MaxMetricsDataPoints to a value using the admin token
        ...  - verify MaxMetricsDataPoints is set
        ...  - then change MaxMetricsDataPoints back

        ${config}=   Show Config    token=${adminToken}
        ${maxdata}=  Set Variable  ${config['MaxMetricsDataPoints']}

        Set Max Metrics Data Points Config   1234
        ${config}=   Show Config    token=${adminToken}
        Should Be Equal As Numbers   ${config['MaxMetricsDataPoints']}  1234 

        Set Max Metrics Data Points Config  ${maxdata} 
        ${config}=   Show Config    token=${adminToken}
        Should Be Equal As Numbers   ${config['MaxMetricsDataPoints']}  ${maxdata}

# ECQ-4254
MC - Admin shall be able to set the UserApiKeyCreateLimit config item
	[Documentation]
	...  default value for userapikeycreatelimit is 10
	...  set userapikeycreatelimit to 1
	...  set userapikeycreatelimit back to the default (10)

	${one}   Convert To Integer  1
	${ten}   Convert To Integer  10
	
	Set Apikey Limit Config    apikey_limit=${one}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['UserApiKeyCreateLimit']}   ${one}

	Set Apikey Limit Config   apikey_limit=${ten}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['UserApiKeyCreateLimit']}   ${ten}

# ECQ-4255
MC - Admin shall be able to set the RateLimitMaxTrackedIps config item 
	[Documentation]
	...  default value for ratelimitmaxtrackedips is 10000
	...  set ratelimitmaxtrackedips to 10 
	...  set ratelimitmaxtrackedips back to the default (10000)

	${ten}   Convert To Integer  10
	${ipsdefault}  Convert To Integer  10000 

        Set Rate Limit Ips Config  rate_limit_ips=${ten}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['RateLimitMaxTrackedIps']}  ${ten}

        Set Rate Limit Ips Config  rate_limit_ips=${ipsdefault}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['RateLimitMaxTrackedIps']}  ${ipsdefault}

# ECQ-4256
MC - Admin shall be able to set the RateLimitMaxTrackedUsers config item 
	[Documentation]
	...  default value for ratelimitmaxtrackedusers is 10000
	...  set ratelimitmaxtrackedusers to 10 
	...  set ratelimitmaxtrackedusers back to the default (10000)

	${ten}   Convert To Integer  10
	${userdefault}  Convert To Integer  10000 

        Set Rate Limit Users Config  rate_limit_users=${ten}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['RateLimitMaxTrackedUsers']}  ${ten}

        Set Rate Limit Users Config  rate_limit_users=${userdefault}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['RateLimitMaxTrackedUsers']}   ${userdefault}

# ECQ-4257
MC - Admin shall be able to set the FailedLoginLockoutThreshold1 config item
	[Documentation]
	...  default value for failedloginlockoutthreshold1 is 3
	...  set failedloginlockoutthreshold1 to 1
	...  set failedloginlockoutthreshold1 back to the default (3)

	${one}   Convert To Integer  1
	${three}  Convert To Integer  3
	
	Set Fail Threshold1 Config   fail_threshold1=${one}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${one}

	Set Fail Threshold1 Config   fail_threshold1=${three}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${three}

# ECQ-4258
MC - Admin shall be able to set the FailedLoginLockoutTimeSec1 config item
	[Documentation]
	...  default value for failedloginlockouttimesec1 is 60 seconds 
	...  set failedloginlockouttimesec1 to 10
	...  set failedloginlockouttimesec1 back to the default (60)

	${ten}   Convert To Integer  10
	${sixty}  Convert To Integer  60
	
	Set Threshold1 Delay Config  threshold1_delay=${ten}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}   ${10}

	Set Threshold1 Delay Config  threshold1_delay=${sixty}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}   ${60}

# ECQ-4259
MC - Admin shall be able to set the FailedLoginLockoutThreshold2 config item
	[Documentation]
	...  default value for failedloginlockoutthreshold2 is 10 
	...  set failedloginlockoutthreshold2 to 3 
	...  set failedloginlockoutthreshold2 back to the default (10)

	${four}  Convert To Integer  4
	${ten}   Convert To Integer  10

	Set Fail Threshold2 Config   fail_threshold2=${four}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold2']}   ${four}

	Set Fail Threshold2 Config   fail_threshold2=${ten}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold2']}   ${ten}

# ECQ-4260
MC - Admin shall be able to set the FailedLoginLockoutTimeSec2 config item
	[Documentation]
	...  default value for failedloginlockouttimesec2 is 300 seconds
	...  set failedloginlockouttimesec2 to 10 
	...  set failedloginlockoutthreshold2 back to the default (300)

	${seventy}   Convert To Integer  70
	${2default}  Convert To Integer  300
	
	Set Threshold2 Delay Config  threshold2_delay=${seventy}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec2']}   ${seventy}

	Set Threshold2 Delay Config  threshold2_delay=${2default}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec2']}   ${2default}

# ECQ-4261
MC - Verify FailedLoginLockoutThreshold1 can not be set higher than FailedLoginLockoutThreshold2
	[Documentation]
	...  default value for failedloginlockoutthreshold1 is 3
	...  default value for failedloginlockoutthreshold2 is 10
	...  set failedloginlockoutthreshold1 to 12
	...  verify the update fails with an message 

	${three}  Convert To Integer  3
	${tweleve}   Convert To Integer  12
	
	${error}=    Run Keyword and Expect Error  *   Set Fail Threshold1 Config   fail_threshold1=${tweleve}
	Should Contain  ${error}    400
	Should Contain  ${error}    {"message":"Failed login lockout threshold 2 of 10 must be greater than threshold 1 of 12"}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${three}

# ECQ-4262
MC - Verify FailedLoginLockoutTimeSec1 can not be set greater than FailedLoginLockoutTimeSec2
	[Documentation]
	...  default value for failedloginlockouttimesec1 is 60 seconds 
	...  default value for failedloginlockouttimesec2 is 300 seconds
	...  set failedloginlockouttimesec1 to 1000 seconds
	...  verify the update fails with an message 

	${sixty}  Convert To Integer  60
	${thousand}   Convert To Integer  1000

	${error}=    Run Keyword and Expect Error  *   Set Threshold1 Delay Config   threshold1_delay=${thousand}
	Should Contain  ${error}    400
	Should Contain  ${error}    {"message":"Failed login lockout time sec 2 of 5m0s must be greater than or equal to lockout time 1 of 16m40s"}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}   ${sixty}

# ECQ-4263
MC - Verify FailedLoginLockoutThreshold2 can not be set lower than FailedLoginLockoutThreshold1
	[Documentation]
	...  default value for failedloginlockoutthreshold1 is 3
	...  default value for failedloginlockoutthreshold2 is 10
	...  set failedloginlockoutthreshold2 to 1
	...  verify the update fails with an message 

	${one}   Convert To Integer  1
	${ten}   Convert To Integer  10
	
	${error}=    Run Keyword and Expect Error  *   Set Fail Threshold2 Config   fail_threshold2=${one}
	Should Contain  ${error}    400
	Should Contain  ${error}    {"message":"Failed login lockout threshold 2 of 1 must be greater than threshold 1 of 3"}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold2']}   ${ten}

#ECQ-4264
MC - Verify FailedLoginLockoutTimeSec2 can not be lower than FailedLoginLockoutTimeSec1
	[Documentation]
	...  default value for failedloginlockouttimesec1 is 60 seconds 
	...  default value for failedloginlockouttimesec2 is 300 seconds
	...  set failedloginlockouttimesec2 to 10 seconds
	...  verify the update fails with an message 

	${ten}  Convert To Integer  10
	${2default}   Convert To Integer  300

	${error}=    Run Keyword and Expect Error  *   Set Threshold2 Delay Config   threshold2_delay=${ten}
	Should Contain  ${error}    400
	Should Contain  ${error}    {"message":"Failed login lockout time sec 2 of 10s must be greater than or equal to lockout time 1 of 1m0s"}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec2']}   ${2default}

# ECQ-4414
MC - Admin shall be able to set the token validation config items
        [Documentation]
        ...  - set UserLoginTokenValidDuration, ApiKeyLoginTokenValidDuration, WebsocketTokenValidDuration
        ...  - verify values are updated

        [Teardown]  Config Cleanup

        Set Token Duration Config   user_login_token_valid_duration=4m1s
        ${config}=   Show Config    token=${adminToken}
        Should Be Equal  ${config['UserLoginTokenValidDuration']}  4m1s 
        Set Token Duration Config   user_login_token_valid_duration=24h
        ${config}=   Show Config    token=${adminToken}
        Should Be Equal   ${config['UserLoginTokenValidDuration']}   24h0m0s

        Set Token Duration Config   api_key_login_token_valid_duration=1s
        ${config}=   Show Config    token=${adminToken}
        Should Be Equal  ${config['ApiKeyLoginTokenValidDuration']}  1s
        Set Token Duration Config   api_key_login_token_valid_duration=1m5s
        ${config}=   Show Config    token=${adminToken}
        Should Be Equal   ${config['ApiKeyLoginTokenValidDuration']}   1m5s

        Set Token Duration Config   websocket_token_valid_duration=100h4m1s
        ${config}=   Show Config    token=${adminToken}
        Should Be Equal  ${config['WebsocketTokenValidDuration']}  100h4m1s
        Set Token Duration Config   websocket_token_valid_duration=24m
        ${config}=   Show Config    token=${adminToken}
        Should Be Equal   ${config['WebsocketTokenValidDuration']}   24m0s

# ECQ-4415
MC - Token validation config items shall error on invalid data
        [Documentation]
        ...  - set UserLoginTokenValidDuration, ApiKeyLoginTokenValidDuration, WebsocketTokenValidDuration to invalid data
        ...  - verify error is returned

        [Teardown]  Config Cleanup

        Run Keyword and Expect Error  ('code=400', 'error={"message":"User login token valid duration cannot be less than 3 minutes"}')  Set Token Duration Config   user_login_token_valid_duration=1s
        Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected duration, but got string ones for field \\\\"UserLoginTokenValidDuration\\\\", valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')  Set Token Duration Config   user_login_token_valid_duration=ones

        Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected duration, but got string ones for field \\\\"ApiKeyLoginTokenValidDuration\\\\", valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')  Set Token Duration Config   api_key_login_token_valid_duration=ones

        Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected duration, but got string ones for field \\\\"WebsocketTokenValidDuration\\\\", valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')  Set Token Duration Config   websocket_token_valid_duration=ones

*** Keywords ***
Setup
	${adminToken}=  Login    username=qaadmin    password=${adminpass}
	${admindefaultlvl}=   Convert To Integer  63072000 
	${userdefaultlvl}=    Convert To Integer  2592000 

        Set Suite Variable   ${adminToken}
	Set Suite Variable   ${admindefaultlvl}
	Set Suite Variable   ${userdefaultlvl}

Config Cleanup
    Set Token Duration Config   user_login_token_valid_duration=24h0m0s
    Set Token Duration Config   api_key_login_token_valid_duration=4h0m0s
    Set Token Duration Config   websocket_token_valid_duration=2m0s

    Cleanup Provisioning
