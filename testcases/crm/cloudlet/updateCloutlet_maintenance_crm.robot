*** Settings ***
Documentation   UpdateCloudlet with maintenance states

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup     Setup
#Test Teardown  Teardown

*** Variables ***
${cloudlet}=  tmocloud-1
${operator_openstack}=  TDG
${region}=  US

*** Test Cases ***
# ECQ-2453
UpdateCloudlet - shall be able to put cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet for openstack cloudlet with maintenance=NormalOperation,MaintenanceStart,MaintenanceStartNoFailover
   ...  - verify maintenance_state is correct

   ${ret1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_crm}     cloudlet_name=${cloudlet_name_crm}     maintenance_state=MaintenanceStart      use_defaults=False
   Should Be Equal As Integers  ${ret1['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_crm}     cloudlet_name=${cloudlet_name_crm}     maintenance_state=NormalOperation      use_defaults=False
   Should Not Contain  ${ret2['data']}  maintenance_state  # we dont show 0 vaules

   ${ret3}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_crm}     cloudlet_name=${cloudlet_name_crm}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False
   Should Be Equal As Integers  ${ret3['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret4}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_crm}     cloudlet_name=${cloudlet_name_crm}     maintenance_state=NormalOperation      use_defaults=False
   Should Not Contain  ${ret4['data']}  maintenance_state  # we dont show 0 vaules

   [Teardown]  Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  maintenance_state=NormalOperation  use_defaults=False

# ECQ-2454
UpdateCloudlet - shall be able to put openstack vmpool cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet for openstack vmpool cloudlet with maintenance=NormalOperation,MaintenanceStart,MaintenanceStartNoFailover
   ...  - verify maintenance_state is correct

   ${ret1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}     cloudlet_name=${cloudlet_name_vmpool}     maintenance_state=MaintenanceStart      use_defaults=False
   Should Be Equal As Integers  ${ret1['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}     cloudlet_name=${cloudlet_name_vmpool}     maintenance_state=NormalOperation      use_defaults=False
   Should Not Contain  ${ret2['data']}  maintenance_state  # we dont show 0 vaules

   ${ret3}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}     cloudlet_name=${cloudlet_name_vmpool}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False
   Should Be Equal As Integers  ${ret3['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret4}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}     cloudlet_name=${cloudlet_name_vmpool}     maintenance_state=NormalOperation      use_defaults=False
   Should Not Contain  ${ret4['data']}  maintenance_state  # we dont show 0 vaules

   [Teardown]  Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_openstack}  maintenance_state=NormalOperation  use_defaults=False

# consolidated with 2453
# ECQ-2455
#UpdateCloudlet - shall be able to put vsphere cloudlet in maintenance mode
#   [Documentation]
#   ...  - send UpdateCloudlet for vsphere cloudlet with maintenance=NormalOperation,MaintenanceStart,MaintenanceStartNoFailover
#   ...  - verify maintenance_state is correct
#
#   ${ret1}=  Update Cloudlet  region=${region_vsphere}  operator_org_name=${operator_name_vsphere}     cloudlet_name=${cloudlet_name_vsphere}     maintenance_state=MaintenanceStart      use_defaults=False
#   Should Be Equal As Integers  ${ret1['data']['maintenance_state']}  31  # UNDER_MAINTENANCE
#
#   ${ret2}=  Update Cloudlet  region=${region_vsphere}  operator_org_name=${operator_name_vsphere}     cloudlet_name=${cloudlet_name_vsphere}     maintenance_state=NormalOperation      use_defaults=False
#   Should Not Contain  ${ret2['data']}  maintenance_state  # we dont show 0 vaules
#
#   ${ret3}=  Update Cloudlet  region=${region_vsphere}  operator_org_name=${operator_name_vsphere}     cloudlet_name=${cloudlet_name_vsphere}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False
#   Should Be Equal As Integers  ${ret3['data']['maintenance_state']}  31  # UNDER_MAINTENANCE
#
#   ${ret4}=  Update Cloudlet  region=${region_vsphere}  operator_org_name=${operator_name_vsphere}     cloudlet_name=${cloudlet_name_vsphere}     maintenance_state=NormalOperation      use_defaults=False
#   Should Not Contain  ${ret4['data']}  maintenance_state  # we dont show 0 vaules
#
#   [Teardown]  Update Cloudlet  region=${region_vsphere}  cloudlet_name=${cloudlet_name_vsphere}  operator_org_name=${operator_name_vsphere}  maintenance_state=NormalOperation  use_defaults=False

# ECQ-2456
UpdateCloudlet - shall be able to put GCP cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet for gcp cloudlet with maintenance=NormalOperation,MaintenanceStart,MaintenanceStartNoFailover
   ...  - verify maintenance_state is correct

   ${ret1}=  Update Cloudlet  region=${region_gcp}  operator_org_name=${operator_name_gcp}     cloudlet_name=${cloudlet_name_gcp}     maintenance_state=MaintenanceStart      use_defaults=False
   Should Be Equal As Integers  ${ret1['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret2}=  Update Cloudlet  region=${region_gcp}  operator_org_name=${operator_name_gcp}     cloudlet_name=${cloudlet_name_gcp}     maintenance_state=NormalOperation      use_defaults=False
   Should Not Contain  ${ret2['data']}  maintenance_state  # we dont show 0 vaules

   ${ret3}=  Update Cloudlet  region=${region_gcp}  operator_org_name=${operator_name_gcp}     cloudlet_name=${cloudlet_name_gcp}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False
   Should Be Equal As Integers  ${ret3['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret4}=  Update Cloudlet  region=${region_gcp}  operator_org_name=${operator_name_gcp}     cloudlet_name=${cloudlet_name_gcp}     maintenance_state=NormalOperation      use_defaults=False
   Should Not Contain  ${ret4['data']}  maintenance_state  # we dont show 0 vaules

   [Teardown]  Update Cloudlet  region=${region_gcp}  cloudlet_name=${cloudlet_name_gcp}  operator_org_name=${operator_name_gcp}  maintenance_state=NormalOperation  use_defaults=False

# ECQ-2457
UpdateCloudlet - shall be able to put Azure cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet for azure with maintenance=NormalOperation,MaintenanceStart,MaintenanceStartNoFailover
   ...  - verify maintenance_state is correct

   ${ret1}=  Update Cloudlet  region=${region_azure}  operator_org_name=${operator_name_azure}     cloudlet_name=${cloudlet_name_azure}     maintenance_state=MaintenanceStart      use_defaults=False
   Should Be Equal As Integers  ${ret1['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret2}=  Update Cloudlet  region=${region_azure}  operator_org_name=${operator_name_azure}     cloudlet_name=${cloudlet_name_azure}     maintenance_state=NormalOperation      use_defaults=False
   Should Not Contain  ${ret2['data']}  maintenance_state  # we dont show 0 vaules

   ${ret3}=  Update Cloudlet  region=${region_azure}  operator_org_name=${operator_name_azure}     cloudlet_name=${cloudlet_name_azure}     maintenance_state=MaintenanceStartNoFailover      use_defaults=False
   Should Be Equal As Integers  ${ret3['data']['maintenance_state']}  31  # UNDER_MAINTENANCE

   ${ret4}=  Update Cloudlet  region=${region_azure}  operator_org_name=${operator_name_azure}     cloudlet_name=${cloudlet_name_azure}     maintenance_state=NormalOperation      use_defaults=False
   Should Not Contain  ${ret4['data']}  maintenance_state  # we dont show 0 vaules

   [Teardown]  Update Cloudlet  region=${region_azure}  cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  maintenance_state=NormalOperation  use_defaults=False

#*** Keywords ***
#Teardown
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_openstack}  maintenance_state=NormalOperation

