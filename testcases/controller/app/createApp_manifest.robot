*** Settings ***
Documentation   Create App with manifest

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

${qcow_centos_image}  https://artifactory-qa.mobiledgex.net/artifactory/repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:ac10044d053221027c286316aa610ed5
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0
${manifest}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml 
${manifest_artifactory_invalid}  https://artifactory-qa.mobiledgex.net/artifactory/epo-org1588686922/postgres_redis_compose.zip

*** Test Cases ***
#ECQ-1355
CreateApp - error shall be received with ImageTypeQCOW and no manifest md5
    [Documentation]
    ...  create QCOW app with no md5 in manifest 
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath	

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Md5 checksum of image is required. Please append checksum to imagepath: "<url>#md5:checksum"

#ECQ-1356
CreateApp - error shall be received with ImageTypeQCOW and manifest md5 too short
    [Documentation]
    ...  create QCOW app with md5 in manifest is too short
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath#md5:checksum

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Md5 checksum must be at least 32 characters"

#ECQ-1357
CreateApp - error shall be received with ImageTypeQCOW and manifest md5 invalid 
    [Documentation]
    ...  create QCOW app with md5 in manifest is invalid
    ...  verify error is received

    # EDGECLOUD-1571 - error message for invalid md5 checksum should be capitalized

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath#md5:12345678901234567890123456checksum

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid md5 checksum"

#ECQ-1452
CreateApp - error shall be received with ImageTypeQCOW and manifest and command 
    [Documentation]
    ...  create QCOW app with manifest and command
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  deployment_manifest=xx  command=zz

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid argument, command is not supported for VM based deployments"

#ECQ-2160
CreateApp - error shall be received with deployment=kubernetes and invalid manifest
    [Documentation]
    ...  create k8s app with invalid manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  deployment_manifest=xx

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, parse kubernetes deployment yaml failed, couldn't get version/kind; json parse error

#ECQ-1462
CreateApp - error shall be received with deployment=kubernetes and tcp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=tcp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port tcp:1 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1463
CreateApp - error shall be received with deployment=kubernetes and udp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=udp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=udp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port udp:1 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1464
CreateApp - error shall be received with deployment=kubernetes and tcp/udp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=tcp:2,udp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2,udp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port tcp:2,udp:1 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1465
CreateApp - error shall be received with deployment=kubernetes and tcp and udp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=tcp:2016,udp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2016,udp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port udp:1 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1466
CreateApp - error shall be received with deployment=kubernetes and udp and tcp accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=udp:2015,tcp:1 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=udp:2015,tcp:1  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port tcp:1 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1467
CreateApp - error shall be received with deployment=kubernetes and udp range accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=udp:[range] but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=udp:2014-2018  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port udp:2014,udp:2016,udp:2017,udp:2018 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1468
CreateApp - error shall be received with deployment=kubernetes and tcp range accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=tcp:[range] but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2014-2018  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port tcp:2014,tcp:2015,tcp:2017,tcp:2018 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1469
CreateApp - error shall be received with deployment=kubernetes and tcp/udp range accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=udp:[range],tcp:[range] but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2014-2018,udp:2014-2018  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port tcp:2014,tcp:2015,tcp:2017,tcp:2018,udp:2014,udp:2016,udp:2017,udp:2018 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1470
CreateApp - error shall be received with deployment=kubernetes and http accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=http:2015 but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=http:2015  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, port tcp:2015 defined in AccessPorts but missing from kubernetes manifest"

#ECQ-1471
CreateApp - error shall be received with deployment=kubernetes and http range accessport/manifest mismatch
    [Documentation]
    ...  create k8s app with access_ports=http:[range] but doenst exist in manifest
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=http:2014-2018  deployment_manifest=${manifest}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid deployment manifest, Port range not allowed for HTTP"

#ECQ-1472
CreateApp - http shall map to tcp with deployment=kubernetes and manifest
    [Documentation]
    ...  create k8s app with access_ports=http and manifest
    ...  verify app is created
    
    Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=http:2016  deployment_manifest=${manifest}

#ECQ-2159
CreateApp - error shall be received with deployment=kubernetes and invalid artifactory manifest
    [Documentation]
    ...  create k8s app with a manifest with an artifactory url that doenst exist  
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=http:2014-2018  deployment_manifest=${manifest_artifactory_invalid}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Cannot get manifest from ${manifest_artifactory_invalid}, Invalid URL: ${manifest_artifactory_invalid}, Not Found"

#ECQ-2161
CreateApp - error shall be received with deployment=docker and invalid artifactory docker compose 
    [Documentation]
    ...  create docker app with a compose with an artifactory url that doenst exist
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2014-2018  deployment_manifest=${manifest_artifactory_invalid}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Cannot get manifest from ${manifest_artifactory_invalid}, Invalid URL: ${manifest_artifactory_invalid}, Not Found"

# ECQ-2968
CreateApp - error shall be received with deployment=kubernetes and scale with cluster but not in manifest
    [Documentation]
    ...  - create docker app with deployment=kubernetes and scale with cluster on but the manifest does not support it
    ...  - verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2014-2018  deployment_manifest=${manifest}  scale_with_cluster=${True}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "DaemonSet required in manifest when ScaleWithCluster set"

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor

