*** Settings ***
Documentation  CreateAlertReceiver for user roles
          ...  - assign user to org as DeveloperManager/DeveloperContributor/DeveloperViewer/OperatorManager/OperatorContributor/OperatorViewer
          ...  - create an alert receiver
          ...  - verify receiver is created

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Template  User with role shall be able to create an alert receiver 

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password} 

${region}=  US

*** Test Cases ***
CreateAlertReceiver - DeveloperManager shall be able to create an alert receiver      orgtype=developer  role=DeveloperManager
CreateAlertReceiver - DeveloperContributor shall be able to create an alert receiver  orgtype=developer  role=DeveloperContributor
CreateAlertReceiver - DeveloperViewer shall be able to create an alert receiver       orgtype=developer  role=DeveloperViewer
CreateAlertReceiver - OperatorManager shall be able to create an alert receiver       orgtype=operator   role=OperatorManager
CreateAlertReceiver - OperatorContributor shall be able to create an alert receiver   orgtype=operator   role=OperatorContributor
CreateAlertReceiver - OperatorViewer shall be able to create an alert receiver        orgtype=operator   role=OperatorViewer

#CreateAlertReceiver - DeveloperManager shall be able to create an alert receiver
#   [Documentation]
#   ...  - assign user to org as DeveloperManager 
#   ...  - create an alert receiver
#   ...  - verify receiver is created 
#
#   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
#   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}
#
#   ${alert1}=  Create Alert Receiver  receiver_name=${receiver_name}_1  token=${user_token2}  developer_org_name=${orgname}
#   Should Be Equal  ${alert1['Name']}  ${receiver_name}_1
#   Should Be Equal  ${alert1['User']}  ${epochusername2}
#   Should Be Equal  ${alert1['Email']}  ${emailepoch2}
#   Should Be Equal  ${alert1['AppInst']['app_key']['organization']}  ${orgname}
#   Should Be Empty  ${alert1['Cloudlet']}
#   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cluster_key']}
#
#   ${alert2}=  Create Alert Receiver  receiver_name=${receiver_name}_2  token=${user_token2}  operator_org_name=${orgname}
#   Should Be Equal  ${alert2['Name']}  ${receiver_name}_2
#   Should Be Equal  ${alert2['User']}  ${epochusername2}
#   Should Be Equal  ${alert2['Email']}  ${emailepoch2}
#   Should Be Empty  ${alert2['AppInst']['app_key']}
#   Should Be Equal  ${alert2['Cloudlet']['organization']}  ${orgname}
#   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cluster_key']}
#
#   #https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022  https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022`
#   ${alert3}=  Create Alert Receiver  receiver_name=${receiver_name}_3  token=${user_token2}  cluster_instance_developer_org_name=${orgname}
#   Should Be Equal  ${alert3['Name']}  ${receiver_name}_3
#   Should Be Equal  ${alert3['User']}  ${epochusername2}
#   Should Be Equal  ${alert3['Email']}  ${emailepoch2}
#   Should Be Empty  ${alert3['AppInst']['app_key']}
#   Should Be Equal  ${alert3['Cloudlet']['organization']}  ${orgname}
#   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cluster_key']}
#
#CreateAlertReceiver - DeveloperContributor shall be able to create an alert receiver
#   [Documentation]
#   ...  - assign user to org as DeveloperContributor
#   ...  - create an alert receiver
#   ...  - verify receiver is created
#
#   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
#   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token}     use_defaults=${False}
#
#   ${alert1}=  Create Alert Receiver  receiver_name=${receiver_name}_1  token=${user_token2}  developer_org_name=${orgname}
#   Should Be Equal  ${alert1['Name']}  ${receiver_name}_1
#   Should Be Equal  ${alert1['User']}  ${epochusername2}
#   Should Be Equal  ${alert1['Email']}  ${emailepoch2}
#   Should Be Equal  ${alert1['AppInst']['app_key']['organization']}  ${orgname}
#   Should Be Empty  ${alert1['Cloudlet']}
#   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cluster_key']}
#
#   ${alert2}=  Create Alert Receiver  receiver_name=${receiver_name}_2  token=${user_token2}  operator_org_name=${orgname}
#   Should Be Equal  ${alert2['Name']}  ${receiver_name}_2
#   Should Be Equal  ${alert2['User']}  ${epochusername2}
#   Should Be Equal  ${alert2['Email']}  ${emailepoch2}
#   Should Be Empty  ${alert2['AppInst']['app_key']}
#   Should Be Equal  ${alert2['Cloudlet']['organization']}  ${orgname}
#   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cluster_key']}
#
#   #https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022  https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022`
#   ${alert3}=  Create Alert Receiver  receiver_name=${receiver_name}_3  token=${user_token2}  cluster_instance_developer_org_name=${orgname}
#   Should Be Equal  ${alert3['Name']}  ${receiver_name}_3
#   Should Be Equal  ${alert3['User']}  ${epochusername2}
#   Should Be Equal  ${alert3['Email']}  ${emailepoch2}
#   Should Be Empty  ${alert3['AppInst']['app_key']}
#   Should Be Equal  ${alert3['Cloudlet']['organization']}  ${orgname}
#   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cluster_key']}
#
#CreateAlertReceiver - DeveloperViewer shall be able to create an alert receiver
#   [Documentation]
#   ...  - assign user to org as DeveloperViewer
#   ...  - create an alert receiver
#   ...  - verify receiver is created
#
#   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
#   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer    token=${user_token}     use_defaults=${False}
#
#   ${alert1}=  Create Alert Receiver  receiver_name=${receiver_name}_1  token=${user_token2}  developer_org_name=${orgname}
#   Should Be Equal  ${alert1['Name']}  ${receiver_name}_1
#   Should Be Equal  ${alert1['User']}  ${epochusername2}
#   Should Be Equal  ${alert1['Email']}  ${emailepoch2}
#   Should Be Equal  ${alert1['AppInst']['app_key']['organization']}  ${orgname}
#   Should Be Empty  ${alert1['Cloudlet']}
#   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cluster_key']}
#
#   ${alert2}=  Create Alert Receiver  receiver_name=${receiver_name}_2  token=${user_token2}  operator_org_name=${orgname}
#   Should Be Equal  ${alert2['Name']}  ${receiver_name}_2
#   Should Be Equal  ${alert2['User']}  ${epochusername2}
#   Should Be Equal  ${alert2['Email']}  ${emailepoch2}
#   Should Be Empty  ${alert2['AppInst']['app_key']}
#   Should Be Equal  ${alert2['Cloudlet']['organization']}  ${orgname}
#   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cluster_key']}
#
#   #https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022  https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022`
#   ${alert3}=  Create Alert Receiver  receiver_name=${receiver_name}_3  token=${user_token2}  cluster_instance_developer_org_name=${orgname}
#   Should Be Equal  ${alert3['Name']}  ${receiver_name}_3
#   Should Be Equal  ${alert3['User']}  ${epochusername2}
#   Should Be Equal  ${alert3['Email']}  ${emailepoch2}
#   Should Be Empty  ${alert3['AppInst']['app_key']}
#   Should Be Equal  ${alert3['Cloudlet']['organization']}  ${orgname}
#   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cluster_key']}
#
#CreateAlertReceiver - OperatorManager shall be able to create an alert receiver
#   [Documentation]
#   ...  - assign user to org as OperatorManager
#   ...  - create an alert receiver
#   ...  - verify receiver is created
#
#   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
#   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager    token=${user_token}     use_defaults=${False}
#
#   ${alert1}=  Create Alert Receiver  receiver_name=${receiver_name}_1  token=${user_token2}  developer_org_name=${orgname}
#   Should Be Equal  ${alert1['Name']}  ${receiver_name}_1
#   Should Be Equal  ${alert1['User']}  ${epochusername2}
#   Should Be Equal  ${alert1['Email']}  ${emailepoch2}
#   Should Be Equal  ${alert1['AppInst']['app_key']['organization']}  ${orgname}
#   Should Be Empty  ${alert1['Cloudlet']}
#   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cluster_key']}
#
#   ${alert2}=  Create Alert Receiver  receiver_name=${receiver_name}_2  token=${user_token2}  operator_org_name=${orgname}
#   Should Be Equal  ${alert2['Name']}  ${receiver_name}_2
#   Should Be Equal  ${alert2['User']}  ${epochusername2}
#   Should Be Equal  ${alert2['Email']}  ${emailepoch2}
#   Should Be Empty  ${alert2['AppInst']['app_key']}
#   Should Be Equal  ${alert2['Cloudlet']['organization']}  ${orgname}
#   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cluster_key']}
#
#   #https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022  https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022`
#   ${alert3}=  Create Alert Receiver  receiver_name=${receiver_name}_3  token=${user_token2}  cluster_instance_developer_org_name=${orgname}
#   Should Be Equal  ${alert3['Name']}  ${receiver_name}_3
#   Should Be Equal  ${alert3['User']}  ${epochusername2}
#   Should Be Equal  ${alert3['Email']}  ${emailepoch2}
#   Should Be Empty  ${alert3['AppInst']['app_key']}
#   Should Be Equal  ${alert3['Cloudlet']['organization']}  ${orgname}
#   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cloudlet_key']}
#   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cluster_key']}
#
#CreateAlertReceiver - OperatorContributor shall be able to create an alert receiver
#   [Documentation]
#   ...  - assign user to org as OperatorContributor
#   ...  - create an alert receiver
#   ...  - verify receiver is created
#
#   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
#   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token}     use_defaults=${False}
#
#   ${alert}=  Create Alert Receiver  token=${user_token2}  developer_org_name=${orgname}
#
#CreateAlertReceiver - OperatorViewer shall be able to create an alert receiver
#   [Documentation]
#   ...  - assign user to org as OperatorViewer
#   ...  - create an alert receiver
#   ...  - verify receiver is created
#
#   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
#   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer    token=${user_token}     use_defaults=${False}
#
#   ${alert}=  Create Alert Receiver  token=${user_token2}  developer_org_name=${orgname}

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

   ${receiver_name}=  Get Default Alert Receiver Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${receiver_name}
   Set Suite Variable  ${developer_name}

   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}
   Set Suite Variable  ${emailepoch2}

User with role shall be able to create an alert receiver
   [Arguments]  ${orgtype}  ${role}

   ${orgname}=  Create Org  token=${user_token}  orgtype=${orgtype}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=${role}    token=${user_token}     use_defaults=${False}

   ${alert1}=  Create Alert Receiver  receiver_name=${receiver_name}_1  token=${user_token2}  developer_org_name=${orgname}
   Should Be Equal  ${alert1['Name']}  ${receiver_name}_1
   Should Be Equal  ${alert1['User']}  ${epochusername2}
   Should Be Equal  ${alert1['Email']}  ${emailepoch2}
   Should Be Equal  ${alert1['AppInst']['app_key']['organization']}  ${orgname}
   Should Be Empty  ${alert1['Cloudlet']}
   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cloudlet_key']}
   Should Be Empty  ${alert1['AppInst']['cluster_inst_key']['cluster_key']}

   ${alert2}=  Create Alert Receiver  receiver_name=${receiver_name}_2  token=${user_token2}  operator_org_name=${orgname}
   Should Be Equal  ${alert2['Name']}  ${receiver_name}_2
   Should Be Equal  ${alert2['User']}  ${epochusername2}
   Should Be Equal  ${alert2['Email']}  ${emailepoch2}
   Should Be Empty  ${alert2['AppInst']['app_key']}
   Should Be Equal  ${alert2['Cloudlet']['organization']}  ${orgname}
   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cloudlet_key']}
   Should Be Empty  ${alert2['AppInst']['cluster_inst_key']['cluster_key']}

   #https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022  https://mobiledgex.atlassian.net/browse/EDGECLOUD-4022`
   ${alert3}=  Create Alert Receiver  receiver_name=${receiver_name}_3  token=${user_token2}  cluster_instance_developer_org_name=${orgname}
   Should Be Equal  ${alert3['Name']}  ${receiver_name}_3
   Should Be Equal  ${alert3['User']}  ${epochusername2}
   Should Be Equal  ${alert3['Email']}  ${emailepoch2}
   Should Be Empty  ${alert3['AppInst']['app_key']}
   Should Be Equal  ${alert3['Cloudlet']['organization']}  ${orgname}
   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cloudlet_key']}
   Should Be Empty  ${alert3['AppInst']['cluster_inst_key']['cluster_key']}

