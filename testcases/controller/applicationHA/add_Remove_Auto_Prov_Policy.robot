*** Settings ***
Documentation  Add/Remove Auto Provisioning Policy to App via mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  10m

#ECQ-3137
*** Variables ***
${region}=  US
${developer}=  automation_dev_org
${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml
${server_ping_threaded_cloudconfig}  http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml
${manifest_string}=  apiVersion: v1\nkind: Service\nmetadata:\n  name: server-ping-threaded-udptcphttp-tcpservice\n  labels:\n    run: server-ping-threaded-udptcphttpapp\nspec:\n  type: LoadBalancer\n  ports:\n  - port: 2016\n    targetPort: 2016\n    protocol: TCP\n    name: tcp2016\n  selector:\n    run: server-ping-threaded-udptcphttpapp
${cloudconfig_string}=  \#cloud-config\n users:\n - name: demo\n groups: sudo\n shell: /bin/bash\n sudo: ['ALL=(ALL) NOPASSWD:ALL']\n runcmd:\n - /opt/rh/rh-python36/root/usr/bin/python3 /home/centos/server_ping_threaded.py
${envvars_config}=  - name: CrmValue\n${SPACE*2}value: [[ .Deployment.ClusterIp ]]\n- name: CrmValue2\n${SPACE*2}value: [[ .Deployment.ClusterIp ]]
${envvars_url}=  http://35.199.188.102/apps/server_ping_threaded_config.yml
${default_flavor_name}   automation_api_flavor
${version}=  latest

*** Test Cases ***
Add/RemoveAppAutoProvPolicy - mcctl shall be able to add AutoProvPolicy to App

   [Template]  Add/Remove auto prov. policy to App via mcctl

      app-org=${developer}  appname=${app_name}  appvers=1.0  autoprovpolicy=${autoprov_name}1

Add/RemoveAppAutoProvPolicy - mcctl shall handle create failures

   [Template]   Fail to Add Auto Provisioning Policy Via mcctl
      # missing values
      Error: missing required args:   #not sending any args with mcctl
      Error: missing required args:  app-org=${developer}  #missing args
      Error: missing required args: appname appvers  app-org=${developer}  autoprovpolicy=${autoprov_name}1  #missing args
      Error: missing required args: appname  app-org=${developer}  autoprovpolicy=${autoprov_name}1  appvers=1.0  #missing args
      Error: Bad Request (400), App key {"organization":"${developer}","name":"x","version":"1.0"} not found  app-org=${developer}  appname=x  appvers=1.0  autoprovpolicy=${autoprov_name}1  #invalid appname
      Error: Bad Request (400), Policy key {"organization":"${developer}","name":"x"} not found  app-org=${developer}  appname=${app_name}  appvers=1.0  autoprovpolicy=x  #invalid autoprovpolicy
      #Error: Bad Request (400), App key {"organization":"${developer}"} not found:  Error: Bad Request (400), App key {} not found  #Error: Bad Request (400), App key {"organization":"${developer}"} not found
      #Error: Bad Request (400), App key {"organization":"${developer}"} not found:  Error: Bad Request (400), App key {"organization":"${developer}"} not found  appkey.organization=${developer}  #Error: Bad Request (400), App key {"organization":"${developer}"} not found
      #Error: Bad Request (400), App key {"organization":"${developer}","name":"${app_name}"} not found:  Error: Bad Request (400), App key {"organization":"${developer}","name":"${app_name}"} not found  appkey.organization=${developer}  appkey.name=${app_name}
      #Error: invalid args: app-org:  Error: invalid args: app-org  app-org=${developer}  appkey.name=${app_name}  appkey.version=1.0  autoprovpolicy=${autoprov_name}1
      #Error: invalid args: name:  Error: invalid args: name  appkey.name=${developer}  name=${app_name}  appkey.version=1.0  autoprovpolicy=${autoprov_name}1
      #Error: invalid args: version:  Error: invalid args: version  appkey.name=${developer}  appkey.name=${app_name}  version=1.0  autoprovpolicy=${autoprov_name}1


*** Keywords ***
Setup

   ${app_name}=  Get Default App Name
   ${autoprov_name}=  Get Default Auto Provisioning Policy Name

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${autoprov_name}

   create app  region=${region}  app_name=${app_name}  app_version=1.0  default_flavor_name=${default_flavor_name}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}

   &{cloudlet1}=  create dictionary  name=tmocloud-1  organization=dmuus
   @{cloudletlist}=  create list  ${cloudlet1}
   Create Auto Provisioning Policy  region=${region}  policy_name=${autoprov_name}1  min_active_instances=1  max_instances=2  developer_org_name=${developer}  cloudlet_list=${cloudletlist}

   @{autoprovpolicies}=  Create List  ${autoprov_name}1  ${autoprov_name}2
   Set Suite Variable  @{autoprovpolicies}

Add/Remove auto prov. policy to App via mcctl

   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   run mcctl  region AddAppAutoProvPolicy region=${region} ${parmss}

   run mcctl  region RemoveAppAutoProvPolicy region=${region} ${parmss}

Fail to Add Auto Provisioning Policy Via mcctl

  [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

  ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

  ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  region AddAppAutoProvPolicy region=${region} ${parmss}
  Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}



