*** Settings ***
Documentation  DME Persistent Connection on CRM

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}    #auto_login=${False}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
#Library  MexOpenstack  environment_file=%{AUTOMATION_OPENSTACK_OFFLINE_ENV}
Library  MexApp
Library  String
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  25m

*** Variables ***
${username}=  qaadmin
${password}=  zudfgojfrdhqntzm
${mexadmin_password}=  mexadminfastedgecloudinfra
${email}=  mxdmnqa@gmail.com

${cloudlet_name_offline}=  automationBuckhornCloudlet
${cloudlet_name_2}=  automationBeaconCloudlet

#${user_username}=  mextester06
#${user_password}=  mextester06123mobiledgexisbadass
#
#${slack_channel}=  channel
#${slack_api_url}=  api

${region}=  EU
${app_name}=  app1601997927-351176
${app_version}=  1.0

${developer}=  ${developer_org_name_automation}

${latitude}       32.7767
${longitude}      -96.7970

#${email_wait}=  300
#${email_not_wait}=  30

*** Test Cases ***
# ECQ-3407
DMEPersistentConnection - shall be able to receive appinst health events
   [Documentation]
   ...  - create 2 clusterinsts
   ...  - create 1 appinst
   ...  - register client and findcloudlet
   ...  - create DME persist connection
   ...  - stop TCP port to create health check fail
   ...  - receive the Health Check Server Fail Event with error
   ...  - start the port back to clear the error
   ...  - receive the Health Check OK Event
   ...  - create 2nd app inst
   ...  - stop TCP port to create health check fail
   ...  - receive the Health Check Server Fail Event with new cloudlet
   ...  - start the port back to clear the error
   ...  - receive the Health Check OK Event
   ...  - stop rootlb to create health check fail
   ...  - receive the Health Check Server Fail Event with new cloudlet
   ...  - start rootlb back to clear the error
   ...  - receive the Health Check OK Event
   ...  - delete appinst to create health check fail
   ...  - receive the Health Check Server Fail Event with new cloudlet
   ...  - create persist connection to new cloudlet

   [Tags]  DMEPersistentConnection

   # create 2 clusterinsts
   Log To Console  Creating Cluster Instance
   ${handle1}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated  use_thread=${True}
   ${handle2}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name}2  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated  use_thread=${True}
   Wait For Replies  ${handle1}  ${handle2}
   Log To Console  Done Creating Cluster Instance

   # create 1 appinst
   ${app}=  Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016,tcp:4015  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  auto_delete=${False}
   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   # register client and findcloudlet
#   ${app_name}=  Set Variable  app1621381025-470966
   Register Client  app_name=${app_name}
   ${cloudlet}=  Find Cloudlet  carrier_name=GDDT  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}

   # create DME persist connection
   Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

   # stop TCP port to create health check fail
   Stop TCP Port  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   # receive the Health Check Server Fail Event with error
   ${finderror}=  Run Keyword and Expect Error  *  Receive Appinst Health Check Server Fail Event
   Should Be Equal  ${finderror}  Current appinst is unusable, but unable to find any cloudlets - FindStatus is FIND_NOTFOUND

   # start the port back to clear the error
   Start TCP Port  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   Wait For App Instance Health Check Ok  region=${region}  app_name=${app_name}

   # receive the Health Check OK Event
   Receive Appinst Health Check OK Event
  
   # create 2nd app inst 
   ${appinst2}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}2

   # stop TCP port to create health check fail
   Stop TCP Port  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   Wait For App Instance Health Check Server Fail  region=${region}  app_name=${app_name}

   # receive the Health Check Server Fail Event with new cloudlet
   log to console  waiting for event
   ${new_cloudlet}=  Receive Appinst Health Check Server Fail Event
   log to console  ${new_cloudlet.fqdn}
   Should Be Equal As Numbers  ${new_cloudlet.status}  1  #FIND_FOUND
   Should Be Equal             ${new_cloudlet.fqdn}  ${appinst2['data']['uri']}
   Should Be Equal As Numbers  ${new_cloudlet.cloudlet_location.latitude}   ${appinst2['data']['cloudlet_loc']['latitude']}
   Should Be Equal As Numbers  ${new_cloudlet.cloudlet_location.longitude}  ${appinst2['data']['cloudlet_loc']['longitude']}
   Should Be Equal As Numbers  ${new_cloudlet.ports[0].proto}  ${appinst2['data']['mapped_ports'][0]['proto']}  #LProtoTCP
   Should Be Equal As Numbers  ${new_cloudlet.ports[0].internal_port}  ${appinst2['data']['mapped_ports'][0]['internal_port']}
   Should Be Equal As Numbers  ${new_cloudlet.ports[0].public_port}  ${appinst2['data']['mapped_ports'][0]['public_port']}
   Should Be Equal As Numbers  ${new_cloudlet.ports[1].proto}  ${appinst2['data']['mapped_ports'][1]['proto']}  #LProtoTCP
   Should Be Equal As Numbers  ${new_cloudlet.ports[1].internal_port}  ${appinst2['data']['mapped_ports'][1]['internal_port']}
   Should Be Equal As Numbers  ${new_cloudlet.ports[1].public_port}  ${appinst2['data']['mapped_ports'][1]['public_port']}
   Should Be True  len('${new_cloudlet.edge_events_cookie}') > 100

   # start the port back to clear the error
   Start TCP Port  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   Wait For App Instance Health Check Ok  region=${region}  app_name=${app_name}

   # receive the Health Check OK Event
   Receive Appinst Health Check OK Event

   # stop rootlb to create health check fail
   ${clusterlb}=  Convert To Lowercase  ${cluster_name}.${cloudlet_name_openstack_dedicated}.${operator_name_openstack}.mobiledgex.net
   Stop Docker Container Rootlb   root_loadbalancer=${clusterlb}

   # receive the Health Check Server Fail Event with new cloudlet
   ${new_cloudlet1}=  Receive Appinst Health Check Rootlb Offline Event
   log to console  ${new_cloudlet1.fqdn}
   Should Be Equal As Numbers  ${new_cloudlet1.status}  1  #FIND_FOUND
   Should Be Equal             ${new_cloudlet1.fqdn}  ${appinst2['data']['uri']}
   Should Be Equal As Numbers  ${new_cloudlet1.cloudlet_location.latitude}   ${appinst2['data']['cloudlet_loc']['latitude']}
   Should Be Equal As Numbers  ${new_cloudlet1.cloudlet_location.longitude}  ${appinst2['data']['cloudlet_loc']['longitude']}
   Should Be Equal As Numbers  ${new_cloudlet1.ports[0].proto}  ${appinst2['data']['mapped_ports'][0]['proto']}  #LProtoTCP
   Should Be Equal As Numbers  ${new_cloudlet1.ports[0].internal_port}  ${appinst2['data']['mapped_ports'][0]['internal_port']}
   Should Be Equal As Numbers  ${new_cloudlet1.ports[0].public_port}  ${appinst2['data']['mapped_ports'][0]['public_port']}
   Should Be Equal As Numbers  ${new_cloudlet1.ports[1].proto}  ${appinst2['data']['mapped_ports'][1]['proto']}  #LProtoTCP
   Should Be Equal As Numbers  ${new_cloudlet1.ports[1].internal_port}  ${appinst2['data']['mapped_ports'][1]['internal_port']}
   Should Be Equal As Numbers  ${new_cloudlet1.ports[1].public_port}  ${appinst2['data']['mapped_ports'][1]['public_port']}
   Should Be True  len('${new_cloudlet1.edge_events_cookie}') > 100
   Should Not Be Equal  ${new_cloudlet.edge_events_cookie}  ${new_cloudlet1.edge_events_cookie}

   # start rootlb back to clear the error
   Start Docker Container Rootlb   root_loadbalancer=${clusterlb}

   # receive the Health Check OK Event
   Receive Appinst Health Check OK Event

   # delete appinst to create health check fail
   Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}

   # receive the Health Check Server Fail Event with new cloudlet
   ${new_cloudlet2}=  Receive Appinst Health Check Server Fail Event
   log to console  ${new_cloudlet2.fqdn}
   Should Be Equal As Numbers  ${new_cloudlet2.status}  1  #FIND_FOUND
   Should Be Equal             ${new_cloudlet2.fqdn}  ${appinst2['data']['uri']}
   Should Be Equal As Numbers  ${new_cloudlet2.cloudlet_location.latitude}   ${appinst2['data']['cloudlet_loc']['latitude']}
   Should Be Equal As Numbers  ${new_cloudlet2.cloudlet_location.longitude}  ${appinst2['data']['cloudlet_loc']['longitude']}
   Should Be Equal As Numbers  ${new_cloudlet2.ports[0].proto}  ${appinst2['data']['mapped_ports'][0]['proto']}  #LProtoTCP
   Should Be Equal As Numbers  ${new_cloudlet2.ports[0].internal_port}  ${appinst2['data']['mapped_ports'][0]['internal_port']}
   Should Be Equal As Numbers  ${new_cloudlet2.ports[0].public_port}  ${appinst2['data']['mapped_ports'][0]['public_port']}
   Should Be Equal As Numbers  ${new_cloudlet2.ports[1].proto}  ${appinst2['data']['mapped_ports'][1]['proto']}  #LProtoTCP
   Should Be Equal As Numbers  ${new_cloudlet2.ports[1].internal_port}  ${appinst2['data']['mapped_ports'][1]['internal_port']}
   Should Be Equal As Numbers  ${new_cloudlet2.ports[1].public_port}  ${appinst2['data']['mapped_ports'][1]['public_port']}
   Should Be True  len('${new_cloudlet2.edge_events_cookie}') > 100
   Should Not Be Equal  ${new_cloudlet.edge_events_cookie}  ${new_cloudlet2.edge_events_cookie}
   Should Not Be Equal  ${new_cloudlet1.edge_events_cookie}  ${new_cloudlet2.edge_events_cookie}

   # create persist connection to new cloudlet
   Create DME Persistent Connection  edge_events_cookie=${new_cloudlet2.edge_events_cookie}  latitude=36  longitude=-96

*** Keywords ***
Setup
#   ${epoch}=  Get Current Date  result_format=epoch
#   ${emailepoch}=  Catenate  SEPARATOR=  ${user_username}  +  ${epoch}  @gmail.com
#   ${epochusername}=  Catenate  SEPARATOR=  ${user_username}  ${epoch}

   Login  username=${username}  password=${mexadmin_password}
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
#   Set Suite Variable  ${emailepoch}
#   Set Suite Variable  ${epoch}
#   Set Suite Variable  ${epochusername}

Teardown CloudletDown
   [Arguments]  ${crmip}=${None}
   Cleanup Provisioning
#   Start CRM Docker Container  ${crm_split[1]}

