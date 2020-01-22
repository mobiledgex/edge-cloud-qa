*** Settings ***
Documentation  DeleteCloudletPool failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
DeleteCloudletPool - delete without region shall return error 
   [Documentation]
   ...  send DeleteCloudletPool without region 
   ...  verify proper error is received 

   #EDGECLOUD-1741 - DeleteCloudletPool without parms gives wrong message

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"no region specified"}

DeleteCloudletPool - delete without parameters shall return error
   [Documentation] 
   ...  send DeleteCloudletPool with region only
   ...  verify proper error is received

   #EDGECLOUD-1741 - DeleteCloudletPool without parms gives wrong message

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {} not found"}

DeleteCloudletPool - delete with name not found shall return error
   [Documentation]
   ...  send DeleteCloudletPool for policy not found
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=xpoolx

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"name\\\\":\\\\"xpoolx\\\\"} not found"}

DeleteCloudletPool - delete when assinged to an org shall return error 
   [Documentation]
   ...  send CreateCloudletPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   #EDGECLOUD-1728 able to do DeleteCloudletPool when the pool is assigned to an org

   ${pool_name}=  Get Default Cloudlet Pool Name
   ${org_name}=   Get Default Organization Name

   Create Org

   ${pool_return1}=  Create Cloudlet Pool  region=US  
   log to console  xxx ${pool_return1}

   ${pool_return}=  Create Org Cloudlet Pool  region=US  

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=US  

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Cannot delete CloudletPool region US name ${pool_name} because it is in use by OrgCloudletPool org ${org_name}"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
