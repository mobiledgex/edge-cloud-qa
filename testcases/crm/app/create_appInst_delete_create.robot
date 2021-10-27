*** Settings ***
Documentation  User shall be able to create/delete/create an app instance 

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexApp
Library  String
#Variables       shared_variables.py

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet
${operator_name_openstack}  GDDT

#${rootlb}          automationhawkinscloudlet.gddt.mobiledgex.net
${mobiledgex_domain}  mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-1138
User shall be able to create/delete/create an app instance on CRM
    [Documentation]
    ...  create app and app instance on CRM
    ...  delete the app instance
    ...  create the app instance again
    ...  verify app instance is created both times

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=  app  ${epoch_time}

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    # create the app and app instance
    Log To Console  Creating App and App Instance
    Create App           image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  #default_flavor_name=${cluster_flavor_name} 
    Create App Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}   cluster_instance_name=${cluster_name_default}  no_auto_delete=${True}
    App Instance Should Exist

    #Log To Console  Waiting for k8s pod to be running
    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    # delete the app instance
    Delete App Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    App Instance Should Not Exist

    # create the app instance again	
    Create App Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}
    App Instance Should Exist

    #Log To Console  Waiting for k8s pod to be running
    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    IF  '${platform_type}' == 'K8SBareMetal'
        ${numnodes}=  Set Variable  0
    ELSE
        ${numnodes}=  Set Variable  ${None}
    END

    #Create Developer
    Create Flavor
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  
    #Create Cluster   default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  number_nodes=${numnodes}  #flavor_name=${cluster_flavor_name}
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}

