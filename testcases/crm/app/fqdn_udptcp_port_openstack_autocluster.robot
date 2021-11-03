*** Settings ***
Documentation  use FQDN to access app on CRM with docker and IpAccessDedicated and autocluster

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${test_timeout_crm}  15 min

*** Test Cases ***
#ECQ-1332
User shall be able to access 2 UDP and 2 TCP ports with k8s and autocluster
    [Documentation]
    ...  deploy app with 2 UDP and 2 TCP ports with autocluster
    ...  verify all ports are accessible via fqdn

    ${app_name_default}=  Get Default App Name
    ${cluster_name_default}=  Get Default Cluster Name
    ${cluster_name_default}=  Catenate  SEPARATOR=  autocluster  ${cluster_name_default}
	
    Create App  image_path=${docker_image}  access_ports=tcp:2015,tcp:8000,udp:2015,udp:2016  command=${docker_command}  image_type=ImageTypeDocker  deployment=kubernetes
    Create App Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_crm}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}

    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn_3}  ${cloudlet.ports[3].public_port}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor

    ${platform_type}  Get Cloudlet Platform Type  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}

    #${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
    #${rootlb}=  Convert To Lowercase  ${rootlb}

    #Set Suite Variable  ${rootlb}
