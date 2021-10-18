*** Settings ***
Documentation    Failure scenarios while updating reporter

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
# ECQ-3785
Update Reporter - Controller throws error when invalid org name is provided
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update reporter by providing invalid org name
    ...  Controller throws error

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}

    ${error_msg}=  Run Keyword and Expect Error  *  Update Reporter  reporter_name=${reporter_name}  organization=xxx  schedule=EveryMonth
    Should Contain  ${error_msg}  Reporter not found

# ECQ-3786
Update Reporter - Controller throws error when invalid reporter name is provided
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update Reporter by providing invalid reporter name
    ...  Controller throws error

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}

    ${error_msg}=  Run Keyword and Expect Error  *  Update Reporter  reporter_name=${reporter_name}1  organization=${operator}  schedule=EveryMonth
    Should Contain  ${error_msg}  Reporter not found

# ECQ-3787
Update Reporter - Controller throws error when invalid schedule is provided
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update reporter by providing invalid schedule
    ...  Controller throws error

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}

    ${error_msg}=  Run Keyword and Expect Error  *  Update Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=EveryDay
    Should Contain  ${error_msg}  Invalid JSON data: Invalid ReportSchedule value 4

# ECQ-3788
Update Reporter - Controller throws error when startscheduledate is a historical date
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update Reporter by providing a historical date as startscheduledate
    ...  Controller throws error

    ${date2}=  Subtract Time From Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}

    ${error_msg}=  Run Keyword and Expect Error  *  Update Reporter  reporter_name=${reporter_name}  organization=${operator}  start_schedule_date=${start_date}
    Should Contain  ${error_msg}  Schedule date must not be historical date

# ECQ-3789
Update Reporter - Controller throws error when startscheduledate format is invalid
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update Reporter by providing startscheduledate in invalid format
    ...  Controller throws error

    @{index}=  Split String  ${date1}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}

    ${error_msg}=  Run Keyword and Expect Error  *  Update Reporter  reporter_name=${reporter_name}  organization=${operator}   start_schedule_date=${date1}
    Should Contain  ${error_msg}  Parsing time \\\\"${date1}\\\\" as \\\\"2006-01-02T15:04:05Z07:00\\\\": cannot parse \\\\" ${index[1]}\\\\" as \\\\"T\\\\"

    ${error_msg}=  Run Keyword and Expect Error  *  Update Reporter  reporter_name=${reporter_name}  organization=${operator}   start_schedule_date=${start_date}
    Should Contain  ${error_msg}  Parsing time \\\\"${start_date}\\\\" as \\\\"2006-01-02T15:04:05Z07:00\\\\": cannot parse \\\\"\\\\" as \\\\"Z07:00\\\\"

# ECQ-3790
Update Reporter - Controller throws error when invalid timezone is provided
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update Reporter by providing invalid timezone
    ...  Controller throws error

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}

    ${error_msg}=  Run Keyword and Expect Error  *  Update Reporter  reporter_name=${reporter_name}  organization=${operator}  timezone=xx
    Should Contain  ${error_msg}  Invalid timezone xx, unknown time zone xx

# ECQ-3791
Update Reporter - Controller throws error when timezone is updated without providing startscheduledate
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update Reporter by providing only non default timezone
    ...  Controller throws error

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}

    ${error_msg}=  Run Keyword and Expect Error  *  Update Reporter  reporter_name=${reporter_name}  organization=${operator}  timezone=Asia/Kolkata
    Should Contain  ${error_msg}  Timezone must match start schedule date timezone

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
