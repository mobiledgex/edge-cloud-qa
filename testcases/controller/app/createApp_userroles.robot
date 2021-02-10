*** Settings ***
Documentation  CreateApp for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

*** Test Cases ***
# ECQ-3164
CreateApp - OperatorManager shall be not able to create/show/delete/update an app
   [Documentation]
   ...  - assign user to org as OperatorManager 
   ...  - do CreateApp/ShowApp/DeleteApp/UpdateApp
   ...  - verify they fail

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App  region=${region}  access_ports=tcp:1
   ${apps}=  Show Apps  region=${region}  
   Should Be Empty  ${apps}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App  region=${region}  access_ports=tcp:1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update App  region=${region}  access_ports=tcp:1

# ECQ-3165
CreateApp - OperatorContributor shall not be able to create/show/delete/update an app
   [Documentation]
   ...  - assign user to org as OperatorContributor
   ...  - do CreateApp/ShowApp/DeleteApp/UpdateApp
   ...  - verify they fail

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App  region=${region}  access_ports=tcp:1
   ${apps}=  Show Apps  region=${region}
   Should Be Empty  ${apps}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App  region=${region}  access_ports=tcp:1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update App  region=${region}  access_ports=tcp:1

# ECQ-3166
CreateApp - OperatorViewer shall not be able to create/show/delete/update an app
   [Documentation]
   ...  - assign user to org as OperatorViewer
   ...  - do CreateApp/ShowApp/DeleteApp/UpdateApp
   ...  - verify they fail

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App  region=${region}  access_ports=tcp:1
   ${apps}=  Show Apps  region=${region}
   Should Be Empty  ${apps}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App  region=${region}  access_ports=tcp:1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update App  region=${region}  access_ports=tcp:1

# ECQ-3167
CreateApp - DeveloperManager shall be able to create/show/delete/update an app
   [Documentation]
   ...  - assign user to org as DeveloperManager
   ...  - do CreateApp/ShowApp/DeleteApp/UpdateApp
   ...  - verify they work

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   Create Flavor  region=${region}  token=${super_token}

   ${app}=  Create App  region=${region}  access_ports=tcp:1
   Length Should Be  ${app}  1

   ${apps}=  Show Apps  region=${region}
   Length Should Be  ${apps}  1

   ${app_u}=  Update App  region=${region}  access_ports=tcp:2  developer_org_name=${orgname}
   Length Should Be  ${app_u}  1

# ECQ-3168
CreateApp - DeveloperContributor shall be able to create/show/delete/update an app
   [Documentation]
   ...  - assign user to org as DeveloperContributor
   ...  - do CreateApp/ShowApp/DeleteApp/UpdateApp
   ...  - verify they work

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token}     use_defaults=${False}

   Create Flavor  region=${region}  token=${super_token}

   ${app}=  Create App  region=${region}  access_ports=tcp:1
   Length Should Be  ${app}  1

   ${apps}=  Show Apps  region=${region}
   Length Should Be  ${apps}  1

   ${app_u}=  Update App  region=${region}  access_ports=tcp:2  developer_org_name=${orgname}
   Length Should Be  ${app_u}  1

# ECQ-3169
CreateApp - DeveloperViewer shall not be able to create/show/delete/update an app
   [Documentation]
   ...  - assign user to org as DeveloperViewer
   ...  - do CreateApp/ShowApp/DeleteApp/UpdateApp
   ...  - verify they fail

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App  region=${region}  access_ports=tcp:1
   ${apps}=  Show Apps  region=${region}
   Should Be Empty  ${apps}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App  region=${region}  access_ports=tcp:1
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update App  region=${region}  access_ports=tcp:1

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
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

   ${policy_name}=  Get Default Trust Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}

