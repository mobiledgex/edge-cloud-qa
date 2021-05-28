*** Settings ***
Documentation  UpdateVMPool Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  TDG
${pool_name_automation}=  automationVMPool

${region}=  EU

*** Test Cases ***
# ECQ-2382
UpdateVMPool - update without region shall return error
   [Documentation]
   ...  - send UpdateVMPool without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Update VM Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-2383
UpdateVMPool - update without parameters shall return error
   [Documentation]
   ...  - send UpdateVMPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Update VM Pool  region=${region}  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Nothing specified to update"}

# ECQ-2384
UpdateVMPool - update with invalid pool name shall fail
   [Documentation]
   ...  - send UpdateVMPool with invalid name
   ...  - verify proper error is received 

   &{vm1}=  Create Dictionary  external_ip=80.187.128.12  internal_ip=80.187.128.12
   @{vmlist}=  Create List  ${vm1}

   # start with a dash
   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  token=${token}  vm_pool_name=-pool  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM pool name"}

   # $ in name 
   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  token=${token}  vm_pool_name=p$ool   org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM pool name"}

   # () in name
   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  token=${token}  vm_pool_name=p(o)ol   org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM pool name"}

   # +={}<> in name
   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  token=${token}  vm_pool_name=+={}<>   org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM pool name"}

# ECQ-2385
UpdateVMPool - update without VM name shall return error
   [Documentation]
   ...  - send UpdateVMPool without name and external/internal address
   ...  - verify pool is created

   # EDGECLOUD-3309 CreateVMPool without vm name gives wrong error - fixed/closed

   &{vm1}=  Create Dictionary  external_ip=80.187.128.12  internal_ip=80.187.128.12 
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Update VM Pool  region=${region}  token=${token}  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing VM name"}

# ECQ-2386
UpdateVMPool - update without external/internal address shall return error
   [Documentation]
   ...  - send UpdateVMPool without external/internal address
   ...  - verify pool is created

   Create VM Pool  region=US  token=${token}  org_name=${organization}
 
   &{vm1}=  Create Dictionary  name=vm1  
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Update VM Pool  region=${region}  token=${token}  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing internal IP for VM: vm1"}

# ECQ-2387
UpdateVMPool - update without internal address shall return error
   [Documentation]
   ...  - send UpdateVMPool without internal address
   ...  - verify pool is created

   Create VM Pool  region=US  token=${token}  org_name=${organization}

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.12
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Update VM Pool  region=${region}  token=${token}  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing internal IP for VM: vm1"}

# ECQ-2388
UpdateVMPool - update with VMPool with duplicate external address shall return error
   [Documentation]
   ...  - update vm pool with duplicate external address
   ...  - verify proper error is received

   # EDGECLOUD-3361  VMPool : Controller should throw error if two VMs in a VMPool have the same internal/external IP

   Create VM Pool  region=US  token=${token}  org_name=${organization}

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2
   &{vm2}=  Create Dictionary  name=vm2  external_ip=1.1.1.1  internal_ip=2.2.2.2
   @{vmlist}=  Create List  ${vm1}  ${vm2}

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VM with same external IP 1.1.1.1 already exists"}

# ECQ-2389
UpdateVMPool - update with VMPool in use shall return error
   [Documentation]
   ...  - update vm pool while is in use
   ...  - verify proper error is received

   # EDGECLOUD-3398 - UpdateVMPool message while pool in use is misleading

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2
   &{vm2}=  Create Dictionary  name=vm2  external_ip=1.1.1.2  internal_ip=2.2.2.3
   @{vmlist}=  Create List  ${vm1}  ${vm2}

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  vm_pool_name=automationVMPool  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain Any  ${error}  Encountered failures: Unable to delete VM automationvmpool1, as it is in use   Encountered failures: Unable to delete VM automationvmpool2, as it is in use   Encountered failures: Unable to delete VM automationvmpool3, as it is in use   Encountered failures: Unable to delete VM automationvmpool4, as it is in use   Encountered failures: Unable to delete VM automationvmpool5, as it is in use   Encountered failures: Unable to delete VM automationvmpool6, as it is in use
   #Should Contain Any  ${error}  error={"message":"Encountered failures: Unable to delete VM automationvmpool2, as it is in use"}

# ECQ-2390
UpdateVMPool - update with VMPool not found shall return error
   [Documentation]
   ...  - update vm pool with pool that doesnt exist 
   ...  - verify proper error is received

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2
   &{vm2}=  Create Dictionary  name=vm2  external_ip=1.1.1.2  internal_ip=2.2.2.3
   @{vmlist}=  Create List  ${vm1}  ${vm2}

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  vm_pool_name=xxautomationVMPool  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VMPool key {\\\\"organization\\\\":\\\\"TDG\\\\",\\\\"name\\\\":\\\\"xxautomationVMPool\\\\"} not found"}

# ECQ-2391
UpdateVMPool - update with invalid address shall return error
   [Documentation]
   ...  - update vm pool with invalid pool address
   ...  - verify proper error is received

   Create VM Pool  region=US  token=${token}  org_name=${organization}

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2
   &{vm2}=  Create Dictionary  name=vm2  external_ip=1.1.1  internal_ip=2.2.2.2
   @{vmlist}=  Create List  ${vm1}  ${vm2}

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Address: 1.1.1"}

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=.2.2.2
   @{vmlist}=  Create List  ${vm1}  ${vm2}

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  org_name=${organization}  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Address: .2.2.2"}

# ECQ-2392
UpdateVMPool - update with invalid state shall return error
   [Documentation]
   ...  - update vm pool with invalid state
   ...  - verify proper error is received

   #  EDGECLOUD-3413 - UpdateVMPool should only allow state of "VM_FORCE_FREE = 6" 

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2  state=x
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  vm_pool_name=automationVMPool  org_name=${organization}  vm_list=${vmlist}
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid POST data, code\=400, message\=No enum value for x"}

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2  state=99
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  vm_pool_name=automationVMPool  org_name=${organization}  vm_list=${vmlist}
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid POST data, code\=400, message\=No enum value for 99"}

   &{vm1}=  Create Dictionary  name=vm1  external_ip=1.1.1.1  internal_ip=2.2.2.2  state=3
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=${region}  vm_pool_name=automationVMPool  org_name=${organization}  vm_list=${vmlist}
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM state, only VmForceFree state is allowed"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
