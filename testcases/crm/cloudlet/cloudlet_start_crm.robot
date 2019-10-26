*** Settings ***
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_hamburg}  automationHamburgCloudlet
${operator_name_openstack_hamburg}  TDG
${physical_name_openstack_hamburg}  hamburg
${cloudlet_name_openstack_bonn}  automationBonnCloudlet
${operator_name_openstack_bonn}  TDG
${physical_name_openstack_bonn}  bonn
${cloudlet_name_openstack_berlin}  automationBerlinCloudlet
${operator_name_openstack_berlin}  TDG
${physical_name_openstack_berlin}  berlin
${cloudlet_name_openstack_munich}  automationMunichCloudlet
${operator_name_openstack_munich}  TDG
${physical_name_openstack_munich}  munich
${cloudlet_name_openstack_frankfurt}  automationFrankfurtCloudlet
${operator_name_openstack_frankfurt}  TDG
${physical_name_openstack_frankfurt}  frankfurt 
${cloudlet_name_openstack_packet}  automationPacketOrd2Cloudlet
${operator_name_openstack_packet}  TDG
${physical_name_openstack_packet}  packet-ord2 

${test_timeout_crm}  15 min

*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on Openstack Hamburg 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on hamburg openstack 

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_hamburg}  cloudlet_name=${cloudlet_name_openstack_hamburg}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_hamburg}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682

CreateCloudlet - User shall be able to create a cloudlet on Openstack Bonn
        [Documentation]
        ...  do CreateCloudlet to start a CRM on bonn openstack

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_bonn}  cloudlet_name=${cloudlet_name_openstack_bonn}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_bonn}  number_dynamic_ips=254  latitude=50.73438    longitude=7.09549  env_vars=FLAVOR_MATCH_PATTERN=m4

CreateCloudlet - User shall be able to create a cloudlet on Openstack Berlin 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on berlin openstack 

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_berlin}  cloudlet_name=${cloudlet_name_openstack_berlin}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_berlin}  number_dynamic_ips=254  latitude=52.520007  longitude=13.404954

CreateCloudlet - User shall be able to create a cloudlet on Openstack Munich 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on munich openstack 

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_munich}  cloudlet_name=${cloudlet_name_openstack_munich}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_munich}  number_dynamic_ips=254  latitude=48.1351253 longitude=11.5819806

CreateCloudlet - User shall be able to create a cloudlet on Openstack Frankfurt 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on frankfurt openstack

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_frankfurt}  cloudlet_name=${cloudlet_name_openstack_frankfurt}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_frankfurt}  number_dynamic_ips=254  latitude=50.110922  longitude=8.682127

CreateCloudlet - User shall be able to create a cloudlet on Openstack Packet 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on packet openstack

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name_openstack_packet}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=41.881832  longitude=-87.623177

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Hamburg
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on hamburg openstack 

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_hamburg}  cloudlet_name=${cloudlet_name_openstack_hamburg}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Bonn
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on bonn openstack

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_bonn}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_bonn}

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_bonn}   cloudlet_name=${cloudlet_name_openstack_bonn}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Berlin
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on berlin openstack 

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_berlin}  cloudlet_name=${cloudlet_name_openstack_berlin}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Munich
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on munich openstack 

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_munich}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_munich}

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_munich}  cloudlet_name=${cloudlet_name_openstack_munich}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Frankfurt 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on frankfurt openstack

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_frankfurt}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_frankfurt}

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_frankfurt}  cloudlet_name=${cloudlet_name_openstack_frankfurt}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Packet 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on packet openstack

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_packet}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_packet}

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name_openstack_packet}

