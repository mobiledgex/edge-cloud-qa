*** Settings ***
Documentation     signup user

Library         MexConsole  %{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

${username}  mextester01
${password}  mextester01123
${email}     mextester01@gmail.com

*** Test Cases ***
WebUI - User shall be able to signup a new user
   [Documentation]
   ...  Signup a new user
   ...  verify email is received

   [Tags]  passing

   Open Signup
   Signup New User  username=${username}  password=${password}  email_address=${email}

   Verification Email Should Be Received

WebUI - User shall be able to signup/verify/login a new user
   [Documentation]
   ...  Signup a new user
   ...  Verify new user can login to console
 
   [Tags]  passing

   Open Signup
   Signup New User  username=${username}  password=${password}  email_address=${email}

   Verification Email Should Be Received

   Verify New User

   Sleep  10s

   Unlock User

   Login to Mex Console  username=${username}  password=${password}

*** Keywords ***
Setup
   Open Browser
   Run Keyword and Ignore Error  Delete User  ${username}

Teardown
   Close Browser
   Delete User  ${username}
