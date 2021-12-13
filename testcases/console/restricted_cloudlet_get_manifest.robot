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
WebUI - Cloudlet manifest is displayed to user while creating cloudlet with restricted access
    [Documentation]
    ...  Create a new EU cloudlet with restricted access
    ...  Cloudlet Manifest is displayed to user
    [Tags]  passing

    Open Cloudlets

    Add New Cloudlet  region=EU  physical_name=hawkins  platform_type=Openstack  operator=GDDT  cloudlet_name=${cloudlet_name}  infra_api_access=Restricted

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
