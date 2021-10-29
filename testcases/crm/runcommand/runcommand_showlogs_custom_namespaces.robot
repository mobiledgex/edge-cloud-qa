*** Settings ***
Documentation  RunCommand for k8s with custom namespaces

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  Collections

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    50 min 
	
*** Variables ***
${cloudlet_name_openstack}  automationHawkinsCloudlet
	
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet
${cloudlet_name_openstack_dedicated}  automationHawkinsCloudlet
${region}  EU
${operator_name_openstack}  GDDT

${namespace_manifest}=  http://35.199.188.102/apps/automation_server_ping_threaded_namespaces.yml
	
${test_timeout_crm}  30 min

*** Test Cases ***
# ECQ-3695
RunCommand - shall be able to do runcommand and showlogs on appinst with custom namespaces
    [Documentation]
    ...  - deploy k8s app with custom namespacess
    ...  - verify RunCommand and ShowLogs work 

    Log To Console  Creating App and App Instance
    ${epoch_time}=  Get Time  epoch
    ${cluster_name}=    Catenate  SEPARATOR=  autocluster  ${epoch_time}

    Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,tcp:8085  image_path=no_default  deployment_manifest=${namespace_manifest}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=kubernetes  #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  timeout=1500

    ${rc_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=hostname

    ${rc_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][1]}  command=hostname

    ${rc_3}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][2]}  command=hostname

    ${rc_4}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][3]}  command=hostname
	
    Should Contain  ${rc_1}  server-ping-threaded-udptcphttp-deployment
    Should Contain  ${rc_2}  server-ping-threaded-udptcphttp-deployment 
    Should Contain  ${rc_3}  server-ping-threaded-udptcphttp-deployment 
    Should Contain  ${rc_4}  server-ping-threaded-udptcphttp-deployment

    @{containers}=  Create List  ${rc_1}  ${rc_2}  ${rc_3}  ${rc_4}
    List Should Not Contain Duplicates  ${containers}

    ${sl_1}=  Show Logs  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]} 

    ${sl_2}=  Show Logs  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][1]}

    ${sl_3}=  Show Logs  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][2]}

    ${sl_4}=  Show Logs  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  container_id=${app_inst['data']['runtime_info']['container_ids'][3]}

    Should Contain  ${sl_1}  all threads started 
    Should Contain  ${sl_2}  all threads started 
    Should Contain  ${sl_3}  all threads started 
    Should Contain  ${sl_4}  all threads started

*** Keywords ***
Setup
    Create Flavor  region=${region}
