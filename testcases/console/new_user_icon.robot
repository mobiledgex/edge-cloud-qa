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
${timeout}           10 min
${tester_account_username}  mextester04
${tester_account_usernamenew}  New\nmextester04
${tester_account_password}  mextester04123
${email}     mextester04@gmail.com

*** Test Cases ***
New Icon Should Be Visible Next To New User
    [Documentation]
    ...  Sign Up New User
    ...  Verify New Icon Shows Next To Username In Accounts
    [Tags]  passing

    Open Signup
    Signup New User  username=${tester_account_username}  password=${tester_account_password}  email_address=${email}

    Verification Email Should Be Received

    Verify New User

    Sleep  10s

    Unlock User

    Login to Mex Console  username=${console_username}  password=${console_password}
    Open Compute

    Open Accounts Page

    Account Should Exist  account_name=${tester_account_usernamenew}
    

*** Keywords ***
Setup
   Open Browser
   Run Keyword and Ignore Error  Delete User  ${tester_account_username}

Teardown
   Close Browser
   Delete User  ${tester_account_username}
