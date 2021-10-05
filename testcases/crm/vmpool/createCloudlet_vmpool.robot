*** Settings ***
Documentation  CreateCloudlet for VM Pools

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_VMPOOL_ENV}
Library  Collections
Library  String

Suite Setup  Setup
#Suite Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${operator_organization}=  TDG
${vmpool_server_name}=  automationvmpool
#${vmpool_server_name}=  vmpoolvm

${physical_name}=  bonn

${cloudlet_name_vmpool}=  automationVMPoolCloudlet
${vmpool_name}=  automationVMPool

${region}=  US

*** Test Cases ***
# ECQ-2314
CreateCloudlet - shall be able to create in vm pool
   [Documentation]
   ...  - create a vmpool based on openstack
   ...  - send CreateCloudlet for a VM Pool
   ...  - verify vmpool contains the cloudlet

   #${pool_name}=  Get Default VM Pool Name
   ${org_name}=   Get Default Organization Name

   ${pool_return}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_organization}  vm_pool=${vmpool_name}  platform_type=PlatformTypeVmPool  physical_name=${physical_name}  #container_version=2020-08-03-1  override_policy_container_version=${True}  env_vars=MEX_EXT_NETWORK=external-network-02

   Should Be Equal As Integers   ${pool_return['data']['platform_type']}  9  # VMPool
   Should Be Equal As Integers  ${pool_return['data']['state']}  5  # Ready
   Should Be Equal              ${pool_return['data']['vm_pool']}  ${vmpool_name}  

   ${operator_organization_lc}=  Convert To Lowercase  ${operator_organization}

   ${group_name}=  Set Variable  ${pool_return['data']['key']['name']}-${operator_organization}-pf
   ${internal_name}=  Set Variable  ${pool_return['data']['key']['name']}.${operator_organization_lc}.mobiledgex.net
   ${internal_name}=  Convert To Lowercase  ${internal_name}

   VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_organization}  group_name=${group_name}  internal_name=${group_name}
   VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_organization}  group_name=${internal_name}  internal_name=${internal_name}
 
   #${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_organization}

   #Should Contain   ${error}  code=400
   #Should Contain   ${error}  error={"message":"VM pool in use by Cloudlet"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${server_list}=  Get Server List  ${vmpool_server_name}
   @{pool_list}=  Create List
   FOR  ${i}  IN  @{server_list}
      ${net0}  ${net1}=  Split String  ${i['Networks']}  separator=;
      ${net0}=  Strip String  ${net0}
      ${net1}=  Strip String  ${net1}
      @{ip0}=  Split String  ${net0}  separator==
      @{ip1}=  Split String  ${net1}  separator==
      &{ipdict}=  Create Dictionary  ${ip0[0]}  ${ip0[1]}  ${ip1[0]}  ${ip1[1]}

      #&{vm1}=  Create Dictionary  name=${i['Name']}  external_ip=${ext_ip[1]}  internal_ip=${int_ip[1]}
      &{vm1}=  Create Dictionary  name=${i['Name']}  external_ip=${ipdict['external-network-02']}  internal_ip=${ipdict['mex-k8s-net-1']}

      Append To List  ${pool_list}  ${vm1}       
   END 

   Run Keyword and Ignore Error  Delete VM Pool  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_organization}
   ${pool_return1}=  Create VM Pool  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_organization}  vm_list=${pool_list}

   Set Suite Variable  ${pool_return1}

