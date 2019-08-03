*** Settings ***
Documentation   Create App with manifest

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1

${qcow_image}  https://artifactory-qa.mobiledgex.net/artifactory/repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:ac10044d053221027c286316aa610ed5
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0

*** Test Cases ***
CreateApp - error shall be received with ImageTypeQCOW and no manifest md5
    [Documentation]
    ...  create QCOW app with no md5 in manifest 
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath	

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "md5 checksum of image is required. Please append checksum to imagepath: "<url>#md5:checksum"

CreateApp - error shall be received wih ImageTypeQCOW and manifest md5 too short
    [Documentation]
    ...  create QCOW app with md5 in manifest is too short
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath#md5:checksum

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "md5 checksum must be at least 32 characters"

CreateApp - error shall be received wih ImageTypeQCOW and manifest md5 invalid 
    [Documentation]
    ...  create QCOW app with md5 in manifest is invalid
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath#md5:12345678901234567890123456checksum

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid md5 checksum"

CreateApp - error shall be received wih ImageTypeQCOW and manifest and command 
    [Documentation]
    ...  create QCOW app with manifest and command
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_image}  deployment_manifest=xx  command=zz

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deploymentment manifest, both deploymentmanifest and command cannot be used together for VM based deployment"

CreateApp - error shall be received wih deployment=kubernetes and invalid manifest
    [Documentation]
    ...  create k8s app with invalid manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  deployment_manifest=xx

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deploymentment manifest, parse kubernetes deployment yaml failed, couldn't get version/kind; json parse error

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor

