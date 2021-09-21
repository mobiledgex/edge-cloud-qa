*** Settings ***
Documentation    Create Reporter tests

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

${username}=   mextester06
${email}=      mextester06+op_manager@gmail.com
${password}=   ${mextester06_gmail_password}

${email1}=  mxdmnqa@gmail.com
${password1}=  zudfgojfrdhqntzm

*** Test Cases ***
# ECQ-3755
Shall be able to create a reporter with default arguments
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only name and org 
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Email']}  mextester06+op_manager@gmail.com
    Should Be Equal  ${reporter[0]['Username']}  op_manager_automation
    Should Be Equal  ${reporter[0]['Status']}  success

    Find Report Period  UTC  EveryWeek
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3756
Shall be able to create a reporter with future date as StartScheduleDate
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing future date as StartScheduleDate
    ...  Validate output of reporter show

    ${date2}=  Add Time To Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  start_schedule_date=${next_date}
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${next_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Not Be Equal  ${reporter[0]['Status']}  success

# ECQ-3757
Shall be able to create a reporter with schedule of Every15Days 
     [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default schedule of Every15Days
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=Every15Days
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

    Find Report Period  UTC  Every15Days
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3758
Shall be able to create a reporter with schedule of EveryMonth
     [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default schedule of EveryMonth
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=EveryMonth
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Add Time To Date  ${date1}  30 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  3

    Find Report Period  UTC  EveryMonth
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3759
Shall be able to create a reporter with non-default timezone
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing timezone other than UTC
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  timezone=Asia/Kolkata
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Be Equal  ${reporter[0]['Status']}  success

    Find Report Period  Asia/Kolkata  EveryWeek
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=Asia/Kolkata  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3760
Shall be able to create a reporter with email address
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing an email address which is not linked to the operator's account
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Email']}  ${email1}
    Should Be Equal  ${reporter[0]['Status']}  success

    Find Report Period  UTC  EveryWeek
    Email With Operator Report Should Be Received  email_password=${password1}  email_address=${email1}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3761
Shall be able to create a reporter with email address and schedule
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default email address and schedule
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}  schedule=Every15Days
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Email']}  ${email1}
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

    Find Report Period  UTC  Every15Days
    Email With Operator Report Should Be Received  email_password=${password1}  email_address=${email1}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3762
Shall be able to create a reporter with email address and StartScheduleDate
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default email address and StartScheduleDate
    ...  Validate output of reporter show

    ${date2}=  Add Time To Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}  start_schedule_date=${next_date}
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${next_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Not Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal  ${reporter[0]['Email']}  ${email1}

# ECQ-3763
Shall be able to create a reporter with email address and timezone
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default email address and timezone
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}  timezone=Asia/Kolkata
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal  ${reporter[0]['Email']}  ${email1}

    Find Report Period  Asia/Kolkata  EveryWeek
    Email With Operator Report Should Be Received  email_password=${password1}  email_address=${email1}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=Asia/Kolkata  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3764
Shall be able to create a reporter with schedule and StartScheduleDate
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default schedule and StartScheduleDate
    ...  Validate output of reporter show

    ${date2}=  Add Time To Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=Every15Days  start_schedule_date=${next_date}
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${next_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Not Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

# ECQ-3765
Shall be able to create a reporter with schedule and timezone
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default schedule and timezone
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=Every15Days  timezone=Asia/Kolkata
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30
    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

    Find Report Period  Asia/Kolkata  Every15Days
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=Asia/Kolkata  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3766
Shall be able to create a reporter with StartScheduleDate and timezone
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default StartScheduleDate and timezone
    ...  Validate output of reporter show

    ${date2}=  Add Time To Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  start_schedule_date=${next_date}  timezone=Asia/Kolkata
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${next_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Not Be Equal  ${reporter[0]['Status']}  success

# ECQ-3767
Shall be able to create a reporter with all optional args
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing non default values of all optional args
    ...  Validate output of reporter show

    ${date2}=  Add Time To Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    ${reporter}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}  schedule=Every15Days  start_schedule_date=${next_date}  timezone=Asia/Kolkata
    Sleep  15s
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}

    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${next_date}
    Should Be Equal  ${reporter[0]['NextScheduleDate']}   ${next_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Not Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal  ${reporter[0]['Email']}  ${email1}
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

# ECQ-3768
Shall be able to create 2 reporters with different timezones/schedule
    [Documentation]
    ...  Login as OperatorManager
    ...  Create 2 reporters with different timezones and schedules
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${reporter1}=  Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    ${reporter2}=  Create Reporter  reporter_name=${reporter_name}1  organization=${operator}  schedule=Every15Days  timezone=Asia/Kolkata
    Sleep  20s
    ${reporter1}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    ${reporter2}=  Show Reporter  reporter_name=${reporter_name}1  organization=${operator}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date1}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${current_date2}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30
    ${date}=  Add Time To Date  ${date1}  6 days
    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    @{index1}=  Split String  ${date}  ${SPACE}
    ${next_date1}=  Catenate  SEPARATOR=  ${index1[0]}  T00:00:00Z
    ${next_date2}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    Should Be Equal  ${reporter1[0]['StartScheduleDate']}  ${current_date1}
    Should Be Equal  ${reporter1[0]['NextScheduleDate']}   ${next_date1}
    Should Be Equal  ${reporter1[0]['Timezone']}  UTC
    Should Be Equal  ${reporter1[0]['Status']}  success

    Should Be Equal  ${reporter2[0]['StartScheduleDate']}  ${current_date2}
    Should Be Equal  ${reporter2[0]['NextScheduleDate']}   ${next_date2}
    Should Be Equal  ${reporter2[0]['Timezone']}  Asia/Kolkata
    Should Be Equal  ${reporter2[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter2[0]['Schedule']}  1

    Find Report Period  Asia/Kolkata  Every15Days
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}1  report_period=${report_period}  timezone=Asia/Kolkata  username=${op_manager_user_automation}  organization=${operator}

    Find Report Period  UTC  EveryWeek
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${reporter_name}=  Get Default Reporter Name
    ${date1}=  DateTime.Get Current Date  UTC

    Skip Verify Email   skip_verify_email=False

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${reporter_name}
    Set Suite Variable  ${op1_token}
    Set Suite Variable  ${date1}

Find Report Period
   [Arguments]  ${timezone}  ${schedule}

   ${current_date}=  MexApp.Get Current Time  ${timezone}
   Log to Console  ${current_date}
   
   IF  '${schedule}' == 'Every15Days'
   ${start_date}=  Subtract Time From Date  ${current_date}  15 days
   ELSE IF  '${schedule}' == 'EveryMonth'
   ${start_date}=  Subtract Time From Date  ${current_date}  31 days
   ELSE
   ${start_date}=  Subtract Time From Date  ${current_date}  7 days
   END

   ${end_date}=  Subtract Time From Date  ${current_date}  1 day
   @{index1}=  Split String  ${start_date}  ${SPACE}
   ${start_date}=  Set Variable  ${index1[0]}

   @{index2}=  Split String  ${end_date}  ${SPACE}
   ${end_date}=  Set Variable  ${index2[0]}

   ${report_period}=  Set Variable  ${start_date} to ${end_date}
   ${report_period}=  Replace String  ${report_period}  -  /

   Set Suite Variable  ${report_period}
