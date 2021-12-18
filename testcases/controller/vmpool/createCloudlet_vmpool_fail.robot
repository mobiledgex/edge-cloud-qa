*** Settings ***
Documentation  CreateCloudlet with VMPool failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${operator_organization}=  GDDT
${vmpool_server_name}=  vmpoolvm

*** Test Cases ***
# ECQ-2315
CreateCloudlet - create with non-existent vmpool shall return error
   [Documentation]
   ...  - send CreateCloudlet with a vmpool that doesnt exist 
   ...  - verify proper error is received

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_organization}  vm_pool=nopool  platform_type=PlatformTypeVmPool

   Should Contain   ${error}  {"result":{"message":"VMPool key {\\\\\"organization\\\\\":\\\\\"GDDT\\\\\",\\\\\"name\\\\\":\\\\\"nopool\\\\\"} not found","code":400}}

# ECQ-2316
CreateCloudlet - create with platformtype=VMPool but no vmpool shall return error
   [Documentation]
   ...  - send CreateCloudlet without a vmpool
   ...  - verify proper error is received

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_organization}  platform_type=PlatformTypeVmPool

   Should Contain   ${error}   ('code=400', 'error={"message":"VM Pool is mandatory for PlatformTypeVmPool"}')

# ECQ-2317
CreateCloudlet - create with VMPool with no external address shall return error
   [Documentation]
   ...  - create vm pool with no external address
   ...  - send CreateCloudlet with the pool
   ...  - verify proper error is received

   # EDGECLOUD-3324 CreateCloudlet with vm pool has typo in message output - fixed

   &{vm1}=  Create Dictionary  name=vm1  internal_ip=2.2.2.2
   @{vmlist}=  Create List  ${vm1}

   ${pool_return}=  Create VM Pool  region=US  org_name=${operator_organization}  vm_list=${vmlist}

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_organization}  platform_type=PlatformTypeVmPool  vm_pool=${pool_return['data']['key']['name']}

   Should Contain   ${error}  {"result":{"message":"At least one VM should have access to external network","code":400}}

# ECQ-2318
CreateCloudlet - create with VMPool with bad external address shall return error
   [Documentation]
   ...  - create vm pool with bad external address
   ...  - send CreateCloudlet with the pool
   ...  - verify proper error is received

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2
   @{vmlist}=  Create List  ${vm1}

   ${pool_return}=  Create VM Pool  region=US  org_name=${operator_organization}  vm_list=${vmlist}

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_organization}  platform_type=PlatformTypeVmPool  vm_pool=${pool_return['data']['key']['name']}

   Should Contain   ${error}  {"result":{"message":"Failed to verify if vm vm1 is accessible over external network:${SPACE}${SPACE}- ssh dial fail to 1.1.1.1:22 - dial tcp 1.1.1.1:22: i/o timeout","code":400}}


