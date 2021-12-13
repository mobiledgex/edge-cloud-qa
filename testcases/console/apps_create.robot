*** Settings ***
Documentation   Create new App
## Needs to be tested in stage
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
${flavorEU}  x1.medium
${flavorUS}  x1.medium
${wait}  200

*** Test Cases ***
Web UI - User shall be able to create a New Docker App for EU Region
    [Documentation]
    ...  Create a new EU Docker App
    ...  Verify Docker App shows in list

    #Sleep  5s

    Add New App  region=EU  developer_name=${developer_name}  deployment_type=docker  access_ports=tcp:2015 

    App Should Exist  change_rows_per_page=True
    sleep  5s

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist

Web UI - User shall be able to create a New Docker App for US Region
    [Documentation]
    ...  Create a new US Docker App
    ...  Verify Docker App shows in list

    #Sleep  5s

    Add New App  region=US  developer_name=${developer_name}  deployment_type=docker  access_ports=tcp:2015
    
    App Should Exist  change_rows_per_page=True

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist

Web UI - User shall be able to create a New Kubernetes App for EU Region
    [Documentation]
    ...  Create a new EU Kubernetes App
    ...  Verify Kubernetes App shows in list

    #Sleep  5s

    Add New App  region=EU  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015
    
    App Should Exist  change_rows_per_page=True

    MexConsole.Delete App  click_previous_page=off 

    App Should Not Exist

Web UI - User shall be able to create a New Kubernetes App for US Region
    [Documentation]
    ...  Create a new US Kubernetes App
    ...  Verify Kubernetes App shows in list

    Sleep  5s

    Add New App  region=US  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015
    
    App Should Exist  change_rows_per_page=True

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist

Web UI - User shall be able to create a New VM App for EU Region
    [Documentation]
    ...  Create a new EU VM App
    ...  Verify VM App shows in list

    Sleep  5s

    Add New App  region=EU  developer_name=${developer_name}  deployment_type=vm  access_ports=tcp:2015
    
    App Should Exist  change_rows_per_page=True

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist

Web UI - User shall be able to create a New VM App for US Region
    [Documentation]
    ...  Create a new US VM App
    ...  Verify VM App shows in list

    Sleep  5s

    Add New App  region=US  developer_name=${developer_name}  deployment_type=vm  access_ports=tcp:2015
    
    App Should Exist  change_rows_per_page=True

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Apps
Teardown
    Close Browser
