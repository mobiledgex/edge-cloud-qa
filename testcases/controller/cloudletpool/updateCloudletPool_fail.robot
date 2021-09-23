*** Settings ***
Documentation  UpdateCloudletPool Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  TDG
${pool_name_automation}=  automationVMPool

${region}=  EU

*** Test Cases ***
# ECQ-2414
UpdateCloudletPool - update without region shall return error
   [Documentation]
   ...  - send UpdateCloudletPool without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Update Cloudlet Pool  token=${token}  cloudlet_pool_name=xxautomationVMPool  operator_org_name=${organization}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-2415
UpdateCloudletPool - update without parameters shall return error
   [Documentation]
   ...  - send UpdateCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Update Cloudlet Pool  region=${region}  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"CloudletPool key {} not found"}
   Should Contain   ${error}  error={"message":"Invalid organization name"}

# ECQ-2416
UpdateCloudletPool - update without pool name shall return error
   [Documentation]
   ...  - send UpdateCloudletPool with org only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Update Cloudlet Pool  region=US  operator_org_name=TDG  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   #Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"organization\\\\":\\\\"TDG\\\\"} not found"}
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name \\\\\"\\\\\""}


# ECQ-2417
UpdateCloudletPool - update with CloudletPool not found shall return error
   [Documentation]
   ...  - update cloudlet pool with pool that doesnt exist 
   ...  - verify proper error is received

   ${error}=  Run Keyword and Expect Error  *  Update Cloudlet Pool  region=${region}  cloudlet_pool_name=xxautomationVMPool  operator_org_name=${organization}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"organization\\\\":\\\\"TDG\\\\",\\\\"name\\\\":\\\\"xxautomationVMPool\\\\"} not found"}

# ECQ-2418
UpdateCloudletPool - update with cloudlet not in org shall return error
   [Documentation]
   ...  - send UpdateCloudletPool with a cloudlet not in the specified org
   ...  - verify proper error is received

   Create Cloudlet Pool  region=${region}  operator_org_name=${organization}

   @{cloudlet_list}=  Create List  tmocloud-1

   ${error}=  Run Keyword and Expect Error  *  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Cloudlets tmocloud-1 not found"}

# ECQ-2419
UpdateCloudletPool - update with cloudlet not exist shall return error
   [Documentation]
   ...  - send UpdateCloudletPool with a cloudlet that doesnt exist anywhere
   ...  - verify proper error is received

   Create Cloudlet Pool  region=${region}  operator_org_name=${organization}

   @{cloudlet_list}=  Create List  xxxxxxxtmocloud-1

   ${error}=  Run Keyword and Expect Error  *  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Cloudlets xxxxxxxtmocloud-1 not found"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
