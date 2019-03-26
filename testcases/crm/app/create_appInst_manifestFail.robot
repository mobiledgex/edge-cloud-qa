*** Settings ***
Documentation  Controller should cleanup autocluster after CreateAppInst fail

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Variables       shared_variables.py

#Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  30 minutes
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name}  automationHamburgCloudlet
${operator_name}  TDG

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

*** Test Cases ***
Controller should cleanup autocluster after CreateAppInst fail
    [Documentation]
    ...  create app with deployment_manifest=xxxx
    ...  create app instance
    ...  verify app instance fails and controller deletes app instance and autocluster instance

    # EDGECLOUD-438: autocluster not cleaned up if CreateAppInst fails
	
    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=  app  ${epoch_time}

    Log To Console  Creating App and App Instance
    Create App  app_name=${app_name}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment_manifest=xxxx  default_flavor_name=flavor1550017240-694686   #using this flavor since I cant change x1.medium because of other bug
    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  app_name=${app_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Encountered failures: [Create App Inst failed: invalid kubernetes deployment yaml

    App Instance Should Not Exist  app_name=${app_name}

    ${cluster_name}=  Catenate  SEPARATOR=  autocluster  ${app_name}
    Cluster Instance Should Not Exist  cluster_name=${cluster_name}

*** Keywords ***
Setup
    #Create Developer
    #Create Flavor
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  
    Create Cluster   default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    #Log To Console  Creating Cluster Instance
    #Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}
    #Log To Console  Done Creating Cluster Instance
