*** Settings ***
Documentation  Cluster Creation 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  String
	
Test Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout} 
	
*** Variables ***
${cloudlet_name_openstack}  automationBonnCloudlet
${operator_name_openstack}  TDG 
${mobiledgex_domain}  mobiledgex.net
${cluster_name}  cluster

${test_timeout_crm}  32 min

${region}=  EU
	
*** Test Cases ***
ClusterInst shall create with IpAccessDedicated/docker on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and deploymenttype=docker
   ...  verify it creates lb only
   [Tags]  docker  dedicated  create

   Log to Console  \nCreating docker dediciated IP cluster instance

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker
   ${cluster_name_dockerdedicated_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockerdedicated_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       1  #IpAccessDedicated
   Should Be Equal             ${cluster_inst['data']['deployment']}      docker
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready

ClusterInst shall create with IpAccessShared/docker on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deploymenttype=docker
   ...  verify it creates lb only
   [Tags]  docker  shared  create

   Log to Console  \nCreating docker shared IP cluster instance

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker
   ${cluster_name_dockershared_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_dockershared_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       3  #IpAccessShared
   Should Be Equal             ${cluster_inst['data']['deployment']}      docker
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready

ClusterInst shall create with IpAccessDedicated/K8s and num_masters=1 and num_nodes=1 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and deploymenttype=k8s and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master
   [Tags]  k8s  dedicated  create

   Log to Console  \nCreating k8s dedicated IP cluster instance

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessDedicated  deployment=kubernetes
   ${cluster_name_k8sdedicated_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8sdedicated_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       1  #IpAccessDedicated
   Should Be Equal             ${cluster_inst['data']['deployment']}      kubernetes
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Should Be Equal As Numbers  ${cluster_inst['data']['num_masters']}     1
   Should Be Equal As Numbers  ${cluster_inst['data']['num_nodes']}       1

ClusterInst shall create with IpAccessShared/K8s and num_masters=1 and num_nodes=1 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deploymenttype=k8s and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master
   [Tags]  k8s  shared  create

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  \nCreating k8s shared IP cluster instance

   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes
   ${cluster_name_k8sshared_endtime}=  Get Time  epoch
   Set Global Variable  ${cluster_name_k8sshared_endtime}

   Log to Console  \nCreating cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       3  #IpAccessShared
   Should Be Equal             ${cluster_inst['data']['deployment']}      kubernetes
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Should Be Equal As Numbers  ${cluster_inst['data']['num_masters']}     1
   Should Be Equal As Numbers  ${cluster_inst['data']['num_nodes']}       1


*** Keywords ***
Setup
   #${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

#   ${cluster_name_dockerdedicated}=  Catenate  SEPARATOR=  ${cluster_name}  dockerdedicated
#   ${cluster_name_dockershared}=  Catenate  SEPARATOR=  ${cluster_name}  dockershared

#   ${cluster_name_k8sdedicated}=  Catenate  SEPARATOR=  ${cluster_name}  k8sdedicated
#   ${cluster_name_k8sshared}=  Catenate  SEPARATOR=  ${cluster_name}  k8sshared

#   Set Suite Variable  ${cluster_name_dockerdedicated}
#   Set Suite Variable  ${cluster_name_dockershared}

#   Set Suite Variable  ${cluster_name_k8sdedicated}
#   Set Suite Variable  ${cluster_name_k8sshared}

   #Set Suite Variable  ${cluster_name}
   Set Suite Variable  ${flavor_name}

