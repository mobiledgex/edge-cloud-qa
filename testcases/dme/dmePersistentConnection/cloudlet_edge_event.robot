*** Settings ***
Documentation   DME persistent connection with cloudlet maintenance and state change

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  String

Suite Setup    Setup Suite
Test Setup     Setup
Test Teardown  Teardown

Test Timeout  1m

*** Variables ***
${cloudlet2}=  tmocloud-2
${cloudlet2_lat}=  35
${cloudlet2_long}=  -95
${operator}=  tmus
${region}=  US

${packet_operator_name}  packet
${packet_cloudlet_latitude}   36
${packet_cloudlet_longitude}  -95

*** Test Cases ***
# ECQ-3422
DmePersistentConnetion - cloudlet in maintenance mode shall not return a new cloudlet
   [Documentation]
   ...  - create 1 appinst
   ...  - send UpdateCloudlet to put the cloudlet in maint mode
   ...  - verify cloudlet maint event is received with no new cloudlet

   [Tags]  DMEPersistentConnection

   ${r}=  Register Client  
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=36  longitude=-96
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}  latitude=36  longitude=-96

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Receive Cloudlet Maintenance Event  #state=FAILOVER_REQUESTED
   Receive Cloudlet Maintenance Event  #state=CRM_REQUESTED
   ${error1}=  Run Keyword and Expect Error  *  Receive Cloudlet Maintenance Event  state=UNDER_MAINTENANCE
   Should Be Equal  ${error1}  Current appinst is unusable. Unable to find any cloudlets doing FindCloudlet - FindStatus is FIND_NOTFOUND

   Sleep  1s

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation  
   Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION_INIT
   #Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION
   ${cloud1}=  Receive Cloudlet Update Event
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud1.new_cloudlet.edge_events_cookie}') > 100
   Should Be Equal  ${cloud1.new_cloudlet.fqdn}  ${fcloudlet.fqdn}
   Should Be Equal  ${cloud1.new_cloudlet.ports}  ${fcloudlet.ports}
   Should Be Equal  ${cloud1.new_cloudlet.cloudlet_location}  ${fcloudlet.cloudlet_location}

   Sleep  1s

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover
   Receive Cloudlet Maintenance Event  state=CRM_REQUESTED
   ${error2}=  Run Keyword and Expect Error  *  Receive Cloudlet Maintenance Event  state=UNDER_MAINTENANCE
   Should Be Equal  ${error2}  Current appinst is unusable. Unable to find any cloudlets doing FindCloudlet - FindStatus is FIND_NOTFOUND

   Sleep  1s

   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation
   Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION_INIT
   #Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION
   ${cloud2}=  Receive Cloudlet Update Event
   Should Be Equal As Numbers  ${cloud2.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud2.new_cloudlet.edge_events_cookie}') > 100
   Should Be Equal  ${cloud2.new_cloudlet.fqdn}  ${fcloudlet.fqdn}
   Should Be Equal  ${cloud2.new_cloudlet.ports}  ${fcloudlet.ports}
   Should Be Equal  ${cloud2.new_cloudlet.cloudlet_location}  ${fcloudlet.cloudlet_location}

# ECQ-3423
DmePersistentConnetion - cloudlet in maintenance mode shall return new cloudlet
   [Documentation]
   ...  - create 2 appinsts
   ...  - send UpdateCloudlet to put the cloudlet in maint mode
   ...  - verify cloudlet maint event is received with the new cloudlet

   [Tags]  DMEPersistentConnection

   Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet2}  operator_org_name=tmus  cluster_instance_name=autoclusteraa2

   ${r}=  Register Client
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=36  longitude=-96
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}  latitude=36  longitude=-96

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Receive Cloudlet Maintenance Event  #state=FAILOVER_REQUESTED
   Receive Cloudlet Maintenance Event  #state=CRM_REQUESTED
   ${cloud1}=  Receive Cloudlet Maintenance Event  state=UNDER_MAINTENANCE
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud1.new_cloudlet.edge_events_cookie}') > 100
   Should contain  ${cloud1.new_cloudlet.fqdn}  ${cloudlet2}-tmus.${region_lc}.mobiledgex.net
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].proto}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].internal_port}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].public_port}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.latitude}  ${cloudlet2_lat}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.longitude}  ${cloudlet2_long}

   Sleep  1s

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation
   Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION_INIT
   #Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION
   ${cloud2}=  Receive Cloudlet Update Event
   Should Be Equal As Numbers  ${cloud2.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud2.new_cloudlet.edge_events_cookie}') > 100
   Should Be Equal  ${cloud2.new_cloudlet.fqdn}  ${fcloudlet.fqdn}
   Should Be Equal  ${cloud2.new_cloudlet.ports}  ${fcloudlet.ports}
   Should Be Equal  ${cloud2.new_cloudlet.cloudlet_location}  ${fcloudlet.cloudlet_location}

   Sleep  1s

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover
   Receive Cloudlet Maintenance Event  state=CRM_REQUESTED
   ${cloud2}=  Receive Cloudlet Maintenance Event  state=UNDER_MAINTENANCE
   Should Be Equal As Numbers  ${cloud2.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud2.new_cloudlet.edge_events_cookie}') > 100
   Should contain  ${cloud2.new_cloudlet.fqdn}  ${cloudlet2}-tmus.${region_lc}.mobiledgex.net
   Should Be Equal As Numbers  ${cloud2.new_cloudlet.ports[0].proto}  1
   Should Be Equal As Numbers  ${cloud2.new_cloudlet.ports[0].internal_port}  1
   Should Be Equal As Numbers  ${cloud2.new_cloudlet.ports[0].public_port}  1
   Should Be Equal As Numbers  ${cloud2.new_cloudlet.cloudlet_location.latitude}  ${cloudlet2_lat}
   Should Be Equal As Numbers  ${cloud2.new_cloudlet.cloudlet_location.longitude}  ${cloudlet2_long}

   Sleep  1s

   ${ret2}=  Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation
   Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION_INIT
   #Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION
   ${cloud3}=  Receive Cloudlet Update Event
   Should Be Equal As Numbers  ${cloud3.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud3.new_cloudlet.edge_events_cookie}') > 100
   Should Be Equal  ${cloud3.new_cloudlet.fqdn}  ${fcloudlet.fqdn}
   Should Be Equal  ${cloud3.new_cloudlet.ports}  ${fcloudlet.ports}
   Should Be Equal  ${cloud3.new_cloudlet.cloudlet_location}  ${fcloudlet.cloudlet_location}

# ECQ-3424
DmePersistentConnetion - cloudlet state change shall not return a new cloudlet
   [Documentation]
   ...  - create 1 appinst
   ...  - change the cloudlet to all possible states
   ...  - verify cloudlet state event is received with no new cloudlet

   [Tags]  DMEPersistentConnection

   @{cloudlet_states}=  Create List  CloudletStateUnknown  CloudletStateErrors  CloudletStateOffline  CloudletStateNotPresent  CloudletStateInit  CloudletStateUpgrade  CloudletStateNeedSync

   ${r}=  Register Client
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=36  longitude=-96
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}  latitude=36  longitude=-96

   FOR  ${state}  IN  @{cloudlet_states}
      # set tmus cloudlet offline
      Inject Cloudlet Info  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  state=${state}

      ${error}=  Run Keyword and Expect Error  *  Receive Cloudlet State Event  state=${state}
      Should Be Equal  ${error}  Current appinst is unusable. Unable to find any cloudlets doing FindCloudlet - FindStatus is FIND_NOTFOUND
   END

# ECQ-3425
DmePersistentConnetion - cloudlet state change shall return a new cloudlet
   [Documentation]
   ...  - create 2 appinsts
   ...  - change the cloudlet to all possible states
   ...  - verify cloudlet state event is received with the new cloudlet

   [Tags]  DMEPersistentConnection

   @{cloudlet_states}=  Create List  CloudletStateUnknown  CloudletStateErrors  CloudletStateOffline  CloudletStateNotPresent  CloudletStateInit  CloudletStateUpgrade  CloudletStateNeedSync

   Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet2}  operator_org_name=tmus  cluster_instance_name=autoclusteraa2

   ${r}=  Register Client
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=36  longitude=-96
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}  latitude=36  longitude=-96

   FOR  ${state}  IN  @{cloudlet_states}
      # set tmus cloudlet offline
      Inject Cloudlet Info  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  state=${state}

      ${cloud2}=  Receive Cloudlet State Event  state=${state}
      Should Be Equal As Numbers  ${cloud2.new_cloudlet.status}  1  #FIND_FOUND
      Should Be True  len('${cloud2.new_cloudlet.edge_events_cookie}') > 100
      Should contain  ${cloud2.new_cloudlet.fqdn}  ${cloudlet2}-tmus.${region_lc}.mobiledgex.net
      Should Be Equal As Numbers  ${cloud2.new_cloudlet.ports[0].proto}  1
      Should Be Equal As Numbers  ${cloud2.new_cloudlet.ports[0].internal_port}  1
      Should Be Equal As Numbers  ${cloud2.new_cloudlet.ports[0].public_port}  1
      Should Be Equal As Numbers  ${cloud2.new_cloudlet.cloudlet_location.latitude}  ${cloudlet2_lat}
      Should Be Equal As Numbers  ${cloud2.new_cloudlet.cloudlet_location.longitude}  ${cloudlet2_long}
   END

# ECQ-3994
DmePersistentConnection - cloudlet in maintenance mode shall return new alliance org cloudlet
   [Documentation]
   ...  - create a cloudlet with alliance org of packet
   ...  - create 2 appinsts
   ...  - send UpdateCloudlet to put the cloudlet in maint mode
   ...  - verify cloudlet maint event is received with packet cloudlet

   [Tags]  DMEPersistentConnection  AllianceOrg

   ${epoch}=  Get Time  epoch
   ${packet_cloudlet_name}=  Catenate  SEPARATOR=  packet  ${epoch}

   ${allianceorgs}=  Create List  tmus

   Create Cloudlet  region=${region}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  latitude=${packet_cloudlet_latitude}  longitude=${packet_cloudlet_longitude}  alliance_org_list=${allianceorgs}
   ${packet_appinst}=  Create App Instance   region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  cluster_instance_name=autocluster

   Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet2}  operator_org_name=tmus  cluster_instance_name=autoclusteraa2

   ${r}=  Register Client
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=36  longitude=-96
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}  latitude=36  longitude=-96  carrier_name=tmus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=65

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Receive Cloudlet Maintenance Event  #state=FAILOVER_REQUESTED
   Receive Cloudlet Maintenance Event  #state=CRM_REQUESTED
   ${cloud1}=  Receive Cloudlet Maintenance Event  state=UNDER_MAINTENANCE
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud1.new_cloudlet.edge_events_cookie}') > 100
   Should contain  ${cloud1.new_cloudlet.fqdn}  ${packet_cloudlet_name}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].proto}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].internal_port}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].public_port}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.latitude}  ${packet_cloudlet_latitude}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.longitude}  ${packet_cloudlet_longitude} 

# ECQ-3995
DmePersistentConnection - cloudlet in maintenance mode shall return new alliance org cloudlet after adding alliance org
   [Documentation]
   ...  - create a cloudlet with packet and without alliance org
   ...  - create 2 appinsts
   ...  - send UpdateCloudlet to put the cloudlet in maint mode
   ...  - verify cloudlet maint event is received with the new cloudlet
   ...  - put cloudlet back to normal operation
   ...  - update the cloudlet to add tmus alliance org to the packet cloudlet
   ...  - send UpdateCloudlet to put the cloudlet in maint mode
   ...  - verify cloudlet maint event is received with the packet cloudlet

   [Tags]  DMEPersistentConnection  AllianceOrg

   ${epoch}=  Get Time  epoch
   ${packet_cloudlet_name}=  Catenate  SEPARATOR=  packet  ${epoch}

   ${allianceorgs}=  Create List  tmus

   Create Cloudlet  region=${region}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  latitude=${packet_cloudlet_latitude}  longitude=${packet_cloudlet_longitude}
   ${packet_appinst}=  Create App Instance   region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  cluster_instance_name=autocluster

   Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet2}  operator_org_name=tmus  cluster_instance_name=autoclusteraa2

   ${r}=  Register Client
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=36  longitude=-96
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}  latitude=36  longitude=-96  carrier_name=tmus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=65

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Receive Cloudlet Maintenance Event  #state=FAILOVER_REQUESTED
   Receive Cloudlet Maintenance Event  #state=CRM_REQUESTED
   ${cloud1}=  Receive Cloudlet Maintenance Event  state=UNDER_MAINTENANCE
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud1.new_cloudlet.edge_events_cookie}') > 100
   Should contain  ${cloud1.new_cloudlet.fqdn}  ${cloudlet2}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].proto}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].internal_port}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].public_port}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.latitude}  35
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.longitude}  -95

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation
   Receive Cloudlet Maintenance Event  state=NORMAL_OPERATION_INIT
   ${cloud3}=  Receive Cloudlet Update Event
   Should Be Equal As Numbers  ${cloud3.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud3.new_cloudlet.edge_events_cookie}') > 100
   Should Be Equal  ${cloud3.new_cloudlet.fqdn}  ${fcloudlet.fqdn}
   Should Be Equal  ${cloud3.new_cloudlet.ports}  ${fcloudlet.ports}
   Should Be Equal  ${cloud3.new_cloudlet.cloudlet_location}  ${fcloudlet.cloudlet_location}

   Update Cloudlet  region=${region}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  latitude=${packet_cloudlet_latitude}  longitude=${packet_cloudlet_longitude}  alliance_org_list=${allianceorgs}

   Update Cloudlet  region=${region}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Receive Cloudlet Maintenance Event  #state=FAILOVER_REQUESTED
   Receive Cloudlet Maintenance Event  #state=CRM_REQUESTED
   ${cloud1}=  Receive Cloudlet Maintenance Event  state=UNDER_MAINTENANCE
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud1.new_cloudlet.edge_events_cookie}') > 100
   Should contain  ${cloud1.new_cloudlet.fqdn}  ${packet_cloudlet_name}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].proto}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].internal_port}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.ports[0].public_port}  1
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.latitude}  ${packet_cloudlet_latitude}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.longitude}  ${packet_cloudlet_longitude}

*** Keywords ***
Setup Suite
   ${cloudlet}=  Get Default Cloudlet Name
   ${region_lc}=  Convert to Lower Case  ${region}

   Set Suite Variable  ${cloudlet}
   Set Suite Variable  ${region_lc}

Setup
   Create Flavor  region=${region}

   Create Org  orgtype=operator
   RestrictedOrg Update

#   ${cloudlet}=  Get Default Cloudlet Name
   ${c}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet}

   Create App  region=${region}  access_ports=tcp:1  developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}
   ${tmus_appinst}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}   cloudlet_name=${c['data']['key']['name']}  operator_org_name=${c['data']['key']['organization']}  cluster_instance_name=autoclusteraa

   ${operator}=  Get Default Organization Name
   Set Suite Variable  ${operator}
#   Set Suite Variable  ${cloudlet}

Teardown
   Inject Cloudlet Info  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  state=CloudletStateReady
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  maintenance_state=NormalOperation
   Cleanup Provisioning
