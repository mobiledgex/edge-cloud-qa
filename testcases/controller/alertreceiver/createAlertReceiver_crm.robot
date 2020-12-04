*** Settings ***
Documentation  CreateAlertReceiver on CRM

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}  auto_login=${False}
Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library  MexOpenstack  environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexApp
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  25m

*** Variables ***
${username}=  qaadmin
${password}=  mexadminfastedgecloudinfra
${mexadmin_password}=  mexadminfastedgecloudinfra
${email}=  mxdmnqa@gmail.com

${user_username}=  mextester06
${user_password}=  mextester06123mobiledgexisbadass

${slack_channel}=  channel
${slack_api_url}=  api

${region}=  EU
${app_name}=  app1601997927-351176 
${app_version}=  1.0

${developer}=  MobiledgeX

${latitude}       32.7767
${longitude}      -96.7970

${email_wait}=  300
${email_not_wait}=  30

*** Test Cases ***
AlertReceiver - shall be able to create/receive appname/apporg HealthCheckFailServerFail email alerts with docker/dedicated/loadbalancer
   [Documentation]
   ...  - create alert reciever with appname and apporg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

#   ${a}=  Show Alerts  region=${region}  app_name=automation-sdk-porttest2  app_version=1.0  developer_org_name=MobiledgeX  port=2016
#   log to console  ${a[0]['data']['labels']['app']}
#   XXXXX
   Create Alert Receiver  app_name=${app_name}  type=email  developer_org_name=${developer}  

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name} 

   Alert Receiver Email For Firing AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   ${alerts1}=  Show Alerts  region=${region}  alert_name=AppInstDown  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}
   Length Should Be  ${alerts1}  1

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][1]['public_port']}

   Alert Receiver Email For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   ${alerts2}=  Show Alerts  region=${region}  alert_name=AppInstDown  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}
   Length Should Be  ${alerts2}  0

   # add checks for alerts once filter bug is fixed EDGECLOUD-3743 ShowAlert does not work with optional args

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive apporg HealthCheckFailServerFail email alerts with docker/shared/loadbalancer
   [Documentation]
   ...  - create docker/shared/loadbalancer appinst
   ...  - create alert reciever with apporg
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessShared
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Create Alert Receiver  type=email  developer_org_name=${developer}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   ${alerts1}=  Show Alerts  region=${region}  alert_name=AppInstDown  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}
   Length Should Be  ${alerts1}  1

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}

   Alert Receiver Email For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Show Alerts  region=${region}

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive appname/apporg/appversion/appcloudlet/appcloudletorg HealthCheckFailRootlbOffline email alerts with docker/dedicated/loadbalancer
   [Documentation]
   ...  - create alert reciever with appname/apporg/appversion/appcloudlet/appcloudletorg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the docker container
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   Create Alert Receiver  app_name=${app_name}  app_version=1.0  developer_org_name=${developer}  app_cloudlet_name=${cloudlet_name_openstack_dedicated}  app_cloudlet_org=${operator_name_openstack}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   ${clusterlb}=  Convert To Lowercase  ${cluster_name}.${cloudlet_name_openstack_dedicated}.${operator_name_openstack}.mobiledgex.net
   Stop Docker Container Rootlb   root_loadbalancer=${clusterlb}

   Wait For App Instance Health Check Rootlb Offline  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown HealthCheckFailRootlbOffline Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start Docker Container Rootlb   root_loadbalancer=${clusterlb}

   Alert Receiver Email For Resolved AppInstDown HealthCheckFailRootlbOffline Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive cloudletorg HealthCheckFailServerFail email alerts with vm/shared/loadbalancer
   [Documentation]
   ...  - create vm/shared/loadbalancer appinst
   ...  - create alert reciever with cloudletorg
   ...  - power off the VM
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   Create Flavor  region=${region}  flavor_name=${flavor_name}vm  disk=80
   ${app}=  Create App  region=${region}  image_path=${qcow_centos_image}  access_ports=tcp:2015,tcp:2016  image_type=ImageTypeQCOW  deployment=vm  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Create Alert Receiver  operator_org_name=${operator_name_openstack}

   Update App Instance  region=${region}  powerstate=PowerOff

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Update App Instance  region=${region}  powerstate=PowerOn

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Alert Receiver Email For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email/slack region HealthCheckFailRootlbOffline alerts with vm/shared/loadbalancer
   [Documentation]
   ...  - create vm/shared/loadbalancer appinst
   ...  - create alert reciever with region 
   ...  - power off the VM
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   Create Flavor  region=${region}  flavor_name=${flavor_name}vm  disk=80
   Create Flavor  region=${region_packet}  flavor_name=${flavor_name}vm  disk=80

   ${app}=  Create App  region=${region}  image_path=${qcow_centos_image}  access_ports=tcp:2015,tcp:2016  image_type=ImageTypeQCOW  deployment=vm  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}
   ${app2}=  Create App  region=${region_packet}  image_path=${qcow_centos_image}  access_ports=tcp:2015,tcp:2016  image_type=ImageTypeQCOW  deployment=vm  access_type=loadbalancer
   Create App Instance  region=${region_packet}  cloudlet_name=${cloudlet_name_openstack_packet}  operator_org_name=${operator_name_openstack_packet}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Wait For App Instance Health Check OK  region=${region_packet}  app_name=${app_name}

   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_openstack}  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Create Alert Receiver  region=${region}  cluster_instance_developer_org_name=${developer}
   Create Alert Receiver  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error  region=${region}  cluster_instance_developer_org_name=${developer}

   ${clusterlb}=  Convert To Lowercase  ${developer}${app['data']['key']['name']}10.${cloudlet_name_openstack_dedicated}.${operator_name_openstack}.mobiledgex.net
   Stop Docker Container Rootlb   root_loadbalancer=${clusterlb}

   Wait For App Instance Health Check Rootlb Offline  region=${region}  app_name=${app_name}

   # verify alerts received for EU region app
   Alert Receiver Email For Firing AppInstDown HealthCheckFailRootlbOffline Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_wait}
   Alert Receiver Slack Message For Firing AppInstDown HealthCheckFailRootlbOffline Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # verify alerts NOT received for US region app
   Alert Receiver Email For Firing AppInstDown HealthCheckFailRootlbOffline Should Not Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region_packet}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_not_wait}
   Alert Receiver Slack Message For Firing AppInstDown HealthCheckFailRootlbOffline Should Not Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region_packet}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_not_wait}

   Start Docker Container Rootlb   root_loadbalancer=${clusterlb}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   # verify alerts received for EU region app
   Alert Receiver Email For Resolved AppInstDown HealthCheckFailRootlbOffline Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_wait}
   Alert Receiver Slack Message For Resolved AppInstDown HealthCheckFailRootlbOffline Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # verify alerts NOT received for US region app
   Alert Receiver Email For Resolved AppInstDown HealthCheckFailRootlbOffline Should Not Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region_packet}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_not_wait}
   Alert Receiver Slack Message For Resolved AppInstDown HealthCheckFailRootlbOffline Should Not Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region_packet}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  wait=${email_not_wait}

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive clusterorg HealthCheckFailServerFail slack alerts with k8s/shared/loadbalancer
   [Documentation]
   ...  - create k8s/shared/loadbalancer appinst
   ...  - create alert reciever with clusterorg
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   ${orgname}=  Create Org  orgtype=developer

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared  developer_org_name=${orgname}
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  developer_org_name=${orgname}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016,tcp:4015  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Create App Instance  region=${region}  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}  developer_org_name=${orgname}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}  tls=${True}

   Create Alert Receiver  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error  cluster_instance_developer_org_name=${orgname}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}  tls:${True}

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Slack Message For Firing AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}

   Alert Receiver Slack Message For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email/slack cluster/clusterorg HealthCheckFailServerFail alerts with docker/dedicated/loadbalancer and multiple receivers
   [Documentation]
   ...  - create a new user
   ...  - create alert reciever with clustername and clusterorg for email and slack
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email/slack are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email/slack are generated

   #EDGECLOUD-4022  alertreceiver - user unable to see cluster receivers created by them

   ${super_token}=  Login  username=mexadmin  password=${mexadmin_password}

   # create a new user
   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername}   password=${user_password}   email_address=${emailepoch}
   # Verify Email  email_address=${emailepoch}
   Unlock User  token=${super_token}  username=${epochusername}
   ${user_token}=  Login  username=${epochusername}  password=${user_password}
   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   # create an alert as mexadmin which has a bogus email
   Create Alert Receiver  token=${super_token}  type=email  severity=info  app_name=${app_name}  developer_org_name=${orgname}

   # create email and slack alert as the new user
   Create Alert Receiver  token=${user_token}  receiver_name=${recv_name}_1  type=email  severity=info  email_address=${email}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}
   Create Alert Receiver  token=${user_token}  receiver_name=${recv_name}_2  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  token=${user_token}  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  token=${user_token}  developer_org_name=${orgname}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  token=${user_token}  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}  developer_org_name=${orgname}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}_1  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Alert Receiver Slack Message For Firing AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}_2  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}

   Alert Receiver Email For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}_1  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Alert Receiver Slack Message For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}_2  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive appname/apporg alerts with docker/dedicated/loadbalancer installed with bad port
   [Documentation]
   ...  - create alert reciever with appname and apporg
   ...  - create docker/dedicated/loadbalancer appinst with bad port
   ...  - verify AppInstDown firing alert and email are generated

   Create Alert Receiver  app_name=${app_name}  developer_org_name=${developer}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015,tcp:2000  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=2000  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

AlertReceiver - shall be able to create/receive cloudletname/cloudletorg slack alerts with docker/dedicated/loadbalancer
   [Documentation]
   ...  - create slack alert reciever with cloudletname and cloudletorg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and slack are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and slack are generated

   Create Alert Receiver  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Slack Message For Firing AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}


   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][1]['public_port']}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Alert Receiver Slack Message For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email alerts with email parm and k8s/shared/loadbalancer
   [Documentation]
   ...  - create k8s/shared/loadbalancer appinst
   ...  - create alert reciever with a different email address than the default
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   # do everything as mexadmin with a fake email address
   Login  username=mexadmin  password=${mexadmin_password}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016,tcp:4015  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}  tls=${True}

   # create receiver with good email address thus overriding the mexadmin address
   Create Alert Receiver  type=email  severity=error  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}  tls:${True}

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}

   Alert Receiver Email For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet['ports'][0]['internal_port']}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email/slack alerts for 2 apps on same cluster with docker/shared/loadbalancer
   [Documentation]
   ...  - create 2 docker/shared/loadbalancer appinsts
   ...  - create alert reciever with apporg
   ...  - stop the port on both apps
   ...  - verify AppInstDown firing alert and email/slack are generated
   ...  - start the port on both apps
   ...  - verify AppInstDown resolve alert and email/slack are generated

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessShared
   Log To Console  Done Creating Cluster Instance

   Create App  region=${region}  app_version=1.0  image_path=${docker_image}  access_ports=tcp:2015,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App  region=${region}  app_version=2.0  image_path=${docker_image}  access_ports=tcp:2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer

   Create App Instance  region=${region}  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}
   Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}  app_version=1.0
   Register Client  app_name=${app_name}  app_version=1.0
   ${cloudlet_0}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet_0['ports'][0]['fqdn_prefix']}  ${cloudlet_0['fqdn']}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}  app_version=2.0
   Register Client  app_name=${app_name}  app_version=2.0
   ${cloudlet_1}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet_1['ports'][0]['fqdn_prefix']}  ${cloudlet_1['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet_0['ports'][0]['public_port']}
   TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet_1['ports'][0]['public_port']}

   Create Alert Receiver  type=email  developer_org_name=${developer}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}
   Create Alert Receiver  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  developer_org_name=${developer}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}

   Stop TCP Port  ${fqdn_0}  ${cloudlet_0['ports'][0]['public_port']}
   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}  app_version=1.0
   Alert Receiver Email For Firing AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet_0['ports'][0]['internal_port']}  wait=${email_wait}
   Alert Receiver Slack Message For Firing AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet_0['ports'][0]['internal_port']}  wait=${email_wait}

   Stop TCP Port  ${fqdn_1}  ${cloudlet_1['ports'][0]['public_port']}
   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}  app_version=2.0
   Alert Receiver Email For Firing AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=2.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet_1['ports'][0]['internal_port']}   wait=${email_wait}
   Alert Receiver Slack Message For Firing AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=2.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet_1['ports'][0]['internal_port']}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet_0['ports'][0]['internal_port']}  server_port=${cloudlet_0['ports'][1]['public_port']}
   Alert Receiver Email For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet_0['ports'][0]['internal_port']}  wait=${email_wait}
   Alert Receiver Slack Message For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet_0['ports'][0]['internal_port']}  wait=${email_wait}

   Start TCP Port  host=${fqdn_1}  port=${cloudlet_1['ports'][0]['internal_port']}  server_port=${cloudlet_1['ports'][1]['public_port']}
   Alert Receiver Email For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=2.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet_1['ports'][0]['internal_port']}  wait=${email_wait}
   Alert Receiver Slack Message For Resolved AppInstDown HealthCheckFailServerFail Should Be Received  alert_receiver_name=${recv_name}  app_name=${app_name}  app_version=2.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer}  port=${cloudlet_1['ports'][0]['internal_port']}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive cloudletorg CloudletDown email/slack alerts
   [Documentation]
   ...  - create alert reciever with cloudletorg
   ...  - stop the crm docker container
   ...  - verify AppInstDown firing alert and email/slack are generated
   ...  - start the crm docker container
   ...  - verify AppInstDown resolve alert and email/slack are generated

   [Teardown]  Teardown CloudletDown

   Create Alert Receiver  type=email  operator_org_name=${operator_name_openstack}
   Create Alert Receiver  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  operator_org_name=${operator_name_openstack}

   ${crm_show}=  Get Server Show  ${cloudlet_name_openstack_dedicated}-${operator_name_openstack}-pf
   @{crm_split}=  Split String  ${crm_show['addresses']}  separator==
   Stop CRM Docker Container  ${crm_split[1]}

   Alert Receiver Email For Firing CloudletDown Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start CRM Docker Container  ${crm_split[1]}

   Alert Receiver Email For Resolved CloudletDown Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive cloudletname/cloudletorg CloudletDown email/slack alerts
   [Documentation]
   ...  - create alert reciever with cloudletname/cloudletorg
   ...  - stop the crm docker container
   ...  - verify AppInstDown firing alert and email/slack are generated
   ...  - start the crm docker container
   ...  - verify AppInstDown resolve alert and email/slack are generated

   Create Alert Receiver  type=email  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}
   Create Alert Receiver  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}

   ${crm_show}=  Get Server Show  ${cloudlet_name_openstack_dedicated}-${operator_name_openstack}-pf
   @{crm_split}=  Split String  ${crm_show['addresses']}  separator==

   #[Teardown]  Teardown CloudletDown  ${crm_split[1]}

   Stop CRM Docker Container  ${crm_split[1]}

   Alert Receiver Slack Message For Firing CloudletDown Should Be Received  alert_receiver_name=${recv_name}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Alert Receiver Email For Firing CloudletDown Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start CRM Docker Container  ${crm_split[1]}

   Alert Receiver Email For Resolved CloudletDown Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Alert Receiver Slack Message For Resolved CloudletDown Should Be Received  alert_receiver_name=${recv_name}  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${user_username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${user_username}  ${epoch}

   Login  username=${username}  password=${password} 
   Create Flavor  region=${region}

   ${flavor_name}=  Get Default Flavor Name

   ${app_name}=  Get Default App Name
   ${app_version}=  Get Default App Version
#   ${app_org}=  Get Default Developer Organization Name
   ${cluster_name}=  Get Default Cluster Name
   ${recv_name}=  Get Default Alert Receiver Name

   Set Suite Variable  ${flavor_name}
   Set Suite Variable  ${app_name}
   Set Suite Variable  ${app_version}
#   Set Suite Variable  ${app_org}
   Set Suite Variable  ${recv_name}
   Set Suite Variable  ${cluster_name}
   Set Suite Variable  ${emailepoch}
   Set Suite Variable  ${epoch}
   Set Suite Variable  ${epochusername}

Teardown CloudletDown
   [Arguments]  ${crmip}
   Start CRM Docker Container  ${crm_split[1]}
   Cleanup Provisioning 
