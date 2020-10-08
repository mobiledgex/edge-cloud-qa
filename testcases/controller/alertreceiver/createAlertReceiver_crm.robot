*** Settings ***
Documentation  CreatePrivacyPolicy

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}  auto_login=${False}
Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library  MexApp
Library  String

Test Setup  Setup
#Test Teardown  Cleanup Provisioning

Test Timeout  15m

*** Variables ***
${username}=  qaadmin
${password}=  mexadminfastedgecloudinfra
${email}=  mxdmnqa@gmail.com

${region}=  EU
${app_name}=  app1601997927-351176 
${app_version}=  1.0

${developer}=  MobiledgeX

${latitude}       32.7767
${longitude}      -96.7970

${email_wait}=  600

*** Test Cases ***
AlertReceiver - shall be able to create/receive alerts with docker/dedicated/loadbalancer
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

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
#   Stop TCP Port  cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  2015

   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name} 

   Alert Receiver Email For Firing AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   Start TCP Port  host=${fqdn_0}  port=${cloudlet['ports'][0]['internal_port']}  server_port=${cloudlet['ports'][1]['public_port']}
#   Start TCP Port  host=cluster1601997927-351176.automationfrankfurtcloudlet.tdg.mobiledgex.net  port=2015  server_port=4015

   Alert Receiver Email For Resolved AppInstDown Should Be Received  email_password=${password}  email_address=${email}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer}  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  wait=${email_wait}
   Show Alerts  region=${region}
   # add checks for alerts once filter bug is fixed

   # add alert silence after EDGECLOUD-3461 is fixed

AlertReceiver - shall be able to create/receive alerts with docker/shared/loadbalancer
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

AlertReceiver - shall be able to create/receive alerts with docker/dedicated/loadbalancer and multiple receivers
   [Documentation]
   ...  - create alert reciever with appname and apporg
   ...  - create docker/dedicated/loadbalancer appinst
   ...  - stop the port on the app
   ...  - verify AppInstDown firing alert and email are generated
   ...  - start the port on the app
   ...  - verify AppInstDown resolve alert and email are generated

   ${recv_name}=  Get Default Alert Receiver Name

   Create Alert Receiver  app_name=${app_name}  developer_org_name=${developer}
   Create Alert Receiver  receiver_name=${recv_name}_1  developer_org_name=${developer}

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated
   Log To Console  Done Creating Cluster Instance

   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

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

*** Keywords ***
Setup
   Login  username=${username}  password=${password} 
   Create Flavor  region=${region}

   ${flavor_name}=  Get Default Flavor Name

   ${app_name}=  Get Default App Name
   ${app_version}=  Get Default App Version
#   ${app_org}=  Get Default Developer Organization Name
   ${cluster_name}=  Get Default Cluster Name

   Set Suite Variable  ${flavor_name}
   Set Suite Variable  ${app_name}
   Set Suite Variable  ${app_version}
#   Set Suite Variable  ${app_org}

   Set Suite Variable  ${cluster_name}


