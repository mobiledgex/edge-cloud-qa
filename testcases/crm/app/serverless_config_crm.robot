*** Settings ***
Documentation  Serverless apps on CRM

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String
Library  Collections

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${region}  EU

${mobiledgex_domain}  mobiledgex-qa.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:8.0

${latitude}       32.7767
${longitude}      -96.7970
	
${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-4342
Serverless - shall be able to create appinst with server config of ram=1024, vcpu=1, replicas=1
    [Documentation]
    ...  - deploy k8s app with allowserverless=true ram=1024, vcpu=1, replicas=1
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_ram=1024  serverless_config_vcpus=1  serverless_config_min_replicas=1
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=1

    Pod Should Be Configured Correctly  memory=1Gi  cpu=1

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4343
Serverless - shall be able to create appinst with server config of ram=2000, vcpu=2, replicas=2
    [Documentation]
    ...  - deploy k8s app with allowserverless=true ram=2000, vcpu=2, replicas=2
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_ram=2000  serverless_config_vcpus=2  serverless_config_min_replicas=2
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=2

    Pod Should Be Configured Correctly  memory=2000Mi  cpu=2

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4344
Serverless - shall be able to create appinst with server config of ram=4096, vcpu=3, replicas=3
    [Documentation]
    ...  - deploy k8s app with allowserverless=true ram=4096, vcpu=3, replicas=3
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_ram=4096  serverless_config_vcpus=3  serverless_config_min_replicas=3
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=3

    Pod Should Be Configured Correctly  memory=4Gi  cpu=3

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4345
Serverless - shall be able to create appinst with allowserverless=True and no config
    [Documentation]
    ...  - deploy k8s app with allowserverless=true only
    ...  - verify pod comes up with correct configuration from defaultflavor

    [Tags]  Serverless

    ${flavor_default}=  Get Default Flavor Name

    Create Flavor  region=${region}  flavor_name=${flavor_default}2  ram=2049  disk=3  vcpus=2

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=1

    Pod Should Be Configured Correctly  memory=2049Mi  cpu=2

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4346
Serverless - shall be able to create appinst with allowserverless=True and ram only
    [Documentation]
    ...  - deploy k8s app with allowserverless=true and ram only
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    ${flavor_default}=  Get Default Flavor Name

    Create Flavor  region=${region}  flavor_name=${flavor_default}2  ram=2049  disk=3  vcpus=2

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_ram=4096
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=1

    Pod Should Be Configured Correctly  memory=4Gi  cpu=2

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4347
Serverless - shall be able to create appinst with allowserverless=True and vcpus only
    [Documentation]
    ...  - deploy k8s app with allowserverless=true and vcpus only
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    ${flavor_default}=  Get Default Flavor Name

    Create Flavor  region=${region}  flavor_name=${flavor_default}2  ram=2049  disk=3  vcpus=2

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_vcpus=3
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=1

    Pod Should Be Configured Correctly  memory=2049Mi  cpu=3

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4348
Serverless - shall be able to create appinst with allowserverless=True and replicas only
    [Documentation]
    ...  - deploy k8s app with allowserverless=true and replicas only
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    ${flavor_default}=  Get Default Flavor Name

    Create Flavor  region=${region}  flavor_name=${flavor_default}2  ram=2049  disk=3  vcpus=2

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_min_replicas=4
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=4

    Pod Should Be Configured Correctly  memory=2049Mi  cpu=2

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4349
Serverless - shall be able to create appinst with server config and ram=1024, vcpu=0.5, replicas=1
    [Documentation]
    ...  - deploy k8s app with allowserverless=true and ram=1024, vcpu=0.5, replicas=1
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_ram=1024  serverless_config_vcpus=0.5  serverless_config_min_replicas=1
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=1

    Pod Should Be Configured Correctly  memory=1Gi  cpu=500m

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4350
Serverless - shall be able to create appinst with server config and ram=1024, vcpu=4.444, replicas=2
    [Documentation]
    ...  - deploy k8s app with allowserverless=true and ram=1024, vcpu=4.444, replicas=2
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_ram=1024  serverless_config_vcpus=4.444  serverless_config_min_replicas=2
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=2

    Pod Should Be Configured Correctly  memory=1Gi  cpu=4.444

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4351
Serverless - shall be able to create appinst with server config and ram=1024, vcpu=0.001, replicas=2
    [Documentation]
    ...  - deploy k8s app with allowserverless=true and ram=1024, vcpu=0.001, replicas=2 
    ...  - verify pod comes up with correct configuration

    [Tags]  Serverless

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_ram=1024  serverless_config_vcpus=0.001  serverless_config_min_replicas=2
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=2

    Pod Should Be Configured Correctly  memory=1Gi  cpu=1m

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

# ECQ-4352
Serverless - shall be able to create appinst with server config of ram=50000, vcpu=500, replicas=500
    [Documentation]
    ...  - deploy k8s app with allowserverless=true and ram=5000, vcpu=5, replicas=5
    ...  - verify error is returned for not enough resources 

    [Tags]  Serverless

    EDGECLOUD-6111 appinst create on anthos with resources that are too large returns success but pods still pending

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015  allow_serverless=${True}  serverless_config_ram=50000  serverless_config_vcpus=500  serverless_config_min_replicas=500
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=5

    Pod Should Be Configured Correctly  memory=5000Mi  cpu=5

# ECQ-4353
Serverless - app1 shall not be able to reach app2
    [Documentation]
    ...  - deploy 2 k8s app with allowserverless=true 
    ...  - verify pod comes up with correct configuration
    ...  - verify each pod cannot reach the http port of the other pod

    [Tags]  Serverless

    ${kubeconfig1}=  Replace String  ${kubeconfig}  ${app_name_default}  ${app_name_default}1
    ${kubeconfig2}=  Replace String  ${kubeconfig}  ${app_name_default}  ${app_name_default}2
    ${kubeconfig1_split}=  Split String  ${kubeconfig1}  .kubeconfig
    ${kubeconfig2_split}=  Split String  ${kubeconfig2}  .kubeconfig
    ${kubeconfig1}=  Get SubString  ${kubeconfig1_split[0]}  0  83
    ${kubeconfig2}=  Get SubString  ${kubeconfig2_split[0]}  0  83
    IF  '${kubeconfig1}'.endswith('-')
        ${kubeconfig1}=  Get SubString  ${kubeconfig1}  0  -1
        ${kubeconfig2}=  Get SubString  ${kubeconfig2}  0  -1
    END

    ${kubeconfig1}=  Set Variable  ${kubeconfig1}.kubeconfig
    ${kubeconfig2}=  Set Variable  ${kubeconfig2}.kubeconfig

    Log To Console  Creating App and App Instance
    Create App  region=${region}  app_name=${app_name_default}1  image_path=${docker_image}  access_ports=tcp:2015,udp:2016,tcp:8085  allow_serverless=${True}  serverless_config_ram=1024  serverless_config_vcpus=1  serverless_config_min_replicas=1
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  dedicated_ip=${True}

    Create App  region=${region}  app_name=${app_name_default}2  image_path=${docker_image}  access_ports=tcp:2015,udp:2016,tcp:8085  allow_serverless=${True}  serverless_config_ram=1024  serverless_config_vcpus=1  serverless_config_min_replicas=1
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  dedicated_ip=${True}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig1}  pod_name=${app_name_default}1  number_of_pods=1
    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig2}  pod_name=${app_name_default}2  number_of_pods=1

    Pod Should Be Configured Correctly  memory=1Gi  cpu=1  kubeconfig_file=${kubeconfig1} 
    Pod Should Be Configured Correctly  memory=1Gi  cpu=1  kubeconfig_file=${kubeconfig2}

    Ports Should Be Alive  http=${True}
 
    ${ip1}=  Get Pod Ip  kubeconfig_file=${kubeconfig1}
    ${ip2}=  Get Pod Ip  kubeconfig_file=${kubeconfig2}

    # these should work since it curling itself
    Run Command On Pod  root_loadbalancer=${clusterlb}  pod_name=${app_name_default}1  command=curl ${ip1}:8085/${http_port_page}  kubeconfig=${kubeconfig1}
    Run Command On Pod  root_loadbalancer=${clusterlb}  pod_name=${app_name_default}2  command=curl ${ip2}:8085/${http_port_page}  kubeconfig=${kubeconfig2}

    # these should fail since it is curling the other pod
    Run Keyword and Expect Error  cmd returned non-zero status of 28  Run Command On Pod  root_loadbalancer=${clusterlb}  pod_name=${app_name_default}1  command=curl ${ip2}:8085/${http_port_page}  kubeconfig=${kubeconfig1}
    Run Keyword and Expect Error  cmd returned non-zero status of 28  Run Command On Pod  root_loadbalancer=${clusterlb}  pod_name=${app_name_default}2  command=curl ${ip1}:8085/${http_port_page}  kubeconfig=${kubeconfig2}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}1
    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}2

# ECQ-4354
Serverless - shall be able to update appinst with server config
    [Documentation]
    ...  - deploy k8s app with allowserverless=true ram=1024, vcpu=1, replicas=1
    ...  - verify pod comes up with correct configuration
    ...  - update the app to ram=2048, vcpu=2, replicas=2
    ...  - refresh the appinst
    ...  - verify pod comes up with new configuration

    [Tags]  Serverless

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  allow_serverless=${True}  serverless_config_ram=1024  serverless_config_vcpus=1  serverless_config_min_replicas=1
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=1

    Pod Should Be Configured Correctly  memory=1Gi  cpu=1

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Update App  region=${region}  serverless_config_ram=2048  serverless_config_vcpus=2  serverless_config_min_replicas=2
    Refresh App Instance  region=${region}

    Wait for K8s Pod To Be Running  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig}  pod_name=${app_name_default}  number_of_pods=2

    Pod Should Be Configured Correctly  memory=2Gi  cpu=2

    Ports Should Be Alive

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

*** Keywords ***
Setup
    #${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Set Variable  ${cloudlet_name_crm}-${operator_name_crm}.${region}.${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_crm}

    ${cluster_name_default}=  Get Default Cluster Name

    Create Flavor     region=${region}

    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}

    ${dev_name}=  Get Default Developer Name
    ${app_name_default}=  Get Default App Name
    ${app_version_default}=  Get Default App Version

    ${kubeconfig}=  Set Variable  ${None}
    ${cluster_name_default}=  Get Default Cluster Name

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=1
        Log To Console  Done Creating Cluster Instance

        ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}
    ELSE
        ${clusterlb}=  Catenate  SEPARATOR=.  shared  ${rootlb}
        ${dev_name_hyphen}=  Replace String  ${dev_name}  _  -
        ${app_version_change}=  Replace String  ${app_version_default}  .  ${EMPTY}
        ${kubeconfig}=  Set Variable  defaultclust.${operator_name_crm}.${dev_name_hyphen}-${app_name_default}-${app_version_change}-${cluster_name_default}
        ${kubeconfig}=  Get SubString  ${kubeconfig}  0  83
        IF  '${kubeconfig}'.endswith('-')
            ${kubeconfig}=  Get SubString  ${kubeconfig}  0  -1
        END
        ${kubeconfig}=  Set Variable  ${kubeconfig}.kubeconfig
    END
    Set Suite Variable  ${platform_type}

    Set Suite Variable  ${cluster_name_default}
    Set Suite Variable  ${clusterlb}
    Set Suite Variable  ${cloudlet_lowercase}
    Set Suite Variable  ${kubeconfig}
    Set Suite Variable  ${app_name_default}

Pod Should Be Configured Correctly
    [Arguments]  ${memory}  ${cpu}  ${kubeconfig_file}=${kubeconfig}

    ${describe}=  Describe Pod  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig_file}  pod_name=${app_name_default}

    @{list_mod}=  Create List
    FOR  ${l}  IN  @{describe}
       ${s}=  Replace String Using Regexp  ${l}  \\s+  ${EMPTY}
       Append To List  ${list_mod}  ${s}
    END

    ${num_cpu}=  Count Values In List  ${list_mod}  cpu:${cpu}
    ${num_mem}=  Count Values In List  ${list_mod}  memory:${memory}

    Should Be Equal As Numbers  ${num_cpu}  2
    Should Be Equal As Numbers  ${num_mem}  2

Ports Should Be Alive
   [Arguments]  ${http}=${False}

   Register Client
   ${found}=  Set Variable  ${False}
   FOR  ${i}  IN RANGE  1  90
       ${cloudlet}=  Run Keyword and Ignore Error  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
       IF  '${cloudlet[0]}' == 'PASS'
           ${found}=  Set Variable  ${True}
           Exit For Loop
       ELSE
           Sleep  1s
       END
   END

   IF  ${found} == ${True}
      ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet[1].ports[0].fqdn_prefix}  ${cloudlet[1].fqdn}
      ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet[1].ports[1].fqdn_prefix}  ${cloudlet[1].fqdn}
      FOR  ${i}  IN RANGE  1  90
          ${alive}=  Run Keyword and Ignore Error  TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet[1].ports[0].public_port}  app_name=${app_name_default}
          ${alive}=  Run Keyword and Ignore Error  UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet[1].ports[1].public_port}  app_name=${app_name_default}
          IF  '${alive[0]}' == 'PASS'
              Exit For Loop
          ELSE
              Sleep  1s
          END
      END
   ELSE
      Fail  FindCloudlet failed
   END

   IF  ${http}
      HTTP Port Should Be Alive  ${fqdn_0}  ${cloudlet[1].ports[2].public_port}  ${http_port_page}
   END

Get Pod IP
    [Arguments]   ${kubeconfig_file}=${kubeconfig}

    ${describe}=  Describe Pod  root_loadbalancer=${clusterlb}  kubeconfig=${kubeconfig_file}  pod_name=${app_name_default}

    FOR  ${l}  IN  @{describe}
        ${l}=  Replace String Using Regexp  ${l}  \\s+  ${EMPTY}
        IF  'IP:' in '${l}'
            ${podips}=   Split String  ${l}  :
            ${podip}=  Set Variable  ${podips[1]}
            Exit For Loop
        END
    END
   
    [Return]  ${podip} 
