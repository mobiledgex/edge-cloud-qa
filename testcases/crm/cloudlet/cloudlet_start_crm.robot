*** Settings ***
Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  OperatingSystem
Library  MexKnife 

Test Timeout    ${test_timeout_crm}

Test Setup  Setup

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
${cloudlet_name_openstack_fairview}  automationFairviewCloudlet
${operator_name_openstack_fairview}  GDDT
${physical_name_openstack_fairview}  fairview 
${cloudlet_name_openstack_packet}  packetcloudlet 
${operator_name_openstack_packet}  packet 
${physical_name_openstack_packet}  packetcloudlet 
${cloudlet_name_openstack_paradise}  automationParadiseCloudlet
${operator_name_openstack_paradise}  GDDT
${physical_name_openstack_paradise}  paradise 
${operator_name_gcp}  gcp 
${cloudlet_name_anthos}  qa-anthos
${operator_name_anthos}  packet

${gpu_resource_name}  mygpuresrouce

${version}   version
${imgversion}	3.0.3

${test_timeout_crm}  60 min

@{cloudlet_list}   ${cloudlet_name_openstack_hawkins}   ${cloudlet_name_openstack_sunnydale}   ${cloudlet_name_openstack_fairview}   ${cloudlet_name_openstack_paradise}
 
*** Test Cases ***
# ECQ-1474
CreateCloudlet - User shall be able to create a cloudlet on Openstack Hawkins 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on hawkins openstack 

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_hawkins}  cloudlet_name=${cloudlet_name_openstack_hawkins}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_hawkins}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  gpudriver_name=nvidia-450  gpudriver_org=GDDT

        Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack_hawkins}  operator_org_name=${operator_name_openstack_hawkins}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_hawkins}  tags=pci=t4gpu:1

# ECQ-1498
CreateCloudlet - User shall be able to create a cloudlet on Openstack Buckhorn
        [Documentation]
        ...  do CreateCloudlet to start a CRM on buckhorn openstack

        Create Cloudlet  region=US  operator_org_name=${operator_name_openstack_buckhorn}  cloudlet_name=${cloudlet_name_openstack_buckhorn}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_buckhorn}  number_dynamic_ips=254  latitude=50.73438    longitude=7.09549  env_vars=FLAVOR_MATCH_PATTERN=m4,MEX_EXT_NETWORK=external-network-02  gpudriver_name=nvidia-450  gpudriver_org=GDDT

        Add Cloudlet Resource Mapping  region=US  cloudlet_name=${cloudlet_name_openstack_buckhorn}  operator_org_name=${operator_name_openstack_buckhorn}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=US  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_buckhorn}  tags=pci=t4gpu:1

# ECQ-1613
CreateCloudlet - User shall be able to create a cloudlet on Openstack Beacon 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on beacon openstack 

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_beacon}  cloudlet_name=${cloudlet_name_openstack_beacon}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_beacon}  number_dynamic_ips=254  latitude=52.520007  longitude=13.404954  gpudriver_name=nvidia-450  gpudriver_org=GDDT

        Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack_beacon}  operator_org_name=${operator_name_openstack_beacon}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_beacon}  tags=pci=t4gpu:1

# ECQ-1538
CreateCloudlet - User shall be able to create a cloudlet on Openstack Sunnydale 
        [Documentation]  
        ...  do CreateCloudlet to start a CRM on sunnydale openstack 

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_sunnydale}  cloudlet_name=${cloudlet_name_openstack_sunnydale}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_sunnydale}  number_dynamic_ips=254  latitude=48.1351253  longitude=11.5819806  gpudriver_name=nvidia-450  gpudriver_org=GDDT

# ECQ-1585
CreateCloudlet - User shall be able to create a cloudlet on Openstack Fairview 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on fairview openstack

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_fairview}  cloudlet_name=${cloudlet_name_openstack_fairview}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_fairview}  number_dynamic_ips=254  latitude=50.110922  longitude=8.682127  gpudriver_name=nvidia-450  gpudriver_org=GDDT

        Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack_fairview}  operator_org_name=${operator_name_openstack_fairview}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_fairview}  tags=pci=t4gpu:1

# ECQ-1635
CreateCloudlet - User shall be able to create a cloudlet on Openstack Paradise 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on paradise openstack

        Create Cloudlet  region=EU  operator_org_name=${operator_name_openstack_paradise}  cloudlet_name=${cloudlet_name_openstack_paradise}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_paradise}  number_dynamic_ips=254  latitude=51.2277  longitude=6.7735  gpudriver_name=nvidia-450  gpudriver_org=GDDT

        Add Cloudlet Resource Mapping  region=EU  cloudlet_name=${cloudlet_name_openstack_paradise}  operator_org_name=${operator_name_openstack_paradise}  mapping=gpu=${gpu_resource_name}
        Add Resource Tag  region=EU  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack_paradise}  tags=pci=t4gpu:1

# ECQ-????
CreateCloudlet - User shall be able to create a cloudlet on Openstack Packet 
        [Documentation]
        ...  do CreateCloudlet to start a CRM on packet openstack

        Create Cloudlet  region=US  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name_openstack_packet}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=41.881832  longitude=-87.623177

# ECQ-1631
CreateCloudlet - User shall be able to create a fake cloudlet
        [Documentation]
        ...  do CreateCloudlet to start a fake CRM 

        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_org_name=dmuus  cloudlet_name=tmocloud-1  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000
        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_org_name=dmuus  cloudlet_name=tmocloud-2  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=35  longitude=-95  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000
        Run Keyword and Continue on Failure  Create Cloudlet  region=US  operator_org_name=att  cloudlet_name=attcloud-1  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=35  longitude=-96  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

        Run Keyword and Continue on Failure  Create App  region=US  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  default_flavor_name=${flavor_name_automation}
        Run Keyword and Continue on Failure  Create App  region=US  app_name=${app_name_auth_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  default_flavor_name=${flavor_name_automation}  auth_public_key=${app_auth_public_key}
        Create App Instance  region=US  app_name=${app_name_automation}       app_version=1.0  developer_org_name=${developer_org_name_automation}  cluster_instance_name=autoclusterAutomation      cloudlet_name=tmocloud-1  operator_org_name=dmuus  flavor_name=${flavor_name_automation}
        #Create App Instance  region=US  app_name=automation_api_auth_app  app_version=1.0  cluster_instance_name=autoclusterAutomationAuth  cloudlet_name=tmocloud-1  operator_org_name=dmuus  flavor_name=automation_api_flavor

# ECQ-1457
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Hawkins
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on hawkins openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_hawkins}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_hawkins}

        Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_hawkins}  cloudlet_name=${cloudlet_name_openstack_hawkins}

# ECQ-4067
CreateCloudlet - User shall be able to create a cloudlet on Anthos
        [Documentation]
        ...  - do CreateCloudlet to start a CRM no Anthos

        Create Cloudlet  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}  platform_type=PlatformTypeK8sBareMetal  number_dynamic_ips=8  latitude=47.60621  longitude=-122.33207  env_vars=K8S_CONTROL_ACCESS_IP=145.40.103.121,K8S_EXTERNAL_IP_RANGES=147.28.142.200/29-147.28.142.207/29,K8S_EXTERNAL_ETH_INTERFACE=bond0,K8S_INTERNAL_IP_RANGES=none,K8S_INTERNAL_ETH_INTERFACE=none

# ECQ-1499
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Buckhorn
        [Documentation]
        ...  - do DeleteCloudlet to delete a CRM on buckhorn openstack

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_openstack_buckhorn}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_openstack_buckhorn}

        Delete Cloudlet  region=US  token=${token}  operator_org_name=${operator_name_openstack_buckhorn}   cloudlet_name=${cloudlet_name_openstack_buckhorn}  use_defaults=${False}

# ECQ-1614
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Beacon
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on beacon openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_beacon}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_beacon}

        Delete Cloudlet  region=EU  token=${token}  operator_org_name=${operator_name_openstack_beacon}  cloudlet_name=${cloudlet_name_openstack_beacon}  use_defaults=${False}

# ECQ-1537
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Sunnydale
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on sunnydale openstack 

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_sunnydale}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_sunnydale}

        Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_sunnydale}  cloudlet_name=${cloudlet_name_openstack_sunnydale}

# ECQ-1586
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Fairview 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on fairview openstack

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_fairview}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_fairview}

        Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_fairview}  cloudlet_name=${cloudlet_name_openstack_fairview}

# ECQ-1636
DeleteCloudlet - User shall be able to delete a cloudlet on Openstack Paradise 
        [Documentation]
        ...  do DeleteCloudlet to delete a CRM on paradise openstack

        Delete All App Instances      region=EU  cloudlet_name=${cloudlet_name_openstack_paradise}
        Delete All Cluster Instances  region=EU  cloudlet_name=${cloudlet_name_openstack_paradise}

        Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_paradise}  cloudlet_name=${cloudlet_name_openstack_paradise}

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

        Run Keyword and Continue on Failure  Update Cloudlet  region=US  cloudlet_name=tmocloud-1  operator_org_name=dmuus  maintenance_state=NormalOperation
        Run Keyword and Continue on Failure  Update Cloudlet  region=US  cloudlet_name=tmocloud-2  operator_org_name=dmuus  maintenance_state=NormalOperation

        Cleanup Clusters and Apps  region=US  cloudlet_name=tmocloud-1  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_org_name=dmuus  cloudlet_name=tmocloud-1

        Cleanup Clusters and Apps  region=US  cloudlet_name=tmocloud-2  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_org_name=dmuus  cloudlet_name=tmocloud-2

        Cleanup Clusters and Apps  region=US  cloudlet_name=attcloud-1  crm_override=IgnoreCrmAndTransientState
        Run Keyword and Continue on Failure  Delete Cloudlet  region=US  operator_org_name=att  cloudlet_name=attcloud-1

# ECQ-4068
DeleteCloudlet - User shall be able to delete a cloudlet on Anthos
        [Documentation]
        ...  - do DeleteCloudlet to delete a CRM on Anthos

        Delete All App Instances      region=US  cloudlet_name=${cloudlet_name_anthos}
        Delete All Cluster Instances  region=US  cloudlet_name=${cloudlet_name_anthos}

        Delete Cloudlet  region=US  operator_org_name=${operator_name_anthos}  cloudlet_name=${cloudlet_name_anthos}

# ECQ-2234
UpgradeCloudlet - User shall be able to upgrade cloudlets on Openstack Paradise,Sunnydale,Fairview and Hawkins
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


