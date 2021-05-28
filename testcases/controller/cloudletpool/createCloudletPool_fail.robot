*** Settings ***
Documentation  CreateCloudletPool Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-1669
CreateCloudletPool - create without region shall return error
   [Documentation]
   ...  - send CreateCloudletPool without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-1670
CreateCloudletPool - create without parameters shall return error
   [Documentation]
   ...  - send CreateCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid organization name"}

# ECQ-2271
CreateCloudletPool - create without pool name shall return error
   [Documentation]
   ...  - send CreateCloudletPool with org only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=US  operator_org_name=GDDT  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

# ECQ-1671
CreateCloudletPool - create with invalid pool name shall fails 
   [Documentation]
   ...  - send CreateCloudletPool with invalid name
   ...  - verify proper error is received 

   # start with a dash
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=-pool  operator_org_name=GDDT

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # $ in name 
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=p$ool  operator_org_name=GDDT

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # () in name
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=p(o)ol  operator_org_name=GDDT

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # +={}<> in name
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=+={}<>  operator_org_name=GDDT

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

# ECQ-1672
CreateCloudletPool - create with same name shall return error
   [Documentation]
   ...  - send CreateCloudletPool twice for same name 
   ...  - verify proper error is received

   Run Keyword and Ignore Error  Delete Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypoool  operator_org_name=GDDT
   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypoool  operator_org_name=GDDT  use_defaults=False

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypoool  operator_org_name=GDDT  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"organization\\\\":\\\\"GDDT\\\\",\\\\"name\\\\":\\\\"mypoool\\\\"} already exists"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
