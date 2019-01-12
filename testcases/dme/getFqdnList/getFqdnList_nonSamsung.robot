*** Settings ***
Documentation  GetFqdnList - request for non-samsung app

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95

*** Test Cases ***
GetFqdnList - request fqdnlist for non-samsung app should fail
    [Documentation]
    ...  register client for non-samsung app
    ...  Send GetFqdnList 
    ...  verify 'API Not allowed for developer' error is received
	
   # no register thus no cookie
   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Get FQDN List 

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "API Not allowed for developer: ${developer_name_default} app: ${app_name_default}"

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    Create Cluster Flavor
    Create Cluster	
    Create Cluster Instance	
    Create App			access_ports=tcp:1  permits_platform_apps=${True}
    Create App Instance		cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}
