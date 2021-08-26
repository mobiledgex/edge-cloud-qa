*** Settings ***
Documentation    Reporter Userrole tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${operator}  packet

*** Test Cases ***
# ECQ-3804
Developer Manager shall not be able to create/update/view/delete reporter
    [Documentation]
    ...  Login as Developer Manager
    ...  Controller throws error when user tries to create reporter
    ...  Controller throws 403 forbidden when user tries to update/view/delete reporter 

    Create Reporter  reporter_name=${reporter_name}  organization=dmuus  token=${super_token}
    ${dev_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Reporter can only be created for Operator org"}')  Create Reporter  reporter_name=${reporter_name}1  organization=automation_dev_org
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Reporter  reporter_name=${reporter_name}  organization=dmuus  schedule=Every15Days
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Reporter  reporter_name=${reporter_name}  organization=dmuus
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Reporter  reporter_name=${reporter_name}  organization=dmuus

# ECQ-3805
Developer Contributor shall not be able to create/update/view/delete reporter
    [Documentation]
    ...  Login as Developer Contributor
    ...  Controller throws error when user tries to create reporter
    ...  Controller throws 403 forbidden when user tries to update/view/delete reporter

    Create Reporter  reporter_name=${reporter_name}  organization=dmuus  token=${super_token}
    ${dev_token}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Reporter can only be created for Operator org"}')  Create Reporter  reporter_name=${reporter_name}1  organization=automation_dev_org
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Reporter  reporter_name=${reporter_name}  organization=dmuus  schedule=Every15Days
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Reporter  reporter_name=${reporter_name}  organization=dmuus
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Reporter  reporter_name=${reporter_name}  organization=dmuus

# ECQ-3806
Developer Viewer shall not be able to create/update/view/delete reporter
    [Documentation]
    ...  Login as Developer Viewer
    ...  Controller throws error when user tries to create reporter
    ...  Controller throws 403 forbidden when user tries to update/view/delete reporter

    Create Reporter  reporter_name=${reporter_name}  organization=dmuus  token=${super_token}
    ${dev_token}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Reporter can only be created for Operator org"}')  Create Reporter  reporter_name=${reporter_name}1  organization=automation_dev_org
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Reporter  reporter_name=${reporter_name}  organization=dmuus  schedule=Every15Days
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Reporter  reporter_name=${reporter_name}  organization=dmuus
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Reporter  reporter_name=${reporter_name}  organization=dmuus

# ECQ-3807
Operator Manager of an org cannot create/update/view/delete reporter of another org
    [Documentation]
    ...  Login as Operator Manager of org A
    ...  Controller throws 403 forbidden when user tries to create/update/view/delete reporter of org B

    Create Reporter  reporter_name=${reporter_name}  organization=packet  token=${super_token}
    ${op_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Reporter  reporter_name=${reporter_name}1  organization=packet
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Reporter  reporter_name=${reporter_name}  organization=packet  schedule=Every15Days
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Reporter  reporter_name=${reporter_name}  organization=packet
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Reporter  reporter_name=${reporter_name}  organization=packet

# ECQ-3808
Operator Contributor shall be able to create/update/view/delete reporter
     [Documentation]
    ...  Login as Operator Contributor
    ...  User shall be able to create/update/view/delete reporter

    ${op_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

    Create Reporter  reporter_name=${reporter_name}  organization=dmuus  auto_delete=${False}
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=dmuus
    Should Be Equal  ${reporter[0]['Name']}  ${reporter_name}
    ${reporter}=  Update Reporter  reporter_name=${reporter_name}  organization=dmuus  schedule=Every15Days
    Should Be Equal As Numbers  ${reporter[0]['Schedule']}  1
    Delete Reporter  reporter_name=${reporter_name}  organization=dmuus

# ECQ-3809
Operator Viewer shall not be able to create/update/delete reporter
     [Documentation]
    ...  Login as Operator Viewer
    ...  User shall be able to view reporter of that org
    ...  Controller throws 403 forbidden when user tries to create/update/delete reporter

    Create Reporter  reporter_name=${reporter_name}  organization=dmuus  token=${super_token}
    ${op_token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Reporter  reporter_name=${reporter_name}1  organization=dmuus  auto_delete=${False}
    ${reporter}=  Show Reporter  reporter_name=${reporter_name}  organization=dmuus
    Should Be Equal  ${reporter[0]['Name']}  ${reporter_name}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Reporter  reporter_name=${reporter_name}  organization=dmuus  schedule=Every15Days
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Reporter  reporter_name=${reporter_name}  organization=dmuus

 
*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${reporter_name}=  Get Default Reporter Name

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${reporter_name}
