*** Settings ***
Documentation  Create app instance on openstack with rootlb rest port blocked

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet
${operator_name_openstack}  GDDT

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhawkinscloudlet.gddt.mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

*** Test Cases ***
CRM shall recover when attempting to create an app instance on openstack with rootlb rest port blocked
    [Documentation]
    ...  block rest port on rootlb
    ...  create an app instance on openstack
    ...  verify proper error is received
    ...  unblock the port
    ...  create the app instance again
    ...  verify app instance is created 

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=  app  ${epoch_time}

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  #flavor_name=${cluster_flavor_name}
    Log To Console  Done Creating Cluster Instance

    Block Rootlb Port  root_loadbalancer=${rootlb}  port=18889  target=INPUT

    # create the app instance
    Log To Console  Creating App Instance
    ${error_msg}=  Run Keyword and Expect Error  *  Create App Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}
    App Instance Should Not Exist

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   proxyerr: error, can\'t request nginx proxy add

    Unblock Rootlb Port  root_loadbalancer=${rootlb}  port=18889  target=INPUT

    Sleep  60 seconds     # wait for failure cleanup

    # create the app instance again
    Log To Console  Creating App Instance After unblock
    Create App Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}
    App Instance Should Exist

    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

CRM shall recover when attempting to create an app instance with autocluster on openstack with rootlb rest port blocked
    [Documentation]
    ...  block rest port on rootlb
    ...  create an app instance on openstack with autocluster
    ...  verify proper error is received
    ...  unblock the port
    ...  create the app instance again
    ...  verify app instance is created

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=  app  ${epoch_time}

    ${cluster_name_default}=  Get Default Cluster Name
    #${flavor_name_default}=   Get Default Flavor Name
    ${app_name_default}=  Get Default App Name

    Block Rootlb Port  root_loadbalancer=${rootlb}  port=18889  target=INPUT

    # create the app instance
    Log To Console  Creating App Instance
    ${error_msg}=  Run Keyword and Expect Error  *  Create App Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}   cluster_instance_name=autocluster  #flavor_name=${flavor_name_default}
    App Instance Should Not Exist

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   proxyerr: error, can\'t request nginx proxy add

    Unblock Rootlb Port  root_loadbalancer=${rootlb}  port=18889  target=INPUT

    Sleep  2 minutes  # wait for heat cleanup to finish

    # create the app instance again
    Log To Console  Creating App Instance After unblock
    Create App Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}   cluster_instance_name=autocluster  #flavor_name=${cluster_name_default}
    App Instance Should Exist

    Log To Console  Waiting for k8s pod to be running
    ${auto_cluster_name}=  Catenate  SEPARATOR=  autocluster  ${app_name_default}
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${auto_cluster_name}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor
    #Create Cluster   #default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Create App           image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}

    ${rootlb}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}

Teardown
    Run Keyword and Ignore Error  Unblock Rootlb Port  root_loadbalancer=${rootlb}  port=18889  target=INPUT
    Cleanup provisioning
