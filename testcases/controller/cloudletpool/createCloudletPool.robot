*** Settings ***
Documentation  CreateCloudletPool

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
CreateCloudletPool - shall be able to create with long pool name 
   [Documentation]
   ...  send CreateCloudletPool with long pool name 
   ...  verify pool is created 

   ${pool_return}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=dfafafasfasfasfasfafasfafasfafasfsafasfffafafasfasfasfafasfafasffasfdsa  use_defaults=False
   log to console  xxx ${pool_return}

   Should Be Equal  ${pool_return['data']['key']['name']}  dfafafasfasfasfasfafasfafasfafasfsafasfffafafasfasfasfafasfafasffasfdsa 

CreateCloudletPool - shall be able to create with numbers in pool name 
   [Documentation]
   ...  send CreateCloudletPool with numbers in pool name
   ...  verify pool is created 

   ${pool_return}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=123  use_defaults=False
   log to console  xxx ${pool_return}

   Should Be Equal  ${pool_return['data']['key']['name']}  123 

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
