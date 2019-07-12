*** Settings ***
Documentation  use FQDN to access app on openstack with docker and IpAccessDedicated

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

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

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${docker_compose_url}=  http://35.199.188.102/apps/server_ping_threaded_compose.yml
${docker_image_path}=   docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

${test_timeout_crm}  15 min

*** Test Cases ***
User shall be able to access 2 UDP and 2 TCP ports on openstack with docker compose
    [Documentation]
    ...  deploy app with 2 UDP and 2 TCP ports with docker compose
    ...  verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  default_flavor_name=${cluster_flavor_name}  image_type=ImageTypeDocker  deployment=docker  developer_name=mobiledgex  app_version=1.0 
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_name=mobiledgex  cluster_instance_developer_name=mobiledgex

    Register Client  developer_name=mobiledgex
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}

    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=${docker_image}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn_3}  ${cloudlet.ports[3].public_port}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor
    #Create Cluster   #default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  ip_access=IpAccessDedicated  number_masters=0  number_nodes=0  deployment=docker  developer_name=mobiledgex
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cluster_name}=  Get Default Cluster Name
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
    
    Set Suite Variable  ${rootlb}
