*** Settings ***
Documentation  IpAccessDedicated Shared Volume Mounts 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
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

${latitude}       32.7767
${longitude}      -96.7970
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-1908
Shall be able to configure IpAccessDedicated k8s cluster/app with shared volume mounts
    [Documentation]
    ...  - deploy IpAccessDedicated cluster and app with manifest with shared volume mounts
    ...  - verify mounts are persisted over pod restart

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}-${operator_name_openstack}  ${region}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}-${developer_org_name_automation}  ${rootlb}
    ${clusterlb}=  Replace String  ${clusterlb}  _  -    

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_crm}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=1  shared_volume_size=1
    Log To Console  Done Creating Cluster Instance

    Create App           region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015  deployment_manifest=${manifest_url}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_org_name=${operator_name_openstack}  pod_name=${manifest_pod_name}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${write_return}=  Write To App Volume Mount  host=${cloudlet.fqdn}  port=${cloudlet.ports[0].public_port}  data=${cluster_name_default}
    Should Be Equal  ${write_return[1]}  ${cluster_name_default}

    #Write File to Node  root_loadbalancer=${clusterlb}  node=${server_info_node[0]['Networks']}  data=${cluster_name_default}  mount=/share

    #Mount Should Persist  root_loadbalancer=${clusterlb}  pod_name=${manifest_pod_name}  mount=/data  cluster_name=${cluster_name_default}      operator_name=${operator_name_openstack}

    Delete Pod  root_loadbalancer=${clusterlb}  pod_name=${manifest_pod_name}  cluster_name=${cluster_name_default}     operator_name=${operator_name_openstack}

    ${write_return}=  Write To App Volume Mount  host=${cloudlet.fqdn}  port=${cloudlet.ports[0].public_port}  data=${cluster_name_default}
    Should Be Equal  ${write_return[1]}  ${cluster_name_default}

*** Keywords ***
Setup
    #${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}

    Create Flavor     region=${region}
