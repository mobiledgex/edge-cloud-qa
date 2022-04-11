#-*- coding: robot -*-

*** Settings ***
Documentation  CreateCluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}    #auto_login=${False}
Library  MexApp
Library  String
Library  DateTime
Library  Collections

Test Setup      Setup
Test Teardown   Teardown

Test Timeout  20m

*** Variables ***
${nogo}=  ${True}
${cloudlet_name_crm}  automationDallasCloudlet
#${cloudlet_name_crm}  qa-anthos
#${cloudlet_name_crm}  dfw-vsphere
#${cloudlet_name_crm}  DFWVMW2
#${cloudlet_name_crm}  automationBonnCloudlet
#${cloudlet_name_crm}  qawwt-cld1
${operator_name_crm}  packet
#${operator_name_crm}  wwt
#${operator_name_crm}  TDG
${developer_org_name_automation}  automation_dev_org
${developer_org_name}  ${developer_org_name_automation}
${connect1}=    ConnectToLoadBalancer
${connect2}=    ConnectToClusterNodes
${connect3}=    ConnectToAll
${region}  US
${num_nodes_0}  0
${num_nodes_1}  1
${num_nodes_x}  0
${app_name}     app16
${app_name_9090}      app9090
${app_name_8086}      app8086
${cluster_name}  cluster16
${cluster_name_8086}  cluster168086
${cluster_name_9090}  cluster169090
${docker_image}
${node_type_ded}  dedicatedrootlb
${node_type_shr}  sharedrootlb
${ip_access_type}  Dedicated
${docker_image_9090}   docker-qa.mobiledgex.net/automation_dev_org/images/jmeterplus8076:14.7.6
${docker_image_8086}   docker-qa.mobiledgex.net/automation_dev_org/images/jmeterplus8086:14.8.6
${docker_image_K8SBareMetal}    docker-qa.mobiledgex.net/mobiledgex/images/jmeterplus8076:14.7.6
${app_version}          1.0 
${app_version_9090}  14.7.6
${app_version_8086}  14.8.6
${mobiledgex_domain}     mobiledgex-qa.net
${access_tcp_port}       tcp:8086
${access_tcp_9090}       tcp:8076,tcp:8077,tcp:9090
${access_tcp_8086}       tcp:8086
${access_tcp_8087}       tcp:8087
${developer_org_K8SBareMetal}  MobiledgeX
${timeout}  600
${net_empt_tru}=  networks:empty=true
${net-vcd-packet-ctb}  qa2nodenet1
${net-vcd-packet-ctn}  qa2nodenet2-ctn
${net-vcd-packet-cta}  QA2NODE3 
${networks-net}  extra-net
${cta-subnet}  10.62.62.
@{cta-subnet-range}=  Create List  10.62.62.1   10.62.62.2   10.62.62.3   10.62.62.4   10.62.62.5   10.62.62.6   10.62.62.7   10.62.62.8

*** Test Cases ***
#ECQ-4450
CreateCluster - Create ConnectToAll network with dedicated k8s clusterinst packet vcd
    [Documentation]
    ...  - create an additional network type ConnectToAll 
    ...  - verify if network already exists if not create network
    ...  - create a dedicated k8s clusterinst with networks ConnectToAll
    ...  - create a app and deploy the appinst on the cluster with additional network
    ...  - verify the network is attached to both cluster nodes and dedicated load balancer

    Run Keyword  Create ConnectToClusterAll Network Packet VCD
    Run Keyword  Set App Cluster Name 8086
    Run Keyword  Setup Dedicated Cluster With Networks ConnectToAll 
    Run Keyword  Setup Appinst Port8086

    ${cluster_info}=  Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_crm}  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  use_defaults=False
    Should Contain  ${cluster_info[0]['data']}  networks
    Should Be Equal  ${cluster_info[0]['data']['networks']}  ${networks-net-list}
    Should Be Equal  ${cluster_info[0]['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
    Should Be Equal  ${cluster_info[0]['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
    Should Be Equal  ${cluster_info[0]['data']['key']['cluster_key']['name']}  ${cluster_name}

    Run Keyword  Check Dedicated LB Attached To ConnectToAll Network 
    Run Keyword  Check Appinst VM Node Attached To ConnectToAll Network 
# EC-6122 EC-4587 EC-6097
# robodry  --outputdir ~/robot-tc-logs/ -l packet-vcd-cta-301-log.html -o packet-vcd-cta-301-output.xml -r packet-vcd-cta-301-report.html -v cloudlet_name_crm:automationDallasCloudlet -v operator_name_crm:packet  -v developer_org_name_automation:automation_dev_org -t "CreateCluster - create ConnectToAll network with dedicated k8s clusterinst packet vcd" networks_CreateClusterInstance_ConnectToAll_vcd_packet_nsx_v_k8s_dedicated.robot
#
# Keeping for manual testing of exising clusterinst
# robodry  --outputdir ~/robot-tc-logs/ -l packet-vcd-cta-man-411-log.html -o packet-vcd-cta-man-411-output.xml -r packet-vcd-cta-man-411-report.html -v cloudlet_name_crm:automationDallasCloudlet -v operator_name_crm:packet  -v developer_org_name_automation:automation_dev_org -t "CreateCluster - Check VM Additional Networks" networks_CreateClusterInstance_ConnectToAll_vcd_packet_nsx_v_k8s_dedicated.robot
#CreateCluster - Check Dedicated LB Attached To Networks
#    [Documentation]
#    ...  - get ip lists
#    Run Keyword  Manual Check Appinst VM Node Attached To ConnectToAll Network
#    Run Keyword  Manual Check Additional Network Is Added And Reachable From Node


*** Keywords ***
Setup
    ${super_token}  Get Super Token
    Set Suite Variable  ${super_token}
    Log To Console  ${\n}Creating Flavor
    ${flavor_name}=     Set Variable   automation_api_flavor
    Set Suite Variable    ${flavor_name}
    Log To Console  ${flavor_name}
    ${cloudlet_name_crm}  Set Variable  automationDallasCloudlet
    Set Suite Variable  ${cloudlet_name_crm}
    ${operator_name_crm}  Set Variable  packet
    Set Suite Variable  ${operator_name_crm} 
    ${developer_org_name}  Set Variable  automation_dev_org
    Set Suite Variable  ${developer_org_name}
    ${developer_org_name_automation}  Set Variable  ${developer_org_name}
    Set Suite Variable  ${developer_org_name_automation}

Check Dedicated LB Attached To ConnectToAll Network
    ${cluster_info}=  Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_crm}  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  use_defaults=False
    @{allip_list}=  Create List  ${cluster_info[0]['data']['resources']['vms']}
    @{mex_allip_list00}=  Create List  ${cluster_info[0]['data']['resources']['vms'][0]}
    Set Suite Variable  ${mex_allip_list00}
    @{mex_allip_list01}=  Create List  ${cluster_info[0]['data']['resources']['vms'][1]}
    Set Suite Variable  ${mex_allip_list01}
    ${ip_list00}=  Create List  ${mex_allip_list00[0]['ipaddresses']}
    ${ip_list00}=  Convert To String  ${ip_list00}
    ${ip_list01}=  Create List  ${mex_allip_list01[0]['ipaddresses']}
    ${ip_list01}=  Convert To String  ${ip_list01}

    Should Contain Any  ${ip_list00} ${ip_list01}  @{cta-subnet-range}

    ${ping_add_net}=  Set Variable  ping -c 2 ${cta-subnet-range}[0];ping -c 2 ${cta-subnet-range}[1];ping -c 2 ${cta-subnet-range}[2];ping -c 2 ${cta-subnet-range}[3];ping -c 2 ${cta-subnet-range}[4];ping -c 2 ${cta-subnet-range}[5];ping -c 2 ${cta-subnet-range}[6];ping -c 2 ${cta-subnet-range}[7];date
    Set Variable  ${ping_add_net}
    ${ping_cta_net}=  Access Cloudlet  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  region=${region}  command=${ping_add_net}  node_name=${rootlb}  node_type=${node_type_ded}
    ${ping_cta_net}=  Convert To String  ${ping_cta_net}
    @{ping_return}=   Create List   64 bytes from 10.62.62   2 received    2 packets transmitted    0% packet loss    icmp_seq=2

    Should Contain    ${ping_cta_net}  @{ping_return} 

Check Appinst VM Node Attached To ConnectToAll Network
    ${bash_cmds_info}=  Set Variable  bash -c "uname -a;whoami"
    Set Variable  ${bash_cmds_info}
    # Checking appinst has corrrect app for test using hostname which will have the the prefix of the appname and the user will be root as a check.
    ${check_vm_appinst}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${bash_cmds_info}

    Should Contain  ${check_vm_appinst}   Linux app8086    root

    # Testing that ConnectToClusterAll is allowing the VM appinst to reach the additional network setup in a ConnectionToAl
    ${ping_add_net}=  Set Variable  bash -c "ping -c 2 ${cta-subnet-range}[0];ping -c 2 ${cta-subnet-range}[1];ping -c 2 ${cta-subnet-range}[2];ping -c 2 ${cta-subnet-range}[3];ping -c 2 ${cta-subnet-range}[4];ping -c 2 ${cta-subnet-range}[5];ping -c 2 ${cta-subnet-range}[6];ping -c 2 ${cta-subnet-range}[7];date"
    Set Variable  ${ping_add_net}
    ${ping_cta_net}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${ping_add_net}
    ${ping_cta_net}=  Convert To String  ${ping_cta_net}
    @{ping_return}=   Create List   64 bytes from 10.62.62   2 received    2 packets transmitted    0% packet loss    icmp_seq=2

    Should Contain      ${ping_cta_net}  @{ping_return}

Set App Cluster Name 8086
    ${date}=         Get Current Date  result_format=epoch  exclude_millis=no
    Set Suite Variable  ${date}
    ${epoch}=        Convert Date    ${date}    epoch  exclude_millis=yes
    ${epoch}=        Convert To String  ${epoch}
    ${epoch}=        Remove String   ${epoch}  .0
    ${rand_str}=  Generate Random String  length=3
    ${cluster_name}=  Catenate  ${cluster_name_8086}-cta-${rand_str}-${epoch}
    Set Suite Variable  ${cluster_name}
    ${app_name}=      Catenate  ${app_name_8086}-cta-${rand_str}-${epoch}
    Set Suite Variable  ${app_name}
    ${docker_image}=  Set Variable  ${docker_image_8086}
    Set Suite Variable  ${docker_image}
    ${app_version}=  Set Variable  ${app_version_8086}
    Set Suite Variable  ${app_version}

Set App Cluster Name 9090
    ${date}=         Get Current Date  result_format=epoch  exclude_millis=no
    Set Suite Variable  ${date}
    ${epoch}=        Convert Date    ${date}    epoch  exclude_millis=yes
    ${epoch}=        Convert To String  ${epoch}
    ${epoch}=        Remove String   ${epoch}  .0
    ${rand_str}=  Generate Random String  length=3
    ${cluster_name}=  Catenate  ${cluster_name_9090}-${rand_str}-${epoch}
    Set Suite Variable  ${cluster_name}
    ${app_name}=      Catenate  ${app_name_9090}-cta-${rand_str}-${epoch}
    Set Suite Variable  ${app_name}
    ${docker_image}=  Set Variable  ${docker_image_9090}
    Set Suite Variable  ${docker_image}
    ${app_version}=  Set Variable  ${app_version_9090}
    Set Suite Variable  ${app_version}

Create ConnectToClusterAll Network Packet VCD
    Log To Console  Checking Network and creating if not existing
    @{networks-net-list}=  Create List  QA2NODE3 
    Set Suite Variable  ${networks-net-list}
    &{route1}=  Create Dictionary  destination_cidr=10.62.62.1/24  next_hop_ip=10.62.62.4
    @{routelist1}=  Create List  ${route1}
    ${networks-net}=  Set Variable  ${net-vcd-packet-cta}
    Set Suite Variable  ${networks-net}

    ${exists_err}  Set Variable  ('code=400', 'error={"message":"Network key {\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_crm}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_crm}\\\\"},\\\\"name\\\\":\\\\"${net-vcd-packet-cta}\\\\"} already exists"}\')
    ${show_return}=  Show Network  region=${region}  token=${super_token}  network_name=${networks-net}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}    #connection_type=${connect1}  route_list=${routelist1}

    ${exists_yes}=  Run Keyword If  ${exists_err}==${show_return}  Set Variable  ${False}
    ${exists_no}=   Run Keyword If  ${show_return}==[]  Set Variable  ${True}
    IF  '${exists_no}'=='${True}'
         ${net_created}=  Create Network  region=${region}  token=${super_token}  network_name=${networks-net}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect3}  route_list=${routelist1}
         Should Be Equal  ${net_created['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
         Should Be Equal  ${net_created['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
         Should Be Equal  ${net_created['data']['connection_type']}  ConnectToAll
         Should Be Equal  ${net_created['data']['routes']}  ${routelist1}
         Should Be Equal  ${net_created['data']['key']['name']}  ${networks-net}
         Log To Console   ${networks-net} was created
    ELSE
         Log To Console  ${\n}${networks-net} already exists
    END

Setup Dedicated Cluster With Networks ConnectToAll
    Log To Console  ${\n}${cluster_name}
    Log To Console  ${\n}Creating Cluster Instance
    ${cluster_info}=  Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=Dedicated  number_masters=1  number_nodes=${num_nodes_x}  deployment=kubernetes  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  networks=${networks-net}  timeout=${timeout}  flavor_name=${flavor_name}  #flavor_name=${cluster_flavor_name}      Set Suite Variable  ${cluster_info}
    Set Suite Variable  ${cluster_info}
    Log To Console  ${\n}Done Creating Cluster Instance
    ${dev_org}=  Set Variable  ${developer_org_name} 
    ${dev_org_dash}=  Replace String  ${dev_org}  _  -
    ${cloudlet_dash}=  Replace String  ${cloudlet_name_crm}  _  -
    ${operator_dash}=  Replace String  ${operator_name_crm}  _  -
    ${cluster_dash}=   Replace String  ${Cluster_name}  _  -
    ${rootlb}=  Set Variable  ${cluster_name}-${dev_org_dash}.${cloudlet_dash}-${operator_dash}.${region}.${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    Set Suite Variable  ${rootlb}
    ${node_name_lb}=  Set Variable  ${rootlb}
    Set Suite Variable  ${node_name_lb}

    Log To Console  ${\n}${rootlb}
    Log To Console  ${\n}${node_name_lb} using for accesscloudlet

    ${cloudlet_name_check}=  Set Variable  ${cluster_info['data']['key']['cloudlet_key']['name']}
#    Set Variable  ${cloudlet_name_check}
    Should Be Equal  ${cloudlet_name_crm}  ${cloudlet_name_check}
    ${operator_name_check}=  Set Variable  ${cluster_info['data']['key']['cloudlet_key']['organization']}
#    Set Variable  ${operator_name_check}
    Should Be Equal  ${operator_name_crm}  ${operator_name_check}
    ${cluster_name_check}=  Set Variable  ${cluster_info['data']['key']['cluster_key']['name']}
#    Set Variable  ${cluster_name_check}
    Should Be Equal  ${cluster_name}  ${cluster_name_check}

Setup Appinst Port9090
    Log To Console  ${\n}Creating App
    Create App  token=${super_token}  region=${region}  image_path=${docker_image}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  developer_org_name=${developer_org_name}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=kubernetes  app_name=${app_name}   default_flavor_name=${flavor_name}
    Log To Console  ${\n}Done Creating App
    Log To Console  ${\n}Creating App Instance
    Create App Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
    Log To Console  ${\n}Done Creating Appinst

    ${public_check}=  Show App Instances  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}

    ${internal_port_val}=  Set Variable  ${public_check[0]['data']['mapped_ports'][0]['internal_port']}
    ${public_port_val}=  Set Variable  ${public_check[0]['data']['mapped_ports'][0]['public_port']}
    #Log ports to console when checking webui manually while test is running
    Log To Console  ${\n}
    Log To Console  Internal port=${internal_port_val}
    Log To Console  Public port=${public_port_val}
    #Values are used in appinst script for jmeter to create active connections
    Set Suite Variable  ${internal_port_val}
    Set Suite Variable  ${public_port_val}

Setup Appinst Port8086
    Log To Console  ${\n}Creating App
    Create App  token=${super_token}  region=${region}  image_path=${docker_image}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  developer_org_name=${developer_org_name}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=kubernetes  app_name=${app_name}   default_flavor_name=${flavor_name}
    Log To Console  ${\n}Done Creating App
    Log To Console  ${\n}Creating App Instance
    Create App Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
    Log To Console  ${\n}Done Creating Appinst

    ${public_check}=  Show App Instances  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}

    ${internal_port_val}=  Set Variable  ${public_check[0]['data']['mapped_ports'][0]['internal_port']}
    ${public_port_val}=  Set Variable  ${public_check[0]['data']['mapped_ports'][0]['public_port']}
    #Log ports to console when checking webui manually while test is running
    Log To Console  ${\n}
    Log To Console  Internal port=${internal_port_val}
    Log To Console  Public port=${public_port_val}
    #Values are used in appinst script for jmeter to create active connections
    Set Suite Variable  ${internal_port_val}
    Set Suite Variable  ${public_port_val}

Create Trusted App Port8086
    Log To Console  ${\n}Creating App
    Create App  token=${super_token}  region=${region}  image_path=${docker_image}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_8087}  developer_org_name=${developer_org_name}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=kubernetes  app_name=${app_name}   default_flavor_name=${flavor_name}  trusted=${True} 
    Log To Console  ${\n}Done Creating Trusted App

Teardown
    Cleanup Provisioning

    # Leaving in for manual testing and trouble shooting
Manual Check Appinst VM Node Attached To ConnectToAll Network
    ${app_name}  Set Variable       app8086-1649281618
    ${cluster_name}  Set Variable   cluster168086-1649281618
    ${developer_org_name}  Set Variable  automation_dev_org
    ${app_version}  Set Variable  ${app_version_8086}
    ${bash_cmds_info}=  Set Variable  bash -c "uname -a;whoami"
    Set Variable  ${bash_cmds_info}
    # Checking appinst has corrrect app for test using hostname which will have the the prefix of the appname and the user will be root as a check.
    ${check_vm_appinst}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${bash_cmds_info}
    Should Contain  ${check_vm_appinst}   Linux app8086    root
    # Testing that ConnectToAll is allowing the VM appinst to reach the additional network setup in a ConnectionToAll
    ${ping_add_net}=  Set Variable  bash -c "ping -c 2 ${cta-subnet-range}[0];ping -c 2 ${cta-subnet-range}[1];ping -c 2 ${cta-subnet-range}[2];ping -c 2 ${cta-subnet-range}[3];ping -c 2 ${cta-subnet-range}[4];ping -c 2 ${cta-subnet-range}[5];ping -c 2 ${cta-subnet-range}[6];ping -c 2 ${cta-subnet-range}[7];date"
    Set Variable  ${ping_add_net}
    ${ping_cta_net}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${ping_add_net}
    ${ping_cta_net}=  Convert To String  ${ping_cta_net}
    @{ping_return}=   Create List   64 bytes from 10.62.62   2 received   2 packets transmitted    0% packet loss    icmp_seq=2
    Should Contain      ${ping_cta_net}  @{ping_return}

    # Leaving in for manual testing
Manual Check Additional Network Is Added And Reachable From Node
    ${nodename_lb}=  Set Variable  cluster168086-1649281618-automation-dev-org.automationdallascloudlet-packet.us.mobiledgex-qa.net
    Set Variable  ${nodename_lb}
    ${node_type_ded}  Set Variable  dedicatedrootlb
    Set Variable  ${node_type_ded}
    ${cluster_info}=  Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_crm}  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}
    ${ping_add_net}=  Set Variable  ping -c 2 ${cta-subnet-range}[0];ping -c 2 ${cta-subnet-range}[1];ping -c 2 ${cta-subnet-range}[2];ping -c 2 ${cta-subnet-range}[3];ping -c 2 ${cta-subnet-range}[4];ping -c 2 ${cta-subnet-range}[5];ping -c 2 ${cta-subnet-range}[6];ping -c 2 ${cta-subnet-range}[7];date
    Set Variable  ${ping_add_net}
    ${ping_cta_net}=  Access Cloudlet  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  region=${region}  command=${ping_add_net}  node_name=${nodename_lb}  node_type=dedicatedrootlb
    ${ping_cta_net}=  Convert To String  ${ping_cta_net}
    @{ping_return}=  Create List  64 bytes from 10.62.22  2 received  0% packet loss   icmp_seq=1   2 packets transmitted
    Should Contain      ${ping_cta_net}  64 bytes from 10.62.22   2 received   0% packet los
    Should Contain      ${ping_cta_net}  @{ping_return}
