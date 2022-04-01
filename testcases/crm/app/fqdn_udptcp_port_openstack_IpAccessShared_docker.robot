*** Settings ***
Documentation  use FQDN to access app on openstack with docker and IpAccessShared

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationFrankfurtCloudlet
${operator_name_openstack}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex-qa.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-2017
User shall be able to access 2 UDP and 2 TCP and HTTP ports on openstack with docker IpAccessShared
    [Documentation]
    ...  deploy app with 2 UDP and 2 TCP ports and TCP 8085 with shared docker
    ...  verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016,tcp:8085  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}

    Register Client
    ${cloudlet}=  Find Cloudlet	 latitude=${latitude}  longitude=${longitude}

    TCP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}

    UDP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[3].public_port}

    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[4].public_port} 

# ECQ-4388
User shall be able to access 2 UDP and 2 TCP and HTTP ports on 2 appinst with 1 docker IpAccessShared cluster
    [Documentation]
    ...  - deploy 2 apps on the same shared docker
    ...  - verify all ports are accessible via fqdn
    ...  - verify container ids are correct

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${app1}=  Create App  region=${region}  app_name=${app_name_default}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016,tcp:8085  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    ${app2}=  Create App  region=${region}  app_name=${app_name_default}2  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016,tcp:8085  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker

    ${t1}=  Create App Instance  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  use_thread=${True}
    ${t2}=  Create App Instance  region=${region}  app_name=${app_name_default}2  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  use_thread=${True}
    Wait For Replies  ${t1}  ${t2}

    ${appinst1}=  Show App Instances  region=${region}  app_name=${app_name_default}
    ${appinst2}=  Show App Instances  region=${region}  app_name=${app_name_default}2
    Length Should Be  ${appinst1[0]['data']['runtime_info']['container_ids']}  1
    Length Should Be  ${appinst2[0]['data']['runtime_info']['container_ids']}  1
    Should Be Equal  ${appinst1[0]['data']['runtime_info']['container_ids'][0]}  ${app_name_default}10
    Should Be Equal  ${appinst2[0]['data']['runtime_info']['container_ids'][0]}  ${app_name_default}210
  
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}2

    Register Client  app_name=${app_name_default}
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    TCP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}
    UDP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[3].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[4].public_port}

    Register Client  app_name=${app_name_default}2
    ${cloudlet2}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    TCP Port Should Be Alive  ${cloudlet2.fqdn}  ${cloudlet2.ports[0].public_port}
    TCP Port Should Be Alive  ${cloudlet2.fqdn}  ${cloudlet2.ports[1].public_port}
    UDP Port Should Be Alive  ${cloudlet2.fqdn}  ${cloudlet2.ports[2].public_port}
    UDP Port Should Be Alive  ${cloudlet2.fqdn}  ${cloudlet2.ports[3].public_port}
    HTTP Port Should Be Alive  ${cloudlet2.fqdn}  ${cloudlet2.ports[4].public_port}

*** Keywords ***
Setup
    Create Flavor  region=${region}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=IpAccessShared  deployment=docker
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_crm}-${operator_name_crm}  ${region}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cluster_name}=  Get Default Cluster Name
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
    
    Set Suite Variable  ${rootlb}
