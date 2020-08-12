*** Settings ***
Documentation  UpdateCloudletPool

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${organization}=  dmuus

*** Test Cases ***
# ECQ-2406
UpdateCloudletPool - shall be able to update empty pool with empty pool 
   [Documentation]
   ...  - send UpdateCloudletPool on empty pool with empty pool
   ...  - verify pool is correct

   Create Cloudlet Pool  region=${region}  operator_org_name=${organization}
   ${pool_return}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name} 
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Dictionary Should Not Contain Key  ${pool_return['data']}  cloudlets

#ECQ-2407
UpdateCloudletPool - shall be able to update empty pool with 1 cloudlet
   [Documentation]
   ...  - send UpdateCloudletPool on empty pool with 1 cloudlet
   ...  - verify pool is correct

   Create Cloudlet Pool  region=${region}  operator_org_name=${organization}

   @{cloudlet_list}=  Create List  tmocloud-1

   ${pool_return}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}

   Length Should Be  ${pool_return['data']['cloudlets']}  1

# ECQ-2408
UpdateCloudletPool - shall be able to update empty pool with 2 cloudlets
   [Documentation]
   ...  - send UpdateCloudletPool on empty pool with 2 cloudlets
   ...  - verify pool is correct

   Create Cloudlet Pool  region=${region}  operator_org_name=${organization}

   @{cloudlet_list}=  Create List  tmocloud-1  tmocloud-2

   ${pool_return}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}

   Length Should Be  ${pool_return['data']['cloudlets']}  2

# ECQ-2409
UpdateCloudletPool - shall be able to update pool with 2 cloudlets to empty pool
   [Documentation]
   ...  - send UpdateCloudletPool on empty pool with 2 cloudlets
   ...  - verify pool is correct

   @{cloudlet_list}=  Create List  tmocloud-1  tmocloud-2
   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}

   @{cloudlet_list2}=  Create List

   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list2}

   Should Be Equal  ${pool_return2['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return2['data']['key']['organization']}  ${organization}
   Dictionary Should Not Contain Key  ${pool_return2['data']}  cloudlets

# ECQ-2410
UpdateCloudletPool - shall be able to update pool with same cloudlets
   [Documentation]
   ...  - send UpdateCloudletPool on pool with same cloudlets
   ...  - verify pool is correct

   @{cloudlet_list}=  Create List  tmocloud-1  tmocloud-2
   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}

   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return2['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return2['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return2['data']['cloudlets']}  ${cloudlet_list}

   Length Should Be  ${pool_return['data']['cloudlets']}  2
   Length Should Be  ${pool_return2['data']['cloudlets']}  2

# ECQ-2411
UpdateCloudletPool - shall be able to update pool by removing cloudlet
   [Documentation]
   ...  - send UpdateCloudletPool on pool with 2 cloudlets to 1 cloudlet
   ...  - verify pool is correct

   @{cloudlet_list}=  Create List  tmocloud-1  tmocloud-2
   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}

   @{cloudlet_list}=  Create List  tmocloud-2
   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return2['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return2['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return2['data']['cloudlets']}  ${cloudlet_list}

   Length Should Be  ${pool_return['data']['cloudlets']}  2
   Length Should Be  ${pool_return2['data']['cloudlets']}  1

# ECQ-2412
UpdateCloudletPool - shall be able to update pool after adding/removing members
   [Documentation]
   ...  - send UpdateCloudletPool on pool with 2 cloudlets to 1 cloudlet
   ...  - verify pool is correct

   ${region}=  Set Variable  EU
   ${organization}=  Set Variable  GDDT

   @{cloudlet_list}=  Create List  automationBeaconCloudlet
   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}

   Add Cloudlet Pool Member  region=${region}  operator_org_name=${organization}  cloudlet_name=automationFairviewCloudlet
   Add Cloudlet Pool Member  region=${region}  operator_org_name=${organization}  cloudlet_name=automationHawkinsCloudlet
   Remove Cloudlet Pool Member  region=${region}  operator_org_name=${organization}  cloudlet_name=automationHawkinsCloudlet
 
   @{cloudlet_list_update}=  Create List  automationParadiseCloudlet  automationBuckhornCloudlet
   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list_update}

   Should Be Equal  ${pool_return2['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return2['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return2['data']['cloudlets']}  ${cloudlet_list_update}

   Length Should Be  ${pool_return['data']['cloudlets']}  1
   Length Should Be  ${pool_return2['data']['cloudlets']}  2

# ECQ-2413
UpdateCloudletPool - shall be able to update after added to org
   [Documentation]
   ...  - send CreateCloudletPool
   ...  - send CreateOrgCloudletPool with the pool
   ...  - send UpdateCloudletPool
   ...  - verify pool is correct

   ${orgname}=  Create Org  orgtype=operator

   Create Cloudlet Pool  region=${region}  operator_org_name=${organization}

   ${pool_return}=  Create Org Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_org_name=${organization}  #cloudlet_pool_name=${name}   #use_defaults=False

   @{cloudlet_list}=  Create List  tmocloud-2
   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
