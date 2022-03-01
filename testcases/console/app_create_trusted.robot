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
Web UI - User shall be able to create a Trusted App
    [Documentation]
    ...  Create a new EU Kubernetes App with Android Package
    ...  Verify Kubernetes App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015  trusted=True

    @{apps_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{apps_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be True  ${row['data']['trusted']}
        Exit For Loop If  '${row['data']['key']['name']}' == '${app_name}'
    END

    ${app_details}=  Open App Details
    Should Be Equal             ${app_details['Deploy On Trusted Cloudlet']}  Yes
    Close Apps Details

    MexConsole.Delete App  click_previous_page=off  change_rows_per_page=True

Web UI - User shall be able to create a Trusted App which requires Outbound Connections
    [Documentation]
    ...  Create a new EU Kubernetes App with Android Package
    ...  Verify Kubernetes App shows in list

    &{rule1}=  Create Dictionary  protocol=TCP  portrangemin=1001  portrangemax=1005  remote_ip=3.1.1.1/32
    @{rulelist}=  Create List  ${rule1}

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015  trusted=True  outbound_connections=${rulelist}

    ${apps_details}=    Show Apps  region=EU  app_name=${app_name}
    Log to Console  ${apps_details}

    Should Be Equal              ${apps_details[0]['data']['required_outbound_connections'][0]['protocol']}  TCP
    Should Be Equal As Numbers   ${apps_details[0]['data']['required_outbound_connections'][0]['port_range_min']}  1001
    Should Be Equal As Numbers   ${apps_details[0]['data']['required_outbound_connections'][0]['port_range_max']}  1005
    Should Be Equal              ${apps_details[0]['data']['required_outbound_connections'][0]['remote_cidr']}  3.1.1.1/32

    ${ui_app_details}=  Open App Details  region=EU  app_name=${app_name}
    Should Be Equal                 ${ui_app_details['Trusted']}  Yes
    Dictionary Should Contain Key   ${ui_app_details}  Required Outbound Connections
    Should Contain                  ${ui_app_details['Required Outbound Connections']}  "protocol": "TCP"
    Should Contain                  ${ui_app_details['Required Outbound Connections']}  "port_range_min": 1001
    Should Contain                  ${ui_app_details['Required Outbound Connections']}  "port_range_max": 1005
    Should Contain                  ${ui_app_details['Required Outbound Connections']}  "remote_cidr": "3.1.1.1/32"
    Close Apps Details

    MexConsole.Delete App  app_name=${app_name}

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${app_name}=  Get Default App Name
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Apps
    Set Suite Variable  ${token}
    Set Suite Variable  ${app_name}

Teardown
    Close Browser
    Run Keyword and Ignore Error  MexMasterController.Delete App  region=EU  app_name=${app_name}  developer_org_name=${developer_name}

