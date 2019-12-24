*** Settings ***
Documentation  CreateOrgCloudletPool

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
CreateOrgCloudletPool - shall be able to create with long pool name 
   [Documentation]
   ...  send CreateOrgCloudletPool with long pool name 
   ...  verify it is success 

   ${pool_return1}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=dfafafasfasfasfasfafasfafasfafasfsafasfffafafasfasfasfafasfafasffasfdsa   ##use_defaults=False
   log to console  xxx ${pool_return1}

   ${pool_return}=  Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=dfafafasfasfasfasfafasfafasfafasfsafasfffafafasfasfasfafasfafasffasfdsa   #use_defaults=False
   log to console  xxx ${pool_return}

   ${found}=  Set Variable  ${False}
   FOR  ${pool_cloudlet}  IN  @{pool_return}
      ${found}=  Run Keyword And Return Status  Should Be True  '${pool_cloudlet['CloudletPool']}'=='dfafafasfasfasfasfafasfafasfafasfsafasfffafafasfasfasfafasfafasffasfdsa'
      Exit For Loop If  ${found}
   END

   Should Be Equal  ${found}  ${True} 

CreateOrgCloudletPool - shall be able to create with numbers in pool name 
   [Documentation]
   ...  send CreateOrgCloudletPool with numbers name
   ...  verify it is success

   ${pool_return1}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=123   ##use_defaults=False
   log to console  xxx ${pool_return1}

   ${pool_return}=  Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=123   #use_defaults=False
   log to console  xxx ${pool_return}

   ${found}=  Set Variable  ${False}
   FOR  ${pool_cloudlet}  IN  @{pool_return}
      ${found}=  Run Keyword And Return Status  Should Be True  '${pool_cloudlet['CloudletPool']}'=='123'
      Exit For Loop If  ${found}
   END

   Should Be Equal  ${found}  ${True}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Create Org  
   Set Suite Variable  ${pool_name}
