*** Settings ***
Documentation   Delete user as admin
Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min

${username}          mextester03
${password}          thequickbrownfoxjumpedoverthelazydog9$
${email}             mextester03@gmail.com

*** Test Cases ***
Web UI - Admin user shall be able to delete a user
    [Documentation]
    ...  Create user to delete
    ...  Add user to organization and relog as admin
    ...  Delete created user and confirm successfully updated

    Open Signup
    Signup New User  username=${username}  password=${password}  email_address=${email}
    # need to sign in the gmail for that

    Verification Email Should Be Received

    Verify New User
    sleep  5s
    Unlock User     username=${username}
    Close Browser

    Open Browser
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Open Compute
    Open Accounts
    sleep  5s

    # HAVE TO INPUT EMAIL BC THIS ANNOYING NEW BUTTON HAS A \n NEW LINE CHAR
    Account Should Exist  email=${email}
    # Account Should Exist  account_name=${username}
    Open Users
    @{userws}=  Get Table Data
    ${usercountpre}=  Get Length  ${userws}

    Open Organizations
    @{orgdata}=  Get Table Data
    Add New Organization User  username=${username}  organization=${orgdata[0][0]}  role=Viewer
    # Adds mextester03 to the first Organization (needs an Organization to exist)

    Open Users
    @{userws2}=  Get Table Data
    ${usercountpost}=  Get Length  ${userws2}

    # Userpre < Userpost
    Should Not Be Equal  ${usercountpre}  ${usercountpost}
    Delete User  username=${username}
    Sleep  3s

    Refresh Page
    # Still on Users Page
    @{userws3}=  Get Table Data
    ${usercountdeleted}=  Get Length  ${userws3}

    # Userpre = Usernowdeleted
    Should Be Equal  ${usercountpre}  ${usercountdeleted}
    #Delete Account  email=${email}  tempName=${username}

*** Keywords ***
Setup
    Open Browser
    Run Keyword and Ignore Error  Delete User  username=${username}

Teardown
    Cleanup Provisioning
    Close Browser
