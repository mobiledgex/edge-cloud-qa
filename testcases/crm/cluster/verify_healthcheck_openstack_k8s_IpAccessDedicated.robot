*** Settings ***
Documentation  Verify Healthcheck with IpAccessDedicated k8s

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Suite Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_dedicated}  automationBuckhornCloudlet

${operator_name_openstack}  GDDT

${region}  EU

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:8.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${latitude}       32.7767
${longitude}      -96.7970
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-2505
IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when replicas are scaled to zero for app with one TCP access port
    [Documentation]
    ...  - deploy IpAccessDedicated k8s and create app with one TCP access port
    ...  - scale replicas to 0 and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  number_of_replicas=0
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  number_of_replicas=1
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-2506
IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when replicas are scaled to zero for app with TCP and UDP access ports
    [Documentation]
    ...  - deploy IpAccessDedicated k8s and create app with one TCP and UDP access ports
    ...  - scale replicas to 0 and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  command=${docker_command}  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  number_of_replicas=0
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  number_of_replicas=1
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-2507
IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports
    [Documentation]
    ...  - deploy IpAccessDedicated k8s and create app with 2 TCP access ports
    ...  - bring down one port and verify healthcheck
    ...  - verify healthcheck after the port comes up

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015  command=${docker_command}  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

    Register Client
    ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    Should Contain  ${error_msg}  FIND_NOTFOUND

    Start TCP Port  ${tcp_fqdn}  2016
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

# ECQ-2508
IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports in range
    [Documentation]
    ...  - deploy IpAccessDedicated k8s and create app with 2 TCP access ports in a range
    ...  - bring down 2nd port in range and verify healthcheck
    ...  - verify healthcheck after the port comes up

    #EDGECLOUD-3427 - CreateAppInst with large port range not setting the proper security group rule
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016,tcp:4015  command=${docker_command}  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].end_port}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

    Register Client
    ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    Should Contain  ${error_msg}  FIND_NOTFOUND

    Start TCP Port  ${tcp_fqdn}  2016
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].end_port}

# ECQ-2509
IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports and TLS enabled on both ports
    [Documentation]
    ...  - deploy IpAccessDedicated k8s and create app with 2 TCP access ports and TLS=true
    ...  - bring down one port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016:tls  command=${docker_command}  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  tls=${True}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}  tls=${True}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016  tls=True
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

    Register Client
    ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    Should Contain  ${error_msg}  FIND_NOTFOUND

# ECQ-2510
IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports and TLS enabled on one port
    [Documentation]
    ...  - deploy IpAccessDedicated k8s and create app with 2 TCP access ports and TLS=true on one port
    ...  - bring down one port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016  command=${docker_command}   allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  tls=${True}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2015  tls=True
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

    Register Client
    ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    Should Contain  ${error_msg}  FIND_NOTFOUND

# ECQ-2511
IpAccessDedicated k8s - healthcheck shows HealthCheckOk when TCP port with skip_hc goes down 
    [Documentation]
    ...  - deploy IpAccessDedicated k8s and create app with 2 TCP access ports and skip_hc on 2nd port
    ...  - bring down 2nd port and verify healthcheck
    ...  - bring down 1st port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  command=${docker_command}  skip_hc_ports=tcp:2016  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Verify Health Check Ok   ${app_name_default}  ${cluster_name_default}  2

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}

    Stop TCP Port  ${tcp_fqdn}  2015
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

    Register Client
    ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    Should Contain  ${error_msg}  FIND_NOTFOUND

# ECQ-2512
IpAccessDedicated k8s - healthcheck shows proper state when skip_hc_ports has a list of ports
    [Documentation]
    ...  - deploy IpAccessDedicated docker and create app with 3 TCP access ports,skip_hc on 1st port and 2nd port
    ...  - bring down 2nd port and verify healthcheck
    ...  - bring down 1st port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:8085  command=${docker_command}  skip_hc_ports=tcp:2015,tcp:2016  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Verify Health Check Ok   ${app_name_default}  ${cluster_name_default}  2

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}

    Stop TCP Port  ${tcp_fqdn}  2015
    Verify Health Check Ok   ${app_name_default}  ${cluster_name_default}  2

    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}

# ECQ-2513
IpAccessDedicated k8s - healthcheck shows proper state when skip_hc_ports has a range of ports
    [Documentation]
    ...  - deploy IpAccessDedicated docker and create app with 3 TCP access ports and skip_hc has a port range
    ...  - bring down 2nd port in skip_hc_ports range and verify healthcheck
    ...  - bring down 1st port in skip_hc_ports range and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016,tcp:8085  command=${docker_command}  skip_hc_ports=tcp:2015-2016  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Verify Health Check Ok   ${app_name_default}  ${cluster_name_default}  2

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}

    Stop TCP Port  ${tcp_fqdn}  2015
    Verify Health Check Ok   ${app_name_default}  ${cluster_name_default}  2

    HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}

# ECQ-2514
IpAccessDedicated k8s - healthcheck shows proper state after UpdateApp
    [Documentation]
    ...  - deploy IpAccessDedicated k8s and create app with 1 TCP access port
    ...  - UpdateApp to add 3 TCP access ports and verify healthcheck
    ...  - Delete App Inst
    ...  - UpdateApp to add skip_hc_ports to one TCP port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  allow_serverless=${allow_serverless}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  auto_delete=False

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}
    Update App  region=${region}  access_ports=tcp:2015,tcp:2016,tcp:4015

    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  auto_delete=False

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

    Start TCP Port  ${tcp_fqdn}  2016
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}
    Update App  region=${region}   skip_hc_ports=tcp:2016

    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Verify Health Check Ok   ${app_name_default}  ${cluster_name_default}  2

    Stop TCP Port  ${tcp_fqdn}  2015
    Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name_default}

*** Keywords ***
Setup
    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_crm}

    Create Flavor     region=${region}

    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}

    IF  '${platform_type}' == 'K8SBareMetal'
        ${allow_serverless}=  Set Variable  ${True}
    ELSE
        Log To Console  Creating Cluster Instance
        Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=1
        Log To Console  Done Creating Cluster Instance
        ${allow_serverless}=  Set Variable  ${None}
    END
    Set Suite Variable  ${platform_type}
    Set Suite Variable  ${allow_serverless}

    ${cluster_name_default}=  Get Default Cluster Name

    ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}
    Set Suite Variable  ${cluster_name_default}
    Set Suite Variable  ${clusterlb}
    Set Suite Variable  ${cloudlet_lowercase}
    
Verify Health Check Ok
    [Arguments]   ${appname}  ${clustername}  ${state}

    FOR  ${x}  IN RANGE  0  30
        ${app_inst}=   Show App Instances   region=${region}  app_name=${appname}  cluster_instance_name=${clustername}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '${state}'
        Sleep  2s
    END
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3
