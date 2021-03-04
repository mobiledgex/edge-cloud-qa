*** Settings ***
Documentation   CreateApp with skip_hc_port failures  

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-2

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${region}=  US

*** Test Cases ***
CreateApp - User shall not be able to CreateApp to include skip_hc_port for Docker based app with AccessTypeDirect
    [Documentation]
    ...  create a docker based app with AccessTypeDirect
    ...  verify that CreateApp to include skip_hc_port fails

    #EDGECLOUD-3567 - Controller should throw error if skiphcports is specified for Docker or VM based app instances with AccessTypeDirect
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    ${error_msg}=  Run Keyword And Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  access_type=Direct  skip_hc_ports=tcp:2016
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"SkipHcPorts not supported for type: ACCESS_TYPE_DIRECT"}')

CreateApp - User shall not be able to CreateApp to include skip_hc_port for vm based app with AccessTypeDirect
    [Documentation]
    ...  create a vm based app instance with AccessTypeDirect
    ...  verify that CreateApp to include skip_hc_port fails

    #EDGECLOUD-3567 - Controller should throw error if skiphcports is specified for Docker or VM based app instances with AccessTypeDirect
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    ${error_msg}=  Run Keyword And Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015   region=${region}  skip_hc_ports=tcp:2016

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"SkipHcPorts not supported for type: ACCESS_TYPE_DIRECT"}')

CreateApp - User shall not be able to CreateApp if skip_hc_port is not one of the access ports 
    [Documentation]
    ...  create a docker based app 
    ...  verify that CreateApp to include skip_hc_port fails

    #EDGECLOUD-3566 - Controller should throw error if port configured in skiphcports is not one of the access ports for the app
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    ${error_msg}=  Run Keyword And Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  skip_hc_ports=tcp:2017

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"SkipHcPort 2017 not found in accessPorts"}')

CreateApp - User shall not be able to CreateApp to include skip_hc_port when invalid protocol is specified
    [Documentation]
    ...  create a docker based app with AccessTypeDirect
    ...  verify that CreateApp to include skip_hc_port fails

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    ${error_msg}=  Run Keyword And Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  ip_access=AccessTypeLoadBalancer  skip_hc_ports=tc:2016
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot parse skipHcPorts: Unsupported protocol: tc"}')

CreateApp - User shall not be able to CreateApp to include skip_hc_port when invalid port number is specified
    [Documentation]
    ...  create a docker based app with AccessTypeDirect
    ...  verify that CreateApp to include skip_hc_port fails

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    ${error_msg}=  Run Keyword And Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  ip_access=AccessTypeLoadBalancer  skip_hc_ports=tcp:0
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot parse skipHcPorts: App ports out of range"}')

*** Keywords ***
Setup
    Create Flavor     region=${region}
  

