*** Settings ***
Documentation  DeleteAlertReceiver userroles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${developer}=  MobiledgeX

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

*** Test Cases ***
# ECQ-2920
DeleteAlertReceiver - developer org owner shall be able to delete alertreceiver from another user
   [Documentation]
   ...  - create alertreceiver as a user
   ...  - send alertreceiver delete as another user
   ...  - verify forbidden is returned
   ...  - send alertreceiver delete as the org owner
   ...  - verify receiver is deleted

   ${orgname}=  Create Org  token=${user_token_owner}  orgtype=developer
   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token_owner}     use_defaults=${False}
   Adduser Role   orgname=${orgname}   username=${epochusername3}   role=DeveloperContributor    token=${user_token_owner}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}  auto_delete=${False} 

   ${alertshow_pre}=  Show Alert Receivers  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}
   Length Should Be  ${alertshow_pre}  1

   ${error}=  Run Keyword and Expect Error  *  Delete Alert Receiver  token=${user_token3}  type=email  severity=info  user=${epochusername2}  developer_org_name=${orgname}
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   Delete Alert Receiver  token=${user_token_owner}  type=email  severity=info  user=${epochusername2}  developer_org_name=${orgname}
  
   ${alertshow_post}=  Show Alert Receivers  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}
   Length Should Be  ${alertshow_post}  0

# ECQ-2921
DeleteAlertReceiver - operator org owner shall be able to delete alertreceiver from another user
   [Documentation]
   ...  - create alertreceiver as a user
   ...  - send alertreceiver delete as another user
   ...  - verify forbidden is returned
   ...  - send alertreceiver delete as the org owner
   ...  - verify receiver is deleted

   ${orgname}=  Create Org  token=${user_token_owner}  orgtype=operator
   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token_owner}     use_defaults=${False}
   Adduser Role   orgname=${orgname}   username=${epochusername3}   role=OperatorContributor    token=${user_token_owner}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}  auto_delete=${False}

   ${alertshow_pre}=  Show Alert Receivers  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}
   Length Should Be  ${alertshow_pre}  1

   ${error}=  Run Keyword and Expect Error  *  Delete Alert Receiver  token=${user_token3}  type=email  severity=info  user=${epochusername2}  developer_org_name=${orgname}
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   Delete Alert Receiver  token=${user_token_owner}  type=email  severity=info  user=${epochusername2}  developer_org_name=${orgname}

   ${alertshow_post}=  Show Alert Receivers  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}
   Length Should Be  ${alertshow_post}  0

# ECQ-2922
DeleteAlertReceiver - mexadmin shall be able to delete alertreceiver from another user
   [Documentation]
   ...  - create alertreceiver as a user
   ...  - send alertreceiver delete as another user
   ...  - verify forbidden is returned
   ...  - send alertreceiver delete as mexadmin
   ...  - verify receiver is deleted

   ${orgname}=  Create Org  token=${user_token_owner}  orgtype=developer
   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token_owner}     use_defaults=${False}
   Adduser Role   orgname=${orgname}   username=${epochusername3}   role=DeveloperContributor    token=${user_token_owner}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}  auto_delete=${False}

   ${alertshow_pre}=  Show Alert Receivers  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}
   Length Should Be  ${alertshow_pre}  1

   ${error}=  Run Keyword and Expect Error  *  Delete Alert Receiver  token=${user_token3}  type=email  severity=info  user=${epochusername2}  developer_org_name=${orgname}
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   Delete Alert Receiver  token=${super_token}  type=email  severity=info  user=${epochusername2}  developer_org_name=${orgname}

   ${alertshow_post}=  Show Alert Receivers  token=${user_token2}  receiver_name=${receiver_name}  type=email  severity=info  developer_org_name=${orgname}
   Length Should Be  ${alertshow_post}  0
 
*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   ${receiver_name}=  Get Default Alert Receiver Name

   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${emailepoch3}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  3  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2
   ${epochusername3}=  Catenate  SEPARATOR=  ${username}  ${epoch}  3

   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   ${user_token_owner}=  Login  username=${epochusername}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   Unlock User
   ${user_token2}=  Login  username=${epochusername2}  password=${password}

   Create User  username=${epochusername3}   password=${password}   email_address=${emailepoch3}
   Unlock User
   ${user_token3}=  Login  username=${epochusername3}  password=${password}

   ${receiver_name}=  Get Default Alert Receiver Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${receiver_name}
   Set Suite Variable  ${developer_name}

   Set Suite Variable  ${user_token_owner}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}
   Set Suite Variable  ${emailepoch2}
   Set Suite Variable  ${user_token3}
   Set Suite Variable  ${epochusername3}

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${receiver_name}
