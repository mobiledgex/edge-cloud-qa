*** Settings ***
Documentation  use FQDN to access app on openstack

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
#Variables       shared_variables.py

Test Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout  30 minutes
	
*** Variables ***
#${dme_api_address}  127.0.0.1:50051
#${controller_api_address}  127.0.0.1:55001

${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationHamburgCloudlet
${operator_name_openstack}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${rootlb}          shared.automationhamburgcloudlet.tdg.mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${app_template}    http://35.199.188.102/apps/apptemplate.yaml
	
*** Test Cases ***
User shall be able to access 1 UDP port on openstack
    [Documentation]
    ...  deploy app with 1 UDP port
    ...  verify the port as accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  app_template=${apptemplate}  default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}
	
    Log To Console  Registering Client and Finding Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_openstack}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
#    UDP Port Should Be Alive  app1554837441-901057-udp.automationhamburgcloudlet.tdg.mobiledgex.net  2015
   #UDP Port Should Be Alive  10.101.8.2  2015

*** Keywords ***
Setup
    Create Developer
    #Create Flavor
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  
    Create Cluster   default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}
    Log To Console  Done Creating Cluster Instance
