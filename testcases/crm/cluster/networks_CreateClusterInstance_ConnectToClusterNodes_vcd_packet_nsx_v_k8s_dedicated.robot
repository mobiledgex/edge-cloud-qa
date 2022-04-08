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
${app_version}          1.0 
${app_version_9090}  14.7.6
${app_version_8086}  14.8.6
${mobiledgex_domain}     mobiledgex-qa.net
${access_tcp_port}       tcp:8086
${access_tcp_9090}       tcp:8076,tcp:8077,tcp:9090
${access_tcp_8086}       tcp:8086
${access_tcp_8087}       tcp:8087
${timeout}  600
${net_empt_tru}=  networks:empty=true
${net-vcd-packet-ctn}  qa2nodenet2-ctn
${networks-net}  extra-net
${ctn-subnet}      10.22.22.
@{ctn-subnet-range}=  Create List  10.22.22.1  10.22.22.2  10.22.22.3  10.22.22.4  10.22.22.5  10.22.22.6  10.22.22.7  10.22.22.8

*** Test Cases ***
# ECQ-
CreateCluster - create ConnectToClusterNodes network with dedicated k8s clusterinst packet vcd
    [Documentation]
    ...  - create an additional network type ConnectToClusterNodes
    ...  - verify if network already exists if not create network
    ...  - create a dedicated k8s clusterinst with networks ConnectToClusterNodes
    ...  - create a app and deploy the appinst on the cluster with additional network
    ...  - verifiy cluster master node is attached to an additional network
    ...  - verifiy appinst vm node is attached to an additional network

    Run Keyword  Create ConnectToClusterNodes Network Packet VCD
    Run Keyword  Set App Cluster Name 8086
    Run Keyword  Setup Dedicated Cluster With Networks ConnectToClusterNodes 
    Run Keyword  Setup Appinst Port8086

    ${cluster_info}=  Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_crm}  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  use_defaults=False
    Should Contain  ${cluster_info[0]['data']}  networks
    Should Be Equal  ${cluster_info[0]['data']['networks']}  ${networks-net-list}
    Should Be Equal  ${cluster_info[0]['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
    Should Be Equal  ${cluster_info[0]['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
    Should Be Equal  ${cluster_info[0]['data']['key']['cluster_key']['name']}  ${cluster_name}

    Run Keyword  Check Cluster Node Attached To ConnectToClusterNodes
    Run Keyword  Check Appinst VM Node Attached To ConnectToClusterNodes

# # EC-6122 EC-4587 EC-6097
# robodry  --outputdir ~/robot-tc-logs/ -l packet-vcd-ctn-501-log.html -o packet-vcd-ctn-501-output.xml -r packet-vcd-ctn-501-report.html -v cloudlet_name_crm:automationDallasCloudlet -v operator_name_crm:packet  -v developer_org_name_automation:automation_dev_org -t "CreateCluster - create ConnectToClusterNodes network with dedicated k8s clusterinst packet vcd" networks_CreateClusterInstance_ConnectToClusterNodes_vcd_packet_nsx_v_k8s_dedicated.robot
#
# robodry  --outputdir ~/robot-tc-logs/ -l packet-vcd-manctn-411-log.html -o packet-vcd-manctn-411-output.xml -r packet-vcd-manctn-411-report.html -v cloudlet_name_crm:automationDallasCloudlet -v operator_name_crm:packet  -v developer_org_name_automation:automation_dev_org -t "CreateCluster - Check VM Additional Networks" networks_CreateClusterInstance_ConnectToClusterNodes_vcd_packet_nsx_v_k8s_dedicated.robot
#CreateCluster - Check VM Additional Networks
#    [Documentation]
#    ...  - get ip lists
#    Run Keyword  Manual Check Appinst VM Node Attached To ConnectToClusterNodes
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


Check Cluster Node Attached To ConnectToClusterNodes
    ${cluster_info}=  Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_crm}  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  use_defaults=False
    @{allip_list}=  Create List  ${cluster_info[0]['data']['resources']['vms']}
    @{mex_allip_list00}=  Create List  ${cluster_info[0]['data']['resources']['vms'][0]}
    Set Suite Variable  ${mex_allip_list00}
    @{mex_allip_list01}=  Create List  ${cluster_info[0]['data']['resources']['vms'][1]}
    Set Suite Variable  ${mex_allip_list01}
    IF  '${num_nodes_x}' == '1'
        @{mex_allip_list02}=  Create List  ${cluster_info[0]['data']['resources']['vms'][2]}
        Set Suite Variable  ${mex_allip_list02}
        ${ip_list02}=  Create List  ${mex_allip_list01[0]['ipaddresses']}
        ${ip_list02}=  Convert To String  ${ip_list02}
    ELSE
    ${ip_list00}=  Create List  ${mex_allip_list00[0]['ipaddresses']}
    ${ip_list00}=  Convert To String  ${ip_list00}
    ${ip_list01}=  Create List  ${mex_allip_list01[0]['ipaddresses']}
    ${ip_list01}=  Convert To String  ${ip_list01}
    END

    Run Keyword If  '${num_nodes_x}' == '1'  Should Contain Any  ${ip_list00} ${ip_list01} ${ip_list02}  @{ctn-subnet-range}
    Run Keyword If  '${num_nodes_x}' == '0'  Should Contain Any  ${ip_list00} ${ip_list01}               @{ctn-subnet-range}

    ${ping_add_net}=   Set Variable  ping -c 2 ${ctn-subnet-range}[0];ping -c 2 ${ctn-subnet-range}[1];ping -c 2 ${ctn-subnet-range}[2];ping -c 2 ${ctn-subnet-range}[3];ping -c 2 ${ctn-subnet-range}[4];ping -c 2 ${ctn-subnet-range}[5];ping -c 2 ${ctn-subnet-range}[6];ping -c 2 ${ctn-subnet-range}[7];date
    Set Variable  ${ping_add_net}
    ${ping_ctn_net}=  Access Cloudlet  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  region=${region}  command=${ping_add_net}  node_name=${rootlb}  node_type=${node_type_ded}
    ${ping_ctn_net}=  Convert To String  ${ping_ctn_net}
    @{ping_return}=   Create List   64 bytes from 10.22.22   2 received    2 packets transmitted    0% packet loss    icmp_seq=2

    Should Contain    ${ping_ctn_net}  @{ping_return}

Check Appinst VM Node Attached To ConnectToClusterNodes
    ${bash_cmds_info}=  Set Variable  bash -c "uname -a;whoami"
    Set Variable  ${bash_cmds_info}
    # Checking appinst has corrrect app for test using hostname which will have the the prefix of the appname and the user will be root.
    ${check_vm_appinst}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${bash_cmds_info}
    Should Contain  ${check_vm_appinst}   Linux app8086    root
    # Testing that ConnectToClusterNodes is allowing the VM appinst to reach the additional network setup in a ConnectionToLoadBlancer this will fail but the dedicated load balancer can reach it.
    ${curl_add_net}=   Set Variable  bash -c "curl -I ${ctn-subnet-range}[0]:${internal_port_val};curl -I ${ctn-subnet-range}[1]:${public_port_val};curl -I ${ctn-subnet-range}[2]:${public_port_val};curl -I ${ctn-subnet-range}[3]:${public_port_val};curl -I ${ctn-subnet-range}[4]:${public_port_val};curl -I ${ctn-subnet-range}[5]:${public_port_val}"
    ${ping_add_net}=  Set Variable  bash -c "ping -c 2 ${ctn-subnet-range}[0];ping -c 2 ${ctn-subnet-range}[1];ping -c 2 ${ctn-subnet-range}[2];ping -c 2 ${ctn-subnet-range}[3];ping -c 2 ${ctn-subnet-range}[4];ping -c 2 ${ctn-subnet-range}[5];ping -c 2 ${ctn-subnet-range}[6];ping -c 2 ${ctn-subnet-range}[7];date"
    Set Variable  ${curl_add_net}
    Set Variable  ${ping_add_net}
    ${curl_ctn_net}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${curl_add_net}
    ${ping_ctn_net}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${ping_add_net}
    ${curl_ctn_net}=  Convert To String  ${curl_ctn_net}
    ${ping_ctn_net}=  Convert To String  ${ping_ctn_net}
    @{curl_return}=   Create List   HTTP/1.1 200 OK   text/html   ETag   c9b-5dafd31a48580
    @{ping_return}=   Create List   64 bytes from 10.22.22   2 received    2 packets transmitted    0% packet loss    icmp_seq=2
    Should Contain      ${curl_ctn_net}  @{curl_return}
    Should Contain      ${ping_ctn_net}  @{ping_return}

Set App Cluster Name 8086
    ${date}=         Get Current Date  result_format=epoch  exclude_millis=no
    Set Suite Variable  ${date}
    ${epoch}=        Convert Date    ${date}    epoch  exclude_millis=yes
    ${epoch}=        Convert To String  ${epoch}
    ${epoch}=        Remove String   ${epoch}  .0
    ${rand_str}=  Generate Random String  length=3
    ${cluster_name}=  Catenate  ${cluster_name_8086}-ctn-${rand_str}-${epoch}
    Set Suite Variable  ${cluster_name}
    ${app_name}=      Catenate  ${app_name_8086}-ctn-${rand_str}-${epoch}
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
    ${cluster_name}=  Catenate  ${cluster_name_9090}-ctn-${rand_str}-${epoch}
    Set Suite Variable  ${cluster_name}
    ${app_name}=      Catenate  ${app_name_9090}-ctn-${rand_str}-${epoch}
    Set Suite Variable  ${app_name}
    ${docker_image}=  Set Variable  ${docker_image_9090}
    Set Suite Variable  ${docker_image}
    ${app_version}=  Set Variable  ${app_version_9090}
    Set Suite Variable  ${app_version}

Create ConnectToClusterNodes Network Packet VCD
    Log To Console  Checking Network and creating if not existing
    @{networks-net-list}=  Create List  qa2nodenet2-ctn 
    Set Suite Variable  ${networks-net-list}
    &{route1}=  Create Dictionary  destination_cidr=10.22.22.1/24  next_hop_ip=10.22.22.4
    @{routelist1}=  Create List  ${route1}
    ${networks-net}=  Set Variable  ${net-vcd-packet-ctn}
    Set Suite Variable  ${networks-net}

    ${exists_err}  Set Variable  ('code=400', 'error={"message":"Network key {\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_crm}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_crm}\\\\"},\\\\"name\\\\":\\\\"${net-vcd-packet-ctn}\\\\"} already exists"}\')
    ${show_return}=  Show Network  region=${region}  token=${super_token}  network_name=${networks-net}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}    #connection_type=${connect1}  route_list=${routelist1}

    ${exists_yes}=  Run Keyword If  ${exists_err}==${show_return}  Set Variable  ${False}
    ${exists_no}=   Run Keyword If  ${show_return}==[]  Set Variable  ${True}
    IF  '${exists_no}'=='${True}'
         ${net_created}=  Create Network  region=${region}  token=${super_token}  network_name=${networks-net}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}
         Should Be Equal  ${net_created['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
         Should Be Equal  ${net_created['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
         Should Be Equal  ${net_created['data']['connection_type']}  ${connect1}
         Should Be Equal  ${net_created['data']['routes']}  ${routelist1}
         Should Be Equal  ${net_created['data']['key']['name']}  ${networks-net}
         Log To Console   ${networks-net} was created
    ELSE
         Log To Console  ${\n}${networks-net} already exists
    END

Create Network ConnectToClusterNodes If Not Existing Wwt VCD
    Log To Console  Checking Network and creating if not existing
    @{networks-net-list}=  Create List  ${net-vcd-wwt-ctn}
    Set Suite Variable  ${networks-net-list}
#    &{route1}=  Create Dictionary  destination_cidr=172.168.0.1/24  next_hop_ip=172.168.0.5
    &{route1}=  Create Dictionary  destination_cidr=10.22.22.1/24  next_hop_ip=10.22.22.4
    @{routelist1}=  Create List  ${route1}
    ${networks-net}=  Set Variable  ${net-vcd-wwt-ctn}
    Set Suite Variable  ${networks-net}
    ${exists_err}  Set Variable  ('code=400', 'error={"message":"Network key {\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"wwt\\\\",\\\\"name\\\\":\\\\"qawwt-cld1\\\\"},\\\\"name\\\\":\\\\"${net-vcd-wwt-ctn}\\\\"} already exists"}\')
    ${show_return}=  Show Network  region=${region}  token=${super_token}  network_name=${networks-net}  cloudlet_name=qawwt-cld1  cloudlet_org=wwt    #connection_type=${connect1}  route_list=${routelist1}

    ${exists_yes}=  Run Keyword If  ${exists_err}==${show_return}  Set Variable  ${False}
    ${exists_no}=   Run Keyword If  ${show_return}==[]  Set Variable  ${True}
    IF  '${exists_no}'=='${True}'
         ${net_created}=  Create Network  region=${region}  token=${super_token}  network_name=${networks-net}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}
         Should Be Equal  ${net_created['data']['key']['cloudlet_key']['name']}  qawwt-cld1
         Should Be Equal  ${net_created['data']['key']['cloudlet_key']['organization']}  wwt
         Should Be Equal  ${net_created['data']['connection_type']}  ${connect1}
         Should Be Equal  ${net_created['data']['routes']}  ${routelist1}
         Should Be Equal  ${net_created['data']['key']['name']}  ${networks-net}
         Log To Console   ${networks-net} was created
    ELSE
         Log To Console  ${\n}${networks-net} already exists
    END

Setup Dedicated Cluster With Networks ConnectToClusterNodes 
    Log To Console  ${\n}${cluster_name}
    Log To Console  ${\n}Creating Cluster Instance
    ${cluster_info}=  Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=Dedicated  number_masters=${num_nodes_1}  number_nodes=${num_nodes_x}  deployment=kubernetes  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  networks=${networks-net}  timeout=${timeout}  flavor_name=${flavor_name}  #flavor_name=${cluster_flavor_name}      Set Suite Variable  ${cluster_info}
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

# Test Existing appinst and clusterinst - leaving this sectiion for manual testing
Manual Check Appinst VM Node Attached To ConnectToClusterNodes
    ${public_port_val}  Set Variable  8086
    ${internal_port_val}  Set Variable  8086
    ${app_name}  Set Variable       app8086-ctn-1649376830
    ${cluster_name}  Set Variable   cluster168086-ctn-0cb-1649376830
    ${developer_org_name}  Set Variable  automation_dev_org
    ${app_version}  Set Variable  ${app_version_8086}
    ${bash_cmds_info}=  Set Variable  bash -c "uname -a;whoami"
    Set Variable  ${bash_cmds_info}
    # Checking appinst has corrrect app for test using hostname which will have the the prefix of the appname and the user will be root as a check.
    ${check_vm_appinst}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${bash_cmds_info}
    Should Contain  ${check_vm_appinst}   Linux app8086    root
    # Testing that ConnectToClusterNodes is allowing the VM appinst to reach the additional network setup in a ConnectionToLoadBlancer this will fail but the dedicated load balancer can reach it.
    ${curl_add_net}=   Set Variable  bash -c "curl -I ${ctn-subnet-range}[0]:${internal_port_val};curl -I ${ctn-subnet-range}[1]:${public_port_val};curl -I ${ctn-subnet-range}[2]:${public_port_val};curl -I ${ctn-subnet-range}[3]:${public_port_val};curl -I ${ctn-subnet-range}[4]:${public_port_val};curl -I ${ctn-subnet-range}[5]:${public_port_val}"
    ${ping_add_net}=   Set Variable  bash -c "ping -c 2 ${ctn-subnet-range}[0];ping -c 2 ${ctn-subnet-range}[1];ping -c 2 ${ctn-subnet-range}[2];ping -c 2 ${ctn-subnet-range}[3];ping -c 2 ${ctn-subnet-range}[4];ping -c 2 ${ctn-subnet-range}[5];ping -c 2 ${ctn-subnet-range}[6];ping -c 2 ${ctn-subnet-range}[7];date"
    Set Variable  ${curl_add_net}
    Set Variable  ${ping_add_net}
    ${curl_ctn_net}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${curl_add_net}
    ${ping_ctn_net}=  Run Command  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  token=${super_token}  command=${ping_add_net}
    ${curl_ctn_net}=  Convert To String  ${curl_ctn_net}
    ${ping_ctn_net}=  Convert To String  ${ping_ctn_net}
    @{ping_return}=  Create List   10.22.22.  2 packets transmitted
     @{curl_return}=  Create List   HTTP/1.1 200 OK   text/html   ETag   c9b-5dafd31a48580

    Should Contain      ${curl_ctn_net}  @{curl_return}
    Should Contain      ${ping_ctn_net}  @{ping_return}
# leaving this sectiion for manual testing
Manual Check Additional Network Is Added And Reachable From Node
    ${nodename_lb}=  Set Variable   cluster168086-ctn-0cb-1649376830-automation-dev-org.qawwt-cld1-wwt.us.mobiledgex-qa.net
    Set Variable  ${nodename_lb}
    Set Variable  ${node_type_ded}
    ${public_port_val}  Set Variable  8086
    ${internal_port_val}  Set Variable  8086
    ${app_name}  Set Variable       app8086-ctn-1649376830
    ${cluster_name}  Set Variable   cluster168086-ctn-0cb-1649376830
    ${developer_org_name}  Set Variable  automation_dev_org
    ${app_version}  Set Variable  ${app_version_8086}
    ${num_nodes_x}  Set Variable  0
    ${cluster_info}=  Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_crm}  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  use_defaults=False
    @{allip_list}=  Create List  ${cluster_info[0]['data']['resources']['vms']}
    @{mex_allip_list00}=  Create List  ${cluster_info[0]['data']['resources']['vms'][0]}
    Set Suite Variable  ${mex_allip_list00}
    @{mex_allip_list01}=  Create List  ${cluster_info[0]['data']['resources']['vms'][1]}
    Set Suite Variable  ${mex_allip_list01}
    IF  '${num_nodes_x}' == '1'
        @{mex_allip_list02}=  Create List  ${cluster_info[0]['data']['resources']['vms'][2]}
        Set Suite Variable  ${mex_allip_list02}
        ${ip_list02}=  Create List  ${mex_allip_list01[0]['ipaddresses']}
        ${ip_list02}=  Convert To String  ${ip_list02}
    ELSE
    ${ip_list00}=  Create List  ${mex_allip_list00[0]['ipaddresses']}
    ${ip_list00}=  Convert To String  ${ip_list00}
    ${ip_list01}=  Create List  ${mex_allip_list01[0]['ipaddresses']}
    ${ip_list01}=  Convert To String  ${ip_list01}
    END

    Run Keyword If  '${num_nodes_x}' == '1'  Should Contain Any  ${ip_list00} ${ip_list01} ${ip_list02}  @{ctn-subnet-range}
    Run Keyword If  '${num_nodes_x}' == '0'  Should Contain Any  ${ip_list00} ${ip_list01}               @{ctn-subnet-range}

    ${cluster_info}=   Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_crm}  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}
    ${ping_add_net}=   Set Variable  ping -c 2 ${ctn-subnet-range}[0];ping -c 2 ${ctn-subnet-range}[1];ping -c 2 ${ctn-subnet-range}[2];ping -c 2 ${ctn-subnet-range}[3];ping -c 2 ${ctn-subnet-range}[4];ping -c 2 ${ctn-subnet-range}[5];ping -c 2 ${ctn-subnet-range}[6];ping -c 2 ${ctn-subnet-range}[7];date
    Set Variable  ${ping_add_net}
    ${ping_ctn_net}=  Access Cloudlet  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  region=${region}  command=${ping_add_net}  node_name=${nodename_lb}  node_type=dedicatedrootlb
    ${ping_ctn_net}=  Convert To String  ${ping_ctn_net}
    @{ping_return}=  Create List  64 bytes from 10.22.22  2 received  0% packet loss   icmp_seq=1   2 packets transmitted
    Should Contain      ${ping_ctn_net}  @{ping_return}
#VCD-NSX-V setup for QA for additional networks
#
#ConnectToAll             10.62.62.1/24
#ConnectToLoadBalancer    10.42.42.1/24
#ConnectToClusterNodes    10.22.22.1/24
#
#vCD datacentert networks  qa2-vdc qa2org
#Networks         Gateway CIDR    Network Type   Connected To vCD External Network
#QA2NODE3         10.62.62.1/24   Direct         QA2NODE3
#qa2nodenet1      10.42.42.1/24   Direct         qa2nodenet1
#qa2nodenet2-ctn  10.22.22.1/24   Direct         qa2nodenet2
#
#vCD External Networks
#Name    QA2NODE3    vlan 62  vSphere Networks  Destributed Port Group   Name: QA2NODE3   vCenter: vctr-vcd
#Name    qa2nodenet1          vSphere Networks  Destributed Port Group   Name: QA2NODE1   vCenter: vctr-vcd
#Name    qa2nodenet2          vSphere Networks  Destributed Port Group   Name: QA2NODE2   vCenter: vctr-vcd
#
#vSphere Client Packet-VCD  Distributed Port Groups
#Distributed switch  ExternalVSwitchVCDQA2   host:vcd-qa2-esxi.mobiledgex.net
#Name           VLAN ID             Port Binding
#QA2NODE1       VLAN access:42      Ephemeral - no binding
#QA2NODE2       VLAN access:22      Static binding (elastic)
#QA2NODE3       VLAN access:62      Ephemeral - no binding
