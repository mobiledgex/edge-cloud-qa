*** Settings ***
Documentation   Create App with imagepath

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***

*** Test Cases ***
CreateApp - error shall be received with image_type=ImageTypeDocker deployment=kubernetes image_path=mypath
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=kubernetes image_path=mypath
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=mypath	

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "imagepath should be full registry URL: <domain-name>/<registry-path>"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes image_path of bad domain
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=kubernetes image_path=docker.registry.com/app
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker.registry.com/app

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid registry path"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes image_path and access denied to registry
    [Documentation]
    ...  create app image_type=ImageTypeDocker deployment=kubernetes image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded and no credentials for docker-qa
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Access denied to registry path"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes image_path and invalid tag
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=kubernetes image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid tag in registry path"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes image_path tag doesnt exist
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=kubernetes image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid registry tag: 99.9 does not exist"

CreateApp - error shall be received with image_type=ImageTypeDocker deployment=docker image_path=mypath
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=docker image_path=mypath
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=mypath	

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "imagepath should be full registry URL: <domain-name>/<registry-path>"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker image_path of bad domain
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=docker image_path=docker.registry.com/app
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=docker.registry.com/app

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid registry path"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker image_path and access denied to registry
    [Documentation]
    ...  create app image_type=ImageTypeDocker deployment=docker image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded and no credentials for docker-qa
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Access denied to registry path"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker image_path and invalid tag
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=kubernetes image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid tag in registry path"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker image_path tag doesnt exist
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=docker image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid registry tag: 99.9 does not exist"

CreateApp - error shall be received with image_type=ImageTypeQCOW deployment=vm image_path=mypath
    [Documentation]
    ...  create app with image_type=ImageTypeQCOW deployment=vm image_path=mypath
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath#md5:12345678901234567890123456789012	

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "imagepath should be full registry URL: <domain-name>/<registry-path>"

CreateApp - error shall be received wih image_type=ImageTypeQCOW deployment=vm image_path of bad domain
    [Documentation]
    ...  create app with image_type=ImageTypeQCOW deployment=vm image_path=docker.registry.com/app
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=docker.registry.com/app#md5:12345678901234567890123456789012

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid registry path"

CreateApp - error shall be received wih image_type=ImageTypeQCOW deployment=vm image_path and access denied to registry
    [Documentation]
    ...  create app image_type=ImageTypeQCOW deployment=vm image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded and no credentials for docker-qa
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded#md5:12345678901234567890123456789012

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Access denied to registry path"

CreateApp - error shall be received wih image_type=ImageTypeQCOW deployment=vm image_path and invalid tag
    [Documentation]
    ...  create app wih image_type=ImageTypeQCOW deployment=vm image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3#md5:12345678901234567890123456789012

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid tag in registry path"

CreateApp - error shall be received wih image_type=ImageTypeQCOW deployment=vm image_path tag doesnt exist
    [Documentation]
    ...  create app wih image_type=ImageTypeQCOW deployment=vm image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9#md5:12345678901234567890123456789012

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid registry tag: 99.9 does not exist"

*** Keywords ***
Setup
    Create Flavor

