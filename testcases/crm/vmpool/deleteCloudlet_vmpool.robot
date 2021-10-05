*** Settings ***
Documentation  DeleteCloudlet for VM Pools

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_VMPOOL_ENV}
#Library  Collections
#Library  String

#Suite Setup  Setup
#Suite Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${operator_organization}=  TDG
${vmpool_server_name}=  automationvmpool
#${vmpool_server_name}=  vmpoolvm

${physical_name}=  berlin

${cloudlet_name_vmpool}=  automationVMPoolCloudlet
${vmpool_name}=  automationVMPool

${region}=  US

*** Test Cases ***
# ECQ-2332
DeleteCloudlet - shall be able to delete in vm pool
   [Documentation]
   ...  - send DeleteCloudlet for vm pool

   Delete Cloudlet  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_organization} 

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${server_list}=  Get Server List  ${vmpool_server_name}
   @{pool_list}=  Create List
   FOR  ${i}  IN  @{server_list}
      log to console  ${i}
      @{net_list}=  Split String  ${i['Networks']}  separator=;
      @{ext_ip}=  Split String  ${net_list[0]}  separator==
      @{int_ip}=  Split String  ${net_list[1]}  separator==

      &{vm1}=  Create Dictionary  name=${i['Name']}  external_ip=${ext_ip[1]}  internal_ip=${int_ip[1]}
      Append To List  ${pool_list}  ${vm1}       
   END 

   Run Keyword and Ignore Error  Delete VM Pool  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_organization}
   ${pool_return1}=  Create VM Pool  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_organization}  vm_list=${pool_list}

   Set Suite Variable  ${pool_return1}

