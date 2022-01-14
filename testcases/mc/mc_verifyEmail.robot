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

        [Tags]  Email

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

*** Keywords ***
Setup
	${adminToken}=  Login    username=qaadmin    password=${adminpass}

        Set Suite Variable   ${adminToken}


