# -*- coding: robot -*-
*** Settings ***
Documentation  App 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections
Library  DateTime

Test Setup      Setup
Test Teardown   Cleanup provisioning

#Test Timeout    ${test_timeout_crm}
Test Timeout  25m

*** Variables ***
${region}  US
${docker_image_web9090}  docker-qa.mobiledgex.net/automation_dev_org/images/jmeterplus8076:14.7.6
${developer_org_name}  automation_dev_org
${developer_org_name_automation}  automation_dev_org
${cluster_name_9090}   cluster169090
${app_name_9090}   app169090
${app_version_9090}  14.7.6
# ${test_timeout_crm}  20 min
${flavor_name}
${app_version}
${app_name}
${access_tcp_port}  tcp:9090


*** Test Cases ***
# ECQ-4453
User shall be able to use port 9090 without exposing prometheus service
    [Documentation]
    ...  - deploy k8s app using internal port 9090
    ...  - verify prometheus external-ip on port 9090 is not the same as the appinst on a dedicated k8s clusterinst
    ...  - Check that a shared appinst can be craeted on same cloudlet using port 9090 check internal and external ip 
    ...  - Create a second shared appinst on the same shared clusterinst using internal port 9090 check the external port is remapped
    ...  - Check that you will get an error when creating a second appinst on the same dedicated k8s cluster using the same port internal port 9090 ec-6437 


    Run Keyword  Dedicated Cluster With App 9090

    ${appinst_9090}=  Create App Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
    Log To Console  ${\n}Done Creating Appinst
    ${kube_cfg}=  Catenate  ${cluster_name}.${operator_name_crm}.kubeconfig
    # EDGECLOUD-5735
    # Verify port 9090 should be mapped to different External IP than prometheus using kubectl get svc to get specific appinst and prometheus service
    # ${svc_ip2} = 10.101.1.200  ${svc_ip} = 10.101.1.201 will retrun ip for each to compare LoadBalancer 10.101.1.200 9090:30157/TCP  ${svc_port2} = 9090:31724/TCP  ${svc_port} = 9090:31085/TCP
    ${chk_svc_ip}=     Set Variable  export KUBECONFIG=${kube_cfg};kubectl get svc|grep mexprometheusappnamev10-ku-prometheus|awk \'{ if ( \$2 == "LoadBalancer" ) print \$4 }\'
    Sleep  1s
    ${chk_svc_ip2}=    Set Variable  export KUBECONFIG=${kube_cfg};kubectl get svc|grep app169090-prom|awk \'{ if ( \$2 == "LoadBalancer" ) print \$4 }\'
    Sleep  1s
    ${chk_svc_port}=   Set Variable  export KUBECONFIG=${kube_cfg};kubectl get svc|grep mexprometheusappnamev10-ku-prometheus|awk \'{ if ( \$2 == "LoadBalancer" ) print \$5 }\'
    Sleep  1s
    ${chk_svc_port2}=  Set Variable  export KUBECONFIG=${kube_cfg};kubectl get svc|grep app169090-prom|awk \'{ if ( \$2 == "LoadBalancer" ) print \$5 }\'

    ${svc_ip}=     Access Cloudlet  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  region=${region}  command=${chk_svc_ip}  node_name=${nodename_lb}  node_type=dedicatedrootlb
    ${svc_ip2}=    Access Cloudlet  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  region=${region}  command=${chk_svc_ip2}  node_name=${nodename_lb}  node_type=dedicatedrootlb
    ${svc_port}=   Access Cloudlet  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  region=${region}  command=${chk_svc_port}  node_name=${nodename_lb}  node_type=dedicatedrootlb
    ${svc_port2}=  Access Cloudlet  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  region=${region}  command=${chk_svc_port2}  node_name=${nodename_lb}  node_type=dedicatedrootlb
    ${svc_ip}=     Convert To String  ${svc_ip}
    ${svc_ip2}=    Convert To String  ${svc_ip2}
    ${svc_port}=   Convert To String  ${svc_port}
    ${svc_port2}=  Convert To String  ${svc_port2}
    ${svc_ip}=     Remove String  ${svc_ip}  \r\n
    ${svc_ip2}=    Remove String  ${svc_ip2}  \r\n
    ${svc_port}=   Remove String  ${svc_port}  \r\n
    ${svc_port2}=  Remove String  ${svc_port2}  \r\n
    Should Contain  ${svc_port} ${svc_port2}  9090
    Should Not Be Equal As Strings  ${svc_ip}  ${svc_ip2}
    ${svc_ip}=   Remove String  ${svc_ip}  .
    ${svc_ip2}=  Remove String  ${svc_ip2}  .
    ${svc_ip}=   Convert To Number  ${svc_ip}
    ${svc_ip2}=  Convert To Number  ${svc_ip2}
    Should Not Be Equal As Numbers  ${svc_ip}  ${svc_ip2}

    # Check that a shared appinst can be craeted on same cloudlet with existing port 9090 on an esiting ded k8s clusterinst and check the internal external port 9090
    Run Keyword  App2 Prom2 9090
    Sleep  1s
    Run Keyword  Shared Cluster With App 9090
    Create App Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_shr}  app_name=${app_name2}  app_version=${app_version}  developer_org_name=${developer_org_name}

    ${public_check}=  Show App Instances  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_shr}  app_name=${app_name2}  app_version=${app_version}  developer_org_name=${developer_org_name}

    ${internal_port_val}=  Set Variable  ${public_check[0]['data']['mapped_ports'][0]['internal_port']}
    ${public_port_val}=  Set Variable  ${public_check[0]['data']['mapped_ports'][0]['public_port']}
    Log To Console  ${\n}
    Log To Console  Internal port=${internal_port_val}
    Log To Console  Public port=${public_port_val}
    Should Be Equal   ${internal_port_val}  ${public_port_val}

    # Create second shared appinst Check that a shared appinst check that port 9090 external port is remapped
    Run Keyword  App3 Prom3 9090
    Create App Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_shr}  app_name=${app_name3}  app_version=${app_version}  developer_org_name=${developer_org_name}

    ${public_check2}=  Show App Instances  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_shr}  app_name=${app_name3}  app_version=${app_version}  developer_org_name=${developer_org_name}

    ${internal_port_val2}=  Set Variable  ${public_check2[0]['data']['mapped_ports'][0]['internal_port']}
    ${public_port_val2}=  Set Variable  ${public_check2[0]['data']['mapped_ports'][0]['public_port']}
    Log To Console  ${\n}
    Log To Console  Internal port=${internal_port_val2}
    Log To Console  Public port=${public_port_val2}
    Should Not Be Equal   ${internal_port_val2}  ${public_port_val2}

    #EDGECLOUD-6347 Currently you will get an error this test should fail when EC-6347 is resolved and can be updated.
    Run Keyword  Appded2 Promded2 9090

    ${err_9090}=  Set Variable  (\'code=400\', \'error={"message":"Port 9090 is already in use on the cluster"}\')

    ${9090_err}=    Run Keyword and Expect Error  *  Create App Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  app_name=${app_name_ded2}  app_version=${app_version}  developer_org_name=${developer_org_name}
    Should Be Equal As Strings   ${err_9090}  ${9090_err}
    ${err_9090}=  Set Variable  (\'code=400\', \'error={"message":"Port 9090 is already in use on the cluster"}\')
    Should Be Equal As Strings   ${err_9090}  ${9090_err}

*** Keywords ***
Setup
    ${super_token}  Get Super Token
    Set Suite Variable  ${super_token}
    ${cluster_name}=  Set Variable  ${cluster_name_9090} 
    ${date}=         Get Current Date  result_format=epoch  exclude_millis=no
    Set Suite Variable  ${date}
    ${epoch}=        Convert Date    ${date}    epoch  exclude_millis=yes
    ${epoch}=        Convert To String  ${epoch}
    ${epoch}=        Remove String   ${epoch}  .0
    ${rand_str}=  Generate Random String  length=2
    ${cluster_name}=  Catenate  ${cluster_name_9090}-PROM-${rand_str}-${epoch}
    ${cluster_name_shr}=  Catenate  ${cluster_name_9090}-Promshr-${rand_str}-${epoch}
    ${cluster_name_ded2}=  Catenate  ${cluster_name_9090}-Promded2-${rand_str}-${epoch}
    Set Suite Variable  ${cluster_name}
    ${kube_cfg}=  Catenate  ${cluster_name}.${developer_org_name}.kubeconfig
    ${kube_cfg}=  Convert To Lowercase  ${kube_cfg}
    Set Suite Variable  ${cluster_name_shr}
    Set Suite Variable  ${cluster_name_ded2}
    ${app_name}=      Catenate  ${app_name_9090}-PROM-${rand_str}-${epoch}
    ${app_name2}=      Catenate  ${app_name_9090}-PROM2-${rand_str}-${epoch}
    ${app_name3}=      Catenate  ${app_name_9090}-PROM3-${rand_str}-${epoch}
    ${app_name_ded2}=  Catenate  ${app_name_9090}-PROMDed2-${rand_str}-${epoch}
    Set Suite Variable  ${app_name}
    Set Suite Variable  ${app_name2}
    Set Suite Variable  ${app_name3}
    Set Suite Variable  ${app_name_ded2}
    ${docker_image}=  Set Variable  ${docker_image_web9090}
    Set Suite Variable  ${docker_image}
    ${app_version}=  Set Variable  ${app_version_9090}
    Set Suite Variable  ${app_version}
    ${flavor_name}=     Set Variable   automation_api_flavor
    Set Suite Variable    ${flavor_name}
    Log To Console  ${flavor_name}
    ${developer_org_name_automation}  Set Variable  ${developer_org_name}
    ${dev_org}=  Set Variable  ${developer_org_name_automation}
    ${dev_org_dash}=   Replace String  ${dev_org}  _  -
    ${cloudlet_dash}=  Replace String  ${cloudlet_name_crm}  _  -
    ${operator_dash}=  Replace String  ${operator_name_crm}  _  -
    ${cluster_dash}=   Replace String  ${Cluster_name}  _  -
    ${cluster_dash2}=  Replace String  ${Cluster_name_shr}  _  -
    ${cluster_dash3}=  Replace String  ${Cluster_name_ded2}  _  -
    ${rootlb}=  Set Variable  ${cluster_dash}-${dev_org_dash}.${cloudlet_dash}-${operator_dash}.${region}.${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    ${rootlb2}=  Set Variable  ${cluster_dash2}-${dev_org_dash}.${cloudlet_dash}-${operator_dash}.${region}.${mobiledgex_domain}
    ${rootlb2}=  Convert To Lowercase  ${rootlb2}
    ${rootlb3}=  Set Variable  ${cluster_dash3}-${dev_org_dash}.${cloudlet_dash}-${operator_dash}.${region}.${mobiledgex_domain}
    ${rootlb3}=  Convert To Lowercase  ${rootlb3}
    Set Suite Variable  ${rootlb}
    Set Suite Variable  ${rootlb2}
    Set Suite Variable  ${rootlb3}
    ${node_name_lb}=   Set Variable  ${rootlb}
    ${node_name_lb2}=  Set Variable  ${rootlb2}
    ${node_name_lb3}=  Set Variable  ${rootlb3}
    Set Suite Variable  ${node_name_lb}
    Set Suite Variable  ${node_name_lb2}
    Set Suite Variable  ${node_name_lb3}
    Log To Console  ${\n}${node_name_lb} using for accesscloudlet
    Log To Console  ${\n}${node_name_lb2} using for accesscloudlet
    Log To Console  ${\n}${node_name_lb3} using for accesscloudlet

App2 Prom2 9090
    Log To Console  Creating App
    Create App  token=${super_token}  region=${region}  image_path=${docker_image}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  image_type=ImageTypeDocker  deployment=kubernetes  app_name=${app_name2}   default_flavor_name=${flavor_name}

App3 Prom3 9090
    Log To Console  Creating App
    Create App  token=${super_token}  region=${region}  image_path=${docker_image}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  image_type=ImageTypeDocker  deployment=kubernetes  app_name=${app_name3}   default_flavor_name=${flavor_name}

Appded2 Promded2 9090
    Log To Console  Creating App
    Create App  token=${super_token}  region=${region}  image_path=${docker_image}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  image_type=ImageTypeDocker  deployment=kubernetes  app_name=${app_name_ded2}   default_flavor_name=${flavor_name}

Shared Cluster With App 9090
    ${super_token}  Get Super Token
    Set Variable  ${super_token}
    Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=IpAccessShared  number_masters=1  number_nodes=0  deployment=kubernetes  developer_org_name=${developer_org_name}  cluster_name=${cluster_name_shr}  flavor_name=${flavor_name}    #flavor_name=${cluster_flavor_name}      
    Log To Console  Done Creating Cluster Instance

Dedicated Cluster With App 9090
    Log To Console  Creating App
    Create App  token=${super_token}  region=${region}  image_path=${docker_image}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  image_type=ImageTypeDocker  deployment=kubernetes  app_name=${app_name}   default_flavor_name=${flavor_name}

    ${cluster_info}=  Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=IpAccessDedicated  number_masters=1  number_nodes=0  deployment=kubernetes  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  flavor_name=${flavor_name}  #flavor_name=${cluster_flavor_name}      Set Suite Variable  ${cluster_info}
    Log To Console  Done Creating Cluster Instance

# Notes
# robodry  --outputdir ~/robot-tc-logs/ -l packet-vcd-03-log.html -o packet-vcd-03-output.xml -r packet-vcd-03-report.html -v cloudlet_name_crm:automationDallasCloudlet -v operator_name_crm:packet  -v developer_org_name_automation:automation_dev_org  -t "User shall be able to use port 9090 without exposing prometheus service" create_appInst_IpAccessDedicated_k8s_port9090.robot
# NAME                                               TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)            AGE
# mexprometheusappnamev10-ku-prometheus              LoadBalancer   10.106.171.255   10.101.1.10   9090:31067/TCP     3h26m
# smokepingkuberlatest-tcp                           LoadBalancer   10.107.188.212   10.101.1.10   9090:32279/TCP     147m
#
# mcctl --addr https://console-qa.mobiledgex.net:443 accesscloudlet cloudlet=qawwt-cld1 region=US cloudletorg=wwt nodetype=sharedrootlb command="export KUBECONFIG=k8s-cluster-shared-9090.wwt.kubeconfig;export MYPOD_QA=\$(kubectl get pods \$(kubectl get pods | grep jmeterplus9090 | awk f1) |egrep -C 0 "jmeter" |awk '{ print \$1 }');kubectl get pods $MYPOD_QA;kubectl get services;kubectl exec \$MYPOD_QA -- bash -c 'echo my uptime;uptime;echo my uname is;uname -a;echo my ip;curl -s ifconfig.me;echo;echo my user is;whoami;echo curl -Is shared.qawwt-cld1-wwt.us.mobiledgex.net:9090;curl -Is shared.qawwt-cld1-wwt.us.mobiledgex.net:9090;echo netstat;netstat -a'" -t
# NAME                                               TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                                        AGE
# jmeterplus90901476-tcp                             LoadBalancer   10.105.31.40     10.201.0.201   8076:30308/TCP,8077:30969/TCP,9090:30458/TCP   56m
