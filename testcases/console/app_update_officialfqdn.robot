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
${uri}  automation01.samsung.com
${wait}  200
${flavor_name}  automation_api_flavor

*** Test Cases ***
Web UI - User shall be able to update a Kubernetes App for EU Region with Official FQDN
    [Documentation]
    ...  Create a new EU Kubernetes App 
    ...  UpdateApp to add Official FQDN

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015 

    MexConsole.Update App  official_fqdn=${uri}
    Sleep  5s
    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['official_fqdn']}  ${uri}
    END

    MexConsole.Delete App  click_previous_page=off  change_rows_per_page=True

    App Should Not Exist


Web UI - User shall be able to update a Docker App for EU Region with Official FQDN
    [Documentation]
    ...  Create a new EU Docker App 
    ...  UpdateApp to add Official FQDN

    MexConsole.Update App  app_name=${app_name}    region=EU   developer_name=${developer_name}   deployment_type=docker   app_version=1.0  official_fqdn=${uri}
    Sleep  5s
    @{app_details}=    Show Apps  region=EU  app_name=${app_name}

    Should Be Equal  ${app_details[0]['data']['official_fqdn']}  ${uri}

    ${app_details_ui}=  Open App Details   app_name=${app_name}  region=EU  app_org=${developer_name}   deployment_type=docker   app_version=1.0
    Log to Console   ${app_details_ui}

    Should Contain   ${app_details_ui['Official FQDN']}   ${uri}

    Close Details
    MexMasterController.Delete App   region=EU   app_name=${app_name}  app_version=1.0  developer_org_name=${developer_name}  deployment=docker


*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${app_name}=  Get Default App Name
    Open Browser
    Login to Mex Console  browser=${browser}
    MexMasterController.Create App   region=EU  developer_org_name=${developer_name}   deployment=docker   access_ports=tcp:2015  default_flavor_name=${flavor_name}
    Open Compute
    Open Apps
    Set Suite Variable  ${token}
    Set Suite Variable  ${app_name}

Teardown
    Close Browser
