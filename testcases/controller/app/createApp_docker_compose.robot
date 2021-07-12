*** Settings ***
Documentation  CreateApp with docker compose 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${docker_compose_url}=  http://35.199.188.102/apps/server_ping_threaded_compose.yml
${developer_org_name}=  MobiledgeX
${region}=  EU

${test_timeout_crm}  15 min

*** Test Cases ***
# direct not supported
# ECQ-1994
#CreateApp - User shall be able to create an app with docker compose and access_type=direct
#    [Documentation]
#    ...  create app with docker compose access_type=direct
#    ...  verify app is created
#
#    ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0   access_type=direct
#
#    Should Be Equal As Numbers  ${app['data']['access_type']}          1  #AccessTypeDirect
#    Should Be Equal As Numbers  ${app['data']['image_type']}           1  #docker
#    Should Contain              ${app['data']['deployment_manifest']}  image

# ECQ-1995
CreateApp - User shall be able to create an app with docker compose and no access_type
    [Documentation]
    ...  create app with docker compose with no access_type
    ...  verify app is created

    ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0 

    Should Be Equal   ${app['data']['access_type']}          AccessTypeLoadBalancer
    Should Be Equal   ${app['data']['image_type']}           ImageTypeDocker
    Should Contain              ${app['data']['deployment_manifest']}  image

# ECQ-1996
# removed test since this supported now
#CreateApp - User shall not be able to create an app with docker compose and access_type=loadbalancer
#    [Documentation]
#    ...  create app with docker compose access_type=loadbalancer
#    ...  verify error is received 
#
#   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=mobiledgex  app_version=1.0   access_type=loadbalancer
#
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  "message":"ACCESS_TYPE_LOAD_BALANCER not supported for docker deployment type: docker-compose" 

# ECQ-1997
CreateApp - User shall be able to create an app with docker compose and access_type=default
    [Documentation]
    ...  create app with docker compose access_type=direct
    ...  verify app is created

    ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0   access_type=default

    Should Be Equal   ${app['data']['access_type']}          AccessTypeLoadBalancer            
    Should Be Equal   ${app['data']['image_type']}           ImageTypeDocker
    Should Contain              ${app['data']['deployment_manifest']}  image

*** Keywords ***
Setup
    Create Flavor  region=${region}
