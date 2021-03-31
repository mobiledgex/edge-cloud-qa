*** Settings ***
Documentation  CreateOrgCloudletPool

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-1676
CreateOrgCloudletPool - shall be able to create with long pool name 
   [Documentation]
   ...  - send CreateOrgCloudletPool with long pool name 
   ...  - verify it is success 

   ${name}=  Generate Random String  length=100

   ${pool_return1}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${name}   ##use_defaults=False

   ${pool_return}=  Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${name}   #use_defaults=False

   ${found}=  Set Variable  ${False}
   FOR  ${pool_cloudlet}  IN  @{pool_return}
      ${found}=  Run Keyword And Return Status  Should Be True  '${pool_cloudlet['CloudletPool']}'=='${name}'
      Exit For Loop If  ${found}
   END

   Should Be Equal  ${found}  ${True} 

# ECQ-1677
CreateOrgCloudletPool - shall be able to create with numbers in pool name 
   [Documentation]
   ...  - send CreateOrgCloudletPool with numbers name
   ...  - verify it is success

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}

   ${pool_return1}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${epoch}   ##use_defaults=False
   log to console  xxx ${pool_return1}

   ${pool_return}=  Create Org Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${epoch}   #use_defaults=False
   log to console  xxx ${pool_return}

   ${found}=  Set Variable  ${False}
   FOR  ${pool_cloudlet}  IN  @{pool_return}
      ${found}=  Run Keyword And Return Status  Should Be True  '${pool_cloudlet['CloudletPool']}'=='${epoch}'
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
