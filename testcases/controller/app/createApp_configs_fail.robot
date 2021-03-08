*** Settings ***
Documentation   Create App with Configs failures

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0
${manifest}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml 

${configs_envvars_url}=  http://35.199.188.102/apps/automation_configs_envvars.yml
${configs_helmvars_url}=  http://35.199.188.102/apps/automation_configs_helmcustomization.yml

${region}=  US

*** Test Cases ***
# ECQ-2576
CreateApp - User shall not be able to create a docker app with ConfigsKind=helmCustomizationYaml 
    [Documentation]
    ...  - create docker app with ConfigsKind=helmCustomizationYaml 
    ...  - verify error is received

    # direct not supported
    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=direct  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig	
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(docker)"}') 

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(docker)"}')

# ECQ-2577
CreateApp - User shall not be able to create a k8s app with ConfigsKind=helmCustomizationYaml
    [Documentation]
    ...  - create k8s app with ConfigsKind=helmCustomizationYaml 
    ...  - verify error is received

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=direct  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(kubernetes)"}')

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(kubernetes)"}')

# ECQ-2578
CreateApp - User shall not be able to create a vm app with ConfigsKind=helmCustomizationYaml
    [Documentation]
    ...  - create vm app with ConfigsKind=helmCustomizationYaml 
    ...  - verify error is received

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(vm)"}')

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer  image_path=${qcow_centos_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(vm)"}')

# ECQ-2579
CreateApp - User shall not be able to create a vm app with ConfigsKind=envVarsYaml
    [Documentation]
    ...  - create vm app with ConfigsKind=envVarsYaml
    ...  - verify error is received

    # fixed - EDGECLOUD-3232 CreateApp with deployment=vm and configs=envVarsYaml should give error

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}  configs_kind=envVarsYaml  configs_config=myconfig
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(envVarsYaml) for deployment type(vm)"}')

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer  image_path=${qcow_centos_image}  configs_kind=envVarsYaml  configs_config=myconfig
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Invalid Config Kind(envVarsYaml) for deployment type(vm)"}')

# ECQ-2580
CreateApp - User shall not be able to create a vm app with unknown ConfigsKind
    [Documentation]
    ...  - create vm app with unknown ConfigsKind
    ...  - verify error is received

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}  configs_kind=xx  configs_config=myconfig
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}') 

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer  image_path=${qcow_centos_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

# ECQ-2581
CreateApp - User shall not be able to create a docker app with unknown ConfigsKind
    [Documentation]
    ...  - create docker app with unknown ConfigsKind
    ...  - verify error is received

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=direct  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

# ECQ-2582
CreateApp - User shall not be able to create a k8s app with unknown ConfigsKind
    [Documentation]
    ...  - create k8s app with unknown ConfigsKind
    ...  - verify error is received

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=direct  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

# ECQ-2583
CreateApp - User shall not be able to create a helm app with unknown ConfigsKind
    [Documentation]
    ...  - create helm app with unknown ConfigsKind 
    ...  - verify error is received

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=direct  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

# readd after docker is supported
#CreateApp - User shall not be able to create a docker app with unknown ConfigsKind
#    [Documentation]
#    ...  create docker app with unknown ConfigsKind
#    ...  verify error is received
#
#    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=direct  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
#    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')
#
#    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
#    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

# ECQ-2584
CreateApp - User shall not be able to create a k8s app with invalid yaml config
    [Documentation]
    ...  - create k8s app with unknown Configs value
    ...  - verify error is received

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=direct  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=myconfig
    #Should Contain  ${error}  ('code=400', 'error={"message":"Cannot unmarshal env vars: myconfig - yaml

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=myconfig
    Should Contain  ${error}  ('code=400', 'error={"message":"Cannot unmarshal env vars: myconfig - yaml

# ECQ-2585
CreateApp - User shall not be able to create a helm app with invalid yaml config
    [Documentation]
    ...  - create helm app with unknown Configs value
    ...  - verify error is received

    # EDGECLOUD-4216

    # no longer supported
    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=myconfig
    #Should Contain  ${error}  ('code=400', 'error={"message":"Cannot unmarshal env vars: myconfig - yaml

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Contain  ${error}  ('code=400', 'error={"message":"Cannot unmarshal env vars: myconfig - yaml

# ECQ-2587
CreateApp - User shall not be able to create a k8s app with invalid config url
    [Documentation]
    ...  - create k8s app with invalid Configs url
    ...  - verify error is received

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=direct  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=http://myconfig
    #Should Contain  ${error}  ('code=400', 'error={"message":"Cannot get manifest from http://myconfig

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=https://myconfig
    Should Contain  ${error}  ('code=400', 'error={"message":"Cannot get manifest from https://myconfig

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=direct  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=http://1.1.1.1
    #Should Contain  ${error}  ('code=400', 'error={"message":"Cannot unmarshal env vars

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=https://1.1.1.1
    Should Contain  ${error}  ('code=400', 'error={"message":"Cannot unmarshal env vars

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=direct  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=http://35.199.188.10
    #Should Contain  ${error}  i/o timeout

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=http://35.199.188.10
    Should Contain  ${error}  i/o timeout 

# ECQ-2588
CreateApp - User shall not be able to create a helm app with invalid config url
    [Documentation]
    ...  - create helm app with invalid Configs url
    ...  - verify error is received

    # EDGECLOUD-4216

    # no longer supported
    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=https://myconfig
    #Should Contain  ${error}  ('code=400', 'error={"message":"Cannot get manifest from http://myconfig

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=https://myconfig
    Should Contain  ${error}  ('code=400', 'error={"message":"Cannot get manifest from https://myconfig

    # no longer supported
    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=https://1.1.1.1
    #Should Contain  ${error}  ('code=400', 'error={"message":"Cannot unmarshal env vars

    # not supported since validation of helm chart prior to deployment is not possible
    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=https:/1.1.1.1
    #Should Contain  ${error}  ('code=400', 'error={"message":"Cannot unmarshal env vars

    # no longer supported
    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=https://myconfig
    #Should Contain  ${error}  i/o timeout

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=http://35.199.188.10
    Should Contain  ${error}  i/o timeout

# ECQ-3097
CreateApp - User shall not be able to create a helm app with ConfigsKind=envVarsYaml
    [Documentation]
    ...  - create helm app with ConfigsKind=envVarsYaml
    ...  - verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml  configs_config=https://myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(envVarsYaml) for deployment type(helm)"}')

# ECQ-3122
CreateApp - User shall not be able to create an app without ConfigsConfig
    [Documentation]
    ...  - create app without ConfigsConfig  
    ...  - verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=helmCustomizationYaml
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Empty config for config kind helmCustomizationYaml"}')

    #${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml
    #Should Be Equal  ${error}  ('code=400', 'error={"message":"Empty config for config kind helmCustomizationYaml"}')

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=envVarsYaml
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Empty config for config kind envVarsYaml"}')

