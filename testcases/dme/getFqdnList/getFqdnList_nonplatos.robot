*** Settings ***
Documentation  GetFqdnList - request for non-platos app

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${dmuus_cloudlet_latitude}	  35
${dmuus_cloudlet longitude}	  -95

*** Test Cases ***
GetFqdnList - request fqdnlist for non-platos app should fail
    [Documentation]
    ...  register client for non-platos app
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
    #Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name}  operator_name=${dmuus_operator_name}  latitude=${dmuus_cloudlet_latitude}  longitude=${dmuus_cloudlet_longitude}
    Create Cluster Flavor
    Create Cluster	
    Create Cluster Instance     cloudlet_name=${dmuus_cloudlet_name}  operator_name=${dmuus_operator_name}	
    Create App			access_ports=tcp:1  permits_platform_apps=${True}
    Create App Instance		cloudlet_name=${dmuus_cloudlet_name}  operator_name=${dmuus_operator_name}  cluster_instance_name=autocluster
