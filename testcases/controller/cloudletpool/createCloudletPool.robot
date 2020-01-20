*** Settings ***
Documentation  CreateCloudletPool

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
CreateCloudletPool - shall be able to create with long pool name 
   [Documentation]
   ...  send CreateCloudletPool with long pool name 
   ...  verify pool is created 

   ${name}=  Generate Random String  length=100

   ${pool_return}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${name}  use_defaults=False

   Should Be Equal  ${pool_return['data']['key']['name']}  ${name} 

CreateCloudletPool - shall be able to create with numbers in pool name 
   [Documentation]
   ...  send CreateCloudletPool with numbers in pool name
   ...  verify pool is created 

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}
   
   ${pool_return}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${epoch}  use_defaults=False

   Should Be Equal  ${pool_return['data']['key']['name']}  ${epoch} 

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
