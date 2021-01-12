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


# ECQ-2777
MC - Verify the SkipVerifyEmail change works
	[Documentation]
	...  change SkipVerifyEmail to False using the admin token
	...  verify SkipVerifyEmail is set to False
	...  (LockNewAccounts must also be set to False for this test)
	...  create a new user and verify login fails without verifying the email address
	...  then change SkipVerifyEmail to True  
	...  verify SkipVerifyEmail is set to True
	...  verif a new user can login without verifying the email address

        ${epoch}=  Get Time  epoch
        ${email}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
        ${newuser}=  Catenate  SEPARATOR=  ${username}  ${epoch}
 
	Set Skip Verify Email  skip_verify_email=False 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['SkipVerifyEmail']}   ${False}
	Set Lock Accounts Config  lock_accounts=False 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['LockNewAccounts']}   ${False}

	${variable}=  Create User   username=${newuser}   password=${password}   email_address=${email}
	#${status_code}=  Response Status Code
	#${body}=         Response Body
	#Should Be Equal As Numbers  ${status_code}  200	
	##Should Be Equal             ${body}         {"message":"user created"}
        #Should Be Equal              ${variable['Message']}         user created

	${error}=    Run Keyword and Expect Error  *   Login   username=${newuser}   password=${password}
	Should Contain  ${error}    responseCode = 400
	Should Contain  ${error}    {"message":"Email not verified yet"}

	Set Skip Verify Email  skip_verify_email=True 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['SkipVerifyEmail']}   ${True}

	${token}=   Login   username=${newuser}   password=${password}

	Set Lock Accounts Config  lock_accounts=True 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['LockNewAccounts']}   ${True}

        Delete User  username=${newuser}   token=${adminToken}
	#${status_code}=  Response Status Code
	#${body}=         Response Body
	#Should Be Equal As Numbers  ${status_code}  200	
	#Should Be Equal             ${body}         {"message":"user deleted"}


# ECQ-2778
MC - Verify the LocknewAccounts change works
	[Documentation]
	...  change LocknewAccounts to False using the admin token
	...  verify LocknewAccounts is set to False
	...  (SkipVerifyEmail must also be set to True for this test)
	...  create a new user and verify login succeeds without unlocking the account
	...  delete the new user 
	...  then change LocknewAccounts to True  
	...  verify LocknewAccounts is set to True
	...  create a new user and verify login without unlocking the account fails
	...  unlock the new user and verify login is successful 

        ${epoch}=  Get Time  epoch
        ${email}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
	${newuser}=  Catenate  SEPARATOR=  ${username}  ${epoch}

	Set Lock Accounts Config  lock_accounts=False 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['LockNewAccounts']}   ${False}
	Set Skip Verify Email  skip_verify_email=True 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['SkipVerifyEmail']}   ${True}

	${variable}=  Create User   username=${newuser}   password=${password}   email_address=${email}
	#${status_code}=  Response Status Code
	#${body}=         Response Body
	#Should Be Equal As Numbers  ${status_code}  200	
	##Should Be Equal             ${body}         {"Message":"user created"}
        #Should Be Equal             ${variable['Message']}         user created

	${token}=   Login   username=${newuser}   password=${password}

        Delete User  username=${newuser}   token=${adminToken}
	#${status_code}=  Response Status Code
	#${body}=         Response Body
	#Should Be Equal As Numbers  ${status_code}  200	
	#Should Be Equal             ${body}         {"message":"user deleted"}

	Set Lock Accounts Config  lock_accounts=True 
	${config}=   Show Config    token=${adminToken}
	Should Be Equal   ${config['LockNewAccounts']}   ${True}

	${variable}=  Create User   username=${newuser}   password=${password}   email_address=${email}
	#${status_code}=  Response Status Code
	#${body}=         Response Body
	#Should Be Equal As Numbers  ${status_code}  200	
	##Should Be Equal             ${body}         {"message":"user created"}
        #Should Be Equal              ${variable['Message']}         user created

	${error}=    Run Keyword and Expect Error  *   Login   username=${newuser}   password=${password}
	Should Contain  ${error}    responseCode = 400
	Should Contain  ${error}    {"message":"Account is locked, please contact MobiledgeX support"}

        Unlock User   username=${newuser}  

	${token}=   Login   username=${newuser}   password=${password}

        Delete User  username=${newuser}   token=${adminToken}
	#${status_code}=  Response Status Code
	#${body}=         Response Body
	#Should Be Equal As Numbers  ${status_code}  200	
	#Should Be Equal             ${body}         {"message":"user deleted"}

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
	Should Contain  ${error}    {"message":"admin password min crack time must be greater than password min crack time"}


# ECQ-2780
MC - Verify User Password strength can not be set higher than Admin Password strength
	[Documentation]
	...  change PasswordMinCrackTimeSec to 1 higher than the default admin pass strength using the admin token
	...  verify the user password strength fails to set
	...  QA Defaultes User 2592000, Admin 63072000}
	
	${level}=   Convert To Integer  63072001 
	${error}=   Run Keyword and Expect Error  *   Set User Pass Strength Config   user_pass=${level}
	Should Contain  ${error}    code=400
	Should Contain  ${error}    {"message":"admin password min crack time must be greater than password min crack time"}
	${config}=   Show Config    token=${adminToken}
	Should Be Equal As Numbers   ${config['PasswordMinCrackTimeSec']}   ${userdefaultlvl}


        
*** Keywords ***
Setup
	${adminToken}=  Login    username=qaadmin    password=${adminpass}
	${admindefaultlvl}=   Convert To Integer  63072000 
	${userdefaultlvl}=    Convert To Integer  2592000 

        Set Suite Variable   ${adminToken}
	Set Suite Variable   ${admindefaultlvl}
	Set Suite Variable   ${userdefaultlvl}
