*** Settings ***
Documentation  CreatePrivacyPolicy for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  mextester06123mobiledgexisbadass

${region}=  US

*** Test Cases ***
CreateAlertReceiver - DeveloperManager shall be able to create an alert receiver
   [Documentation]
   ...  assign user to org as DeveloperManager 
   ...  do CreatePrivacyPolicy
   ...  verify policy is created 

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Alert Receiver  region=${region}  token=${user_token}  developer_org_name=${orgname}

CreatePrivacyPolicy - DeveloperContributor shall be able to create a privacy policy
   [Documentation]
   ...  assign user to org as DeveloperContributor
   ...  do CreatePrivacyPolicy
   ...  verify policy is created

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Alert Receiver  region=${region}  token=${user_token}  #receiver_name=${name}  developer_org_name=${developer}  use_defaults=${False}

CreatePrivacyPolicy - DeveloperViewer shall not be able to create a privacy policy
   [Documentation]
   ...  assign user to org as DeveloperViewer
   ...  do CreatePrivacyPolicy
   ...  verify error is returned 

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Alert Receiver  region=${region}  token=${user_token}  #receiver_name=${name}  developer_org_name=${developer}  use_defaults=${False}

CreatePrivacyPolicy - OperatorManager shall not be able to create a privacy policy
   [Documentation]
   ...  assign user to org as OperatorManager
   ...  attempt to do CreatePrivacyPolicy 
   ...  verify proper error is returned 

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Alert Receiver  token=${user_token2}  operator_org_name=${orgname}  #use_defaults=${False}

CreatePrivacyPolicy - OperatorContributor shall not be able to create a privacy policy
   [Documentation]
   ...  assign user to org as OperatorContributor
   ...  attempt to do CreatePrivacyPolicy
   ...  verify proper error is returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Privacy Policy  developer_org_name=${orgname}  token=${user_token2}  region=${region}  rule_list=${rulelist}

CreatePrivacyPolicy - OperatorViewer shall not be able to create a privacy policy
   [Documentation]
   ...  assign user to org as OperatorViewer
   ...  attempt to do CreatePrivacyPolicy
   ...  verify proper error is returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Privacy Policy  developer_org_name=${orgname}  token=${user_token2}  region=${region}  rule_list=${rulelist}

*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token

   # No longer need to verify email to create user accounts EDC-2163 has been added using Skip Verify Config
   Skip Verify Email  token=${super_token}  
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   # Verify Email  email_address=${emailepoch}
   Unlock User 
   ${user_token}=  Login  username=${epochusername}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   # Verify Email  email_address=${emailepoch2}
   Unlock User 
   ${user_token2}=  Login  username=${epochusername2}  password=${password}

   ${policy_name}=  Get Default Privacy Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}

   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}
