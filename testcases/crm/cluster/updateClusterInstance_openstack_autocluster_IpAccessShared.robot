*** Settings ***
Documentation  Update Cluster Instance on IpAccessShared k8s autocluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  MexApp
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm1}

*** Variables ***

${cloudlet_name_openstack_shared}  automationBuckhornCloudlet

${operator_name_openstack}  GDDT

${region}  EU

${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py

${docker_image_cpu}    docker-qa.mobiledgex.net/mobiledgex/images/cpu_generator:1.0

${test_timeout_crm}  15 min

*** Test Cases ***
Shall be able to update IpAccessShared k8s autocluster to modify number of worker nodes
    [Documentation]
    ...  increase and reduce the number of slave nodes 

    #EDGECLOUD-3133 - After UpdateClusterInst to increase the number of worker nodes , App Inst is no longer running
    ${cluster_name_default}=  Get Default Cluster Name
    ${cluster_name_default}=  Catenate  SEPARATOR=  auto  ${cluster_name_default}
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  autocluster_ip_access=IpAccessShared 

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  number_nodes=2  cluster_name=${cluster_name_default}
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}
    ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name_default}

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${server_info_master}=  Get Server List  name=${openstack_node_master}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    2   # 2 nodes

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  number_nodes=1  cluster_name=${cluster_name_default}
    Log To Console  Done Updating Cluster Instance

    ${server_info_node}=    Get Server List  name=${openstack_node_name}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    2   # 2 worker nodes

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}


Shall be able to update IpAccessShared k8s autocluster to modify number of worker nodes with scale_with_cluster
    [Documentation]
    ...  increase the number of slave nodes with scale_with_cluster enabled for App

    #EDGECLOUD-3133 - After UpdateClusterInst to increase the number of worker nodes , App Inst is no longer running
    ${cluster_name_default}=  Get Default Cluster Name
    ${cluster_name_default}=  Catenate  SEPARATOR=  auto  ${cluster_name_default}
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015  command=${docker_command}  scale_with_cluster=True
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  autocluster_ip_access=IpAccessShared

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  number_nodes=2  cluster_name=${cluster_name_default}
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}
    ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name_default}

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${server_info_master}=  Get Server List  name=${openstack_node_master}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    2   # 2 nodes

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}


Shall be able to update IpAccessShared k8s autocluster to include auto scale policy
    [Documentation]
    ...  create an auto scale policy
    ...  create a cluster instance
    ...  update cluster instance to add the auto scale policy

    #EDGECLOUD-3271 - After cluster instance is created by auto scaling policy , app instances are no longer running
    ${policy_name_default}=  Get Default Autoscale Policy Name
    ${cluster_name_default}=  Get Default Cluster Name
    ${cluster_name_default}=  Catenate  SEPARATOR=  auto  ${cluster_name_default}
    ${app_name_default}=  Get Default App Name

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Create App  region=${region}  image_path=${docker_image_cpu}  access_ports=tcp:2017  scale_with_cluster=True
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}  autocluster_ip_access=IpAccessShared

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}
    ${public_port}=  Set Variable  ${app_inst[0]['data']['mapped_ports'][0]['public_port']}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}  cluster_name=${cluster_name_default}
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}

    Set CPU Load  host=${rootlb}  port=${public_port}  load_percentage=72
    Sleep  60s

    FOR  ${x}  IN RANGE  0  30
        ${server_info_node}=    Get Server List  name=${openstack_node_name}
        ${num_servers_node}=    Get Length  ${server_info_node}
        Exit For Loop If  '${num_servers_node}' == '2'
        Sleep  10s
    END

    Should Be Equal As Numbers   ${num_servers_node}    2

    FOR  ${x}  IN RANGE  0  30
        ${clusterInst}=  Show Cluster Instances  region=${region}   cluster_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_shared}
        Exit For Loop If  '${clusterInst[0]['data']['state']}' == '5'
        Sleep  10s
    END

    Should Be Equal As Numbers   ${clusterInst[0]['data']['state']}   5

    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=Unset
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}


Shall be able to update IpAccessShared k8s autocluster to include auto scale policy where min_nodes > number_nodes
    [Documentation]
    ...  create an auto scale policy
    ...  create a cluster instance
    ...  update cluster instance to add the auto scale policy

    #EDGECLOUD-3167 - UpdateClusterInst should scale up the worker nodes to match the auto scaling policy
    ${policy_name_default}=  Get Default Autoscale Policy Name
    ${cluster_name_default}=  Get Default Cluster Name
    ${cluster_name_default}=  Catenate  SEPARATOR=  auto  ${cluster_name_default}
    ${app_name_default}=  Get Default App Name

    Create Autoscale Policy  region=${region}  min_nodes=2  max_nodes=4  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015  command=${docker_command}   scale_with_cluster=True
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}  autocluster_ip_access=IpAccessShared

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}  cluster_name=${cluster_name_default}
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}

    ${server_info_node}=    Get Server List  name=${openstack_node_name}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    2   # 2 nodes

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}


*** Keywords ***
Setup
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_shared}
    Set Suite Variable  ${cloudlet_lowercase}

    ${rootlb}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    Set Suite Variable  ${rootlb}

    Create Flavor     region=${region}
