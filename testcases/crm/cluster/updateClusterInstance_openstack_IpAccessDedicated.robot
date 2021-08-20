*** Settings ***
Documentation  Update Cluster Instance on IpAccessDedicated k8s cluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexApp
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm1}

*** Variables ***

${cloudlet_name_openstack_dedicated}  automationBonnCloudlet

${operator_name_openstack}  TDG

${region}  EU

${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${docker_image_cpu}    docker-qa.mobiledgex.net/mobiledgex/images/cpu_generator:1.0

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-2281
Shall be able to update IpAccessDedicated k8s cluster to modify number of worker nodes
    [Documentation]
    ...  increase and reduce the number of slave nodes 

    #EDGECLOUD-3133 - After UpdateClusterInst to increase the number of worker nodes , App Inst is no longer running 
    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=0
    Log To Console  Done Creating Cluster Instance

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${page}=    Catenate  SEPARATOR=   /  ${http_page}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}
    ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name_default}

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    0   # 0 nodes

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  number_nodes=1
    Log To Console  Done Updating Cluster Instance

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${server_info_master}=  Get Server List  name=${openstack_node_master}
    ${server_info_lb}=      Get Server List  name=${clusterlb}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    1   # 1 nodes

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  number_nodes=2
    Log To Console  Done Updating Cluster Instance

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${server_info_master}=  Get Server List  name=${openstack_node_master}
    ${server_info_lb}=      Get Server List  name=${clusterlb}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    2   # 2 nodes

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  number_nodes=1
    Log To Console  Done Updating Cluster Instance

    ${server_info_node}=    Get Server List  name=${openstack_node_name}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    1   # 2 worker nodes

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  number_nodes=1
    Log To Console  Done Updating Cluster Instance

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    0   # 0 worker nodes

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

# ECQ-2282
Shall be able to update IpAccessDedicated k8s cluster to increase number of worker nodes with scale_with_cluster
    [Documentation]
    ...  increase the number of slave nodes with scale_with_cluster enabled for App

    #EDGECLOUD-3133 - After UpdateClusterInst to increase the number of worker nodes , App Inst is no longer running
    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  command=${docker_command}  scale_with_cluster=True
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${page}=    Catenate  SEPARATOR=   /  ${http_page}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  number_nodes=2
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}
    ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name_default}

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${server_info_master}=  Get Server List  name=${openstack_node_master}
    ${server_info_lb}=      Get Server List  name=${clusterlb}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    2   # 2 nodes

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

# ECQ-2275
Shall be able to update IpAccessDedicated k8s cluster to include auto scale policy
    [Documentation]
    ...  create an auto scale policy
    ...  create a cluster instance
    ...  update cluster instance to add the auto scale policy

    #EDGECLOUD-3271 - After cluster instance is created by auto scaling policy , app instances are no longer running
    ${policy_name_default}=  Get Default Autoscale Policy Name
    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}

    #Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60
    Create Autoscale Policy  region=${region}  policy_name=${policy_name_default}  developer_org_name=automation_dev_org  min_nodes=1  max_nodes=2  target_cpu=70  stabilization_window_sec=60  use_defaults=${False}  token=${super_token}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    Create App  region=${region}  image_path=${docker_image_cpu}  access_ports=tcp:2017  scale_with_cluster=True 
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}

    Log To Console  Updating Cluster Instance 
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default} 
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name_default}

    Set CPU Load  host=${clusterlb}  port=2017  load_percentage=72
    Sleep  120s

    FOR  ${x}  IN RANGE  0  35
        ${server_info_node}=    Get Server List  name=${openstack_node_name}
        ${num_servers_node}=    Get Length  ${server_info_node}
        Exit For Loop If  '${num_servers_node}' == '2'
        Sleep  10s
    END

    Should Be Equal As Numbers   ${num_servers_node}    2

    FOR  ${x}  IN RANGE  0  40
        ${clusterInst}=  Show Cluster Instances  region=${region}   cluster_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}
        Exit For Loop If  '${clusterInst[0]['data']['state']}' == '5'
        Sleep  10s
    END

    Should Be Equal As Numbers   ${clusterInst[0]['data']['state']}   5

    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=Unset
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}

# ECQ-2276
Shall be able to update IpAccessDedicated k8s cluster to include auto scale policy where min_nodes > number_nodes
    [Documentation]
    ...  create an auto scale policy
    ...  create a cluster instance
    ...  update cluster instance to add the auto scale policy

    #EDGECLOUD-3167 - UpdateClusterInst should scale up the worker nodes to match the auto scaling policy
    ${policy_name_default}=  Get Default Autoscale Policy Name
    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Autoscale Policy  region=${region}  min_nodes=2  max_nodes=4  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  command=${docker_command}   scale_with_cluster=True
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}
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
    ${page}=    Catenate  SEPARATOR=   /  ${http_page}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}


*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}
    Set Suite Variable  ${cloudlet_lowercase}
    Set Suite Variable  ${super_token}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    Set Suite Variable  ${rootlb}

    Create Flavor     region=${region}
