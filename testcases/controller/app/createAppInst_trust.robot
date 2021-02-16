*** Settings ***
Documentation   Create AppInst with Trusted Parm 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

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

   #EDGECLOUD-4224 able to CreateAppInst on trusted cloudlet with different requiredoutboundconnections than trust policy

   [Setup]  Setup RequiredOutboundConnections

   [Template]  Create Trusted AppInst with RequiredOutboundConnections

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${tcp1_rulelist}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${udp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${icmp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${icmp1port_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${udptcpicmp_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${tcp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  required_outbound_connections_list=${udp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  required_outbound_connections_list=${icmp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  required_outbound_connections_list=${udptcpicmp_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  required_outbound_connections_list=${tcp1_rulelist}

# ECQ-3127
CreateAppInst - User shall be able to create a trusted appinst with in range RequiredOutboundConnections
   [Documentation]
   ...  - create app with RequiredOutboundConnections of the beginning/ending port and beginning/ending ip
   ...  - verify appInst is created

   [Tags]  TrustPolicy

   [Setup]  Setup In Range RequiredOutboundConnections

   [Template]  Create Trusted AppInst with In Range RequiredOutboundConnections

   required_outbound_connections_list=${tcpstartport_rulelist}
   required_outbound_connections_list=${tcpendport_rulelist}
   required_outbound_connections_list=${tcpstartip_rulelist}
   required_outbound_connections_list=${tcpendip_rulelist}

   required_outbound_connections_list=${udpstartport_rulelist}
   required_outbound_connections_list=${udpendport_rulelist}
   required_outbound_connections_list=${udpstartip_rulelist}
   required_outbound_connections_list=${udpendip_rulelist}

# ECQ-3128
CreateAppInst - Error shall be received for appinst with out of range RequiredOutboundConnections
   [Documentation]
   ...  - create app with RequiredOutboundConnections outside the port/ip range
   ...  - verify appInst fails with error

   [Tags]  TrustPolicy

   [Setup]  Setup Out Of Range RequiredOutboundConnections

   [Template]  Fail Create Trusted AppInst with Out Of Range RequiredOutboundConnections

   required_outbound_connections_list=${tcpbeforestartport_rulelist}
   required_outbound_connections_list=${tcpafterendport_rulelist}
   required_outbound_connections_list=${tcpbeforeip_rulelist}
   required_outbound_connections_list=${tcpafterip_rulelist}

   required_outbound_connections_list=${udpbeforestartport_rulelist}
   required_outbound_connections_list=${udpafterendport_rulelist}
   required_outbound_connections_list=${udpbeforeip_rulelist}
   required_outbound_connections_list=${udpafterip_rulelist}

# ECQ-3106
CreateAppInst - Error shall be received for create with RequiredOutboundConnections not matching the trust policy
   [Documentation]
   ...  - create k8s/docker/helm/vm lb/direct app with RequiredOutboundConnections not matching trust policy
   ...  - verify error is received

   [Tags]  TrustPolicy

   #EDGECLOUD-4224 able to CreateAppInst on trusted cloudlet with different requiredoutboundconnections than trust policy

   [Setup]  Setup RequiredOutboundConnections

   [Template]  Fail Create Trusted AppInst with RequiredOutboundConnections

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${tcp1_rulelist}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${udp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${icmp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${icmp1port_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${udptcpicmp_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}  required_outbound_connections_list=${tcp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  required_outbound_connections_list=${udp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  required_outbound_connections_list=${icmp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  required_outbound_connections_list=${udptcpicmp_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  required_outbound_connections_list=${tcp1_rulelist}

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

# ECQ-3136
CreateAppInst - autoprov appinst shall start for trusted k8s/lb/shared on trusted cloudlet
   [Documentation]
   ...  - create privacy policy with 2 trusted cloudlets
   ...  - create 2 reservable clusterInst with k8s/shared
   ...  - create trusted k8s/lb app with privacy policy
   ...  - verify appinst starts on cloudlet1

   [Tags]  TrustPolicy

   &{cloudlet1}=  Create Dictionary  name=${cloudlet_name}  organization=${operator_name_fake}
   &{cloudlet2}=  Create Dictionary  name=${cloudlet_name}2  organization=${operator_name_fake}
   @{cloudlets}=  Create List  ${cloudlet1}  ${cloudlet2}

   ${cloudlet2}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}2  operator_org_name=${operator_name_fake}  trust_policy=${policy_name}

   ${policy}=  Create Auto Provisioning Policy  region=${region}  developer_org_name=automation_dev_org  min_active_instances=1  max_instances=0  cloudlet_list=${cloudlets}

   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}  reservable=${True}   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}2  reservable=${True}   cloudlet_name=${cloudlet_name}2  operator_org_name=${operator_name_fake}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes

   @{policy_list}=  Create List  ${policy['data']['key']['name']}
   Create App  region=${region}  app_name=${appname}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer  trusted=${True}

   #AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cloudlet_name1}.${operator_name}.mobiledgex.net  cloudlet2_fqdn=${cloudlet_name2}.${operator_name}.mobiledgex.net

   App Instance Should Exist  region=${region}  app_name=${appname}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}
 
*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   Create Flavor  region=${region}
   #${appname}=  Get Default App Name
   ${appname}=  Set Variable  app${epoch}
   #${appname}  ${appname_micro}=  Split String  ${appname}  -
 
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${cluster_name}=  Get Default Cluster Name
   ${token}=  Get Super Token

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
   Set Suite Variable  ${policy_name}

   Set Suite Variable  ${token}

Setup In Range RequiredOutboundConnections
   Setup

   # startip=3.9.0.0  endip=3.9.127.255
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.9.2.3/17
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=3001  port_range_maximum=3002  remote_cidr=3.9.2.3/17
   &{rule3}=  Create Dictionary  protocol=icmp  remote_cidr=3.9.2.3/17
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}
   ${policy_return}=  Update Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_fake}

   &{rule1}=  Create Dictionary  protocol=tcp  port=3001  remote_ip=3.9.1.2
   &{rule2}=  Create Dictionary  protocol=udp  port=3001  remote_ip=3.9.1.2
   &{rule3}=  Create Dictionary  protocol=icmp  remote_ip=3.9.1.2
   @{rules}=  Create List  ${rule1}  ${rule2}  ${rule3}
   ${app}=  Create App  region=${region}  app_name=${appname}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2016  trusted=${True}  required_outbound_connections_list=${rules}

   &{rule1}=  Create Dictionary  protocol=tcp  port=3001  remote_ip=3.9.5.10
   @{tcpstartport_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=tcp  port=3002  remote_ip=3.9.5.10
   @{tcpendport_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=tcp  port=3002  remote_ip=3.9.0.0
   @{tcpstartip_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=tcp  port=3002  remote_ip=3.9.127.255
   @{tcpendip_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=udp  port=1001  remote_ip=3.9.5.10
   @{udpstartport_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=udp  port=2001  remote_ip=3.9.5.10
   @{udpendport_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=udp  port=1111  remote_ip=3.9.0.0
   @{udpstartip_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=udp  port=1999  remote_ip=3.9.127.255
   @{udpendip_rulelist}=  Create List  ${rule1}

   Set Suite Variable  ${tcpstartport_rulelist}
   Set Suite Variable  ${tcpendport_rulelist}
   Set Suite Variable  ${tcpstartip_rulelist}
   Set Suite Variable  ${tcpendip_rulelist}

   Set Suite Variable  ${udpstartport_rulelist}
   Set Suite Variable  ${udpendport_rulelist}
   Set Suite Variable  ${udpstartip_rulelist}
   Set Suite Variable  ${udpendip_rulelist}

Setup Out Of Range RequiredOutboundConnections
   Setup In Range RequiredOutboundConnections

   # startip=3.9.0.0  endip=3.9.127.255

   &{rule1}=  Create Dictionary  protocol=tcp  port=3000  remote_ip=3.9.5.10
   @{tcpbeforestartport_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=tcp  port=3003  remote_ip=3.9.5.10
   @{tcpafterendport_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=tcp  port=3002  remote_ip=3.8.255.255
   @{tcpbeforeip_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=tcp  port=3002  remote_ip=3.9.128.0
   @{tcpafterip_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=udp  port=1000  remote_ip=3.9.5.10
   @{udpbeforestartport_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=udp  port=2002  remote_ip=3.9.5.10
   @{udpafterendport_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=udp  port=1111  remote_ip=3.8.255.255
   @{udpbeforeip_rulelist}=  Create List  ${rule1}
   &{rule1}=  Create Dictionary  protocol=udp  port=1999  remote_ip=3.9.128.0
   @{udpafterip_rulelist}=  Create List  ${rule1}

   Set Suite Variable  ${tcpbeforestartport_rulelist}
   Set Suite Variable  ${tcpafterendport_rulelist}
   Set Suite Variable  ${tcpbeforeip_rulelist}
   Set Suite Variable  ${tcpafterip_rulelist}

   Set Suite Variable  ${udpbeforestartport_rulelist}
   Set Suite Variable  ${udpafterendport_rulelist}
   Set Suite Variable  ${udpbeforeip_rulelist}
   Set Suite Variable  ${udpafterip_rulelist}

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

   [Teardown]  Teardown RequiredOutboundConnections  app=${appname}-${app_counter}  cluster=${clustername}${app_counter}  deployment=${parms['deployment']}

   ${rule_list}=  Create List
   FOR  ${rule}  IN  @{parms['required_outbound_connections_list']}
      log to console  ${rule}
      ${port}=  Run Keyword If  '${rule['protocol']}' == 'icmp' and 'port' not in ${rule}  Set Variable  0
      ...   ELSE  Set Variable  ${rule['port']}

      &{rule1}=  Create Dictionary  protocol=${rule['protocol']}  port_range_minimum=${port}  port_range_maximum=${port}  remote_cidr=${rule['remote_ip']}/1
      Append To List  ${rule_list}  ${rule1}
   END

   ${policy_return}=  Update Trust Policy  region=${region}  policy_name=${policy_name}  rule_list=${rulelist}  operator_org_name=${operator_name_fake}

   ${app}=  Create App  region=${region}  app_name=${appname}-${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${True}  required_outbound_connections_list=${parms['required_outbound_connections_list']}  auto_delete=${False}

   ${clusterinst}=  Run Keyword If  '${parms['deployment']}' != 'vm'  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_name=${cluster_name}${app_counter}  deployment=${parms['deployment']}  auto_delete=${False}

   ${appinst}=  Run Keyword If  '${parms['deployment']}' == 'vm'  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  auto_delete=${False}
   ...  ELSE  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${clusterinst['data']['key']['cluster_key']['name']}  auto_delete=${False}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}
   Should Be Equal  ${app['data']['trusted']}     ${True}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${appname}-${app_counter}

Create Trusted AppInst with In Range RequiredOutboundConnections
   [Arguments]  &{parms}

   [Teardown]  Teardown In Range RequiredOutboundConnections

   #${app_counter}=  Evaluate  ${app_counter} + 1
   #Set Suite Variable  ${app_counter}

   ${rule_list}=  Create List
   FOR  ${rule}  IN  @{parms['required_outbound_connections_list']}
      log to console  ${rule}
      ${port}=  Run Keyword If  '${rule['protocol']}' == 'icmp' and 'port' not in ${rule}  Set Variable  0
      ...   ELSE  Set Variable  ${rule['port']}

      &{rule1}=  Create Dictionary  protocol=${rule['protocol']}  port_range_minimum=${port}  port_range_maximum=${port}  remote_cidr=${rule['remote_ip']}/1
      Append To List  ${rule_list}  ${rule1}
   END

   ${app}=  Update App  region=${region}  app_name=${appname}  required_outbound_connections_list=${parms['required_outbound_connections_list']}

   ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${appname}  auto_delete=${False}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${appname}

Fail Create Trusted AppInst with Out Of Range RequiredOutboundConnections
   [Arguments]  &{parms}

   ${rule_list}=  Create List
   FOR  ${rule}  IN  @{parms['required_outbound_connections_list']}
      log to console  ${rule}
      ${port}=  Run Keyword If  '${rule['protocol']}' == 'icmp' and 'port' not in ${rule}  Set Variable  0
      ...   ELSE  Set Variable  ${rule['port']}

      &{rule1}=  Create Dictionary  protocol=${rule['protocol']}  port_range_minimum=${port}  port_range_maximum=${port}  remote_cidr=${rule['remote_ip']}/1
      Append To List  ${rule_list}  ${rule1}
   END

   ${app}=  Update App  region=${region}  app_name=${appname}  required_outbound_connections_list=${parms['required_outbound_connections_list']}

   ${appinst}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${appname}  auto_delete=${False}

   Should Be Equal  ${appinst}  ('code=400', 'error={"message":"App is not compatible with cloudlet trust policy: No outbound rule in policy to match required connection ${parms['required_outbound_connections_list'][0]['protocol']}:${parms['required_outbound_connections_list'][0]['remote_ip']}:${parms['required_outbound_connections_list'][0]['port']} for App {\\\\"organization\\\\":\\\\"automation_dev_org\\\\",\\\\"name\\\\":\\\\"${appname}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"}"}\')

Fail Create Trusted AppInst with RequiredOutboundConnections
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}-${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${True}  required_outbound_connections_list=${parms['required_outbound_connections_list']}

   ${clusterinst}=  Run Keyword If  '${parms['deployment']}' != 'vm'  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_name=${cluster_name}${app_counter}  deployment=${parms['deployment']}

   ${appinst}=  Run Keyword If  '${parms['deployment']}' == 'vm'  Run Keyword and Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}
   ...  ELSE  Run Keyword and Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${clusterinst['data']['key']['cluster_key']['name']}

   ${port}=  Run Keyword If  '${parms['required_outbound_connections_list'][0]['protocol']}' == 'icmp' and 'port' not in ${parms['required_outbound_connections_list'][0]}  Set Variable  0
   ...   ELSE  Set Variable  ${parms['required_outbound_connections_list'][0]['port']}
   Should Be Equal  ${appinst}  ('code=400', 'error={"message":"App is not compatible with cloudlet trust policy: No outbound rule in policy to match required connection ${parms['required_outbound_connections_list'][0]['protocol']}:${parms['required_outbound_connections_list'][0]['remote_ip']}:${port} for App {\\\\"organization\\\\":\\\\"automation_dev_org\\\\",\\\\"name\\\\":\\\\"${appname}-${app_counter}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"}"}\')

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

Teardown RequiredOutboundConnections
   [Arguments]  ${app}  ${cluster}  ${deployment}

    Run Keyword If  '${deployment}' == 'vm'  Delete App Instance  region=${region}  app_name=${app}  app_version=1.0  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}
    ...  ELSE  Delete App Instance  region=${region}  app_name=${app}  app_version=1.0  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${cluster}  cluster_instance_developer_org_name=MobiledgeX  token=${token}  use_defaults=${False}
   Delete App  region=${region}  app_name=${app}  app_version=1.0  developer_org_name=MobiledgeX  token=${token}  use_defaults=${False}

   Run Keyword If  '${deployment}' != 'vm'  Delete Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_name=${cluster}

Teardown In Range RequiredOutboundConnections
   Delete App Instance  region=${region}  app_name=${appname}  app_version=1.0  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${appname}  cluster_instance_developer_org_name=MobiledgeX  token=${token}  use_defaults=${False}
