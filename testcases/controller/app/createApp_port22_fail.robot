*** Settings ***
Documentation  CreateApp port22 failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${region}=  EU
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

*** Test Cases ***
# direct not supported
# ECQ-2562
#CreateApp - Create shall fail with docker direct and tcp:22
#   [Documentation]
#   ...  - deploy app with docker and access_type=direct and tcp:22
#   ...  - verify error is received
#
#   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   Should Be Equal  ${error}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22:tls  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   Should Be Equal  ${error1}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   Should Be Equal  ${error2}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22:tls  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   Should Be Equal  ${error3}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error4}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-2200  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   Should Be Equal  ${error4}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error5}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22-2200  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   Should Be Equal  ${error5}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error6}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:22  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   Should Be Equal  ${error6}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

# ECQ-2563
CreateApp - Create shall fail with docker lb and tcp:22
   [Documentation]
   ...  - deploy app with docker and access_type=loadbalancer and tcp:22
   ...  - verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Should Be Equal  ${error}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22:tls  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22:tls  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Should Be Equal  ${error3}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error4}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-200  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Should Be Equal  ${error4}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error5}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22-200  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Should Be Equal  ${error5}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error6}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:22  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Should Be Equal  ${error6}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

# ECQ-2564
CreateApp - Create shall fail with k8s lb and tcp:22
   [Documentation]
   ...  - deploy app with k8s and access_type=loadbalancer and tcp:22
   ...  - verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Should Be Equal  ${error}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22:tls  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22:tls  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Should Be Equal  ${error3}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error4}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-200  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Should Be Equal  ${error4}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error5}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22-200  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Should Be Equal  ${error5}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error6}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:22  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Should Be Equal  ${error6}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

# ECQ-2565
CreateApp - Create shall fail with helm lb and tcp:22
   [Documentation]
   ...  - deploy app with helm and access_type=loadbalancer and tcp:22
   ...  - verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   Should Be Equal  ${error}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22:tls  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22:tls  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   Should Be Equal  ${error3}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error4}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-200  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   Should Be Equal  ${error4}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error5}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22-200  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   Should Be Equal  ${error5}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error6}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:22  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   Should Be Equal  ${error6}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

# direct not supported
# ECQ-2566
#CreateApp - Create shall fail with vm direct and tcp:22
#   [Documentation]
#   ...  - deploy app with vm and access_type=direct and tcp:22
#   ...  - verify error is received
#
#   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   Should Be Equal  ${error}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22:tls  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   Should Be Equal  ${error1}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   Should Be Equal  ${error2}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22:tls  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   Should Be Equal  ${error3}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error4}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-2200  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   Should Be Equal  ${error4}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error5}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22-2200  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   Should Be Equal  ${error5}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')
#
#   ${error6}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:22  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   Should Be Equal  ${error6}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

# ECQ-2567
CreateApp - Create shall fail with vm lb and tcp:22
   [Documentation]
   ...  - deploy app with vm and access_type=loadbalancer and tcp:22
   ...  - verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   Should Be Equal  ${error}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error1}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22:tls  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error2}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error3}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-22:tls  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   Should Be Equal  ${error3}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error4}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:1-200  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   Should Be Equal  ${error4}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error5}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:22-200  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   Should Be Equal  ${error5}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

   ${error6}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:21,tcp:23,udp:1,tcp:22  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   Should Be Equal  ${error6}  ('code=400', 'error={"message":"App cannot use port tcp:22 - reserved for Platform inter-node SSH"}')

*** Keywords ***
Setup
    #${time}=  Get Time  epoch
    Create Flavor  region=${region}  #flavor_name=flavor${time}

