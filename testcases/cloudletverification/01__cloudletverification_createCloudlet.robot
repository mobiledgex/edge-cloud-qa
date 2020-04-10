*** Settings ***
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout    ${test_timeout}

*** Variables ***
${cloudlet_name_openstack}  automationHawkinsCloudlet
${operator_name_openstack}  GDDT
${physical_name_openstack}  hawkins

${test_timeout}  32 min

*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on Openstack 
   [Documentation]  
   ...  do CreateCloudlet to start a CRM on openstack 
   [Tags]  cloudlet  create

   Log To Console  \nCreating Cloudlet

   Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=MEX_SECURITY_GROUP=cloudletverifcation

   Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  mapping=gpu=${gpu_resource_name}
   Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack}  tags=pci=t4gpu:1

   Log To Console  \nCreating Cloudlet Done

#DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Hawkins
#        [Documentation]
#        ...  do DeleteCloudlet to delete a CRM on hawkins openstack 
#
#        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack}
#        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack}
#
#        Delete Cloudlet  region=EU  operator_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}

#*** Keywords ***
#Cleanup Clusters and Apps
#   [Arguments]  ${region}  ${cloudlet_name}
#  
#   Run Keyword and Continue on Failure  Delete All App Instances      region=${region}  cloudlet_name=${cloudlet_name_openstack}
#   Run Keyword and Continue on Failure  Delete All Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_openstack}


