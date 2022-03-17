*** Settings ***
Documentation  RunCommand for k8s/docker 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  String
Library  Collections

Test Setup      Setup
#Test Teardown   Cleanup provisioning

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
	
${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-1486
RunCommand - k8s shared shall return command result on CRM
    [Documentation]
    ...  - deploy k8s shared app 
    ...  - verify RunCommand works 

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  flavor_name=${cluster_flavor_name}  deployment=kubernetes  ip_access=IpAccessShared
        ${cluster_developer_name}=  Set Variable  ${cluster['data']['key']['organization']}
        ${cluster_name}=  Set Variable  ${cluster['data']['key']['cluster_key']['name']}
    END

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${cluster_developer_name}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout_noid}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=hostname

    ${stdout_id}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=hostname

    ${stdout_noid_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname;hostname;hostname;${SPACE}${SPACE}hostname"

    ${stdout_id_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname${SPACE}${SPACE};${SPACE}${SPACE}hostname;hostname;hostname"

    ${stdout_noid_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname && hostname &&${SPACE}${SPACE}hostname && hostname"

    ${stdout_id_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname && hostname && hostname && hostname"

    ${stdout_nobash_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname && hostname && hostname && hostname"

    ${stdout_nobash_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname;hostname;hostname;hostname"

    ${error}=  Run Keyword and Expect Error  *  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=notfound  command=whoami
	
    Should Start With  ${stdout_noid}  ${app_inst['data']['key']['app_key']['name']}
    Should Start With  ${stdout_id}  ${app_inst['data']['key']['app_key']['name']}
    Should Contain   ${error}  Error from server (NotFound): pods "notfound" not found

    Should Contain  ${stdout_nobash_2}  starting container process caused: exec: "hostname;hostname;hostname;hostname": executable file not found in $PATH: unknown\r\ncommand terminated with exit code 126\r\n
    Should Contain  ${stdout_nobash_1}  starting container process caused: exec: "hostname && hostname && hostname && hostname": executable file not found in $PATH: unknown\r\ncommand terminated with exit code 126\r\n

    @{split_noid_multi_1}=  Split To Lines  ${stdout_noid_multi_1}
    @{split_noid_multi_2}=  Split To Lines  ${stdout_noid_multi_2}
    @{split_id_multi_1}=  Split To Lines  ${stdout_id_multi_1}
    @{split_id_multi_2}=  Split To Lines  ${stdout_id_multi_2}
    ${count_noid_multi_1}=  Count Values In List  ${split_noid_multi_1}  ${stdout_id.strip()}
    ${count_noid_multi_2}=  Count Values In List  ${split_noid_multi_2}  ${stdout_id.strip()}
    ${count_id_multi_1}=    Count Values In List  ${split_id_multi_1}  ${stdout_id.strip()}
    ${count_id_multi_2}=    Count Values In List  ${split_id_multi_2}  ${stdout_id.strip()}

    Length Should Be  ${split_noid_multi_1}  4
    Length Should Be  ${split_noid_multi_2}  4
    Length Should Be  ${split_id_multi_1}    4
    Length Should Be  ${split_id_multi_2}    4
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_noid_multi_2}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_1}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_2}
    Should Be Equal As Numbers  ${count_noid_multi_1}  4
    Should Be Equal As Numbers  ${count_noid_multi_2}  4
    Should Be Equal As Numbers  ${count_id_multi_1}    4
    Should Be Equal As Numbers  ${count_id_multi_2}    4
 
# ECQ-1487
RunCommand - k8s dedicated shall return command result on CRM
    [Documentation]
    ...  - deploy k8s dedicated app
    ...  - verify RunCommand works

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated 
        ${cluster_developer_name}=  Set Variable  ${cluster['data']['key']['organization']}
        ${cluster_name}=  Set Variable  ${cluster['data']['key']['cluster_key']['name']}
    END

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2015  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${cluster_developer_name}  dedicated_ip=${dedicated_ip}

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout_noid}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=hostname

    ${stdout_id}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=hostname

    ${stdout_noid_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname;hostname;hostname;${SPACE}${SPACE}hostname"

    ${stdout_id_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname${SPACE}${SPACE};${SPACE}${SPACE}hostname;hostname;hostname"

    ${stdout_noid_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname && hostname &&${SPACE}${SPACE}hostname && hostname"

    ${stdout_id_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname && hostname && hostname && hostname"

    ${stdout_nobash_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname && hostname && hostname && hostname"

    ${stdout_nobash_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname;hostname;hostname;hostname"

    ${error}=  Run Keyword and Expect Error  *  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=notfound  command=whoami

    log to console   ${stdout_noid}

    Should Start With  ${stdout_noid}  ${app_inst['data']['key']['app_key']['name']}
    Should Start With  ${stdout_id}  ${app_inst['data']['key']['app_key']['name']}
    Should Contain   ${error}  Error from server (NotFound): pods "notfound" not found

    Should Contain  ${stdout_nobash_2}  starting container process caused: exec: "hostname;hostname;hostname;hostname": executable file not found in $PATH: unknown\r\ncommand terminated with exit code 126\r\n
    Should Contain  ${stdout_nobash_1}  starting container process caused: exec: "hostname && hostname && hostname && hostname": executable file not found in $PATH: unknown\r\ncommand terminated with exit code 126\r\n

    @{split_noid_multi_1}=  Split To Lines  ${stdout_noid_multi_1}
    @{split_noid_multi_2}=  Split To Lines  ${stdout_noid_multi_2}
    @{split_id_multi_1}=  Split To Lines  ${stdout_id_multi_1}
    @{split_id_multi_2}=  Split To Lines  ${stdout_id_multi_2}
    ${count_noid_multi_1}=  Count Values In List  ${split_noid_multi_1}  ${stdout_id.strip()}
    ${count_noid_multi_2}=  Count Values In List  ${split_noid_multi_2}  ${stdout_id.strip()}
    ${count_id_multi_1}=    Count Values In List  ${split_id_multi_1}  ${stdout_id.strip()}
    ${count_id_multi_2}=    Count Values In List  ${split_id_multi_2}  ${stdout_id.strip()}

    Length Should Be  ${split_noid_multi_1}  4
    Length Should Be  ${split_noid_multi_2}  4
    Length Should Be  ${split_id_multi_1}    4
    Length Should Be  ${split_id_multi_2}    4
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_noid_multi_2}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_1}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_2}
    Should Be Equal As Numbers  ${count_noid_multi_1}  4
    Should Be Equal As Numbers  ${count_noid_multi_2}  4
    Should Be Equal As Numbers  ${count_id_multi_1}    4
    Should Be Equal As Numbers  ${count_id_multi_2}    4

# ECQ-1488
RunCommand - docker dedicated shall return command result on CRM
    [Documentation]
    ...  deploy docker app
    ...  verify RunCommand works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=docker  ip_access=IpAccessDedicated  #flavor_name=${cluster_flavor_name}

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment=docker  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout_noid}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=hostname

    log to console   aaa ${stdout_noid}\n

    ${stdout_id}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=hostname

    ${stdout_noid_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname;hostname;hostname;${SPACE}${SPACE}hostname"

    ${stdout_id_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname${SPACE}${SPACE};${SPACE}${SPACE}hostname;hostname;hostname"

    ${stdout_noid_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname && hostname &&${SPACE}${SPACE}hostname && hostname"

    ${stdout_id_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname && hostname && hostname && hostname"

    ${stdout_nobash_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname && hostname && hostname && hostname"

    ${stdout_nobash_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname;hostname;hostname;hostname"

    ${error}=  Run Keyword and Expect Error  *  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=notfound  command=whoami

    ${cloudlet_name_lc}=  Convert To Lowercase  ${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
    Should Start With  ${stdout_noid}  mex-docker-vm-${cloudlet_name_lc}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}
    Should Start With  ${stdout_id}    mex-docker-vm-${cloudlet_name_lc}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']} 
    Should Contain   ${error}  Error: No such container: notfound 

    Should Contain  ${stdout_nobash_2}  starting container process caused: exec: "hostname;hostname;hostname;hostname": executable file not found in $PATH: unknown\r\n
    Should Contain  ${stdout_nobash_1}  starting container process caused: exec: "hostname && hostname && hostname && hostname": executable file not found in $PATH: unknown\r\n

    @{split_noid_multi_1}=  Split To Lines  ${stdout_noid_multi_1}
    @{split_noid_multi_2}=  Split To Lines  ${stdout_noid_multi_2}
    @{split_id_multi_1}=  Split To Lines  ${stdout_id_multi_1}
    @{split_id_multi_2}=  Split To Lines  ${stdout_id_multi_2}
    ${count_noid_multi_1}=  Count Values In List  ${split_noid_multi_1}  ${stdout_id.strip()}
    ${count_noid_multi_2}=  Count Values In List  ${split_noid_multi_2}  ${stdout_id.strip()}
    ${count_id_multi_1}=    Count Values In List  ${split_id_multi_1}  ${stdout_id.strip()}
    ${count_id_multi_2}=    Count Values In List  ${split_id_multi_2}  ${stdout_id.strip()}

    Length Should Be  ${split_noid_multi_1}  4
    Length Should Be  ${split_noid_multi_2}  4
    Length Should Be  ${split_id_multi_1}    4
    Length Should Be  ${split_id_multi_2}    4
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_noid_multi_2}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_1}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_2}
    Should Be Equal As Numbers  ${count_noid_multi_1}  4
    Should Be Equal As Numbers  ${count_noid_multi_2}  4
    Should Be Equal As Numbers  ${count_id_multi_1}    4
    Should Be Equal As Numbers  ${count_id_multi_2}    4

# ECQ-2062
RunCommand - docker shared shall return command result on CRM
    [Documentation]
    ...  deploy docker shared app
    ...  verify RunCommand works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=docker  ip_access=IpAccessShared  #flavor_name=${cluster_flavor_name}

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment=docker  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout_noid}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=hostname

    log to console   aaa ${stdout_noid}\n

    ${stdout_id}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=hostname

    ${stdout_noid_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname;hostname;hostname;${SPACE}${SPACE}hostname"

    ${stdout_id_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname${SPACE}${SPACE};${SPACE}${SPACE}hostname;hostname;hostname"

    ${stdout_noid_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname && hostname &&${SPACE}${SPACE}hostname && hostname"

    ${stdout_id_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname && hostname && hostname && hostname"

    ${stdout_nobash_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname && hostname && hostname && hostname"

    ${stdout_nobash_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname;hostname;hostname;hostname"

    ${error}=  Run Keyword and Expect Error  *  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=notfound  command=whoami

    ${cloudlet_name_lc}=  Convert To Lowercase  ${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
    Should Start With  ${stdout_noid}  mex-docker-vm-${cloudlet_name_lc}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}
    Should Start With  ${stdout_id}    mex-docker-vm-${cloudlet_name_lc}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}
    Should Contain   ${error}  Error: No such container: notfound

    Should Contain  ${stdout_nobash_2}  starting container process caused: exec: "hostname;hostname;hostname;hostname": executable file not found in $PATH: unknown\r\n
    Should Contain  ${stdout_nobash_1}  starting container process caused: exec: "hostname && hostname && hostname && hostname": executable file not found in $PATH: unknown\r\n

    @{split_noid_multi_1}=  Split To Lines  ${stdout_noid_multi_1}
    @{split_noid_multi_2}=  Split To Lines  ${stdout_noid_multi_2}
    @{split_id_multi_1}=  Split To Lines  ${stdout_id_multi_1}
    @{split_id_multi_2}=  Split To Lines  ${stdout_id_multi_2}
    ${count_noid_multi_1}=  Count Values In List  ${split_noid_multi_1}  ${stdout_id.strip()}
    ${count_noid_multi_2}=  Count Values In List  ${split_noid_multi_2}  ${stdout_id.strip()}
    ${count_id_multi_1}=    Count Values In List  ${split_id_multi_1}  ${stdout_id.strip()}
    ${count_id_multi_2}=    Count Values In List  ${split_id_multi_2}  ${stdout_id.strip()}

    Length Should Be  ${split_noid_multi_1}  4
    Length Should Be  ${split_noid_multi_2}  4
    Length Should Be  ${split_id_multi_1}    4
    Length Should Be  ${split_id_multi_2}    4
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_noid_multi_2}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_1}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_2}
    Should Be Equal As Numbers  ${count_noid_multi_1}  4
    Should Be Equal As Numbers  ${count_noid_multi_2}  4
    Should Be Equal As Numbers  ${count_id_multi_1}    4
    Should Be Equal As Numbers  ${count_id_multi_2}    4

# ECQ-2586
RunCommand - docker dedicated idle timeout shall be 30min on CRM
    [Documentation]
    ...  - deploy docker app
    ...  - send RunCommand with cmd=/bin/bash to get a shell to the container
    ...  - verify RunCommand returns back in 30mins which is the idle timeout value

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=docker  ip_access=IpAccessDedicated  #flavor_name=${cluster_flavor_name}

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment=docker  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    log to console  ${app_inst}
    ${token}=  Login

    ${start_time}=  Get Time  epoch
    ${stdout}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=/bin/bash
    ${end_time}=  Get Time  epoch

    log to console   aaa ${start_time} ${end_time}

    ${total_time}=  Set Variable  ${end_time} - ${start_time}

    Should Be True  ${total_time} > 1800 and ${total_time} < 1830  # should be between 30min and 30min30secs

# ECQ-3219
RunCommand - docker autocluster shall return command result on CRM
    [Documentation]
    ...  - deploy docker autocluster app
    ...  - verify RunCommand works

    [Tags]  ReservableCluster

    Log To Console  Creating App and App Instance
    ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment=docker  developer_org_name=${developer_org_name_automation}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  cluster_instance_developer_org_name=MobiledgeX

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout_noid}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=hostname

    log to console   aaa ${stdout_noid}\n

    ${stdout_id}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=hostname

    ${stdout_noid_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname;hostname;hostname;${SPACE}${SPACE}hostname"

    ${stdout_id_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname${SPACE}${SPACE};${SPACE}${SPACE}hostname;hostname;hostname"

    ${stdout_noid_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname && hostname &&${SPACE}${SPACE}hostname && hostname"

    ${stdout_id_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname && hostname && hostname && hostname"

    ${stdout_nobash_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname && hostname && hostname && hostname"

    ${stdout_nobash_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname;hostname;hostname;hostname"

    ${error}=  Run Keyword and Expect Error  *  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=notfound  command=whoami

    ${cloudlet_name_lc}=  Convert To Lowercase  ${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
    Should Start With  ${stdout_noid}  mex-docker-vm-${cloudlet_name_lc}-reservable
    Should Start With  ${stdout_id}    mex-docker-vm-${cloudlet_name_lc}-reservable
    Should Contain   ${error}  Error: No such container: notfound

    Should Contain  ${stdout_nobash_2}  starting container process caused: exec: "hostname;hostname;hostname;hostname": executable file not found in $PATH: unknown\r\n
    Should Contain  ${stdout_nobash_1}  starting container process caused: exec: "hostname && hostname && hostname && hostname": executable file not found in $PATH: unknown\r\n

    @{split_noid_multi_1}=  Split To Lines  ${stdout_noid_multi_1}
    @{split_noid_multi_2}=  Split To Lines  ${stdout_noid_multi_2}
    @{split_id_multi_1}=  Split To Lines  ${stdout_id_multi_1}
    @{split_id_multi_2}=  Split To Lines  ${stdout_id_multi_2}
    ${count_noid_multi_1}=  Count Values In List  ${split_noid_multi_1}  ${stdout_id.strip()}
    ${count_noid_multi_2}=  Count Values In List  ${split_noid_multi_2}  ${stdout_id.strip()}
    ${count_id_multi_1}=    Count Values In List  ${split_id_multi_1}  ${stdout_id.strip()}
    ${count_id_multi_2}=    Count Values In List  ${split_id_multi_2}  ${stdout_id.strip()}

    Length Should Be  ${split_noid_multi_1}  4
    Length Should Be  ${split_noid_multi_2}  4
    Length Should Be  ${split_id_multi_1}    4
    Length Should Be  ${split_id_multi_2}    4
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_noid_multi_2}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_1}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_2}
    Should Be Equal As Numbers  ${count_noid_multi_1}  4
    Should Be Equal As Numbers  ${count_noid_multi_2}  4
    Should Be Equal As Numbers  ${count_id_multi_1}    4
    Should Be Equal As Numbers  ${count_id_multi_2}    4

# ECQ-3220
RunCommand - k8s autocluster shall return command result on CRM
    [Documentation]
    ...  - deploy k8s autocluster app
    ...  - verify RunCommand works

    [Tags]  ReservableCluster

    ${random_num}=  Generate Random String  5  0123456789
    ${cluster_name}=  Set Variable  autocluster${random_num}

    Log To Console  Creating App and App Instance
    ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment=kubernetes  developer_org_name=${developer_org_name_automation}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  developer_org_name=${app['data']['key']['organization']}  cluster_instance_developer_org_name=MobiledgeX  cleanup_cluster_instance=${cleanup_cluster}

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout_noid}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=hostname

    ${stdout_id}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=hostname

    ${stdout_noid_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname;hostname;hostname;${SPACE}${SPACE}hostname"

    ${stdout_id_multi_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname${SPACE}${SPACE};${SPACE}${SPACE}hostname;hostname;hostname"

    ${stdout_noid_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=bash -c "hostname && hostname &&${SPACE}${SPACE}hostname && hostname"

    ${stdout_id_multi_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=bash -c "hostname && hostname && hostname && hostname"

    ${stdout_nobash_1}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname && hostname && hostname && hostname"

    ${stdout_nobash_2}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command="hostname;hostname;hostname;hostname"

    ${error}=  Run Keyword and Expect Error  *  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${app_inst['data']['key']['cluster_inst_key']['organization']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  container_id=notfound  command=whoami

    Should Start With  ${stdout_noid}  ${app_inst['data']['key']['app_key']['name']}
    Should Start With  ${stdout_id}  ${app_inst['data']['key']['app_key']['name']}
    Should Contain   ${error}  Error from server (NotFound): pods "notfound" not found

    Should Contain  ${stdout_nobash_2}  starting container process caused: exec: "hostname;hostname;hostname;hostname": executable file not found in $PATH: unknown\r\ncommand terminated with exit code 126\r\n
    Should Contain  ${stdout_nobash_1}  starting container process caused: exec: "hostname && hostname && hostname && hostname": executable file not found in $PATH: unknown\r\ncommand terminated with exit code 126\r\n

    @{split_noid_multi_1}=  Split To Lines  ${stdout_noid_multi_1}
    @{split_noid_multi_2}=  Split To Lines  ${stdout_noid_multi_2}
    @{split_id_multi_1}=  Split To Lines  ${stdout_id_multi_1}
    @{split_id_multi_2}=  Split To Lines  ${stdout_id_multi_2}
    ${count_noid_multi_1}=  Count Values In List  ${split_noid_multi_1}  ${stdout_id.strip()}
    ${count_noid_multi_2}=  Count Values In List  ${split_noid_multi_2}  ${stdout_id.strip()}
    ${count_id_multi_1}=    Count Values In List  ${split_id_multi_1}  ${stdout_id.strip()}
    ${count_id_multi_2}=    Count Values In List  ${split_id_multi_2}  ${stdout_id.strip()}

    Length Should Be  ${split_noid_multi_1}  4
    Length Should Be  ${split_noid_multi_2}  4
    Length Should Be  ${split_id_multi_1}    4
    Length Should Be  ${split_id_multi_2}    4
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_noid_multi_2}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_1}
    Lists Should Be Equal  ${split_noid_multi_1}  ${split_id_multi_2}
    Should Be Equal As Numbers  ${count_noid_multi_1}  4
    Should Be Equal As Numbers  ${count_noid_multi_2}  4
    Should Be Equal As Numbers  ${count_id_multi_1}    4
    Should Be Equal As Numbers  ${count_id_multi_2}    4

*** Keywords ***
Setup
    #Create Developer
    Create Flavor  region=${region}

    ${epoch}=  Get Time  epoch
    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}

    ${cluster_name}=  Set Variable  cluster${epoch}
    
    IF  '${platform_type}' == 'K8SBareMetal'
        ${allow_serverless}=  Set Variable  ${True}
        ${cluster_developer_name}=  Set Variable  MobiledgeX
        ${cleanup_cluster}=  Set Variable  ${False}
        ${dedicated_ip}=  Set Variable  ${True}
    ELSE
        ${allow_serverless}=  Set Variable  ${None}
        ${cleanup_cluster}=  Set Variable  ${True}
        ${cluster_developer_name}=  Get Default Developer Name
        ${dedicated_ip}=  Set Variable  ${False}
    END
    Set Suite Variable  ${platform_type}
    Set Suite Variable  ${allow_serverless}
    Set Suite Variable  ${cluster_developer_name}
    Set Suite Variable  ${cluster_name}
    Set Suite Variable  ${cleanup_cluster}
    Set Suite Variable  ${dedicated_ip}

    #${cloudlet}=  Show Cloudlets  region=${region}  cloudlet_name=${cloudlet_name_crm}
    #${platform_type}=  Set Variable  ${cloudlet[0]['data']['platform_type']}

    #${numnodes}=  Set Variable  1
    #IF  ${platform_type} == 12
    #    ${numnodes}=  Set Variable  0
    #END
 
    #Log To Console  Creating Cluster Instance
    #Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  #deployment=kubernetes  ip_access=IpAccessShared
    #Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}

    #Log To Console  Done Creating Cluster Instance

    #${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    #${rootlb}=  Convert To Lowercase  ${rootlb}

    #Set Suite Variable  ${rootlb}
    #Set Suite Variable  ${numnodes}
