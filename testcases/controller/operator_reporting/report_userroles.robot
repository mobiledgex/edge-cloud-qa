*** Settings ***
Documentation    Report Generate/View/Download Userrole tests

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
# ECQ-3821
Developer Manager shall not be able to generate/view/download reports
    [Documentation]
    ...  Login as Developer Manager
    ...  Controller throws 403 forbidden when user tries to generate/view/download report 

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    ${report_list}=  Show Report  organization=${operator}  token=${op1_token}
    ${filename}=  Set Variable  ${report_list[-1]}

    ${dev_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  use_defaults=${False}  token=${dev_token}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Report  organization=${operator}  token=${dev_token}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Download Report  organization=${operator}  filename=${filename}  token=${dev_token}

# ECQ-3822
Developer Contributor shall not be able to generate/view/download reports
    [Documentation]
    ...  Login as Developer Contributor
    ...  Controller throws 403 forbidden when user tries to generate/view/download report

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    ${report_list}=  Show Report  organization=${operator}  token=${op1_token}
    ${filename}=  Set Variable  ${report_list[-1]}

    ${dev_token}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  use_defaults=${False}  token=${dev_token}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Report  organization=${operator}  token=${dev_token}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Download Report  organization=${operator}  filename=${filename}  token=${dev_token}

# ECQ-3823
Developer Viewer shall not be able to generate/view/download reports
    [Documentation]
    ...  Login as Developer Viewer
    ...  Controller throws 403 forbidden when user tries to generate/view/download report

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=${operator}  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    ${report_list}=  Show Report  organization=${operator}  token=${op1_token}
    ${filename}=  Set Variable  ${report_list[-1]}

    ${dev_token}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  use_defaults=${False}  token=${dev_token}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Report  organization=${operator}  token=${dev_token}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Download Report  organization=${operator}  filename=${filename}  token=${dev_token}

# ECQ-3824
Operator Contributor shall be able to generate/view/download reports
     [Documentation]
    ...  Login as Operator Contributor
    ...  User shall be able to generate/view/download report

    Run Keyword And Ignore Error  Adduser Role  username=${op_contributor_user_automation}  orgname=${operator}  role=OperatorContributor  token=${super_token}
    ${op_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

    Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  use_defaults=${False}  token=${op_token}

    ${report_list}=  Show Report  organization=${operator}  token=${op_token}
    ${filename}=  Set Variable  ${report_list[-1]}

    Download Report  organization=${operator}  filename=${filename}  token=${op_token}

# ECQ-3825
Operator Viewer shall be able to generate/view/download reports
     [Documentation]
    ...  Login as Operator Viewer
    ...  User shall be able to generate/view/download report

    Run Keyword And Ignore Error  Adduser Role  username=${op_viewer_user_automation}  orgname=${operator}  role=OperatorViewer  token=${super_token}
    ${op_token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

    Generate Report  organization=${operator}  start_time=${start_date}  end_time=${end_date}  use_defaults=${False}  token=${op_token}

    ${report_list}=  Show Report  organization=${operator}  token=${op_token}
    ${filename}=  Set Variable  ${report_list[-1]}

    Download Report  organization=${operator}  filename=${filename}  token=${op_token}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${date1}=  DateTime.Get Current Date  UTC

    @{index}=  Split String  ${date1}  ${SPACE}
    ${end_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z
    ${date2}=  Subtract Time From Date  ${date1}  7 days
    @{index}=  Split String  ${date2}  ${SPACE}
    ${start_date}=  Catenate  SEPARATOR=  ${index[0]}  T00:00:00Z

    Set Suite Variable  ${start_date}
    Set Suite Variable  ${end_date}
    Set Suite Variable  ${super_token}
