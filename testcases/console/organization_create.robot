*** Settings ***
Documentation   Create new organization

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
         
Test Setup      Setup
Test Teardown   Teardown 

Test Timeout    40 minutes
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - user shall be able to create a developer organization
    [Documentation]
    ...  Create a new developer organization
    ...  Verify organization shows in list
    [Tags]  passing

    Open Organizations  

    #Get Table Data

    Add New Organization  organization_name=${orgname}  organization_type=Developer 

WebUI - user shall be able to create an operator organization
    [Documentation]
    ...  Create a new operator organization
    ...  Verify organization shows in list
    [Tags]  passing

    Open Organizations

    #Get Table Data

    Add New Organization  organization_name=${orgname}  organization_type=Operator

*** Keywords ***
Setup
    Open Browser	
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

    ${epoch_time}=  Get Time  epoch
    ${orgname}=     Catenate  SEPARATOR=  org  ${epoch_time}

    Set Suite Variable  ${orgname}

Teardown
    Close Browser
    Run Keyword and Ignore Error  Delete Org  orgname=${orgname}
