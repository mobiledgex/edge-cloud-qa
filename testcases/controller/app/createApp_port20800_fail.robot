*** Settings ***
Documentation  CreateApp port 20800 failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-2811
CreateApp - create with reserved port tcp:20800 shall return error
   [Documentation]
   ...  - send CreateApp with reserved port tcp:20800
   ...  - verify proper error is received

   [Template]  Fail Create App port tcp:20800

# direct not supported
#   image_path=${docker_image}  access_ports=tcp:20800  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:20800:tls  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:23-20800  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:23-20800:tls  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:20800-20801  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:20800  image_type=ImageTypeDocker  deployment=docker  access_type=direct

   image_path=${docker_image}  access_ports=tcp:20800  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20800:tls  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20700-20800  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20700-20800:tls  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20800-20801  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:20800  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer

   image_path=${docker_image}  access_ports=tcp:20800  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20800:tls  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20700-20800  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20700-20800:tls  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20800-20801  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:20800  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer

   image_path=${docker_image}  access_ports=tcp:20800  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20800:tls  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20700-20800  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20700-20800:tls  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20800-20801  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:20800  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer

   image_path=${docker_image}  access_ports=tcp:20800  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20800:tls  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20700-20800  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20700-20800:tls  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:20800-20801  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:20800  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer

#   image_path=${docker_image}  access_ports=tcp:20800  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:20800:tls  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:23-20800  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:23-20800:tls  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:20800-20801  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:20800  image_type=ImageTypeQcow  deployment=vm  access_type=direct

*** Keywords ***
Setup
   Create Flavor  region=${region}

Fail Create App port tcp:20800
   [Arguments]  &{parms}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"App cannot use port tcp:20800 - reserved for Kubernetes master join server"}')  Create App  region=${region}  &{parms}

