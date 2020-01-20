*** Settings ***
Documentation  CreateCloudletPoolMember

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${operator}=  tmus
${cloudlet}=  tmocloud-1

*** Test Cases ***
CreateCloudletPoolMember - shall be able to create with long pool name 
   [Documentation]
   ...  send CreateCloudletPoolMember with long pool name 
   ...  verify pool member is created 

   ${name}=  Generate Random String  length=100

   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${name}
   ${pool_return}=  Create Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=${name}  operator_name=${operator}  cloudlet_name=${cloudlet} 
   log to console  xxx ${pool_return}

   Should Be Equal  ${pool_return['data']['pool_key']['name']}                      ${name} 
   Should Be Equal  ${pool_return['data']['cloudlet_key']['name']}                  ${cloudlet}
   Should Be Equal  ${pool_return['data']['cloudlet_key']['operator_key']['name']}  ${operator}

CreateCloudletPoolMember - shall be able to create with numbers in pool name 
   [Documentation]
   ...  send CreateCloudletPoolMember with numbers in pool name
   ...  verify pool member is created 

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}

   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${epoch}
   ${pool_return}=  Create Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=${epoch}  operator_name=tmus  cloudlet_name=tmocloud-1 

   Should Be Equal  ${pool_return['data']['pool_key']['name']}                      ${epoch} 
   Should Be Equal  ${pool_return['data']['cloudlet_key']['name']}                  ${cloudlet}
   Should Be Equal  ${pool_return['data']['cloudlet_key']['operator_key']['name']}  ${operator}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
