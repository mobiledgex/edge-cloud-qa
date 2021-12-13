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
Web UI - User shall be able to create a New Kubernetes App for EU Region with tls enabled
    [Documentation]
    ...  Create a new EU Kubernetes App with an access port and enable tls
    ...  Verify Kubernetes App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015:tls

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['access_ports']}  tcp:2015:tls
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist


Web UI - User shall be able to create a New Docker App for EU Region with tls enabled
    [Documentation]
    ...  Create a new EU Docker App with one access port and enable tls
    ...  Verify Docker App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=docker  access_ports=tcp:2015:tls

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['access_ports']}  tcp:2015:tls
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist


Web UI - User shall be able to create a New VM App for EU Region with tls enabled
    [Documentation]
    ...  Create a new EU VM App with one access port and enable tls
    ...  Verify VM App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=vm  access_ports=tcp:2015:tls  access_type=Load Balancer

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['access_ports']}  tcp:2015:tls
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist


Web UI - User shall be able to create a New Kubernetes App with 2 access ports and tls enabled on one port
    [Documentation]
    ...  Create a new EU Kubernetes App with an access port and enable tls
    ...  Verify Kubernetes App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015:tls,tcp:2016

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['access_ports']}  tcp:2016,tcp:2015:tls
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
