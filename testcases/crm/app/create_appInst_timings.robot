*** Settings ***
Documentation  CreateAppInst openstack timings

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationHamburgCloudlet
${operator_name_openstack}  TDG


#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

*** Test Cases ***
CreateAppInst on openstack shall create quickly
    [Documentation]
    ...  create app and app instance on openstack
    ...  verify app instance is created within 30secs

    ${clusterInst_create_time}=  Evaluate  ${clusterInst_end_epoch_time}-${clusterInst_start_epoch_time}
    ${appInst_create_time}=      Evaluate  ${appInst_end_epoch_time}-${appInst_start_epoch_time}

    Should Be True  ${clusterInst_create_time} < 600  #should create within 5 mins
    Should Be True  ${appInst_create_time} < 30  #should create within 30 seconds

*** Keywords ***
Setup

    #Create Cluster   default_flavor_name=${cluster_flavor_name}

    Log To Console  Creating Cluster Instance
    ${clusterInst_start_epoch_time}=  Get Time  epoch
    Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}
    ${clusterInst_end_epoch_time}=  Get Time  epoch
    Log To Console  Done Creating Cluster Instance

    Log To Console  Creating App and App Instance
    Create App           image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  default_flavor_name=${cluster_flavor_name} 
    ${cluster_name_default}=  Get Default Cluster Name
    ${appInst_start_epoch_time}=  Get Time  epoch
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}
    ${appInst_end_epoch_time}=  Get Time  epoch
    App Instance Should Exist

    Set Suite Variable  ${clusterInst_start_epoch_time}
    Set Suite Variable  ${clusterInst_end_epoch_time}

    Set Suite Variable  ${appInst_start_epoch_time}
    Set Suite Variable  ${appInst_end_epoch_time}
