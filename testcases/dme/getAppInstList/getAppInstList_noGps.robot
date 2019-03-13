*** Settings ***
Documentation   GetAppInstList - request with no GPS shall return error 

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***

*** Test Cases ***
GetAppInstList - request shall fail with no GPS coords
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList with no GPS coord
    ...  verify returns "missing GPS location"

      Register Client

      ${error_msg}=  Run Keyword And Expect Error  *  Get App Instance List

      Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
      Should Contain  ${error_msg}   details = "missing GPS location"

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cluster Flavor
    Create Cluster	
    Create App			access_ports=tcp:1 
    ${tmus_appinst}=            Create App Instance  cloudlet_name=tmocloud-1  operator_name=tmus  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst} 
