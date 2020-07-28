*** Settings ***
Documentation  DeleteVMPool failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX

*** Test Cases ***
DeleteVMPool - delete without region shall return error 
   [Documentation]
   ...  send DeleteVMPool without region 
   ...  verify proper error is received 

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"no region specified"}

DeleteVMPool - delete without parameters shall return error
   [Documentation] 
   ...  send DeleteVMPool with region only
   ...  verify proper error is received

   #EDGECLOUD-1741 - DeleteCloudletPool without parms gives wrong message

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid organization name"}

DeleteVMPool - delete with name not found shall return error
   [Documentation]
   ...  send DeleteVMPool for policy not found
   ...  verify proper error is received

   # EDGECLOUD-3310 - DeleteVMPool does not give error when pool does not exist

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=US  token=${token}  vm_pool_name=xpoolx  org_name=${organization}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"name\\\\":\\\\"xpoolx\\\\"} not found"}

DeleteVMPool - delete when assinged to an org shall return error 
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   #EDGECLOUD-1728 able to do DeleteCloudletPool when the pool is assigned to an org

   ${pool_name}=  Get Default VM Pool Name
   ${org_name}=   Get Default Organization Name


   #Create Org

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.12  internal_ip=2.2.2.2
   @{vmlist}=  Create List  ${vm1}
   ${pool_return1}=  Create VM Pool  region=US  org_name=${organization}  vm_list=${vmlist}
   log to console  xxx ${pool_return1}

   ${pool_return}=  Create Cloudlet  region=US  operator_org_name=${organization}  vm_pool=${pool_name}  platform_type=PlatformTypeVmPool

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=US  

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Cannot delete CloudletPool region US name ${pool_name} because it is in use by OrgCloudletPool org ${org_name}"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
