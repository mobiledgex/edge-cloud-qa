*** Settings ***
Documentation  CreateApp mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml
${server_ping_threaded_cloudconfig}  http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml
${manifest_string}=  apiVersion: v1\nkind: Service\nmetadata:\n  name: server-ping-threaded-udptcphttp-tcpservice\n  labels:\n    run: server-ping-threaded-udptcphttpapp\nspec:\n  type: LoadBalancer\n  ports:\n  - port: 2016\n    targetPort: 2016\n    protocol: TCP\n    name: tcp2016\n  selector:\n    run: server-ping-threaded-udptcphttpapp
${cloudconfig_string}=  \#cloud-config\n users:\n - name: demo\n groups: sudo\n shell: /bin/bash\n sudo: ['ALL=(ALL) NOPASSWD:ALL']\n runcmd:\n - /opt/rh/rh-python36/root/usr/bin/python3 /home/centos/server_ping_threaded.py
${envvars_config}=  - name: CrmValue\n${SPACE*2}value: [[ .Deployment.ClusterIp ]]\n- name: CrmValue2\n${SPACE*2}value: [[ .Deployment.ClusterIp ]]
${envvars_url}=  http://35.199.188.102/apps/server_ping_threaded_config.yml

${version}=  2021-01-12

*** Test Cases ***
# ECQ-2889
CreateApp - mcctl shall be able to create/show/delete app 
   [Documentation]
   ...  - send CreateApp/ShowApp/DeleteApp via mcctl with various parms
   ...  - verify app is created/shown/deleted

   [Template]  Success Create/Show/Delete App Via mcctl
      # no protocol 
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  imagepath=${docker_image}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  imagepath=${docker_image}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow  imagepath=${qcow_centos_image}

      # officialfqdn and androidpackagename
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  officialfqdn=automation.com  
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}   officialfqdn=automation.com 
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}   officialfqdn=automation.com 
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}   officialfqdn=automation.com 
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  androidpackagename=automation.android.com  
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}     androidpackagename=automation.android.com
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}     androidpackagename=automation.android.com
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}     androidpackagename=automation.android.com
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  officialfqdn=automation.com  androidpackagename=automation.android.com
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}   officialfqdn=automation.com  androidpackagename=automation.android.com
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}   officialfqdn=automation.com  androidpackagename=automation.android.com
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}   officialfqdn=automation.com  androidpackagename=automation.android.com

      # authpublickey
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  authpublickey="${vm_public_key}"
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  authpublickey="${vm_public_key}"  
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}    authpublickey="${vm_public_key}"
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}    authpublickey="${vm_public_key}"

      # manifest
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  deploymentmanifest="${manifest_string}"
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  deploymentmanifest="${manifest_string}"
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  deploymentmanifest="${manifest_string}"
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  deploymentmanifest="${cloudconfig_string}"
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  deploymentmanifest=${server_ping_threaded_cloudconfig}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  deploymentmanifest=${manifest_url}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  deploymentmanifest=${manifest_url}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  deploymentmanifest=${manifest_url}

      # scalewithcluster
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=${True}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=${False}

      # configs
      # EDGECLOUD-3163 Support envVarsYaml config for CreateApp on docker
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config="${envvars_config}" 
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml  configs:0.config="${envvars_config}"
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config=${envvars_url}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml  configs:0.config=${envvars_url}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config="${envvars_config}"  configs:1.kind=envVarsYaml  configs:1.config="${envvars_config}"
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config=${envvars_url}  configs:1.kind=envVarsYaml  configs:1.config=${envvars_url}

      # autoprovpolicies
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  autoprovpolicies=${autoprov_name}1
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  autoprovpolicies=${autoprov_name}1 
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  autoprovpolicies=${autoprov_name}1
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}  autoprovpolicies=${autoprov_name}1
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow  deployment=vm  imagepath=${qcow_centos_image}  autoprovpolicies=${autoprov_name}1 autoprovpolicies=${autoprov_name}2
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  autoprovpolicies=${autoprov_name}1 autoprovpolicies=${autoprov_name}2
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  autoprovpolicies=${autoprov_name}1 autoprovpolicies=${autoprov_name}2
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}  autoprovpolicies=${autoprov_name}1 autoprovpolicies=${autoprov_name}2

      # trusted
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${False}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${False}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${False}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeLoadBalancer  imagepath=${qcow_centos_image}  trusted=${True}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeLoadBalancer  imagepath=${qcow_centos_image}  trusted=${False}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=${True}
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=${False}

      # requiredoutboundconnections
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.port=0  requiredoutboundconnections:0.remoteip=1.1.1.1
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${False}  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.remoteip=1.1.1.1
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remoteip=1.1.1.1  requiredoutboundconnections:0.port=2
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=udp  requiredoutboundconnections:0.remoteip=1.1.1.1  requiredoutboundconnections:0.port=2
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remoteip=1.1.1.1  requiredoutboundconnections:0.port=2  requiredoutboundconnections:1.protocol=udp  requiredoutboundconnections:1.remoteip=1.1.1.1  requiredoutboundconnections:1.port=2
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remoteip=1.1.1.1  requiredoutboundconnections:0.port=2  requiredoutboundconnections:1.protocol=icmp  requiredoutboundconnections:1.remoteip=1.1.1.1  
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remoteip=1.1.1.1  requiredoutboundconnections:0.port=2  requiredoutboundconnections:1.protocol=tcp  requiredoutboundconnections:1.remoteip=1.1.1.1  requiredoutboundconnections:1.port=2
      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=  # remove the ports

# ECQ-2890
CreateApp - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateApp via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create App Via mcctl
      # missing values
      Error: Bad Request (400), Unknown image type IMAGE_TYPE_UNKNOWN  appname=${app_name}  app-org=${developer}  appvers=1.0

      # autoprovpolicies
      Error: Bad Request (400), Policy key {"organization":"MobiledgeX","name":"x"} not found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow  imagepath=${qcow_centos_image}  autoprovpolicies=x
      Error: Bad Request (400), Policy key {"organization":"MobiledgeX","name":"x"} not found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  autoprovpolicies=x
      Error: Bad Request (400), Policy key {"organization":"MobiledgeX","name":"x"} not found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker   deployment=docker  imagepath=${docker_image}  autoprovpolicies=x
      Error: Bad Request (400), Policy key {"organization":"MobiledgeX","name":"x"} not found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  autoprovpolicies=x
      Error: Bad Request (400), Policy key {"organization":"MobiledgeX"} not found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow  imagepath=${qcow_centos_image}  autoprovpolicies=

      # authpublickey
      Error: Bad Request (400), Failed to parse public key: ssh: no key found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow  imagepath=${qcow_centos_image}  authpublickey=x
      Error: Bad Request (400), Failed to parse public key: ssh: no key found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  authpublickey=x
      Error: Bad Request (400), Failed to parse public key: ssh: no key found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker   deployment=docker  imagepath=${docker_image}  authpublickey=x
      Error: Bad Request (400), Failed to parse public key: ssh: no key found  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  authpublickey=x

      # deployment manifest
      # EDGECLOUD-4002  CreateApp should validate for proper helm chart and docker compose when using deploymentmanifest
      Error: Bad Request (400), Invalid deployment manifest, only cloud-init script support, must start with \\\'#cloud-config\\\'  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  deploymentmanifest=${manifest_url}
      Error: Bad Request (400), Invalid deployment manifest, only cloud-init script support, must start with \\\'#cloud-config\\\'  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  deploymentmanifest=x
      Error: Bad Request (400), Invalid deployment manifest, parse kubernetes deployment yaml failed  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker   deployment=kubernetes  imagepath=${docker_image}  deploymentmanifest=x
      Error: Bad Request (400), Invalid deployment manifest, parse kubernetes deployment yaml failed  appname=${app_name}1  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker   deployment=docker  imagepath=${docker_image}  deploymentmanifest=x
      Error: Bad Request (400), Invalid deployment manifest, parse kubernetes deployment yaml failed  appname=${app_name}2  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm   deployment=helm  imagepath=${docker_image}  deploymentmanifest=x

      # scalewithcluster
      Error: Bad Request (400), App scaling is only supported for Kubernetes deployments  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=${True}
      Error: Bad Request (400), App scaling is only supported for Kubernetes deployments  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=${True}
      Error: Bad Request (400), App scaling is only supported for Kubernetes deployments  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  scalewithcluster=${True}
      Unable to parse "scalewithcluster" value "x" as bool: invalid syntax, valid values are true, false   appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  scalewithcluster=x
      Unable to parse "scalewithcluster" value "x" as bool: invalid syntax, valid values are true, false   appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=x
      Unable to parse "scalewithcluster" value "x" as bool: invalid syntax, valid values are true, false   appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=x
      Unable to parse "scalewithcluster" value "x" as bool: invalid syntax, valid values are true, false   appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  scalewithcluster=x


      # androidpackagename and officialfqdn - no errors

      #configs
      # fixed EDGECLOUD-3993 CreateApp with configs.kind only should give an error
      # fixed EDGECLOUD-3232 CreateApp with deployment=vm and configs=envVarsYaml should give error
      # EDGECLOUD-3163 Support envVarsYaml config for CreateApp on docker
      # fixed EDGECLOUD-3238 no error given with CreateAppInst with bad configs envVarsYaml value
      # EDGECLOUD-4216 CreateApp with invalid helmCustomizationYaml config should give an error
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  configs:0.kind=nvVarsYam
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=nvVarsYam
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=nvVarsYam
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=nvVarsYam
      Error: Bad Request (400), Invalid Config Kind - nvVarsYam  appname=${app_name}3  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  configs:0.kind=nvVarsYaml
     Error: Bad Request (400), Cannot unmarshal env vars: x - yaml: unmarshal errors:\\n  line 1: cannot unmarshal !!str `x` into []v1.EnvVar  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config=x
      Error: Bad Request (400), Cannot unmarshal env vars: x - yaml: unmarshal errors:\\n  line 1: cannot unmarshal !!str `x` into []v1.EnvVar  appname=${app_name}4  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config=x
      Error: Bad Request (400), Cannot unmarshal env vars: x - yaml: unmarshal errors:\\n  line 1: cannot unmarshal !!str `x` into []v1.EnvVar  appname=${app_name}6  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml  configs:0.config=x
      Error: Bad Request (400), Invalid Config Kind(envVarsYaml) for deployment type(vm)  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml
      Error: Bad Request (400), Invalid Config Kind(helmCustomizationYaml) for deployment type(vm)  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm  imagepath=${qcow_centos_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml
      Error: Bad Request (400), Invalid Config Kind(helmCustomizationYaml) for deployment type(kubernetes)  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=kubernetes  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml
      Error: Bad Request (400), Invalid Config Kind(helmCustomizationYaml) for deployment type(docker)  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker    deployment=docker  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=helmCustomizationYaml
      Error: Bad Request (400), Invalid Config Kind(envVarsYaml) for deployment type(helm)  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm  deployment=helm  imagepath=${docker_image}  accessports=tcp:2015  configs:0.kind=envVarsYaml  configs:0.config="${envvars_config}"

      # trusted
      Unable to parse "trusted" value "x" as bool: invalid syntax, valid values are true, false       appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}  trusted=x
      Unable to parse "trusted" value "x" as bool: invalid syntax, valid values are true, false       appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=x
      Unable to parse "trusted" value "xTrue}" as bool: invalid syntax, valid values are true, false  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=xTrue}
      Unable to parse "trusted" value "a" as bool: invalid syntax, valid values are true, false       appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=docker      accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=a
      Unable to parse "trusted" value "r" as bool: invalid syntax, valid values are true, false       appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=r
      Unable to parse "trusted" value "cccccc" as bool: invalid syntax, valid values are true, false  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm    deployment=helm        accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=cccccc
      Unable to parse "trusted" value "111" as bool: invalid syntax, valid values are true, false     appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeLoadBalancer  imagepath=${qcow_centos_image}  trusted=111
      Unable to parse "trusted" value "-1" as bool: invalid syntax, valid values are true, false       appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeLoadBalancer  imagepath=${qcow_centos_image}  trusted=-1
      Unable to parse "trusted" value "no" as bool: invalid syntax, valid values are true, false      appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=no
      Unable to parse "trusted" value "yes" as bool: invalid syntax, valid values are true, false     appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow    deployment=vm          accesstype=AccessTypeDirect        imagepath=${qcow_centos_image}  trusted=yes

      # requiredoutboundconnections
      Bad Request (400), Port must be 0 for icmp   appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.port=1  requiredoutboundconnections:0.remoteip=1.1.1.1
      Error: Bad Request (400), Remote port out of range: 0   appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.port=0  requiredoutboundconnections:0.remoteip=1.1.1.1
      Error: Bad Request (400), Remote port out of range: 0   appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=udp  requiredoutboundconnections:0.port=0  requiredoutboundconnections:0.remoteip=1.1.1.1
      Error: Bad Request (400), Invalid protocol specified for remote connection: cmp  appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=cmp  requiredoutboundconnections:0.port=1  requiredoutboundconnections:0.remoteip=1.1.1.1
      Error: Bad Request (400), Invalid remote IP:    appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=icmp
      Error: Bad Request (400), Invalid remote IP:    appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp 
      Error: Bad Request (400), Invalid remote IP:    appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=udp  requiredoutboundconnections:0.port=1
      Error: Bad Request (400), Remote port out of range: 0   appname=${app_name}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker  deployment=kubernetes  accesstype=AccessTypeLoadBalancer  imagepath=${docker_image}       trusted=${True}  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.remoteip=1.1.1.1


# ECQ-2829
UpdateApp - mcctl shall handle update app 
   [Documentation]
   ...  - send UpdateApp via mcctl with various args
   ...  - verify proper is updated

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success Update/Show App Via mcctl
      appname=${app_name_k8s}  app-org=${developer}  appvers=1.0  imagepath=${docker_image_cpu}
      appname=${app_name_docker}  app-org=${developer}  appvers=1.0  imagepath=${docker_image_cpu}
      appname=${app_name_helm}  app-org=${developer}  appvers=1.0  imagepath=${docker_image_cpu}
      appname=${app_name_vm}  app-org=${developer}  appvers=1.0  imagepath=${qcow_gpu_ubuntu16_image}

      appname=${app_name_k8s}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker
      appname=${app_name_docker}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeDocker
      appname=${app_name_helm}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeHelm
      appname=${app_name_vm}  app-org=${developer}  appvers=1.0  imagetype=ImageTypeQcow

      appname=${app_name_k8s}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeLoadBalancer
      appname=${app_name_docker}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeLoadBalancer 
      appname=${app_name_docker}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeDirect
      appname=${app_name_helm}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeLoadBalancer 
      appname=${app_name_vm}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeLoadBalancer
      appname=${app_name_vm}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeDirect
      appname=${app_name_k8s}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeDefaultForDeployment
      appname=${app_name_docker}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeDefaultForDeployment
      appname=${app_name_helm}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeDefaultForDeployment
      appname=${app_name_vm}  app-org=${developer}  appvers=1.0  accesstype=AccessTypeDefaultForDeployment
 
      appname=${app_name_vm}  app-org=${developer}  appvers=1.0  trusted=${True}
      appname=${app_name_vm}  app-org=${developer}  appvers=1.0  trusted=${False}

      appname=${app_name_k8s}  app-org=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.remoteip=1.1.1.1
      appname=${app_name_docker}  app-org=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.port=1  requiredoutboundconnections:0.remoteip=1.1.1.1
      appname=${app_name_docker}  app-org=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=udp  requiredoutboundconnections:0.port=1  requiredoutboundconnections:0.remoteip=1.1.1.1
      appname=${app_name_helm}  app-org=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=icmp  requiredoutboundconnections:0.remoteip=1.1.1.1  requiredoutboundconnections:1.protocol=tcp  requiredoutboundconnections:1.port=1  requiredoutboundconnections:1.remoteip=1.1.1.1
      appname=${app_name_vm}  app-org=${developer}  appvers=1.0  requiredoutboundconnections:0.protocol=tcp  requiredoutboundconnections:0.port=10  requiredoutboundconnections:0.remoteip=1.1.1.1  requiredoutboundconnections:1.protocol=tcp  requiredoutboundconnections:1.port=1  requiredoutboundconnections:1.remoteip=1.1.1.1
 
*** Keywords ***
Setup
   ${app_name}=  Get Default App Name
   ${autoprov_name}=  Get Default Auto Provisioning Policy Name

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${autoprov_name}

   &{cloudlet1}=  create dictionary  name=tmocloud-1  organization=tmus
   &{cloudlet2}=  create dictionary  name=tmocloud-2  organization=tmus
   @{cloudletlist}=  create list  ${cloudlet1}  ${cloudlet2}
   Create Auto Provisioning Policy  region=${region}  policy_name=${autoprov_name}1  min_active_instances=1  max_instances=2  developer_org_name=${developer}  cloudlet_list=${cloudletlist}
   Create Auto Provisioning Policy  region=${region}  policy_name=${autoprov_name}2  min_active_instances=1  max_instances=2  developer_org_name=${developer}  cloudlet_list=${cloudletlist}

   @{autoprovpolicies}=  Create List  ${autoprov_name}1  ${autoprov_name}2
   Set Suite Variable  @{autoprovpolicies}
 
Success Create/Show/Delete App Via mcctl
   [Arguments]  &{parms}
   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   Remove From Dictionary  ${parms_copy}  deploymentmanifest
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
 
   Run mcctl  region CreateApp region=${region} ${parmss} --debug  version=${version}
   ${show}=  Run mcctl  region ShowApp region=${region} ${parmss_modify}  version=${version}
   Run mcctl  region DeleteApp region=${region} ${parmss_modify}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['appname']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['app-org']}
   Should Be Equal  ${show[0]['key']['version']}  ${parms['appvers']}
   Should Be Equal  ${show[0]['image_path']}  ${parms['imagepath']}

   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeDocker'  Should Be Equal As Integers  ${show[0]['image_type']}  1 
   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeQcow'  Should Be Equal As Integers  ${show[0]['image_type']}  2
   Run Keyword If  '${parms['imagetype']}' == 'ImageTypeHelm'  Should Be Equal As Integers  ${show[0]['image_type']}  3

   Run Keyword If  'deployment' in ${parms}  Should Be Equal  ${show[0]['deployment']}  ${parms['deployment']}

   Run Keyword If  'deployment' not in ${parms} and '${parms['imagetype']}' == 'ImageTypeDocker'  Should Be Equal  ${show[0]['deployment']}  kubernetes
   Run Keyword If  'deployment' not in ${parms} and '${parms['imagetype']}' == 'ImageTypeHelm'    Should Be Equal  ${show[0]['deployment']}  helm
   Run Keyword If  'deployment' not in ${parms} and '${parms['imagetype']}' == 'ImageTypeQcow'    Should Be Equal  ${show[0]['deployment']}  vm
 

   Run Keyword If  'accesstype' not in ${parms} and '${show[0]['deployment']}' == 'kubernetes'  Should Be Equal As Integers  ${show[0]['access_type']}  2
   Run Keyword If  'accesstype' not in ${parms} and '${show[0]['deployment']}' == 'helm'        Should Be Equal As Integers  ${show[0]['access_type']}  2
   Run Keyword If  'accesstype' not in ${parms} and '${show[0]['deployment']}' == 'vm'          Should Be Equal As Integers  ${show[0]['access_type']}  1
   Run Keyword If  'accesstype' not in ${parms} and '${show[0]['deployment']}' == 'docker'      Should Be Equal As Integers  ${show[0]['access_type']}  2

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

   Run Keyword If  'requiredoutboundconnections:0.protocol' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][0]['protocol']}  ${parms['requiredoutboundconnections:0.protocol']}
   Run Keyword If  'requiredoutboundconnections:0.remoteip' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][0]['remote_ip']}  ${parms['requiredoutboundconnections:0.remoteip']}
   Run Keyword If  'requiredoutboundconnections:0.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:0.protocol']}' == 'icmp'  Should Not Contain  ${show[0]['required_outbound_connections'][0]}  port
   Run Keyword If  'requiredoutboundconnections:0.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:0.protocol']}' != 'icmp'  Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][0]['port']}  ${parms['requiredoutboundconnections:0.port']}
   Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][1]['protocol']}  ${parms['requiredoutboundconnections:1.protocol']}
   Run Keyword If  'requiredoutboundconnections:1.remoteip' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][1]['remote_ip']}  ${parms['requiredoutboundconnections:1.remoteip']}
   Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:1.protocol']}' == 'icmp'  Should Not Contain  ${show[0]['required_outbound_connections'][1]}  port
   Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:1.protocol']}' != 'icmp'  Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][1]['port']}  ${parms['requiredoutboundconnections:1.port']}

Update Setup
   ${app_name}=  Get Default App Name
   ${app_name_k8s}=  Set Variable  ${app_name}_k8s
   ${app_name_docker}=  Set Variable  ${app_name}_docker
   ${app_name_helm}=  Set Variable  ${app_name}_helm
   ${app_name_vm}=  Set Variable  ${app_name}_vm

   Set Suite Variable  ${app_name_k8s}
   Set Suite Variable  ${app_name_docker}
   Set Suite Variable  ${app_name_vm}
   Set Suite Variable  ${app_name_helm}

   Run mcctl  region CreateApp region=${region} appname=${app_name_k8s} app-org=${developer} appvers=1.0 imagetype=ImageTypeDocker deployment=kubernetes imagepath=${docker_image}  version=${version}
   Run mcctl  region CreateApp region=${region} appname=${app_name_docker} app-org=${developer} appvers=1.0 imagetype=ImageTypeDocker deployment=docker imagepath=${docker_image}  version=${version}
   Run mcctl  region CreateApp region=${region} appname=${app_name_helm} app-org=${developer} appvers=1.0 imagetype=ImageTypeHelm deployment=helm imagepath=${docker_image}  version=${version}
   Run mcctl  region CreateApp region=${region} appname=${app_name_vm} app-org=${developer} appvers=1.0 imagetype=ImageTypeQcow deployment=vm imagepath=${qcow_centos_image}  version=${version}

Update Teardown
   Run mcctl  region DeleteApp region=${region} appname=${app_name_k8s} app-org=${developer} appvers=1.0  version=${version}
   Run mcctl  region DeleteApp region=${region} appname=${app_name_docker} app-org=${developer} appvers=1.0  version=${version}
   Run mcctl  region DeleteApp region=${region} appname=${app_name_helm} app-org=${developer} appvers=1.0  version=${version}
   Run mcctl  region DeleteApp region=${region} appname=${app_name_vm} app-org=${developer} appvers=1.0  version=${version}

Success Update/Show App Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  region UpdateApp region=${region} ${parmss}  version=${version}
   ${show}=  Run mcctl  region ShowApp region=${region} ${parmss}  version=${version}

   #Verify Show  show=${show}  &{parms}
   Should Be Equal  ${show[0]['key']['name']}  ${parms['appname']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['app-org']}
   Should Be Equal  ${show[0]['key']['version']}  ${parms['appvers']}

   Run Keyword If  'imagepath' in ${parms}  Should Be Equal  ${show[0]['image_path']}  ${parms['imagepath']} 

   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDirect'  Should Be Equal As Numbers  ${show[0]['access_type']}  1
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeLoadBalancer'  Should Be Equal As Numbers  ${show[0]['access_type']}  2
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDefaultForDeployment'  Run Keyword If  '${show[0]['deployment']}' == 'docker'  Should Be Equal As Numbers  ${show[0]['access_type']}  2
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDefaultForDeployment'  Run Keyword If  '${show[0]['deployment']}' == 'kubernetes'  Should Be Equal As Numbers  ${show[0]['access_type']}  2
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDefaultForDeployment'  Run Keyword If  '${show[0]['deployment']}' == 'helm'  Should Be Equal As Numbers  ${show[0]['access_type']}  2
   Run Keyword If  'accesstype' in ${parms}  Run Keyword If  '${parms['accesstype']}' == 'AccessTypeDefaultForDeployment'  Run Keyword If  '${show[0]['deployment']}' == 'vm'  Should Be Equal As Numbers  ${show[0]['access_type']}  1

   Run Keyword If  'imagetype' in ${parms}  Run Keyword If  '${parms['imagetype']}' == 'ImageTypeDocker'  Should Be Equal As Integers  ${show[0]['image_type']}  1
   Run Keyword If  'imagetype' in ${parms}  Run Keyword If  '${parms['imagetype']}' == 'ImageTypeQcow'  Should Be Equal As Integers  ${show[0]['image_type']}  2
   Run Keyword If  'imagetype' in ${parms}  Run Keyword If  '${parms['imagetype']}' == 'ImageTypeHelm'  Should Be Equal As Integers  ${show[0]['image_type']}  3

   Run Keyword If  'trusted' in ${parms}  Run Keyword If  ${parms['trusted']} == ${True}  Should Be Equal  ${show[0]['trusted']}  ${True}
   ...  ELSE  Should Not Contain  ${show[0]}  trusted
   Run Keyword If  'trusted' in ${parms}  Run Keyword If  ${parms['trusted']} == ${False}  Should Not Contain  ${show[0]}  trusted

   Run Keyword If  'requiredoutboundconnections:0.protocol' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][0]['protocol']}  ${parms['requiredoutboundconnections:0.protocol']}
   Run Keyword If  'requiredoutboundconnections:0.remoteip' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][0]['remote_ip']}  ${parms['requiredoutboundconnections:0.remoteip']}
   Run Keyword If  'requiredoutboundconnections:0.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:0.protocol']}' == 'icmp'  Should Not Contain  ${show[0]['required_outbound_connections'][0]}  port
   Run Keyword If  'requiredoutboundconnections:0.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:0.protocol']}' != 'icmp'  Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][0]['port']}  ${parms['requiredoutboundconnections:0.port']}
   Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][1]['protocol']}  ${parms['requiredoutboundconnections:1.protocol']}
   Run Keyword If  'requiredoutboundconnections:1.remoteip' in ${parms}  Should Contain  ${show[0]['required_outbound_connections'][1]['remote_ip']}  ${parms['requiredoutboundconnections:1.remoteip']}
   Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:1.protocol']}' == 'icmp'  Should Not Contain  ${show[0]['required_outbound_connections'][1]}  port
   Run Keyword If  'requiredoutboundconnections:1.protocol' in ${parms}  Run Keyword If  '${parms['requiredoutboundconnections:1.protocol']}' != 'icmp'  Should Be Equal As Numbers  ${show[0]['required_outbound_connections'][1]['port']}  ${parms['requiredoutboundconnections:1.port']}

Fail Create App Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  region CreateApp region=${region} ${parmss}  version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
