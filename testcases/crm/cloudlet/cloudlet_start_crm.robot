*** Settings ***
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_hawkins}  automationHawkinsCloudlet
${operator_name_openstack_hawkins}  GDDT
${physical_name_openstack_hawkins}  hawkins
${cloudlet_name_openstack_buckhorn}  automationBuckhornCloudlet
${operator_name_openstack_buckhorn}  GDDT
${physical_name_openstack_buckhorn}  buckhorn
${cloudlet_name_openstack_beacon}  automationBeaconCloudlet
${operator_name_openstack_beacon}  GDDT
${physical_name_openstack_beacon}  beacon
${cloudlet_name_openstack_sunnydale}  automationSunnydaleCloudlet
${operator_name_openstack_sunnydale}  GDDT
${physical_name_openstack_sunnydale}  sunnydale

${test_timeout_crm}  15 min

*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on Openstack Hawkins 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on hawkins openstack 

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_hawkins}  cloudlet_name=${cloudlet_name_openstack_hawkins}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_hawkins}  number_dynamic_ips=254  latitude=35  longitude=-96

CreateCloudlet - User shall be able to create a cloudlet on Openstack Buckhorn
        [Documentation]
        ...  do CreateCloudlet to start a CRM on buckhorn openstack

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_buckhorn}  cloudlet_name=${cloudlet_name_openstack_buckhorn}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_buckhorn}  number_dynamic_ips=254  latitude=50.73438    longitude=7.09549  env_vars=FLAVOR_MATCH_PATTERN=m4

CreateCloudlet - User shall be able to create a cloudlet on Openstack Beacon 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on beacon openstack 

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_beacon}  cloudlet_name=${cloudlet_name_openstack_beacon}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_beacon}  number_dynamic_ips=254  latitude=35  longitude=-96

CreateCloudlet - User shall be able to create a cloudlet on Openstack Sunnydale 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on sunnydale openstack 

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_sunnydale}  cloudlet_name=${cloudlet_name_openstack_sunnydale}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_sunnydale}  number_dynamic_ips=254  latitude=35  longitude=-96


DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Hawkins
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on hawkins openstack 

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_hawkins}  cloudlet_name=${cloudlet_name_openstack_hawkins}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Buckhorn
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on buckhorn openstack

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_buckhorn}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_buckhorn}

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_buckhorn}   cloudlet_name=${cloudlet_name_openstack_buckhorn}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Beacon
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on beacon openstack 

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_beacon}  cloudlet_name=${cloudlet_name_openstack_beacon}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Sunnydale
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on sunnydale openstack 

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_sunnydale}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_sunnydale}

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_sunnydale}  cloudlet_name=${cloudlet_name_openstack_sunnydale}

