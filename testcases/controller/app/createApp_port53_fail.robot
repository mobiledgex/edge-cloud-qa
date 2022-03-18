*** Settings ***
Documentation  CreateApp port 53 failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-4430
CreateApp - create with reserved port tcp:53 shall return error
   [Documentation]
   ...  - send CreateApp with reserved port tcp:53
   ...  - verify proper error is received

   [Template]  Fail Create App port tcp:53

   image_path=${docker_image}  access_ports=tcp:53         image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:53:tls     image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:50-53      image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:50-53:tls  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:53-54      image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:53  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer

   image_path=${docker_image}  access_ports=tcp:53  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:53:tls  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:50-53  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:50-53:tls  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:53-54  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:53  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer

   image_path=${docker_image}  access_ports=tcp:53  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:53:tls  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:50-53  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:50-53:tls  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:53-54  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:53  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer

   image_path=${docker_image}  access_ports=tcp:53  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:53:tls  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:50-53  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:50-53:tls  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:53-54  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:53  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer

*** Keywords ***
Setup
   Create Flavor  region=${region}

Fail Create App port tcp:53
   [Arguments]  &{parms}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"App cannot use port tcp:53 - reserved for dns tcp"}')  Create App  region=${region}  &{parms}

