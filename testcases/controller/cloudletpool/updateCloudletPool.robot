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

   ${pool_return1}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}
   Should Be True  ${pool_return1['data']['created_at']['seconds']} > 0
   Should Be True  ${pool_return1['data']['created_at']['nanos']} > 0
   Should Be True  'updated_at' in ${pool_return1['data']} and 'seconds' not in ${pool_return1['data']['updated_at']} and 'nanos' not in ${pool_return1['data']['updated_at']}

   Sleep  1s

   ${pool_return}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name} 
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Dictionary Should Not Contain Key  ${pool_return['data']}  cloudlets

   Should Be True  ${pool_return['data']['created_at']['seconds']} == ${pool_return1['data']['created_at']['seconds']} 
   Should Be True  ${pool_return['data']['created_at']['nanos']} == ${pool_return1['data']['created_at']['nanos']} 
   Should Be True  'updated_at' in ${pool_return['data']} and 'seconds' not in ${pool_return['data']['updated_at']} and 'nanos' not in ${pool_return['data']['updated_at']}

#ECQ-2407
UpdateCloudletPool - shall be able to update empty pool with 1 cloudlet
   [Documentation]
   ...  - send UpdateCloudletPool on empty pool with 1 cloudlet
   ...  - verify pool is correct

   ${pool_return1}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}
   Should Be True  ${pool_return1['data']['created_at']['seconds']} > 0
   Should Be True  ${pool_return1['data']['created_at']['nanos']} > 0
   Should Be True  'updated_at' in ${pool_return1['data']} and 'seconds' not in ${pool_return1['data']['updated_at']} and 'nanos' not in ${pool_return1['data']['updated_at']}

   @{cloudlet_list}=  Create List  ${cloudlet_name}

   Sleep  1s

   ${pool_return}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}

   Length Should Be  ${pool_return['data']['cloudlets']}  1

   Should Be True  ${pool_return['data']['created_at']['seconds']} == ${pool_return1['data']['created_at']['seconds']}
   Should Be True  ${pool_return['data']['created_at']['nanos']} == ${pool_return1['data']['created_at']['nanos']}
   Should Be True  ${pool_return['data']['updated_at']['seconds']} > ${pool_return1['data']['created_at']['seconds']}
   Should Be True  ${pool_return['data']['updated_at']['nanos']} > 0

# ECQ-2408
UpdateCloudletPool - shall be able to update empty pool with 2 cloudlets
   [Documentation]
   ...  - send UpdateCloudletPool on empty pool with 2 cloudlets
   ...  - verify pool is correct

   ${pool_return1}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}
   Should Be True  ${pool_return1['data']['created_at']['seconds']} > 0
   Should Be True  ${pool_return1['data']['created_at']['nanos']} > 0
   Should Be True  'updated_at' in ${pool_return1['data']} and 'seconds' not in ${pool_return1['data']['updated_at']} and 'nanos' not in ${pool_return1['data']['updated_at']}

   @{cloudlet_list}=  Create List  ${cloudlet_name}  tmocloud-2

   Sleep  1s

   ${pool_return}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}

   Length Should Be  ${pool_return['data']['cloudlets']}  2

   Should Be True  ${pool_return['data']['created_at']['seconds']} == ${pool_return1['data']['created_at']['seconds']}
   Should Be True  ${pool_return['data']['created_at']['nanos']} == ${pool_return1['data']['created_at']['nanos']}
   Should Be True  ${pool_return['data']['updated_at']['seconds']} > ${pool_return1['data']['created_at']['seconds']}
   Should Be True  ${pool_return['data']['updated_at']['nanos']} > 0

# ECQ-2409
UpdateCloudletPool - shall be able to update pool with 2 cloudlets to empty pool
   [Documentation]
   ...  - send UpdateCloudletPool on empty pool with 2 cloudlets
   ...  - verify pool is correct

   @{cloudlet_list}=  Create List  ${cloudlet_name}  tmocloud-2
   ${pool_return1}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Be Equal  ${pool_return1['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return1['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return1['data']['cloudlets']}  ${cloudlet_list}
   Should Be True  ${pool_return1['data']['created_at']['seconds']} > 0
   Should Be True  ${pool_return1['data']['created_at']['nanos']} > 0
   Should Be True  'updated_at' in ${pool_return1['data']} and 'seconds' not in ${pool_return1['data']['updated_at']} and 'nanos' not in ${pool_return1['data']['updated_at']}

   @{cloudlet_list2}=  Create List

   Sleep  1s

   ${pool_return}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list2}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Dictionary Should Not Contain Key  ${pool_return['data']}  cloudlets

   Should Be True  ${pool_return['data']['created_at']['seconds']} == ${pool_return1['data']['created_at']['seconds']}
   Should Be True  ${pool_return['data']['created_at']['nanos']} == ${pool_return1['data']['created_at']['nanos']}
   Should Be True  ${pool_return['data']['updated_at']['seconds']} > ${pool_return1['data']['created_at']['seconds']}
   Should Be True  ${pool_return['data']['updated_at']['nanos']} > 0

# ECQ-2410
UpdateCloudletPool - shall be able to update pool with same cloudlets
   [Documentation]
   ...  - send UpdateCloudletPool on pool with same cloudlets
   ...  - verify pool is correct

   @{cloudlet_list}=  Create List  ${cloudlet_name}  tmocloud-2
   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}
   Should Be True  ${pool_return['data']['created_at']['seconds']} > 0
   Should Be True  ${pool_return['data']['created_at']['nanos']} > 0
   Should Be True  'updated_at' in ${pool_return['data']} and 'seconds' not in ${pool_return['data']['updated_at']} and 'nanos' not in ${pool_return['data']['updated_at']}

   Sleep  1s

   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return2['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return2['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return2['data']['cloudlets']}  ${cloudlet_list}

   Length Should Be  ${pool_return['data']['cloudlets']}  2
   Length Should Be  ${pool_return2['data']['cloudlets']}  2

   Should Be True  ${pool_return2['data']['created_at']['seconds']} == ${pool_return['data']['created_at']['seconds']}
   Should Be True  ${pool_return2['data']['created_at']['nanos']} == ${pool_return['data']['created_at']['nanos']}
   Should Be True  ${pool_return2['data']['updated_at']['seconds']} > ${pool_return['data']['created_at']['seconds']}
   Should Be True  ${pool_return2['data']['updated_at']['nanos']} > 0

# ECQ-2411
UpdateCloudletPool - shall be able to update pool by removing cloudlet
   [Documentation]
   ...  - send UpdateCloudletPool on pool with 2 cloudlets to 1 cloudlet
   ...  - verify pool is correct

   @{cloudlet_list}=  Create List  ${cloudlet_name}  tmocloud-2
   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}
   Should Be True  ${pool_return['data']['created_at']['seconds']} > 0
   Should Be True  ${pool_return['data']['created_at']['nanos']} > 0
   Should Be True  'updated_at' in ${pool_return['data']} and 'seconds' not in ${pool_return['data']['updated_at']} and 'nanos' not in ${pool_return['data']['updated_at']}

   Sleep  1s

   @{cloudlet_list}=  Create List  tmocloud-2
   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Should Be Equal  ${pool_return2['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return2['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return2['data']['cloudlets']}  ${cloudlet_list}

   Length Should Be  ${pool_return['data']['cloudlets']}  2
   Length Should Be  ${pool_return2['data']['cloudlets']}  1

   Should Be True  ${pool_return2['data']['created_at']['seconds']} == ${pool_return['data']['created_at']['seconds']}
   Should Be True  ${pool_return2['data']['created_at']['nanos']} == ${pool_return['data']['created_at']['nanos']}
   Should Be True  ${pool_return2['data']['updated_at']['seconds']} > ${pool_return['data']['created_at']['seconds']}
   Should Be True  ${pool_return2['data']['updated_at']['nanos']} > 0

# ECQ-2412
UpdateCloudletPool - shall be able to update pool after adding/removing members
   [Documentation]
   ...  - send UpdateCloudletPool on pool with 2 cloudlets to 1 cloudlet
   ...  - verify pool is correct

   #${region}=  Set Variable  EU
   #${organization}=  Set Variable  GDDT

   ${cloudlet_name2}=  Set Variable  ${cloudlet_name}2
   ${cloudlet_name3}=  Set Variable  ${cloudlet_name}3
   ${cloudlet_name4}=  Set Variable  ${cloudlet_name}4

   Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name2}  operator_org_name=${organization}
   Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name3}  operator_org_name=${organization}
   Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name4}  operator_org_name=${organization}

   @{cloudlet_list}=  Create List  ${cloudlet_name}
   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return['data']['cloudlets']}  ${cloudlet_list}
   Should Be True  ${pool_return['data']['created_at']['seconds']} > 0
   Should Be True  ${pool_return['data']['created_at']['nanos']} > 0
   Should Be True  'updated_at' in ${pool_return['data']} and 'seconds' not in ${pool_return['data']['updated_at']} and 'nanos' not in ${pool_return['data']['updated_at']}

   Add Cloudlet Pool Member  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name2}  #cloudlet_name=automationFairviewCloudlet
   Add Cloudlet Pool Member  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name3}  #cloudlet_name=automationHawkinsCloudlet
   Remove Cloudlet Pool Member  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name3}  #cloudlet_name=automationHawkinsCloudlet

   Sleep  1s
 
   @{cloudlet_list_update}=  Create List  ${cloudlet_name4}  ${cloudlet_name}  #automationParadiseCloudlet  automationBeaconCloudlet
   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list_update}

   Should Be Equal  ${pool_return2['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return2['data']['key']['organization']}  ${organization}
   Should Be Equal  ${pool_return2['data']['cloudlets']}  ${cloudlet_list_update}

   Length Should Be  ${pool_return['data']['cloudlets']}  1
   Length Should Be  ${pool_return2['data']['cloudlets']}  2

   Should Be True  ${pool_return2['data']['created_at']['seconds']} == ${pool_return['data']['created_at']['seconds']}
   Should Be True  ${pool_return2['data']['created_at']['nanos']} == ${pool_return['data']['created_at']['nanos']}
   Should Be True  ${pool_return2['data']['updated_at']['seconds']} > ${pool_return['data']['created_at']['seconds']}
   Should Be True  ${pool_return2['data']['updated_at']['nanos']} > 0

# createorgcloudletpool no longer supporte
# ECQ-2413
#UpdateCloudletPool - shall be able to update after added to org
#   [Documentation]
#   ...  - send CreateCloudletPool
#   ...  - send CreateOrgCloudletPool with the pool
#   ...  - send UpdateCloudletPool
#   ...  - verify pool is correct
#
#   ${orgname}=  Create Org  orgtype=operator
#
#   ${pool_return1}=  Create Cloudlet Pool  region=${region}  operator_org_name=${organization}
#   Should Be True  ${pool_return1['data']['created_at']['seconds']} > 0
#   Should Be True  ${pool_return1['data']['created_at']['nanos']} > 0
#   Should Be True  'updated_at' in ${pool_return1['data']} and 'seconds' not in ${pool_return1['data']['updated_at']} and 'nanos' not in ${pool_return1['data']['updated_at']}
#
#   ${pool_return}=  Create Org Cloudlet Pool  region=${region}  token=${token}  cloudlet_pool_org_name=${organization}  #cloudlet_pool_name=${name}   #use_defaults=False
#
#   Sleep  1s
#
#   @{cloudlet_list}=  Create List  tmocloud-2
#   ${pool_return2}=  Update Cloudlet Pool  region=${region}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}
#
#   Should Be True  ${pool_return2['data']['created_at']['seconds']} == ${pool_return1['data']['created_at']['seconds']}
#   Should Be True  ${pool_return2['data']['created_at']['nanos']} == ${pool_return1['data']['created_at']['nanos']}
#   Should Be True  ${pool_return2['data']['updated_at']['seconds']} > ${pool_return1['data']['created_at']['seconds']}
#   Should Be True  ${pool_return2['data']['updated_at']['nanos']} > 0

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
   Login  username=mexadmin  password=${mexadmin_password}
   ${pool_name}=  Get Default Cloudlet Pool Name

   ${cloudlet_name}=  Get Default Cloudlet Name
   Create Cloudlet  region=${region}  operator_org_name=${organization}

   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${cloudlet_name}
