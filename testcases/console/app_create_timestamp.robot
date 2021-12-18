*** Settings ***
Documentation   Create new App
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         DateTime
Library         Collections
Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  MobiledgeX

*** Test Cases ***
Web UI - User shall be able to view the timestamp when app is created 
    [Documentation]
    ...  Create a new App
    ...  Verify that timestamp displayed in app details matches the backend

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015 

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        ${time}=  Set Variable If  '${row['data']['key']['name']}' == '${app_name}'  ${row['data']['created_at']['seconds']}       
        Exit For Loop If  '${row['data']['key']['name']}' == '${app_name}'
    END

    Log to Console  ${time}
    ${timestamp}=  Convert Date  ${time}  exclude_millis=yes
    Log to Console  ${timestamp}

    ${details_us}=  Open App Details
    Log to Console  ${details_us}
    Should Be Equal   ${details_us['Created']}   ${timestamp}

    Close Apps Details   
    MexConsole.Delete App  change_rows_per_page=True

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${app_name}=  Get Default App Name
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Apps
    Set Suite Variable  ${token}
    Set Suite Variable  ${app_name}

Teardown
    Close Browser
