*** Settings ***
Documentation  AddVMPoolMember Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX

*** Test Cases ***
# ECQ-2341
AddVMPoolMember - add without region shall return error
   [Documentation]
   ...  - send AddVMPoolMember without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Add VM Pool Member  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"no region specified"}

# ECQ-2342
AddVMPoolMember - add without parameters shall return error
   [Documentation]
   ...  - send AddVMPoolMember with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Add VM Pool Member  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid organization name"}

# ECQ-2343
AddVMPoolMember - add with same vm name shall return error
   [Documentation]
   ...  - send AddVMPoolMember twice for same vm name 
   ...  - verify proper error is received

   Create VM Pool  region=US  token=${token}  vm_pool_name=mypoool  org_name=packet  use_defaults=False

   Add VM Pool Member  region=US  token=${token}  vm_pool_name=mypoool  org_name=${organization}  vm_name=x  external_ip=80.187.128.12  internal_ip=80.187.128.12 

   ${error}=  Run Keyword And Expect Error  *   Add VM Pool Member  region=US  token=${token}  vm_pool_name=mypoool  org_name=${organization}  vm_name=x  external_ip=80.187.128.12  internal_ip=80.187.128.12 

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VM with same name already exists as part of VM pool"}

# ECQ-2344
AddVMPoolMember - add without VM name shall return error
   [Documentation]
   ...  - send AddVMPoolMember without vm name and external/internal address
   ...  - verify proper error is received

   &{vm1}=  Create Dictionary  external_ip=80.187.128.12  internal_ip=80.187.128.12 
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Add VM Pool Member  region=US  token=${token}  org_name=packet  external_ip=80.187.128.12  internal_ip=80.187.128.12 

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing VM name"}

# ECQ-2345
AddVMPoolMember - add without external/internal address shall return error
   [Documentation]
   ...  - send AddVMPoolMember without external/internal address
   ...  - verify pool is created

   &{vm1}=  Create Dictionary  name=vm1  
   @{vmlist}=  Create List  ${vm1}
   Create VM Pool  region=US  token=${token}  vm_pool_name=mypoool  org_name=packet  use_defaults=False

   ${error}=  Run Keyword And Expect Error  *  Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm1

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing internal IP for VM: vm1"}

# ECQ-2346
AddVMPoolMember - add without internal address shall return error
   [Documentation]
   ...  - send AddVMPoolMember without internal address
   ...  - verify pool is created

   &{vm1}=  Create Dictionary  name=vm1  internal_ip=80.187.128.12
   @{vmlist}=  Create List  ${vm1}
   Create VM Pool  region=US  token=${token}  org_name=packet  vm_list=${vmlist} 

   ${error}=  Run Keyword And Expect Error  *  Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm1  external_ip=80.187.128.12

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing internal IP for VM: vm1"}

# ECQ-2347
AddVMPoolMember - add with duplicate external address shall return error
   [Documentation]
   ...  - send AddVMPoolMember with duplicate external address\n
   ...  - send CreateCloudlet with the pool\n
   ...  - verify proper error is received\n

   # EDGECLOUD-3361  VMPool : Controller should throw error if two VMs in a VMPool have the same internal/external IP

   &{vm1}=  Create Dictionary  name=vm1  internal_ip=80.187.128.12
   @{vmlist}=  Create List  ${vm1}
   Create VM Pool  region=US  token=${token}  org_name=packet  vm_list=${vmlist}

   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm  external_ip=1.1.1.2  internal_ip=80.187.128.13

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  org_name=packet  vm_name=vm2  external_ip=1.1.1.2  internal_ip=80.187.128.12 

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VM with same internal IP already exists as part of VM pool"}

# ECQ-2348
AddVMPoolMember - add with invalid address shall return error
   [Documentation]
   ...  - send AddVMPoolMember with invalid address\n
   ...  - verify pool is created\n

   &{vm1}=  Create Dictionary  name=vm1  internal_ip=80.187.128.12
   @{vmlist}=  Create List  ${vm1}
   Create VM Pool  region=US  token=${token}  vm_pool_name=mypoool  org_name=packet  use_defaults=False

   ${error}=  Run Keyword And Expect Error  *  Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm  internal_ip=80.187.128
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Address: 80.187.128"}

   ${error}=  Run Keyword And Expect Error  *  Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm  external_ip=80.187  internal_ip=80.187.128.1
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Address: 80.187"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
