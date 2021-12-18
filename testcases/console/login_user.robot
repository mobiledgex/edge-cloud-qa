*** Settings ***
Documentation     Login to console with nonmexadmin

Library         MexConsole  %{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mextester99
${console_password}  mextester99123
${console_email}     mextester99@gmail.com
${password}=   H31m8@W8maSfg

*** Test Cases ***
WebUI - User shall be able to login with non-mexadmin username
   [Documentation]
   ...  login with non-mexadmin username/password
   ...  verify login is successful

   [Tags]  passing

   Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}

WebUI - User shall be able to login with non-mexadmin email
   [Documentation]
   ...  login with non-mexadmin email/password
   ...  verify login is successful

   [Tags]  passing

   Login to Mex Console  browser=${browser}  username=${console_email}  password=${console_password}

WebUI - User shall not be able to login with non-verified account
   [Documentation]
   ...  login with non-verified account
   ...  verify error

   [Tags]  passing

   ${epoch}=  Get Time  epoch
   ${username}=  Catenate  SEPARATOR=   user   ${epoch}
   ${email}=  Catenate  SEPARATOR=   user  +  ${epoch}  @gmail.com
   Create User  username=${username}   password=${password}   email_address=${email}  email_check=False
   Unlock User
   Run Keyword and Expect Error  Email not verified yet  Login to Mex Console  username=${username}  password=${password}  browser=${browser}

WebUI - User shall not be able to login with locked account
   [Documentation]
   ...  login with locked account
   ...  verify error

   [Tags]  passing

   ${epoch}=  Get Time  epoch
   ${username}=  Catenate  SEPARATOR=   user   ${epoch}
   ${email}=  Catenate  SEPARATOR=   user  +  ${epoch}  @gmail.com
   Create User   username=${username}   password=${password}   email_address=${email}  email_check=False
   Run Keyword and Expect Error  Your account is locked, please contact support@mobiledgex.com to unlock it  Login to Mex Console  username=${username}  password=${password}  browser=${browser}

WebUI - User shall not be able to login with bad username and password
   [Documentation]
   ...  login with bad username and password
   ...  verify error

   [Tags]  passing

   Run Keyword and Expect Error  Invalid username or password  Login to Mex Console  browser=${browser}  username=wrong  password=wrong

WebUI - User shall not be able to login with username and bad password
   [Documentation]
   ...  login with good username and bad password
   ...  verify error

   [Tags]  passing

   Run Keyword and Expect Error  Invalid username or password  Login to Mex Console  browser=${browser}  username=${console_username}  password=wrong

WebUI - User shall not be able to login with email and bad password
   [Documentation]
   ...  login with good email and bad password
   ...  verify error

   [Tags]  passing

   Run Keyword and Expect Error  Invalid username or password  Login to Mex Console  browser=${browser}  username=${console_email}  password=wrong

WebUI - User shall not be able to login without username and password
   [Documentation]
   ...  login without username and password
   ...  verify error

   [Tags]  passing

   Run Keyword and Expect Error  Insert Username and Password  Login to Mex Console  browser=${browser}  username=${EMPTY}  password=${EMPTY}

WebUI - User shall not be able to login without username
   [Documentation]
   ...  login without username and good password
   ...  verify error

   [Tags]  passing

   Run Keyword and Expect Error  Insert Username  Login to Mex Console  browser=${browser}  username=${EMPTY}  password=${console_password}

WebUI - User shall not be able to login with username and no password
   [Documentation]
   ...  login with good username and no password
   ...  verify error

   [Tags]  passing

   ${epoch}=  Get Time  epoch
   ${username}=  Catenate  SEPARATOR=   user   ${epoch}
   ${email}=  Catenate  SEPARATOR=   user  +  ${epoch}  @gmail.com
   Create User  username=${username}   password=${password}   email_address=${email}  email_check=False
   Run Keyword and Expect Error  Insert Password  Login to Mex Console  browser=${browser}  username=${username}  password=${EMPTY}

*** Keywords ***
Setup
   Open Browser
   Skip Verify Email  skip_verify_email=${False}

Teardown
   Cleanup Provisioning
   Close Browser
   Skip Verify Email  skip_verify_email=${True}
