*** Settings ***
Documentation   VerifyLocation REST - request with bad token shall return LOC_ERROR_UNAUTHORIZED

Library         MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}    root_cert=%{AUTOMATION_DME_CERT}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
		
Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${access_ports}    tcp:80,http:443,udp:10002
${operator_name}   tmus
${cloudlet_name1}  tmocloud-1

${berlin_lat}      52.5200
${berlin_long}     13.4050

*** Test Cases ***
VerifyLocation REST - request with bad token shall return LOC_ERROR_UNAUTHORIZED
    [Documentation]
    ...  send VerifyLocatoin with token=xx
    ...  verify return LOC_ERROR_UNAUTHORIZED
	
      Register Client
      ${verify_reply}=  Verify Location  token=xx  carrier_name=TDG  latitude=${berlin_lat}  longitude=${berlin_long}
      log to console  ${verify_reply}
      Should Be Equal As Numbers  ${verify_reply.gps_location_status}  6  #LOC_ERROR_UNAUTHORIZED
      Should Be Equal As Numbers  ${verify_reply.gps_location_accuracy_km}  -1

VerifyLocation REST - request with empty token shall return 'verifyloc token required'
    [Documentation]
    ...  send VerifyLocatoin with empty token
    ...  verify return 'verifyloc token required'
	
      Register Client
      ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  token=  carrier_name=TDG  latitude=${berlin_lat}  longitude=${berlin_long}

      Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
      Should Contain  ${error_msg}   details = "verifyloc token required"

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    #Create Cluster
    Create App             access_ports=${access_ports} 
    Create App Instance    cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}  cluster_instance_name=autocluster



