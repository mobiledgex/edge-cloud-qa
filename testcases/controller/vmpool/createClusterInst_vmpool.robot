*** Settings ***
Documentation  DeleteVMPool failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  Collections
Library  String

Test Setup  Setup
#Suite Teardown  Teardown

*** Variables ***
${organization}=  MobiledgeX
${operator_name_vmpool}=  TDG
${vmpool_server_name}=  vmpoolvm
${physical_name}=  berlin

${cloudlet_name_vmpool}=  cloudlet1595967146-891194
${vmpool_name}=  vmpool1595967146-891194

${region}=  US

*** Test Cases ***
ClusterInst shall create with VMPool IpAccessDedicated/docker
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received


   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=docker
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_lb}=  Set Variable  ${cluster_inst['data']['key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_lb}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_vm}

   @{vm_list}=  Append To List  ${vm_list}  ${vm1}  ${vm2}

   [Teardown]  Teardown  ${vm_list}

ClusterInst shall create with VMPool IpAccessShared/docker
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=docker
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_vm}
   
   @{vm_list}=  Append To List  ${vm_list}  ${vm1}

   [Teardown]  Teardown  ${vm_list}

ClusterInst shall create with VMPool IpAccessShared/k8s nummasters=1 numnodes=1
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=1
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_node}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node}

   @{vm_list}=  Append To List  ${vm_list}  ${vm1}  ${vm2}

   [Teardown]  Teardown  ${vm_list}

ClusterInst shall create with VMPool IpAccessDedicated/k8s nummasters=1 numnodes=1
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=kubernetes  number_masters=1  number_nodes=1
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_lb}=  Set Variable  ${cluster_inst['data']['key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_node}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node}
   ${vm3}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_lb}

   @{vm_list}=  Append To List  ${vm_list}  ${vm1}  ${vm2}  ${vm3}

   [Teardown]  Teardown  ${vm_list}

ClusterInst shall create with VMPool IpAccessShared/k8s nummasters=1 numnodes=0
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=0
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}

   @{vm_list}=  Append To List  ${vm_list}  ${vm1}

   [Teardown]  Teardown  ${vm_list}

ClusterInst shall create with VMPool IpAccessShared/k8s nummasters=1 numnodes=2
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=2
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_node1}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_node2}=  Set Variable  mex-k8s-node-2-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node1}
   ${vm3}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node2}

   @{vm_list}=  Append To List  ${vm_list}  ${vm1}  ${vm2}  ${vm3}

   [Teardown]  Teardown  ${vm_list}
 
*** Keywords ***
Setup
   Create Flavor  region=${region}
   
   #${token}=  Get Super Token
   #Set Suite Variable  ${token}

   #${server_list}=  Get Server List  ${vmpool_server_name}
   #@{pool_list}=  Create List
   #FOR  ${i}  IN  @{server_list}
   #   log to console  ${i}
   #   @{net_list}=  Split String  ${i['Networks']}  separator=;
   #   @{ext_ip}=  Split String  ${net_list[0]}  separator==
   #   @{int_ip}=  Split String  ${net_list[1]}  separator==
#
#      &{vm1}=  Create Dictionary  name=${i['Name']}  external_ip=${ext_ip[1]}  internal_ip=${int_ip[1]}
#      Append To List  ${pool_list}  ${vm1}       
#   END 
#
#   ${pool_return1}=  Create VM Pool  region=US  org_name=${operator_organization}  vm_list=${pool_list}
#
#   Set Suite Variable  ${pool_return1}

Teardown
    [Arguments]  ${vm_list}

    Cleanup Provisioning

    FOR  ${v}  IN  @{vm_list}
       VM Should Not Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  vm_name=${v}
    END
