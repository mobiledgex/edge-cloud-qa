*** Settings ***
Documentation  Cluster Creation 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  auto_login=${False}
#Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}  auto_login=${False}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  String
	
Test Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout} 
	
*** Variables ***
${cloudlet_name}  automationBonnCloudlet
${operator_name}  TDG 
${mobiledgex_domain}  mobiledgex.net
${cluster_name}  cluster
${s_timeout}  1200

${region}=  EU
	
*** Test Cases ***
ClusterInst shall create with IpAccessDedicated/docker for Direct App
   [Documentation]
   ...  create a cluster with IpAccessDedicated and deploymenttype=docker
   ...  verify it creates lb only
   ...  verify cluster is used for error case to test Direct App no longer supported
   [Tags]  cluster  docker  dedicated  direct  create

   Log to Console  \nCreating docker dediciated IP cluster instance

   ${cluster_name_dockerdedicateddirect_starttime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockerdedicateddirect_starttime}

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor_name_small}  developer_org_name=${developer_organization_name}  timeout=${s_timeout}
   ${cluster_name_dockerdedicateddirect_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockerdedicateddirect_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_small}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       1  #IpAccessDedicated
   Should Be Equal             ${cluster_inst['data']['deployment']}      docker
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_small}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
#  These lines have been replaced with line above for vsphere or openstack # Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_small}

ClusterInst shall create with IpAccessDedicated/docker for LB App
   [Documentation]
   ...  create a cluster with IpAccessDedicated and deploymenttype=docker
   ...  verify it creates lb only
   [Tags]  cluster  docker  dedicated  loadbalancer  create

   Log to Console  \nCreating docker dediciated IP cluster instance

   ${cluster_name_dockerdedicatedlb_starttime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockerdedicatedlb_starttime}

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor_name_small}  developer_org_name=${developer_organization_name}  timeout=${s_timeout}
   ${cluster_name_dockerdedicatedlb_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockerdedicatedlb_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_small}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       1  #IpAccessDedicated
   Should Be Equal             ${cluster_inst['data']['deployment']}      docker
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_small}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
#   Should Be Equal             ${cluster_inst['data']['node_flavor']}     ${node_flavor_name_small}

ClusterInst shall create with IpAccessShared/docker for LB App
   [Documentation]
   ...  create a cluster with IpAccessShared and deploymenttype=docker
   ...  verify it creates lb only
   [Tags]  cluster  docker  shared  loadbalancer  create

   Log to Console  \nCreating docker shared IP cluster instance

   ${cluster_name_dockershared_starttime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockersharedlb_starttime}

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessShared  deployment=docker  flavor_name=${flavor_name_medium}  developer_org_name=${developer_organization_name}  timeout=${s_timeout}
   ${cluster_name_dockersharedlb_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockersharedlb_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_medium}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       3  #IpAccessShared
   Should Be Equal             ${cluster_inst['data']['deployment']}      docker
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_medium}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
#   Should Be Equal             ${cluster_inst['data']['node_flavor']}     ${node_flavor_name_medium}

ClusterInst shall create with IpAccessDedicated/K8s for LB App and num_masters=1 and num_nodes=1
   [Documentation]
   ...  create a cluster with IpAccessDedicated and deploymenttype=k8s and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master
   [Tags]  cluster  k8s  dedicated  loadbalancer  create

   Log to Console  \nCreating k8s dedicated IP cluster instance

   ${cluster_name_k8sdedicatedlb_starttime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8sdedicatedlb_starttime}

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=1  number_masters=1  ip_access=IpAccessDedicated  deployment=kubernetes  flavor_name=${flavor_name_large}  developer_org_name=${developer_organization_name}  timeout=${s_timeout}
   ${cluster_name_k8sdedicatedlb_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8sdedicatedlb_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_large}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       1  #IpAccessDedicated
   Should Be Equal             ${cluster_inst['data']['deployment']}      kubernetes
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Should Be Equal As Numbers  ${cluster_inst['data']['num_masters']}     1
   Should Be Equal As Numbers  ${cluster_inst['data']['num_nodes']}       1
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_large}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_large}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
#   Should Be Equal             ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_large}
#   Should Be Equal             ${cluster_inst['data']['node_flavor']}         ${node_flavor_name_large}

ClusterInst shall create with IpAccessShared/K8s for LB App and num_masters=1 and num_nodes=1
   [Documentation]
   ...  create a cluster with IpAccessShared and deploymenttype=k8s and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master
   [Tags]  cluster  k8s  shared  loadbalancer  create

   Log to Console  \nCreating k8s shared IP cluster instance

   ${cluster_name_k8ssharedlb_starttime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8ssharedlb_starttime}

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  flavor_name=${flavor_name_small}  developer_org_name=${developer_organization_name}  timeout=${s_timeout}
   ${cluster_name_k8ssharedlb_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8ssharedlb_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_small}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       3  #IpAccessShared
   Should Be Equal             ${cluster_inst['data']['deployment']}      kubernetes
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Should Be Equal As Numbers  ${cluster_inst['data']['num_masters']}     1
   Should Be Equal As Numbers  ${cluster_inst['data']['num_nodes']}       1
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_small}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_small}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
#   Should Be Equal             ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_small}
#   Should Be Equal             ${cluster_inst['data']['node_flavor']}         ${node_flavor_name_small}

ClusterInst shall create with K8s and sharedvolumesize
   [Documentation]
   ...  create a cluster with IpAccessShared and deploymenttype=k8s and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master
   [Tags]  cluster  k8s  shared  create  sharedvolumesize

   Log to Console  \nCreating k8s shared IP cluster instance for sharedvolumesize

   ${cluster_name_k8ssharedvolumesize_starttime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8ssharedvolumesize_starttime}

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8ssharedvolumesize}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  shared_volume_size=1  flavor_name=${flavor_name_small}  developer_org_name=${developer_organization_name}  timeout=${s_timeout}
   ${cluster_name_k8ssharedvolumesize_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8ssharedvolumesize_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_small}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       3  #IpAccessShared
   Should Be Equal             ${cluster_inst['data']['deployment']}      kubernetes
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Should Be Equal As Numbers  ${cluster_inst['data']['num_masters']}     1
   Should Be Equal As Numbers  ${cluster_inst['data']['num_nodes']}       1
   Should Be Equal As Numbers  ${cluster_inst['data']['shared_volume_size']}  1
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_small}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_small}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
#   Should Be Equal             ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_small}
#   Should Be Equal             ${cluster_inst['data']['node_flavor']}         ${node_flavor_name_small}

ClusterInst shall create with IpAccessDedicated/docker and GPU
   [Documentation]
   ...  create a gpu cluster with IpAccessDedicated and deploymenttype=docker
   ...  verify it creates vm with gpu flavor
   [Tags]  cluster  docker  dedicated  gpu  create

   Log to Console  \nCreating GPU docker dedicated IP cluster instance

   ${cluster_name_dockerdedicatedgpu_starttime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockerdedicatedgpu_starttime}

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_dockerdedicatedgpu}   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor_name_gpu}  developer_org_name=${developer_organization_name}  timeout=${s_timeout}
   ${cluster_name_dockerdedicatedgpu_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockerdedicatedgpu_endtime}

   Log to Console  \nCreating GPU cluster instance done

   # verify gpu_flavor
   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_gpu}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       1  #IpAccessDedicated
   Should Be Equal             ${cluster_inst['data']['deployment']}      docker
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_gpu}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
#   Should Be Equal             ${cluster_inst['data']['node_flavor']}     ${node_flavor_name_gpu}

ClusterInst shall create with IpAccessShared/K8s and GPU and num_masters=1 and num_nodes=1
   [Documentation]
   ...  create a GPU cluster with IpAccessShared and deploymenttype=k8s and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master
   [Tags]  cluster  k8s  shared  gpu  create

   Log to Console  \nCreating GPU k8s shared IP cluster instance

   ${cluster_name_k8ssharedgpu_starttime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8ssharedgpu_starttime}

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8ssharedgpu}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  flavor_name=${flavor_name_gpu}  developer_org_name=${developer_organization_name}  timeout=${s_timeout}
   ${cluster_name_k8ssharedgpu_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8ssharedgpu_endtime}

   Log to Console  \nCreating GPU cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_gpu}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       3  #IpAccessShared
   Should Be Equal             ${cluster_inst['data']['deployment']}      kubernetes
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Should Be Equal As Numbers  ${cluster_inst['data']['num_masters']}     1
   Should Be Equal As Numbers  ${cluster_inst['data']['num_nodes']}       1
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_gpu}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    Should Be Equal    ${cluster_inst['data']['node_flavor']}  ${node_flavor_name_gpu}     ELSE  Log to Console  \nSkipping node new flavor check Vsphere detected
#   Should Be Equal             ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_gpu}
#   Should Be Equal             ${cluster_inst['data']['node_flavor']}         ${node_flavor_name_gpu}

*** Keywords ***
Setup
   Login  username=${username_developer}  password=${password_developer}
   ${flavor_name}=   Get Default Flavor Name
   Set Suite Variable  ${flavor_name}


