*** Settings ***
Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  OperatingSystem

Test Timeout    ${test_timeout_crm}

Test Setup  Setup

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
${cloudlet_name_openstack_dusseldorf}  automationDusseldorfCloudlet
${operator_name_openstack_dusseldorf}  TDG
${physical_name_openstack_dusseldorf}  dusseldorf 

${version}  version

${test_timeout_crm}  60 min

*** Test Cases ***
CreateCloudlet - User shall be able to create a cloudlet on Openstack Hamburg 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on hamburg openstack 

        Create Cloudlet  region=EU  operator_name=${operator_name_openstack_hamburg}  cloudlet_name=${cloudlet_name_openstack_hamburg}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_hamburg}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682

CreateCloudlet - User shall be able to create a cloudlet on Openstack Bonn
        [Documentation]
        ...  do CreateCloudlet to start a CRM on bonn openstack

        Create Cloudlet  region=EU  operator_name=${operator_name_openstack_bonn}  cloudlet_name=${cloudlet_name_openstack_bonn}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_bonn}  number_dynamic_ips=254  latitude=50.73438    longitude=7.09549  env_vars=FLAVOR_MATCH_PATTERN=m4

CreateCloudlet - User shall be able to create a cloudlet on Openstack Berlin 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on berlin openstack 

        Create Cloudlet  region=EU  operator_name=${operator_name_openstack_berlin}  cloudlet_name=${cloudlet_name_openstack_berlin}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_berlin}  number_dynamic_ips=254  latitude=52.520007  longitude=13.404954

CreateCloudlet - User shall be able to create a cloudlet on Openstack Munich 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on munich openstack 

        Create Cloudlet  region=EU  operator_name=${operator_name_openstack_munich}  cloudlet_name=${cloudlet_name_openstack_munich}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_munich}  number_dynamic_ips=254  latitude=48.1351253  longitude=11.5819806

CreateCloudlet - User shall be able to create a cloudlet on Openstack Frankfurt 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on frankfurt openstack

        Create Cloudlet  region=EU  operator_name=${operator_name_openstack_frankfurt}  cloudlet_name=${cloudlet_name_openstack_frankfurt}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_frankfurt}  number_dynamic_ips=254  latitude=50.110922  longitude=8.682127

CreateCloudlet - User shall be able to create a cloudlet on Openstack Dusseldorf 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on dusseldorf openstack

        Create Cloudlet  region=EU  operator_name=${operator_name_openstack_dusseldorf}  cloudlet_name=${cloudlet_name_openstack_dusseldorf}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_dusseldorf}  number_dynamic_ips=254  latitude=51.2277  longitude=6.7735

CreateCloudlet - User shall be able to create a cloudlet on Openstack Packet 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on packet openstack

        Create Cloudlet  region=US  operator_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name_openstack_packet}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=41.881832  longitude=-87.623177

CreateCloudlet - User shall be able to create a fake cloudlet
        [Documentation]
        ...  do CreateCloudlet to start a fake CRM 

        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_name=tmus  cloudlet_name=tmocloud-1  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91
        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_name=tmus  cloudlet_name=tmocloud-2  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=35  longitude=-95
        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_name=att  cloudlet_name=attcloud-1  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=35  longitude=-96

        Create App Instance  region=US  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterAutomation  cloudlet_name=tmocloud-1  operator_name=tmus  flavor_name=automation_api_flavor

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Hamburg
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on hamburg openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_hamburg}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_hamburg}

        Delete Cloudlet  region=EU  operator_name=${operator_name_openstack_hamburg}  cloudlet_name=${cloudlet_name_openstack_hamburg}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Bonn
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on bonn openstack

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_bonn}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_bonn}

        Delete Cloudlet  region=EU  operator_name=${operator_name_openstack_bonn}   cloudlet_name=${cloudlet_name_openstack_bonn}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Berlin
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on berlin openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_berlin}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_berlin}

        Delete Cloudlet  region=EU  operator_name=${operator_name_openstack_berlin}  cloudlet_name=${cloudlet_name_openstack_berlin}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Munich
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on munich openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_munich}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_munich}

        Delete Cloudlet  region=EU  operator_name=${operator_name_openstack_munich}  cloudlet_name=${cloudlet_name_openstack_munich}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Frankfurt 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on frankfurt openstack

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_frankfurt}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_frankfurt}

        Delete Cloudlet  region=EU  operator_name=${operator_name_openstack_frankfurt}  cloudlet_name=${cloudlet_name_openstack_frankfurt}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Dusseldorf 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on dusseldorf openstack

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_dusseldorf}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_dusseldorf}

        Delete Cloudlet  region=EU  operator_name=${operator_name_openstack_dusseldorf}  cloudlet_name=${cloudlet_name_openstack_dusseldorf}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Packet 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on packet openstack

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_packet}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_packet}

        Delete Cloudlet  region=US  operator_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name_openstack_packet}

DeleteCloudlet - User shall be able to delete a fake cloudlet
        [Documentation]
        ...  do DeleteCloudlet to delete a fake CRM 

        Cleanup Clusters and Apps  region=US  cloudlet_name=tmocloud-1  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_name=tmus  cloudlet_name=tmocloud-1

        Cleanup Clusters and Apps  region=US  cloudlet_name=tmocloud-2  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_name=tmus  cloudlet_name=tmocloud-2

        Cleanup Clusters and Apps  region=US  cloudlet_name=attcloud-1  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_name=att  cloudlet_name=attcloud-1

UpgradeCloudlet - User shall be able to upgrade a cloudlet on Openstack Bonn
        [Documentation]
        ...  do UpdateCloudlet to upgrade a CRM on bonn openstack

        Update Cloudlet  region=EU  operator_name=${operator_name_openstack_bonn}  cloudlet_name=${cloudlet_name_openstack_bonn}  version=${version}  use_defaults=${False}

UpgradeCloudlet - User shall be able to upgrade a cloudlet on Openstack Munich 
        [Documentation]
        ...  do UpdateCloudlet to upgrade a CRM on munich openstack

        Update Cloudlet  region=EU  operator_name=${operator_name_openstack_munich}  cloudlet_name=${cloudlet_name_openstack_munich}  version=${version}  use_defaults=${False}

UpgradeCloudlet - User shall be able to upgrade a cloudlet on Openstack Hamburg 
        [Documentation]
        ...  do UpdateCloudlet to upgrade a CRM on hamburg openstack

        Update Cloudlet  region=EU  operator_name=${operator_name_openstack_hamburg}  cloudlet_name=${cloudlet_name_openstack_hamburg}  version=${version}  use_defaults=${False}

UpgradeCloudlet - User shall be able to upgrade a cloudlet on Openstack Frankfurt 
        [Documentation]
        ...  do UpdateCloudlet to upgrade a CRM on frankfurt openstack

        Update Cloudlet  region=EU  operator_name=${operator_name_openstack_frankfurt}  cloudlet_name=${cloudlet_name_openstack_frankfurt}  version=${version}  use_defaults=${False}

UpgradeCloudlet - User shall be able to upgrade a cloudlet on Openstack Dusseldorf
        [Documentation]
        ...  do UpdateCloudlet to upgrade a CRM on dusseldorf openstack

        Update Cloudlet  region=EU  operator_name=${operator_name_openstack_dusseldorf}  cloudlet_name=${cloudlet_name_openstack_dusseldorf}  version=${version}  use_defaults=${False}

*** Keywords ***
Setup
   ${version}=  Get Environment Variable  AUTOMATION_VERSION  version_not_set
   Set Suite Variable  ${version}

Cleanup Clusters and Apps
   [Arguments]  ${region}  ${cloudlet_name}  ${crm_override}=${None}
  
   Run Keyword and Ignore Error  Delete All App Instances      region=${region}  cloudlet_name=${cloudlet_name}  crm_override=${crm_override}
   Run Keyword and Ignore Error  Delete All Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name}  crm_override=${crm_override}


