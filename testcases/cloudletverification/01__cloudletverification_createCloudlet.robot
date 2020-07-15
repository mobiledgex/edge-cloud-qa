*** Settings ***
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout    ${test_timeout}

*** Variables ***
${cloudlet_name}  automationHawkinsCloudlet
${operator_name}  GDDT
${physical_name}  hawkins

${test_timeout}  32 min

*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on Openstack 
   [Documentation]  
   ...  do CreateCloudlet to start a CRM 
   [Tags]  cloudlet  create

   Log To Console  \nCreating Cloudlet

   Create Cloudlet  region=EU  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  platform_type=${cloudlet_platform_type}  physical_name=${physical_name}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=${cloudlet_env_vars}

   Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  mapping=gpu=${gpu_resource_name}
   Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name}  tags=pci=t4gpu:1

   Log To Console  \nCreating Cloudlet Done

#*** Keywords ***
#Cleanup Clusters and Apps
#   [Arguments]  ${region}  ${cloudlet_name}
#  
#   Run Keyword and Continue on Failure  Delete All App Instances      region=${region}  cloudlet_name=${cloudlet_name_openstack}
#   Run Keyword and Continue on Failure  Delete All Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_openstack}


