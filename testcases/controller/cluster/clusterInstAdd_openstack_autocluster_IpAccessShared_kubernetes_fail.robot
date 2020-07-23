*** Settings ***
Documentation   Create cluster instances with long name on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         String

Test Timeout     ${test_timeout_crm}

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_shared}  automationFrankfurtCloudlet
${operator_name_openstack}  TDG
${region}  EU
${flavor_name}    x1.medium
${cluster_name_long}=  longnameeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

*** Test Cases ***
Controller shall return error while creating kubernetes based App Inst and IpAccessShared with autocluster name greater than 40 characters
    [Documentation]
    ...  Create an autocluster instance on openstack with a long name 
    ...  Verify that creation fails

    ${cluster_name}=  Catenate  SEPARATOR=  autocluster  ${cluster_name_long}
    ${cluster_name_openstack_length}=  Get Length   ${cluster_name}
    log to console   Length of autocluster name=${cluster_name_openstack_length}

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015  command=${docker_command}  image_type=ImageTypeDocker  deployment=kubernetes
    ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  autocluster_ip_access=IpAccessShared

    Should be equal  ${error}  ('code=400', 'error={"message":"Cluster name limited to 40 characters"}')


*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    Create Flavor  region=${region} 

