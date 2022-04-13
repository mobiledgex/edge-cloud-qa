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
${ip_access_type}  Shared
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
${networks-net}  extra-net
${ctb-subnet}  10.42.42.
@{ctb-subnet-range}=  Create List  10.42.42.1   10.42.42.2   10.42.42.3   10.42.42.4   10.42.42.5   10.42.42.6   10.42.42.7


# EDGECLOUD-5702
*** Test Cases ***
# ECQ-4454
CreateCluster - Verify that platforms that do not support additional networks return error message
    [Documentation]
    ...  - create an additional network type ConnectToLoadBalancer ClusterNodes and All
    ...  - verify if network already exists if not create network
    ...  - create a shared k8s clusterinst with additional networks
    ...  - verify adding additional network is not allowed for shared LB on supported platform
    ...  - verify adding additional network is not allowed for platform Vsphere
    ...  - verify adding additional network is not allowed for platform K8S Bare Metal

    Run Keyword  Create Network If Not Existing Vcd
    Run Keyword  Set App Cluster Name 8086
    Run Keyword  Setup Shared Cluster With Add Net Vcd
    Log To Console  ${cluster_info_vcd}
    Run Keyword  Create Network If Not Existing Openstack
    Run Keyword  Setup Shared Cluster With Add Net Openstack
    Log To Console  ${cluster_info_os}
    Run Keyword  Setup Dedicated Cluster With Add Net K8S Bare Metal
    Log To Console  ${cluster_info2}
    Run Keyword  Setup Dedicated Cluster With Add Net Vsphere
    Log To Console  ${cluster_info3}


# EC-5702
#  robodry  --outputdir ~/robot-tc-logs/ -l errpacket-vcd-ctb-01-log.html -o errpacket-vcd-ctb-01-output.xml -r errpacket-vcd-ctb-01-report.html -v cloudlet_name_crm:automationDallasCloudlet -v operator_name_crm:packet  -v developer_org_name=automation_dev_org networks_CreateClusterInstance_Add_Network_Fail.robot

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

Setup Shared Cluster With Add Net Vcd
    ${connect_err_vcd}=  Set Variable   (\'code=400\', \'error={"message":"Cannot specify an additional cluster network of ConnectionType ConnectToLoadBalancer or ConnectToAll with IpAccessShared"}\')
    Log To Console  ${\n}Creating Cluster Instance
    ${cluster_info_vcd}=  Run Keyword And Expect Error  *  Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=automationDallasCloudlet  operator_org_name=packet  ip_access=Shared  number_masters=1  number_nodes=${num_nodes_x}  deployment=kubernetes  developer_org_name=automation_dev_org  cluster_name=${cluster_name}  networks=${networks-net}  timeout=${timeout}  flavor_name=${flavor_name}  #flavor_name=${cluster_flavor_name}      Set Suite Variable  ${cluster_info}i

    Set Suite Variable  ${cluster_info_vcd}
    Should Be Equal As Strings  ${cluster_info_vcd}  ${connect_err_vcd}

Setup Shared Cluster With Add Net Openstack
    ${connect_err_os}=  Set Variable   (\'code=400\', \'error={"message":"Cannot specify an additional cluster network of ConnectionType ConnectToLoadBalancer or ConnectToAll with IpAccessShared"}\')
    Log To Console  ${\n}Creating Cluster Instance
    ${cluster_info_os}=  Run Keyword And Expect Error  *  Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=automationBonnCloudlet  operator_org_name=TDG  ip_access=Shared  number_masters=1  number_nodes=${num_nodes_x}  deployment=kubernetes  developer_org_name=automation_dev_org  cluster_name=${cluster_name}  networks=${networks-net}  timeout=${timeout}  flavor_name=${flavor_name}  #flavor_name=${cluster_flavor_name}      Set Suite Variable  ${cluster_info}i

    Set Suite Variable  ${cluster_info_os}
    Should Be Equal As Strings  ${cluster_info_os}  ${connect_err_os}

Setup Dedicated Cluster With Add Net K8S Bare Metal
    ${connect_err2}=  Set Variable   (\'code=400\', \'error={"message":"Single kubernetes cluster platform PLATFORM_TYPE_K8S_BARE_METAL only supports AppInst creates"}\')
    Log To Console  ${\n}Creating Cluster Instance
    ${cluster_info2}=  Run Keyword And Expect Error  *  Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=qa-anthos  operator_org_name=packet  ip_access=Dedicated  number_masters=1  number_nodes=${num_nodes_1}  deployment=kubernetes  developer_org_name=automation_dev_org  cluster_name=${cluster_name}  networks=${networks-net}  timeout=${timeout}  flavor_name=${flavor_name}  #flavor_name=${cluster_flavor_name}      Set Suite Variable  ${cluster_info}i

    Set Suite Variable  ${cluster_info2}
    Should Be Equal As Strings  ${cluster_info2}  ${connect_err2}

Setup Dedicated Cluster With Add Net Vsphere
    ${connect_err3}=  Set Variable   (\'code=400\', \'error={"message":"Additional cluster networks not supported on platform: PLATFORM_TYPE_VSPHERE"}\')
    Log To Console  ${\n}Creating Cluster Instance
    ${cluster_info3}=  Run Keyword And Expect Error  *  Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=DFWVMW2  operator_org_name=packet  ip_access=Dedicated  number_masters=1  number_nodes=${num_nodes_0}  deployment=kubernetes  developer_org_name=automation_dev_org  cluster_name=${cluster_name}  networks=${networks-net}  timeout=${timeout}  flavor_name=${flavor_name}  #flavor_name=${cluster_flavor_name}      Set Suite Variable  ${cluster_info}i

    Set Suite Variable  ${cluster_info3}
    Should Be Equal As Strings  ${cluster_info3}  ${connect_err3}

Set App Cluster Name 8086
    ${date}=         Get Current Date  result_format=epoch  exclude_millis=no
    Set Suite Variable  ${date}
    ${epoch}=        Convert Date    ${date}    epoch  exclude_millis=yes
    ${epoch}=        Convert To String  ${epoch}
    ${epoch}=        Remove String   ${epoch}  .0
    ${rand_str}=  Generate Random String  length=3
    ${cluster_name}=  Catenate  ${cluster_name_8086}-ctb-${rand_str}-${epoch}
    Set Suite Variable  ${cluster_name}
    ${app_name}=      Catenate  ${app_name_8086}-ctb-${rand_str}-${epoch}
    Set Suite Variable  ${app_name}
    ${docker_image}=  Set Variable  ${docker_image_8086}
    Set Suite Variable  ${docker_image}
    ${app_version}=  Set Variable  ${app_version_8086}
    Set Suite Variable  ${app_version}

Create Network If Not Existing Vcd
    Log To Console  Checking Network and creating if not existing
    @{networks-net-list}=  Create List  qa2nodenet1 
    Set Suite Variable  ${networks-net-list}
    &{route1}=  Create Dictionary  destination_cidr=10.42.42.1/24  next_hop_ip=10.42.42.4
    @{routelist1}=  Create List  ${route1}
    ${networks-net}=  Set Variable  ${net-vcd-packet-ctb}
    Set Suite Variable  ${networks-net}

    Log To Console  Checking Network and creating if not existing
    @{networks-net-list}=  Create List  qa2nodenet1
    Set Suite Variable  ${networks-net-list}
    &{route1}=  Create Dictionary  destination_cidr=10.42.42.1/24  next_hop_ip=10.42.42.4
    @{routelist1}=  Create List  ${route1}
    ${networks-net}=  Set Variable  ${net-vcd-packet-ctb}
    Set Suite Variable  ${networks-net}

    ${exists_err}  Set Variable  ('code=400', 'error={"message":"Network key {\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_crm}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_crm}\\\\"},\\\\"name\\\\":\\\\"${net-vcd-packet-ctb}\\\\"} already exists"}\')
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

Create Network If Not Existing Openstack
    Log To Console  Checking Network and creating if not existing
    @{networks-net-list}=  Create List  qa2nodenet1
    Set Suite Variable  ${networks-net-list}
    &{route1}=  Create Dictionary  destination_cidr=10.42.42.1/24  next_hop_ip=10.42.42.4
    @{routelist1}=  Create List  ${route1}
    ${networks-net}=  Set Variable  ${net-vcd-packet-ctb}
    Set Suite Variable  ${networks-net}

    Log To Console  Checking Network and creating if not existing
    @{networks-net-list}=  Create List  qa2nodenet1
    Set Suite Variable  ${networks-net-list}
    &{route1}=  Create Dictionary  destination_cidr=10.42.42.1/24  next_hop_ip=10.42.42.4
    @{routelist1}=  Create List  ${route1}
    ${networks-net}=  Set Variable  ${net-vcd-packet-ctb}
    Set Suite Variable  ${networks-net}

    ${exists_err}  Set Variable  ('code=400', 'error={"message":"Network key {\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"TDG\\\\",\\\\"name\\\\":\\\\"automationBonnCloudlet\\\\"},\\\\"name\\\\":\\\\"${net-vcd-packet-ctb}\\\\"} already exists"}\')
    ${show_return}=  Show Network  region=${region}  token=${super_token}  network_name=${networks-net}  cloudlet_name=automationBonnCloudlet  cloudlet_org=TDG    #connection_type=${connect1}  route_list=${routelist1}

    ${exists_yes}=  Run Keyword If  ${exists_err}==${show_return}  Set Variable  ${False}
    ${exists_no}=   Run Keyword If  ${show_return}==[]  Set Variable  ${True}
    IF  '${exists_no}'=='${True}'
         ${net_created}=  Create Network  region=${region}  token=${super_token}  network_name=${networks-net}  cloudlet_name=automationBonnCloudlet  cloudlet_org=TDG  connection_type=${connect1}  route_list=${routelist1}
         Should Be Equal  ${net_created['data']['key']['cloudlet_key']['name']}  automationBonnCloudlet
         Should Be Equal  ${net_created['data']['key']['cloudlet_key']['organization']}  TDG
         Should Be Equal  ${net_created['data']['connection_type']}  ${connect1}
         Should Be Equal  ${net_created['data']['routes']}  ${routelist1}
         Should Be Equal  ${net_created['data']['key']['name']}  ${networks-net}
         Log To Console   ${networks-net} was created
    ELSE
         Log To Console  ${\n}${networks-net} already exists
    END

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

Teardown
    Cleanup Provisioning
