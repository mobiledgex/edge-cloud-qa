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
${package}  automation01.samsung.com
${wait}  200

*** Test Cases ***
Web UI - User shall be able to update a Kubernetes App for EU Region with Android Package
    [Documentation]
    ...  Create a new EU Kubernetes App 
    ...  UpdateApp to add android package

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015

    MexConsole.Update App  android_package=${package}

    MexConsole.Delete App  click_previous_page=off  change_rows_per_page=True

    App Should Not Exist


Web UI - User shall be able to update a Docker App for EU Region with Android Package
    [Documentation]
    ...  Create a new EU Docker App 
    ...  UpdateApp to add android package

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=docker  access_ports=tcp:2015

    MexConsole.Update App  android_package=${package}

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
