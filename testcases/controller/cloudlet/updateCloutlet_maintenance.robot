*** Settings ***
Documentation   UpdateCloudlet with maintenance states

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp

Test Setup     Setup
Test Teardown  Teardown

*** Variables ***
${cloudlet}=  tmocloud-1
${operator}=  dmuus
${region}=  US

*** Test Cases ***
# ECQ-2443
UpdateCloudlet - shall be able to put cloudlet in maintenance=NormalOperation
   [Documentation]
   ...  - send UpdateCloudlet with maintenance=NormalOperation
   ...  - verify maintenance_state is correct

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
   ${updated_epoch1}=  Convert to Epoch  ${ret['data']['updated_at']}   

   Should Not Contain  ${ret['data']}  maintenance_state  # we dont show 0 vaules

   #Should Be True  ${ret['data']['updated_at']['seconds']} > ${created_secs}
   #Should Be True  ${ret['data']['updated_at']['nanos']} > 0
   Should Be True  ${updated_epoch1} > ${created_epoch}

   Sleep  1s

   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
   ${updated_epoch2}=  Convert to Epoch  ${ret2['data']['updated_at']}

   Should Not Contain  ${ret2['data']}  maintenance_state  # we dont show 0 vaules

   #Should Be True  ${ret2['data']['updated_at']['seconds']} > ${ret['data']['updated_at']['seconds']} 
   #Should Be True  ${ret2['data']['updated_at']['nanos']} > 0 
   Should Be True  ${updated_epoch2} > ${updated_epoch1}

# ECQ-2444
UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStart
   [Documentation]
   ...  - send UpdateCloudlet with maintenance=MaintenanceStart
   ...  - verify maintenance_state is correct

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False
   ${updated_epoch1}=  Convert to Epoch  ${ret['data']['updated_at']}

   Should Be Equal    ${ret['data']['maintenance_state']}  UnderMaintenance  # UNDER_MAINTENANCE

   #Should Be True  ${ret['data']['updated_at']['seconds']} > ${created_secs}
   #Should Be True  ${ret['data']['updated_at']['nanos']} > 0
   Should Be True  ${updated_epoch1} > ${created_epoch}

   Sleep  1s

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False
   ${updated_epoch2}=  Convert to Epoch  ${ret2['data']['updated_at']}

   Should Be Equal    ${ret2['data']['maintenance_state']}  UnderMaintenance  # UNDER_MAINTENANCE

   #Should Be True  ${ret2['data']['updated_at']['seconds']} > ${ret['data']['updated_at']['seconds']}
   #Should Be True  ${ret2['data']['updated_at']['nanos']} > 0
   Should Be True  ${updated_epoch2} > ${updated_epoch1}

# ECQ-2445
UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStartNoFailover
   [Documentation]
   ...  - send UpdateCloudlet with maintenance=MaintenanceStartNoFailover
   ...  - verify maintenance_state is correct

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False
   ${updated_epoch1}=  Convert to Epoch  ${ret['data']['updated_at']}

   Should Be Equal    ${ret['data']['maintenance_state']}  UnderMaintenance  # UNDER_MAINTENANCE

   #Should Be True  ${ret['data']['updated_at']['seconds']} > ${created_secs}
   #Should Be True  ${ret['data']['updated_at']['nanos']} > 0
   Should Be True  ${updated_epoch1} > ${created_epoch}

   Sleep  1s

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False
   ${updated_epoch2}=  Convert to Epoch  ${ret2['data']['updated_at']}

   Should Be Equal    ${ret2['data']['maintenance_state']}  UnderMaintenance  # UNDER_MAINTENANCE

   #Should Be True  ${ret2['data']['updated_at']['seconds']} > ${ret['data']['updated_at']['seconds']}
   #Should Be True  ${ret2['data']['updated_at']['nanos']} > 0
   Should Be True  ${updated_epoch2} > ${updated_epoch1}

# ECQ-2446
UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStartNoFailover to maintenance=MaintenanceStart
   [Documentation]
   ...  - send UpdateCloudlet with maintenance=MaintenanceStartNoFailover
   ...  - verify maintenance_state is correct
   ...  - send UpdateCloudlet with maintenance=MaintenanceStart
   ...  - verify maintenance_state is correct

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover     use_defaults=False
   ${updated_epoch1}=  Convert to Epoch  ${ret['data']['updated_at']}

   Should Be Equal    ${ret['data']['maintenance_state']}  UnderMaintenance  # UNDER_MAINTENANCE

   #Should Be True  ${ret['data']['updated_at']['seconds']} > ${created_secs}
   #Should Be True  ${ret['data']['updated_at']['nanos']} > 0
   Should Be True  ${updated_epoch1} > ${created_epoch}

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False
   ${updated_epoch2}=  Convert to Epoch  ${ret2['data']['updated_at']}

   Should Be Equal    ${ret2['data']['maintenance_state']}  UnderMaintenance  # UNDER_MAINTENANCE

   #Should Be True  ${ret2['data']['updated_at']['seconds']} > ${ret['data']['updated_at']['seconds']}
   #Should Be True  ${ret2['data']['updated_at']['nanos']} > 0
   Should Be True  ${updated_epoch2} > ${updated_epoch1}

*** Keywords ***
Setup
   ${current_date}=   Fetch Current Date
   Create Flavor  region=${region}

   Create Org  orgtype=operator
   RestrictedOrg Update
   ${cloudlet}=  Create Cloudlet  region=${region}

   #Should Be True  ${cloudlet['data']['created_at']['seconds']} > 0
   #Should Be True  ${cloudlet['data']['created_at']['nanos']} > 0

   Should Contain   ${cloudlet['data']['created_at']}   ${current_date}

   ${created_epoch}=  Convert To Epoch   ${cloudlet['data']['created_at']}
   #${created_secs}=  Set Variable  ${cloudlet['data']['created_at']['seconds']}
   #${created_nanos}=   Set Variable  ${cloudlet['data']['created_at']['nanos']}
   #Set Suite Variable  ${created_secs}
   #Set Suite Variable  ${created_nanos}
   Set Suite Variable   ${created_epoch}

   ${operator}=  Get Default Organization Name
   ${cloudlet}=  Get Default Cloudlet Name
   #${flavor_name_default}=  Get Default Flavor Name
   #Set Suite Variable  ${flavor_name_default}
   Set Suite Variable  ${operator}
   Set Suite Variable  ${cloudlet}

Teardown
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  maintenance_state=NormalOperation
   Cleanup Provisioning
