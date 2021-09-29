*** Settings ***
Documentation    Update Reporter tests

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
# ECQ-3775
Shall be able to update email address of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update email address of the reporter
    ...  Validate output of reporter show

    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Email']}  ${email1}
    Should Be Equal  ${reporter[0]['Username']}  op_manager_automation
    Should Be Equal  ${reporter[0]['Status']}  success

# ECQ-3776
Shall be able to update schedule of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update schedule of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    Find Report Period  UTC  EveryWeek
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=Every15Days
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Email']}  ${email}
    Should Be Equal  ${reporter[0]['Username']}  op_manager_automation
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

    Find Report Period  UTC  Every15Days
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3777
Shall be able to update StartScheduleDate of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing next date as StartScheduleDate
    ...  Update StartScheduleDate of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${date2}=  Add Time To Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}  start_schedule_date=${next_date}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
 
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
 
    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  start_schedule_date=${current_date}

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Status']}  success

    Find Report Period  UTC  EveryWeek
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3778
Shall be able to update timezone of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update timezone of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  timezone=Asia/Kolkata  start_schedule_date=${current_date}

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Be Equal  ${reporter[0]['Status']}  success

    Find Report Period  Asia/Kolkata  EveryWeek
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=Asia/Kolkata  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3779
Shall be able to update email address and schedule of a reporter
     [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update email address and schedule of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}  schedule=Every15Days

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Email']}  ${email1}
    Should Be Equal  ${reporter[0]['Username']}  op_manager_automation
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

    Find Report Period  UTC  Every15Days
    Email With Operator Report Should Be Received  email_password=${password1}  email_address=${email1}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3780
Shall be able to update email address and StartScheduleDate of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing next date as StartScheduleDate
    ...  Update email address and StartScheduleDate of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${date2}=  Add Time To Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}  start_schedule_date=${next_date}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}  start_schedule_date=${current_date}

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal  ${reporter[0]['Email']}  ${email1}

    Find Report Period  UTC  EveryWeek
    Email With Operator Report Should Be Received  email_password=${password1}  email_address=${email1}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3781
Shall be able to update email address and timezone of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update email address and timezone of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30
    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}  timezone=Asia/Kolkata  start_schedule_date=${current_date}

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal  ${reporter[0]['Email']}  ${email1}

    Find Report Period  Asia/Kolkata  EveryWeek
    Email With Operator Report Should Be Received  email_password=${password1}  email_address=${email1}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=Asia/Kolkata  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3782
Shall be able to update schedule and StartScheduleDate of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter with next date as StartScheduleDate
    ...  Update schedule and StartScheduleDate of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${date2}=  Add Time To Date  ${date1}  1 day
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}  start_schedule_date=${next_date}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=Every15Days  start_schedule_date=${current_date}

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  UTC
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

    Find Report Period  UTC  Every15Days
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=UTC  username=${op_manager_user_automation}  organization=${operator}

# ECQ-3783
Shall be able to update schedule and timezone of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update schedule and timezone of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30
    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  schedule=Every15Days  timezone=Asia/Kolkata  start_schedule_date=${current_date}

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

    Find Report Period  Asia/Kolkata  Every15Days
    Email With Operator Report Should Be Received  email_password=${mextester06_gmail_password}  email_address=${email}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=Asia/Kolkata  username=${op_manager_user_automation}  organization=${operator}

ECQ-3784
Shall be able to update all optional args of a reporter
    [Documentation]
    ...  Login as OperatorManager
    ...  Create a Reporter by providing only mandatory args
    ...  Update all optional args of the reporter
    ...  Validate output of reporter show
    ...  Verify that email with operator report is received

    ${date2}=  Add Time To Date  ${date1}  6 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Create Reporter  reporter_name=${reporter_name}  organization=${operator}
    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    @{index}=  Split String  ${date1}  ${SPACE}
    ${current_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    ${date2}=  Add Time To Date  ${date1}  14 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${next_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00+05:30

    Update Reporter  reporter_name=${reporter_name}  organization=${operator}  email_address=${email1}  schedule=Every15Days  start_schedule_date=${current_date}  timezone=Asia/Kolkata

    Wait For Next Schedule Date  reporter_name=${reporter_name}  organization=${operator}  next_schedule_date=${next_date}

    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=${operator}
    Should Be Equal  ${reporter[0]['StartScheduleDate']}  ${current_date}
    Should Be Equal  ${reporter[0]['Timezone']}  Asia/Kolkata
    Should Be Equal  ${reporter[0]['Status']}  success
    Should Be Equal  ${reporter[0]['Email']}  ${email1}
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1

    Find Report Period  Asia/Kolkata  Every15Days
    Email With Operator Report Should Be Received  email_password=${password1}  email_address=${email1}  reporter_name=${reporter_name}  report_period=${report_period}  timezone=Asia/Kolkata  username=${op_manager_user_automation}  organization=${operator}


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
