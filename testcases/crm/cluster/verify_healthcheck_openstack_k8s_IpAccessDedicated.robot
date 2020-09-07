*** Settings ***
Documentation  Verify Healthcheck with IpAccessDedicated k8s

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

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:8.0
${docker_command}  ./server_ping_threaded.py
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when replicas are scaled to zero for app with one TCP access port
    [Documentation]
    ...  deploy IpAccessDedicated k8s and create app with one TCP access port
    ...  scale replicas to 0 and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}  number_of_replicas=0

    Verify Health Check  ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}  number_of_replicas=1

    Verify Health Check  ${app_name_default}  {cluster_name_default}  3
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3


IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when replicas are scaled to zero for app with TCP and UDP access ports
    [Documentation]
    ...  deploy IpAccessDedicated k8s and create app with one TCP and UDP access ports
    ...  scale replicas to 0 and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}  number_of_replicas=0

    Verify Health Check  ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

    K8s scale replicas  root_loadbalancer=${clusterlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}  number_of_replicas=1

    Verify Health Check  ${app_name_default}  {cluster_name_default}  3
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3


IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports
    [Documentation]
    ...  deploy IpAccessDedicated k8s and create app with 2 TCP access ports
    ...  bring down one port and verify healthcheck
    ...  verify healthcheck after the port comes up

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016

    Verify Health Check  ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

    Start TCP Port  ${tcp_fqdn}  2016

    Verify Health Check  ${app_name_default}  {cluster_name_default}  3
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3


IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports and TLS enabled on both ports
    [Documentation]
    ...  deploy IpAccessDedicated k8s and create app with 2 TCP access ports and TLS=true
    ...  bring down one port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016:tls  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016  tls=True

    Verify Health Check  ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2


IpAccessDedicated k8s - healthcheck shows HealthCheckFailServerFail when one port goes down for app with 2 TCP access ports and TLS enabled on one port
    [Documentation]
    ...  deploy IpAccessDedicated k8s and create app with 2 TCP access ports and TLS=true on one port
    ...  bring down one port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016  command=${docker_command} 
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2015  tls=True

    Verify Health Check  ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2


IpAccessDedicated k8s - healthcheck shows HealthCheckOk when TCP port with skip_hc goes down 
    [Documentation]
    ...  deploy IpAccessDedicated k8s and create app with 2 TCP access ports and skip_hc on 2nd port
    ...  bring down 2nd port and verify healthcheck
    ...  bring down 1st port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  command=${docker_command}  skip_hc_ports=tcp:2016
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Verify Health Check   ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3

    Stop TCP Port  ${tcp_fqdn}  2015
    Verify Health Check   ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2


IpAccessDedicated k8s - healthcheck shows proper state after UpdateApp
    [Documentation]
    ...  deploy IpAccessDedicated k8s and create app with 1 TCP access port
    ...  UpdateApp to add 3 TCP access ports and verify healthcheck
    ...  Delete App Inst
    ...  UpdateApp to add skip_hc_ports to one TCP port and verify healthcheck

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  auto_delete=False

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}
    Update App  region=${region}  access_ports=tcp:2015,tcp:2016,tcp:4015

    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  auto_delete=False

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016

    Verify Health Check   ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   2

    Start TCP Port  ${tcp_fqdn}  2016

    Verify Health Check   ${app_name_default}  {cluster_name_default}  3
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3

    Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}
    Update App  region=${region}   skip_hc_ports=tcp:2016

    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    ${tcp_fqdn}=   Set Variable  ${app_inst[0]['data']['uri']}

    Stop TCP Port  ${tcp_fqdn}  2016
    Verify Health Check   ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
    Should Be Equal As Numbers   ${app_inst[0]['data']['health_check']}   3

    Stop TCP Port  ${tcp_fqdn}  2015
    Verify Health Check   ${app_name_default}  {cluster_name_default}  2
    ${app_inst}=   Show App Instances   region=${region}  app_name=${app_name_default}  cluster_instance_name={cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
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
    
Verify Health Check
    [Arguments]   ${appname}  ${clustername}  ${state}

    FOR  ${x}  IN RANGE  0  30
        ${app_inst}=   Show App Instances   region=${region}  app_name=${appname}  cluster_instance_name=${clustername}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
        Exit For Loop If  '${app_inst[0]['data']['health_check']}' == '${state}'
        Sleep  2s
    END
