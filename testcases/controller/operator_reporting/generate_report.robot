*** Settings ***
Documentation    Report Generation by Operator

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${operator}  packet

*** Test Cases ***
# ECQ-3810
Shall be able to generate a report in default timezone
    [Documentation]
    ...  Login as OperatorManager
    ...  Generate a report in default timezone

    @{index}=  Split String  ${date1}  ${SPACE}
    ${end_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Subtract Time From Date  ${date1}  7 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  use_defaults=${False}  token=${op_token}

# ECQ-3811
Shall be able to generate a report in non-default timezone
    [Documentation]
    ...  Login as OperatorManager
    ...  Generate a report in non default timezone

    ${end_date}=  MexApp.Get Current Time  Asia/Kolkata
    ${start_date}=  Subtract Time From Date  ${end_date}  7 days
    @{index1}=  Split String  ${end_date}  ${SPACE}
    ${end_date}=  Catenate  SEPARATOR=  ${index1[0]}  T${index1[1]}+05:30
    @{index2}=  Split String  ${start_date}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index2[0]}  T${index2[1]}+05:30

    Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  timezone=Asia/Kolkata  use_defaults=${False}  token=${op_token}

# ECQ-3812
Shall be able to generate report with maximum time range of 31 days
    [Documentation]
    ...  Login as OperatorManager
    ...  Generate a report with maximum time range of 31 days

    @{index}=  Split String  ${date1}  ${SPACE}
    ${end_time}=  Catenate  SEPARATOR=  ${index[0]}  T${index[1]}Z
    ${date2}=  Subtract Time From Date  ${date1}  31 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${start_time}=  Catenate  SEPARATOR=  ${index[0]}  T${index[1]}Z

    Generate Report  organization=${operator}  start_time=${start_time}  end_time=${end_time}  use_defaults=${False}  token=${op_token}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${date1}=  DateTime.Get Current Date  UTC

    Skip Verify Email   skip_verify_email=False

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${op_token}
    Set Suite Variable  ${date1}
