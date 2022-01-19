*** Settings ***
Documentation   Latency Edge Event Tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections
Library  String

Test Setup	Setup
Test Teardown	Teardown

Test Timeout    60s

*** Variables ***
${region}=  US
${gcp_cloudlet_name}  gcpcloud-1
${gcp_cloudlet_latitude}          37
${gcp_cloudlet longitude}         -95
${gcp_operator_name}  gcp

${packet_operator_name}  packet
${packet_cloudlet_latitude}   37
${packet_cloudlet_longitude}  -95

*** Test Cases ***
# ECQ-3345
DMEPersistentConnection - Location Update edge event shall return new cloudlet
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Location Update Edge Event with new coord
    ...  - verify response has new cloudlet

    [Tags]  DMEPersistentConnection

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}	
    ${cloudlet}=  Find Cloudlet	 carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${cloudlet2}=  Send Location Update Edge Event  latitude=31  longitude=-91

    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet2.new_cloudlet.fqdn}  shared.tmocloud-1-tmus.${region_lc}.mobiledgex.net
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.latitude}  31.0
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.longitude}  -91.0

# ECQ-3346
DMEPersistentConnection - Location Update edge event with device info shall return new cloudlet
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Location Update Edge Event with new coord and device info
    ...  - verify response has new cloudlet

    [Tags]  DMEPersistentConnection

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  carrier_name=tmus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=65

    ${cloudlet2}=  Send Location Update Edge Event  latitude=31  longitude=-91  carrier_name=tmus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=65


    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet2.new_cloudlet.fqdn}  shared.tmocloud-1-tmus.${region_lc}.mobiledgex.net
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.latitude}  31.0
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.longitude}  -91.0

# ECQ-3347
DMEPersistentConnection - Location Update edge event without lat/long shall return error
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Location Update Edge Event without lat/long
    ...  - verify response has proper error

    [Tags]  DMEPersistentConnection

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${error}=  Run Keyword and Expect Error  *  Send Location Update Edge Event  #latitude=31  longitude=-91

    Should Contain  ${error}  event_type: EVENT_ERROR
    Should Contain  ${error}  "Invalid EVENT_LOCATION_UPDATE, invalid location: rpc error: code = InvalidArgument desc = Missing GpsLocation"

# ECQ-3402
DMEPersistentConnection - Location Update edge event with invalid lat/long shall return error
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Location Update Edge Event with out of range lat/long
    ...  - verify response has proper error

    [Tags]  DMEPersistentConnection

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=31  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${error}=  Run Keyword and Expect Error  *  Send Location Update Edge Event  latitude=91  longitude=-91
    Should Contain  ${error}  event_type: EVENT_ERROR
    Should Contain  ${error}  "Invalid EVENT_LOCATION_UPDATE, invalid location: rpc error: code = InvalidArgument desc = Invalid GpsLocation"

    ${error2}=  Run Keyword and Expect Error  *  Send Location Update Edge Event  latitude=31  longitude=-181
    Should Contain  ${error2}  event_type: EVENT_ERROR
    Should Contain  ${error2}  "Invalid EVENT_LOCATION_UPDATE, invalid location: rpc error: code = InvalidArgument desc = Invalid GpsLocation"

# ECQ-3348
DMEPersistentConnection - Shall be able to make another Persistent Connection after Location Update edge event
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Location Update Edge Event with new coord
    ...  - verify response has new cloudlet
    ...  - make new DME persistent connection with new cloudlet
    ...  - send Location Update Edge Event with new coord
    ...  - verify response has new cloudlet

    [Tags]  DMEPersistentConnection

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${cloudlet2}=  Send Location Update Edge Event  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=31  longitude=-91

    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet2.new_cloudlet.fqdn}  shared.tmocloud-1-tmus.${region_lc}.mobiledgex.net
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.latitude}  31.0
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.longitude}  -91.0

    Create DME Persistent Connection  edge_events_cookie=${cloudlet2.new_cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${cloudlet3}=  Send Location Update Edge Event  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet3.new_cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet3.new_cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.cloudlet_location.latitude}  35.0
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.cloudlet_location.longitude}  -95.0

# ECQ-3349
DMEPersistentConnection - Location Update edge event shall return public cloudlet
    [Documentation]
    ...  - create gcp cloudlet
    ...  - make DME persistent connection
    ...  - send Location Update Edge Event with new coord
    ...  - verify response has gcp cloudlet

    [Tags]  DMEPersistentConnection

    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}

    Create Cloudlet  region=${region}  cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    ${gcp_appinst}=  Create App Instance   region=${region}  app_name=${app_name_automation}  cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${cloudlet2}=  Send Location Update Edge Event  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=37  longitude=-96

    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Contain  ${cloudlet2.new_cloudlet.fqdn}  ${gcp_cloudlet_name}
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.latitude}  ${gcp_cloudlet_latitude}
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.longitude}  ${gcp_cloudlet_longitude} 

# ECQ-3992
DMEPersistentConnection - Location Update edge event shall return alliance org cloudlet
    [Documentation]
    ...  - create packet cloudlet/appinst with alliance org
    ...  - make DME persistent connection with tmus device info
    ...  - send Location Update Edge Event with coord closer to packet
    ...  - verify response has packet cloudlet

    [Tags]  DMEPersistentConnection  AllianceOrg

    ${epoch}=  Get Time  epoch
    ${packet_cloudlet_name}=  Catenate  SEPARATOR=  packet  ${epoch}

    ${allianceorgs}=  Create List  tmus

    Create Cloudlet  region=${region}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  latitude=${packet_cloudlet_latitude}  longitude=${packet_cloudlet_longitude}  alliance_org_list=${allianceorgs}
    ${gcp_appinst}=  Create App Instance   region=${region}  app_name=${app_name_automation}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  cluster_instance_name=autocluster

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=35  longitude=-95

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  carrier_name=tmus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=65

    ${cloudlet2}=  Send Location Update Edge Event  latitude=37  longitude=-96  

    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Contain  ${cloudlet2.new_cloudlet.fqdn}  ${packet_cloudlet_name}
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.latitude}  ${packet_cloudlet_latitude}
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.longitude}  ${packet_cloudlet_longitude}

# ECQ-3993
DMEPersistentConnection - Location Update edge event shall return alliance org cloudlet after AddAllianceOrg
    [Documentation]
    ...  - create packet cloudlet/appinst without alliance org
    ...  - make DME persistent connection with tmus device info
    ...  - send Location Update Edge Event with coord closer to packet
    ...  - verify response has tmus cloudlet since no alliance org yet
    ...  - add alliance org of tmus via AddAllianceOrg to packet cloudlet
    ...  - send Location Update Edge Event with coord closer to packet
    ...  - verify response has packet cloudlet since it has an alliance org

    [Tags]  DMEPersistentConnection  AllianceOrg

    ${epoch}=  Get Time  epoch
    ${packet_cloudlet_name}=  Catenate  SEPARATOR=  packet  ${epoch}

    Create Cloudlet  region=${region}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  latitude=31  longitude=-92
    ${gcp_appinst}=  Create App Instance   region=${region}  app_name=${app_name_automation}  cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  cluster_instance_name=autocluster

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=35  longitude=-95

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  shared.tmocloud-2-tmus.${region_lc}.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  carrier_name=tmus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=65

    ${cloudlet2}=  Send Location Update Edge Event  latitude=31  longitude=-91.999
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Contain  ${cloudlet2.new_cloudlet.fqdn}  shared.tmocloud-1-tmus.${region_lc}.mobiledgex.net
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.latitude}  31
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.longitude}  -91

    Add Cloudlet Alliance Org  region=${region}   cloudlet_name=${packet_cloudlet_name}  operator_org_name=${packet_operator_name}  alliance_org_name=tmus

    ${cloudlet3}=  Send Location Update Edge Event  latitude=31  longitude=-91.999
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet3.new_cloudlet.edge_events_cookie}') > 100
    Should Contain  ${cloudlet3.new_cloudlet.fqdn}  ${packet_cloudlet_name}
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.cloudlet_location.latitude}  31
    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.cloudlet_location.longitude}  -92

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${app_name}=  Get Default App Name

    #${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    Create Flavor  region=${region}
#    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    #Create Cluster		
    #Create App  region=${region}  developer_org_name=${developer_org_name_automation}  access_ports=tcp:1
    ${tmus_appinst}=  Create App Instance  region=${region}  app_name=${app_name_automation}  cluster_instance_developer_org_name=MobiledgeX  cloudlet_name=tmocloud-2  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster
#    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

    ${region_lc}=  Convert To Lower Case  ${region}
     
    Set Suite Variable  ${tmus_appinst} 
    Set Suite Variable  ${app_name}
    Set Suite Variable  ${region_lc}

Teardown
   Terminate DME Persistent Connection
   Cleanup Provisioning
