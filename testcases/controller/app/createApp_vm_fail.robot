*** Settings ***
Documentation   CreateApp for VM

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown   Cleanup Provisioning	

*** Variables ***
${qcow_centos_image}  qcowimage

*** Test Cases ***
App - VM deployment with command shall fail
    [Documentation]
    ...  create a VM app with command arg
    ...  verify proper error is received 


    ${error_msg}=  Run Keyword and Expect Error  *  Create App   deployment=vm  image_type=ImageTypeQCOW  image_path=${qcow_centos_image}  command=ls 

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid argument, command is not supported for VM based deployments"

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
