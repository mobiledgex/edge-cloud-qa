*** Settings ***
Documentation  Update Cluster Instance on IpAccessDedicated k8s cluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexApp
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm}

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

${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml
${manifest_pod_name}=  server-ping-threaded-udptcphttp

${test_timeout_crm}  15 min

*** Test Cases ***
Shall be able to update IpAccessDedicated k8s cluster to modify number of worker nodes
    [Documentation]
    ...  increase and reduce the number of slave nodes 

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait for k8s pod to be running  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_org_name=${operator_name_openstack}  pod_name=${manifest_pod_name}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  number_nodes=2
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
    ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

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
    Should Be Equal As Numbers  ${num_servers_node}    1   # 1 node

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}


Shall be able to update IpAccessDedicated k8s cluster to increase number of worker nodes with scale_with_cluster
    [Documentation]
    ...  increase the number of slave nodes with scale_with_cluster enabled for App

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}  scale_with_cluster=True
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait for k8s pod to be running  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_org_name=${operator_name_openstack}  pod_name=${manifest_pod_name}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  number_nodes=2
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
    ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

    ${server_info_node}=    Get Server List  name=${openstack_node_name}
    ${server_info_master}=  Get Server List  name=${openstack_node_master}
    ${server_info_lb}=      Get Server List  name=${clusterlb}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    2   # 2 nodes

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}


Shall be able to update IpAccessDedicated k8s cluster to include auto scale policy
    [Documentation]
    ...  create an auto scale policy
    ...  create a cluster instance
    ...  update cluster instance to add the auto scale policy

    ${policy_name_default}=  Get Default Autoscale Policy Name
    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Autoscale Policy  region=${region}  min_nodes=2  max_nodes=4  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=2
    Log To Console  Done Creating Cluster Instance

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}   scale_with_cluster=True 
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}

    Log To Console  Updating Cluster Instance 
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default} 
    Log To Console  Done Updating Cluster Instance

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}


Shall be able to update IpAccessDedicated k8s cluster to include auto scale policy where min_nodes > number_nodes
    [Documentation]
    ...  create an auto scale policy
    ...  create a cluster instance
    ...  update cluster instance to add the auto scale policy

    ${policy_name_default}=  Get Default Autoscale Policy Name
    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Autoscale Policy  region=${region}  min_nodes=2  max_nodes=4  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}   scale_with_cluster=True
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name_default}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}
    Log To Console  Done Updating Cluster Instance

    ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}

    ${server_info_node}=    Get Server List  name=${openstack_node_name}

    ${num_servers_node}=     Get Length  ${server_info_node}
    Should Be Equal As Numbers  ${num_servers_node}    2   # 2 nodes

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}


*** Keywords ***
Setup
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}
    Set Suite Variable  ${cloudlet_lowercase}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    Set Suite Variable  ${rootlb}

    Create Flavor     region=${region}
