*** Settings ***
Documentation   Create App with Configs 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0
${manifest}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml 

${config}=  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]
${configs_envvars_url}=  http://35.199.188.102/apps/automation_configs_envvars.yml
${configs_helmvars_url}=  http://35.199.188.102/apps/automation_configs_helmcustomization.yml

${region}=  US

*** Test Cases ***
# revisit after docker supported. EDGECLOUD-3163 Support envVarsYaml config for CreateApp on docker
#CreateApp - User shall be able to create a docker direct app with Configs parm 
#    [Documentation]
#    ...  create QCOW app with no md5 in manifest 
#    ...  verify error is received
#
#    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=direct  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=myconfig	
#
#    Should Be Equal  ${app['data']['deployment']}            docker
#    Should Be Equal As Numbers  ${app['data']['access_type']}           1 
#    Should Be Equal  ${app['data']['configs'][0]['kind']}    envVarsYaml
#    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig 

# revisit after docker supported. EDGECLOUD-3163 Support envVarsYaml config for CreateApp on docker
#CreateApp - User shall be able to create a docker loadbalancer app with Configs parm
#    [Documentation]
#    ...  create QCOW app with no md5 in manifest
#    ...  verify error is received
#
#    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=myconfig
#
#    Should Be Equal  ${app['data']['deployment']}            docker
#    Should Be Equal As Numbers  ${app['data']['access_type']}           2
#    Should Be Equal  ${app['data']['configs'][0]['kind']}    envVarsYaml
#    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig

# revisit after docker supported. EDGECLOUD-3163 Support envVarsYaml config for CreateApp on docker
#CreateApp - User shall be able to create a docker app with manifest and Configs parm
#    [Documentation]
#    ...  create QCOW app with no md5 in manifest
#    ...  verify error is received
#
#    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  deployment_manifest=${manifest}  configs_kind=envVarsYaml  configs_config=myconfig
#    
#    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
#    Should Be Equal  ${app['data']['configs'][0]['config']}  myconfig
#    Should Contain   ${app['data']['deployment_manifest']}   apiVersion

# ECQ-2569
CreateApp - User shall be able to create a k8s loadbalancer app with envVarsYaml Configs parm
    [Documentation]
    ...  - create k8s lb app with envvars config
    ...  - verify app is created

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=${config}

    Should Be Equal  ${app['data']['deployment']}            kubernetes 
    Should Be Equal  ${app['data']['access_type']}           LoadBalancer
    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  ${config}

# ECQ-2570
CreateApp - User shall be able to create a k8s app with manifest and Configs parm
    [Documentation]
    ...  - create k8s app with manifest and envvars config
    ...  - verify app is created

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2016  deployment_manifest=${manifest}  configs_kind=envVarsYaml  configs_config=${config}

    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  ${config}
    Should Contain   ${app['data']['deployment_manifest']}   apiVersion

# ECQ-2571
CreateApp - User shall be able to create a helm app with envVarsYaml Configs parm
    [Documentation]
    ...  - create helm app with envvars config
    ...  - verify app is created

    ${app}=  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  image_path=${helm_image}  access_ports=tcp:2016  configs_kind=envVarsYaml  configs_config=${config}

    Should Be Equal  ${app['data']['deployment']}           helm 
    Should Be Equal As Numbers  ${app['data']['access_type']}           2
    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  ${config}

#ECQ-2572
CreateApp - User shall be able to create a helm app with helmCustomizationYaml Configs parm
    [Documentation]
    ...  - create helm app with helmCustomizationYaml config
    ...  - verify app is created

    ${app}=  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  image_path=${helm_image}  access_ports=tcp:2016  configs_kind=helmCustomizationYaml  configs_config=${config}

    Should Be Equal  ${app['data']['deployment']}           helm
    Should Be Equal  ${app['data']['access_type']}           LoadBalancer
    Should Be Equal  ${app['data']['configs'][0]['kind']}  helmCustomizationYaml 
    Should Be Equal  ${app['data']['configs'][0]['config']}  ${config}

# ECQ-2573
CreateApp - User shall be able to create a k8s loadbalancer app with envVarsYaml Configs url 
    [Documentation]
    ...  - create k8s lb app with configs url
    ...  - verify app is created

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=${configs_envvars_url}

    Should Be Equal  ${app['data']['deployment']}            kubernetes
    Should Be Equal  ${app['data']['access_type']}           LoadBalancer
    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  ${configs_envvars_url}

# ECQ-2574
CreateApp - User shall be able to create a helm app with envVarsYaml Configs url 
    [Documentation]
    ...  - create helm app with envvars config url 
    ...  - verify error is received

    ${app}=  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  image_path=${helm_image}  access_ports=tcp:2016  configs_kind=envVarsYaml  configs_config=${configs_envvars_url}

    Should Be Equal  ${app['data']['deployment']}           helm
    Should Be Equal As Numbers  ${app['data']['access_type']}           2
    Should Be Equal  ${app['data']['configs'][0]['kind']}  envVarsYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  ${configs_envvars_url}

# ECQ-2575
CreateApp - User shall be able to create a helm app with helmCustomizationYaml Configs url 
    [Documentation]
    ...  - create helm app with helmCustomizationYaml Configs url
    ...  - verify app is created

    ${app}=  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  image_path=${helm_image}  access_ports=tcp:2016  configs_kind=helmCustomizationYaml  configs_config=${configs_helmvars_url}

    Should Be Equal  ${app['data']['deployment']}           helm
    Should Be Equal  ${app['data']['access_type']}           LoadBalancer
    Should Be Equal  ${app['data']['configs'][0]['kind']}  helmCustomizationYaml
    Should Be Equal  ${app['data']['configs'][0]['config']}  ${configs_helmvars_url}
 
*** Keywords ***
Setup
    Create Flavor  region=${region}

