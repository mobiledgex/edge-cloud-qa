*** Settings ***
Documentation   Create App with Configs 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0
${manifest}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml 

${region}=  US

# add fail tests
# add URI tests

*** Test Cases ***
CreateApp - User shall be able to create a docker direct app with Configs parm 
    [Documentation]
    ...  create QCOW app with no md5 in manifest 
    ...  verify error is received

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=direct  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=myconfig	

    Should Be Equal  ${app['data']['deployment']}            docker
    Should Be Equal As Numbers  ${app['data']['access_type']}           1 
    Should Be Equal  ${app['data']['configs'][0]['kind']}    envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig 

CreateApp - User shall be able to create a docker loadbalancer app with Configs parm
    [Documentation]
    ...  create QCOW app with no md5 in manifest
    ...  verify error is received

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=myconfig

    Should Be Equal  ${app['data']['deployment']}            docker
    Should Be Equal As Numbers  ${app['data']['access_type']}           2
    Should Be Equal  ${app['data']['configs'][0]['kind']}    envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig

CreateApp - User shall be able to create a docker app with manifest and Configs parm
    [Documentation]
    ...  create QCOW app with no md5 in manifest
    ...  verify error is received

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  deployment_manifest=${manifest}  configs_kind=envVarsYaml  configs_config=myconfig
    
    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig
    Should Contain   ${app['data']['deployment_manifest']}   apiVersion

CreateApp - User shall be able to create a k8s loadbalancer app with Configs parm
    [Documentation]
    ...  create QCOW app with no md5 in manifest
    ...  verify error is received

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=myconfig

    Should Be Equal  ${app['data']['deployment']}            kubernetes 
    Should Be Equal As Numbers  ${app['data']['access_type']}           2
    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig

CreateApp - User shall be able to create a k8s app with manifest and Configs parm
    [Documentation]
    ...  create QCOW app with no md5 in manifest
    ...  verify error is received

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2016  deployment_manifest=${manifest}  configs_kind=envVarsYaml  configs_config=myconfig

    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig
    Should Contain   ${app['data']['deployment_manifest']}   apiVersion

CreateApp - User shall be able to create a helm app with envVarsYaml Configs parm
    [Documentation]
    ...  create QCOW app with no md5 in manifest
    ...  verify error is received

    ${app}=  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  image_path=${helm_image}  access_ports=tcp:2016  configs_kind=envVarsYaml  configs_config=myconfig

    Should Be Equal  ${app['data']['deployment']}           helm 
    Should Be Equal As Numbers  ${app['data']['access_type']}           2
    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig

CreateApp - User shall be able to create a helm app with helmCustomizationYaml Configs parm
    [Documentation]
    ...  create QCOW app with no md5 in manifest
    ...  verify error is received

    ${app}=  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  image_path=${helm_image}  access_ports=tcp:2016  configs_kind=helmCustomizationYaml  configs_config=myconfig

    Should Be Equal  ${app['data']['deployment']}           helm
    Should Be Equal As Numbers  ${app['data']['access_type']}           2
    Should Be Equal  ${app['data']['configs'][0]['kind']}  helmCustomizationYaml 
    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig
 
*** Keywords ***
Setup
    Create Flavor  region=${region}

