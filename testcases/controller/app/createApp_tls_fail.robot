*** Settings ***
Documentation  CreateApp TLS failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${region}=  EU
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

*** Test Cases ***
# direct not supported
# ECQ-2244
#CreateApp - Create shall fail with docker access_type=direct and TCP TLS
#   [Documentation]
#   ...  deploy app with docker and access_type=direct and TCP TLS port
#   ...  verify error is received
#
#   # EDGECLOUD-2797 error should be given for CreateApp with docker direct access and tls
#
#   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016:tls  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   Should Be Equal  ${error}  ('code=400', 'error={"message":"TLS unsupported on VM and docker deployments with direct access"}')

# ECQ-2245 no longer supported
#CreateApp - Create shall fail with docker access_type=direct and HTTP TLS
#   [Documentation]
#   ...  deploy app with docker and access_type=direct and HTTP TLS port
#   ...  verify error is received
#
#   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=http:2016:tls  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   #Should Be Equal  ${error}  ('code=400', 'error={"message":"Deployment Type and HTTP access ports are incompatible"}')
#   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid protocol http, not available for tls support"}')

# direct not found
# ECQ-2246
#CreateApp - Create shall fail with VM access_type=direct and TCP TLS
#   [Documentation]
#   ...  deploy app with VM and access_type=direct and TCP TLS port
#   ...  verify error is received
#
#   # EDGECLOUD-3233 error should be given for CreateApp with VM direct access and tls  fixed/closed
#
#   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=tcp:2016:tls  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}
#   Should Be Equal  ${error}  ('code=400', 'error={"message":"TLS unsupported on VM and docker deployments with direct access"}')

# ECQ-2247 no longer supported
#CreateApp - Create shall fail with VM access_type=direct and HTTP TLS
#   [Documentation]
#   ...  deploy app with VM and access_type=direct and HTTP TLS port
#   ...  verify error is received
##
#   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  access_ports=http:2016:tls  image_type=ImageTypeQcow  deployment=vm  access_type=direct  image_path=${qcow_centos_image}
#   #Should Be Equal  ${error}  ('code=400', 'error={"message":"Deployment Type and HTTP access ports are incompatible"}')
#   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid protocol http, not available for tls support"}')

# ECQ-2248
CreateApp - Create shall fail with docker and UDP TLS
   [Documentation]
   ...  deploy app with docker and access_type=direct/lb and UDP TLS port
   ...  verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2016:tls  image_type=ImageTypeDocker  deployment=docker  access_type=direct
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid protocol udp, not available for tls support"}')

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2016:tls  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid protocol udp, not available for tls support"}')

# ECQ-2249
CreateApp - Create shall fail with k8s and UDP TLS
   [Documentation]
   ...  deploy app with k8s and access_type=lb and UDP TLS port
   ...  verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2016:tls  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid protocol udp, not available for tls support"}')

# ECQ-2250
CreateApp - Create shall fail with VM and UDP TLS
   [Documentation]
   ...  deploy app with VM and access_type=direct/lb and UDP TLS port
   ...  verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${qcow_centos_image}  access_ports=udp:2016:tls  image_type=ImageTypeQcow  deployment=vm  access_type=direct
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid protocol udp, not available for tls support"}')

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${qcow_centos_image}  access_ports=udp:2016:tls  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid protocol udp, not available for tls support"}')

# ECQ-2251
CreateApp - Create shall fail with helm and UDP TLS
   [Documentation]
   ...  deploy app with helm and access_type=lb and UDP TLS port
   ...  verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2016:tls  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid protocol udp, not available for tls support"}')

*** Keywords ***
Setup
    #${time}=  Get Time  epoch
    Create Flavor  region=${region}  #flavor_name=flavor${time}

