*** Settings ***
Documentation   Create App with manifest

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1

${qcow_centos_image}  https://artifactory-qa.mobiledgex.net/artifactory/repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:ac10044d053221027c286316aa610ed5
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0
${manifest}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml 

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

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  deployment_manifest=xx  command=zz

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, both deploymentmanifest and command cannot be used together for VM based deployment"

CreateApp - error shall be received wih deployment=kubernetes and invalid manifest
    [Documentation]
    ...  create k8s app with invalid manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  deployment_manifest=xx

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, parse kubernetes deployment yaml failed, couldn't get version/kind; json parse error

CreateApp - error shall be received wih deployment=kubernetes and tcp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=tcp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port tcp:1 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"


CreateApp - error shall be received wih deployment=kubernetes and udp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=udp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=udp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port udp:1 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - error shall be received wih deployment=kubernetes and tcp/udp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=tcp:2,udp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2,udp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port tcp:2,udp:1 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - error shall be received wih deployment=kubernetes and tcp and udp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=tcp:2016,udp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2016,udp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port udp:1 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - error shall be received wih deployment=kubernetes and udp and tcp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=udp:2015,tcp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=udp:2015,tcp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port tcp:1 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - error shall be received wih deployment=kubernetes and udp range accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=udp:[range] but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=udp:2014-2018  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port udp:2014,udp:2016,udp:2017,udp:2018 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - error shall be received wih deployment=kubernetes and tcp range accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=tcp:[range] but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2014-2018  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port tcp:2014,tcp:2015,tcp:2017,tcp:2018 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - error shall be received wih deployment=kubernetes and tcp/udp range accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=udp:[range],tcp:[range] but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2014-2018,udp:2014-2018  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port tcp:2014,tcp:2015,tcp:2017,tcp:2018,udp:2014,udp:2016,udp:2017,udp:2018 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - error shall be received wih deployment=kubernetes and http accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=http:2015 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=http:2015  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port tcp:2015 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - error shall be received wih deployment=kubernetes and http range accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=http:[range] but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=http:2014-2018  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid deployment manifest, port tcp:2014,tcp:2015,tcp:2017,tcp:2018 defined in AccessPorts but missing from kubernetes manifest (note http is mapped to tcp)"

CreateApp - http shall map to tcp wih deployment=kubernetes and manifest
    [Documentation]
    ...  create k8s app with access_ports=http and manifest
    ...  verify app is created
    
    Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=http:2016  deployment_manifest=${manifest}

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor

