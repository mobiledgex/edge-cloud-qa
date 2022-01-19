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

        [Tags]  Email

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

*** Keywords ***
Setup
	${adminToken}=  Login    username=qaadmin    password=${adminpass}

        Set Suite Variable   ${adminToken}

