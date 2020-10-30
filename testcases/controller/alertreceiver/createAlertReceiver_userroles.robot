*** Settings ***
Documentation  CreateAlertReceiver for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password} 

${region}=  US

*** Test Cases ***
CreateAlertReceiver - DeveloperManager shall be able to create an alert receiver
   [Documentation]
   ...  - assign user to org as DeveloperManager 
   ...  - create an alert receiver
   ...  - verify receiver is created 

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  developer_org_name=${orgname}

CreateAlertReceiver - DeveloperContributor shall be able to create an alert receiver
   [Documentation]
   ...  - assign user to org as DeveloperContributor
   ...  - create an alert receiver
   ...  - verify receiver is created

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  developer_org_name=${orgname}

CreateAlertReceiver - DeveloperViewer shall be able to create an alert receiver
   [Documentation]
   ...  - assign user to org as DeveloperViewer
   ...  - create an alert receiver
   ...  - verify receiver is created

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer    token=${user_token}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  developer_org_name=${orgname}

CreateAlertReceiver - OperatorManager shall be able to create an alert receiver
   [Documentation]
   ...  - assign user to org as OperatorManager
   ...  - create an alert receiver
   ...  - verify receiver is created

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager    token=${user_token}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  developer_org_name=${orgname}

CreateAlertReceiver - OperatorContributor shall be able to create an alert receiver
   [Documentation]
   ...  - assign user to org as OperatorContributor
   ...  - create an alert receiver
   ...  - verify receiver is created

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  developer_org_name=${orgname}

CreateAlertReceiver - OperatorViewer shall be able to create an alert receiver
   [Documentation]
   ...  - assign user to org as OperatorViewer
   ...  - create an alert receiver
   ...  - verify receiver is created

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer    token=${user_token}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  developer_org_name=${orgname}

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
