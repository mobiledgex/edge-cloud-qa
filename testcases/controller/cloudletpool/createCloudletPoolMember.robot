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

   Should Be Equal  ${pool_return[0]['data']['key']['name']}                   ${name} 
   Should Be Equal  ${pool_return[0]['data']['key']['organization']}           ${operator}
   Should Be Equal  ${pool_return[0]['data']['cloudlets'][0]}                  ${cloudlet}

   Length Should Be  ${pool_return[0]['data']['cloudlets']}   1

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

   Should Be Equal  ${pool_return[0]['data']['key']['name']}                   ${epoch}
   Should Be Equal  ${pool_return[0]['data']['key']['organization']}           ${operator}
   Should Be Equal  ${pool_return[0]['data']['cloudlets'][0]}                  ${cloudlet}

   Length Should Be  ${pool_return[0]['data']['cloudlets']}   1

# ECQ-3397
CreateCloudletPoolMember - shall be able to add multiple members to a pool
   [Documentation]
   ...  - send 2 CreateCloudletPoolMember with numbers in pool name
   ...  - verify pool member is created
   ...  - do ShowCloudletPool with different filters
   ...  - verify show is correct

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}

   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${epoch}  operator_org_name=${operator}
   Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=${epoch}  operator_org_name=tmus  cloudlet_name=tmocloud-1
   Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=${epoch}  operator_org_name=tmus  cloudlet_name=tmocloud-2

   ${pool_return}=  Show Cloudlet Pool  region=US  cloudlet_pool_name=${epoch}  operator_org_name=${operator}

   Should Be Equal  ${pool_return[0]['data']['key']['name']}                   ${epoch}
   Should Be Equal  ${pool_return[0]['data']['key']['organization']}           ${operator}
   Should Be Equal  ${pool_return[0]['data']['cloudlets'][0]}                  ${cloudlet}
   Should Be Equal  ${pool_return[0]['data']['cloudlets'][1]}                  tmocloud-2

   Length Should Be  ${pool_return[0]['data']['cloudlets']}   2

   @{cloudlet_list}=  Create List  ${cloudlet}
   ${pool_return2}=  Show Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${epoch}  cloudlet_list=${cloudlet_list}  use_defaults=${False}

   Should Be Equal  ${pool_return2[0]['data']['key']['name']}                   ${epoch}
   Should Be Equal  ${pool_return2[0]['data']['key']['organization']}           ${operator}
   Should Be Equal  ${pool_return2[0]['data']['cloudlets'][0]}                  ${cloudlet}
   Should Be Equal  ${pool_return2[0]['data']['cloudlets'][1]}                  tmocloud-2

   Length Should Be  ${pool_return2[0]['data']['cloudlets']}   2

   @{cloudlet_list}=  Create List  tmocloud-2
   ${pool_return3}=  Show Cloudlet Pool  region=US  cloudlet_pool_name=${epoch}  cloudlet_list=${cloudlet_list}  operator_org_name=${operator}

   Should Be Equal  ${pool_return3[0]['data']['key']['name']}                   ${epoch}
   Should Be Equal  ${pool_return3[0]['data']['key']['organization']}           ${operator}
   Should Be Equal  ${pool_return3[0]['data']['cloudlets'][0]}                  ${cloudlet}
   Should Be Equal  ${pool_return3[0]['data']['cloudlets'][1]}                  tmocloud-2

   Length Should Be  ${pool_return3[0]['data']['cloudlets']}   2

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
