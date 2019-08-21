*** Settings ***
Documentation   Create App with deployment=docker

Library         MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

#Test Setup      Setup
Test Teardown   Cleanup Provisioning

*** Variables ***

*** Test Cases ***
CreateApp - error shall be received with image_type=ImageTypeDocker deployment=docker and access_ports=http
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=docker and access_ports=http
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  access_ports=http:80  image_path=mypath

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Deployment Type and HTTP access ports are incompatible" 

CreateApp - error shall be received with image_type=ImageTypeDocker deployment=docker and access_ports=tcp,udp,http
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=docker and access_ports=tcp,udp,http
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  access_ports=tcp:1,udp:2,http:80  image_path=mypath

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Deployment Type and HTTP access ports are incompatible"

