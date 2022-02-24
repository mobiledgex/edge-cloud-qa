*** Settings ***
Documentation   Create new network

Library		MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library     MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min

*** Test Cases ***
WebUI - User shall be able to create a new network in US region with Connect To LoadBalancer
    [Documentation]
    ...  Create a new network
    ...  Fill in Region=US and all proper values
    ...  Verify network shows in list
    ...  Verify details

    ${region}=          Set Variable  US
    ${operator}=        Set Variable  packet
    ${cloudlet}=        Set Variable  packet-qaregression
    ${connectiontype}=  Set Variable  Connect to Loadbalancer

    Add New Network  region=${region}  network_name=${network_name_default}  operator=${operator}  cloudlet=${cloudlet}   connectiontype=${connectiontype}
    Network Should Exist  network_name=${network_name_default}  operator=${operator}  cloudlet=${cloudlet}   connectiontype=${connectiontype}

    ${network_details}=    Show Network  region=${region}  network_name=${network_name_default}
    Log to Console  ${network_details}
    Should Be Equal   ${network_details[0]['data']['connection_type']}   ConnectToLoadBalancer
    Should Be Equal   ${network_details[0]['data']['key']['name']}  ${network_name_default}

    ${network_ui_details}=  Open Network Details  region=${region}  network_name=${network_name_default}
    Log to Console  ${network_ui_details}
    Should Be Equal                     ${network_ui_details}[Region]            ${region}
    Should Be Equal                     ${network_ui_details}[Network Name]      ${network_name_default}
    Should Be Equal                     ${network_ui_details}[Connection Type]   ${connectiontype}
    Should Be Equal                     ${network_ui_details}[Cloudlet]          ${cloudlet}
    Should Be Equal                     ${network_ui_details}[Organization]      ${operator}

    Close Network Details
    MexConsole.Delete Network  region=${region}  network_name=${network_name_default}
    Network Should Not Exist  region=${region}  network_name=${network_name_default}

WebUI - User shall be able to create a new network in US region with Connect To ClusterNodes with Routes
    [Documentation]
    ...  Create a new network
    ...  Fill in Region=US and all proper values with Routes
    ...  Verify network shows in list
    ...  Verify details

    ${region}=          Set Variable  US
    ${operator}=        Set Variable  packet
    ${cloudlet}=        Set Variable  packet-qaregression
    ${connectiontype}=  Set Variable  Connect to Cluster Nodes

    Add New Network  region=${region}  network_name=${network_name_default}  operator=${operator}  cloudlet=${cloudlet}   connectiontype=${connectiontype}  routes=11.71.71.1/16:11.70.70.1
    Network Should Exist  network_name=${network_name_default}  operator=${operator}  cloudlet=${cloudlet}   connectiontype=${connectiontype}

    ${network_details}=    Show Network  region=${region}  network_name=${network_name_default}
    Log to Console  ${network_details}
    Should Be Equal   ${network_details[0]['data']['connection_type']}   ConnectToClusterNodes
    Should Be Equal   ${network_details[0]['data']['key']['name']}  ${network_name_default}

    ${network_ui_details}=  Open Network Details  region=${region}  network_name=${network_name_default}
    Log to Console  ${network_ui_details}
    Should Be Equal                     ${network_ui_details}[Region]            ${region}
    Should Be Equal                     ${network_ui_details}[Network Name]      ${network_name_default}
    Should Be Equal                     ${network_ui_details}[Connection Type]   ${connectiontype}
    Should Be Equal                     ${network_ui_details}[Cloudlet]          ${cloudlet}
    Should Be Equal                     ${network_ui_details}[Organization]      ${operator}
    Should Contain                      ${network_ui_details}[Routes]            "destination_cidr": "11.71.71.1/16"
    Should Contain                      ${network_ui_details}[Routes]            "next_hop_ip": "11.70.70.1"

    Close Network Details
    MexConsole.Delete Network  region=${region}  network_name=${network_name_default}
    Network Should Not Exist  region=${region}  network_name=${network_name_default}

*** Keywords ***
Setup
    ${network_name_default}=  Get Default Network Name
    Open Browser
    Login to Mex Console  browser=${browser}
    Open Compute
    Sleep  3s
    Open Networks
    ${token}=  Get Supertoken
    Set Suite Variable  ${token}
    Set Suite Variable  ${network_name_default}

Teardown
    Close Browser
    Cleanup Provisioning
