*** Settings ***
Documentation  use FQDN to access app with metallb

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${region}=  US

${cloudlet_name_crm}  automationBonnCloudlet
${operator_name_crm}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-4904
User shall be able to access UDP,TCP and HTTP ports after masternode stopped
    [Documentation]
    ...  - deploy app with 1 UDP and 1 TCP and 1 HTTP ports
    ...  - verify all ports are accessible via fqdn
    ...  - shutdown master node
    ...  - verify all ports are accessible via fqdn after shutdown

    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port} 

#    ${platform_type}=  Set Variable  11
#    ${cluster_name_default}=  Set Variable  cluster1634670098-223624
#    ${masternode_name}=  Set Variable  mex-k8s-master-automationdallascloudlet-cluster1634670098-223624-automation-dev-org
    IF  ${platform_type} == 2    #openstack
        ${rundebug_out}=  Run Debug  cloudlet_name=${cloudlet_name_crm}  node_type=crm  command=oscmd  args=openstack server stop ${masternode_name}
        Should Be True  'output' not in ${rundebug_out[0]['data']}  # no error returned
        Sleep  30s
        ${rundebug_out2}=  Run Debug  cloudlet_name=${cloudlet_name_crm}  node_type=crm  command=oscmd  args=openstack server list --name ${masternode_name}
        Should Contain  ${rundebug_out2[0]['data']['output']}  SHUTOFF
    ELSE IF  ${platform_type} == 11    #openstack
        ${vcd_cmd}=  Convert To Lowercase  ${cloudlet_name_crm}-${cluster_name_default}-automation-dev-org-vapp ${masternode_name}
        ${rundebug_out}=  Run Debug  cloudlet_name=${cloudlet_name_crm}  node_type=crm  command=crmcmd  args=/usr/bin/env LC_ALL=C.UTF-8 LANG=C.UTF-8 vcd vm power-off ${vcd_cmd}  timeout=60s
        Sleep  30s
        ${rundebug_out2}=  Run Debug  cloudlet_name=${cloudlet_name_crm}  node_type=crm  command=crmcmd  args=/usr/bin/env LC_ALL=C.UTF-8 LANG=C.UTF-8 vcd vm info ${vcd_cmd}
        Should Contain  ${rundebug_out2[0]['data']['output']}  Powered off
    ELSE
        Fail  Unknown platform type
    END

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}
 
*** Keywords ***
Setup
    ${cluster_name_default}=  Get Default Cluster Name

    ${cloudlet}=  Show Cloudlets  region=${region}  cloudlet_name=${cloudlet_name_crm}
    ${platform_type}=  Set Variable  ${cloudlet[0]['data']['platform_type']}
   
    Create Flavor  region=${region}
    Log To Console  Creating Cluster Instance
    ${clusterinst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    IF  '${clusterinst['data']['resources']['vms'][0]['type']}' == 'cluster-master'
        ${masternode_name}=  Set Variable  ${clusterinst['data']['resources']['vms'][0]['name']}
    ELSE
        ${masternode_name}=  Set Variable  ${clusterinst['data']['resources']['vms'][1]['name']}
    END
    #${masternode_name}=  Set Variable  mex-k8s-master-automationbonncloudlet-cluster1634586341-9922829-automation-dev-org

    Set Suite Variable  ${masternode_name}
    Set Suite Variable  ${clusterinst}
    Set Suite Variable  ${platform_type}
    Set Suite Variable  ${cluster_name_default}

Teardown
    IF  ${platform_type} == 2    #openstack
        ${rundebug_out}=  Run Debug  cloudlet_name=${cloudlet_name_crm}  node_type=crm  command=oscmd  args=openstack server start ${masternode_name}
    ELSE IF  ${platform_type} == 11    #openstack
        ${vcd_cmd}=  Convert To Lowercase  ${cloudlet_name_crm}-${cluster_name_default}-automation-dev-org-vapp ${masternode_name}
        ${rundebug_out}=  Run Debug  cloudlet_name=${cloudlet_name_crm}  node_type=crm  command=crmcmd  args=/usr/bin/env LC_ALL=C.UTF-8 LANG=C.UTF-8 vcd vm power-on ${vcd_cmd}  timeout=60s
    END

    Sleep  30s

    Cleanup provisioning
