*** Settings ***
Documentation  CreateAlertReceiver on CRM

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}  auto_login=${False}
Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library  MexApp
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  15m

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

*** Test Cases ***
AlertReceiver - shall be able to create/receive email alerts with docker/dedicated/loadbalancer
   [Documentation]
   ...  - create alert reciever with appname and apporg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   Create Alert Receiver  app_name=${app_name}  type=email  developer_org_name=${developer}  

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
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

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][1]['public_port']}

   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email alerts with docker/shared/loadbalancer
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

   Create Alert Receiver  developer_org_name=${developer}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
#   Stop TCP Port  cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  2015

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}
#   Start TCP Port  host=cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  port=2015  server_port=4015

   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive HealthCheckFailRootlbOffline alerts with docker/dedicated/loadbalancer
   [Documentation]
   ...  - create alert reciever with appname and apporg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   Create Alert Receiver  app_name=${app_name}  developer_org_name=${developer}

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

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  status=1  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start Docker Container Rootlb   root_loadbalancer=${clusterlb}

   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  status=1  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive HealthCheckFailServerFail alerts with vm/shared/loadbalancer
   [Documentation]
   ...  - create docker/shared/loadbalancer appinst
   ...  - create alert reciever with apporg
   ...  - stop the port on the app
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

   Create Alert Receiver  developer_org_name=${developer}

#   ${cluster_name}=  Set Variable  cluster1602098261-390385 
#   ${app_name}=  Set Variable  app1602098261-390385 
#   ${app_org}=  Set Variable  MobiledgeX
#   ${rootlb}=  Convert To Lowercase  ${cluster_name}.${cloudlet_name_openstack_dedicated}.${operator_name_openstack}.mobiledgex.net
#   Update App Instance  app_name=${app_name}  app_version=${app_version}  developer_org_name=${app_org}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${app_org}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  region=${region}  powerstate=PowerOff  #use_defaults=${False}
   Update App Instance  region=${region}  powerstate=PowerOff

#   Stop Docker Container Rootlb   root_loadbalancer=${rootlb}

#   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
#   Stop TCP Port  cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  2015

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   #Update App Instance  app_name=${app_name}  app_version=${app_version}  developer_org_name=${app_org}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${app_org}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  region=${region}  powerstate=PowerOn  #use_defaults=${False}
   Update App Instance  region=${region}  powerstate=PowerOn

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

#   Start Docker Container Rootlb   root_loadbalancer=${rootlb}

#   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}
#   Start TCP Port  host=cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  port=2015  server_port=4015

   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive alerts with k8s/shared/loadbalancer
   [Documentation]
   ...  - create k8s/shared/loadbalancer appinst
   ...  - create alert reciever with apporg
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

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

   Create Alert Receiver  type=email  severity=error  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}  tls:${True}
#   Stop TCP Port  cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  2015

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}
#   Start TCP Port  host=cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  port=2015  server_port=4015

   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email/slack alerts with docker/dedicated/loadbalancer and multiple receivers
   [Documentation]
   ...  - create alert reciever with appname and apporg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

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
   Create Alert Receiver  token=${user_token}  receiver_name=${recv_name}_1  type=email  severity=info  email_address=${email}  app_name=${app_name}  developer_org_name=${orgname}
   Create Alert Receiver  token=${user_token}  receiver_name=${recv_name}_2  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  developer_org_name=${orgname}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  token=${user_token}  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  token=${user_token}  developer_org_name=${orgname}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  token=${user_token}  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}  developer_org_name=${orgname}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
#   Stop TCP Port  cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  2015

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Alert Receiver Slack Message For Firing AppInstDown Should Be Received  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}
#   Start TCP Port  host=cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  port=2015  server_port=4015

   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Alert Receiver Slack Message For Resolved AppInstDown Should Be Received  app_name=${app_name}  app_version=${app_version}  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive alerts with docker/dedicated/loadbalancer installed with bad port
   [Documentation]
   ...  - create alert reciever with appname and apporg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   Create Alert Receiver  app_name=${app_name}  developer_org_name=${developer}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015,tcp:2000  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  status=2  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

AlertReceiver - shall be able to create/receive slack alerts with docker/dedicated/loadbalancer
   [Documentation]
   ...  - create alert reciever with appname and apporg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   Create Alert Receiver  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  app_name=${app_name}  developer_org_name=${developer}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
#   Stop TCP Port  cluster1602766801-4264672.automationfrankfurtcloudlet.tdg.mobiledgex.net  2015

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Slack Message For Firing AppInstDown Should Be Received  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
#   Alert Receiver Slack Message For Firing AppInstDown Should Be Received  app_name=app1602766801-4264672  app_version=1.0  developer_org_name=MobiledgeX  region=EU  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][1]['public_port']}
#   Start TCP Port  host=cluster1602766801-4264672.automationfrankfurtcloudlet.tdg.mobiledgex.net  port=2015  server_port=4015

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Alert Receiver Slack Message For Resolved AppInstDown Should Be Received  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
#   Alert Receiver Slack Message For Resolved AppInstDown Should Be Received  app_name=app1602766801-4264672  app_version=1.0  developer_org_name=MobiledgeX  region=EU  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email alerts with email parm and k8s/shared/loadbalancer
   [Documentation]
   ...  - create k8s/shared/loadbalancer appinst
   ...  - create alert reciever with apporg
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   # do everything as mexadmin with as a fake email address
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
#   Stop TCP Port  cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  2015

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][2]['public_port']}
#   Start TCP Port  host=cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  port=2015  server_port=4015

   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email/slack alerts for 2 apps on same cluster with docker/shared/loadbalancer
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
   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Alert Receiver Slack Message For Firing AppInstDown Should Be Received  app_name=${app_name}  app_version=1.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Stop TCP Port  ${fqdn_1}  ${cloudlet_1['ports'][0]['public_port']}
   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}  app_version=2.0
   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=2.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Alert Receiver Slack Message For Firing AppInstDown Should Be Received  app_name=${app_name}  app_version=2.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet_0['ports'][0]['internal_port']}  server_port=${cloudlet_0['ports'][2]['public_port']}
   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Alert Receiver Slack Message For Resolved AppInstDown Should Be Received  app_name=${app_name}  app_version=1.0  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Start TCP Port  host=${fqdn_1}  port=${cloudlet_1['ports'][0]['internal_port']}  server_port=${cloudlet_1['ports'][2]['public_port']}
   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=2.0  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Alert Receiver Slack Message For Resolved AppInstDown Should Be Received  app_name=${app_name}  app_version=2.0  developer_org_name=${orgname}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}

   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive email/slack alerts for 2 apps on same cluster with docker/shared/loadbalancer

CreateAlertReceiver - shall be able to create/receive email/slack autoscale alerts for k8s/dedicated/loadbalancer
   [Documentation]
   ...  create an auto scale policy
   ...  create a cluster instance
   ...  update cluster instance to add the auto scale policy

   #EDGECLOUD-3271 - After cluster instance is created by auto scaling policy , app instances are no longer running
   #${policy_name_default}=  Get Default Autoscale Policy Name
   #${cluster_name_default}=  Get Default Cluster Name
   #${cluster_name_default}=  Catenate  SEPARATOR=  auto  ${cluster_name_default}
   #${app_name_default}=  Get Default App Name

   ${epoch}=  Get Time  epoch

   #${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name_default}  ${rootlb}

   Create Alert Receiver  receiver_name=autoalert ${epoch}1  type=email  developer_org_name=${developer}  app_version=1.1
   Create Alert Receiver  receiver_name=autoalert ${epoch}2  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  developer_org_name=${developer}  app_version=1.1

   ${autoscale_policy}=  Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  autoscale_policy_name=${autoscale_policy['data']['key']['name']}
   Log To Console  Done Creating Cluster Instance

   Create App  region=${region}  app_version=1.1  image_path=${docker_image_cpu}  access_ports=tcp:2017  scale_with_cluster=True
   Create App Instance  region=${region}  app_version=1.1  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}   cluster_instance_name=${cluster_name}  autocluster_ip_access=IpAccessDedicated

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_version=1.1
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

#   ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}

   Set CPU Load  host=${fqdn_0}  port=2017  load_percentage=72
   Sleep  120s

#   FOR  ${x}  IN RANGE  0  30
#       ${server_info_node}=    Get Server List  name=${openstack_node_name}
#       ${num_servers_node}=    Get Length  ${server_info_node}
#       Exit For Loop If  '${num_servers_node}' == '2'
#       Sleep  10s
#   END
#
#   Should Be Equal As Numbers   ${num_servers_node}    2
#
#   FOR  ${x}  IN RANGE  0  40
#       ${clusterInst}=  Show Cluster Instances  region=${region}   cluster_name=${cluster_name_default}  cloudlet_name=${cloudlet_name_openstack_dedicated}
#       Exit For Loop If  '${clusterInst[0]['data']['state']}' == '5'
#       Sleep  10s
#   END
#
#   Should Be Equal As Numbers   ${clusterInst[0]['data']['state']}   5

#   Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=Unset
#   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
#   Register Client
#   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
#   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
#
#   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}

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
   Set Suite Variable  ${epochusername}

