*** Settings ***
Documentation   UpdateApp with skip_hc_port failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-2

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${region}=  US

*** Test Cases ***
UpdateApp - User shall not be able to UpdateApp to include skip_hc_port when app inst is running
    [Documentation]
    ...  create a docker based app instance
    ...  verify that UpdateApp to include skip_hc_port fails 

    ${app_name_default}=  Get Default App Name
    ${cluster_name_default}=  Get Default Cluster Name

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared
    Log To Console  Done Creating Cluster Instance

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name_default}

    ${error_msg}=  Run Keyword And Expect Error  *  Update App  region=${region}  skip_hc_ports=tcp:2016  

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot update Skip Hc Ports when AppInst exists"}')

UpdateApp - User shall not be able to UpdateApp to include skip_hc_port for Docker based app with AccessTypeDirect
    [Documentation]
    ...  create a docker based app with AccessTypeDirect
    ...  verify that UpdateApp to include skip_hc_port fails

    #EDGECLOUD-3567 - Controller should throw error if skiphcports is specified for Docker or VM based app instances with AccessTypeDirect
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  access_type=Direct
    ${error_msg}=  Run Keyword And Expect Error  *  Update App  region=${region}  skip_hc_ports=tcp:2016

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"SkipHcPorts not supported for type: ACCESS_TYPE_DIRECT"}')

UpdateApp - User shall not be able to UpdateApp to include skip_hc_port for vm based app with AccessTypeDirect
    [Documentation]
    ...  create a vm based app instance with AccessTypeDirect
    ...  verify that UpdateApp to include skip_hc_port fails

    #EDGECLOUD-3567 - Controller should throw error if skiphcports is specified for Docker or VM based app instances with AccessTypeDirect
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015   region=${region}
    ${error_msg}=  Run Keyword And Expect Error  *  Update App  region=${region}  skip_hc_ports=tcp:2016

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"SkipHcPorts not supported for type: ACCESS_TYPE_DIRECT"}')

UpdateApp - User shall not be able to UpdateApp if skip_hc_port is not one of the access ports 
    [Documentation]
    ...  create a docker based app 
    ...  verify that UpdateApp to include skip_hc_port fails

    #EDGECLOUD-3566 - Controller should throw error if port configured in skiphcports is not one of the access ports for the app
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016
    ${error_msg}=  Run Keyword And Expect Error  *  Update App  region=${region}  skip_hc_ports=tcp:2017

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"SkipHcPort 2017 not found in accessPorts"}')

UpdateApp - User shall not be able to UpdateApp to include skip_hc_port when invalid protocol is specified
    [Documentation]
    ...  create a docker based app
    ...  verify that UpdateApp to include skip_hc_port fails

    #EDGECLOUD-3585 - Controller show throw error if skiphcports has invalid protocol while updating app
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016
    ${error_msg}=  Run Keyword And Expect Error  *  Update App  region=${region}  skip_hc_ports=tc:2017

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot parse skipHcPorts: Unsupported protocol: tc"}')

UpdateApp - User shall not be able to UpdateApp to include skip_hc_port when invalid port number is specified
    [Documentation]
    ...  create a docker based app
    ...  verify that UpdateApp to include skip_hc_port fails

    #EDGECLOUD-3586 - Controller show throw error if skiphcports has invalid port number while updating app
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App
    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016
    ${error_msg}=  Run Keyword And Expect Error  *  Update App  region=${region}  skip_hc_ports=tcp:0

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot parse skipHcPorts: App ports out of range"}')

*** Keywords ***
Setup
    Create Flavor     region=${region}
  

