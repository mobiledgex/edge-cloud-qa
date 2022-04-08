*** Settings ***
Documentation   CreateClusterInst with cloudlet maintenance failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US
${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-4449
ShowEvents - an org with reused name shall not see events from previous org
    [Documentation]
    ...  - create an org and add a user
    ...  - verify correct events show
    ...  - delete the org and recreate with the same name
    ...  - add user to the org
    ...  - verify events dont show the events from the previous use of the org
 
    Sleep  5s

    ${events_admin_1}=  Show Events  region=${region}  org_name=${op_org}  token=${super_token}
    ${events_op_0_1}=   Show Events  region=${region}  org_name=${op_org}  token=${tokenop_0}
    ${events_op_1_1}=   Show Events  region=${region}  org_name=${op_org}  token=${tokenop_1}

    Delete Org  orgname=${op_org}  token=${tokenop_0}

    ${op_org}=  Create Org  orgtype=operator  token=${tokenop_0}  auto_delete=${False}  auto_delete=${False}
    Adduser Role  username=${usernameop_epoch1}  orgname=${op_org}  role=OperatorManager  token=${tokenop_0}

    Sleep  5s
    ${events_admin_2}=  Show Events  region=${region}  org_name=${op_org}  token=${super_token}
    ${events_op_0_2}=   Show Events  region=${region}  org_name=${op_org}  token=${tokenop_0}
    ${events_op_1_2}=   Show Events  region=${region}  org_name=${op_org}  token=${tokenop_1}

    Should Not Be Equal  ${events_op_0_1[0]['timestamp']}  ${events_op_0_2[0]['timestamp']}
    Should Not Be Equal  ${events_op_1_1[0]['timestamp']}  ${events_op_1_2[0]['timestamp']}

    Length Should Be  ${events_admin_1}  2
    Length Should Be  ${events_admin_2}  5

    Length Should Be  ${events_op_0_1}  2
    Length Should Be  ${events_op_0_2}  2

    Length Should Be  ${events_op_1_1}  2
    Length Should Be  ${events_op_1_2}  2

*** Keywords ***
Setup
    ${super_token}=  Get Super Token

    ${epoch}=  Get Time  epoch
    ${usernameop_epoch0}=  Set Variable  ${username}op${epoch}_0
    ${usernameop_epoch1}=  Set Variable  ${username}op${epoch}_1
    ${emailop0}=  Set Variable  ${usernameop_epoch0}@gmail.com
    ${emailop1}=  Set Variable  ${usernameop_epoch1}@gmail.com

    Skip Verify Email
    Create User  username=${usernameop_epoch0}  password=${password}  email_address=${emailop0}  auto_delete=${False}
    Unlock User
    ${tokenop_0}=  Login  username=${usernameop_epoch0}  password=${password}

    Create User  username=${usernameop_epoch1}  password=${password}  email_address=${emailop1}
    Unlock User

    ${tokenop_1}=  Login  username=${usernameop_epoch1}  password=${password}

    ${op_org}=  Create Org  orgtype=operator  token=${tokenop_0}  auto_delete=${False}

    Adduser Role  username=${usernameop_epoch1}  orgname=${op_org}  role=OperatorManager  token=${tokenop_0}

    Set Suite Variable  ${usernameop_epoch0}
    Set Suite Variable  ${usernameop_epoch1}
    Set Suite Variable  ${super_token}
    Set Suite Variable  ${tokenop_0}
    Set Suite Variable  ${tokenop_1}
    Set Suite Variable  ${op_org}

Teardown
    Cleanup Provisioning
    Delete Org  orgname=${op_org}  token=${super_token}
    Delete User  username=${usernameop_epoch0}  token=${super_token}
