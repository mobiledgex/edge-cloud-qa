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
   ...  - create a user with 2FA enabled
   ...  - verify the totpsharedkey is captured

   ${epoch}=  Get Current Date  result_format=epoch
   ${username}=  Set Variable   username${epoch}
   ${password}=  Set Variable   H31m8@W8maSfg
   ${email}=     Set Variable   ${username}@gmail.com
   ${message}=   Set Variable   User created with two factor authentication enabled. Please use the following text code with the two factor authentication app on your phone to set it up

   ${userresp}=    Create User    username=${username}     password=${password}     email_address=${email}    enable_totp=${True}    auto_show=${False}
   Should Be Equal As Strings   ${userresp['Message']}    ${message}
   ${totpsharedkey}=  Set Variable   ${userresp['TOTPSharedKey']}
   Should Not Be Empty    ${totpsharedkey}

# ECQ-4266
MC - Login with a 2FA user
   [Documentation]
   ...  - create a user with 2FA enabled
   ...  - login with the created 2FA user
   ...  - verify the login is successful

   ${userotp}=  Get Totp  ${2fakey}
   ${userotp}=  Convert To String  ${userotp}	
   ${token}=   Login  username=${username}  password=${password}  totp=${userotp}
   Should Not Be Empty   ${token}

# ECQ-4267
MC - Update a non 2FA user to a 2FA user
   [Documentation]
   ...  - create a non 2FA user 
   ...  - update the user to a 2FA user
   ...  - verify the 2FA user can log in

   ${epoch}=       Get Current Date  result_format=epoch
   ${non2fauser}=  Set Variable      username${epoch}
   ${password}=    Set Variable      H31m8@W8maSfg
   ${email}=       Set Variable      ${non2fauser}@gmail.com

   ${newuserrsp}=  Create User    username=${non2fauser}     password=${password}     email_address=${email} 
   Update Restricted User   username=${non2fauser}  email_verified=${True}   locked=${False}   token=${admintoken}
   ${token}=   Login   username=${non2fauser}    password=${password}
   ${updatersp}=   Update Current User   enable_totp=${True}   token=${token}   use_defaults=False
   ${newkey}=    Set Variable   ${updatersp['TOTPSharedKey']}
   ${userotp}=  Get Totp   ${newkey}
   ${userotp}=   Convert To String   ${userotp}
   ${token}=   Login  username=${non2fauser}  password=${password}  totp=${userotp}
   Should Not Be Empty   ${token}

# ECQ-4268
MC - Update a 2FA user to a non 2FA user
   [Documentation]
   ...  - Create a 2FA user 
   ...  - Update the user to a non 2FA user
   ...  - verify the non 2FA user can login 

   ${epoch}=       Get Current Date  result_format=epoch
   ${new2fauser}=    Set Variable      username${epoch}
   ${password}=      Set Variable      H31m8@W8maSfg
   ${email}=         Set Variable      ${new2fauser}@gmail.com
   ${message}=       Set Variable      User created with two factor authentication enabled. Please use the following text code with the two factor authentication app on your phone to set it up
	
   ${userresp}=   Create User   username=${new2fauser}     password=${password}     email_address=${email}    enable_totp=${True}    auto_show=${False}
   Should Be Equal As Strings    ${userresp['Message']}    ${message}
   ${newkey}=   Set Variable  ${userresp['TOTPSharedKey']}
   Update Restricted User   username=${new2fauser}  email_verified=${True}   locked=${False}   token=${admintoken}
   ${userotp}=   Get Totp   ${newkey}
   ${userotp}=   Convert To String  ${userotp}
   ${token}=   Login   username=${new2fauser}    password=${password}   totp=${userotp}
   Should Not Be Empty   ${token}
	
   ${updatersp}=   Update Current User   enable_totp=${False}   token=${token}   use_defaults=False
   ${token}=   Login   username=${new2fauser}    password=${password}
   Should Not Be Empty   ${token}
	
# ECQ-4364
MC - Verify an expired otp will not allow a user login
   [Documentation]
   ...  - generate an otp and wait for it to expire
   ...  - try and login with the expired otp
   ...  - verify the error message 

   ${msg}=      Set Variable    Invalid or expired OTP. Please login again to receive another OTP
	
   ${userotp}=  Get Totp  ${2fakey}
   ${userotp}=  Convert To String  ${userotp}	
   Sleep   65s	
   ${resp}=   Run Keyword and Expect Error  *   Login  username=${username}  password=${password}  totp=${userotp}
   Should Contain   ${resp}   code=400
   Should Contain   ${resp}   ${msg}
   
# ECQ-4365
MC - Verify another users otp will not work for any other user
   [Documentation]
   ...  - create two 2fa users
   ...  - generate an otp for user 2 
   ...  - try to use the user 2 otp for user 1 login
   ...  - verify the error  

   ${msg}=      Set Variable    Invalid or expired OTP. Please login again to receive another OTP

   ${epoch}=  Get Current Date  result_format=epoch
   ${user2}=     Set Variable   user2${epoch}
   ${password}=  Set Variable   H31m8@W8maSfg
   ${email}=     Set Variable   ${user2}@gmail.com
   ${message}=   Set Variable   User created with two factor authentication enabled. Please use the following text code with the two factor authentication app on your phone to set it up
	
   ${createresp}=    Create User    username=${user2}     password=${password}     email_address=${email}    enable_totp=${True}	auto_show=${False}
   Should Be Equal As Strings   ${createresp['Message']}    ${message}
   ${user2key}=    Set Variable   ${createresp['TOTPSharedKey']}
   Update Restricted User   username=${user2}  email_verified=${True}   locked=${False}   token=${admintoken}

   ${user2otp}=  Get Totp  ${user2key}
   ${user2otp}=  Convert To String  ${user2otp}	
   ${resp}=   Run Keyword and Expect Error  *   Login  username=${username}  password=${password}  totp=${user2otp}  # username is user 1
   Should Contain   ${resp}   code=400
   Should Contain   ${resp}   ${msg}

   ${token}=   Login   username=${user2}    password=${password}   totp=${user2otp}
   Should Not Be Empty   ${token}


*** Keywords ***
Setup

   ${admintoken}=   Get Super Token
   
   ${epoch}=  Get Current Date  result_format=epoch
   ${username}=  Set Variable  username${epoch}
   ${password}=  Set Variable  H31m8@W8maSfg
   ${email}=  Set Variable  ${username}@gmail.com
   ${message}=   Set Variable   User created with two factor authentication enabled. Please use the following text code with the two factor authentication app on your phone to set it up
   ${createresp}=    Create User    username=${username}     password=${password}     email_address=${email}    enable_totp=${True}	auto_show=${False}
   Should Be Equal As Strings   ${createresp['Message']}    ${message}
   ${2fakey}=    Set Variable   ${createresp['TOTPSharedKey']}
   Update Restricted User   username=${username}  email_verified=${True}   locked=${False}   token=${admintoken}
				
   Set Suite Variable    ${admintoken}
   Set Suite Variable    ${username}
   Set Suite Variable    ${password} 
   Set Suite Variable    ${email}
   Set Suite Variable    ${2fakey}  


