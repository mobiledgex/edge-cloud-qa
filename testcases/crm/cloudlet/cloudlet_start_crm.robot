*** Settings ***
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack}  automationHawkinsCloudlet
${operator_name_openstack}  GDDT
${physical_name_openstack}  hawkins
${cloudlet_name_openstack_buckhorn}  automationBuckhornCloudlet
${operator_name_openstack_buckhorn}  GDDT
${physical_name_openstack_buckhorn}  buckhorn

${test_timeout_crm}  15 min

*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on Openstack Hawkins 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on hawkins openstack 

        Create Cloudlet  region=US  operator_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=35  longitude=-96

CreateCloudlet - User shall be able to create a cloudlet on Openstack Buckhorn
        [Documentation]
        ...  do CreateCloudlet to start a CRM on buckhorn openstack

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_buckhorn}  cloudlet_name=${cloudlet_name_openstack_buckhorn}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_buckhorn}  number_dynamic_ips=254  latitude=50.73438    longitude=7.09549  env_vars=FLAVOR_MATCH_PATTERN=m4

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on hawkins openstack 

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=35  longitude=-96

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Buckhorn
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on buckhorn openstack

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_buckhorn}   cloudlet_name=${cloudlet_name_openstack_buckhorn}

