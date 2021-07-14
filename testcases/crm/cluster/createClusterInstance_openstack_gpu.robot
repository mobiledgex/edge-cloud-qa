*** Settings ***
Documentation  GPU allocation  

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_GPU_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_gpu}  automationDusseldorfCloudlet
${operator_name_openstack}  TDG 
${region}  EU
${mobiledgex_domain}  mobiledgex.net
${gpu_resource_name}  mygpuresrouce
 
${openstack_flavor_name}  m4.large-gpu
 
${qcow_centos_image}   https://artifactory-qa.mobiledgex.net/artifactory/repo-ldevorg/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d 

${test_timeout_crm}  15 min

	
*** Test Cases ***
GPU - 1 GPU shall be allocated for K8s IpAccessShared on openstack
   [Documentation]
   ...  create a cluster on openstack with 1 GPU for K8s IpAccessShared
   ...  verify GPU is allocated 

   #EDGECLOUD-1767 - GPU should not be allocated on master node and worker node for k8s h

   ${cluster_name}=  Get Default Cluster Name
 
   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Server List  name=${openstack_node_master}

   # verify master and node have gpu_flavor
   Should Be Equal      ${server_info_node[0]['Flavor']}    ${openstack_flavor_name} 
   Should Not Be Equal  ${server_info_master[0]['Flavor']}  ${openstack_flavor_name} 
   Should Be Equal      ${server_info_node[0]['Status']}    ACTIVE
   Should Be Equal      ${server_info_master[0]['Status']}  ACTIVE

   Should Be Equal              ${cluster_inst['data']['node_flavor']}  ${openstack_flavor_name} 
   Should Be Equal              ${cluster_inst['data']['deployment']}   kubernetes
   Should Be Equal              ${cluster_inst['data']['ip_access']}    IpAccessShared
 
   # verify the NVIDIA is allocated
   Node Should Have GPU      root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}
   Node Should Not Have GPU  root_loadbalancer=${rootlb}  node=${server_info_master[0]['Networks']}

GPU - 1 GPU shall be allocated for K8s IpAccessDedicated on openstack
   [Documentation]
   ...  create a cluster on openstack with 1 GPU for K8s IpAccessDedicated
   ...  verify GPU is allocated

   ${cluster_name}=  Get Default Cluster Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessDedicated  deployment=kubernetes
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_rootlb}=       Catenate  SEPARATOR=.  ${cluster_name}  ${cloudlet_lowercase}

   ${server_info_node}=    Get Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Server List  name=${openstack_node_master}
   ${server_info_rootlb}=  Get Server List  name=${openstack_rootlb}

   # verify master and node have gpu_flavor
   Should Be Equal       ${server_info_node[0]['Flavor']}    ${openstack_flavor_name} 
   Should Not Be Equal   ${server_info_master[0]['Flavor']}  ${openstack_flavor_name} 
   Should Not Be Equal   ${server_info_rootlb[0]['Flavor']}  ${openstack_flavor_name}

   Should Be Equal       ${server_info_node[0]['Status']}    ACTIVE
   Should Be Equal       ${server_info_master[0]['Status']}  ACTIVE
   Should Be Equal       ${server_info_rootlb[0]['Status']}  ACTIVE

   Should Be Equal              ${cluster_inst['data']['node_flavor']}  ${openstack_flavor_name}
   Should Be Equal              ${cluster_inst['data']['deployment']}   kubernetes
   Should Be Equal              ${cluster_inst['data']['ip_access']}    IpAccessDedicated

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}

   # verify the NVIDIA is allocated
   Node Should Have GPU  root_loadbalancer=${clusterlb}  node=${server_info_node[0]['Networks']}
   Node Should Not Have GPU  root_loadbalancer=${clusterlb}  node=${server_info_master[0]['Networks']}
   Node Should Not Have GPU  root_loadbalancer=${clusterlb}  node=${server_info_rootlb[0]['Networks']}

# ECQ-1904
GPU - 1 GPU shall be allocated for Docker IpAccessDedicated on openstack
   [Documentation]
   ...  create a cluster on openstack with 1 GPU for Docker
   ...  verify GPU is allocated

   ${cluster_name}=  Get Default Cluster Name
   ${developer_name}=  Get Default Developer Name
   ${developer_name2}=  Replace String  ${developer_name}  _  -  # replace underscore with dash for openstack lookup

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker
   Log to Console  DONE creating cluster instance

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
   ${clustervm}=  Set Variable  mex-docker-vm-${cloudlet_name_openstack_gpu}-${cluster_name}-${developer_name2}

   ${server_info}=    Get Server List  name=${clusterlb}
   ${server_info_vm}=    Get Server List  name=${clustervm}

   # verify master and node have gpu_flavor
   Should Be Equal  ${server_info[0]['Flavor']}             m4.medium 
   Should Be Equal  ${server_info[0]['Status']}             ACTIVE
   Should Be Equal  ${server_info_vm[0]['Flavor']}             m4.large-gpu
   Should Be Equal  ${server_info_vm[0]['Status']}             ACTIVE
   Should Be Equal  ${cluster_inst['data']['node_flavor']}  ${openstack_flavor_name} 
   Should Be Equal  ${cluster_inst['data']['deployment']}   docker 
  
   # verify the NVIDIA is allocated
   Node Should Have GPU  root_loadbalancer=${clusterlb}  node=${server_info_vm[0]['Networks']}

# ECQ-1905
GPU - 1 GPU shall be allocated for Docker IpAccessShared on openstack
   [Documentation]
   ...  create a cluster on openstack with 1 GPU for docker IpAccessShared
   ...  verify GPU is allocated

   #EDGECLOUD-1767 - GPU should not be allocated on master node and worker node for k8s h

   ${cluster_name}=  Get Default Cluster Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Server List  name=mex-docker-vm-${cloudlet_lowercase}-${cluster_name}

   # verify master and node have gpu_flavor
   Should Be Equal      ${server_info_node[0]['Flavor']}    ${openstack_flavor_name}
   Should Be Equal      ${server_info_node[0]['Status']}    ACTIVE

   Should Be Equal              ${cluster_inst['data']['node_flavor']}  ${openstack_flavor_name}
   Should Be Equal              ${cluster_inst['data']['deployment']}   docker
   Should Be Equal              ${cluster_inst['data']['ip_access']}    IpAccessShared

   Sleep  15s

   # verify the NVIDIA is allocated
   Node Should Have GPU      root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}

# ECQ-1902
GPU - no GPU shall be allocated if gpu not specified for K8s IpAccessShared on openstack
   [Documentation]
   ...  create a cluster on openstack without specifying the gpu option for k8s shared 
   ...  verify GPU is not allocated

   ${time}=  Get Time  epoch

   Create Flavor  region=${region}  flavor_name=flavor${time}  ram=8192  vcpus=4  disk=50 

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Server List  name=${openstack_node_master}

   # verify master and node have gpu_flavor
   Should Not Be Equal  ${server_info_node[0]['Flavor']}    gpu_flavor
   Should Not Be Equal  ${server_info_master[0]['Flavor']}  gpu_flavor
   Should Be Equal      ${server_info_node[0]['Status']}    ACTIVE
   Should Be Equal      ${server_info_master[0]['Status']}  ACTIVE

   Should Not Be Equal          ${cluster_inst['data']['node_flavor']}  gpu_flavor
   Should Be Equal              ${cluster_inst['data']['deployment']}   kubernetes
   Should Be Equal              ${cluster_inst['data']['ip_access']}    IpAccessShared


   # verify the NVIDIA is allocated
   Node Should Not Have GPU  root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}
   Node Should Not Have GPU  root_loadbalancer=${rootlb}  node=${server_master_node[0]['Networks']}

# ECQ-1903
GPU - no GPU shall be allocated if gpu not specified for K8s IpAccessDedicated on openstack
   [Documentation]
   ...  create a cluster on openstack without specifying the gpu option for k8s dedicated
   ...  verify GPU is not allocated

   ${time}=  Get Time  epoch

   Create Flavor  region=${region}  flavor_name=flavor${time}  ram=8192  vcpus=4  disk=50

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessDedicated  deployment=kubernetes
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Server List  name=${openstack_node_master}

   # verify master and node have gpu_flavor
   Should Not Be Equal  ${server_info_node[0]['Flavor']}    gpu_flavor
   Should Not Be Equal  ${server_info_master[0]['Flavor']}  gpu_flavor
   Should Be Equal      ${server_info_node[0]['Status']}    ACTIVE
   Should Be Equal      ${server_info_master[0]['Status']}  ACTIVE

   Should Not Be Equal          ${cluster_inst['data']['node_flavor']}  gpu_flavor
   Should Be Equal              ${cluster_inst['data']['deployment']}   kubernetes
   Should Be Equal              ${cluster_inst['data']['ip_access']}    IpAccessDedicated


   # verify the NVIDIA is allocated
   Node Should Not Have GPU  root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}
   Node Should Not Have GPU  root_loadbalancer=${rootlb}  node=${server_master_node[0]['Networks']}

GPU - No GPU shall be allocated if gpu not specified for Docker on openstack
   [Documentation]
   ...  create a cluster on openstack without specifying the gpu option for Docker
   ...  verify GPU is not allocated

   ${time}=  Get Time  epoch

   Create Flavor  region=${region}  flavor_name=flavor${time}  ram=8192  vcpus=4  disk=50

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker
   Log to Console  DONE creating cluster instance

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}

   ${server_info}=    Get Server List  name=${clusterlb}

   # verify master and node have gpu_flavor
   Should Not Be Equal   ${server_info[0]['Flavor']}  gpu_flavor 
   Should Be Equal       ${server_info[0]['Status']}  ACTIVE

   # verify the NVIDIA is NOT allocated
   Node Should Not Have GPU  root_loadbalancer=${clusterlb}  node=${server_info[0]['Networks']}

GPU - No GPU shall be allocated if gpu not specified for VM on openstack
   [Documentation]
   ...  create a cluster on openstack with 1 GPU for VM
   ...  verify GPU is allocated

   ${time}=  Get Time  epoch

   Create Flavor  region=${region}  flavor_name=flavor${time}  disk=50 

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name
   ${app_name}=      Get Default App Name

   Log to Console  START creating VM instance
   Create App  region=${region}  image_type=ImageTypeQCOW  deployment=vm  developer_org_name=mobiledgex  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015
   ${app_inst}=  Create App Instance  region=${region}  developer_org_name=mobiledgex  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}
   Log to Console  DONE creating VM instance

   ${server_info}=    Get Server List  name=mobiledgex${app_name}

   # verify master and node have gpu_flavor
   Should Be Equal  ${server_info[0]['Flavor']}             gpu_flavor
   Should Be Equal  ${server_info[0]['Status']}             ACTIVE
   Should Be Equal  ${cluster_inst['data']['node_flavor']}  gpu_flavor
   Should Be Equal  ${cluster_inst['data']['deployment']}   docker

   # verify the NVIDIA is allocated
   Node Should Have GPU  root_loadbalancer=${clusterlb}  node=${server_info[0]['Networks']}

GPU - 1 GPU shall be allocated for each node for K8s IpAccessShared and nodes=2 on openstack
   [Documentation]
   ...  create a cluster on openstack with 1 GPU for K8s IpAccessShared
   ...  verify GPU is allocated

   #EDGECLOUD-1767 - GPU should not be allocated on master node and worker node for k8s h

   ${time}=  Get Time  epoch

   Create Flavor  region=${region}  flavor_name=flavor${time}  optional_resources=gpu=1

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  number_nodes=2  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes
   Log to Console  DONE creating cluster instance

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   ${server_info_node}=    Get Server List  name=${openstack_node_name}
   ${server_info_master}=  Get Server List  name=${openstack_node_master}

   # verify master and node have gpu_flavor
   Should Be Equal      ${server_info_node[0]['Flavor']}    gpu_flavor
   Should Not Be Equal  ${server_info_master[0]['Flavor']}  gpu_flavor
   Should Be Equal      ${server_info_node[0]['Status']}    ACTIVE
   Should Be Equal      ${server_info_master[0]['Status']}  ACTIVE

   Should Be Equal              ${cluster_inst['data']['node_flavor']}  gpu_flavor
   Should Be Equal              ${cluster_inst['data']['deployment']}   kubernetes
   Should Be Equal              ${cluster_inst['data']['ip_access']}    IpAccessShared


   # verify the NVIDIA is allocated
   Node Should Have GPU      root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}
   Node Should Not Have GPU  root_loadbalancer=${rootlb}  node=${server_master_node[0]['Networks']}

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_gpu}

    Set Suite Variable  ${cloudlet_lowercase}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_gpu}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Create Flavor  region=${region}  disk=80  optional_resources=gpu=pci:1

    Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  mapping=gpu=${gpu_resource_name}
    Add Resource Tag  region=${region}  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack}  tags=pci=t4gpu:1

    Set Suite Variable  ${rootlb}
