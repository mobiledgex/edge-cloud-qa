*** Settings ***
Documentation   CreateAppInst with accesstype failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-2

${qcow_gpu_ubuntu16_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

${region}=  US

*** Test Cases ***
# no longer supported with autocluster_ip_access
# ECQ-2027
#AppInst - User shall not be able to create a VM AppInst with ipaccess=shared and accesstype=direct 
#    [Documentation]
#    ...  create a VM app instance with ipaccess=shared and accesstype=direct 
#    ...  verify proper error is received
#
#    Create App  region=${region}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_gpu_ubuntu16_image}  access_ports=tcp:8008,tcp:8011
#
#    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  #app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_name_default}  use_defaults=${False}   #cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  use_defaults=${False}
#
#    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot specify AutoClusterIpAccess as IP_ACCESS_SHARED if App access type is ACCESS_TYPE_DIRECT"}')
#
## ECQ-2028
#AppInst - User shall not be able to create a docker AppInst with autocluster and ipaccess=shared and accesstype=direct
#    [Documentation]
#    ...  create a docker autocluster app instance with ipaccess=shared and accesstype=direct
#    ...  verify proper error is received
#
#    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=direct
#
#    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  autocluster_ip_access=IpAccessShared 
#
#    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot specify AutoClusterIpAccess as IP_ACCESS_SHARED if App access type is ACCESS_TYPE_DIRECT"}')

# ECQ-2029
AppInst - User shall not be able to create a docker AppInst with ipaccess=shared and accesstype=direct
    [Documentation]
    ...  create a docker app instances with ipaccess=shared and accesstype=direct
    ...  verify proper error is received

    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessShared  deployment=docker

    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=direct

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Direct Access App cannot be deployed on IP_ACCESS_SHARED ClusterInst"}')

*** Keywords ***
Setup
    Create Flavor  region=${region}  #disk=80

    ${flavor_name_default}=  Get Default Flavor Name
    Set Suite Variable  ${flavor_name_default}

