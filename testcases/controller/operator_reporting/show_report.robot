*** Settings ***
Documentation    Report Generation by Operator

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections
Library  random

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${operator}  packet

*** Test Cases ***
# ECQ-3818
Shall be able to view and download operator reports stored in GCS bucket
    [Documentation]
    ...  Login as OperatorManager
    ...  Run report show API and verify reports are visible 
    ...  Run report download API to download a random report from the list

    ${report_list}=  Show Report  organization=${operator}  token=${op_token}
    ${length}=  Get Length  ${report_list}
    ${min value}=  Convert to Integer    0
    ${index}=  random.randint  ${min value}  ${length}

    ${filename}=  Set Variable  ${report_list[${index}]}

    Download Report  organization=${operator}  filename=${filename}  token=${op_token}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${op_token}
