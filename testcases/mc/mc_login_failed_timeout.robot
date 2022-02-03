*** Settings ***
Documentation   MasterController user/current superuser

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  OperatingSystem
Library  String
Library  Collections
	
Suite Setup	 Setup
Test Teardown    Cleanup provisioning

*** Variables ***
	
*** Test Cases ***
# ECQ-4314
MC - Veryify failed login threshold 1 delay
	[Documentation]
	...   failed logins has 2 thresholds, each threshold has a delay
	...   default for threshold1 is 3 with a delay of 60 seconds
	...   so 3 failed logins with a 3 second delay untill threshold1 is reached
	...   then a 60 seocond delay until threshold 2 is reached
	...   this test will set threshold 1 to 1 with a 15 second delay
	...   1 failed login with a three second delay and the next should have a 15 second delay
	...   failed logins can be cleared using the mcctl command restrictedupdateuser failedlogins=0

	${one}         Convert To Integer  1
	${fifteen}     Convert To Integer  15
	${three}       Convert To Integer  3
	${sixty}       Convert To Integer  60
	${ten}         Convert To Integer  10
	${threehund}   Convert To Integer  300
	${zero}        Convert To Integer  0

        # Create a user for the test
	${epoch}=        Get Current Date  result_format=epoch
        ${username}=     Set Variable      newuser${epoch}
        ${password}=     Set Variable      H31m8@W8maSfg
	${wrongpass}=    Set Variable      H31m8@W8maSf
        ${email}=        Set Variable      ${username}@gmail.com
	Create User    username=${username}     password=${password}     email_address=${email} 
	Update Restricted User   username=${username}  email_verified=${True}   locked=${False}   

        # Set the config
        Set Fail Threshold1 Config   fail_threshold1=${one}
	Set Threshold1 Delay Config  threshold1_delay=${fifteen}
	${config}=   Show Config     token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${one}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}     ${fifteen}
	
	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Contain  ${error}    {"message":"Invalid username or password"}

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Match Regexp  ${error}    {"message":"Login temporarily disabled due to 1 failed login attempts, please try again in \\d{2}s"}

        # Set the config back to deafult
	Set Fail Threshold2 Config   fail_threshold2=${ten}
	Set Threshold2 Delay Config  threshold2_delay=${threehund}
        Set Fail Threshold1 Config   fail_threshold1=${three}
	Set Threshold1 Delay Config  threshold1_delay=${sixty}
	${config}=   Show Config     token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${three}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}     ${sixty}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold2']}   ${ten}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec2']}     ${threehund}

# ECQ-4315
MC - Veryify failed login threshold 2 delay
	[Documentation]
	...   failed logins has 2 thresholds, each threshold has a delay
	...   default for threshold1 is 3 with a delay of 60 seconds
	...   so 3 failed logins with a 3 second delay untill threshold1 is reached
	...   then a 60 seocond delay until threshold 2 is reached
	...   this test will set threshold 1 to 1 with a 20 second delay
	...   and threshold 2 to 2 with a 90 second delay 
	...   1 failed login with a three second delay and the next should have a 15 second delay
	...   the next failed login should have a delay of 15 seconds
	...   failed logins can be cleared using the mcctl command restrictedupdateuser failedlogins=0

	${one}         Convert To Integer  1
	${twenty}      Convert To Integer  20
	${four}        Convert To Integer  2
	${ninety}      Convert To Integer  90	
	${three}       Convert To Integer  3
	${sixty}       Convert To Integer  60
	${ten}         Convert To Integer  10
	${threehund}   Convert To Integer  300

        # Create a user for the test
	${epoch}=        Get Current Date  result_format=epoch
        ${username}=     Set Variable      newuser${epoch}
        ${password}=     Set Variable      H31m8@W8maSfg
	${wrongpass}=    Set Variable      H31m8@W8maSf
        ${email}=        Set Variable      ${username}@gmail.com
	Create User    username=${username}     password=${password}     email_address=${email} 
	Update Restricted User   username=${username}  email_verified=${True}   locked=${False}   

        # Set the config
        Set Fail Threshold1 Config   fail_threshold1=${one}
	Set Threshold1 Delay Config  threshold1_delay=${twenty}
	Set Fail Threshold2 Config   fail_threshold2=${four}
	Set Threshold2 Delay Config  threshold2_delay=${ninety}
	${config}=   Show Config     token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${one}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}     ${twenty}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold2']}   ${four}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec2']}     ${ninety}
	
	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Contain  ${error}    {"message":"Invalid username or password"}

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Match Regexp  ${error}    {"message":"Login temporarily disabled due to 1 failed login attempts, please try again in \\d{2}s"}

        Sleep   20s

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Match Regexp  ${error}    {"message":"Invalid username or password"}

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Match Regexp  ${error}    {"message":"Login temporarily disabled due to 2 failed login attempts, please try again in 1m\\d{2}s"}

	# Set the config back to deafult
	Set Fail Threshold2 Config   fail_threshold2=${ten}
	Set Threshold2 Delay Config  threshold2_delay=${threehund}
        Set Fail Threshold1 Config   fail_threshold1=${three}
	Set Threshold1 Delay Config  threshold1_delay=${sixty}
	${config}=   Show Config     token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${three}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}     ${sixty}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold2']}   ${ten}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec2']}     ${threehund}

MC - Veriy failed login set to 0 works
	[Documentation]
	...   failed logins can be set to 0 with the restrictedupdateuser command 
	...   do 2 failed logins then reset the failed logins
	...   the next failed login should show 1 failed login 
	...   failed logins can be cleared using the mcctl command restrictedupdateuser failedlogins=0

	${one}         Convert To Integer  1
	${fifteen}     Convert To Integer  15
	${three}       Convert To Integer  3
	${sixty}       Convert To Integer  60
	${ten}         Convert To Integer  10
	${threehund}   Convert To Integer  300
	${zero}        Convert To Integer  0

        # Create a user for the test
	${epoch}=        Get Current Date  result_format=epoch
        ${username}=     Set Variable      newuser${epoch}
        ${password}=     Set Variable      H31m8@W8maSfg
	${wrongpass}=    Set Variable      H31m8@W8maSf
        ${email}=        Set Variable      ${username}@gmail.com
	Create User    username=${username}     password=${password}     email_address=${email} 
	Update Restricted User   username=${username}  email_verified=${True}   locked=${False}   

        # Set the config
        Set Fail Threshold1 Config   fail_threshold1=${one}
	Set Threshold1 Delay Config  threshold1_delay=${fifteen}
	${config}=   Show Config     token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${one}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}     ${fifteen}
	
	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Contain  ${error}    {"message":"Invalid username or password"}

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Match Regexp  ${error}    {"message":"Login temporarily disabled due to 1 failed login attempts, please try again in \\d{2}s"}

        Sleep   15s

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Match Regexp  ${error}    {"message":"Invalid username or password"}

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Match Regexp  ${error}    {"message":"Login temporarily disabled due to 2 failed login attempts, please try again in \\d{2}s"}
        
        Update Restricted User   username=${username}   failed_logins=${zero}

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Contain  ${error}    {"message":"Invalid username or password"}

	${error}=   Run Keyword And Expect Error   *   Login  username=${username}  password=${wrongpass}
	Should Contain  ${error}    code=400
	Should Match Regexp  ${error}    {"message":"Login temporarily disabled due to 1 failed login attempts, please try again in \\d{2}s"}


        # Set the config back to deafult
	Set Fail Threshold2 Config   fail_threshold2=${ten}
	Set Threshold2 Delay Config  threshold2_delay=${threehund}
        Set Fail Threshold1 Config   fail_threshold1=${three}
	Set Threshold1 Delay Config  threshold1_delay=${sixty}
	${config}=   Show Config     token=${adminToken}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold1']}   ${three}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec1']}     ${sixty}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutThreshold2']}   ${ten}
	Should Be Equal As Numbers   ${config['FailedLoginLockoutTimeSec2']}     ${threehund}


*** Keywords ***
Setup
	${adminToken}=   Login  username=qaadmin  password=mexadminfastedgecloudinfra

	Set Suite Variable    ${adminToken}

