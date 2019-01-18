*** Settings ***
Documentation   VerifyLocation - within 10KM

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
	
Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${access_ports}    tcp:80,http:443,udp:10002
${operator_name}   dmuus
${cloudlet_name1}  tmocloud-1
${cloudlet_lat1}   31
${cloudlet_long1}  -91

${beacon_lat}      52.5200
${beacon_long}     13.4050

*** Test Cases ***
VerifyLocation - request with coord barely > 10km and < 100km shall return LOC_VERIFIED of 100km
    [Documentation]
    ...  update location to Beacon
    ...  send VerifyLocatoin with coord barely over 10km away from Beacon
    ...  Beacon at 52.52,13.4050 and verifyLocation at 52.61,13.4050. distance of 10.01 KM
    ...  verify return LOC_VERIFIED of 100km

      Register Client
      Get Token
      ${verify_reply}=  Verify Location  carrier_name=${operator_name}  latitude=52.61  longitude=${beacon_long}

      Should Be Equal As Numbers  ${verify_reply.gps_location_status}  1  #LOC_VERIFIED
      Should Be Equal As Numbers  ${verify_reply.GPS_Location_Accuracy_KM}  100.0

VerifyLocation - request with coord > 10km and < 100km shall return LOC_VERIFIED of 100km
    [Documentation]
    ...  update location to Beacon
    ...  send VerifyLocatoin with coord < 100km away. 
    ...  Beacon at 52.52,13.4050 and verifyLocation at 53.41,13.4050. distance of 98.96 KM
    ...  verify return LOC_VERIFIED of 100KM

      Register Client
      Get Token
      ${verify_reply}=  Verify Location  carrier_name=${operator_name}  latitude=53.41  longitude=${beacon_long}

      Should Be Equal As Numbers  ${verify_reply.gps_location_status}  1  #LOC_VERIFIED
      Should Be Equal As Numbers  ${verify_reply.GPS_Location_Accuracy_KM}  100.0

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor
    Create Cluster
    Create App             access_ports=${access_ports} 
    Create App Instance    cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}

    #Beacon
    Update Location  latitude=${beacon_lat}  longitude=${beacon_long}  
