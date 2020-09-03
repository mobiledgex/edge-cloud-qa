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

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:6.0
${docker_command}  ./server_ping_threaded.py
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when replicas are scaled to zero for app with TCP access port
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}  number_of_replicas=0

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '2'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2 

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}  number_of_replicas=1

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '3'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3

IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when replicas are scaled to zero for app with TCP and UDP access port
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}  number_of_replicas=0

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '2'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}  number_of_replicas=1

    FOR  ${x}  IN RANGE  0  20
        ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '3'
        Sleep  2s
    END

    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3

IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports
    [Documentation]
    ...  deploy IpAccessShared k8s cluster and app with manifest with shared volume mounts
    ...  verify mounts are persisted over pod restart

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  command=${docker_command}
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

*** Keywords ***
Setup
    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}

    Create Flavor     region=${region}

    ${cluster_name_default}=  Get Default Cluster Name
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}
    Set Suite Variable  ${cluster_name_default}
    Set Suite Variable  ${clusterlb}
    Set Suite Variable  ${cloudlet_lowercase}

    

