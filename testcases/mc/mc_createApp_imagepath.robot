*** Settings ***
Documentation   Create App with imagepath

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***

*** Test Cases ***
# ECQ-2001
CreateApp - error shall be received with image_type=ImageTypeDocker deployment=kubernetes and org in imagepath not found
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=kubernetes and org in imagepath not found 
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  region=US  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker-qa.mobiledgex.net/mobiledx/images/server_ping_threaded:5.0

    Should Contain  ${error_msg}   code=400 
    Should Contain  ${error_msg}   error={"message":"Organization mobiledx from ImagePath not found"}'

*** Keywords ***
Setup
    Create Flavor  region=US

