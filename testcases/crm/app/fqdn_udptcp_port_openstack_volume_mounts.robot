*** Settings ***
Documentation  use FQDN to access app on openstack with volume mounts

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationBonnCloudlet
${operator_name_openstack}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationbonncloudlet.tdg.mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_volumemount.yml
${manifest_pod_name}=  server-ping-threaded-udptcphttp
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
User shall be able to access UDP,TCP and HTTP ports on openstack with volume mounts
    [Documentation]
    ...  deploy app with 1 UDP and 1 TCP and 1 HTTP ports with manifest volume mounts
    ...  verify mounts
    ...  verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,http:8085  deployment_manifest=${manifest_url}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${manifest_pod_name}

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_node_name}
   
    Write File to Node  node=${server_info_node[0]['Networks']}  data=${cluster_name_default}  
	
    Mount Should Exist on Pod  pod_name=${manifest_pod_name}  mount=/data  cluster_name=${cluster_name_default}  

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    #Create Cluster   #default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator_name_openstack}  #flavor_name=${cluster_flavor_name}
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_shared}

    Set Suite Variable  ${cloudlet_lowercase}

    Set Suite Variable  ${rootlb}
