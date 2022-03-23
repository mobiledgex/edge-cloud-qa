*** Settings ***
Documentation   Update App
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  MobiledgeX
${package}  automation01.platos.com
${wait}  200

*** Test Cases ***
Web UI - User shall be able to update a Kubernetes App for EU Region with Android Package
    [Documentation]
    ...  Create a new EU Kubernetes App 
    ...  UpdateApp to add android package

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015

    MexConsole.Update App  android_package=${package}

    ${details}=  Open App Details
    Log to Console  ${details}
    Should Be Equal   ${details['Android Package Name']}   ${package}

    Close Details

    MexConsole.Delete App  click_previous_page=off  change_rows_per_page=True

    App Should Not Exist


Web UI - User shall be able to update a Docker App for EU Region with Android Package and QOS Profile
    [Documentation]
    ...  Create a new EU Docker App 
    ...  UpdateApp to add android package
    ...  UpdateApp to add QOS values
    ...  Verify App details

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=docker  access_ports=tcp:2015

    ${qos_nw}=    Set Variable  Throughput Down S
    &{qos_dict}=  Create Dictionary  hour=${1}  min=${30}  sec=${15}
    @{qos_list}=  Create List  ${qos_dict}

    MexConsole.Update App  android_package=${package}  qos_nw_prioritization=${qos_nw}   qos_session_duration=${qos_list}

    ${ui_details}=    Open App Details
    Log to Console    ${ui_details}
    Should Be Equal   ${ui_details['Android Package Name']}   ${package}
    Should Be Equal   ${ui_details['QOS Network Prioritization']}   ${qos_nw}
    Should Be Equal   ${ui_details['QOS Session Duration']}   ${qos_dict.hour}h ${qos_dict.min}m ${qos_dict.sec}s

    Close Details

    MexConsole.Delete App  click_previous_page=off  change_rows_per_page=True

    App Should Not Exist

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
    Run Keyword and Ignore Error  MexMasterController.Delete App  region=EU  app_name=${app_name}  developer_org_name=${developer_name}
