*** Settings ***
Documentation  CreateCloudletPool Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
CreateCloudletPool - create without region shall return error
   [Documentation]
   ...  send CreateCloudletPool without region
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"no region specified"}

CreateCloudletPool - create without parameters shall return error
   [Documentation]
   ...  send CreateCloudletPool with region only
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

CreateCloudletPool - create with invalid pool name shall fails 
   [Documentation]
   ...  send CreateCloudletPool with invalid name
   ...  verify proper error is received 

   # start with a dash
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=-pool

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # $ in name 
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=p$ool

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # () in name
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=p(o)ol

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # +={}<> in name
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=+={}<>

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

CreateCloudletPool - create with same name shall return error
   [Documentation]
   ...  send CreateCloudletPool twice for same name 
   ...  verify proper error is received

   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypoool  use_defaults=False

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypoool  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"name\\\\":\\\\"mypoool\\\\"} already exists"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
