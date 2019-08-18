*** Settings ***
Documentation   CreateAppInst 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown   Cleanup Provisioning	

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1
${qcow_centos_image}  qcowimage

*** Test Cases ***
AppInst - VM deployment without cluster shall create clustername='DefaultVMCluster'
    [Documentation]
    ...  create a VM app instance without cluster 
    ...  verify DefaultVMCluster is set as cluster name

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name
    ${developer_name_default}=  Get Default Developer Name
    ${app_version_default}=  Get Default App Version

    ${app_inst}=  Create App Instance  app_name=${app_name_default}  developer_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  use_defaults=${False}
    
    Should Be Equal  ${app_inst.key.cluster_inst_key.cluster_key.name}  DefaultVMCluster

AppInst - VM deployment shall be created with clustername
    [Documentation]
    ...  create a VM app instance with cluster name
    ...  verify app instance is created 

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  dummyvmcluster  ${epoch_time}

    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_name}

    Should Be Equal  ${app_inst.key.cluster_inst_key.cluster_key.name}  ${cluster_name}

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    #Create Cloudlet  cloudlet_name=tmocloud-10  operator_name=tmus
    Create App	 deployment=vm  image_type=ImageTypeQCOW  image_path=${qcow_centos_image}  #	access_ports=tcp:1

    ${app_name_default}=  Get Default App Name
    ${app_version_default}=  Get Default App Version
    ${developer_name_default}=  Get Default Developer Name
    ${flavor_name_default}=  Get Default Flavor Name
  
    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${app_version_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${flavor_name_default}

