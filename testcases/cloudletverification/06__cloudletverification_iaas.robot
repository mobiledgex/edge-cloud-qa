*** Settings ***
Documentation  IaaS 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  auto_login=${False}
#Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
#Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  MexApp
Library  String

Suite Setup      Setup

Test Timeout    ${test_timeout} 
	
*** Variables ***
${cloudlet_name}  automationSunnydaleCloudlet
${operator_name}  GDDT
${mobiledgex_domain}  mobiledgex.net
${region}  EU

${manifest_pod_name}=  server-ping-threaded-udptcphttp

#${test_timeout_crm}  32 min

*** Test Cases ***
User shall be able to access block storage to a VM 
   [Documentation]
   ...  do RunCommand on k8s shared app 
   ...  verify RunCommand works 
   [Tags]  k8s  sharedvolumesize  oscmd

   ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name}  ${operator_name}  ${mobiledgex_domain}
   ${rootlb}=  Convert To Lowercase  ${rootlb}
   ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name}

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_k8ssharedvolumesize}  ${rootlb}

   ${node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_k8ssharedvolumesize}

   ${run_debug_out}=    Run Debug  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  node_type=crm  command=oscmd  args=openstack server list --name ${node_name} -f json
   @{server_info_node}=    evaluate    json.loads('''${run_debug_out['data']['output']}''')    json

   #${server_info_node}=    Get Server List  name=${node_name}

   Write File to Node  root_loadbalancer=${rootlb}  node=${server_info_node[0]['Networks']}  data=${cluster_name_k8ssharedvolumesize}  mount=/share

   Mount Should Persist  root_loadbalancer=${rootlb}  pod_name=${manifest_pod_name}  mount=/data  cluster_name=${cluster_name_k8ssharedvolumesize}  operator_name=${operator_name}

*** Keywords ***
Setup
   ${token}=  Login  username=${username_mexadmin}  password=${password_mexadmin}

   Set Suite Variable  ${token}   
