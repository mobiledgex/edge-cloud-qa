*** Settings ***
Documentation   VerifyLocation - request with shall return LOC_MISMATCH_OTHER_COUNTRY

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
${warsaw_lat}      52.22977
${warsaw_long}     21.01178
${allen_lat}       33.10317
${allen_long}      -96.67055

*** Test Cases ***
VerifyLocation - request claiming to be home but actually in neighboring country shall return LOC_MISMATCH_OTHER_COUNTRY
    [Documentation]
    ...  update location to Warsaw, Poland
    ...  send VerifyLocatoin with coord in Beacon
    ...  verify return LOC_MISMATCH_OTHER_COUNTRY

      #Warsaw
      Update Location  latitude=${warsaw_lat}  longitude=${warsaw_long}  

      Register Client
      Get Token
      ${verify_reply}=  Verify Location  carrier_name=${operator_name}  latitude=${beacon_lat}  longitude=${beacon_long}

      Should Be Equal As Numbers  ${verify_reply.gps_location_status}  3  #LOC_MISMATCH_OTHER_COUNTRY
      Should Be Equal As Numbers  ${verify_reply.GPS_Location_Accuracy_KM}  -1

VerifyLocation - request claiming to be home but actually overseas shall return LOC_MISMATCH_OTHER_COUNTRY
    [Documentation]
    ...  update location to Allen, TX
    ...  send VerifyLocatoin with coord in Beacon
    ...  verify return LOC_MISMATCH_OTHER_COUNTRY

      #Allen Tx
      Update Location  latitude=${allen_lat}  longitude=${allen_long}  

      Register Client
      Get Token
      ${verify_reply}=  Verify Location  carrier_name=${operator_name}  latitude=${beacon_lat}  longitude=${beacon_long}

      Should Be Equal As Numbers  ${verify_reply.gps_location_status}  3  #LOC_MISMATCH_OTHER_COUNTRY
      Should Be Equal As Numbers  ${verify_reply.GPS_Location_Accuracy_KM}  -1

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor
    Create Cluster
    Create App             access_ports=${access_ports} 
    Create App Instance    cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}


