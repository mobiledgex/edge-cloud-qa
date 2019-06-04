*** Settings ***
Documentation  Create an app instance on openstack with a dot in the appname

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

#Variables       shared_variables.py

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationBonnCloudlet
${operator_name_openstack}  TDG

${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${app_template}    http://35.199.188.102/apps/apptemplate.yaml

${test_timeout_crm}  15 min
	
*** Test Cases ***
User shall be able to create an app instance on openstack with a dot in the app name
    [Documentation]
    ...  create an app instance on openstack with a dot in the app name. Such as 'my.app'
    ...  verify the app is create with the dot removed. Such as 'myapp'

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=.  app  ${epoch_time}

    ${cluster_name_default}=  Get Default Cluster Name

    Log To Console  Creating App and App Instance
    Create App  app_name=${app_name}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  app_template=${apptemplate}    #   default_flavor_name=flavor1550592128-673488   cluster_name=cl1550691984-633559 
    Create App Instance  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Registering Client and Finding Cloudlet
    Register Client  app_name=${app_name}
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${app_name_nodot}=    Catenate  SEPARATOR=  app  ${epoch_time}  -udp.

    # verify dot is gone
    Should Be Equal     ${app_name_nodot}  ${cloudlet.ports[0].fqdn_prefix}

    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name}

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster   #default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}
