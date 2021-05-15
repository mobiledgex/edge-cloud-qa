*** Settings ***
Documentation   Latency Edge Event Tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections

Test Setup	Setup
Test Teardown	Teardown

Test Timeout    60s

*** Variables ***
${region}=  US
${gcp_cloudlet_name}  gcpcloud-1
${gcp_cloudlet_latitude}          37
${gcp_cloudlet longitude}         -95
${gcp_operator_name}  gcp

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
    Should Be Equal  ${cloudlet.fqdn}  tmocloud-2.dmuus.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${cloudlet2}=  Send Location Update Edge Event  latitude=31  longitude=-91

    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet2.new_cloudlet.fqdn}  tmocloud-1.dmuus.mobiledgex.net
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
    Should Be Equal  ${cloudlet.fqdn}  tmocloud-2.dmuus.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  carrier_name=dmuus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=65

    ${cloudlet2}=  Send Location Update Edge Event  latitude=31  longitude=-91  carrier_name=dmuus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=65


    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet2.new_cloudlet.fqdn}  tmocloud-1.dmuus.mobiledgex.net
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
    ...  - verify response has new cloudlet

    [Tags]  DMEPersistentConnection

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet.fqdn}  tmocloud-2.dmuus.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${error}=  Run Keyword and Expect Error  *  Send Location Update Edge Event  #latitude=31  longitude=-91

    Should Contain  ${error}  event_type: EVENT_ERROR
    Should Contain  ${error}  "Invalid EVENT_LOCATION_UPDATE, invalid location: rpc error: code = InvalidArgument desc = Missing GpsLocation"

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
    Should Be Equal  ${cloudlet.fqdn}  tmocloud-2.dmuus.mobiledgex.net

    Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${cloudlet2}=  Send Location Update Edge Event  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=31  longitude=-91

    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.new_cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet2.new_cloudlet.fqdn}  tmocloud-1.dmuus.mobiledgex.net
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].proto}  1
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].internal_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.ports[0].public_port}  1234
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.latitude}  31.0
    Should Be Equal As Numbers  ${cloudlet2.new_cloudlet.cloudlet_location.longitude}  -91.0

    Create DME Persistent Connection  edge_events_cookie=${cloudlet2.new_cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${cloudlet3}=  Send Location Update Edge Event  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet3.new_cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet3.new_cloudlet.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet3.new_cloudlet.fqdn}  tmocloud-2.dmuus.mobiledgex.net
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
    Should Be Equal  ${cloudlet.fqdn}  tmocloud-2.dmuus.mobiledgex.net

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

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${app_name}=  Get Default App Name

    #${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    Create Flavor  region=${region}
#    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name}  operator_org_name=${dmuus_operator_name}  latitude=${dmuus_cloudlet_latitude}  longitude=${dmuus_cloudlet_longitude}
    #Create Cluster		
    #Create App  region=${region}  developer_org_name=${developer_org_name_automation}  access_ports=tcp:1
    ${dmuus_appinst}=  Create App Instance  region=${region}  app_name=${app_name_automation}  cluster_instance_developer_org_name=MobiledgeX  cloudlet_name=tmocloud-2  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster
#    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

   
    Set Suite Variable  ${dmuus_appinst} 
    Set Suite Variable  ${app_name}

Teardown
   Terminate DME Persistent Connection
   Cleanup Provisioning
