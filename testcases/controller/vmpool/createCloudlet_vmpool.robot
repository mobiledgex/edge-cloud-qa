*** Settings ***
Documentation  DeleteVMPool failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  Collections
Library  String

Suite Setup  Setup
#Suite Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${operator_organization}=  TDG
${vmpool_server_name}=  vmpoolvm
${physical_name}=  berlin

${region}=  US

*** Test Cases ***
DeleteVMPool - delete when assinged to an org shall return error
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   ${pool_name}=  Get Default VM Pool Name
   ${org_name}=   Get Default Organization Name

   ${pool_return}=  Create Cloudlet  region=US  operator_org_name=${operator_organization}  vm_pool=${pool_name}  platform_type=PlatformTypeVmPool  physical_name=${physical_name}

   Should Be Equal As Integers  ${pool_return['data']['platform_type']}  9  # VMPool
   Should Be Equal As Integers  ${pool_return['data']['state']}  5  # Ready
   Should Be Equal              ${pool_return['data']['vm_pool']}  ${pool_name}  # Ready

   ${operator_organization_lc}=  Convert To Lowercase  ${operator_organization}

   ${group_name}=  Set Variable  ${pool_return['data']['key']['name']}-${operator_organization}-pf
   ${internal_name}=  Set Variable  ${pool_return['data']['key']['name']}.${operator_organization_lc}.mobiledgex.net

   VM Should Be In Use  region=${region}  vm_pool_name=${pool_name}  org_name=${operator_organization}  group_name=${group_name}  internal_name=${group_name}
   VM Should Be In Use  region=${region}  vm_pool_name=${pool_name}  org_name=${operator_organization}  group_name=${internal_name}  internal_name=${internal_name}
 
   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=US  org_name=${operator_organization}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VMPool in use by Cloudlet"}

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

   ${pool_return1}=  Create VM Pool  region=US  org_name=${operator_organization}  vm_list=${pool_list}

   Set Suite Variable  ${pool_return1}

