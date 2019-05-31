*** Settings ***
Documentation  use FQDN to access app on openstack with docker and IpAccessDedicated and autocluster

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  30 minutes
	
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

*** Test Cases ***
User shall be able to access 2 UDP and 2 TCP ports on openstack with docker and autocluster
    [Documentation]
    ...  deploy app with 2 UDP and 2 TCP ports with docker and autocluster
    ...  verify all ports are accessible via fqdn

    Create App  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  command=${docker_command}  default_flavor_name=${cluster_flavor_name}  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_openstack}
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
    Create Developer
    Create Flavor

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cluster_name}=  Get Default Cluster Name
    ${cluster_name}=  Catenate  SEPARATOR=  autocluster  ${cluster_name}
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
    
    Set Suite Variable  ${rootlb}
    Set Suite Variable  ${cluster_name}
