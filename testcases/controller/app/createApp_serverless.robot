*** Settings ***
Documentation  CreateApp with multi tenancy

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${docker_compose_url}=  http://35.199.188.102/apps/server_ping_threaded_compose.yml
${developer_org_name}=  MobiledgeX
${region}=  EU

${ram}=  2000
${vcpus}=  5
${disk}=  12

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-3492
CreateApp - serverless apps shall create with serverless config defaults
   [Documentation]
   ...  - create app with serverless=true and no config
   ...  - verify app is created with defaults from flavor

   [Tags]  Serverless

   ${app}=   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}
   Should Be Equal  ${app['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app['data']['serverless_config']['ram']}           ${ram}
   Should Be Equal As Numbers  ${app['data']['serverless_config']['vcpus']}         ${vcpus}
   Should Be Equal As Numbers  ${app['data']['serverless_config']['min_replicas']}  1

   ${app_name}=  Get Default App Name

   ${app2}=   Create App  region=${region}  app_name=${app_name}2  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_ram=2
   Should Be Equal  ${app2['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app2['data']['serverless_config']['ram']}           2
   Should Be Equal As Numbers  ${app2['data']['serverless_config']['vcpus']}         ${vcpus}
   Should Be Equal As Numbers  ${app2['data']['serverless_config']['min_replicas']}  1

   ${app3}=   Create App  region=${region}  app_name=${app_name}3  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_vcpus=39
   Should Be Equal  ${app3['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app3['data']['serverless_config']['ram']}           ${ram}
   Should Be Equal As Numbers  ${app3['data']['serverless_config']['vcpus']}         39
   Should Be Equal As Numbers  ${app3['data']['serverless_config']['min_replicas']}  1

   ${app4}=   Create App  region=${region}  app_name=${app_name}4  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_min_replicas=33
   Should Be Equal  ${app4['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app4['data']['serverless_config']['ram']}           ${ram}
   Should Be Equal As Numbers  ${app4['data']['serverless_config']['vcpus']}         ${vcpus}
   Should Be Equal As Numbers  ${app4['data']['serverless_config']['min_replicas']}  33

# ECQ-3493
CreateApp - serverless apps shall create with serverless config values
   [Documentation]
   ...  - create app with serverless config values
   ...  - verify app is created with config values

   [Tags]  Serverless

   ${app}=   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_ram=22  serverless_config_vcpus=0.39  serverless_config_min_replicas=33
   Should Be Equal  ${app['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app['data']['serverless_config']['ram']}           22
   Should Be Equal As Numbers  ${app['data']['serverless_config']['vcpus']}         0.39
   Should Be Equal As Numbers  ${app['data']['serverless_config']['min_replicas']}  33

   ${app_name}=  Get Default App Name

   ${app_trusted}=   Create App  region=${region}  app_name=${app_name}2  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_ram=22  serverless_config_vcpus=0.39  serverless_config_min_replicas=33  trusted=${True}
   Should Be Equal  ${app_trusted['data']['trusted']}  ${True}
   Should Be Equal  ${app_trusted['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app_trusted['data']['serverless_config']['ram']}           22
   Should Be Equal As Numbers  ${app_trusted['data']['serverless_config']['vcpus']}         0.39
   Should Be Equal As Numbers  ${app_trusted['data']['serverless_config']['min_replicas']}  33

# ECQ-3494
CreateApp - serverless apps with user manifest shall fail
   [Documentation]
   ...  - create app with serverless=true and user manifest
   ...  - verify proper error

   [Tags]  Serverless

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}

   Should Be Equal  ${error}  ('code=400', 'error={"message":"Allow serverless only allowed for system generated manifests"}')

# ECQ-3495
CreateApp - serverless apps with non k8s shall fail
    [Documentation]
    ...  - create app with serverless=true and non k8s deployment
    ...  - verify proper error

    [Tags]  Serverless

    ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_path=${docker_image}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}
    Should Be Equal  ${error1}  ('code=400', 'error={"message":"Allow serverless only supported for deployment type Kubernetes"}')

    ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_path=${docker_image}  image_type=ImageTypeHelm  deployment=helm  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Allow serverless only supported for deployment type Kubernetes"}')

    ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_path=${qcow_centos_image}  image_type=ImageTypeQcow  deployment=vm  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}
    Should Be Equal  ${error3}  ('code=400', 'error={"message":"Allow serverless only supported for deployment type Kubernetes"}')

# ECQ-3496
CreateApp - serverless apps with config and no serverless option shall fail
   [Documentation]
   ...  - create app with serverless=true and no options
   ...  - verify proper error

   [Tags]  Serverless

   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${False}  serverless_config_vcpus=1
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"Serverless config cannot be specified without allow serverless true"}')

   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${False}  serverless_config_vcpus=1  serverless_config_ram=1  serverless_config_min_replicas=1
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"Serverless config cannot be specified without allow serverless true"}')

   ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  serverless_config_vcpus=1  serverless_config_ram=1  serverless_config_min_replicas=1
   Should Be Equal  ${error3}  ('code=400', 'error={"message":"Serverless config cannot be specified without allow serverless true"}')

# ECQ-3497
CreateApp - serverless apps with serverless vcpus less than 0.001 shall fail
   [Documentation]
   ...  - create app with serverless=true and vcpus < 0.001
   ...  - verify app is created

   [Tags]  Serverless

   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_vcpus=0.00001
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"Serverless config vcpus cannot be less than 0.001"}')

   ${app_name}=  Get Default App Name
   ${token}=  Get Super Token
   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  token=${token}  app_name=${app_name}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_vcpus=0.00001  use_defaults=${False}
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"Serverless config vcpus cannot be less than 0.001"}')

# ECQ-3498
CreateApp - serverless apps with scale with cluster shall fail
   [Documentation]
   ...  - create app with serverless=true and scaleiwithcluster=true
   ...  - verify app is created

   [Tags]  Serverless

   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_vcpus=1  serverless_config_ram=1  serverless_config_min_replicas=1  scale_with_cluster=${True}
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"Allow serverless does not support scale with cluster"}')

# ECQ-3499
CreateApp - serverless apps with invalid config options shall fail
   [Documentation]
   ...  - create app with serverless=true and invalid config options
   ...  - verify proper error

   [Tags]  Serverless

   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_vcpus=1  serverless_config_ram=-1  serverless_config_min_replicas=1
   Should Contain  ${error1}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint64, but got number -1 for field \\\\"App.serverless_config.ram\\\\" at offset
  
   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_vcpus=1  serverless_config_ram=1  serverless_config_min_replicas=-1
   Should Contain  ${error2}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"App.serverless_config.min_replicas\\\\" at offset
  
   ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_vcpus=-1  serverless_config_ram=-1  serverless_config_min_replicas=-1
   Should Contain  ${error3}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint64, but got number -1 for field \\\\"App.serverless_config.ram\\\\" at offset
   
   ${error4}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_org_name}  app_version=1.0  allow_serverless=${True}  serverless_config_vcpus=x  serverless_config_ram=x  serverless_config_min_replicas=x
   Should Contain  ${error4}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected float32, but got string for field \\\\"App.serverless_config.vcpus\\\\" at offset

*** Keywords ***
Setup
    Create Flavor  region=${region}  ram=${ram}  disk=${disk}  vcpus=${vcpus}
