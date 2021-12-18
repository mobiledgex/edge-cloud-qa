*** Settings ***
Documentation   Create new App
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  MobiledgeX
${wait}  200

*** Test Cases ***
Web UI - User shall be able to update an existing Kubernetes App to skip healthcheck on one access port
    [Documentation]
    ...  Create a new Kubernetes App with two access ports 
    ...  UpdateApp to turf off healthcheck on one access port

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015,tcp:2016 

    MexConsole.Update App   skip_hc=On
    Sleep  5s

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['skip_hc_ports']}  tcp:2016
    END

    MexConsole.Delete App  click_previous_page=off  change_rows_per_page=True


Web UI - User shall be able to update an existing Docker App to skip healthcheck on one access port
    [Documentation]
    ...  Create a new Docker App with two access ports
    ...  UpdateApp to turf off healthcheck on one access port

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=docker  access_ports=tcp:2015,tcp:2016

    MexConsole.Update App   skip_hc=On
    Sleep  5s

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['skip_hc_ports']}  tcp:2016
    END

    MexConsole.Delete App  click_previous_page=off  change_rows_per_page=True


Web UI - User shall be able to update an existing VM App to skip healthcheck on one access port
    [Documentation]
    ...  Create a new VM App with two access ports
    ...  UpdateApp to turf off healthcheck on one access port

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=vm  access_ports=tcp:2015,tcp:2016  access_type=Load Balancer

    MexConsole.Update App   skip_hc=On
    Sleep  5s

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['skip_hc_ports']}  tcp:2016
    END

    MexConsole.Delete App  click_previous_page=off  change_rows_per_page=True

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${app_name}=  Get Default App Name
    Open Browser
    Login to Mex Console  browser=${browser}
    Open Compute
    Open Apps
    Set Suite Variable  ${token}
    Set Suite Variable  ${app_name}

Teardown
    Close Browser
