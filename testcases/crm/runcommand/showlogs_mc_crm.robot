*** Settings ***
Documentation  ShowLogs for CRM 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexApp
Library  Collections
Library  String

Test Setup      Setup
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

${num_lines}=  13

${test_timeout_crm}  15 min

${since}=  45s

*** Test Cases ***
# ECQ-1887
ShowLogs - k8s shared shall return logs on CRM
    [Documentation]
    ...  deploy k8s shared app 
    ...  verify ShowLogs works 

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessShared  #flavor_name=${cluster_flavor_name}

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}
    Sleep  10 seconds  # wait for app to fully start

    # without containerid
    ${stdout_noid}=  Show Logs  region=${region}

    # with containerid
    ${stdout_id}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}

    # with timestamps
    ${stdout_timestamps}=  Show Logs  region=${region}  tail=3  time_stamps=${True}

    # with tail
    ${stdout_tail}=  Show Logs  region=${region}  tail=1

    # with since
    Sleep  60 
    TCP Port Should Be Alive  ${app_inst['data']['uri']}  ${app_inst['data']['mapped_ports'][0]['public_port']}
    ${stdout_since}=  Show Logs  region=${region}  since=${since}

    # with wrong containerid
    ${error}=  Run Keyword and Expect Error  *  Show Logs  region=${region}  container_id=notfound

    Should Contain   ${error}  Error from server (NotFound): pods "notfound" not found 

    Should Contain  ${stdout_id}  all threads started
    Should Contain  ${stdout_noid}  all threads started

    Should Match Regexp          ${stdout_timestamps}  ^\\d{1,4}\\-\\d{1,2}\\-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2}

    ${stdout_noid_lines}=        Split To Lines  ${stdout_noid}
    ${stdout_id_lines}=          Split To Lines  ${stdout_id}
    ${stdout_tail_lines}=        Split To Lines  ${stdout_tail}
    ${stdout_timestamps_lines}=  Split To Lines  ${stdout_timestamps}
    ${stdout_since_lines}=       Split To Lines  ${stdout_since}
 
    Length Should Be  ${stdout_noid_lines}         ${num_lines} 
    Length Should Be  ${stdout_id_lines}           ${num_lines}
    Length Should Be  ${stdout_tail_lines}         1
    Length Should Be  ${stdout_timestamps_lines}   3
    Length Should Be  ${stdout_since_lines}        2

# ECQ-1888
ShowLogs - k8s dedicated shall return logs on CRM
    [Documentation]
    ...  deploy k8s dedicated app
    ...  verify ShowLogs works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated  #flavor_name=${cluster_flavor_name}

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}
    Sleep  10 seconds  # wait for app to fully start

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
    Sleep  60 
    TCP Port Should Be Alive  ${app_inst['data']['uri']}  ${app_inst['data']['mapped_ports'][0]['public_port']}
    ${stdout_since}=  Show Logs  region=${region}  since=${since}

    # with wrong containerid
    ${error}=  Run Keyword and Expect Error  *  Show Logs  region=${region}  container_id=notfound

    Should Contain   ${error}  Error from server (NotFound): pods "notfound" not found

    Should Contain   ${stdout_id}  all threads started
    Should Contain   ${stdout_noid}  all threads started

    Should Match Regexp          ${stdout_timestamps}  ^\\d{1,4}\\-\\d{1,2}\\-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2}

    ${stdout_noid_lines}=        Split To Lines  ${stdout_noid}
    ${stdout_id_lines}=          Split To Lines  ${stdout_id}
    ${stdout_tail_lines}=        Split To Lines  ${stdout_tail}
    ${stdout_timestamps_lines}=  Split To Lines  ${stdout_timestamps}
    ${stdout_since_lines}=       Split To Lines  ${stdout_since}

    Length Should Be  ${stdout_noid_lines}         ${num_lines}
    Length Should Be  ${stdout_id_lines}           ${num_lines}
    Length Should Be  ${stdout_tail_lines}         1
    Length Should Be  ${stdout_timestamps_lines}   3
    Length Should Be  ${stdout_since_lines}        2

# ECQ-1889
ShowLogs - docker dedicated shall return logs on CRM
    [Documentation]
    ...  deploy docker dedicated app
    ...  verify ShowLogs works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=docker  ip_access=IpAccessDedicated  #flavor_name=${cluster_flavor_name}

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  deployment=docker  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}
    Sleep  10 seconds  # wait for app to fully start

    # without containerid
    ${stdout_noid}=  Show Logs  region=${region} 

    # with containerid
    ${stdout_id}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}

    # with timestamps
    ${stdout_timestamps}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  tail=3  time_stamps=${True}

    # with tail
    ${stdout_tail}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  tail=1

    # with since
    Get Time
    Sleep  60
    Get Time
    TCP Port Should Be Alive  ${app_inst['data']['uri']}  ${app_inst['data']['mapped_ports'][0]['public_port']}
    Get Time
    ${stdout_since}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  since=${since}

    # with wrong containerid
    ${error}=  Run Keyword and Expect Error  *  Show Logs  region=${region}  container_id=notfound 

    Should Contain   ${error}  Error: No such container: notfound 

    Should Contain   ${stdout_id}  all threads started
    Should Contain   ${stdout_noid}  all threads started

    Should Match Regexp          ${stdout_timestamps}  ^\\d{1,4}\\-\\d{1,2}\\-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2}

    ${stdout_noid_lines}=        Split To Lines  ${stdout_noid}
    ${stdout_id_lines}=          Split To Lines  ${stdout_id}
    ${stdout_tail_lines}=        Split To Lines  ${stdout_tail}
    ${stdout_timestamps_lines}=  Split To Lines  ${stdout_timestamps}
    ${stdout_since_lines}=       Split To Lines  ${stdout_since}

    Length Should Be  ${stdout_noid_lines}  ${num_lines}
    Length Should Be  ${stdout_id_lines}  ${num_lines}
    Length Should Be  ${stdout_tail_lines}  1
    Length Should Be  ${stdout_timestamps_lines}  3
    Length Should Be  ${stdout_since_lines}  2

# ECQ-2066
ShowLogs - docker shared shall return logs on CRM
    [Documentation]
    ...  deploy docker shared app
    ...  verify ShowLogs works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=docker  ip_access=IpAccessShared  #flavor_name=${cluster_flavor_name}

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  deployment=docker  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=${region}  #cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}
    Sleep  10 seconds  # wait for app to fully start

    # without containerid
    ${stdout_noid}=  Show Logs  region=${region}

    # with containerid
    ${stdout_id}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}

    # with timestamps
    ${stdout_timestamps}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  tail=3  time_stamps=${True}

    # with tail
    ${stdout_tail}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  tail=1

    # with since
    Sleep  60
    TCP Port Should Be Alive  ${app_inst['data']['uri']}  ${app_inst['data']['mapped_ports'][0]['public_port']}
    ${stdout_since}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  since=${since}

    # with wrong containerid
    ${error}=  Run Keyword and Expect Error  *  Show Logs  region=${region}  container_id=notfound

    Should Contain   ${error}  Error: No such container: notfound

    Should Contain   ${stdout_id}  all threads started
    Should Contain   ${stdout_noid}  all threads started

    Should Match Regexp          ${stdout_timestamps}  ^\\d{1,4}\\-\\d{1,2}\\-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2}

    ${stdout_noid_lines}=        Split To Lines  ${stdout_noid}
    ${stdout_id_lines}=          Split To Lines  ${stdout_id}
    ${stdout_tail_lines}=        Split To Lines  ${stdout_tail}
    ${stdout_timestamps_lines}=  Split To Lines  ${stdout_timestamps}
    ${stdout_since_lines}=       Split To Lines  ${stdout_since}

    Length Should Be  ${stdout_noid_lines}  ${num_lines}
    Length Should Be  ${stdout_id_lines}  ${num_lines}
    Length Should Be  ${stdout_tail_lines}  1
    Length Should Be  ${stdout_timestamps_lines}  3
    Length Should Be  ${stdout_since_lines}  2

# ECQ-3221
ShowLogs - docker autocluster shall return logs on CRM
    [Documentation]
    ...  - deploy docker autocluster app
    ...  - verify ShowLogs works

    [Tags]  ReservableCluster

    Log To Console  Creating App and App Instance
    ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  deployment=docker  developer_org_name=${developer_org_name_automation}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app['data']['key']['name']}  cluster_instance_developer_org_name=MobiledgeX
    Sleep  10 seconds  # wait for app to fully start

    # without containerid
    ${stdout_noid}=  Show Logs  region=${region}  cluster_instance_name=autocluster${app['data']['key']['name']}  cluster_instance_developer_org_name=MobiledgeX

    # with containerid
    ${stdout_id}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  cluster_instance_name=autocluster${app['data']['key']['name']}  cluster_instance_developer_org_name=MobiledgeX

    Should Contain   ${stdout_id}  all threads started
    Should Contain   ${stdout_noid}  all threads started

# ECQ-3222
ShowLogs - k8s autocluster shall return logs on CRM
    [Documentation]
    ...  - deploy k8s autocluster app
    ...  - verify ShowLogs works

    [Tags]  ReservableCluster

    Log To Console  Creating App and App Instance
    ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  deployment=kubernetes  developer_org_name=${developer_org_name_automation}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app['data']['key']['name']}  cluster_instance_developer_org_name=MobiledgeX
    Sleep  10 seconds  # wait for app to fully start

    # without containerid
    ${stdout_noid}=  Show Logs  region=${region}  cluster_instance_name=autocluster${app['data']['key']['name']}  cluster_instance_developer_org_name=MobiledgeX

    # with containerid
    ${stdout_id}=  Show Logs  region=${region}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  cluster_instance_name=autocluster${app['data']['key']['name']}  cluster_instance_developer_org_name=MobiledgeX

    Should Contain   ${stdout_id}  all threads started
    Should Contain   ${stdout_noid}  all threads started

*** Keywords ***
Setup
    #Create Developer
    Create Flavor  region=${region}
    #Log To Console  Creating Cluster Instance
    #Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  #deployment=kubernetes  ip_access=IpAccessShared
    ##Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}

    #Log To Console  Done Creating Cluster Instance

    #${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    #${rootlb}=  Convert To Lowercase  ${rootlb}

    #Set Suite Variable  ${rootlb}
