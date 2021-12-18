*** Settings ***
Documentation   Create new cloudlet

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    20 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - Error is displayed to user after selecting Show Manifest
    [Documentation]
    ...  Create a new EU cloudlet with restricted access
    ...  Error message is displayed when show manifest is selected
    [Tags]  passing

    Open Cloudlets

    Add New Cloudlet  region=EU  physical_name=hamburg  platform_type=Openstack  operator=TDG  cloudlet_name=${cloudlet_name}  infra_api_access=Restricted

    Search Cloudlet
    Show Cloudlet Manifest  option=NO

    Search Cloudlet
    MexConsole.Delete Cloudlet

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${cloudlet_name}=  Get Default Cloudlet Name
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Set Suite Variable  ${token}
    Set Suite Variable  ${cloudlet_name}
