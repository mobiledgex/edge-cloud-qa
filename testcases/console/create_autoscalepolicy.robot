*** Settings ***
Documentation   Create new Auto Scale Policy
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  MobiledgeX
${wait}  200

*** Test Cases ***
Web UI - User shall be able to create an Auto Scale Policy
    [Documentation]
    ...  Create a new Auto Scale Policy
    ...  Verify Policy details in backend

    Add New Autoscalepolicy  region=EU  developer_org_name=${developer_name}  policy_name=${policy_name}  targetCPU=2

    Autoscalepolicy Should Exist  policy_name=${policy_name}

    ${policy_details}=    Show Autoscale Policy  region=EU  policy_name=${policy_name}  developer_org_name=${developer_name}  token=${token}  use_defaults=${False}
    Should Be Equal As Integers  ${policy_details[0]['data']['min_nodes']}  1
    Should Be Equal As Integers  ${policy_details[0]['data']['max_nodes']}   2
    Should Be Equal As Integers  ${policy_details[0]['data']['stabilization_window_sec']}  30
    Should Be Equal As Integers  ${policy_details[0]['data']['target_cpu']}  2

    MexConsole.Delete Autoscalepolicy 

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${policy_name}=  Get Default Autoscale Policy Name
    Open Browser
    Login to Mex Console  browser=${browser}
    Open Compute
    Open Policies
    Open Autoscalepolicy
    Set Suite Variable  ${token}
    Set Suite Variable  ${policy_name}

Teardown
    Close Browser
    Run Keyword and Ignore Error  MexMasterController.Delete Autoscale policy  policy_name=${policy_name}  region=EU
