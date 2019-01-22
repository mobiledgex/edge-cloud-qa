*** Settings ***
Documentation   VerifyLocation - request shall return LOC_MISMATCH_SAME_COUNTRY

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
	
Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${access_ports}    tcp:80,http:443,udp:10002
${operator_name}   tmus
${cloudlet_name1}  tmocloud-1
${cloudlet_lat1}   31
${cloudlet_long1}  -91

${berlin_lat}      52.5200
${berlin_long}     13.4050

*** Test Cases ***
VerifyLocation - request with coord barely > 100km and still within country shall return LOC_MISMATCH_SAME_COUNTRY
    [Documentation]
    ...  update location to Berlin
    ...  send VerifyLocatoin with coord barely over 100km away from Berlin
    ...  Berlin at 52.52,13.4050 and verifyLocation at 53.42,13.4050. distance of 100.08 KM
    ...  verify return LOC_MISMATCH_SAME_COUNTRY

      Register Client
      Get Token
      ${verify_reply}=  Verify Location  carrier_name=${operator_name}  latitude=53.42  longitude=${berlin_long}

      Should Be Equal As Numbers  ${verify_reply.gps_location_status}  2  #LOC_MISMATCH_SAME_COUNTRY
      Should Be Equal As Numbers  ${verify_reply.GPS_Location_Accuracy_KM}  -1

VerifyLocation - request with coord > 100km and within same country shall return LOC_MISMATCH_SAME_COUNTRY
    [Documentation]
    ...  update location to Berlin
    ...  send VerifyLocatoin with coord > 100km away. 
    ...  Berlin at 52.52,13.4050 and verifyLocation at 50.73438 7.09549(Bonn, Germny).
    ...  verify return LOC_VERIFIED of 100KM

      Register Client
      Get Token
      ${verify_reply}=  Verify Location  carrier_name=${operator_name}  latitude=50.73438  longitude=7.09549

      Should Be Equal As Numbers  ${verify_reply.gps_location_status}  2  #LOC_MISMATCH_SAME_COUNTRY
      Should Be Equal As Numbers  ${verify_reply.GPS_Location_Accuracy_KM}  -1

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor
    Create Cluster
    Create App             access_ports=${access_ports} 
    Create App Instance    cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}

    #Berlin
    Update Location  latitude=${berlin_lat}  longitude=${berlin_long}  

