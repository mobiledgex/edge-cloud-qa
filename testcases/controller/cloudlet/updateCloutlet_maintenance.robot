*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Teardown  teardown

*** Variables ***
${cloudlet}=  tmocloud-1
${operator}=  dmuus
${region}=  US

*** Test Cases ***
UpdateCloudlet - shall be able to put cloudlet in maintenance=NormalOperation
   [Documentation]   UpdateCloudlet - invalid maintenance mode shall return error
   ...  send UpdateCloudlet with invalid maintenance mode
   ...  verify correct error is received

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False

   Should Not Contain  ${ret['data']}  maintenance_state  # we dont show 0 vaules

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False

   Should Not Contain  ${ret['data']}  maintenance_state  # we dont show 0 vaules

UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStart
   [Documentation]   UpdateCloudlet - invalid maintenance mode shall return error
   ...  send UpdateCloudlet with invalid maintenance mode
   ...  verify correct error is received

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStartNoFailover
   [Documentation]   UpdateCloudlet - invalid maintenance mode shall return error
   ...  send UpdateCloudlet with invalid maintenance mode
   ...  verify correct error is received

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

UpdateCloudlet - shall be able to put cloudlet in maintenance=MaintenanceStartNoFailover to maintenance=MaintenanceStart
   [Documentation]   UpdateCloudlet - invalid maintenance mode shall return error
   ...  send UpdateCloudlet with invalid maintenance mode
   ...  verify correct error is received

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover     use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart     use_defaults=False

   Should Be Equal As Integers  ${ret['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

*** Keywords ***
teardown
   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation      use_defaults=False
