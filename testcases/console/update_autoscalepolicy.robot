*** Settings ***
Documentation   Update an existing Auto Scale Policy
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
Web UI - User shall be able to update minimum nodes for an existing Auto Scale Policy
    [Documentation]
    ...  Create a new Auto Scale Policy
    ...  Verify minimum nodes can be changed

    Add New Autoscalepolicy  region=EU  developer_org_name=${developer_name}  policy_name=${policy_name}  max_nodes=4

    MexConsole.Update Autoscalepolicy  min_nodes=2
 
    ${policy_details}=    Show Autoscale Policy  region=EU  policy_name=${policy_name}  min_nodes=2  max_nodes=4
    Should Be Equal As Integers  ${policy_details[0]['data']['min_nodes']}  2
    Should Be Equal As Integers  ${policy_details[0]['data']['max_nodes']}   4
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_up_cpu_thresh']}  50
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_down_cpu_thresh']}  40
    Should Be Equal As Integers  ${policy_details[0]['data']['trigger_time_sec']}  30

    MexConsole.Delete Autoscalepolicy  change_rows_per_page=True

Web UI - User shall be able to update maximum nodes for an existing Auto Scale Policy
    [Documentation]
    ...  Create a new Auto Scale Policy
    ...  Verify maximum nodes can be changed

    Add New Autoscalepolicy  region=EU  developer_org_name=${developer_name}  policy_name=${policy_name} 

    MexConsole.Update Autoscalepolicy  max_nodes=4

    ${policy_details}=    Show Autoscale Policy  region=EU  policy_name=${policy_name}  max_nodes=4
    Should Be Equal As Integers  ${policy_details[0]['data']['min_nodes']}  1
    Should Be Equal As Integers  ${policy_details[0]['data']['max_nodes']}   4
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_up_cpu_thresh']}  50
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_down_cpu_thresh']}  40
    Should Be Equal As Integers  ${policy_details[0]['data']['trigger_time_sec']}  30

    MexConsole.Delete Autoscalepolicy  change_rows_per_page=True

Web UI - User shall be able to update scale_down_threshold for an existing Auto Scale Policy
    [Documentation]
    ...  Create a new Auto Scale Policy
    ...  Verify scale_down_threshold can be changed

    Add New Autoscalepolicy  region=EU  developer_org_name=${developer_name}  policy_name=${policy_name} 

    MexConsole.Update Autoscalepolicy  scale_down_threshold=20

    ${policy_details}=    Show Autoscale Policy  region=EU  policy_name=${policy_name}  scale_down_cpu_threshold=20
    Should Be Equal As Integers  ${policy_details[0]['data']['min_nodes']}  1
    Should Be Equal As Integers  ${policy_details[0]['data']['max_nodes']}   2
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_up_cpu_thresh']}  50
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_down_cpu_thresh']}  20
    Should Be Equal As Integers  ${policy_details[0]['data']['trigger_time_sec']}  30

    MexConsole.Delete Autoscalepolicy  change_rows_per_page=True

Web UI - User shall be able to update scale_up_threshold for an existing Auto Scale Policy
    [Documentation]
    ...  Create a new Auto Scale Policy
    ...  Verify scale_up_threshold can be changed

    Add New Autoscalepolicy  region=EU  developer_org_name=${developer_name}  policy_name=${policy_name}

    MexConsole.Update Autoscalepolicy  scale_up_threshold=70

    ${policy_details}=    Show Autoscale Policy  region=EU  policy_name=${policy_name}  scale_up_cpu_threshold=70
    Should Be Equal As Integers  ${policy_details[0]['data']['min_nodes']}  1
    Should Be Equal As Integers  ${policy_details[0]['data']['max_nodes']}   2
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_up_cpu_thresh']}  70
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_down_cpu_thresh']}  40
    Should Be Equal As Integers  ${policy_details[0]['data']['trigger_time_sec']}  30

    MexConsole.Delete Autoscalepolicy  change_rows_per_page=True

Web UI - User shall be able to update trigger time for an existing Auto Scale Policy
    [Documentation]
    ...  Create a new Auto Scale Policy
    ...  Verify trigger time can be changed

    Add New Autoscalepolicy  region=EU  developer_org_name=${developer_name}  policy_name=${policy_name}

    MexConsole.Update Autoscalepolicy  trigger_time=100

    ${policy_details}=    Show Autoscale Policy  region=EU  policy_name=${policy_name}  trigger_time=100
    Should Be Equal As Integers  ${policy_details[0]['data']['min_nodes']}  1
    Should Be Equal As Integers  ${policy_details[0]['data']['max_nodes']}   2
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_up_cpu_thresh']}  50
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_down_cpu_thresh']}  40
    Should Be Equal As Integers  ${policy_details[0]['data']['trigger_time_sec']}  100

    MexConsole.Delete Autoscalepolicy  change_rows_per_page=True

Web UI - User shall be able to update all fields for an existing Auto Scale Policy
    [Documentation]
    ...  Create a new Auto Scale Policy
    ...  Verify all editable fields can be changed

    Add New Autoscalepolicy  region=EU  developer_org_name=${developer_name}  policy_name=${policy_name}

    MexConsole.Update Autoscalepolicy  min_nodes=2  max_nodes=4  scale_down_threshold=20  scale_up_threshold=70  trigger_time=100 

    ${policy_details}=    Show Autoscale Policy  region=EU  policy_name=${policy_name}  min_nodes=2  max_nodes=4  scale_down_cpu_threshold=20  scale_up_cpu_threshold=70  trigger_time=100
    Should Be Equal As Integers  ${policy_details[0]['data']['min_nodes']}  2
    Should Be Equal As Integers  ${policy_details[0]['data']['max_nodes']}   4
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_up_cpu_thresh']}  70
    Should Be Equal As Integers  ${policy_details[0]['data']['scale_down_cpu_thresh']}  20
    Should Be Equal As Integers  ${policy_details[0]['data']['trigger_time_sec']}  100

    MexConsole.Delete Autoscalepolicy  change_rows_per_page=True

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
