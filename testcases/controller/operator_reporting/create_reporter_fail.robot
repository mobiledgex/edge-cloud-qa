*** Settings ***
Documentation    Failure scenarios while creating reporter

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
# ECQ-3769
Create Reporter - Controller throws error when invalid org name is provided
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing invalid org name
    ...  Controller throws error

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=${reporter_name}  organization=xxx
    Should Contain  ${error_msg}  Org xxx not found

# ECQ-3770
Create Reporter - Controller throws error when invalid reporter name is provided
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing invalid reporter names
    ...  Controller throws error

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=-${reporter_name}  organization=${operator}
    Should Contain  ${error_msg}  Name cannot start with \\'-\\'

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=_${reporter_name}  organization=${operator}
    Should Contain  ${error_msg}  Name cannot contain _

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=${reporter_name}.  organization=${operator}
    Should Contain  ${error_msg}  Name cannot end with \\'.\\'

# ECQ-3771
Create Reporter - Controller throws error when invalid schedule is provided
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing invalid schedule
    ...  Controller throws error

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=EveryDay
    Should Contain  ${error_msg}  Invalid reporter schedule

# ECQ-3772
Create Reporter - Controller throws error when startscheduledate is a historical date
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing historical date as startscheduledate
    ...  Controller throws error

    ${date2}=  Subtract Time From Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=${reporter_name}  organization=${operator}   start_schedule_date=${start_date}
    Should Contain  ${error_msg}  Schedule date must not be historical date

# ECQ-3773
Create Reporter - Controller throws error when startscheduledate format is invalid
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing startscheduledate in invalid format
    ...  Controller throws error

    @{index}=  Split String  ${date1}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00
    ${start_date1}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+0530

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=${reporter_name}  organization=${operator}   start_schedule_date=${date1}
    Should Contain  ${error_msg}  Parsing time \\\\"${date1}\\\\" as \\\\"2006-01-02T15:04:05Z07:00\\\\": cannot parse \\\\" ${index[1]}\\\\" as \\\\"T\\\\"

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=${reporter_name}  organization=${operator}   start_schedule_date=${start_date}
    Should Contain  ${error_msg}  Parsing time \\\\"${start_date}\\\\" as \\\\"2006-01-02T15:04:05Z07:00\\\\": cannot parse \\\\"\\\\" as \\\\"Z07:00\\\\"

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=${reporter_name}  organization=${operator}   start_schedule_date=${start_date1}
    Should Contain  ${error_msg}  Parsing time \\\\"${start_date1}\\\\" as \\\\"2006-01-02T15:04:05Z07:00\\\\": cannot parse \\\\"+0530\\\\" as \\\\"Z07:00\\\\"

# ECQ-3774
Create Reporter - Controller throws error when invalid timezone is provided
     [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing invalid timezone
    ...  Controller throws error

    ${error_msg}=  Run Keyword and Expect Error  *  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  timezone=xx
    Should Contain  ${error_msg}  Invalid timezone xx, unknown time zone xx


*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${reporter_name}=  Get Default Reporter Name
    ${date1}=  DateTime.Get Current Date  UTC

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${reporter_name}
    Set Suite Variable  ${op1_token}
    Set Suite Variable  ${date1}
