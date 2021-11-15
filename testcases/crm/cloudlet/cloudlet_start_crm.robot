*** Settings ***
Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  OperatingSystem
Library  MexKnife 

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
${cloudlet_name_openstack_packet}  packetcloudlet 
${operator_name_openstack_packet}  packet 
${physical_name_openstack_packet}  packetcloudlet 
${cloudlet_name_openstack_dusseldorf}  automationDusseldorfCloudlet
${operator_name_openstack_dusseldorf}  TDG
${physical_name_openstack_dusseldorf}  dusseldorf 
${operator_name_gcp}  gcp 
${cloudlet_name_anthos}  qa-anthos
${operator_name_anthos}  packet

${gpu_resource_name}  mygpuresrouce

${version}   version
${imgversion}	3.0.3

${test_timeout_crm}  60 min

@{cloudlet_list}   ${cloudlet_name_openstack_hamburg}   ${cloudlet_name_openstack_munich}   ${cloudlet_name_openstack_frankfurt}   ${cloudlet_name_openstack_dusseldorf}
 
*** Test Cases ***
# ECQ-1474
CreateCloudlet - User shall be able to create a cloudlet on Openstack Hamburg 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on hamburg openstack 

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_hamburg}  cloudlet_name=${cloudlet_name_openstack_hamburg}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_hamburg}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  gpudriver_name=nvidia-450  gpudriver_org=TDG

        Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack_hamburg}  operator_org_name=${operator_name_openstack_hamburg}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_hamburg}  tags=pci=t4gpu:1

# ECQ-1498
CreateCloudlet - User shall be able to create a cloudlet on Openstack Bonn
        [Documentation]
        ...  do CreateCloudlet to start a CRM on bonn openstack

        Create Cloudlet  region=US  operator_org_name=${operator_name_openstack_bonn}  cloudlet_name=${cloudlet_name_openstack_bonn}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_bonn}  number_dynamic_ips=254  latitude=50.73438    longitude=7.09549  env_vars=FLAVOR_MATCH_PATTERN=m4,MEX_EXT_NETWORK=external-network-02  gpudriver_name=nvidia-450  gpudriver_org=TDG

        Add Cloudlet Resource Mapping  region=US  cloudlet_name=${cloudlet_name_openstack_bonn}  operator_org_name=${operator_name_openstack_bonn}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=US  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_bonn}  tags=pci=t4gpu:1

# ECQ-1613
CreateCloudlet - User shall be able to create a cloudlet on Openstack Berlin 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on berlin openstack 

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_berlin}  cloudlet_name=${cloudlet_name_openstack_berlin}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_berlin}  number_dynamic_ips=254  latitude=52.520007  longitude=13.404954  gpudriver_name=nvidia-450  gpudriver_org=TDG

        Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack_berlin}  operator_org_name=${operator_name_openstack_berlin}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_berlin}  tags=pci=t4gpu:1

# ECQ-1538
CreateCloudlet - User shall be able to create a cloudlet on Openstack Munich 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on munich openstack 

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_munich}  cloudlet_name=${cloudlet_name_openstack_munich}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_munich}  number_dynamic_ips=254  latitude=48.1351253  longitude=11.5819806  gpudriver_name=nvidia-450  gpudriver_org=TDG

# ECQ-1585
CreateCloudlet - User shall be able to create a cloudlet on Openstack Frankfurt 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on frankfurt openstack

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_frankfurt}  cloudlet_name=${cloudlet_name_openstack_frankfurt}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_frankfurt}  number_dynamic_ips=254  latitude=50.110922  longitude=8.682127  gpudriver_name=nvidia-450  gpudriver_org=TDG

        Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack_frankfurt}  operator_org_name=${operator_name_openstack_frankfurt}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_frankfurt}  tags=pci=t4gpu:1

# ECQ-1635
CreateCloudlet - User shall be able to create a cloudlet on Openstack Dusseldorf 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on dusseldorf openstack

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_dusseldorf}  cloudlet_name=${cloudlet_name_openstack_dusseldorf}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_dusseldorf}  number_dynamic_ips=254  latitude=51.2277  longitude=6.7735  gpudriver_name=nvidia-450  gpudriver_org=TDG

        Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack_dusseldorf}  operator_org_name=${operator_name_openstack_dusseldorf}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_dusseldorf}  tags=pci=t4gpu:1

# ECQ-????
CreateCloudlet - User shall be able to create a cloudlet on Openstack Packet 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on packet openstack

        Create Cloudlet  region=US  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name_openstack_packet}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=41.881832  longitude=-87.623177

# ECQ-1631
CreateCloudlet - User shall be able to create a fake cloudlet
        [Documentation]
        ...  - do CreateCloudlet to start a fake CRM 

        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_org_name=tmus  cloudlet_name=tmocloud-1  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000
        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_org_name=tmus  cloudlet_name=tmocloud-2  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=35  longitude=-95  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000
        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_org_name=att  cloudlet_name=attcloud-1  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=35  longitude=-96  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

        Run Keyword and Ignore Error  Create App  region=US  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  default_flavor_name=${flavor_name_automation}
        Run Keyword and Ignore Error  Create App  region=US  app_name=${app_name_auth_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  default_flavor_name=${flavor_name_automation}  auth_public_key=${app_auth_public_key}
        Create App Instance  region=US  app_name=${app_name_automation}       app_version=1.0  developer_org_name=${developer_org_name_automation}  cluster_instance_name=autoclusterAutomation      cloudlet_name=tmocloud-1  operator_org_name=tmus  flavor_name=${flavor_name_automation}
        #Create App Instance  region=US  app_name=automation_api_auth_app  app_version=1.0  cluster_instance_name=autoclusterAutomationAuth  cloudlet_name=tmocloud-1  operator_org_name=tmus  flavor_name=automation_api_flavor

# ECQ-1457
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Hamburg
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on hamburg openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_hamburg}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_hamburg}

        Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_hamburg}  cloudlet_name=${cloudlet_name_openstack_hamburg}

# ECQ-4067
CreateCloudlet - User shall be able to create a cloudlet on Anthos
        [Documentation]
        ...  - do CreateCloudlet to start a CRM no Anthos

        Create Cloudlet  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  platform_type=PlatformTypeK8sBareMetal  number_dynamic_ips=8  latitude=47.60621  longitude=-122.33207  env_vars=K8S_CONTROL_ACCESS_IP=145.40.103.121,K8S_EXTERNAL_IP_RANGES=147.28.142.200/29-147.28.142.207/29,K8S_EXTERNAL_ETH_INTERFACE=bond0,K8S_INTERNAL_IP_RANGES=none,K8S_INTERNAL_ETH_INTERFACE=none

# ECQ-1499
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Bonn
        [Documentation]
        ...  - do DeleteCloudlet to delete a CRM on bonn openstack

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_bonn}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_bonn}

        Delete Cloudlet  region=US  token=${token}  operator_org_name=${operator_name_openstack_bonn}   cloudlet_name=${cloudlet_name_openstack_bonn}  use_defaults=${False}

# ECQ-1614
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Berlin
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on berlin openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_berlin}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_berlin}

        Delete Cloudlet  region=EU  token=${token}  operator_org_name=${operator_name_openstack_berlin}  cloudlet_name=${cloudlet_name_openstack_berlin}  use_defaults=${False}

# ECQ-1537
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Munich
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on munich openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_munich}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_munich}

        Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_munich}  cloudlet_name=${cloudlet_name_openstack_munich}

# ECQ-1586
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Frankfurt 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on frankfurt openstack

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_frankfurt}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_frankfurt}

        Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_frankfurt}  cloudlet_name=${cloudlet_name_openstack_frankfurt}

# ECQ-1636
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Dusseldorf 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on dusseldorf openstack

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_dusseldorf}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_dusseldorf}

        Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_dusseldorf}  cloudlet_name=${cloudlet_name_openstack_dusseldorf}

DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Packet 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on packet openstack

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_packet}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_packet}

        Delete Cloudlet  region=US  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name_openstack_packet}

# ECQ-1632
DeleteCloudlet - User shall be able to delete a fake cloudlet
        [Documentation]
        ...  do DeleteCloudlet to delete a fake CRM 

        Run Keyword and Continue on Failure  Update Cloudlet  region=US  cloudlet_name=tmocloud-1  operator_org_name=tmus  maintenance_state=NormalOperation
        Run Keyword and Continue on Failure  Update Cloudlet  region=US  cloudlet_name=tmocloud-2  operator_org_name=tmus  maintenance_state=NormalOperation

        Cleanup Clusters and Apps  region=US  cloudlet_name=tmocloud-1  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_org_name=tmus  cloudlet_name=tmocloud-1

        Cleanup Clusters and Apps  region=US  cloudlet_name=tmocloud-2  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_org_name=tmus  cloudlet_name=tmocloud-2

        Cleanup Clusters and Apps  region=US  cloudlet_name=attcloud-1  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_org_name=att  cloudlet_name=attcloud-1

# ECQ-4068
DeleteCloudlet - User shall be able to delete a cloudlet on Anthos
        [Documentation]
        ...  - do DeleteCloudlet to delete a CRM on Anthos

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_anthos}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_anthos}

        Delete Cloudlet  region=US  token=${token}  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  use_defaults=${False}

# ECQ-2234
UpgradeCloudlet - User shall be able to upgrade cloudlets on Openstack Dusseldorf,Munich,Frankfurt and Hamburg
        [Documentation]
        ...  do UpgradeCloudlet to upgrade CRMs on openstack nodes

        Upgrade Cloudlet   cloudlet_names=@{cloudlet_list}   container_version=${version}  


UpgradeCloudlet - User shall be able to upgrade a cloudlet on Openstack Packet
        [Documentation]
        ...  do UpdateCloudlet to upgrade a CRM on packet openstack

        Update Cloudlet  region=US  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name_openstack_packet}  container_version=${version}   use_defaults=${False}

*** Keywords ***
Setup
   ${version}  Get Environment Variable  AUTOMATION_VERSION  version_not_set
   Set Suite Variable  ${version}

   ${token}=  Get Super Token
   Set Suite Variable  ${token}

Cleanup Clusters and Apps
   [Arguments]  ${region}  ${cloudlet_name}  ${crm_override}=${None}
  
   Run Keyword and Ignore Error  Delete All App Instances      region=${region}  cloudlet_name=${cloudlet_name}  crm_override=${crm_override}
   Run Keyword and Ignore Error  Delete All Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name}  crm_override=${crm_override}


