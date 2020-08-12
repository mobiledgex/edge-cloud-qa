*** Settings ***
Documentation  DeleteOrgCloudletPool Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-1693
DeleteOrgCloudletPool - delete without region shall return error
   [Documentation]
   ...  - send DeleteOrgCloudletPool without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Delete Org Cloudlet Pool  token=${token}  cloudlet_pool_name=andy  org_name=myorg  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Region not specified"} 

# ECQ-1694
DeleteOrgCloudletPool - delete without parameters shall return error
   [Documentation]
   ...  - send DeleteOrgCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Delete Org Cloudlet Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Organization name not specified"}

# ECQ-1695
DeleteOrgCloudletPool - delete without org name shall return error
   [Documentation]
   ...  - send DeleteOrgCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Delete Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=andy  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Organization name not specified"}

# ECQ-1696
DeleteOrgCloudletPool - delete without pool name shall return error
   [Documentation]
   ...  - send DeleteOrgCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Delete Org Cloudlet Pool  region=US  token=${token}  org_name=myorg  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool not specified"}

# ECQ-1697
DeleteOrgCloudletPool - delete with pool name not found shall return error
   [Documentation]
   ...  - send DeleteOrgCloudletPool for pool name that doesnt exist 
   ...  - verify proper error is received

   EDGECLOUD-1733 Inconsistencies in API behavior between MC specific and Controller specific returns

   ${error}=  Run Keyword And Expect Error  *   Delete Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypooolxxx  org_name=myorg  use_defaults=False
   ${response}=  Response Body

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Specified CloudletPool for region not found"}

# ECQ-1698
DeleteOrgCloudletPool - delete with org name not found shall return error
   [Documentation]
   ...  - send DeleteOrgCloudletPool for pool name that doesnt exist
   ...  - verify proper error is received

   EDGECLOUD-1733 Inconsistencies in API behavior between MC specific and Controller specific returns

   Create Cloudlet Pool  region=US  token=${token} 

   ${error}=  Run Keyword And Expect Error  *   Delete Org Cloudlet Pool  region=US  token=${token}  org_name=myorg
   ${response}=  Response Body

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Specified Organization does not exist"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
