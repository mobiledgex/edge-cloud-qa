*** Settings ***
Documentation  DeleteAlertReceiver failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${developer}=  MobiledgeX
${username}=  mexadmin
${mexadmin_password}=  mexadminfastedgecloudinfra

*** Test Cases ***
# ECQ-2918
DeleteAlertReveiver - missing/invalid/empty parms shall return error
   [Documentation]
   ...  - send alertreceiver delete with various missing/invalid/empty parms
   ...  - verify proper error is received

   [Template]  Fail Delete Alert Receiver

   # no/invalid token
   ('code\=400', 'error\={"message":"No bearer token found"}')   use_defaults=${False}
   ('code\=401', 'error\={"message":"Invalid or expired jwt"}')  token=xx  use_defaults=${False}

   # no parms
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"\\\\" of type ${SPACE}and severity ${SPACE}for user \\\\"mexadmin\\\\"]"}')  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type ${SPACE}and severity info for user \\\\"mexadmin\\\\"]"}')  token=${super_token}  receiver_name=${receiver_name}  severity=info  use_defaults=${False}
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type email and severity ${SPACE}for user \\\\"mexadmin\\\\"]"}')  token=${super_token}  receiver_name=${receiver_name}  type=email  use_defaults=${False}
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type ${SPACE}and severity info for user \\\\"mexadmin\\\\"]"}')  token=${super_token}  receiver_name=${receiver_name}  type=${empty}  severity=info  use_defaults=${False}
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type email and severity ${SPACE}for user \\\\"mexadmin\\\\"]"}')  token=${super_token}  receiver_name=${receiver_name}  type=email  severity=${Empty}   use_defaults=${False}
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type ${SPACE}and severity ${SPACE}for user \\\\"mexadmin\\\\"]"}')  token=${super_token}  receiver_name=${receiver_name}  type=${Empty}  severity=${Empty}   use_defaults=${False}

   # alert receiver not found
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type email and severity info for user \\\\"mexadmin\\\\"]"}')  type=email  severity=info
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type email and severity error for user \\\\"mexadmin\\\\"]"}')  type=email  severity=error
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type email and severity warn for user \\\\"mexadmin\\\\"]"}')  type=email  severity=warn 
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type slack and severity info for user \\\\"mexadmin\\\\"]"}')  type=slack  severity=info
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type slack and severity error for user \\\\"mexadmin\\\\"]"}')  type=slack  severity=error
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type slack and severity warn for user \\\\"mexadmin\\\\"]"}')  type=slack  severity=warn
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type pagerduty and severity info for user \\\\"mexadmin\\\\"]"}')  type=pagerduty  severity=info
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type pagerduty and severity error for user \\\\"mexadmin\\\\"]"}')  type=pagerduty  severity=error
   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type pagerduty and severity warn for user \\\\"mexadmin\\\\"]"}')  type=pagerduty  severity=warn

   ('code\=400', 'error\={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type z and severity a for user \\\\"mexadmin\\\\"]"}')  type=z  severity=a

   ('code\=400', 'error\={"message":"Org details must be present to manage a specific receiver"}')  token=${super_token}  receiver_name=${receiver_name}  type=email  severity=info  user=xxx  use_defaults=${False}

# ECQ-2919
DeleteAlertReceiver - delete alertreceiver from another user shall return error
   [Documentation]
   ...  - create alertreceiver as mexadmin
   ...  - send alertreceiver delete as qaadmin
   ...  - verify error is returned

   ${receiver_name}=  Get Default Alert Receiver Name

   ${alert}=  Create Alert Receiver  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${developer}  #use_defaults=${False}

   Login  username=qaadmin  password=${mexadmin_password}

   ${error}=  Run Keyword and Expect Error  *  Delete Alert Receiver  type=email  severity=info
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Unable to delete a receiver - bad response status 404 Not Found[No receiver \\\\"${receiver_name}\\\\" of type email and severity info for user \\\\"qaadmin\\\\"]"}')

# ECQ-4420
DeleteAlertReceiver - delete alertreceiver from another org shall return error
   [Documentation]
   ...  - create 2 users
   ...  - create new org on user1
   ...  - create alertreceiver as user1 with new org 
   ...  - send alertreceiver delete as user2 on new org
   ...  - verify error is returned

   ${receiver_name}=  Get Default Alert Receiver Name

   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername}   password=${mextester06_gmail_password}   email_address=${emailepoch}
   Unlock User

   ${user_token1}=  Login  username=${epochusername}  password=${mextester06_gmail_password}
   ${user_token2}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

   ${orgname}=  Create Org  token=${user_token1}  orgtype=developer

   ${alert1}=  Create Alert Receiver  token=${user_token1}  receiver_name=${receiver_name}1  type=email  severity=info  developer_org_name=${orgname}
   ${alert2}=  Create Alert Receiver  token=${user_token1}  receiver_name=${receiver_name}2  type=email  severity=info  cluster_instance_developer_org_name=${orgname}

   ${error1}=  Run Keyword and Expect Error  *  Delete Alert Receiver  token=${user_token2}  receiver_name=${receiver_name}1  type=email  severity=info  developer_org_name=${orgname}
   ${error2}=  Run Keyword and Expect Error  *  Delete Alert Receiver  token=${user_token2}  receiver_name=${receiver_name}2  type=email  severity=info  cluster_instance_developer_org_name=${orgname}

   Should Be Equal  ${error1}  ('code=403', 'error={"message":"Forbidden"}')
   Should Be Equal  ${error2}  ('code=403', 'error={"message":"Forbidden"}')

*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   ${receiver_name}=  Get Default Alert Receiver Name

   ${epoch}=  Get Current Date  result_format=epoch
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${receiver_name}
   Set Suite Variable  ${epochusername}
   Set Suite Variable  ${emailepoch}

Fail Delete Alert Receiver
   [Arguments]  ${error_msg}  &{parms}

   ${std_create}=  Run Keyword and Expect Error  *  Delete Alert Receiver  &{parms}
   Should Be Equal  ${std_create}  ${error_msg}

