*** Settings ***
Documentation   Create new App
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    10 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  MobiledgeX

*** Test Cases ***
Web UI - User shall be able to update an existing App to enable Trusted Setting
    [Documentation]
    ...  Create a new Kubernetes App which is not trusted
    ...  UpdateApp to enable Trusted 

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015 

    MexConsole.Update App  trusted=True
    Sleep  5s
    ${app_details}=    Show Apps  region=EU  app_name=${app_name}
    Log to Console  ${app_details}

    Should Be True   ${app_details[0]['data']['trusted']}

    ${app_details_ui}=  Open App Details  app_name=${app_name}
    Should Be Equal             ${app_details_ui['Trusted']}  Yes
    Close Apps Details

    MexConsole.Delete App   app_name=${app_name}

Web UI - User shall be able to update an existing Trusted App to add Required Outbound Connections
    [Documentation]
    ...  Create a new Kubernetes App which is trusted
    ...  UpdateApp to add Required Outbound Connections

    &{rule1}=  Create Dictionary  protocol=TCP  portrangemin=1006  portrangemax=1009  remote_ip=3.1.1.1/32
    @{rulelist}=  Create List  ${rule1}

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015  trusted=True

    MexConsole.Update App  outbound_connections=${rulelist}
    Sleep  5s
    ${app_details}=    Show Apps  region=EU  app_name=${app_name}
    Log to Console  ${app_details}

    Should Be Equal  ${app_details[0]['data']['required_outbound_connections'][0]['protocol']}  TCP
    Should Be Equal As Numbers   ${app_details[0]['data']['required_outbound_connections'][0]['port_range_min']}  1006
    Should Be Equal As Numbers   ${app_details[0]['data']['required_outbound_connections'][0]['port_range_max']}  1009
    Should Be Equal              ${app_details[0]['data']['required_outbound_connections'][0]['remote_cidr']}  3.1.1.1/32

    ${app_details_ui}=  Open App Details
    Should Be Equal                 ${app_details_ui['Trusted']}  Yes
    Dictionary Should Contain Key   ${app_details_ui}  Required Outbound Connections
    Should Contain                  ${app_details_ui['Required Outbound Connections']}  "protocol": "TCP"
    Should Contain                  ${app_details_ui['Required Outbound Connections']}  "port_range_min": 1006
    Should Contain                  ${app_details_ui['Required Outbound Connections']}  "port_range_max": 1009
    Should Contain                  ${app_details_ui['Required Outbound Connections']}  "remote_cidr": "3.1.1.1/32"
    Close Apps Details

    MexConsole.Delete App  app_name=${app_name}

Web UI - User shall be able to disable Trusted Setting on an existing Trusted App 
    [Documentation]
    ...  Create a new Kubernetes App which is trusted
    ...  UpdateApp to remove Trusted

    &{rule1}=  Create Dictionary   protocol=TCP  portrangemin=1006  portrangemax=1009  remote_ip=3.1.1.1/32
    @{rulelist}=  Create List  ${rule1}

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015  trusted=True  outbound_connections=${rulelist}

    MexConsole.Update App  trusted=True  ## To toggle
    Sleep  5s
    ${app_details}=    Show Apps  region=EU  app_name=${app_name}

    Dictionary Should Not Contain Key  ${app_details[0]['data']}  trusted

    ${app_details_ui}=  Open App Details
    Should Be Equal             ${app_details_ui['Trusted']}  No
    Dictionary Should Not Contain Key   ${app_details_ui}  Required Outbound Connections
    Close Apps Details

    MexConsole.Delete App  app_name=${app_name}

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${app_name}=  Get Default App Name
    Open Browser
    Login to Mex Console  browser=${browser}
    Open Compute
    Open Apps
    Set Suite Variable  ${token}
    Set Suite Variable  ${app_name}

Teardown
    Close Browser
    Run Keyword and Ignore Error  MexMasterController.Delete App  region=EU  app_name=${app_name}  developer_org_name=${developer_name}

