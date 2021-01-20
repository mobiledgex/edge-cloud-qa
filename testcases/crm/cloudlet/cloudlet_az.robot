*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout   25 min 

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${cloudlet_name_openstack_az}  automationAz 
${operator_name_openstack_az}  packet
${physical_name_openstack_az}  packet

${region}=  US

${test_timeout_crm}  60 min

*** Test Cases ***
# ECQ-2979
CreateCloudlet - User shall be able to create a cloudlet with availability zone
   [Documentation]
   ...  - do CreateCloudlet with MEX_COMPUTE_AVAILABILITY_ZONE set
   ...  - verify it is created successfully

   Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_az}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_az}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=MEX_COMPUTE_AVAILABILITY_ZONE=qa-az,MEX_VOLUME_AVAILABILITY_ZONE=qa-az

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_az}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=1  shared_volume_size=1  #cloudlet_name=cloudlet1608134578-458848

CreateCloudlet - CreateClusterInst with shared volumes on cloudlet with bad MEX_VOLUME_AVAILABILITY shall return error
   [Documentation]
   ...  - do CreateCloudlet with unknown MEX_VOLUME_AVAILABILITY
   ...  - do CreateClusterInst with shared volumes
   ...  - verify error is received

   Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_az}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_az}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=MEX_COMPUTE_AVAILABILITY_ZONE=qa-az,MEX_VOLUME_AVAILABILITY_ZONE=qa-qz

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_az}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=1  shared_volume_size=1

   Should Contain  ${error}  Availability zone \'qa-qz\' is invalid

# ECQ-2980
CreateCloudlet - create with unknown availability zone shall return error
   [Documentation]
   ...  - do CreateCloudlet with MEX_COMPUTE_AVAILABILITY_ZONE that doesnt exist
   ...  - verify error is received

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet  region=US  operator_org_name=${operator_name_openstack_az}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_az}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=MEX_COMPUTE_AVAILABILITY_ZONE=qa-az2,MEX_VOLUME_AVAILABILITY_ZONE=qa-qz2

   Should Contain  ${error}  The requested availability zone is not available


*** Keywords ***
Setup
   Create Flavor  region=${region}
