*** Settings ***
Documentation   Add users to developer roles as AdminManager
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
Web UI - Admin user shall be able to add a user in an DeveloperManager role
    [Documentation]
    ...  Create user to delete
    ...  Add user to organization as DeveloperManager and relog as admin
    ...  Confirm successfully updated and delete created user

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

    Open Organizations
    Sort Organization Type  3
    @{orgdata}=  Get Table Data
    Add New Organization User  username=${username}  organization=${orgdata[0][0]}  role=Manager
    # Adds mextester03 to the first Organization (after sorting odd # it is Dev)

    Open Users
    Filter Users  choice=Organization
    Search Users  organization=${orgdata[0][0]}

    @{userws2}=  Get Table Data
    # If the label in front of each role type changes then the variable has to too
    ${role}=      Set Variable   MDeveloperManager
    ${counter}=   Set Variable   ${0}

    :FOR    ${row}    IN     @{userws2}
    \  Log To Console   \n${row[0]}
    \  Exit For Loop If  '${row[0]}'=='${username}'
    \  ${counter}=  Evaluate  ${counter} + 1
    # Found mextester03 in users of organization mextester03 added to
    Should Be Equal  ${userws2}[${counter}][0]  ${username}
    Should Be Equal  ${userws2}[${counter}][2]  ${role}

    Delete User  username=${username}

Web UI - Admin user shall be able to add a user in an DeveloperContributor role
    [Documentation]
    ...  Create user to delete
    ...  Add user to organization as DeveloperContributor and relog as admin
    ...  Confirm successfully updated and delete created user

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

    Open Organizations
    @{orgdata}=  Get Table Data
    Add New Organization User  username=${username}  organization=${orgdata[0][0]}  role=Contributor
    # Adds mextester03 to the first Organization (after sorting odd # it is Dev)

    Open Users
    Filter Users  choice=Organization
    Search Users  organization=${orgdata[0][0]}

    @{userws2}=  Get Table Data
    ${role}=      Set Variable   CDeveloperContributor

    ${counter}  Set Variable   ${0}
    :FOR    ${row}    IN     @{userws2}
    \  Log To Console   \n${row[0]}
    \  Exit For Loop If  '${row[0]}'=='${username}'
    \  ${counter}=  Evaluate  ${counter} + 1
    # Found mextester03 in users of organization mextester03 added to
    Should Be Equal  ${userws2}[${counter}][0]  ${username}
    Should Be Equal  ${userws2}[${counter}][2]  ${role}

    Delete User  username=${username}

Web UI - Admin user shall be able to add a user in an DeveloperViewer role
    [Documentation]
    ...  Create user to delete
    ...  Add user to organization as DeveloperViewer and relog as admin
    ...  Confirm successfully updated and delete created user

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

    Open Organizations
    @{orgdata}=  Get Table Data
    Add New Organization User  username=${username}  organization=${orgdata[0][0]}  role=Viewer
    # Adds mextester03 to the first Organization (after sorting odd # it is Dev)

    Open Users
    Filter Users  choice=Organization
    Search Users  organization=${orgdata[0][0]}

    @{userws2}=  Get Table Data
    ${role}=      Set Variable   VDeveloperViewer

    ${counter}  Set Variable   ${0}
    :FOR    ${row}    IN     @{userws2}
    \  Log To Console   \n${row[0]}
    \  Exit For Loop If  '${row[0]}'=='${username}'
    \  ${counter}=  Evaluate  ${counter} + 1
    # Found mextester03 in users of organization mextester03 added to
    Should Be Equal  ${userws2}[${counter}][0]  ${username}
    Should Be Equal  ${userws2}[${counter}][2]  ${role}

    Delete User  username=${username}


*** Keywords ***
Setup
    Open Browser
    Run Keyword and Ignore Error  Delete User  username=${username}

Teardown
    Cleanup Provisioning
    Close Browser
