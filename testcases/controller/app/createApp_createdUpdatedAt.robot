*** Settings ***
Documentation   Create App with timestamps

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         MexApp

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0

${region}=  US

*** Test Cases ***
# ECQ-2879
CreateApp - timestamps shall be created for CreateApp
   [Documentation]
   ...  - create app with various types 
   ...  - verify timestamps are correct

   [Template]  CreateApp and Verify Timestamps
   
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}

   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
# direct not supported
#   image_type=ImageTypeDocker  deployment=docker      access_type=direct  image_path=${docker_image}

   image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer  image_path=${docker_image}

   image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer  image_path=${qcow_centos_image}
#   image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}

*** Keywords ***
Setup
    Create Flavor  region=${region}
    ${current_date}=   Fetch Current Date

    Set Suite Variable  ${current_date}

CreateApp and Verify Timestamps
   [Arguments]  &{parms}

   ${app}=  Create App  region=${region}  &{parms}  auto_delete=${False}
   ${created_epoch}=  Convert to Epoch  ${app['data']['created_at']}
   #Should Be True  ${app['data']['created_at']['seconds']} > 0
   #Should Be True  ${app['data']['created_at']['nanos']} > 0
   Should Contain   ${app['data']['created_at']}  ${current_date}
   Should Be True  'updated_at' in ${app['data']}

   Sleep  1s

   ${app_update}=  Update App  region=${region}  access_ports=tcp:1 
   ${updated_epoch}=  Convert to Epoch   ${app_update['data']['updated_at']}
   #Should Be True  ${app_update['data']['created_at']['seconds']} > 0
   #Should Be True  ${app_update['data']['created_at']['nanos']} > 0
   Should Be True  '${app_update['data']['created_at']}' == '${app['data']['created_at']}'
   #Should Be True  ${app_update['data']['updated_at']['seconds']} > ${app['data']['created_at']['seconds']}
   #Should Be True  ${app_update['data']['updated_at']['nanos']} > 0
   Should Be True   ${updated_epoch} > ${created_epoch}

   Delete App  region=${region}
