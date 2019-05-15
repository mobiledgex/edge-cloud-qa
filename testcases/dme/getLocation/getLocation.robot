*** Settings ***
Documentation   GetLocation

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
	
Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${access_ports}    tcp:80,http:443,udp:10002
${operator_name}   dmuus

*** Test Cases ***
GetLocation - request should return LOC_FOUND
    [Documentation]
    ...  send GetLocation 
    ...  verify return LOC_FOUND

      Register Client
      ${verify_reply}=  Get Location  carrier_name=${operator_name}

      Should Be Equal As Numbers  ${verify_reply.Status}  1  #LOC_FOUND
      Should Be Equal  ${verify_reply.CarrierName}  ${operator_name}

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster
    Create App             access_ports=${access_ports} 
