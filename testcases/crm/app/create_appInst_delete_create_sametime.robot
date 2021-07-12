*** Settings ***
Documentation  User shall be able to delete/create an app instance on openstack at the same time

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationBonnCloudlet
${operator_name_openstack}  TDG

${mobiledgex_domain}  mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

*** Test Cases ***
User shall be able to delete/create an app instance at the same time on openstack
    [Documentation]
    ...  create app and app instance on openstack
    ...  delete the app instance and create a new one at the same time
    ...  verify app instance is created and other deleted successfully

    #${epoch_time}=  Get Time  epoch
    #${app_name}=    Catenate  SEPARATOR=  app  ${epoch_time}

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    # create app instance in thread
    Log To Console  Creating Second App Instance
    ${handle1}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}   cluster_instance_name=autocluster  use_thread=${True}

    # delete the app instance in thread
    ${handle2}=  Delete App Instance  app_name=${app_name_1}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  use_thread=${True}

    # wait for them to finish
    Log To Console  Waiting for threads
    Wait For Replies  ${handle1}  ${handle2}

    Log To Console  Waiting for k8s pod to be running
    ${auto_cluster_name}=  Catenate  SEPARATOR=  autocluster  ${app_name_2}
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${auto_cluster_name}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    # delete the app instance
    #Delete App Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator_name_openstack}
    #App Instance Should Not Exist

    # create the app instance again	
    #Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_name_default}
    #App Instance Should Exist

    #Log To Console  Waiting for k8s pod to be running
    #${auto_cluster_name}=  Catenate  SEPARATOR=  autocluster  ${app_name_default}
    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${auto_cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    #Create Cluster

    ${app_name_1}=  Get Default App Name
    ${app_name_2}=  Catenate  SEPARATOR=.  ${app_name_1}  2
    Create App  app_name=${app_name_1}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  
    Create App  app_name=${app_name_2}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}

    ${rootlb}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

#    Log To Console  Creating First App Instance
    ${app_inst_1}=  Create App Instance  app_name=${app_name_1}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}   cluster_instance_name=autocluster  no_auto_delete=${True}
    App Instance Should Exist  app_instance=${app_inst_1}

    Log To Console  Waiting for k8s pod to be running
    ${auto_cluster_name}=  Catenate  SEPARATOR=  autocluster  ${app_name_1}
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${auto_cluster_name}  operator_name=${operator_name_openstack}  pod_name=${app_name_1}

    #Log To Console  Creating Cluster Instance
    #Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}
    #Log To Console  Done Creating Cluster Instance

    Set Suite Variable  ${rootlb}
    Set Suite Variable  ${app_inst_1}
    Set Suite Variable  ${app_name_1}
    Set Suite Variable  ${app_name_2}
