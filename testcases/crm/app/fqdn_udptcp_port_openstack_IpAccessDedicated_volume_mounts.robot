*** Settings ***
Documentation  use FQDN to access app on CRM with IpAccessDedicated and volume mounts

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet
${operator_name_openstack}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${region}=  EU

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_volumemount.yml
${manifest_pod_name}=  server-ping-threaded-udptcphttp

${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-1385
User shall be able to access UDP and TCP ports on CRM with IpAccessDedicated and volume mounts
    [Documentation]
    ...  - deploy app with 1 UDP and 1 TCP ports and volume mounts
    ...  - verify mounts
    ...  - verify all ports are accessible via fqdn

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015  deployment_manifest=${manifest_url}  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${manifest_pod_name}

    #${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}
    #${server_info_node}=    Get Server List  name=${openstack_node_name}
   
    #Write File to Node  root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}  data=${cluster_name_default}  #root_loadbalancer=${rootlb} 
	
    #Mount Should Exist on Pod  root_loadbalancer=${rootlb}  operator_name=${operator_name_openstack}  pod_name=${manifest_pod_name}  mount=/data  cluster_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client  #app_name=app1579992291-485193  developer_org_name=mobiledgex  app_version=1.0
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}  #carrier_name=TDG  latitude=32.7767  longitude=-96.797
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    ${write_return}=  Write To App Volume Mount  host=${cloudlet.fqdn}  port=${cloudlet.ports[0].public_port}  data=${cluster_name_default}
    Should Be Equal  ${write_return[1]}  ${cluster_name_default}

*** Keywords ***
Setup
    #Create Developer
    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    IF  '${platform_type}' == 'K8SBareMetal'
        ${allow_serverless}=  Set Variable  ${True}
    ELSE
        ${allow_serverless}=  Set Variable  ${None}
    END
    Set Suite Variable  ${platform_type}
    Set Suite Variable  ${allow_serverless}

    Create Flavor  region=${region}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=0
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cluster_name}=  Get Default Cluster Name
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Set Suite Variable  ${cloudlet_lowercase}
    Set Suite Variable  ${cluster_name_default}
    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${rootlb}
