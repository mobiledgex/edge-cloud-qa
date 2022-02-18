*** Settings ***

Library         MexConsole  %{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${password}=   H31m8@W8maSfg

*** Test Cases ***

WebUI - User login gets temporarily disabled due to 3 failed login attempts
   [Documentation]
        ...  create a new user, verify and unlock it
        ...  login with correct username but wrong password
        ...  after 3 failed attempts, the user should be disabled temporarily
        ...  after the elapsed time, login should be successful

   ${epoch}=  Get Time  epoch
   ${username}=  Catenate  SEPARATOR=   user   ${epoch}
   ${email}=  Catenate  SEPARATOR=   user  +  ${epoch}  @gmail.com
   Create User  username=${username}   password=${password}   email_address=${email}  email_check=False
   Update Restricted User   username=${username}  email_verified=${True}   locked=${False}

   Run Keyword and Expect Error  Invalid username or password  Login to Mex Console  browser=${browser}  username=${username}  password=H31m8@W8maSfg123
   Sleep  5s

   Run Keyword and Expect Error  Invalid username or password  Login to Mex Console  browser=${browser}  username=${username}  password=H31m8@W8maSfg12
   Sleep  5s

   Run Keyword and Expect Error  Invalid username or password  Login to Mex Console  browser=${browser}  username=${username}  password=H31m8@W8maSfg1234
   Sleep  5s

   ${error}=   Run Keyword And Expect Error   *     Login to Mex Console  browser=${browser}  username=${username}  password=H31m8@W8maSfgpqr
   Should Match Regexp  ${error}    Login temporarily disabled due to 3 failed login attempts, please try again in \\d{2}s

   Sleep  60s
   Login to Mex Console  browser=${browser}  username=${username}  password=${password}


*** Keywords ***
Setup
   Open Browser
   Skip Verify Email  skip_verify_email=${False}

Teardown
   Cleanup Provisioning
   Close Browser
   Skip Verify Email  skip_verify_email=${True}
