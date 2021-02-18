*** Settings ***
Documentation  IpAccessShared Shared Volume Mounts 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationBonnCloudlet
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
# ECQ-1907
Shall be able to configure IpAccessShared k8s cluster/app with shared volume mounts
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_shared}

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared  number_nodes=1  shared_volume_size=1
    Log To Console  Done Creating Cluster Instance

    Create App           region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015  deployment_manifest=${manifest_url}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${manifest_pod_name}

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_node_name}

    Write File to Node  node=${server_info_node[0]['Networks']}  data=${cluster_name_default}  mount=/share 

    Mount Should Persist  pod_name=${manifest_pod_name}  mount=/data  cluster_name=${cluster_name_default}	operator_name=${operator_name_openstack}

*** Keywords ***
Setup
    Create Flavor     region=${region}
