*** Settings ***
Documentation   CreateApp with accesstype failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-2

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

${region}=  US

*** Test Cases ***
# ECQ-2030
App - User shall not be able to create a k8s App with accesstype=direct
    [Documentation]
    ...  create a k8s app with accesstype=direct
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=direct

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Access Type Direct no longer supported"}')

# ECQ-2031
App - User shall not be able to create a helm App with accesstype=direct
    [Documentation]
    ...  create a helm app with accesstype=direct
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create App  region=${region}  image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=direct

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Access Type Direct no longer supported"}')

# ECQ-3215
App - User shall not be able to create a docker App with accesstype=direct
    [Documentation]
    ...  - create a docker app with accesstype=direct
    ...  - verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=direct

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Access Type Direct no longer supported"}')

# ECQ-3216
App - User shall not be able to create a vm App with accesstype=direct
    [Documentation]
    ...  - create a vm app with accesstype=direct
    ...  - verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create App  region=${region}  image_type=ImageTypeQcow  deployment=vm  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=direct

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Access Type Direct no longer supported"}')

*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${flavor_name_default}=  Get Default Flavor Name
    Set Suite Variable  ${flavor_name_default}

