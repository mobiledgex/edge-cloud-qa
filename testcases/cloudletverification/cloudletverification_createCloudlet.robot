*** Settings ***
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_create}  automationHamburgCloudlet
${operator_name_openstack}  TDG
${physical_name_openstack}  hamburg

${test_timeout_crm}  60 min

*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on Openstack Hamburg 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on hamburg openstack 

        Create Cloudlet  region=EU  operator_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack_create}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682


DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Hamburg
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on hamburg openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_create}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_create}

        Delete Cloudlet  region=EU  operator_name=${operator_name_openstack_create}  cloudlet_name=${cloudlet_name_openstack_create}

*** Keywords ***
Cleanup Clusters and Apps
   [Arguments]  ${region}  ${cloudlet_name}
  
   Run Keyword and Continue on Failure  Delete All App Instances      region=${region}  cloudlet_name=${cloudlet_name}
   Run Keyword and Continue on Failure  Delete All Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name}


