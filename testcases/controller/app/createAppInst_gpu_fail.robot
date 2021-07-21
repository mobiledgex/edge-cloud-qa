*** Settings ***
Documentation   CreateAppInst with GPU failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-2

${qcow_gpu_ubuntu16_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

${region}=  US

*** Test Cases ***
AppInst - User shall not be able to create a VM AppInst with GPU flavor on cloudlet that doesnt support GPU 
    [Documentation]
    ...  create a VM app instance with gpu flavor but no gpu supported on cloudlet 
    ...  verify proper error is received

    Create App  region=${region}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_gpu_ubuntu16_image}  access_ports=tcp:8008,tcp:8011

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_name_default}  use_defaults=${False}   #cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  use_defaults=${False}

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet ${cloudlet_name} doesn\\\'t support GPU"}')

# ECQ-3183
AppInst - User shall not be able to create a docker autocluster AppInst with GPU flavor on cloudlet that doesnt support GPU
    [Documentation]
    ...  - create a docker autocluster app instance with gpu flavor but no gpu supported on cloudlet
    ...  - verify proper error is received

    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster 

    Should Be Equal  ${error_msg}  ('code=200', 'error={"result":{"message":"Cloudlet ${cloudlet_name} doesn\\\'t support GPU","code":400}}')

# ECQ-3184
AppInst - User shall not be able to create a k8s autocluster AppInst with GPU flavor on cloudlet that doesnt support GPU
    [Documentation]
    ...  - create a k8s autocluster app instance with gpu flavor but no gpu supported on cloudlet
    ...  - verify proper error is received

    Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster 

    Should Be Equal  ${error_msg}  ('code=200', 'error={"result":{"message":"Cloudlet ${cloudlet_name} doesn\\\'t support GPU","code":400}}')

# no longer supported because removed autocluster_ip_access option
# ECQ-2005
#AppInst - User shall not be able to create a docker/shared autocluster AppInst with GPU flavor on cloudlet that doesnt support GPU
#    [Documentation]
#    ...  create a docker/shared autocluster app instance with gpu flavor but no gpu supported on cloudlet
#    ...  verify proper error is received
#
#    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011
#
#    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  autocluster_ip_access=IpAccessShared 
# 
#    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Optional resource requested by ${flavor_name_default}, cloudlet ${cloudlet_name} supports none"}')
#
# ECQ-2006
#AppInst - User shall not be able to create a docker/dedicated autocluster AppInst with GPU flavor on cloudlet that doesnt support GPU
#    [Documentation]
#    ...  create a docker/dedicated autocluster app instance with gpu flavor but no gpu supported on cloudlet
#    ...  verify proper error is received
#
#    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011
#
#    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  autocluster_ip_access=IpAccessDedicated
#
#    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Optional resource requested by ${flavor_name_default}, cloudlet ${cloudlet_name} supports none"}')
#
# ECQ-2007
#AppInst - User shall not be able to create a k8s/shared autocluster AppInst with GPU flavor on cloudlet that doesnt support GPU
#    [Documentation]
#    ...  create a k8s/shared autocluster app instance with gpu flavor but no gpu supported on cloudlet
#    ...  verify proper error is received
#
#    Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011
#
#    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  autocluster_ip_access=IpAccessShared
#
#    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Optional resource requested by ${flavor_name_default}, cloudlet ${cloudlet_name} supports none"}')
#
# ECQ-2008
#AppInst - User shall not be able to create a k8s/dedicated autocluster AppInst with GPU flavor on cloudlet that doesnt support GPU
#    [Documentation]
#    ...  create a k8s/dedicated autocluster app instance with gpu flavor but no gpu supported on cloudlet
#    ...  verify proper error is received
#
#    Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011
#
#    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  autocluster_ip_access=IpAccessDedicated
#
#    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Optional resource requested by ${flavor_name_default}, cloudlet ${cloudlet_name} supports none"}')

*** Keywords ***
Setup
    Create Flavor  region=${region}  disk=80  optional_resources=gpu=gpu:1

    ${flavor_name_default}=  Get Default Flavor Name
    Set Suite Variable  ${flavor_name_default}

