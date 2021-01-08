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
    Should Contain  ${error_msg}   details = "Failed to validate docker registry image, path docker.io/mypath, Access denied to registry path"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes image_path of bad domain
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=kubernetes image_path=docker.registry.com/app
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker.registry.com/app

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    #Should Contain  ${error_msg}   details = "Invalid registry path"
    #Should Contain  ${error_msg}  details = "Get https://docker.registry.com/v2/app/tags/list: remote error: tls: internal error"
    Should Contain  ${error_msg}  details = "Failed to validate docker registry image, path docker.registry.com/app, Get "https://docker.registry.com/v2/app/tags/list": EOF" 

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes image_path and no latest
    [Documentation]
    ...  create app image_type=ImageTypeDocker deployment=kubernetes image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded and no credentials for docker-qa
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    #Should Contain  ${error_msg}   details = "Access denied to registry path"
    Should Contain  ${error_msg}   details = "Failed to validate docker registry image, path docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded, Invalid registry tag: latest does not exist" 

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes image_path and invalid tag
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=kubernetes image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Failed to validate docker registry image, path docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3, Invalid tag in registry path" 

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes image_path tag doesnt exist
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=kubernetes image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Failed to validate docker registry image, path docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9, Invalid registry tag: 99.9 does not exist" 

CreateApp - error shall be received with image_type=ImageTypeDocker deployment=docker image_path=mypath
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=docker image_path=mypath
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=mypath	

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Failed to validate docker registry image, path docker.io/mypath, Access denied to registry path"

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker image_path of bad domain
    [Documentation]
    ...  create app with image_type=ImageTypeDocker deployment=docker image_path=docker.registry.com/app
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=docker.registry.com/app

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    #Should Contain  ${error_msg}   details = "Invalid registry path"
    Should Contain  ${error_msg}  details = "Failed to validate docker registry image, path docker.registry.com/app, Get "https://docker.registry.com/v2/app/tags/list": EOF" 

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker image_path and no latest
    [Documentation]
    ...  create app image_type=ImageTypeDocker deployment=docker image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded and no credentials for docker-qa
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    #Should Contain  ${error_msg}   details = "Access denied to registry path"
    Should Contain  ${error_msg}   details = "Failed to validate docker registry image, path docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded, Invalid registry tag: latest does not exist" 


CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker image_path and invalid tag
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=kubernetes image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Failed to validate docker registry image, path docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3, Invalid tag in registry path" 

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker image_path tag doesnt exist
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=docker image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Failed to validate docker registry image, path docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9, Invalid registry tag: 99.9 does not exist" 

CreateApp - error shall be received with image_type=ImageTypeQCOW deployment=vm image_path=mypath
    [Documentation]
    ...  create app with image_type=ImageTypeQCOW deployment=vm image_path=mypath
    ...  verify error is received

    ${qcow_centos_image}=  Set Variable  https://artifactory-qa.mobiledgex.net/artifactory/repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:12345678901234567890123456789012
    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}	

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
#    Should Contain  ${error_msg}   details = "imagepath should be full registry URL: <domain-name>/<registry-path>"
    Should Contain  ${error_msg}  details = "Failed to validate VM registry image, path ${qcow_centos_image}, Invalid URL: ${qcow_centos_image}, Not Found" 

CreateApp - error shall be received wih image_type=ImageTypeQCOW deployment=vm image_path of bad domain
    [Documentation]
    ...  create app with image_type=ImageTypeQCOW deployment=vm image_path=docker.registry.com/app
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=docker.registry.com/app#md5:12345678901234567890123456789012

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    #Should Contain  ${error_msg}   details = "Invalid registry path"
    #Should Contain  ${error_msg}  details = "Failed to validate VM registry image, path docker.registry.com/app#md5:12345678901234567890123456789012, Get "docker.registry.com/app#md5:12345678901234567890123456789012": unsupported protocol scheme """ 
    Should Contain  ${error_msg}   details = "Missing filename from image path"

# ECQ-1370 - removed from automation since qa vault now has access to artifactory and artifactory-qa. But retested bug manually
CreateApp - error shall be received wih image_type=ImageTypeQCOW deployment=vm image_path and access denied to registry
    [Documentation]
    ...  create app image_type=ImageTypeQCOW deployment=vm image_path=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded and no credentials for docker-qa
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=https://artifactory.mobiledgex.net/artifactory/mobiledgex/erver_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    #Should Contain  ${error_msg}   details = "Access denied to registry path"
    #Should Contain  ${error_msg}  details = "unable to find bearer token"
    Should Contain  ${error_msg}  details = "Failed to validate VM registry image, path https://artifactory.mobiledgex.net/artifactory/mobiledgex/erver_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d, Invalid URL: https://artifactory.mobiledgex.net/artifactory/mobiledgex/erver_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d, Not Found

CreateApp - error shall be received wih image_type=ImageTypeQCOW deployment=vm image_path and image not found
    [Documentation]
    ...  create app wih image_type=ImageTypeQCOW deployment=vm image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:1:3
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/erver_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Failed to validate VM registry image, path https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/erver_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d, Invalid URL: https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/erver_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d, Not Found" 

CreateApp - error shall be received wih image_type=ImageTypeQCOW deployment=vm image_path and invalid url
    [Documentation]
    ...  create app wih image_type=ImageTypeQCOW deployment=vm image_path=docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:99.9
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=htt://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c300621167199
                                                                                                                   
    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    #Should Contain  ${error_msg}   details = "Invalid image path"
    Should Contain  ${error_msg}  details = "Failed to validate VM registry image, path htt://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c300621167199, Get "htt://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c300621167199": unsupported protocol scheme "htt""

*** Keywords ***
Setup
    Create Flavor

