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
# ECQ-1658
CreateCloudletPoolMember - shall be able to create with long pool name 
   [Documentation]
   ...  - send CreateCloudletPoolMember with long pool name 
   ...  - verify pool member is created 

   ${name}=  Generate Random String  length=100

   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${name}  operator_org_name=${operator}
   Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=${name}  operator_org_name=${operator}  cloudlet_name=${cloudlet} 

   ${pool_return}=  Show Cloudlet Pool  region=US  cloudlet_pool_name=${name}  operator_org_name=${operator}

   Should Be Equal  ${pool_return['data']['key']['name']}                   ${name} 
   Should Be Equal  ${pool_return['data']['key']['organization']}           ${operator}
   Should Be Equal  ${pool_return['data']['cloudlets'][0]}                  ${cloudlet}

   Length Should Be  ${pool_return['data']['cloudlets']}   1

# ECQ-1659
CreateCloudletPoolMember - shall be able to create with numbers in pool name 
   [Documentation]
   ...  - send CreateCloudletPoolMember with numbers in pool name
   ...  - verify pool member is created 

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}

   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${epoch}  operator_org_name=${operator}
   Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=${epoch}  operator_org_name=tmus  cloudlet_name=tmocloud-1 

   ${pool_return}=  Show Cloudlet Pool  region=US  cloudlet_pool_name=${epoch}  operator_org_name=${operator}

   Should Be Equal  ${pool_return['data']['key']['name']}                   ${epoch}
   Should Be Equal  ${pool_return['data']['key']['organization']}           ${operator}
   Should Be Equal  ${pool_return['data']['cloudlets'][0]}                  ${cloudlet}

   Length Should Be  ${pool_return['data']['cloudlets']}   1

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
