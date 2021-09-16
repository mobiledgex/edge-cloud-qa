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
# ECQ-3813
Generate Report - Controller throws error if start time comes before end time
    [Documentation]
    ...  Login as OperatorManager
    ...  Generate a report with start time before end time
    ...  Controller throws error

    @{index}=  Split String  ${date1}  ${SPACE}
    ${start_time}=  Catenate  SEPARATOR=  ${index[0]}  T${index[1]}Z
    ${date2}=  Subtract Time From Date  ${date1}  7 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${end_time}=  Catenate  SEPARATOR=  ${index[0]}  T${index[1]}Z

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Start time must be before end time"}')  Generate Report  organization=${operator}  start_time=${start_time}  end_time=${end_time}  use_defaults=${False}  token=${op1_token}

# ECQ-3814
Generate Report - Controller throws error if report duration is greater than 31 days
    [Documentation]
    ...  Login as OperatorManager
    ...  Generate a report with report duration greater than 31 days
    ...  Controller throws error

    @{index}=  Split String  ${date1}  ${SPACE}
    ${end_time}=  Catenate  SEPARATOR=  ${index[0]}  T${index[1]}Z
    ${date2}=  Subtract Time From Date  ${date1}  32 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${start_time}=  Catenate  SEPARATOR=  ${index[0]}  T${index[1]}Z

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Time range must not be more than 31 days"}')  Generate Report  organization=${operator}  start_time=${start_time}  end_time=${end_time}  use_defaults=${False}  token=${op1_token}

# ECQ-3815
Generate Report - Controller throws error if timezone does not match start time's timezone
    [Documentation]
    ...  Login as OperatorManager
    ...  Generate a report with starttime/endtime in UTC and non default timezone
    ...  Controller throws error

    ${end_date}=  MexApp.Get Current Time  Asia/Kolkata
    ${start_date}=  Subtract Time From Date  ${end_date}  7 days
    @{index1}=  Split String  ${end_date}  ${SPACE}
    ${end_date}=  Catenate  SEPARATOR=  ${index1[0]}  T${index1[1]}Z
    @{index2}=  Split String  ${start_date}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index2[0]}  T${index2[1]}Z

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Timezone must match start time\\'s timezone"}')  Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  timezone=Asia/Kolkata  use_defaults=${False}  token=${op1_token}

# ECQ-3816
Generate Report - Controller throws error if start time format is invalid
    [Documentation]
    ...  Login as OperatorManager
    ...  Generate report by providing start time in invalid format
    ...  Controller throws error

    ${end_date}=  MexApp.Get Current Time  Asia/Kolkata
    ${start_date}=  Subtract Time From Date  ${end_date}  7 days
    @{index1}=  Split String  ${end_date}  ${SPACE}
    ${end_date}=  Catenate  SEPARATOR=  ${index1[0]}  T${index1[1]}+05:30
    @{index2}=  Split String  ${start_date}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index2[0]}  T${index2[1]}+0530

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal time \\\\"${start_date}\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}')  Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  timezone=Asia/Kolkata  use_defaults=${False}  token=${op1_token}

# ECQ-3817
Generate Report - Controller throws error if end time format is invalid
    [Documentation]
    ...  Login as OperatorManager
    ...  Generate report by providing end time in invalid format
    ...  Controller throws error

    ${end_date}=  MexApp.Get Current Time  Asia/Kolkata
    ${start_date}=  Subtract Time From Date  ${end_date}  7 days
    @{index1}=  Split String  ${end_date}  ${SPACE}
    ${end_date}=  Catenate  SEPARATOR=  ${index1[0]}  T${index1[1]}+0530
    @{index2}=  Split String  ${start_date}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index2[0]}  T${index2[1]}+05:30

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal time \\\\"${end_date}\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}')  Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  timezone=Asia/Kolkata  use_defaults=${False}  token=${op1_token}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${date1}=  DateTime.Get Current Date  UTC  exclude_millis=yes

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${op1_token}
    Set Suite Variable  ${date1}
