*** Settings ***
Documentation  CreateOrgCloudletPool Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-1678
CreateOrgCloudletPool - create without region shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Org Cloudlet Pool  token=${token}  cloudlet_pool_name=andy  org_name=myorg  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Region not specified"} 

# ECQ-1679
CreateOrgCloudletPool - create without parameters shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Organization name not specified"}

# ECQ-1680
CreateOrgCloudletPool - create without org name shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=andy  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Organization name not specified"}

# ECQ-1681
CreateOrgCloudletPool - create without pool name shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=US  token=${token}  org_name=myorg  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool name not specified"}

# ECQ-2304
CreateOrgCloudletPool - create without pool org name shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool without pool org name 
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=myorg  org_name=MobiledgeX  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool organization not specified"}

# ECQ-2305
CreateOrgCloudletPool - create with pool org not found shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool for pool org that doesnt exist
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypooolxxx  cloudlet_pool_org_name=xxx  org_name=MobiledgeX  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"org xxx not found"}

# ECQ-1682
CreateOrgCloudletPool - create with pool name not found shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool for pool name that doesnt exist 
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypooolxxx  cloudlet_pool_org_name=MobiledgeX  org_name=MobiledgeX  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Specified CloudletPool mypooolxxx org MobiledgeX for region US not found"}

# ECQ-1683
CreateOrgCloudletPool - create with org name not found shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool for pool name that doesnt exist
   ...  - verify proper error is received

   Create Cloudlet Pool  region=US  token=${token}  operator_org_name=MobiledgeX

   ${error}=  Run Keyword And Expect Error  *   Create Org Cloudlet Pool  region=US  token=${token}  org_name=myorg  cloudlet_pool_org_name=MobiledgeX

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Specified Organization myorg does not exist"}

# ECQ-1684
CreateOrgCloudletPool - create with same name shall return error
   [Documentation]
   ...  - send CreateOrgCloudletPool twice for same name 
   ...  - verify proper error is received

   #EDGECLOUD-1724 - creating same org cloudlet pool with same name should give info in error message

   Create Cloudlet Pool  region=US  token=${token}  operator_org_name=MobiledgeX

   Create Org    
   Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_org_name=MobiledgeX 

   ${error}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_org_name=MobiledgeX

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"OrgCloudletPool org ${org_name}, region US, pool ${pool_name} poolorg MobiledgeX already exists"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name
   ${org_name}=   Get Default Organization Name

   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${org_name}

