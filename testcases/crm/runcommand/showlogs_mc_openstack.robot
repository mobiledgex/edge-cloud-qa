*** Settings ***
Documentation  ShowLogs for openstack 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexApp
Library  Collections

#Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationHamburgCloudlet
${cloudlet_name_openstack_dedicated}  automationHamburgCloudlet
${region}  EU
${operator_name_openstack}  TDG

${docker_image}    docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:6.0
${docker_command}  ./server_ping_threaded.py
	
${test_timeout_crm}  15 min

*** Test Cases ***
ShowLogs - k8s shared shall return logs on openstack
    [Documentation]
    ...  deploy k8s shared app 
    ...  verify ShowLogs works 

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  deployment=kubernetes  ip_access=IpAccessShared

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    # without containerid
    ${stdout_noid}=  Show Logs  region=${region}

    # with containerid
    ${stdout_id}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}

    # with timestamps
    ${stdout_timestamps}=  Show Logs  region=${region}  tail=3  time_stamps=${True}

    # with tail
    ${stdout_tail}=  Show Logs  region=${region}  tail=1

    # with since
    TCP Port Should Be Alive  ${app_inst['data']['mapped_ports'][0]['fqdn_prefix']}${app_inst['data']['uri']}  ${app_inst['data']['mapped_ports'][0]['public_port']}
    ${stdout_since}=  Show Logs  region=${region}  since=10s

    # with wrong containerid
    ${error}=  Run Keyword and Expect Error  *  Show Logs  region=${region}  container_id=notfound

    Should Contain   ${error}  Error from server (NotFound): pods "notfound" not found 

    List Should Contain Value  ${stdout_id}  all threads started\r\n
    List Should Contain Value  ${stdout_noid}  all threads started\r\n

    Should Match Regexp          ${stdout_timestamps[0]}  ^\\d{1,4}\\-\\d{1,2}\\-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2}

    Length Should Be  ${stdout_noid}         9
    Length Should Be  ${stdout_id}           9
    Length Should Be  ${stdout_tail}         1
    Length Should Be  ${stdout_timestamps}   3
    Length Should Be  ${stdout_since}        1

ShowLogs - k8s dedicated shall return logs on openstack
    [Documentation]
    ...  deploy k8s dedicated app
    ...  verify ShowLogs works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  deployment=kubernetes  ip_access=IpAccessDedicated

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    log to console  ${app_inst}
    ${token}=  Login

    # without containerid
    ${stdout_noid}=  Show Logs  region=${region}

    # with containerid
    ${stdout_id}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}

    # with timestamps
    ${stdout_timestamps}=  Show Logs  region=${region}  tail=3  time_stamps=${True}

    # with tail
    ${stdout_tail}=  Show Logs  region=${region}  tail=1

    # with since
    TCP Port Should Be Alive  ${app_inst['data']['mapped_ports'][0]['fqdn_prefix']}${app_inst['data']['uri']}  ${app_inst['data']['mapped_ports'][0]['public_port']}
    ${stdout_since}=  Show Logs  region=${region}  since=10s

    # with wrong containerid
    ${error}=  Run Keyword and Expect Error  *  Show Logs  region=${region}  container_id=notfound

    Should Contain   ${error}  Error from server (NotFound): pods "notfound" not found

    List Should Contain Value  ${stdout_id}  all threads started\r\n
    List Should Contain Value  ${stdout_noid}  all threads started\r\n

    Should Match Regexp          ${stdout_timestamps[0]}  ^\\d{1,4}\\-\\d{1,2}\\-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2}

    Length Should Be  ${stdout_noid}         9
    Length Should Be  ${stdout_id}           9
    Length Should Be  ${stdout_tail}         1
    Length Should Be  ${stdout_timestamps}   3
    Length Should Be  ${stdout_since}        1

ShowLogs - docker shall return logs on openstack
    [Documentation]
    ...  deploy docker app
    ...  verify ShowLogs works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  deployment=docker  ip_access=IpAccessDedicated

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  deployment=docker  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    # without containerid
    ${stdout_noid}=  Show Logs  region=${region} 

    # with containerid
    ${stdout_id}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][1]}

    # with timestamps
    ${stdout_timestamps}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][1]}  tail=3  time_stamps=${True}

    # with tail
    ${stdout_tail}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][1]}  tail=1

    # with since
    TCP Port Should Be Alive  ${app_inst['data']['uri']}  ${app_inst['data']['mapped_ports'][0]['public_port']}
    ${stdout_since}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][1]}  since=10s

    # with wrong containerid
    ${error}=  Run Keyword and Expect Error  *  Show Logs  region=${region}  container_id=notfound 

    Should Contain   ${error}  Error: No such container: notfound 

    List Should Contain Value  ${stdout_id}  all threads started\r\n
    List Should Contain Value  ${stdout_noid}  all threads started\r\n

    Should Match Regexp          ${stdout_timestamps[0]}  ^\\d{1,4}\\-\\d{1,2}\\-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2}

    Length Should Be  ${stdout_noid} >= 9
    Length Should Be  ${stdout_id}  9
    Length Should Be  ${stdout_tail}  1
    Length Should Be  ${stdout_timestamps}  3
    Length Should Be  ${stdout_since}  1

*** Keywords ***
Setup
    #Create Developer
    #Create Flavor
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  #deployment=kubernetes  ip_access=IpAccessShared
    #Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}

    Log To Console  Done Creating Cluster Instance

    #${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    #${rootlb}=  Convert To Lowercase  ${rootlb}

    #Set Suite Variable  ${rootlb}
