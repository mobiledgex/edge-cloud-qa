*** Settings ***
Documentation  IaaS 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  MexApp
Library  String

Suite Setup      Setup

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack}  automationMunichCloudlet
${operator_name_openstack}  TDG
${mobiledgex_domain}  mobiledgex.net
${region}  EU

${manifest_pod_name}=  server-ping-threaded-udptcphttp

${test_timeout_crm}  32 min

*** Test Cases ***
User shall be able to access block storage to a VM 
   [Documentation]
   ...  do RunCommand on k8s shared app 
   ...  verify RunCommand works 
   [Tags]  k8s  sharedvolumesize

   ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
   ${rootlb}=  Convert To Lowercase  ${rootlb}
   ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack}

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_k8ssharedvolumesize}  ${rootlb}

   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_k8ssharedvolumesize}
   ${server_info_node}=    Get Server List  name=${openstack_node_name}

   Write File to Node  root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}  data=${cluster_name_k8ssharedvolumesize}  mount=/share

   Mount Should Persist  root_loadbalancer=${rootlb}  pod_name=${manifest_pod_name}  mount=/data  cluster_name=${cluster_name_k8ssharedvolumesize}  operator_name=${operator_name_openstack}

*** Keywords ***
Setup
   ${token}=  Login

   Set Suite Variable  ${token}   
