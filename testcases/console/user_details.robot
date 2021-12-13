*** Settings ***
Documentation   Click and Verify User Data

Library         Collections
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

*** Test Cases ***
Web UI - User details should be possible to view
    [Documentation]
    ...  Sign in as mexadmin
    ...  Load Users page
    ...  View all users and confirm data visible

    Sort User Name  1
    @{rowsUsers}=  Show Role Assignment  sort_field=username
    @{rowsSecondary}=  Get Table Data

    &{tabledict}=  Create Dictionary
    :FOR    ${row}    IN     @{rowsSecondary}
    \  Set To Dictionary  ${tabledict}  ${row}[0]  ${row}[2]
    &{userdict}=  Create Dictionary
    :FOR    ${row}    IN     @{rowsUsers}
    \  Set To Dictionary  ${userdict}  ${row}[username]  ${row}[org]

    @{newList}=  Convert To List  ${tabledict}
    @{newList2}=  Convert To List  ${userdict}
    ${ForLoop}=  Get Length  ${newList}
    ${CheckLoop}=  Get Length  ${newList2}
    Should Be Equal  ${ForLoop}  ${CheckLoop}

    ${count}=  Evaluate  ${ForLoop}-1
    ${username}=     Set Variable  ${newList}[${count}]
    ${role}=    Evaluate    """${tabledict}[${username}]"""[1:]

    Log To Console  \nViewing details of: ${username}
    &{userDetails}=  View User Details  username=${username}

    Should Be Equal  ${userDetails}[Organization]  ${userdict}[${username}]
    Should Be Equal  ${userDetails}[Role Type]     ${role}

    # checking all usernames
    Sort List  ${newList2}
    Sort List  ${newList}
    :FOR    ${i}    IN RANGE    0     ${ForLoop}
    \  Should Be Equal    ${newList}[${i}]  ${newList2}[${i}]
    Close User Details


*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Open Compute
    Open Users

Teardown
    Close Browser
