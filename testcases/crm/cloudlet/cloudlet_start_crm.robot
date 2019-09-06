*** Settings ***
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${cloudlet_name_openstack}  automationHawkinsCloudlet
${operator_name_openstack}  GDDT
${physical_name_openstack}  hawkins

*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on Openstack 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on openstack 

        Create Cloudlet  region=US  operator_name=${operator_name_openstack}   cloudlet_name=${cloudlet_name_openstack}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254     latitude=35     longitude=-96

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on openstack 

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack}   cloudlet_name=${cloudlet_name_openstack}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254     latitude=35     longitude=-96

