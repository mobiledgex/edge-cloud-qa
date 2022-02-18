*** Settings ***
Documentation  CreateCloudletPool

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  MexApp
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${organization}=  tmus

*** Test Cases ***
# ECQ-1656
CreateCloudletPool - shall be able to create with long pool name 
   [Documentation]
   ...  - send CreateCloudletPool with long pool name 
   ...  - verify pool is created 

   ${name}=  Generate Random String  length=100

   ${pool_return}=  Create Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_name=${name}  operator_org_name=${organization}  use_defaults=False

   Should Be Equal  ${pool_return['data']['key']['name']}  ${name} 

   #Should Be True  ${pool_return['data']['created_at']['seconds']} > 0
   #Should Be True  ${pool_return['data']['created_at']['nanos']} > 0
   Should Contain   ${pool_return['data']['created_at']}  ${current_date}   
   Should Be Empty  ${pool_return['data']['updated_at']}

# ECQ-1657
CreateCloudletPool - shall be able to create with numbers in pool name 
   [Documentation]
   ...  - send CreateCloudletPool with numbers in pool name
   ...  - verify pool is created 

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}
   
   ${pool_return}=  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=${epoch}  operator_org_name=${organization}  use_defaults=False

   Should Be Equal  ${pool_return['data']['key']['name']}  ${epoch} 

   #Should Be True  ${pool_return['data']['created_at']['seconds']} > 0
   #Should Be True  ${pool_return['data']['created_at']['nanos']} > 0
   Should Contain   ${pool_return['data']['created_at']}  ${current_date}
   Should Be Empty  ${pool_return['data']['updated_at']}

# ECQ-2420
CreateCloudletPool - shall be able to create with 1 cloudlet in cloudlet list
   [Documentation]
   ...  - send CreateCloudletPool with 1 cloudlet in list
   ...  - verify pool is created

   Create Cloudlet  region=${region}  operator_org_name=${organization}

   @{cloudlet_list}=  Create List  ${cloudlet_name}

   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['cloudlets'][0]['name']}  ${cloudlet_list[0]}
   Length Should Be  ${pool_return['data']['cloudlets']}  1 

   #Should Be True  ${pool_return['data']['created_at']['seconds']} > 0
   #Should Be True  ${pool_return['data']['created_at']['nanos']} > 0
   Should Contain   ${pool_return['data']['created_at']}  ${current_date}
   Should Be Empty  ${pool_return['data']['updated_at']} 

# ECQ-2421
CreateCloudletPool - shall be able to create with 2 cloudlets in cloudlet list
   [Documentation]
   ...  - send CreateCloudletPool with 2 cloudlets in list
   ...  - verify pool is created

   Create Cloudlet  region=${region}  operator_org_name=${organization}

   @{cloudlet_list}=  Create List  ${cloudlet_name}  tmocloud-2

   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   #Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}
   Length Should Be  ${pool_return['data']['cloudlets']}  2

   #Should Be True  ${pool_return['data']['created_at']['seconds']} > 0
   #Should Be True  ${pool_return['data']['created_at']['nanos']} > 0
   Should Contain   ${pool_return['data']['created_at']}  ${current_date}
   Should Be Empty  ${pool_return['data']['updated_at']}
 
*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${current_date}=   Fetch Current Date

   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${current_date}

