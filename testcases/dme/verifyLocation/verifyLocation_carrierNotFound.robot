*** Settings ***
Documentation  VerifyLocation with carrier not found
...   attempt to send VerifyLocation with carrier that does not exist

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${cloudlet_name}  tmocloud-2
${carrier_name}  tmus

*** Test Cases ***
VerifyLocation - request with carrier not found should pass
   [Documentation]  
   ...  send VerifyLocation with carrier that does not exist
   ...  verify request passes

   Register Client
   Get Token
   Verify Location  carrier_name=xx  latitude=1  longitude=1

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor
    Create Cluster
    Create App
    Create App Instance         cloudlet_name=${cloudlet_name}  operator_name=${carrier_name}
