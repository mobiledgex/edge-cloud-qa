*** Settings ***
Documentation     Login to console

Library         MexConsole  %{AUTOMATION_CONSOLE_ADDRESS}

Test Teardown   Close Browser

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123

*** Test Cases ***
User shall be able to login with mexadmin
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Log to console   Pass

User shall be able to login with mexadmin and Enter key
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}  enter_key=${True}

User shall not be able to login with mexadmin and wrong password
    Run Keyword and Expect Error  Invalid username or password  Login to Mex Console  browser=${browser}  username=${console_username}  password=wrong
	 
User shall not be able to login without username and password
    Run Keyword and Expect Error  Insert Username and Password  Login to Mex Console  browser=${browser}  username=${EMPTY}  password=${EMPTY}

User shall not be able to login without username
    Run Keyword and Expect Error  Insert Username  Login to Mex Console  browser=${browser}  username=${EMPTY}  password=${console_password}

User shall not be able to login without password
    Run Keyword and Expect Error  Insert Password  Login to Mex Console  browser=${browser}  username=${console_username}  password=${EMPTY}
