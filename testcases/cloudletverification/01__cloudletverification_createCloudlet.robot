*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  auto_login=${False}
#Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout    ${test_timeout}

*** Variables ***
${cloudlet_name}  automationHamburgCloudlet
${operator_name}  TDG
${physical_name}  hamburg
${cloudlet_platform_type}  fromcloudletvarsfile
${s_timeout}  1200
*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on platform specified 
   [Documentation]  
   ...  do CreateCloudlet to start a CRM 
   [Tags]  cloudlet  create

   Log To Console  \nCreating Cloudlet ${cloudlet_platform_type}


   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'   Platform Type Openstack
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeVsphere'     Platform Type Vsphere
   Run Keyword If  '${cloudlet_platform_type}' == 'PlatformTypeVcd'         Platform Type VCD   ELSE  Platform Not Supported

*** Keywords ***

Platform Type Openstack
   Create Cloudlet  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  platform_type=${cloudlet_platform_type}  physical_name=${physical_name}  number_dynamic_ips=${cloudlet_numdynamicips}  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  env_vars=${cloudlet_env_vars}

   Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  mapping=gpu=${gpu_resource_name}
   Add Resource Tag  region=${region}  resource_name=${gpu_resource_name}  operator_org_name=${operator_name}  tags=pci=t4gpu:1

   Log To Console  \nCreating Cloudlet ${cloudlet_platform_type} Done

Platform Type Vsphere
   Create Cloudlet  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  platform_type=${cloudlet_platform_type}  physical_name=${physical_name}  infra_config_flavor_name=${cloudlet_infraconfig_flavorname}  number_dynamic_ips=${cloudlet_numdynamicips}  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  env_vars=${cloudlet_env_vars}

#Options for platform like GPU if supported
#   Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  mapping=gpu=${gpu_resource_name}
#   Add Resource Tag  region=${region}  resource_name=${gpu_resource_name}  operator_org_name=${operator_name}  tags=pci=t4gpu:1

   Log To Console  \nCreating Cloudlet ${cloudlet_platform_type} Done

Platform Type VCD
   Create Cloudlet  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  platform_type=${cloudlet_platform_type}  physical_name=${physical_name}  infra_config_flavor_name=${cloudlet_infraconfig_flavorname}  number_dynamic_ips=${cloudlet_numdynamicips}  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  env_vars=${cloudlet_env_vars}  timeout=${s_timeout}

#Options for platform like GPU if supported 
#   Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  mapping=gpu=${gpu_resource_name}
#   Add Resource Tag  region=${region}  resource_name=${gpu_resource_name}  operator_org_name=${operator_name}  tags=pci=t4gpu:1

   Log To Console  \nCreating Cloudlet ${cloudlet_platform_type} Done

Platform Not Supported
   Log To Console  \nNot Creating ${cloudlet_platform_type} this platform is not supported  
   Should Contain Any  ${cloudlet_platform_type}  PlatformTypeOpenstack  PlatformTypeVsphere  PlatformTypeVcd 

#Cleanup Clusters and Apps
#   [Arguments]  ${region}  ${cloudlet_name}
#  
#   Run Keyword and Continue on Failure  Delete All App Instances      region=${region}  cloudlet_name=${cloudlet_name_openstack}
#   Run Keyword and Continue on Failure  Delete All Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_openstack}


