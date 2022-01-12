*** Settings ***
Documentation  UpdateApp with multi tenancy

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${ram}=  2000
${vcpus}=  5
${disk}=  12

${region}=  US

*** Test Cases ***
# ECQ-4243
UpdateApp - serverless apps shall update with serverless config values
   [Documentation]
   ...  - create app with serverless config values
   ...  - update the app with for the various fields
   ...  - verify app is updated with config values

   [Tags]  Serverless

   ${app}=   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  allow_serverless=${True}  serverless_config_ram=22  serverless_config_vcpus=0.39  serverless_config_min_replicas=33
   Should Be Equal  ${app['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app['data']['serverless_config']['ram']}           22
   Should Be Equal As Numbers  ${app['data']['serverless_config']['vcpus']}         0.39
   Should Be Equal As Numbers  ${app['data']['serverless_config']['min_replicas']}  33

   # update ram only
   ${app_1}=   Update App  region=${region}  serverless_config_ram=23
   Should Be Equal  ${app_1['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app_1['data']['serverless_config']['ram']}           23
   Should Be Equal As Numbers  ${app_1['data']['serverless_config']['vcpus']}         0.39
   Should Be Equal As Numbers  ${app_1['data']['serverless_config']['min_replicas']}  33

   # update vcpus only
   ${app_2}=   Update App  region=${region}  serverless_config_vcpus=3
   Should Be Equal  ${app_2['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['ram']}           23
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['vcpus']}         3
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['min_replicas']}  33

   # update replicas only
   ${app_3}=   Update App  region=${region}  serverless_config_min_replicas=10
   Should Be Equal  ${app_3['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app_3['data']['serverless_config']['ram']}           23
   Should Be Equal As Numbers  ${app_3['data']['serverless_config']['vcpus']}         3
   Should Be Equal As Numbers  ${app_3['data']['serverless_config']['min_replicas']}  10

   # update all
   ${app_4}=   Update App  region=${region}  serverless_config_ram=1  serverless_config_min_replicas=2  serverless_config_vcpus=3.3
   Should Be Equal  ${app_4['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app_4['data']['serverless_config']['ram']}           1
   Should Be Equal As Numbers  ${app_4['data']['serverless_config']['vcpus']}         3.3
   Should Be Equal As Numbers  ${app_4['data']['serverless_config']['min_replicas']}  2

# ECQ-4244
UpdateApp - serverless apps shall update allowserverless=false
   [Documentation]
   ...  - create app with serverless config values
   ...  - update the app with allowserverless=False
   ...  - verify app is updated with False

   [Tags]  Serverless

   ${app}=   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  allow_serverless=${True}  serverless_config_ram=22  serverless_config_vcpus=0.39  serverless_config_min_replicas=33
   Should Be Equal  ${app['data']['allow_serverless']}  ${True}
   Should Be Equal As Numbers  ${app['data']['serverless_config']['ram']}           22
   Should Be Equal As Numbers  ${app['data']['serverless_config']['vcpus']}         0.39
   Should Be Equal As Numbers  ${app['data']['serverless_config']['min_replicas']}  33

   # update allowserverless=false
   ${app_1}=   Update App  region=${region}  allow_serverless=${False}
   Should Not Contain  ${app_1['data']}  allow_serverless
   Should Not Contain  ${app_1['data']}  serverless_config

   # update allowserverless=true
   ${app_2}=   Update App  region=${region}  allow_serverless=${True}
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['ram']}           ${ram}
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['vcpus']}         ${vcpus}
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['min_replicas']}  1

   # update allowserverless=false
   ${app_3}=   Update App  region=${region}  allow_serverless=${False}
   Should Not Contain  ${app_3['data']}  allow_serverless
   Should Not Contain  ${app_3['data']}  serverless_config

# ECQ-4245
UpdateApp - serverless apps shall update allowserverless=true
   [Documentation]
   ...  - create app with serverless with allowserverless=false
   ...  - update the app with allowserverless=true
   ...  - verify app is updated with true and config values

   [Tags]  Serverless

   ${app}=   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  allow_serverless=${False}
   Should Not Contain  ${app['data']}  allow_serverless
   Should Not Contain  ${app['data']}  serverless_config

   # update allowserverless=true
   ${app_2}=   Update App  region=${region}  allow_serverless=${True}
   Should Be Equal             ${app_2['data']['allow_serverless']}                   ${True}
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['ram']}           ${ram}
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['vcpus']}         ${vcpus}
   Should Be Equal As Numbers  ${app_2['data']['serverless_config']['min_replicas']}  1

   # update allowserverless=false
   ${app_3}=   Update App  region=${region}  allow_serverless=${False}
   Should Not Contain  ${app_3['data']}  allow_serverless
   Should Not Contain  ${app_3['data']}  serverless_config

   # update allowserverless=true
   ${app_4}=   Update App  region=${region}  allow_serverless=${True}  serverless_config_ram=22  serverless_config_vcpus=0.39  serverless_config_min_replicas=33
   Should Be Equal             ${app_4['data']['allow_serverless']}                   ${True}
   Should Be Equal As Numbers  ${app_4['data']['serverless_config']['ram']}           22
   Should Be Equal As Numbers  ${app_4['data']['serverless_config']['vcpus']}         0.39
   Should Be Equal As Numbers  ${app_4['data']['serverless_config']['min_replicas']}  33

# ECQ-4246
UpdateApp - serverless apps with user manifest shall fail
   [Documentation]
   ...  - create app with user manifest
   ...  - update allowserveless=true
   ...  - verify proper error

   [Tags]  Serverless

   Create App  region=${region}  access_ports=udp:2015  deployment_manifest=${namespace_manifest}  image_type=ImageTypeDocker  deployment=kubernetes

   ${error}=  Run Keyword and Expect Error  *  Update App  region=${region}  allow_serverless=${True}

   Should Be Equal  ${error}  ('code=400', 'error={"message":"Allow serverless only allowed for system generated manifests"}')

# ECQ-4247
UpdateApp - serverless apps with non k8s shall fail
    [Documentation]
    ...  - create app with non k8s deployment
    ...  - update allowserveless=true
    ...  - verify proper error

    [Tags]  Serverless

    ${appname}=  Get Default Appname
    Create App  region=${region}  app_name=${appname}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_path=${docker_image}  image_type=ImageTypeDocker  deployment=docker
    ${error1}=  Run Keyword and Expect Error  *  Update App  region=${region}  allow_serverless=${True}
    Should Be Equal  ${error1}  ('code=400', 'error={"message":"Allow serverless only supported for deployment type Kubernetes"}')

    Create App  region=${region}  app_name=${appname}2  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_path=${docker_image}  image_type=ImageTypeHelm  deployment=helm
    ${error2}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}2  allow_serverless=${True}
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Allow serverless only supported for deployment type Kubernetes"}')

    Create App  region=${region}  app_name=${appname}3  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_path=${qcow_centos_image}  image_type=ImageTypeQcow  deployment=vm
    ${error3}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}3  allow_serverless=${True}
    Should Be Equal  ${error3}  ('code=400', 'error={"message":"Allow serverless only supported for deployment type Kubernetes"}')

# ECQ-4248
UpdateApp - serverless apps with config and no serverless option shall fail
   [Documentation]
   ...  - create app with serverless=false
   ...  - update app with config only
   ...  - verify proper error

   [Tags]  Serverless

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  allow_serverless=${False}

   ${error1}=  Run Keyword and Expect Error  *  Update App  region=${region}  serverless_config_vcpus=1
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"Serverless config cannot be specified without allow serverless true"}')

   ${error1}=  Run Keyword and Expect Error  *  Update App  region=${region}  serverless_config_ram=1
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"Serverless config cannot be specified without allow serverless true"}')

   ${error1}=  Run Keyword and Expect Error  *  Update App  region=${region}  serverless_config_min_replicas=1
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"Serverless config cannot be specified without allow serverless true"}')

   ${error2}=  Run Keyword and Expect Error  *  Update App  region=${region}  allow_serverless=${False}  serverless_config_vcpus=1  serverless_config_ram=1  serverless_config_min_replicas=1
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"Serverless config cannot be specified without allow serverless true"}')

   ${error3}=  Run Keyword and Expect Error  *  Update App  region=${region}  serverless_config_vcpus=1  serverless_config_ram=1  serverless_config_min_replicas=1
   Should Be Equal  ${error3}  ('code=400', 'error={"message":"Serverless config cannot be specified without allow serverless true"}')

# ECQ-4249
UpdateApp - serverless apps with serverless vcpus less than 0.001 shall fail
   [Documentation]
   ...  - update app with serverless=true and vcpus < 0.001
   ...  - verify error is returned

   [Tags]  Serverless

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  allow_serverless=${True}  serverless_config_vcpus=0.1

   ${error1}=  Run Keyword and Expect Error  *  Update App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  serverless_config_vcpus=0.00001
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"Serverless config vcpus cannot have precision less than 0.001"}')

   ${error2}=  Run Keyword and Expect Error  *  Update App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  serverless_config_vcpus=0.00001  serverless_config_ram=1  serverless_config_min_replicas=3
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"Serverless config vcpus cannot have precision less than 0.001"}')

# ECQ-4250
UpdateApp - serverless apps with scale with cluster shall fail
   [Documentation]
   ...  - update app with serverless=true and scalewithcluster=true
   ...  - verify error is received

   [Tags]  Serverless

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes

   ${error1}=  Run Keyword and Expect Error  *  Update App  region=${region}  allow_serverless=${True}  serverless_config_vcpus=1  serverless_config_ram=1  serverless_config_min_replicas=1  scale_with_cluster=${True}
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"Allow serverless does not support scale with cluster"}')

# ECQ-4251
UpdateApp - serverless apps with invalid config options shall fail
   [Documentation]
   ...  - update app with serverless=true and invalid config options
   ...  - verify proper error

   [Tags]  Serverless

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes

   ${error1}=  Run Keyword and Expect Error  *  Update App  region=${region}  allow_serverless=${True}  serverless_config_vcpus=1  serverless_config_ram=-1  serverless_config_min_replicas=1
   Should Contain  ${error1}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint64, but got number -1 for field \\\\"App.serverless_config.ram\\\\" at offset
  
   ${error2}=  Run Keyword and Expect Error  *  Update App  region=${region}  allow_serverless=${True}  serverless_config_vcpus=1  serverless_config_ram=1  serverless_config_min_replicas=-1
   Should Contain  ${error2}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"App.serverless_config.min_replicas\\\\" at offset
  
   ${error3}=  Run Keyword and Expect Error  *  Update App  region=${region}  allow_serverless=${True}  serverless_config_vcpus=-1  serverless_config_ram=-1  serverless_config_min_replicas=-1
   #Should Contain  ${error3}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected unsigned decimal, but got number -1 for field \\\\"App.serverless_config.vcpus\\\\"
   
   ${error4}=  Run Keyword and Expect Error  *  Update App  region=${region}  allow_serverless=${True}  serverless_config_vcpus=x  serverless_config_ram=x  serverless_config_min_replicas=x
   Should Contain  ${error4}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected unsigned decimal, but got string x for field \\\\"App.serverless_config.vcpus\\\\"

*** Keywords ***
Setup
    Create Flavor  region=${region}  ram=${ram}  disk=${disk}  vcpus=${vcpus}
