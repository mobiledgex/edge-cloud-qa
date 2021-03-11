*** Settings ***
Documentation  DeleteAlertReceiver failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String

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
   ('code\=400', 'error\={"message":"no bearer token found"}')   use_defaults=${False}
   ('code\=401', 'error\={"message":"invalid or expired jwt"}')  token=xx  use_defaults=${False}

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

*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   ${receiver_name}=  Get Default Alert Receiver Name

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${receiver_name}

Fail Delete Alert Receiver
   [Arguments]  ${error_msg}  &{parms}

   ${std_create}=  Run Keyword and Expect Error  *  Delete Alert Receiver  &{parms}
   Should Be Equal  ${std_create}  ${error_msg}

