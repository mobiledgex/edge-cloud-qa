*** Settings ***
Documentation   MasterController New 2FA User Login

Library	   MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library    DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***

*** Test Cases ***
# ECQ-4265	
MC - Create a 2FA user
	[Documentation]
	...  create a user with 2FA enabled
	...  verify the totpsharedkey is captured

        ${epoch}=  Get Current Date  result_format=epoch
        ${username}=  Set Variable  username${epoch}
        ${password}=  Set Variable  H31m8@W8maSfg
        ${email}=  Set Variable  ${username}@gmail.com
	${message}=   Set Variable   User created with two factor authentication enabled. Please use the following text code with the two factor authentication app on your phone to set it up

	${userresp}=    Create User    username=${username}     password=${password}     email_address=${email}    enable_totp=${True}    auto_show=${False}
	Should Be Equal As Strings   ${userresp['Message']}    ${message}
        ${totpsharedkey}=  Set Variable   ${userresp['TOTPSharedKey']}
	Should Not Be Empty    ${totpsharedkey}

# ECQ-4266
MC - Login with a 2FA user
        [Documentation]
	...  create a user with 2FA enabled
	...  login with the created 2FA user
	...  verify the login is successful


	Update Restricted User   username=${username}  email_verified=${True}   locked=${False}
	${userotp}=  Get Totp  ${2fakey}
	${userotp}=  Convert To String  ${userotp}
        ${token}=   Login  username=${username}  password=${password}  totp=${userotp}
	Should Not Be Empty   ${token}

# ECQ-4267
MC - Update a non 2FA user to a 2FA user
	[Documentation]
	...  create a non 2FA user 
	...  update the user to a 2FA user
	...  verify the 2FA user can log in

        ${epoch}=  Get Current Date  result_format=epoch
        ${username}=  Set Variable  username${epoch}
        ${password}=  Set Variable  H31m8@W8maSfg
        ${email}=  Set Variable  ${username}@gmail.com

        ${newuserrsp}=  Create User    username=${username}     password=${password}     email_address=${email} 
        Update Restricted User   username=${username}  email_verified=${True}   locked=${False}
	${token}=   Login   username=${username}    password=${password}
        ${updatersp}=   Update Current User   enable_totp=${True}   token=${token}   use_defaults=False
        ${newkey}=    Set Variable   ${updatersp['TOTPSharedKey']}
	${userotp}=  Get Totp   ${newkey}
	${userotp}=   Convert To String   ${userotp}
        ${token}=   Login  username=${username}  password=${password}  totp=${userotp}
	Should Not Be Empty   ${token}

# ECQ-4268
MC - Update a 2FA user to a non 2FA user
	[Documentation]
	...  Create a non 2FA user 
	...  Update the user to a 2FA user
	...  verify the non 2FA user can login 

        ${epoch}=  Get Current Date  result_format=epoch
        ${username}=  Set Variable  username${epoch}
        ${password}=  Set Variable  H31m8@W8maSfg
        ${email}=  Set Variable  ${username}@gmail.com
	${message}=   Set Variable   User created with two factor authentication enabled. Please use the following text code with the two factor authentication app on your phone to set it up
        ${userresp}=    Create User    username=${username}     password=${password}     email_address=${email}    enable_totp=${True}    auto_show=${False}
	Should Be Equal As Strings   ${userresp['Message']}    ${message}
        ${newkey}=   Set Variable   ${userresp['TOTPSharedKey']}
	Update Restricted User   username=${username}  email_verified=${True}   locked=${False}
	${userotp}=  Get Totp  ${newkey}
	${userotp}=  Convert To String  ${userotp}
	${token}=   Login   username=${username}    password=${password}   totp=${userotp}
	Should Not Be Empty   ${token}
	${updatersp}=   Update Current User   enable_totp=${False}   token=${token}   use_defaults=False
	${token}=   Login   username=${username}    password=${password}
	Should Not Be Empty   ${token}
	

*** Keywords ***
Setup

   Login   username=qaadmin   password=mexadminfastedgecloudinfra
   
   ${epoch}=  Get Current Date  result_format=epoch
   ${username}=  Set Variable  username${epoch}
   ${password}=  Set Variable  H31m8@W8maSfg
   ${email}=  Set Variable  ${username}@gmail.com
   ${message}=   Set Variable   User created with two factor authentication enabled. Please use the following text code with the two factor authentication app on your phone to set it up
   ${createresp}=    Create User    username=${username}     password=${password}     email_address=${email}    enable_totp=${True}	auto_show=${False}
   Should Be Equal As Strings   ${createresp['Message']}    ${message}
   ${2fakey}=    Set Variable   ${createresp['TOTPSharedKey']}
			
   Set Suite Variable    ${username}
   Set Suite Variable    ${password} 
   Set Suite Variable    ${email}
   Set Suite Variable    ${2fakey}  

