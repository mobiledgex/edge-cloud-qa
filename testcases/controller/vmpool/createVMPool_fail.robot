*** Settings ***
Documentation  CreateVMPool Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX

*** Test Cases ***
CreateVMPool - create without region shall return error
   [Documentation]
   ...  send CreateVMPool without region
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create VM Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"no region specified"}

CreateVMPool - create without parameters shall return error
   [Documentation]
   ...  send CreateVMPool with region only
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create VM Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid organization name"}

CreateVMPool - create with invalid pool name shall fails 
   [Documentation]
   ...  send CreateVMPool with invalid name
   ...  verify proper error is received 

   # EDGECLOUD-3308 CreateVMPool with invalid name should give better error message

   # start with a dash
   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${token}  vm_pool_name=-pool  org_name=${organization}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM Pool name"}

   # $ in name 
   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${token}  vm_pool_name=p$ool   org_name=${organization}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM Pool name"}

   # () in name
   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${token}  vm_pool_name=p(o)ol   org_name=${organization}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM Pool name"}

   # +={}<> in name
   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${token}  vm_pool_name=+={}<>   org_name=${organization}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid VM Pool name"}

CreateVMPool - create with same name shall return error
   [Documentation]
   ...  send CreateVMPool twice for same name 
   ...  verify proper error is received

   Create VM Pool  region=US  token=${token}  vm_pool_name=mypoool  org_name=MobiledgeX  use_defaults=False

   ${error}=  Run Keyword And Expect Error  *   Create VM Pool  region=US  token=${token}  vm_pool_name=mypoool  org_name=${organization}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VMPool key {\\\\"organization\\\\":\\\\"${organization}\\\\",\\\\"name\\\\":\\\\"mypoool\\\\"} already exists"}

CreateVMPool - create without VM name shall return error
   [Documentation]
   ...  send CreateVMPool without name and external/internal address
   ...  verify pool is created

   # EDGECLOUD-3309 CreateVMPool without vm name gives wrong error

   &{vm1}=  Create Dictionary  external_ip=80.187.128.12  internal_ip=80.187.128.12 
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Create VM Pool  region=US  token=${token}  org_name=MobiledgeX  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing internal IP for VM: vm1"}

CreateVMPool - create without external/internal address shall return error
   [Documentation]
   ...  send CreateVMPool without external/internal address
   ...  verify pool is created

   &{vm1}=  Create Dictionary  name=vm1  
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Create VM Pool  region=US  token=${token}  org_name=MobiledgeX  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing internal IP for VM: vm1"}

CreateVMPool - create without internal address shall return error
   [Documentation]
   ...  send CreateVMPool without internal address
   ...  verify pool is created

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.12
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Create VM Pool  region=US  token=${token}  org_name=MobiledgeX  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing internal IP for VM: vm1"}

CreateVMPool - create without external address shall return error
   [Documentation]
   ...  send CreateVMPool without external address
   ...  verify pool is created

   &{vm1}=  Create Dictionary  name=vm1  internal_ip=80.187.128.12
   @{vmlist}=  Create List  ${vm1}

   ${error}=  Run Keyword And Expect Error  *  Create VM Pool  region=US  token=${token}  org_name=MobiledgeX  vm_list=${vmlist}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Missing external IP for VM: vm1"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   #${pool_name}=  Get Default VM Pool Name

   #Set Suite Variable  ${pool_name}
