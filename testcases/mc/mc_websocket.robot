*** Settings ***
Documentation   MasterController Websocket
	
Library		MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
	
*** Test Cases ***
# ECQ-4427
MC - Websocket connection with invalid origin shall return error
    [Documentation]
    ...  - make web socket connection with invalid origin header
    ...  - verify error returns

    [Template]  Create with Invalid Origin Shall Return Error

    https://x.console-qa.mobiledgex.net
    http://x.console-qa.mobiledgex.net
    x.console-qa.mobiledgex.net
    http://x.console-qa.mobiledgex.ne
    http://x.console-qa.mobiledgex.nett
    http://google.com
    http://test.com
 
*** Keywords ***
Setup
    ${devtoken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

    ${dev_wstoken}=  Create Websocket Token  token=${devtoken}
    Set Suite Variable  ${devtoken}
    Set Suite Variable  ${dev_wstoken}

Create with Invalid Origin Shall Return Error
    [Arguments]  ${origin}

    Run Keyword and Expect Error  ('code=None', 'error=Handshake status 403 Forbidden')  Create App Instance  region=US  token=${devtoken}  websocket_token=${dev_wstoken}  websocket_origin=${origin}  app_name=${app_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autoclusterws1

