*** Settings ***
Documentation  ShowAlertReceiver

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  DateTime
     
#Test Setup  Setup
Test Teardown  Cleanup Provisioning
 
Test Timeout  1m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-2923
ShowAlertReceiver - shall be able to show all alert receivers
   [Documentation]
   ...  - send ShowAlertReceiver with no args
   ...  - verify all receivers

   ${alert}=  Show Alert Receivers  

   Receivers Data Should Be Good  ${alert}

# ECQ-2924
ShowAlertReceiver - users should only see their own receivers
   [Documentation]
   ...  - create alert receivers as different users
   ...  - verify users cannot see each others receivers
   ...  - verify mexadmin can see all of them

   [Setup]  Setup Users

   ${alert11}=  Create Alert Receiver  receiver_name=${receiver_name}11  type=email  severity=info  developer_org_name=${orgname}  token=${user_token1}
   ${alert12}=  Create Alert Receiver  receiver_name=${receiver_name}12  type=slack  severity=info  developer_org_name=${orgname}  token=${user_token1}  slack_channel=mychannel  slack_api_url=http://slack.com
   ${alert13}=  Create Alert Receiver  receiver_name=${receiver_name}12  type=pagerduty  severity=info  developer_org_name=${orgname}  token=${user_token1}  pagerduty_integration_key=${pagerduty_key}

   ${alert21}=  Create Alert Receiver  receiver_name=${receiver_name}21  type=email  severity=info  developer_org_name=${orgname}  token=${user_token2}
   ${alert22}=  Create Alert Receiver  receiver_name=${receiver_name}22  type=slack  severity=info  developer_org_name=${orgname}  token=${user_token2}  slack_channel=mychannel  slack_api_url=http://slack.com
   ${alert23}=  Create Alert Receiver  receiver_name=${receiver_name}12  type=pagerduty  severity=info  developer_org_name=${orgname}  token=${user_token2}  pagerduty_integration_key=${pagerduty_key}

   ${show1}=  Show Alert Receivers  token=${user_token1}  use_defaults=${False}
   ${show2}=  Show Alert Receivers  token=${user_token2}  use_defaults=${False}
   ${show_admin}=  Show Alert Receivers  token=${super_token}  developer_org_name=${orgname}  use_defaults=${False}

   Length Should Be  ${show1}  3
   Length Should Be  ${show2}  3
   Length Should Be  ${show_admin}  6

   Should Be Equal  ${show1[0]['User']}  ${epochusername1}
   Should Be Equal  ${show1[1]['User']}  ${epochusername1}
   Should Be Equal  ${show2[0]['User']}  ${epochusername2}
   Should Be Equal  ${show2[1]['User']}  ${epochusername2}

# ECQ-2925
ShowAlertReceiver - org manager should see other receivers
   [Documentation]
   ...  - create alert receivers as contributors
   ...  - verify org manager can see the receivers

   [Setup]  Setup Users

   ${org_default}=  Get Default Organization Name

   ${orgname}=  Create Org  orgname=${org_default}1  token=${user_token1}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token1}     use_defaults=${False}

   ${alert11}=  Create Alert Receiver  receiver_name=${receiver_name}11  type=email  severity=info  developer_org_name=${orgname}  token=${user_token2}
   ${show1}=  Show Alert Receivers  user=${epochusername2}  developer_org_name=${orgname}  token=${user_token1}  use_defaults=${False}
   Should Be Equal  ${show1[0]}  ${alert11}

   ${alert12}=  Create Alert Receiver  receiver_name=${receiver_name}12  type=email  severity=info  cluster_instance_developer_org_name=${orgname}  token=${user_token2}
   ${show2}=  Show Alert Receivers  user=${epochusername2}  cluster_instance_developer_org_name=${orgname}  token=${user_token1}  use_defaults=${False}
   Should Be Equal  ${show2[0]}  ${alert12}

   ${alert13}=  Create Alert Receiver  receiver_name=${receiver_name}13  type=email  severity=info  operator_org_name=${orgname}  token=${user_token2}
   ${show3}=  Show Alert Receivers  user=${epochusername2}  operator_org_name=${orgname}  token=${user_token1}  use_defaults=${False}
   Should Be Equal  ${show3[0]}  ${alert13}

*** Keywords ***
#Setup
#   ${token}=  Get Super Token
#   Set Suite Variable  ${token}
#
#   ${policy_name}=  Get Default Privacy Policy Name
#   ${developer_name}=  Get Default Developer Name
#
#   Set Suite Variable  ${policy_name}
#   Set Suite Variable  ${developer_name}

Setup Users
   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername1}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token

   # No longer need to verify email to create user accounts EDC-2163 has been added using Skip Verify Config
   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername1}   password=${password}   email_address=${emailepoch}
   # Verify Email  email_address=${emailepoch}
   Unlock User
   ${user_token1}=  Login  username=${epochusername1}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   # Verify Email  email_address=${emailepoch2}
   Unlock User
   ${user_token2}=  Login  username=${epochusername2}  password=${password}

   ${orgname}=  Create Org  token=${super_token}  orgtype=developer
   Adduser Role   orgname=${orgname}   username=${epochusername1}   role=DeveloperManager    token=${super_token}     use_defaults=${False}
   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${super_token}     use_defaults=${False}

   ${receiver_name}=  Get Default Alert Receiver Name

   Set Suite Variable  ${receiver_name}
   Set Suite Variable  ${orgname}

   Set Suite Variable  ${user_token1}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername1}
   Set Suite Variable  ${epochusername2}
   Set Suite Variable  ${emailepoch2}
   Set Suite Variable  ${super_token}

Receivers Data Should Be Good
   [Arguments]  ${alert}

   FOR  ${a}  IN  @{alert}
      Should Be True  len('${a['Name']}') > 0
      Should Be True  '${a['Type']}' == 'email' or '${a['Type']}' == 'slack'  or '${a['Type']}' == 'pagerduty'
      Should Be True  '${a['Severity']}' == 'info' or '${a['Severity']}' == 'error' or '${a['Severity']}' == 'warn'
      Should Be True  len('${a['User']}') > 0
      #Should Be True  len('${a['Email']}') > 0
   END
