*** Settings ***
Documentation   Create App with Configs failures

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0
${manifest}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml 

${region}=  US

*** Test Cases ***
CreateApp - User shall not be able to create a docker app with ConfigsKind=helmCustomizationYaml 
    [Documentation]
    ...  create docker app with ConfigsKind=helmCustomizationYaml 
    ...  verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=direct  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig	
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(docker)"}') 

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(docker)"}')

CreateApp - User shall not be able to create a k8s app with ConfigsKind=helmCustomizationYaml
    [Documentation]
    ...  create k8s app with ConfigsKind=helmCustomizationYaml 
    ...  verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=direct  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(kubernetes)"}')

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=direct  image_path=${docker_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(kubernetes)"}')

CreateApp - User shall not be able to create a vm app with ConfigsKind=helmCustomizationYaml
    [Documentation]
    ...  create vm app with ConfigsKind=helmCustomizationYaml 
    ...  verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(vm)"}')

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}  configs_kind=helmCustomizationYaml  configs_config=myconfig
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(vm)"}')

CreateApp - User shall not be able to create a vm app with ConfigsKind=envVarsYaml
    [Documentation]
    ...  create vm app with ConfigsKind=envVarsYaml
    ...  verify error is received

    # EDGECLOUD-3232 CreateApp with deployment=vm and configs=envVarsYaml should give error

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}  configs_kind=envVarsYaml  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(vm)"}')

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}  configs_kind=envVarsYaml  configs_config=myconfig
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Invalid Config Kind(helmCustomizationYaml) for deployment type(vm)"}')

CreateApp - User shall not be able to create a vm app with unknown ConfigsKind
    [Documentation]
    ...  create vm app with unknown ConfigsKind
    ...  verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}') 

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer  image_path=${qcow_centos_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

CreateApp - User shall not be able to create a docker app with unknown ConfigsKind
    [Documentation]
    ...  create docker app with unknown ConfigsKind
    ...  verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=direct  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

CreateApp - User shall not be able to create a k8s app with unknown ConfigsKind
    [Documentation]
    ...  create k8s app with unknown ConfigsKind
    ...  verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')

CreateApp - User shall not be able to create a helm app with unknown ConfigsKind
    [Documentation]
    ...  create helm app with unknown ConfigsKind 
    ...  verify error is received

    ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}  configs_kind=xx  configs_config=myconfig
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid Config Kind - xx"}')
 
