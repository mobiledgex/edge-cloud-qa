*** Settings ***
Documentation   Create App with Trusted Parm 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime
Library  String

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded_dummy:1.0

${app_counter}=  ${0}
${operator}=  dmuus
${region}=  US

*** Test Cases ***
# ECQ-3083
CreateApp - User shall be able to create a k8s/docker/helm/vm loadbalancer/direct app with trusted parm
   [Documentation]
   ...  - create k8s/docker/helm.vm lb/direct app with trusted=True/False
   ...  - verify app is created

   [Tags]  TrustPolicy

   [Template]  Create Trusted App

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}

# ECQ-4109
CreateApp - Error shall be received for invalid requiredoutboundconnections parms
   [Documentation]
   ...  - create app with invalid connections parms
   ...  - verify error is created

   [Tags]  TrustPolicy

   [Template]  Fail Create Outbound App

   ('code\=400', 'error\={"message":"Invalid CIDR address: 1.1.1/24"}')   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,1001,20013,1.1.1/24
   ('code\=400', 'error\={"message":"Invalid CIDR address: 1.1.1.24"}')   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,1001,20013,1.1.1.24
   ('code\=400', 'error\={"message":"Invalid CIDR address: x"}')   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,1001,20013,x
   ('code\=400', 'error\={"message":"Min port range: 1001 cannot be higher than max: 1000"}')   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,1001,1000,1.1.1.1/24
   ('code\=400', 'error\={"message":"Invalid min port: 0"}')   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,0,1000,1.1.1.1/24
   Unmarshal error: expected uint32, but got string for field \\\\"App.required_outbound_connections.port_range_min\\\\"   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,x,1000,1.1.1.1/24
   Unmarshal error: expected uint32, but got string for field \\\\"App.required_outbound_connections.port_range_max\\\\"   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,1,x1000,1.1.1.1/24
   ('code\=400', 'error\={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=dp,1001,20013,1.1.1.1/24

   Unmarshal error: expected uint32, but got string for field \\\\"App.required_outbound_connections.port_range_min\\\\"   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,,20013,1.1.1.1/24
   Unmarshal error: expected uint32, but got string for field \\\\"App.required_outbound_connections.port_range_max\\\\"   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,1,,1.1.1.1/24
   ('code\=400', 'error\={"message":"Invalid CIDR address: "}')   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=udp,1001,20013,
   ('code\=400', 'error\={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}   required_outbound_connections=,1001,20013,1.1.1.1/24

# ECQ-3084
CreateApp - Error shall be received for invalid trusted parm
   [Documentation]
   ...  - create k8s/docker/helm.vm lb/direct app with invalid trusted parm
   ...  - verify error is created

   [Tags]  TrustPolicy

   [Template]  Fail Create Trusted App

   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\" at offset   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  trusted=x
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\" at offset   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=x
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\" at offset   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=xTrue}
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\" at offset   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=a
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\" at offset   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=r
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\" at offset   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=cccccc
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\" at offset   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=111
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\" at offset   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=-1
   #('code\=400', 'error\={"message":"Invalid POST data, code\=400, message\=Unmarshal type error: expected\=bool, got\=string, field\=App.trusted, offset\=  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=no
   #('code\=400', 'error\={"message":"Invalid POST data, code\=400, message\=Unmarshal type error: expected\=bool, got\=string, field\=App.trusted, offset\=  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=yes

# ECQ-3101
CreateApp - shall be able to create with k8s/docker/helm/vm lb/direct app with empty RequiredOutboundConnections
   [Documentation]
   ...  - send CreateApp with empty RequiredOutboundConnections for k8s/docker/helm/vm lb/direct
   ...  - verify app is created

   [Tags]  TrustPolicy

   [Template]  Create Trusted App With Empty RequiredOutboundConnections

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=

# ECQ-3102
CreateApp - shall be able to create with k8s/docker/helm/vm lb/direct app with icmp/tcp/udp RequiredOutboundConnections
   [Documentation]
   ...  - send CreateApp with icmp/tcp/udp RequiredOutboundConnections for k8s/docker/helm/vm lb/direct
   ...  - verify app is created

   [Tags]  TrustPolicy

   [Setup]  Setup RequiredOutboundConnections

   [Template]  Create Trusted App With RequiredOutboundConnections

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${icmp1_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${icmp1_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${icmp1_rulelist}

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${tcp1_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${tcp1_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${tcp1_rulelist}

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${udp1_rulelist}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${udp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${udp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${udp1_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${udp1_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${udp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${udp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${udp1_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${udp1_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${udp1_rulelist}

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${icmp1port_rulelist}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${icmp1port_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${icmp1port_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${icmp1port_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${icmp1port_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${icmp1port_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${icmp1port_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${icmp1port_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${icmp1port_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${icmp1port_rulelist}

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${udptcpicmp_rulelist}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${udptcpicmp_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${udptcpicmp_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${udptcpicmp_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${udptcpicmp_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${udptcpicmp_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${udptcpicmp_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${udptcpicmp_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${udptcpicmp_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${udptcpicmp_rulelist}


# ECQ-3088
UpdateApp - User shall be able to update a k8s/docker/helm/vm loadbalancer/direct app with trusted parm
   [Documentation]
   ...  - update k8s/docker/helm/vm lb/direct app with trusted=True/False
   ...  - verify app is updated

   [Tags]  TrustPolicy

   [Template]  Update Trusted App
   
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}

# ECQ-3089
UpdateApp - Error shall be received for invalid trusted parm
   [Documentation]
   ...  - update k8s/docker/helm/vm lb/direct app with invalid trusted parm
   ...  - verify error is created

   [Tags]  TrustPolicy

   [Template]  Fail Update Trusted App

   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\"  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  trusted=x
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\"  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=x
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\"  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=xTrue}
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\"  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=a
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\"  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=r
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\"  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=cccccc
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\"  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=111
   ('code\=400', 'error\={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"App.trusted\\\\"  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=-1
   #('code\=400', 'error\={"message":"Invalid POST data, code\=400, message\=Unmarshal type error: expected\=bool, got\=string, field\=App.trusted, offset\=  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=no
   #('code\=400', 'error\={"message":"Invalid POST data, code\=400, message\=Unmarshal type error: expected\=bool, got\=string, field\=App.trusted, offset\=  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=yes

# ECQ-3099
UpdateApp - Error shall be received for updated to non-trusted on trusted cloudlet
   [Documentation]
   ...  - update k8s/docker/helm/vm lb/direct app to non-trusted on trusted cloudlet
   ...  - verify error is created

   [Tags]  TrustPolicy

   [Setup]  Setup Trusted Cloudlet

   [Template]  Fail Update Non-Trusted App on Trusted Cloudlet

   ('code\=400', 'error\={"message":"Cannot set app to untrusted which has an instance on a trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  
   ('code\=400', 'error\={"message":"Cannot set app to untrusted which has an instance on a trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image} 
   ('code\=400', 'error\={"message":"Cannot set app to untrusted which has an instance on a trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Cannot set app to untrusted which has an instance on a trusted cloudlet"}')  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}     
   ('code\=400', 'error\={"message":"Cannot set app to untrusted which has an instance on a trusted cloudlet"}')  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}    
   ('code\=400', 'error\={"message":"Cannot set app to untrusted which has an instance on a trusted cloudlet"}')  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}   
   ('code\=400', 'error\={"message":"Cannot set app to untrusted which has an instance on a trusted cloudlet"}')  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
   #('code\=400', 'error\={"message":"Update App not supported for deployment: vm when AppInsts exist"}')  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}
   #('code\=400', 'error\={"message":"Update App not supported for deployment: vm when AppInsts exist"}')  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}
   #('code\=400', 'error\={"message":"Update App not supported for deployment: vm when AppInsts exist"}')  image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}

# ECQ-4274
UpdateApp - Error shall be received for updated to non-trusted with trustpolicyexception
   [Documentation]
   ...  - update k8s/docker/helm/vm lb/direct app to non-trusted with a trustpolicyexception attached
   ...  - verify error is created

   [Tags]  TrustPolicy

   [Setup]  Setup Cloudletpool

   [Template]  Fail Update Non-Trusted App With TrustPolicyException

   ('code\=400', 'error\={"message":"Application in use by Trust Policy Exception  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Application in use by Trust Policy Exception  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Application in use by Trust Policy Exception  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Application in use by Trust Policy Exception  image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Application in use by Trust Policy Exception  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Application in use by Trust Policy Exception  image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   ('code\=400', 'error\={"message":"Application in use by Trust Policy Exception  image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}

# ECQ-3392
UpdateApp - shall be able to update to trusted with appinst
   [Documentation]
   ...  - create k8s/docker/helm/vm non-trusted app and appinst on non-trusted cloudlet
   ...  - update app to trusted while the appinst is still running
   ...  - verify success

   [Tags]  TrustPolicy

   #[Setup]  Setup Trusted Cloudlet

   [Template]  Update Trusted App on non-Trusted Cloudlet

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image} 
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}

# ECQ-3100
UpdateApp - shall be able to remove RequiredOutboundConnections from k8s/docker/helm/vm lb/direct app
   [Documentation]
   ...  - send CreateApp with icmp/tcp/udp RequiredOutboundConnections for k8s/docker/helm/vm lb/direct
   ...  - send UpdateApp with empty RequiredOutboundConnections to remove them
   ...  - verify RequiredOutboundConnections is removed

   [Tags]  TrustPolicy

   [Setup]  Setup RequiredOutboundConnections

   [Template]  Remove RequiredOutboundConnections from Trusted App

   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${icmp1port_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeDocker  deployment=docker      access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${udp1_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${True}   required_outbound_connections=${udptcpicmp_rulelist}
   image_type=ImageTypeHelm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}       trusted=${False}  required_outbound_connections=${icmp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${tcp1_rulelist}
   image_type=ImageTypeQcow    deployment=vm          access_type=loadbalancer  image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${udp1_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${True}   required_outbound_connections=${udptcpicmp_rulelist}
   #image_type=ImageTypeQcow    deployment=vm          access_type=direct        image_path=${qcow_centos_image}  trusted=${False}  required_outbound_connections=${udptcpicmp_rulelist}

# ECQ-3125
UpdateApp - shall not be able to update app with mismatched appinst rules
   [Documentation]
   ...  - create a trust policy
   ...  - send CreateCloudlet with policy
   ...  - create app/appinst with required_outbound_connections
   ...  - send UpdateApp with mismatched policy rules
   ...  - verify error is received

   [Tags]  TrustPolicy

#   Create Flavor  region=${region}

   ${policy_name}=  Get Default Trust Policy Name
   ${token}=  Get Super Token

   # create a trust policy
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/24
   @{rulelist1}=  Create List  ${rule1}

   &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=2001  port_range_maximum=3001  remote_cidr=3.1.1.1/24
   @{rulelist11}=  Create List  ${rule11}

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.2.1.1/24
   @{rulelist2}=  Create List  ${rule2}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist1}  operator_org_name=${operator}

   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${operator}
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        UDP
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/24
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   # create cloudlet with trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudletname}  operator_org_name=${operator}  trust_policy=${policy_name}
   Should Be Equal  ${cloudlet['data']['trust_policy']}  ${policy_name}
   Should Be Equal  ${cloudlet['data']['trust_policy_state']}  Ready

   # add appinst on the cloudlet
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=1001  remote_cidr=3.1.1.1/24
   @{tcp1_rulelist}=  Create List  ${rule1}
   ${app}=  Create App  region=${region}  app_name=${appname}  app_version=1.0  developer_org_name=automation_dev_org  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2016  trusted=${True}  required_outbound_connections_list=${tcp1_rulelist}
   ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudletname}  operator_org_name=${operator}  cluster_instance_name=autocluster${appname}

   # update cloudlet with new trust policy with mismatch port list
   &{rule4}=  Create Dictionary  protocol=udp  port_range_minimum=1000  port_range_maximum=1000  remote_cidr=3.1.1.1/24
   @{tcp1_rulelist2}=  Create List  ${rule4}
   ${error}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}  app_version=1.0  developer_org_name=automation_dev_org  required_outbound_connections_list=${tcp1_rulelist2}  use_defaults=${False}  token=${token}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"No outbound rule in policy or exception to match required connection udp:3.1.1.1/24:1000-1000 for App {\\\\"organization\\\\":\\\\"automation_dev_org\\\\",\\\\"name\\\\":\\\\"${appname}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"}"}')

   # update cloudlet with new trust policy with mismatch port list
   &{rule4}=  Create Dictionary  protocol=udp  port_range_minimum=1003  port_range_maximum=1005  remote_cidr=4.1.1.1/1
   @{tcp1_rulelist2}=  Create List  ${rule4}
   ${error}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}  app_version=1.0  developer_org_name=automation_dev_org  required_outbound_connections_list=${tcp1_rulelist2}  use_defaults=${False}  token=${token}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"No outbound rule in policy or exception to match required connection udp:4.1.1.1/1:1003-1005 for App {\\\\"organization\\\\":\\\\"automation_dev_org\\\\",\\\\"name\\\\":\\\\"${appname}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"}"}')

   # update cloudlet with new trust policy with mismatch port list
   &{rule5}=  Create Dictionary  protocol=tcp  port_range_minimum=1001  port_range_maximum=1001  remote_cidr=3.1.1.1/1
   @{tcp1_rulelist3}=  Create List  ${rule5}
   ${error}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}  app_version=1.0  developer_org_name=automation_dev_org  required_outbound_connections_list=${tcp1_rulelist3}  use_defaults=${False}  token=${token}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"No outbound rule in policy or exception to match required connection tcp:3.1.1.1/1:1001-1001 for App {\\\\"organization\\\\":\\\\"automation_dev_org\\\\",\\\\"name\\\\":\\\\"${appname}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"}"}')
 
*** Keywords ***
Setup
   ${time}=  Get Current Date  result_format=epoch

   Create Flavor  region=${region}
   ${appname}=  Set Variable  app${time}
   ${cloudletname}=  Set Variable  cloudlet${time}

   Set Suite Variable  ${appname}  
   Set Suite variable  ${cloudletname}

Setup Trusted Cloudlet
   Setup
   #Create Flavor  region=${region}

   ${policy_name}=  Get Default Trust Policy Name
   #${app_name}=  Get Default App Name
   #${cloudlet_name}=  Get Default Cloudlet Name

   # create a trust policy
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}
   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator}
   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${operator}
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        UDP
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   # create cloudlet with trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudletname}  operator_org_name=${operator}  trust_policy=${policy_name}  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

   Set Suite Variable  ${app_name}

Setup Cloudletpool
   Setup

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}
   Set Suite Variable  ${pool}

Setup RequiredOutboundConnections
   Setup

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{icmp1_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=icmp  port_range_mininum=0  remote_cidr=1.1.1.1/1
   @{icmp1port_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{tcp1_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=65535  port_range_maximum=65535  remote_cidr=1.1.1.1/1
   @{udp1_rulelist}=  Create List  ${rule1}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=11  port_range_maximum=12  remote_cidr=2.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=6535  port_range_maximum=6536  remote_cidr=3.1.1.1/1
   @{udptcpicmp_rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Set Suite Variable  ${icmp1_rulelist}
   Set Suite Variable  ${icmp1port_rulelist}
   Set Suite Variable  ${tcp1_rulelist}
   Set Suite Variable  ${udp1_rulelist}
   Set Suite Variable  ${udptcpicmp_rulelist}

Fail Create Outbound App
   [Arguments]  ${error_msg}  &{parms}

   ${c}=  Split String  ${parms['required_outbound_connections']}  ,
   &{rule1}=  Create Dictionary  protocol=${c[0]}  port_range_minimum=${c[1]}   port_range_maximum=${c[2]}  remote_cidr=${c[3]}
   ${clist}=  Create List  ${rule1}

   ${std_create}=  Run Keyword and Expect Error  *  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  access_type=${parms['access_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${True}  required_outbound_connections_list=${clist}
   Should Contain Any  ${std_create}  ${error_msg}  #${error_msg2}

Update Trusted App
   [Arguments]  &{parms}

   Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=${parms['access_type']}  image_path=${parms['image_path']}  access_ports=tcp:2016 

   ${app}=  Update App  region=${region}  app_name=${appname}_${app_counter}  trusted=${parms['trusted']}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}

   Run Keyword If  ${parms['trusted']} == ${True}  Should Be Equal  ${app['data']['trusted']}     ${parms['trusted']}
   ...  ELSE  Should Not Contain  ${app['data']}  trusted

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

Update Trusted App on non-Trusted Cloudlet
   [Arguments]  &{parms}

   Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=${parms['access_type']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${False}

   ${appinst}=  Run Keyword If  '${parms['deployment']}' != 'vm'  Create App Instance  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=${operator}  cluster_instance_name=autocluster${app_counter}
   ...  ELSE  Create App Instance  region=${region}  operator_org_name=${operator}

   ${app}=  Update App  region=${region}  app_name=${appname}_${app_counter}  trusted=${True}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}

   Should Be Equal  ${app['data']['trusted']}  ${True} 

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

Create Trusted App
   [Arguments]  &{parms}

   ${app}=  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=${parms['access_type']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${parms['trusted']}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}

   Run Keyword If  ${parms['trusted']} == ${True}  Should Be Equal  ${app['data']['trusted']}     ${parms['trusted']}
   ...  ELSE  Should Not Contain  ${app['data']}  trusted

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

Create Trusted App With RequiredOutboundConnections
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=${parms['access_type']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${parms['trusted']}  required_outbound_connections_list=${parms['required_outbound_connections']}

   ${num_connections_req}=  Get Length  ${parms['required_outbound_connections']}
   
   Length Should Be  ${app['data']['required_outbound_connections']}  ${num_connections_req}

   Run Keyword If  ${parms['trusted']} == ${True}  Should Be Equal  ${app['data']['trusted']}     ${parms['trusted']}
   ...  ELSE  Should Not Contain  ${app['data']}  trusted

   ${conn_counter}=  Set Variable  0
   FOR  ${i}  IN  @{parms['required_outbound_connections']}
      Should Be Equal  ${i['protocol']}  ${app['data']['required_outbound_connections'][${conn_counter}]['protocol']}
      Should Be Equal  ${i['remote_cidr']}  ${app['data']['required_outbound_connections'][${conn_counter}]['remote_cidr']}
      Run Keyword If  'port' in ${i}  Run Keyword If  ${i['port']} != 0  Should Be Equal as Numbers  ${i['port']}  ${app['data']['required_outbound_connections'][${conn_counter}]['port']}
      ${conn_counter}=  Evaluate  ${conn_counter}+1
   END

Create Trusted App With Empty RequiredOutboundConnections
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=${parms['access_type']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${parms['trusted']}  required_outbound_connections_list=${parms['required_outbound_connections']}

   Should Be Equal  ${app['data']['required_outbound_connections']}  ${None}

   Run Keyword If  ${parms['trusted']} == ${True}  Should Be Equal  ${app['data']['trusted']}     ${parms['trusted']}
   ...  ELSE  Should Not Contain  ${app['data']}  trusted

Remove RequiredOutboundConnections from Trusted App
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app1}=  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=${parms['access_type']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${parms['trusted']}  required_outbound_connections_list=${parms['required_outbound_connections']}
   Should Be True  len(${app1['data']['required_outbound_connections']}) > 0

   ${app2}=  Update App  region=${region}  required_outbound_connections_list=empty

   Should Be Equal  ${app2['data']['required_outbound_connections']}  ${None}

   Run Keyword If  ${parms['trusted']} == ${True}  Should Be Equal  ${app2['data']['trusted']}     ${parms['trusted']}
   ...  ELSE  Should Not Contain  ${app2['data']}  trusted

Fail Create Trusted App
   [Arguments]  ${error_msg}  &{parms}  

   ${std_create}=  Run Keyword and Expect Error  *  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  access_type=${parms['access_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${parms['trusted']}
   Should Contain Any  ${std_create}  ${error_msg}  #${error_msg2}

Fail Update Trusted App
   [Arguments]  ${error_msg}  &{parms}

   ${std_create}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${parms['trusted']}
   Should Contain Any  ${std_create}  ${error_msg}  #${error_msg2}

Fail Update Non-Trusted App on Trusted Cloudlet
   [Arguments]  ${error_msg}  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=${parms['access_type']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${True}
   ${appinst}=  Run Keyword If  '${parms['deployment']}' != 'vm'  Create App Instance  region=${region}  cloudlet_name=${cloudletname}  operator_org_name=${operator}  cluster_instance_name=autocluster${app_counter}
   ...  ELSE  Create App Instance  region=${region}  operator_org_name=${operator}

   ${std_create}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}_${app_counter}  trusted=${False}
   Should Contain Any  ${std_create}  ${error_msg}  #${error_msg2}

Fail Update Non-Trusted App With TrustPolicyException
   [Arguments]  ${error_msg}  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=${parms['access_type']}  image_path=${parms['image_path']}  access_ports=tcp:2016  trusted=${True}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   @{rulelist}=  Create List  ${rule1}
   Create Trust Policy Exception  region=${region}  app_name=${appname}_${app_counter}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   #${appinst}=  Run Keyword If  '${parms['deployment']}' != 'vm'  Create App Instance  region=${region}  cloudlet_name=${cloudletname}  operator_org_name=${operator}  cluster_instance_name=autocluster${app_counter}
   #...  ELSE  Create App Instance  region=${region}  operator_org_name=${operator}

   ${std_create}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}_${app_counter}  trusted=${False}
   Should Contain Any  ${std_create}  ${error_msg}  #${error_msg2}

