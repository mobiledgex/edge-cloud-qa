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
Web UI - User shall be able to create a New Kubernetes App and skip healthcheck on access port
    [Documentation]
    ...  Create a new EU Kubernetes App with one access port and turf off healthcheck
    ...  Verify Kubernetes App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015  skip_hc=On

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['skip_hc_ports']}  tcp:2015
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist


Web UI - User shall be able to create a New Docker App and skip healthcheck on access port
    [Documentation]
    ...  Create a new EU Docker App one access port and turf off healthcheck
    ...  Verify Docker App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=docker  access_ports=tcp:2015  skip_hc=On

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['skip_hc_ports']}  tcp:2015
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist


Web UI - User shall be able to create a New VM App and skip healthcheck on access port
    [Documentation]
    ...  Create a new EU VM App with one access port and turf off healthcheck
    ...  Verify VM App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=vm  access_ports=tcp:2015  access_type=Load Balancer  skip_hc=On

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['skip_hc_ports']}  tcp:2015
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist

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
