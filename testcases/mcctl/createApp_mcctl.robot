*** Settings ***
Documentation  CreateApp mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  25m

*** Variables ***
${region}=  US
${developer}=  ${developer_org_name_automation}
${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml
${server_ping_threaded_cloudconfig}  http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml
${manifest_string}=  apiVersion: v1\nkind: Service\nmetadata:\n  name: server-ping-threaded-udptcphttp-tcpservice\n  labels:\n    run: server-ping-threaded-udptcphttpapp\nspec:\n  type: LoadBalancer\n  ports:\n  - port: 2016\n    targetPort: 2016\n    protocol: TCP\n    name: tcp2016\n  selector:\n    run: server-ping-threaded-udptcphttpapp
${cloudconfig_string}=  \#cloud-config\n users:\n - name: demo\n groups: sudo\n shell: /bin/bash\n sudo: ['ALL=(ALL) NOPASSWD:ALL']\n runcmd:\n - /opt/rh/rh-python36/root/usr/bin/python3 /home/centos/server_ping_threaded.py
${envvars_config}=  - name: CrmValue\n${SPACE*2}value: [[ .Deployment.ClusterIp ]]\n- name: CrmValue2\n${SPACE*2}value: [[ .Deployment.ClusterIp ]]
${envvars_url}=  http://35.199.188.102/apps/server_ping_threaded_config.yml

${version}=  latest

*** Test Cases ***
# ECQ-2889
CreateApp - mcctl shall be able to create/show/delete app 
   [Documentation]
   ...  - send CreateApp/ShowApp/DeleteApp via mcctl with various parms
   ...  - verify app is created/shown/deleted

   [Template]  Success Create/Show/Delete App Via mcctl
      # no protocol 
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow  imagepath=${qcow_centos_image}  defaultflavor=${flavor_name_automation}

      # officialfqdn and androidpackagename
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  officialfqdn=automation.com  defaultflavor=${flavor_name_automation}  
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}   officialfqdn=automation.com  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}   officialfqdn=automation.com  defaultflavor=${flavor_name_automation} 
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}   officialfqdn=automation.com  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  androidpackagename=automation.android.com  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}     androidpackagename=automation.android.com  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}     androidpackagename=automation.android.com  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}     androidpackagename=automation.android.com  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  officialfqdn=automation.com  androidpackagename=automation.android.com  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}   officialfqdn=automation.com  androidpackagename=automation.android.com  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}   officialfqdn=automation.com  androidpackagename=automation.android.com   defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}   officialfqdn=automation.com  androidpackagename=automation.android.com  defaultflavor=${flavor_name_automation}

      # authpublickey
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  authpublickey="${vm_public_key}"  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  authpublickey="${vm_public_key}"   defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}    authpublickey="${vm_public_key}"  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}    authpublickey="${vm_public_key}"  defaultflavor=${flavor_name_automation}

      # manifest
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  deploymentmanifest="${manifest_string}"  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  deploymentmanifest="${manifest_string}"  defaultflavor=${flavor_name_automation}
      #appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  deploymentmanifest="${manifest_string}"  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  deploymentmanifest="${cloudconfig_string}"  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  deploymentmanifest=${server_ping_threaded_cloudconfig}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  deploymentmanifest=${manifest_url}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  deploymentmanifest=${manifest_url}  defaultflavor=${flavor_name_automation}
      #appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  deploymentmanifest=${manifest_url}  defaultflavor=${flavor_name_automation}

      # scalewithcluster
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=${True}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=${False}  defaultflavor=${flavor_name_automation}

      # configs
      # EDGECLOUD-3163 Support envVarsYaml config for CreateApp on docker
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config="${envvars_config}"  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml  configs:0.config="${envvars_config}"  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config=${envvars_url}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml  configs:0.config=${envvars_url}  defaultflavor=${flavor_name_automation}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config="${envvars_config}"  configs:1.kind=envVarsYaml  configs:1.config="${envvars_config}"  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config=${envvars_url}  configs:1.kind=envVarsYaml  configs:1.config=${envvars_url}  defaultflavor=${flavor_name_automation}

      # autoprovpolicies
      #appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          imagepath=${qcow_centos_image}  defaultflavor=${flavor_name_automation}  autoprovpolicies=${autoprov_name}1  vm not supported
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      imagepath=${docker_image}       defaultflavor=${flavor_name_automation}  autoprovpolicies=${autoprov_name}1 
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       defaultflavor=${flavor_name_automation}  autoprovpolicies=${autoprov_name}1
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        imagepath=${docker_image}       defaultflavor=${flavor_name_automation}  autoprovpolicies=${autoprov_name}1
      #appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          imagepath=${qcow_centos_image}  defaultflavor=${flavor_name_automation}  autoprovpolicies=${autoprov_name}1 autoprovpolicies=${autoprov_name}2  vm not supported
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      imagepath=${docker_image}       defaultflavor=${flavor_name_automation}  autoprovpolicies=${autoprov_name}1 autoprovpolicies=${autoprov_name}2
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       defaultflavor=${flavor_name_automation}  autoprovpolicies=${autoprov_name}1 autoprovpolicies=${autoprov_name}2
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        imagepath=${docker_image}       defaultflavor=${flavor_name_automation}  autoprovpolicies=${autoprov_name}1 autoprovpolicies=${autoprov_name}2

      # trusted
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${False}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${False}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${False}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeLoadBalancer  imagepath=${qcow_centos_image}  trusted=${True}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeLoadBalancer  imagepath=${qcow_centos_image}  trusted=${False}  defaultflavor=${flavor_name_automation}
      #appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=${True}  direct no longer supported
      #appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=${False}  direct no longer supported

      # requiredoutboundconnections
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.portrangemin=0  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${False}  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:0.portrangemin=2  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=udp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:0.portrangemin=2  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:0.portrangemin=2  requiredoutboundconnections:1.protocol=udp  requiredoutboundconnections:1.remotecidr=1.1.1.1/1  requiredoutboundconnections:1.portrangemin=2  defaultflavor=${flavor_name_automation}
      #appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:0.portrangemin=2  requiredoutboundconnections:1.protocol=icmp  requiredoutboundconnections:1.remotecidr=1.1.1.1/1  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:0.portrangemin=2  requiredoutboundconnections:1.protocol=tcp  requiredoutboundconnections:1.remotecidr=1.1.1.1/1  requiredoutboundconnections:1.portrangemin=2  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:0.portrangemin=2  requiredoutboundconnections:0.portrangemax=6  requiredoutboundconnections:1.protocol=tcp  requiredoutboundconnections:1.remotecidr=1.1.1.1/1  requiredoutboundconnections:1.portrangemin=20  requiredoutboundconnections:1.portrangemax=60  defaultflavor=${flavor_name_automation}

      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=kubernetes        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=TCP  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:0.portrangemin=2  requiredoutboundconnections:0.portrangemax=6  requiredoutboundconnections:1.protocol=UDP  requiredoutboundconnections:1.remotecidr=1.1.1.1/1  requiredoutboundconnections:1.portrangemin=20  requiredoutboundconnections:1.portrangemax=60  requiredoutboundconnections:2.protocol=ICMP  requiredoutboundconnections:2.remotecidr=1.1.1.1/1  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=docker        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tCP  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:0.portrangemin=2  requiredoutboundconnections:0.portrangemax=6  requiredoutboundconnections:1.protocol=UdP  requiredoutboundconnections:1.remotecidr=1.1.1.1/1  requiredoutboundconnections:1.portrangemin=20  requiredoutboundconnections:1.portrangemax=60  requiredoutboundconnections:2.protocol=ICMp  requiredoutboundconnections:2.remotecidr=1.1.1.1/1  defaultflavor=${flavor_name_automation}


      # serverless
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  allowserverless=${False}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  allowserverless=${True}  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  allowserverless=${True}  serverlessconfig.vcpus=1  serverlessconfig.ram=2  serverlessconfig.minreplicas=3  defaultflavor=${flavor_name_automation}

      # accessports
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:2015:tls,tcp:2016,udp:2016:nginx,udp:2015:maxpktsize=1800  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      imagepath=${docker_image}       accessports=tcp:2015:tls,tcp:2016,udp:2016:nginx,udp:2015:maxpktsize=1800  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        imagepath=${docker_image}       accessports=tcp:2015:tls,tcp:2016,udp:2016:nginx,udp:2015:maxpktsize=1800  defaultflavor=${flavor_name_automation}
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          imagepath=${qcow_centos_image}  accessports=tcp:2015:tls,tcp:2016,udp:2016:nginx,udp:2015:maxpktsize=1800  defaultflavor=${flavor_name_automation}

      # qos session 
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=0
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=1
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=2
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=3
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=4
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=NoPriority
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=LowLatency
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=ThroughputDownS
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=ThroughputDownM
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=ThroughputDownL
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionduration=1s
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=NoPriority  qossessionduration=1m1s
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=LowLatency  qossessionduration=1h1m1s
      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=ThroughputDownS  qossessionduration=1ms

# ECQ-2890
CreateApp - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateApp via mcctl with various error cases
   ...  - verify proper error is received

   # EDGECLOUD-4577 CreateApp should disallow deploymentmanifest for helm - closed/fixed
   # EDGECLOUD-4576 CreateApp should valide the deploymentmanifest for docker

   [Template]  Fail Create App Via mcctl
      # missing values
      Error: Bad Request (400), Unknown image type IMAGE_TYPE_UNKNOWN  appname=${app_name}  apporg=${developer}  appvers=1.0  defaultflavor=${flavor_name_automation}

      # autoprovpolicies
      Error: Bad Request (400), Policy key {"organization":"${developer}","name":"x"} not found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow  imagepath=${qcow_centos_image}  autoprovpolicies=x  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Policy key {"organization":"${developer}","name":"x"} not found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  autoprovpolicies=x  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Policy key {"organization":"${developer}","name":"x"} not found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker   deployment=docker  imagepath=${docker_image}  autoprovpolicies=x  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Policy key {"organization":"${developer}","name":"x"} not found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  autoprovpolicies=x  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Policy key {"organization":"${developer}"} not found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow  imagepath=${qcow_centos_image}  autoprovpolicies=  defaultflavor=${flavor_name_automation}

      # authpublickey
      Error: Bad Request (400), Failed to parse public key: ssh: no key found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow  imagepath=${qcow_centos_image}  authpublickey=x
      Error: Bad Request (400), Failed to parse public key: ssh: no key found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  authpublickey=x
      Error: Bad Request (400), Failed to parse public key: ssh: no key found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker   deployment=docker  imagepath=${docker_image}  authpublickey=x
      Error: Bad Request (400), Failed to parse public key: ssh: no key found  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  authpublickey=x

      # deployment manifest
      # EDGECLOUD-4002  CreateApp should validate for proper helm chart and docker compose when using deploymentmanifest
      Error: Bad Request (400), Invalid deployment manifest, only cloud-init script support, must start with \'#cloud-config\'  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  deploymentmanifest=${manifest_url}  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Invalid deployment manifest, only cloud-init script support, must start with \'#cloud-config\'  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  deploymentmanifest=x  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Invalid deployment manifest, parse kubernetes deployment yaml failed  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker   deployment=kubernetes  imagepath=${docker_image}  deploymentmanifest=x  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Invalid deployment manifest, parse kubernetes deployment yaml failed  appname=${app_name}1  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker   deployment=docker  imagepath=${docker_image}  deploymentmanifest=x  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Manifest is not used for Helm deployments. Use config files for customizations  appname=${app_name}2  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm   deployment=helm  imagepath=${docker_image}  deploymentmanifest=x

      # scalewithcluster
      Error: Bad Request (400), App scaling is only supported for Kubernetes deployments  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=${True}
      Error: Bad Request (400), App scaling is only supported for Kubernetes deployments  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=${True}
      Error: Bad Request (400), App scaling is only supported for Kubernetes deployments  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  scalewithcluster=${True}
      Error: parsing arg "scalewithcluster\=x" failed: unable to parse "x" as bool: invalid syntax, valid values are true, false   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  scalewithcluster=x
      Error: parsing arg "scalewithcluster\=x" failed: unable to parse "x" as bool: invalid syntax, valid values are true, false   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=x
      Error: parsing arg "scalewithcluster\=x" failed: unable to parse "x" as bool: invalid syntax, valid values are true, false   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=x
      Error: parsing arg "scalewithcluster\=x" failed: unable to parse "x" as bool: invalid syntax, valid values are true, false   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=x


      # androidpackagename and officialfqdn - no errors

      #configs
      # fixed EDGECLOUD-3993 CreateApp with configs.kind only should give an error
      # fixed EDGECLOUD-3232 CreateApp with deployment=vm and configs=envVarsYaml should give error
      # EDGECLOUD-3163 Support envVarsYaml config for CreateApp on docker
      # fixed EDGECLOUD-3238 no error given with CreateAppInst with bad configs envVarsYaml value
      # fixed EDGECLOUD-4216 CreateApp with invalid helmCustomizationYaml config should give an error
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  configs:0.kind=nvVarsYam
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=nvVarsYam
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=nvVarsYam
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=nvVarsYam
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}3  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  configs:0.kind=nvVarsYaml
     Error: Bad Request (400), Cannot unmarshal env vars: x - yaml: unmarshal errors:\\n  line 1: cannot unmarshal !!str `x` into []v1.EnvVar  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config=x  defaultflavor=${flavor_name_automation}
      #Error: Bad Request (400), Cannot unmarshal env vars: x - yaml: unmarshal errors:\\n  line 1: cannot unmarshal !!str `x` into []v1.EnvVar  appname=${app_name}4  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config=x
      #Error: Bad Request (400), Cannot unmarshal env vars: x - yaml: unmarshal errors:\\n  line 1: cannot unmarshal !!str `x` into []v1.EnvVar  appname=${app_name}6  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml  configs:0.config=x  we dont support helm config verifcation since it is freeform
      Error: Bad Request (400), Invalid Config Kind(envVarsYaml) for deployment type(vm)  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml
      Error: Bad Request (400), Invalid Config Kind(helmCustomizationYaml) for deployment type(vm)  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml
      Error: Bad Request (400), Invalid Config Kind(helmCustomizationYaml) for deployment type(kubernetes)  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml
      Error: Bad Request (400), Invalid Config Kind(helmCustomizationYaml) for deployment type(docker)  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml
      Error: Bad Request (400), Invalid Config Kind(envVarsYaml) for deployment type(helm)  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config="${envvars_config}"

      # trusted
      Error: parsing arg "trusted\=x" failed: unable to parse "x" as bool: invalid syntax, valid values are true, false       appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  trusted=x
      Error: parsing arg "trusted\=x" failed: unable to parse "x" as bool: invalid syntax, valid values are true, false       appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=x
      Error: parsing arg "trusted\=xTrue}" failed: unable to parse "xTrue}" as bool: invalid syntax, valid values are true, false  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=xTrue}
      Error: parsing arg "trusted\=a" failed: unable to parse "a" as bool: invalid syntax, valid values are true, false       appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=a
      Error: parsing arg "trusted\=r" failed: unable to parse "r" as bool: invalid syntax, valid values are true, false       appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=r
      Error: parsing arg "trusted\=cccccc" failed: unable to parse "cccccc" as bool: invalid syntax, valid values are true, false  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=cccccc
      Error: parsing arg "trusted\=111" failed: unable to parse "111" as bool: invalid syntax, valid values are true, false     appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeLoadBalancer  imagepath=${qcow_centos_image}  trusted=111
      Error: parsing arg "trusted\=-1" failed: unable to parse "-1" as bool: invalid syntax, valid values are true, false       appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeLoadBalancer  imagepath=${qcow_centos_image}  trusted=-1
      #Unable to parse "trusted" value "no" as bool: invalid syntax, valid values are true, false      appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=no  direct not supported
      #Unable to parse "trusted" value "yes" as bool: invalid syntax, valid values are true, false     appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=yes  direct not supported

      # requiredoutboundconnections
      Bad Request (400), Port range must be empty for ICMP   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.portrangemin=1  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      Error: Bad Request (400), Invalid min port: 0   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.portrangemin=0  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      Error: Bad Request (400), Invalid min port: 0   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=udp  requiredoutboundconnections:0.portrangemin=0  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      Error: Bad Request (400), Protocol must be one of: (TCP,UDP,ICMP)  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=cmp  requiredoutboundconnections:0.portrangemin=1  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      Error: Bad Request (400), Invalid CIDR address:    appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=icmp
      Error: Bad Request (400), Invalid min port: 0    appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp 
      Error: Bad Request (400), Invalid CIDR address:    appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=udp  requiredoutboundconnections:0.portrangemin=1
      Error: Bad Request (400), Invalid min port: 0   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      Error: Bad Request (400), Protocol must be one of: (TCP,UDP,ICMP)  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=  # remove the ports
      Bad Request (400), Invalid min port: 0   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.portrangemax=1  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      Bad Request (400), Min port range: 2 cannot be higher than max: 1   appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.portrangemin=2  requiredoutboundconnections:0.portrangemax=1  requiredoutboundconnections:0.remotecidr=1.1.1.1/1

      # serverless
      #Error: Bad Request (400), Serverless config vcpus cannot be less than 0.001  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  allowserverless=${True}  defaultflavor=${flavor_name_automation}
      Error: Bad Request (400), Serverless config vcpus cannot have precision less than 0.001  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  allowserverless=${True}  serverlessconfig.vcpus=0.000001  serverlessconfig.ram=2  serverlessconfig.minreplicas=3
      Error: Bad Request (400), Serverless config cannot be specified without allow serverless true  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  allowserverless=${False}  serverlessconfig.vcpus=0.01  serverlessconfig.ram=2  serverlessconfig.minreplicas=3
      Error: Bad Request (400), Serverless config cannot be specified without allow serverless true  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  serverlessconfig.vcpus=0.01  serverlessconfig.ram=2  serverlessconfig.minreplicas=3
      Error: parsing arg "serverlessconfig.minreplicas\=x" failed: unable to parse "x" as uint: invalid syntax  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  allowserverless=${True}  allowserverless=${True}  serverlessconfig.vcpus=0.01  serverlessconfig.ram=2  serverlessconfig.minreplicas=x
      Error: parsing arg "serverlessconfig.vcpus\=x" failed: unable to parse "x" as unsigned decimal: invalid format  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  allowserverless=${True}  serverlessconfig.vcpus=x  serverlessconfig.ram=2  serverlessconfig.minreplicas=1
      Error: parsing arg "serverlessconfig.ram\=x" failed: unable to parse "x" as uint: invalid syntax  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  allowserverless=${True}  serverlessconfig.vcpus=1  serverlessconfig.ram=x  serverlessconfig.minreplicas=1
      Error: parsing arg "serverlessconfig.minreplicas\=-1" failed: unable to parse "-1" as uint: invalid syntax  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  allowserverless=${True}  serverlessconfig.vcpus=1  serverlessconfig.ram=1  serverlessconfig.minreplicas=-1
      Error: parsing arg "serverlessconfig.vcpus\=-1" failed: unable to parse "-1" as unsigned decimal: invalid format  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  allowserverless=${True}  serverlessconfig.vcpus=-1  serverlessconfig.ram=2  serverlessconfig.minreplicas=1
      Error: parsing arg "serverlessconfig.ram\=-1" failed: unable to parse "-1" as uint: invalid syntax  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  defaultflavor=${flavor_name_automation}  allowserverless=${True}  serverlessconfig.vcpus=1  serverlessconfig.ram=-1  serverlessconfig.minreplicas=1

      # qos priority session
      Error: parsing arg "qossessionprofile\=x" failed: unable to parse "x" as QosSessionProfile: invalid format, valid values are one of NoPriority, LowLatency, ThroughputDownS, ThroughputDownM, ThroughputDownL, or 0, 1, 2, 3, 4  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionprofile=x
      Error: parsing arg "qossessionduration\=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionduration=1
      Error: parsing arg "qossessionduration\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  appname=${app_name}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}       accessports=tcp:20150  defaultflavor=${flavor_name_automation}  qossessionduration=x
      
# ECQ-2891
UpdateApp - mcctl shall handle update app 
   [Documentation]
   ...  - send UpdateApp via mcctl with various args
   ...  - verify proper is updated

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success Update/Show App Via mcctl
      appname=${app_name_k8s}  apporg=${developer}  appvers=1.0  imagepath=${docker_image_cpu}
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  imagepath=${docker_image_cpu}
      appname=${app_name_helm}  apporg=${developer}  appvers=1.0  imagepath=${docker_image_cpu}
      appname=${app_name_vm}  apporg=${developer}  appvers=1.0  imagepath=${qcow_gpu_ubuntu16_image}

      appname=${app_name_k8s}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeDocker
      appname=${app_name_helm}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeHelm
      appname=${app_name_vm}  apporg=${developer}  appvers=1.0  imagetype=ImageTypeQcow

      appname=${app_name_k8s}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeLoadBalancer
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeLoadBalancer 
      #appname=${app_name_docker}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeDirect  direct not supported
      appname=${app_name_helm}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeLoadBalancer 
      appname=${app_name_vm}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeLoadBalancer
      #appname=${app_name_vm}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeDirect  direct not supported
      appname=${app_name_k8s}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeDefaultForDeployment
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeDefaultForDeployment
      appname=${app_name_helm}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeDefaultForDeployment
      appname=${app_name_vm}  apporg=${developer}  appvers=1.0  accesstype=AccessTypeDefaultForDeployment
 
      appname=${app_name_vm}  apporg=${developer}  appvers=1.0  trusted=${True}
      appname=${app_name_vm}  apporg=${developer}  appvers=1.0  trusted=${False}

      appname=${app_name_k8s}  apporg=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.portrangemin=1  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=udp  requiredoutboundconnections:0.portrangemin=1  requiredoutboundconnections:0.remotecidr=1.1.1.1/1
      appname=${app_name_helm}  apporg=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:1.protocol=tcp  requiredoutboundconnections:1.portrangemin=1  requiredoutboundconnections:1.remotecidr=1.1.1.1/1
      appname=${app_name_vm}  apporg=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.portrangemin=10  requiredoutboundconnections:0.remotecidr=1.1.1.1/1  requiredoutboundconnections:1.protocol=tcp  requiredoutboundconnections:1.portrangemin=1  requiredoutboundconnections:1.remotecidr=1.1.1.1/1
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.portrangemin=1  requiredoutboundconnections:0.portrangemax=2  requiredoutboundconnections:0.remotecidr=1.1.1.1/1

      appname=${app_name_k8s}  apporg=${developer}  appvers=1.0  autoprovpolicies=${autoprovpolicy_name}
      appname=${app_name_k8s}  apporg=${developer}  appvers=1.0  autoprovpolicies:empty=true

      # accessports
      appname=${app_name_k8s}     apporg=${developer}  appvers=1.0  accessports=tcp:2015:tls,tcp:2016,udp:2016:nginx,udp:2015:maxpktsize=1800
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  accessports=tcp:2015:tls,tcp:2016,udp:2016:nginx,udp:2015:maxpktsize=1800
      appname=${app_name_helm}    apporg=${developer}  appvers=1.0  accessports=tcp:2015:tls,tcp:2016,udp:2016:nginx,udp:2015:maxpktsize=1800
      appname=${app_name_vm}      apporg=${developer}  appvers=1.0  accessports=tcp:2015:tls,tcp:2016,udp:2016:nginx,udp:2015:maxpktsize=1800

      # qos priority
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  qossessionprofile=LowLatency
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  qossessionprofile=ThroughputDownS
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  qossessionprofile=ThroughputDownM
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  qossessionprofile=ThroughputDownL
      appname=${app_name_docker}  apporg=${developer}  appvers=1.0  qossessionprofile=LowLatency  qossessionduration=1m1s

# ECQ-3618
UpdateApp - mcctl shall handle update failures
   [Documentation]
   ...  - send UpdateApp via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Update App Via mcctl

      Error: parsing arg "autoprovpolicies:empty\=xx" failed: unable to parse "xx" as bool, valid values are true, false  appname=andyautoprov appvers=1.0 apporg=automation_dev_org autoprovpolicies:empty=xx 

      # qos priority session
      Error: parsing arg "qossessionprofile\=x" failed: unable to parse "x" as QosSessionProfile: invalid format, valid values are one of NoPriority, LowLatency, ThroughputDownS, ThroughputDownM, ThroughputDownL, or 0, 1, 2, 3, 4  appname=${app_name}  apporg=${developer}  appvers=1.0  qossessionprofile=x
      Error: parsing arg "qossessionduration\=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  appname=${app_name}  apporg=${developer}  appvers=1.0  qossessionduration=1
      Error: parsing arg "qossessionduration\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  appname=${app_name}  apporg=${developer}  appvers=1.0  qossessionduration=x
 
*** Keywords ***
Setup
   ${app_name}=  Get Default App Name
   ${autoprov_name}=  Get Default Auto Provisioning Policy Name

   ${dev_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
#   ${op_token}=   Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
   ${super_token}=  Get Super Token
   Set Suite Variable  ${dev_token}
#   Set Suite Variable  ${op_token}
   Set Suite Variable  ${super_token}
   Set Suite Variable  ${app_name}
   Set Suite Variable  ${autoprov_name}

   &{cloudlet1}=  create dictionary  name=tmocloud-1  organization=tmus
   &{cloudlet2}=  create dictionary  name=tmocloud-2  organization=tmus
   @{cloudletlist}=  create list  ${cloudlet1}  ${cloudlet2}
   Create Auto Provisioning Policy  region=${region}  policy_name=${autoprov_name}1  min_active_instances=1  max_instances=2  developer_org_name=${developer}  cloudlet_list=${cloudletlist}  token=${super_token}
   Create Auto Provisioning Policy  region=${region}  policy_name=${autoprov_name}2  min_active_instances=1  max_instances=2  developer_org_name=${developer}  cloudlet_list=${cloudletlist}  token=${super_token}

   @{autoprovpolicies}=  Create List  ${autoprov_name}1  ${autoprov_name}2
   Set Suite Variable  @{autoprovpolicies}
 
Success Create/Show/Delete App Via mcctl
   [Arguments]  &{parms}
   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   Remove From Dictionary  ${parms_copy}  deploymentmanifest
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
 
   Run mcctl  app create region=${region} ${parmss}  token=${dev_token} --debug  version=${version}
   ${show}=  Run mcctl  app show region=${region} ${parmss_modify}  token=${dev_token}  version=${version}
   Run mcctl  app delete region=${region} ${parmss_modify}  token=${dev_token}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['appname']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['apporg']}
   Should Be Equal  ${show[0]['key']['version']}  ${parms['appvers']}
   Should Be Equal  ${show[0]['image_path']}  ${parms['imagepath']}

   Run Keyword If  'accessports' in ${parms}  Should Be Equal  ${show[0]['access_ports']}  ${parms['accessports']}

#   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeDocker'  Should Be Equal  ${show[0]['image_type']}  ImageTypeDocker 
#   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeQcow'  Should Be Equal  ${show[0]['image_type']}  ImageTypeQcow
#   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeHelm'  Should Be Equal  ${show[0]['image_type']}  ImageTypeHelm
   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeDocker'  Should Be Equal   ${show[0]['image_type']}  Docker
   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeQcow'  Should Be Equal     ${show[0]['image_type']}  Qcow
   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeHelm'  Should Be Equal     ${show[0]['image_type']}  Helm

   Run Keyword If  'deployment' in ${parms}  Should Be Equal  ${show[0]['deployment']}  ${parms['deployment']}

   Run Keyword If  'deployment' not in ${parms} and '${parms['imagetype']}' == 'ImageTypeDocker'  Should Be Equal  ${show[0]['deployment']}  kubernetes
   Run Keyword If  'deployment' not in ${parms} and '${parms['imagetype']}' == 'ImageTypeHelm'    Should Be Equal  ${show[0]['deployment']}  helm
   Run Keyword If  'deployment' not in ${parms} and '${parms['imagetype']}' == 'ImageTypeQcow'    Should Be Equal  ${show[0]['deployment']}  vm
 

   #Run Keyword If  'accesstype' not in ${parms} and '${show[0]['deployment']}' == 'kubernetes'  Should Be Equal  ${show[0]['access_type']}  AccessTypeLoadBalancer
   #Run Keyword If  'accesstype' not in ${parms} and '${show[0]['deployment']}' == 'helm'        Should Be Equal  ${show[0]['access_type']}  AccessTypeLoadBalancer
   #Run Keyword If  'accesstype' not in ${parms} and '${show[0]['deployment']}' == 'vm'          Should Be Equal  ${show[0]['access_type']}  AccessTypeLoadBalancer
   #Run Keyword If  'accesstype' not in ${parms} and '${show[0]['deployment']}' == 'docker'      Should Be Equal  ${show[0]['access_type']}  AccessTypeLoadBalancer
   Should Be Equal  ${show[0]['access_type']}  LoadBalancer

   Run Keyword If  'officialfqdn' in ${parms}  Should Be Equal  ${show[0]['official_fqdn']}  ${parms['officialfqdn']} 
   Run Keyword If  'androidpackagename' in ${parms}  Should Be Equal  ${show[0]['android_package_name']}  ${parms['androidpackagename']}

   ${num_autoprovpolicies}=  Run Keyword If  'autoprovpolicies' in ${parms}  Get Length  ${parms['autoprovpolicies'].split()}  ELSE  Set Variable  0
   Run Keyword If  'autoprovpolicies' in ${parms}  Should Be Equal  ${show[0]['auto_prov_policies']}[0]  ${parms['autoprovpolicies'].split()}[0]
   Run Keyword If  ${num_autoprovpolicies} == 2  Should Contain  ${parms['autoprovpolicies'].split()}[1]  ${show[0]['auto_prov_policies']}[1]

   ${authkey_stripped}=   Run Keyword If  'authpublickey' in ${parms}  Remove String  ${parms['authpublickey']}  "
   Run Keyword If  'authpublickey' in ${parms}  Should Be Equal  ${show[0]['auth_public_key']}  ${authkey_stripped}

   Run Keyword If  'deploymentmanifest' in ${parms} and '${show[0]['deployment']}' == 'vm'  Should Contain  ${show[0]['deployment_manifest']}  cloud-config
   Run Keyword If  'deploymentmanifest' in ${parms} and '${show[0]['deployment']}' != 'vm'  Should Contain  ${show[0]['deployment_manifest']}  apiVersion

   Run Keyword If  'scalewithcluster' in ${parms}  Run Keyword If  ${parms['scalewithcluster']} == ${True}  Should Be Equal  ${show[0]['scale_with_cluster']}  ${parms['scalewithcluster']}
   Run Keyword If  'scalewithcluster' in ${parms}  Run Keyword If  ${parms['scalewithcluster']} == ${False}  Should Be True  'scale_with_cluster' not in ${show[0]}

   ${configs0_stripped}=   Run Keyword If  'configs:0.config' in ${parms}  Remove String  ${parms['configs:0.config']}  "
   ${configs1_stripped}=   Run Keyword If  'configs:1.config' in ${parms}  Remove String  ${parms['configs:1.config']}  "
   Run Keyword If  'configs:0.kind' in ${parms}  Should Contain  ${show[0]['configs'][0]['kind']}  ${parms['configs:0.kind']}
   Run Keyword If  'configs:0.config' in ${parms}  Should Contain  ${show[0]['configs'][0]['config']}  ${configs0_stripped}
   Run Keyword If  'configs:1.kind' in ${parms}  Should Contain  ${show[0]['configs'][1]['kind']}  ${parms['configs:1.kind']}
   Run Keyword If  'configs:1.config' in ${parms}  Should Contain  ${show[0]['configs'][1]['config']}  ${configs1_stripped}

   Run Keyword If  'trusted' in ${parms}  Run Keyword If  ${parms['trusted']} == ${True}  Should Be Equal  ${show[0]['trusted']}  ${True}
   ...  ELSE  Should Not Contain  ${show[0]}  trusted 
   Run Keyword If  'trusted' in ${parms}  Run Keyword If  ${parms['trusted']} == ${False}  Should Not Contain  ${show[0]}  trusted

   #Run Keyword If  'requiredoutboundconnections:0.protocol' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][0]['protocol']}  ${parms['requiredoutboundconnections:0.protocol']}
   Run Keyword If  'requiredoutboundconnections:0.remotecidr' in ${parms}  Should Be Equal  ${show[0]['required_outbound_connections'][0]['remote_cidr']}  ${parms['requiredoutboundconnections:0.remotecidr']}
   #Run Keyword If  'requiredoutboundconnections:0.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:0.protocol']}' == 'icmp'  Should Not Contain  ${show[0]['required_outbound_connections'][0]}  portrangemin
   IF  'requiredoutboundconnections:0.protocol' in ${parms}
      ${protocol_upper0}=  Convert To Uppercase  ${parms['requiredoutboundconnections:0.protocol']}
      Should Be Equal  ${show[0]['required_outbound_connections'][0]['protocol']}  ${protocol_upper0}
      IF  '${parms['requiredoutboundconnections:0.protocol']}' != 'icmp'
         Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][0]['port_range_min']}  ${parms['requiredoutboundconnections:0.portrangemin']}
         IF  'requiredoutboundconnections:0.portrangemax' in ${parms}
            Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][0]['port_range_max']}  ${parms['requiredoutboundconnections:0.portrangemax']}
         END
      ELSE
         Should Not Contain  ${show[0]['required_outbound_connections'][0]}  port_range_min
      END
   END
   #Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][1]['protocol']}  ${parms['requiredoutboundconnections:1.protocol']}
   Run Keyword If  'requiredoutboundconnections:1.remotecidr' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][1]['remote_cidr']}  ${parms['requiredoutboundconnections:1.remotecidr']}
   #Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:1.protocol']}' == 'icmp'  Should Not Contain  ${show[0]['required_outbound_connections'][1]}  port_range_min
   #Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:1.protocol']}' != 'icmp'  Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][1]['port_range_min']}  ${parms['requiredoutboundconnections:1.portrangemin']}
   IF  'requiredoutboundconnections:1.protocol' in ${parms}
      ${protocol_upper1}=  Convert To Uppercase  ${parms['requiredoutboundconnections:1.protocol']}
      Should Be Equal  ${show[0]['required_outbound_connections'][1]['protocol']}  ${protocol_upper1}
      IF  '${parms['requiredoutboundconnections:1.protocol']}' != 'icmp'
         Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][1]['port_range_min']}  ${parms['requiredoutboundconnections:1.portrangemin']}
         IF  'requiredoutboundconnections:1.portrangemax' in ${parms}
            Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][1]['port_range_max']}  ${parms['requiredoutboundconnections:1.portrangemax']}
         END
      ELSE
         Should Not Contain  ${show[0]['required_outbound_connections'][1]}  port_range_min
      END
   END


   IF  'allowserverless' in ${parms}
      IF  ${parms['allowserverless']} == ${True}
         Should Be Equal  ${show[0]['allow_serverless']}  ${True}
         IF  'serverlessconfig.vcpus' in ${parms}
            Should Be Equal As Numbers  ${show[0]['serverless_config']['vcpus']}  ${parms['serverlessconfig.vcpus']}
            Should Be Equal As Numbers  ${show[0]['serverless_config']['ram']}  ${parms['serverlessconfig.ram']}
            Should Be Equal As Numbers  ${show[0]['serverless_config']['min_replicas']}  ${parms['serverlessconfig.minreplicas']}
         END
      END
   END

   IF  'qossessionprofile' in ${parms}
      Run Keyword If  '${parms['qossessionprofile']}' == '0' or '${parms['qossessionprofile']}' == 'NoPriority'  Should Not Contain  ${show[0]}  qos_session_profile
      Run Keyword If  '${parms['qossessionprofile']}' == '1' or '${parms['qossessionprofile']}' == 'LowLatency'  Should Be Equal  ${show[0]['qos_session_profile']}   LowLatency
      Run Keyword If  '${parms['qossessionprofile']}' == '2' or '${parms['qossessionprofile']}' == 'ThroughputDownS'  Should Be Equal  ${show[0]['qos_session_profile']}   ThroughputDownS
      Run Keyword If  '${parms['qossessionprofile']}' == '3' or '${parms['qossessionprofile']}' == 'ThroughputDownM'  Should Be Equal  ${show[0]['qos_session_profile']}   ThroughputDownM
      Run Keyword If  '${parms['qossessionprofile']}' == '4' or '${parms['qossessionprofile']}' == 'ThroughputDownL'  Should Be Equal  ${show[0]['qos_session_profile']}   ThroughputDownL
   END

   IF  'qossessionduration' in ${parms}
      Should Be Equal  ${show[0]['qos_session_duration']}  ${parms['qossessionduration']}
   END

Update Setup
   ${app_name}=  Get Default App Name
   ${app_name_k8s}=  Set Variable  ${app_name}_k8s
   ${app_name_docker}=  Set Variable  ${app_name}_docker
   ${app_name_helm}=  Set Variable  ${app_name}_helm
   ${app_name_vm}=  Set Variable  ${app_name}_vm
   ${autoprovpolicy_name}=  Set Variable  ${app_name}_autoprovpolicy

   Set Suite Variable  ${app_name_k8s}
   Set Suite Variable  ${app_name_docker}
   Set Suite Variable  ${app_name_vm}
   Set Suite Variable  ${app_name_helm}
   Set Suite Variable  ${autoprovpolicy_name}

   ${dev_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   Set Suite Variable  ${dev_token}

   Run mcctl  autoprovpolicy create region=${region} name=${autoprovpolicy_name}0 apporg=${developer} deployclientcount=1 minactiveinstances=1 cloudlets:0.key.organization=tmus cloudlets:0.key.name=tmocloud-1  token=${dev_token}  version=${version}
   Run mcctl  autoprovpolicy create region=${region} name=${autoprovpolicy_name} apporg=${developer} deployclientcount=1 minactiveinstances=1 cloudlets:0.key.organization=tmus cloudlets:0.key.name=tmocloud-1  token=${dev_token}  version=${version}

   Run mcctl  app create region=${region} appname=${app_name_k8s} apporg=${developer} appvers=1.0 imagetype=ImageTypeDocker deployment=kubernetes imagepath=${docker_image} defaultflavor=automation_api_flavor autoprovpolicies=${autoprovpolicy_name}0  token=${dev_token}  version=${version}
   Run mcctl  app create region=${region} appname=${app_name_docker} apporg=${developer} appvers=1.0 imagetype=ImageTypeDocker deployment=docker imagepath=${docker_image} defaultflavor=automation_api_flavor  token=${dev_token}  version=${version}
   Run mcctl  app create region=${region} appname=${app_name_helm} apporg=${developer} appvers=1.0 imagetype=ImageTypeHelm deployment=helm imagepath=${docker_image} defaultflavor=automation_api_flavor  token=${dev_token}  version=${version}
   Run mcctl  app create region=${region} appname=${app_name_vm} apporg=${developer} appvers=1.0 imagetype=ImageTypeQcow deployment=vm imagepath=${qcow_centos_image} defaultflavor=automation_api_flavor  token=${dev_token}  version=${version}

Update Teardown
   Run mcctl  app delete region=${region} appname=${app_name_k8s} apporg=${developer} appvers=1.0  token=${dev_token}  version=${version}
   Run mcctl  app delete region=${region} appname=${app_name_docker} apporg=${developer} appvers=1.0  token=${dev_token}  version=${version}
   Run mcctl  app delete region=${region} appname=${app_name_helm} apporg=${developer} appvers=1.0  token=${dev_token}  version=${version}
   Run mcctl  app delete region=${region} appname=${app_name_vm} apporg=${developer} appvers=1.0  token=${dev_token}  version=${version}
   Run mcctl  autoprovpolicy delete region=${region} name=${autoprovpolicy_name}0 apporg=${developer}  token=${dev_token}  version=${version}
   Run mcctl  autoprovpolicy delete region=${region} name=${autoprovpolicy_name} apporg=${developer}  token=${dev_token}  version=${version}

Success Update/Show App Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  app update region=${region} ${parmss}  token=${dev_token}  version=${version}
   ${show}=  Run mcctl  app show region=${region} ${parmss}  token=${dev_token}  version=${version}

   #Verify Show  show=${show}  &{parms}
   Should Be Equal  ${show[0]['key']['name']}  ${parms['appname']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['apporg']}
   Should Be Equal  ${show[0]['key']['version']}  ${parms['appvers']}

   Run Keyword If  'imagepath' in ${parms}  Should Be Equal  ${show[0]['image_path']}  ${parms['imagepath']} 

   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDirect'  Should Be Equal   ${show[0]['access_type']}  Direct
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeLoadBalancer'  Should Be Equal   ${show[0]['access_type']}  LoadBalancer
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDefaultForDeployment'  Run Keyword If  '${show[0]['deployment']}' == 'docker'  Should Be Equal   ${show[0]['access_type']}  LoadBalancer
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDefaultForDeployment'  Run Keyword If  '${show[0]['deployment']}' == 'kubernetes'  Should Be Equal   ${show[0]['access_type']}  LoadBalancer
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDefaultForDeployment'  Run Keyword If  '${show[0]['deployment']}' == 'helm'  Should Be Equal   ${show[0]['access_type']}  LoadBalancer
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDefaultForDeployment'  Run Keyword If  '${show[0]['deployment']}' == 'vm'  Should Be Equal     ${show[0]['access_type']}  LoadBalancer

   Run Keyword If  'imagetype' in ${parms}  Run Keyword If  '${parms['imagetype']}' == 'ImageTypeDocker'  Should Be Equal   ${show[0]['image_type']}  Docker
   Run Keyword If  'imagetype' in ${parms}  Run Keyword If  '${parms['imagetype']}' == 'ImageTypeQcow'  Should Be Equal     ${show[0]['image_type']}  Qcow
   Run Keyword If  'imagetype' in ${parms}  Run Keyword If  '${parms['imagetype']}' == 'ImageTypeHelm'  Should Be Equal     ${show[0]['image_type']}  Helm

   Run Keyword If  'trusted' in ${parms}  Run Keyword If  ${parms['trusted']} == ${True}  Should Be Equal  ${show[0]['trusted']}  ${True}
   ...  ELSE  Should Not Contain  ${show[0]}  trusted
   Run Keyword If  'trusted' in ${parms}  Run Keyword If  ${parms['trusted']} == ${False}  Should Not Contain  ${show[0]}  trusted

   IF  'requiredoutboundconnections:0.protocol' in ${parms}
      ${protocol_upper0}=  Convert To Uppercase  ${parms['requiredoutboundconnections:0.protocol']}
      Should Contain  ${show[0]['required_outbound_connections'][0]['protocol']}  ${protocol_upper0}
      Should Contain  ${show[0]['required_outbound_connections'][0]['remote_cidr']}  ${parms['requiredoutboundconnections:0.remotecidr']}
      Run Keyword If  '${parms['requiredoutboundconnections:0.protocol']}' == 'icmp'  Should Not Contain  ${show[0]['required_outbound_connections'][0]}  port_range_min
      Run Keyword If  '${parms['requiredoutboundconnections:0.protocol']}' != 'icmp'  Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][0]['port_range_min']}  ${parms['requiredoutboundconnections:0.portrangemin']}
   END

   IF  'requiredoutboundconnections:1.protocol' in ${parms}
      ${protocol_upper1}=  Convert To Uppercase  ${parms['requiredoutboundconnections:1.protocol']}
      Should Contain  ${show[0]['required_outbound_connections'][1]['protocol']}  ${protocol_upper1}
      Should Contain  ${show[0]['required_outbound_connections'][1]['remote_cidr']}  ${parms['requiredoutboundconnections:1.remotecidr']}
      Run Keyword If  '${parms['requiredoutboundconnections:1.protocol']}' == 'icmp'  Should Not Contain  ${show[0]['required_outbound_connections'][1]}  port_range_min
      Run Keyword If  '${parms['requiredoutboundconnections:1.protocol']}' != 'icmp'  Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][1]['port_range_min']}  ${parms['requiredoutboundconnections:1.portrangemin']}
   END
   Run Keyword If  'requiredoutboundconnections:0.portrangemax' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:0.protocol']}' != 'icmp'  Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][0]['port_range_max']}  ${parms['requiredoutboundconnections:0.portrangemax']}

   IF  'autoprovpolicies' in ${parms}
      Should Be Equal  ${show[0]['auto_prov_policies'][0]}  ${autoprovpolicy_name}
   END
   IF  'autoprovpolicies:empty' in ${parms}
      Should Be True  'auto_prov_policies' not in ${show[0]} 
   END

   Run Keyword If  'accessports' in ${parms}  Should Be Equal  ${show[0]['access_ports']}  ${parms['accessports']}

   IF  'qossessionprofile' in ${parms}
      Run Keyword If  '${parms['qossessionprofile']}' == '0' or '${parms['qossessionprofile']}' == 'NoPriority'  Should Not Contain  ${show[0]}  qos_session_profile
      Run Keyword If  '${parms['qossessionprofile']}' == '1' or '${parms['qossessionprofile']}' == 'LowLatency'  Should Be Equal  ${show[0]['qos_session_profile']}   LowLatency
      Run Keyword If  '${parms['qossessionprofile']}' == '2' or '${parms['qossessionprofile']}' == 'ThroughputDownS'  Should Be Equal  ${show[0]['qos_session_profile']}   ThroughputDownS
      Run Keyword If  '${parms['qossessionprofile']}' == '3' or '${parms['qossessionprofile']}' == 'ThroughputDownM'  Should Be Equal  ${show[0]['qos_session_profile']}   ThroughputDownM
      Run Keyword If  '${parms['qossessionprofile']}' == '4' or '${parms['qossessionprofile']}' == 'ThroughputDownL'  Should Be Equal  ${show[0]['qos_session_profile']}   ThroughputDownL
   END

   IF  'qossessionduration' in ${parms}
      Should Be Equal  ${show[0]['qos_session_duration']}  ${parms['qossessionduration']}
   END
 
Fail Create App Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  app create region=${region} ${parmss}  token=${dev_token}  version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Update App Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  app update region=${region} ${parmss}  token=${dev_token}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

