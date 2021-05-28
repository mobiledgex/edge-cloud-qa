*** Settings ***
Documentation  DeleteVMPool failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${region}=  US

*** Test Cases ***
# ECQ-2333
DeleteVMPool - delete without region shall return error 
   [Documentation]
   ...  - send DeleteVMPool without region 
   ...  - verify proper error is received 

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-2334
DeleteVMPool - delete without parameters shall return error
   [Documentation] 
   ...  - send DeleteVMPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=${region}  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid organization name"}

# ECQ-2335
DeleteVMPool - delete without pool name shall return error
   [Documentation]
   ...  - send DeleteVMPool without pool name
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=${region}  org_name=${organization}  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   #Should Contain   ${error}  error={"message":"VMPool key {\\\\"organization\\\\":\\\\"${organization}\\\\"} not found"}
    Should Contain   ${error}  error={"message":"Invalid VM pool name"}

# ECQ-2336
DeleteVMPool - delete without org name shall return error
   [Documentation]
   ...  - send DeleteVMPool without org name
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=${region}  vm_pool_name=xxx  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   #Should Contain   ${error}  error={"message":"VMPool key {\\\\"name\\\\":\\\\"xxx\\\\"} not found"}
   Should Contain   ${error}  error={"message":"Invalid organization name"}

# ECQ-2337
DeleteVMPool - delete with name not found shall return error
   [Documentation]
   ...  - send DeleteVMPool for pool not found
   ...  - verify proper error is received

   # EDGECLOUD-3310 - DeleteVMPool does not give error when pool does not exist  retested/closed

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=${region}  token=${token}  vm_pool_name=xpoolx  org_name=${organization}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VMPool key {\\\\"organization\\\\":\\\\"${organization}\\\\",\\\\"name\\\\":\\\\"xpoolx\\\\"} not found"}

# ECQ-2338
DeleteVMPool - delete while in use shall return error
   [Documentation]
   ...  - send DeleteVMPool while in use
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Delete VM Pool  region=EU  vm_pool_name=automationVMPool  org_name=GDDT

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"VM pool in use by Cloudlet"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
