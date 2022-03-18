*** Settings ***
Documentation  MC User emails 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}  #mc_password=SFC6s59XjB4HsQM3@3@
Library  DateTime
	
Test Setup	 Setup
Test Teardown    Teardown

*** Variables ***
${username}          mextester06
${password}          ${mextester06_gmail_password}
	
*** Test Cases ***
# ECQ-4428
MC - User create with callbackurl should not have callbackurl in email
    [Documentation] 
    ...  - create a new user with callback url
    ...  - verify user email doesnt have the callback url

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${epoch}

    Skip Verify Email   skip_verify_email=False

    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester06_gmail_password}  callback_url=hack.com  email_check=True

    ${msg}=  Verify Email

    Should Not Contain  ${msg}  hack.com

# ECQ-4429
MC - User password reset with callbackurl should have callback url in email
    [Documentation]
    ...  - create a new user with callback url
    ...  - reset the password with callback url
    ...  - verify reset password email doesnt have the callback url

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${epoch}

    Skip Verify Email   skip_verify_email=${True}

    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester06_gmail_password}  callback_url=hack.com  email_check=True
    Unlock User  username=${username1}

    ${user_token}=  Login  username=${username1}   password=${mextester06_gmail_password}
    Verify Email Via MC    token=${user_token}

    Skip Verify Email   skip_verify_email=${False}

    Reset Password  email_address=${email1}  email_password=${mextester06_gmail_password}  email_check=True  callback_url=hack.com

    ${msg}=  Verify Password Reset Email  

    Should Not Contain  ${msg}  hack.com
	
*** Keywords ***
Setup
    ${epoch}=  Get Current Date  result_format=epoch
    Set Suite Variable  ${epoch}

Teardown
    Skip Verify Email   skip_verify_email=True
    Cleanup Provisioning
 
