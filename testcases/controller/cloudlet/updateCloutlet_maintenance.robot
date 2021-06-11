*** Settings ***
Documentation   UpdateCloudlet with maintenance states

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup     Setup
Test Teardown  Teardown

*** Variables ***
${cloudlet}=  tmocloud-1
${operator}=  tmus
${region}=  US

*** Test Cases ***
# ECQ-2443
UpdateCloudlet - shall be able to put cloudlet in maintenance=NormalOperation
   [Documentation]
   ...  - send UpdateCloudlet with maintenance=NormalOperation
   ...  - verify maintenance_state is correct

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False

   Should Not Contain  ${ret['data']}  maintenance_state  # we dont show 0 vaules

   Should Be True  ${ret['data']['updated_at']['seconds']} > ${created_secs}
   Should Be True  ${ret['data']['updated_at']['nanos']} > 0

   Sleep  1s

   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False

   Should Not Contain  ${ret2['data']}  maintenance_state  # we dont show 0 vaules

   Should Be True  ${ret2['data']['updated_at']['seconds']} > ${ret['data']['updated_at']['seconds']} 
   Should Be True  ${ret2['data']['updated_at']['nanos']} > 0 

# ECQ-2444
UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStart
   [Documentation]
   ...  - send UpdateCloudlet with maintenance=MaintenanceStart
   ...  - verify maintenance_state is correct

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   Should Be True  ${ret['data']['updated_at']['seconds']} > ${created_secs}
   Should Be True  ${ret['data']['updated_at']['nanos']} > 0

   Sleep  1s

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False

   Should Be Equal As Integers  ${ret2['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   Should Be True  ${ret2['data']['updated_at']['seconds']} > ${ret['data']['updated_at']['seconds']}
   Should Be True  ${ret2['data']['updated_at']['nanos']} > 0

# ECQ-2445
UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStartNoFailover
   [Documentation]
   ...  - send UpdateCloudlet with maintenance=MaintenanceStartNoFailover
   ...  - verify maintenance_state is correct

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   Should Be True  ${ret['data']['updated_at']['seconds']} > ${created_secs}
   Should Be True  ${ret['data']['updated_at']['nanos']} > 0

   Sleep  1s

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False

   Should Be Equal As Integers  ${ret2['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   Should Be True  ${ret2['data']['updated_at']['seconds']} > ${ret['data']['updated_at']['seconds']}
   Should Be True  ${ret2['data']['updated_at']['nanos']} > 0

# ECQ-2446
UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStartNoFailover to maintenance=MaintenanceStart
   [Documentation]
   ...  - send UpdateCloudlet with maintenance=MaintenanceStartNoFailover
   ...  - verify maintenance_state is correct
   ...  - send UpdateCloudlet with maintenance=MaintenanceStart
   ...  - verify maintenance_state is correct

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover     use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   Should Be True  ${ret['data']['updated_at']['seconds']} > ${created_secs}
   Should Be True  ${ret['data']['updated_at']['nanos']} > 0

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False

   Should Be Equal As Integers  ${ret2['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   Should Be True  ${ret2['data']['updated_at']['seconds']} > ${ret['data']['updated_at']['seconds']}
   Should Be True  ${ret2['data']['updated_at']['nanos']} > 0

*** Keywords ***
Setup
   Create Flavor  region=${region}

   Create Org  orgtype=operator
   RestrictedOrg Update
   ${cloudlet}=  Create Cloudlet  region=${region}

   Should Be True  ${cloudlet['data']['created_at']['seconds']} > 0
   Should Be True  ${cloudlet['data']['created_at']['nanos']} > 0

   ${created_secs}=  Set Variable  ${cloudlet['data']['created_at']['seconds']}
   ${created_nanos}=   Set Variable  ${cloudlet['data']['created_at']['nanos']}
   Set Suite Variable  ${created_secs}
   Set Suite Variable  ${created_nanos}

   ${operator}=  Get Default Organization Name
   ${cloudlet}=  Get Default Cloudlet Name
   #${flavor_name_default}=  Get Default Flavor Name
   #Set Suite Variable  ${flavor_name_default}
   Set Suite Variable  ${operator}
   Set Suite Variable  ${cloudlet}

Teardown
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  maintenance_state=NormalOperation
   Cleanup Provisioning
