*** Settings ***
Documentation  DeleteVMPool failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  Collections
Library  String

#Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${operator_organization}=  GDDT
${vmpool_server_name}=  vmpoolvm

*** Test Cases ***
CreateCloudlet - create with non-existent vmpool shall return error
   [Documentation]
   ...  send CreateCloudlet with a vmpool that doesnt exist 
   ...  verify proper error is received

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_organization}  vm_pool=nopool  platform_type=PlatformTypeVmPool

   Should Contain   ${error}  {"result":{"message":"VM Pool nopool not found","code":400}}

CreateCloudlet - create with platformtype=VMPool but no vmpool shall return error
   [Documentation]
   ...  send CreateCloudlet without a vmpool
   ...  verify proper error is received

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_organization}  platform_type=PlatformTypeVmPool

   Should Contain   ${error}  {"result":{"message":"VM Pool is mandatory for PlatformTypeVmPool","code":400}}

CreateCloudlet - create with VMPool with no external address shall return error
   [Documentation]
   ...  create vm pool with no external address
   ...  send CreateCloudlet with the pool
   ...  verify proper error is received

   # EDGECLOUD-3324 CreateCloudlet with vm pool has typo in message output

   &{vm1}=  Create Dictionary  name=vm1  internal_ip=2.2.2.2
   @{vmlist}=  Create List  ${vm1}

   ${pool_return}=  Create VM Pool  region=US  org_name=${operator_organization}  vm_list=${vmlist}

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_organization}  platform_type=PlatformTypeVmPool  vm_pool=${pool_return['data']['key']['name']}

   Should Contain   ${error}  {"result":{"message":"At least one VM should have access to external network","code":400}}

CreateCloudlet - create with VMPool with bad external address shall return error
   [Documentation]
   ...  create vm pool with bad external address
   ...  send CreateCloudlet with the pool
   ...  verify proper error is received

   # EDGECLOUD-3324 CreateCloudlet with vm pool has typo in message output

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2
   @{vmlist}=  Create List  ${vm1}

   ${pool_return}=  Create VM Pool  region=US  org_name=${operator_organization}  vm_list=${vmlist}

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_organization}  platform_type=PlatformTypeVmPool  vm_pool=${pool_return['data']['key']['name']}

   Should Contain   ${error}  {"result":{"message":"Failed to get flavor info for vm1:${SPACE}${SPACE}- ssh dial fail to 1.1.1.1:22 - dial tcp 1.1.1.1:22: i/o timeout","code":400}}

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

