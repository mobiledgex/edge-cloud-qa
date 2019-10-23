*** Settings ***
Documentation   Create App with deployment=helm

Library         MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

#Test Setup      Setup
Test Teardown   Cleanup Provisioning

*** Variables ***

*** Test Cases ***
CreateApp - error shall be received with image_type=ImageTypeDocker deployment=helm
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=helm
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=helm  access_ports=tcp:1,udp:2,http:80  image_path=mypath

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "deployment is not valid for image type"

CreateApp - error shall be received with image_type=ImageTypeQcow deployment=helm 
    [Documentation]
    ...  create app with image_type=ImageTypeQcow deployment=helm
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQcow  deployment=helm  access_ports=tcp:1,udp:2,http:80  image_path=mypath

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "deployment is not valid for image type"

