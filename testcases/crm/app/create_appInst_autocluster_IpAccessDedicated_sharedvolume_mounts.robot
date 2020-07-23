*** Settings ***
Documentation  Autocluster Shared Volume Mounts 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
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

${region}  EU

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

#${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_volumemount.yml
${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_shared_volumemount.yml
${manifest_pod_name}=  server-ping-threaded-udptcphttp
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-2158
Shall be able to configure IpAccessDedicated k8s autocluster with shared volume mounts
    [Documentation]
    ...  deploy IpAccessDedicated k8s autocluster app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${time}=  Get Time  epoch

    ${rootlb}=  Catenate  SEPARATOR=.  autocluster${time}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App           region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015  deployment=kubernetes  deployment_manifest=${manifest_url}
    ${app_name_default}=  Get Default App Name
    log to console  ${app_name_default}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=autocluster${time}  autocluster_ip_access=IpAccessDedicated  shared_volume_size=10

    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=autocluster${time}  operator_name=${operator_name_openstack}  pod_name=${manifest_pod_name}

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  autocluster${time}
    ${server_info_node}=    Get Server List  name=${openstack_node_name}

#    Write File to Node  root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}  data=autocluster${time}  mount=/share

    Mount Should Persist  root_loadbalancer=${rootlb}  pod_name=${manifest_pod_name}  mount=/data  cluster_name=autocluster${time}  operator_name=${operator_name_openstack}

*** Keywords ***
Setup
    Create Flavor     region=${region}
