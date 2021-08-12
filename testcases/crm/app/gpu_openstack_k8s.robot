*** Settings ***
Documentation  GPU k8s app on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_GPU_ENV}
Library  MexApp
Library  String
Library  OperatingSystem
Library  Process

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${region}=  EU
${gpu_resource_name}  mygpuresrouce

${cluster_flavor_name}  x1.medium

${cloudlet_name_openstack_gpu}  automationParadiseCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

${k8s_manifest_url}=  http://35.199.188.102/apps/k8s-computervision-gpu.yaml
${k8s_gpu}  docker.mobiledgex.net/mobiledgex-samples/images/computervision-gpu:no-pose-2020-10-28
${openstack_flavor_name}  m4.small-gpu	
${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-3670
GPU - shall be able to deploy k8s shared NVidia T4 Passthru GPU app on KVM Openstack
    [Documentation]
    ...  - deploy k8s shared cluster with GPU support on openstack
    ...  - verify app uses the GPU for Object Detection

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=kubernetes  developer_org_name=MobiledgeX-Samples
    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}
    ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name_default}

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${server_info_master}=  Get Server List  name=${openstack_node_master}

    # verify master and node have gpu_flavor
    Should Be Equal      ${server_info_node[0]['Flavor']}    ${openstack_flavor_name}
    Should Not Be Equal  ${server_info_master[0]['Flavor']}  ${openstack_flavor_name}
    Should Be Equal      ${server_info_node[0]['Status']}    ACTIVE
    Should Be Equal      ${server_info_master[0]['Status']}  ACTIVE

    Should Be Equal              ${cluster_inst['data']['node_flavor']}  ${openstack_flavor_name}
    Should Be Equal              ${cluster_inst['data']['deployment']}   kubernetes
    Should Be Equal As Integers  ${cluster_inst['data']['ip_access']}    3

    # verify the NVIDIA is allocated
    Node Should Have GPU      root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}
    Node Should Not Have GPU  root_loadbalancer=${rootlb}  node=${server_info_master[0]['Networks']}

    Create App  region=${region}  image_path=${k8s_gpu}  access_ports=tcp:8008:tls,tcp:8011  image_type=ImageTypeDocker  deployment=kubernetes  skip_hc_ports=tcp:8011  developer_org_name=MobiledgeX-Samples
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=MobiledgeX-Samples

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

# ECQ-3671
GPU - shall be able to deploy k8s dedicated NVidia T4 Passthru GPU app on KVM Openstack
    [Documentation]
    ...  - deploy k8s dedicated cluster with GPU support on openstack
    ...  - verify app uses the GPU for Object Detection

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=kubernetes  developer_org_name=MobiledgeX-Samples
    Sleep  30  seconds
    Create App  region=${region}  image_path=${k8s_gpu}  access_ports=tcp:8008:tls,tcp:8011  image_type=ImageTypeDocker  deployment=kubernetes  skip_hc_ports=tcp:8011  developer_org_name=MobiledgeX-Samples
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=MobiledgeX-Samples

    Register Client  developer_org_name=MobiledgeX-Samples
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    ${rootlb_ip}=  Wait For DNS  ${cloudlet.fqdn}

    Sleep  30 s

    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    Run Process   curl -k -X POST https://${rootlb_ip}:8008/object/detect/ -F image\=@Bruce.jpg  shell=True  stdout=${outfile}  stderr=STDOUT
    ${output}=  Get File  ${outfile}
    Log To Console  ${output}

    Should Contain  ${output}  "gpu_support": true

# ECQ-3672
GPU - shall be able to deploy k8s reservable autocluster NVidia T4 Passthru GPU app on KVM Openstack
    [Documentation]
    ...  - deploy k8s reservable autocluster with GPU support on openstack
    ...  - verify app uses the GPU for Object Detection

    ${cluster_name_default}=  Get Default Cluster Name
    ${cluster_name_default}=  Catenate  SEPARATOR=  autocluster  ${cluster_name_default}
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  image_path=${k8s_gpu}  access_ports=tcp:8008:tls,tcp:8011  image_type=ImageTypeDocker  deployment=kubernetes  skip_hc_ports=tcp:8011  developer_org_name=MobiledgeX-Samples
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=MobiledgeX-Samples

    Register Client  developer_org_name=MobiledgeX-Samples
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    ${rootlb_ip}=  Wait For DNS  ${cloudlet.fqdn}

    Sleep  30 s

    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    Run Process   curl -k -X POST https://${rootlb_ip}:8008/object/detect/ -F image\=@Bruce.jpg  shell=True  stdout=${outfile}  stderr=STDOUT
    ${output}=  Get File  ${outfile}
    Log To Console  ${output}

    Should Contain  ${output}  "gpu_support": true

# ECQ-3693
GPU - shall be able to deploy k8s NVidia T4 Passthru GPU app on KVM Openstack with user provided deployment manifest
    [Documentation]
    ...  - deploy k8s cluster with GPU support on openstack
    ...  - create app with user defined manifest and deploy app instance
    ...  - verify app uses the GPU for Object Detection

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=kubernetes  developer_org_name=MobiledgeX-Samples
    Sleep  30  seconds
    Create App  region=${region}  deployment_manifest=${k8s_manifest_url}  access_ports=tcp:8008:tls,tcp:8011  image_type=ImageTypeDocker  deployment=kubernetes  skip_hc_ports=tcp:8011  developer_org_name=MobiledgeX-Samples
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=MobiledgeX-Samples

    Register Client  developer_org_name=MobiledgeX-Samples
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    ${rootlb_ip}=  Wait For DNS  ${cloudlet.fqdn}

    Sleep  30 s

    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    Run Process   curl -k -X POST https://${rootlb_ip}:8008/object/detect/ -F image\=@Bruce.jpg  shell=True  stdout=${outfile}  stderr=STDOUT
    ${output}=  Get File  ${outfile}
    Log To Console  ${output}

    Should Contain  ${output}  "gpu_support": true

*** Keywords ***
Setup
    Create Flavor  region=${region}  disk=40  optional_resources=gpu=pci:1

    Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  mapping=gpu=${gpu_resource_name}
    Add Resource Tag  region=${region}  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack}  tags=pci=t4gpu:1

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_gpu}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_gpu}

    Set Suite Variable  ${cloudlet_lowercase}
    Set Suite Variable  ${rootlb}	
