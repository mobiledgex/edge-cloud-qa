*** Settings ***
Documentation  RunCommand for k8s/docker 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    50 min 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
${cloudlet_name_openstack}  automationHawkinsCloudlet
	
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet
${cloudlet_name_openstack_dedicated}  automationHawkinsCloudlet
${region}  EU
${operator_name_openstack}  GDDT

${docker_image}    docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
	
${test_timeout_crm}  30 min

*** Test Cases ***
# ECQ-3505
RunCommand - shall be able to do runcommand and showlogs on appinst with multiple containers
    [Documentation]
    ...  - deploy k8s shared app with multiple containers
    ...  - verify RunCommand and ShowLogs work 

    Log To Console  Creating App and App Instance
    ${epoch_time}=  Get Time  epoch
    ${cluster_name}=    Catenate  SEPARATOR=  autocluster  ${epoch_time}

    ${app}=  Create App  region=${region}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:30090  deployment_manifest=${robotnik_manifest}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  timeout=1500
#    ${app_inst}=  Show App Instances  region=${region}  app_name=app1624835677-42721  use_defaults=${False}

    log to console  ${app_inst}
#    ${app_inst}=  Set Variable  ${app_inst[0]}

    ${rc_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=hostname

    ${rc_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][10]}  command=hostname

    ${rc_3}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][12]}  command=hostname
	
    Should Contain  ${rc_1}  fms-ros-master
    Should Contain  ${rc_2}  fms-webserver
    Should Contain  ${rc_3}  mqtt-broker

    ${sl_1}=  Show Logs  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]} 

    ${sl_2}=  Show Logs  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][10]}

    ${sl_3}=  Show Logs  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][12]}

    Should Contain  ${sl_1}  logging to
    Should Contain  ${sl_2}  NOTICE
    Should Contain  ${sl_3}  mosquitto 

*** Keywords ***
Setup
    Create Flavor  region=${region}
