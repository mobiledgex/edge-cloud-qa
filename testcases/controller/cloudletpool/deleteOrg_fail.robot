*** Settings ***
Documentation  DeleteOrg Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-1699
DeleteOrg - delete org in use by org cloudlet pool shall return error
   [Documentation]
   ...  - send CreateOrg
   ...  - send CreateOrgCloudletPool
   ...  - send DeleteOrg
   ...  - verify proper error is received

   #EDGECLOUD-1725 deleting an org which is in use by orgcloudletpool gives database error

   Create Org
   Create Cloudlet Pool  region=US  operator_org_name=dmuus
   Create Org Cloudlet Pool  region=US  cloudlet_pool_org_name=dmuus

   ${error}=  Run Keyword And Expect Error  *  Delete Org 

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Cannot delete organization because it is referenced by an OrgCloudletPool"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name
   ${org_name}=  Get Default Organization Name

   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${org_name}
