*** Settings ***
Documentation   Create AppInst with Trusted Parm 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0

${app_counter}=  ${0}

${region}=  US
${operator_name_fake}=  tmus

*** Test Cases ***
# ECQ-3103
CreateAppInst - User shall be able to create a autocluster k8s/docker/helm/vm loadbalancer/direct appinst with trusted parm
   [Documentation]
   ...  - create autocluster k8s/docker/helm/vm lb/direct appinst with trusted=True
   ...  - verify app is created

   [Tags]  TrustPolicy

   [Template]  Create Trusted Autocluster AppInst

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}      
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}     
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}    
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}   
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}  
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image} 
   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}
   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}

# ECQ-3104
CreateAppInst - User shall be able to create a k8s/docker/helm/vm loadbalancer/direct appinst with trusted parm
   [Documentation]
   ...  - create k8s/docker/helm/vm lb/direct appinst with trusted=True
   ...  - verify app is created

   [Tags]  TrustPolicy

   [Template]  Create Trusted AppInst

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}
   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}

# ECQ-3105
CreateAppInst - User shall be able to create a trusted k8s/docker/helm/vm loadbalancer/direct appinst with RequiredOutboundConnections
   [Documentation]
   ...  - create k8s/docker/helm/vm lb/direct app with RequiredOutboundConnections matching trust policy
   ...  - verify app is created

   [Tags]  TrustPolicy

   EDGECLOUD-4224 able to CreateAppInst on trusted cloudlet with different requiredoutboundconnections than trust policy

   [Setup]  Setup RequiredOutboundConnections

   [Template]  Create Trusted AppInst with RequiredOutboundConnections

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${tcp1_rulelist}
#   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
#   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
#   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}
#   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}

# ECQ-3106
CreateAppInst - Error shall be received for create with RequiredOutboundConnections not matching the trust policy
   [Documentation]
   ...  - create k8s/docker/helm/vm lb/direct app with RequiredOutboundConnections not matching trust policy
   ...  - verify error is received

   [Tags]  TrustPolicy

   EDGECLOUD-4224 able to CreateAppInst on trusted cloudlet with different requiredoutboundconnections than trust policy

   [Setup]  Setup RequiredOutboundConnections

   [Template]  Create Trusted AppInst with RequiredOutboundConnections

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${tcp1_rulelist}
#   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
#   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
#   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
#   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}
#   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}

# ECQ-3107
CreateAppInst - Error shall be received for create of untrusted appinst on trusted cloudlet
   [Documentation]
   ...  - create k8s/docker/helm/vm lb/direct untrusted appinst 
   ...  - verify error is created

   [Tags]  TrustPolicy

   [Template]  Fail Create Untrusted AppInst

   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image} 
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image} 
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image} 
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}

# ECQ-3108
CreateAppInst - Error shall be received for create of untrusted autocluster appinsts on trusted cloudlet
   [Documentation]
   ...  - create k8s/docker/helm/vm lb/direct untrusted autocluster appinst on trusted cloudlet
   ...  - verify error is created

   [Tags]  TrustPolicy

   [Template]  Fail Create Untrusted AutoCluster AppInst

   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image} 
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image} 
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}
   ('code\=400', 'error\={"message":"Cannot start non trusted App on trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}
 
*** Keywords ***
Setup
   Create Flavor  region=${region}
   ${appname}=  Get Default App Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${cluster_name}=  Get Default Cluster Name

   ${policy_name}=  Get Default Trust Policy Name

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${operator_name_fake}

   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${policy_return['data']['key']['name']}

   Set Suite Variable  ${app_name}  
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}

Setup RequiredOutboundConnections
   Setup

   &{rule1}=  Create Dictionary  protocol=icmp  remote_ip=1.1.1.1
   @{icmp1_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=icmp  port=0  remote_ip=1.1.1.1
   @{icmp1port_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=tcp  port=1  remote_ip=1.1.1.1
   @{tcp1_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=udp  port=65535  remote_ip=1.1.1.1
   @{udp1_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_ip=1.1.1.1
   &{rule2}=  Create Dictionary  protocol=tcp  port=11  remote_ip=2.1.1.1
   &{rule3}=  Create Dictionary  protocol=udp  port=6535  remote_ip=3.1.1.1
   @{udptcpicmp_rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Set Suite Variable  ${icmp1_rulelist}
   Set Suite Variable  ${icmp1port_rulelist}
   Set Suite Variable  ${tcp1_rulelist}
   Set Suite Variable  ${udp1_rulelist}
   Set Suite Variable  ${udptcpicmp_rulelist}

Create Trusted Autocluster AppInst
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}-${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${True}

   ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${appname}  ${app_counter}

   ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${cluster_name}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}
   Should Be Equal  ${app['data']['trusted']}     ${True}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${appname}-${app_counter}

Create Trusted AppInst
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}-${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${True}

   ${clusterinst}=  Run Keyword If  '${parms['deployment']}' != 'vm'  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_name=${cluster_name}${app_counter}  deployment=${parms['deployment']}

   ${appinst}=  Run Keyword If  '${parms['deployment']}' == 'vm'  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}
   ...  ELSE  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${clusterinst['data']['key']['cluster_key']['name']}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}
   Should Be Equal  ${app['data']['trusted']}     ${True}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${appname}-${app_counter}

Create Trusted AppInst with RequiredOutboundConnections
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}-${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${True}  required_outbound_connections_list=${parms['required_outbound_connections_list']}

   ${clusterinst}=  Run Keyword If  '${parms['deployment']}' != 'vm'  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_name=${cluster_name}${app_counter}  deployment=${parms['deployment']}

   ${appinst}=  Run Keyword If  '${parms['deployment']}' == 'vm'  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}
   ...  ELSE  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${clusterinst['data']['key']['cluster_key']['name']}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}
   Should Be Equal  ${app['data']['trusted']}     ${True}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${appname}-${app_counter}

Fail Create Untrusted AppInst
   [Arguments]  ${error_msg}  &{parms}  

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}-${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016

   ${clusterinst}=  Run Keyword If  '${parms['deployment']}' != 'vm'  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_name=${cluster_name}${app_counter}  deployment=${parms['deployment']}

   ${std_create}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}
   Should Contain Any  ${std_create}  ${error_msg}  #${error_msg2}

Fail Create Untrusted AutoCluster AppInst
   [Arguments]  ${error_msg}  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}-${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016

   ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${appname}  ${app_counter}

   ${std_create}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}   cluster_instance_name=${cluster_name}
   Should Contain Any  ${std_create}  ${error_msg}  #${error_msg2}

