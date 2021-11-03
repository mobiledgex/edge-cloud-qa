*** Settings ***
Documentation  use FQDN to access app on CRM with docker and IpAccessDedicated

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium

${developer_org_name}=  MobiledgeX
	
${cloudlet_name_openstack_dedicated}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${docker_compose_url}=  http://35.199.188.102/apps/server_ping_threaded_compose.yml
${docker_image_path}=   docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

${region}=  EU

${test_timeout_crm}  15 min

*** Test Cases ***
# direct not supported
# ECQ-1383
#User shall be able to access 2 UDP and 2 TCP ports on openstack with docker compose and access_type=direct
#    [Documentation]
#    ...  deploy app with 2 UDP and 2 TCP ports with docker compose
#    ...  verify all ports are accessible via fqdn
#
#    ${cluster_name_default}=  Get Default Cluster Name
#    ${app_name_default}=  Get Default App Name
#
#    Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0   access_type=direct
#    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=${developer_org_name}  cluster_instance_developer_org_name=${developer_org_name}
#
#    Register Client  developer_org_name=${developer_org_name}
#    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
#    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
#    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
#    ${fqdn_2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
#    ${fqdn_3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}
#
##    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=${docker_image}
#
#    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
#    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
#
#    UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
#    UDP Port Should Be Alive  ${fqdn_3}  ${cloudlet.ports[3].public_port}

# ECQ-1998
User shall be able to access 2 UDP and 2 TCP ports on CRM with docker compose and no access_type
    [Documentation]
    ...  - deploy app with 2 UDP and 2 TCP ports with docker compose dedicated and no access_type
    ...  - verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0 
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  developer_org_name=${developer_org_name}  cluster_instance_developer_org_name=${developer_org_name}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client  developer_org_name=${developer_org_name}
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}

#    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=${docker_image}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn_3}  ${cloudlet.ports[3].public_port}

# ECQ-1999
User shall be able to access 2 UDP and 2 TCP ports on CRM with docker compose and access_type=loadbalancer
    [Documentation]
    ...  - deploy app with 2 UDP and 2 TCP ports with docker compose dedicated and access_type=loadbalancer
    ...  - verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0  access_type=loadbalancer
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  developer_org_name=${developer_org_name}  cluster_instance_developer_org_name=${developer_org_name}
  
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client  developer_org_name=${developer_org_name}
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}

#    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=${docker_image}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn_3}  ${cloudlet.ports[3].public_port}

# ECQ-2000
User shall be able to access 2 UDP and 2 TCP ports on CRM with docker compose and access_type=default
    [Documentation]
    ...  - deploy app with 2 UDP and 2 TCP ports with docker compose dedicated and access_type=default
    ...  - verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0  access_type=default
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  developer_org_name=${developer_org_name}  cluster_instance_developer_org_name=${developer_org_name}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client  developer_org_name=${developer_org_name}
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}

#    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=${docker_image}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn_3}  ${cloudlet.ports[3].public_port}

# ECQ-2269
User shall be able to access 2 UDP and 2 TCP ports on CRM with docker compose and no image_path 
    [Documentation]
    ...  - deploy app with 2 UDP and 2 TCP ports with docker compose dedicated and no image path
    ...  - verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  deployment_manifest=${docker_compose_url}  image_path=no_default  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0  access_type=default
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  developer_org_name=${developer_org_name}  cluster_instance_developer_org_name=${developer_org_name}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client  developer_org_name=${developer_org_name}
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn_3}  ${cloudlet.ports[3].public_port}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor  region=${region}
    #Create Cluster   #default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=IpAccessDedicated  number_masters=0  number_nodes=0  deployment=docker  developer_org_name=${developer_org_name}
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cluster_name}=  Get Default Cluster Name
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
    
    Set Suite Variable  ${rootlb}
