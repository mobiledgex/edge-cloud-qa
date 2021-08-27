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
# ECQ-3819
Operator of Org A shall not be able to view reports of Org B
    [Documentation]
    ...  Login as OperatorManager
    ...  Run report show API with different org name
    ...  Controller throws 403 forbidden

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Report  organization=reportorg1  token=${op_token}

# ECQ-3820
Download Report - Controller throws error if invalid filename is provided
    [Documentation]
    ...  Login as OperatorManager
    ...  Run report show API and fetch list of reports
    ...  Download a report with invalid filename
    ...  Controller throws error

    ${report_list}=  Show Report  organization=${operator}  token=${op_token}
    ${filename}=  Set Variable  ${report_list[-1]}

    @{index}=  Split String  ${filename}  /
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Unable to get org name from filename: ${index[-1]}"}')   Download Report  organization=${operator}  filename=${index[-1]}  token=${op_token}


*** Keywords ***
Setup
    ${super_token}=  Get Super Token

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${op_token}
