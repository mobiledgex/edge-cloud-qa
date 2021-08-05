*** Settings ***
Documentation  VGPU docker app on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_VGPU_ENV}
Library  MexApp
Library  String
Library  OperatingSystem
Library  Process

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${region}=  EU
${vgpu_resource_name}  myvgpuresource
${gpu_resource_name}  mygpuresrouce

${cloudlet_name_openstack_vgpu}  automationParadiseCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

${docker_compose_url}=  http://35.199.188.102/apps/automation_configs_gpu_compose.yml
${docker_gpu}  docker.mobiledgex.net/mobiledgex-samples/images/computervision-gpu:no-pose-2020-10-28
${openstack_flavor_name}  m4.large-vgpu	
${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-3674
VGPU - shall be able to deploy docker shared NVidia VGPU app on KVM Openstack
    [Documentation]
    ...  - deploy docker shared cluster with VGPU support on openstack
    ...  - verify app uses the GPU for Object Detection
    ...  - verify License is acquired from license server

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_vgpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker  developer_org_name=MobiledgeX-Samples
    ${openstack_node_name}=    Catenate  SEPARATOR=-  mex-docker-vm  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_node_name}

    Create App  region=${region}  image_path=${docker_gpu}  access_ports=tcp:8008:tls,tcp:8011  image_type=ImageTypeDocker  deployment=docker  skip_hc_ports=tcp:8011  developer_org_name=MobiledgeX-Samples
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_vgpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=MobiledgeX-Samples

    Register Client  developer_org_name=MobiledgeX-Samples
    ${cloudlet}=  Find Cloudlet	 latitude=${latitude}  longitude=${longitude}

    ${rootlb_ip}=  Wait For DNS  ${cloudlet.fqdn}

    Sleep  30 s

    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    Run Process   curl -k -X POST https://${rootlb_ip}:8008/object/detect/ -F image\=@Bruce.jpg  shell=True  stdout=${outfile}  stderr=STDOUT
    ${output}=  Get File  ${outfile}
    Log To Console  ${output}
    Should Contain  ${output}  "gpu_support": true

    ${output}=  Run Command on Clustervm  root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}  command=systemctl status nvidia-gridd
    Log To Console  ${output}
    ${length}=  Get Length  ${output}
    Should Contain  ${output[2]}   Active: active (running)

    ${output}=  Run Command on Clustervm  root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}  command=sudo cat /var/log/syslog|grep gridd
    Log To Console  ${output}
    Should Contain  ${output[-1]}  nvidia-gridd: License acquired successfully

*** Keywords ***
Setup
    Create Flavor  region=${region}  disk=80  optional_resources=gpu=resources:VGPU:1

    Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name_openstack_vgpu}  operator_org_name=${operator_name_openstack}  mapping=gpu=${vgpu_resource_name}
    #Add Resource Tag  region=${region}  resource_name=${vgpu_resource_name}  operator_org_name=${operator_name_openstack}  tags=resources=VGPU=1

    ${cloudlet_show}=  Show Cloudlets  region=${region}  cloudlet_name=${cloudlet_name_openstack_vgpu}  operator_org_name=${operator_name_openstack}

    Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack_vgpu}  gpudriver_name=nvidia-450v  gpudriver_org=${operator_name_openstack}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_vgpu}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_vgpu}

    Set Suite Variable  ${cloudlet_lowercase}
    Set Suite Variable  ${rootlb}

Teardown
    Cleanup Provisioning
    Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack_vgpu}  gpudriver_name=nvidia-450  gpudriver_org=${operator_name_openstack}
    Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name_openstack_vgpu}  operator_org_name=${operator_name_openstack}  mapping=gpu=${gpu_resource_name}
