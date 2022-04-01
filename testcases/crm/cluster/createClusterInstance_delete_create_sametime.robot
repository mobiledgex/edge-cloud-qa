*** Settings ***
Documentation  User shall be able to delete/create an app instance on openstack at the same time

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT

${mobiledgex_domain}  mobiledgex-qa.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

*** Test Cases ***
User shall be able to delete/create an app instance at the same time on openstack
    [Documentation]
    ...  create app and app instance on openstack
    ...  delete the app instance and create a new one at the same time
    ...  verify app instance is created and other deleted successfully

    Log To Console  Creating Cluster Instance
    ${handle1}=  Create Cluster Instance  cluster_name=${cluster_name_2}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  use_thread=${True}
    Log To Console  Done Creating Cluster Instance

    # delete the cluster instance in thread
    ${handle2}=  Delete Cluster Instance  cluster_name=${cluster_name_1}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  use_thread=${True}

    # wait for them to finish
    Log To Console  Waiting for threads
    Wait For Replies  ${handle1}  ${handle2}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor
    #Create Cluster

    ${cluster_name_1}=  Get Default Cluster Name
    ${cluster_name_2}=  Catenate  SEPARATOR=.  ${cluster_name_1}  2

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cluster_name=${cluster_name_1}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  no_auto_delete=${True}
    Log To Console  Done Creating Cluster Instance

    Set Suite Variable  ${cluster_name_1}
    Set Suite Variable  ${cluster_name_2}
