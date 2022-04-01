*** Settings ***
Documentation  use FQDN to access app on CRM after reboot

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
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

${mobiledgex_domain}  mobiledgex-qa.net


${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py

${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml
${manifest_pod_name}=  server-ping-threaded-udptcphttp
	
${test_timeout_crm}  15 min

${region}  US
	
*** Test Cases ***
# ECQ-1379
User shall be able to access UDP,TCP and HTTP ports on CRM after reboot
    [Documentation]
    ...  - deploy app with 1 UDP and 1 TCP and 1 HTTP ports
    ...  - verify all ports are accessible via fqdn
    ...  - reboot rootlb
    ...  - verify all ports are accessible via fqdn after reboot

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  command=${docker_command}  #default_flavor_name=${cluster_flavor_name}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}


    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  app_name=${app_name_default}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}  app_name=${app_name_default}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port} 

    Reboot Rootlb  root_loadbalancer=${rootlb}

    Wait For Cloudlet Status Offline  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    Wait For Cloudlet Status Online  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  timeout=600

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  num_tries=90  app_name=${app_name_default}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}  app_name=${app_name_default}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}
 
*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  #flavor_name=${cluster_flavor_name}
        Log To Console  Done Creating Cluster Instance
    END

    ${rootlb}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_crm}-${operator_name_crm}  ${region}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}
