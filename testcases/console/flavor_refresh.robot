*** Settings ***
Documentation   Refresh all flavors

Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - user shall be refresh all Flavors
    [Documentation]
    ...  Load flavor page
    ...  Create flavor on MexMasterController
    ...  Refresh page and ensure flavor exists
    [Tags]  passing

    ${epoch_time}=   Get Time  epoch
    ${flavor_name}=  Catenate  SEPARATOR=  flavor  ${epoch_time}

    #Flavor Should Not Exist  region=EU  flavor_name=${flavor_name}  ram=4  vcpus=1  disk=1

    MexMasterController.Create Flavor  region=EU  flavor_name=${flavor_name}  ram=4  vcpus=1  disk=1
    #@{ws}=  Get Table Data

    Refresh Page
    Flavor Should Exist  region=EU  flavor_name=${flavor_name}  ram=4  vcpus=1  disk=1  change_rows_per_page=True  number_of_pages=${num_pages}
    #@{ws2}=  Get Table Data

    #Should Not Be Equal  ${ws}  ${ws2}

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Flavors
    Sleep  2
    ${num_pages}=  Find Number Of Pages
    Set Suite Variable  ${num_pages}

Teardown
    Cleanup Provisioning
    Close Browser
