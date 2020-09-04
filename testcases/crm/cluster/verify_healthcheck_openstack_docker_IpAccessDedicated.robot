*** Settings ***
Documentation  IpAccessShared Shared Volume Mounts 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexApp
Library  String

Suite Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet

${operator_name_openstack}  TDG

${region}  EU

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:8.0
${docker_command}  ./server_ping_threaded.py
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
IpAccessDedicated docker - healthcheck shows HealthCheckFailRootlbOffline when docker container is stopped on rootlb for app with one TCP access port
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Restart Docker Container Rootlb   root_loadbalancer=${clusterlb}   operation=stop

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '1'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   1 

    Restart Docker Container Rootlb  root_loadbalancer=${clusterlb}   operation=start

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '3'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3

IpAccessDedicated docker - healthcheck shows HealthCheckFailServerFail when docker container is stopped on clustervm for app with TCP access port
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Restart Docker Container Clustervm  root_loadbalancer=${clusterlb}  node=${server_info_node[0]['Networks']}  operation=stop

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '2'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

    Restart Docker Container Clustervm  root_loadbalancer=${clusterlb}  cluster_instance_name=${cluster_name_default}   operation=start

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '3'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3

IpAccessDedicated docker - healthcheck shows HealthCheckFailServerFail when docker container is stopped on clustervm for app with TCP and UDP access port
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Restart Docker Container Clustervm  root_loadbalancer=${clusterlb}  node=${server_info_node[0]['Networks']}  operation=stop

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '2'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

    Restart Docker Container Clustervm  root_loadbalancer=${clusterlb}  cluster_instance_name=${cluster_name_default}   operation=start

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '3'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3

IpAccessDedicated docker - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '2'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

IpAccessDedicated docker - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP TLS access ports
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016:tls  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016  tls=True

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '2'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

IpAccessDedicated docker - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 1 TCP/TLS access ports
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2015  tls=True

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '2'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

*** Keywords ***
Setup
    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}

    Create Flavor     region=${region}

    ${cluster_name_default}=  Get Default Cluster Name
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker
    Log To Console  Done Creating Cluster Instance

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}
    ${openstack_node_name}=    Catenate  SEPARATOR=-  docker  vm  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    Set Suite Variable  ${cluster_name_default}
    Set Suite Variable  ${clusterlb}
    Set Suite Variable  ${cloudlet_lowercase}
    Set Suite Variable  ${server_info_node}
    

