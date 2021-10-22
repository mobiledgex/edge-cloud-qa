*** Settings ***
Documentation  RemoveVMPoolMember Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  GDDT
${region}=  EU
${region_US}=  US

*** Test Cases ***
# ECQ-2357
RemoveVMPoolMember - remove without region shall return error
   [Documentation]
   ...  - send RemoveVMPoolMember without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Remove VM Pool Member  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-2358
RemoveVMPoolMember - remove without parameters shall return error
   [Documentation]
   ...  - send RemoveVMPoolMember with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Remove VM Pool Member  region=${region}  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   #Should Contain   ${error}  error={"message":"VMPool key {} not found"}
   Should Contain   ${error}  error={"message":"Invalid organization name"}

# ECQ-2359
RemoveVMPoolMember - remove without VM name shall return error
   [Documentation]
   ...  - send RemoveVMPoolMember without vm name and external/internal address
   ...  - verify proper error is received

   # EDGECLOUD-3411 - RemoveVMPoolMember with missing vm name should give consistent error message  fixed/closed

   &{vm1}=  Create Dictionary  external_ip=80.187.128.12  internal_ip=80.187.128.12 
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Remove VM Pool Member  region=${region_US}  token=${token}  vm_pool_name=automationVMPool  org_name=${organization}  use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing VM name"}

# ECQ-2360
RemoveVMPoolMember - remove with unknown vm name shall return error
   [Documentation]
   ...  - send RemoveVMPoolMember with unknown vm name
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Remove VM Pool Member  region=${region_US}  token=${token}  vm_pool_name=automationVMPool  org_name=${organization}  vm_name=xxxxxx

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VM xxxxxx does not exist in the pool"}

# ECQ-2361
RemoveVMPoolMember - remove while in use shall return error
   [Documentation]
   ...  - send RemoveVMPoolMember while in use
   ...  - verify proper error is received

   ${pool}=  Show VM Pool  region=${region_US}  vm_pool_name=automationVMPool  org_name=${organization}
   ${length}=  Get Length  ${pool[0]['data']['vms']}

   FOR  ${x}  IN RANGE  0  ${length}
       IF  'state' in ${pool[0]['data']['vms'][${x}]}
          ${vm_name}=  Set Variable  ${pool[0]['data']['vms'][${x}]['name']}
          EXIT FOR LOOP
       END
   END

   ${error}=  Run Keyword And Expect Error  *  Remove VM Pool Member  region=${region_US}  token=${token}  vm_pool_name=automationVMPool  org_name=${organization}  vm_name=${vm_name}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Encountered failures: Unable to delete VM ${pool[0]['data']['vms'][${x}]['name']}, as it is in use"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
