*** Settings ***
Documentation  Controller should cleanup autocluster after CreateAppInst fail

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
#Variables       shared_variables.py

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet
${operator_name_openstack}  GDDT

${docker_image}    docker.mobiledgex.net/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_badimage.yml

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-1136
Controller should cleanup autocluster after CreateAppInst fail
    [Documentation]
    ...  create app with deployment_manifest=xxxx
    ...  create app instance
    ...  verify app instance fails and controller deletes app instance and autocluster instance

    # EDGECLOUD-438: autocluster not cleaned up if CreateAppInst fails
	
    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=  app  ${epoch_time}
    ${cluster_name}=    Catenate  SEPARATOR=  autocluster  ${epoch_time}

    Log To Console  Creating App and App Instance
    Create App  app_name=${app_name}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment_manifest=${manifest_url}  #default_flavor_name=${cluster_flavor_name}

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}
    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Encountered failures: Create App Inst failed

    Log to Console  Createing again to make sure it doesnt get App already exists
    ${error_msg1}=  Run Keyword And Expect Error  *  Create App Instance  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}
    Should Contain  ${error_msg1}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg1}   details = "Encountered failures: Create App Inst failed

    App Instance Should Not Exist  app_name=${app_name}

    ${cluster_name}=  Catenate  SEPARATOR=  autocluster  ${app_name}
    Cluster Instance Should Not Exist  cluster_name=${cluster_name}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  
    #Create Cluster   default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    #Log To Console  Creating Cluster Instance
    #Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}
    #Log To Console  Done Creating Cluster Instance
