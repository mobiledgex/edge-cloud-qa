*** Settings ***
Documentation   DeleteCloudlet Reservable Cluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown   Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3193
DeleteCloudlet - delete cloudlet shall delete unused reservable clusters
   [Documentation]
   ...  - create a cloudlet
   ...  - create 2 reservable clusters and delete the related app instances
   ...  - delete the cloudlet
   ...  - verify the reservable clusters are deleted

   [Tags]  ReservableCluster

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  auto_delete=${False} 

   Create App  region=${region}   developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1

   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}  cluster_instance_name=autocluster${app_name_default}  auto_delete=${False}
   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}  cluster_instance_name=autocluster${app_name_default}-2  auto_delete=${False}

   Delete App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}  cluster_instance_name=autocluster${app_name_default}  cluster_instance_developer_org_name=MobiledgeX
   Delete App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}  cluster_instance_name=autocluster${app_name_default}-2  cluster_instance_developer_org_name=MobiledgeX

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1

   Delete Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  0
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  0

# ECQ-3194
DeleteCloudlet - shall not be able to delete cloudlet with used reservable clusters
   [Documentation]
   ...  - create a cloudlet
   ...  - create 2 reservable clusters and related app instances
   ...  - delete the cloudlet
   ...  - verify error is received

   [Tags]  ReservableCluster

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake} 

   Create App  region=${region}   developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1

   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}  cluster_instance_name=autocluster${app_name_default}  
   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}  cluster_instance_name=autocluster${app_name_default}-2

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cloudlet in use by ClusterInst name reservable0, reserved by Organization automation_dev_org"}')  Delete Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}

*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${app_name_default}=  Get Default App Name
    ${app_version_default}=  Get Default App Version
    ${developer_name_default}=  Get Default Developer Name
    ${flavor_name_default}=  Get Default Flavor Name
  
    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${app_version_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${flavor_name_default}

