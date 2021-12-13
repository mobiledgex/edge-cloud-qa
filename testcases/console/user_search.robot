*** Settings ***
Documentation   Search for Mexadmin in Users page
Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           5 min

*** Test Cases ***
Web UI - Username search functionality should work
    [Documentation]
    ...  Log into console
    ...  Change search box filter to username
    ...  Search for 'mexadmin' and confirm number is 1

    Open Users
    Filter Users  choice=Organization
    Filter Users  choice=Username
    Refresh Page
    Search Users  username=${console_username}

    Sleep  2s
    @{user_table}=  Get Table Data
    ${table_count}=  Get Length  ${user_table}
    Should Be Equal As Numbers  ${table_count}  1

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
