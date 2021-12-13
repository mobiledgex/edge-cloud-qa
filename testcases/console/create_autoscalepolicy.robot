*** Settings ***
Documentation   Create new Auto Scale Policy
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Test Setup      Setup
Test Teardown   Close Browser

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

    Add New Autoscalepolicy  region=EU  developer_org_name=${developer_name}  policy_name=${policy_name}

    Autoscalepolicy Should Exist  change_rows_per_page=True

    ${policy_details}=    Show Autoscale Policy  region=EU  policy_name=${policy_name}
    Should Be Equal As Integers  ${policy_details[0]['data']['min_nodes']}  1
    Should Be Equal As Integers  ${policy_details[0]['data']['max_nodes']}   2
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_up_cpu_thresh']}  50
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_down_cpu_thresh']}  40
    Should Be Equal As Integers  ${policy_details[0]['data']['trigger_time_sec']}  30

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
