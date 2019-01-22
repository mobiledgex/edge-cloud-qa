*** Settings ***
Documentation   GetAppInstList - request shall return 0 app

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
GetAppInstList - request with no app instance shall return 0 app
    [Documentation]
    ...  registerClient against app with no app instance
    ...  send GetAppInstList for 0 app
    ...  verify returns 0 result

      Register Client
      ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      Length Should Be   ${appfqdns}  0

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cluster Flavor
    Create Cluster	
    Create App			access_ports=tcp:1  permits_platform_apps=${True}


