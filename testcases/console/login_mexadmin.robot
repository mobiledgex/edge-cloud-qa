*** Settings ***
Documentation     Login to console

Library         MexConsole  %{AUTOMATION_CONSOLE_ADDRESS}

Test Setup      Open Browser
Test Teardown   Close Browser

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${console_username_mexadmin}  mexadmin
${console_password_mexadmin}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - User shall be able to login with mexadmin
   [Documentation]
   ...  login to web console with mexadmin username/password
   ...  verify login is succesfull

   [Tags]  passing

   Login to Mex Console  browser=${browser}  username=${console_username_mexadmin}  password=${console_password_mexadmin}

WebUI - User shall be able to login with mexadmin and Enter key
   [Documentation]
   ...  login to web console with mexadmin username/password and hit enter key instead of clicking login button
   ...  verify login is succesfull

   [Tags]  passing

   Login to Mex Console  browser=${browser}  username=${console_username_mexadmin}  password=${console_password_mexadmin}  enter_key=${True}

WebUI - User shall not be able to login with mexadmin and wrong password
   [Documentation]
   ...  login to web console with mexadmin username and wrong password
   ...  verify error

   [Tags]  passing

   Run Keyword and Expect Error  Invalid username or password  Login to Mex Console  browser=${browser}  username=${console_username_mexadmin}  password=wrong
	 
WebUI - User shall not be able to login with mexadmin and no password
   [Documentation]
   ...  login to web console with mexadmin username and no password
   ...  verify error

   [Tags]  passing

   Run Keyword and Expect Error  Insert Password  Login to Mex Console  browser=${browser}  username=${console_username_mexadmin}  password=${EMPTY}
