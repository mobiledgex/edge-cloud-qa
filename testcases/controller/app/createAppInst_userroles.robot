*** Settings ***
Documentation  CreateAppInst for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${configs_envvars_url}=  http://35.199.188.102/apps/automation_configs_envvars.yml

${region}=  US

*** Test Cases ***
# ECQ-3170
CreateAppInst - OperatorManager shall be not able to create/show/delete/update an appinst
   [Documentation]
   ...  - assign user to org as OperatorManager 
   ...  - do CreateAppInst/ShowAppInst/DeleteAppInst/UpdateAppInst
   ...  - verify they fail

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  
   ${apps}=  Show App Instances  region=${region}  
   Should Be Empty  ${apps}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region} 
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update App Instance  region=${region}

# ECQ-3171
CreateAppInst - OperatorContributor shall not be able to create/show/delete/update an appinst
   [Documentation]
   ...  - assign user to org as OperatorContributor
   ...  - do CreateAppInst/ShowAppInst/DeleteAppInst/UpdateAppInst
   ...  - verify they fail

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  
   ${apps}=  Show App Instances  region=${region}
   Should Be Empty  ${apps}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region} 
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update App Instance  region=${region}

# ECQ-3172
CreateAppInst - OperatorViewer shall not be able to create/show/delete/update an appinst
   [Documentation]
   ...  - assign user to org as OperatorViewer
   ...  - do CreateAppInst/ShowAppInst/DeleteAppInst/UpdateAppInst
   ...  - verify they fail

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance
   ${apps}=  Show App Instances  region=${region}
   Should Be Empty  ${apps}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update App Instance

# ECQ-3173
CreateApp - DeveloperManager shall be able to create/show/delete/update an app
   [Documentation]
   ...  - assign user to org as DeveloperManager
   ...  - do CreateApp/ShowApp/DeleteApp/UpdateApp
   ...  - verify they work

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   Create Flavor  region=${region}  token=${super_token}

   ${app}=  Create App  region=${region}  access_ports=tcp:1
   ${appinst}=  Create App Instance  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=dmuus  cluster_instance_name=autoclusterxxx  cluster_instance_developer_org_name=MobiledgeX
   Length Should Be  ${app}  1
   Length Should Be  ${appinst}  1

   ${apps}=  Show App Instances  region=${region}
   Length Should Be  ${apps}  1

   ${app_u}=  Update App Instance  region=${region}  developer_org_name=${orgname}  cluster_instance_name=autoclusterxxx  cluster_instance_developer_org_name=MobiledgeX  configs_kind=envVarsYaml  configs_config=${configs_envvars_url}
   Length Should Be  ${app_u}  1

# ECQ-3174
CreateApp - DeveloperContributor shall be able to create/show/delete/update an app
   [Documentation]
   ...  - assign user to org as DeveloperContributor
   ...  - do CreateApp/ShowApp/DeleteApp/UpdateApp
   ...  - verify they work

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token}     use_defaults=${False}

   Create Flavor  region=${region}  token=${super_token}

   ${app}=  Create App  region=${region}  access_ports=tcp:1
   ${appinst}=  Create App Instance  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=dmuus  cluster_instance_name=autoclusterxxx  cluster_instance_developer_org_name=MobiledgeX
   Length Should Be  ${app}  1
   Length Should Be  ${appinst}  1

   ${apps}=  Show App Instances  region=${region}
   Length Should Be  ${apps}  1

   ${app_u}=  Update App Instance  region=${region}  developer_org_name=${orgname}  cluster_instance_name=autoclusterxxx  cluster_instance_developer_org_name=MobiledgeX  configs_kind=envVarsYaml  configs_config=${configs_envvars_url}
   Length Should Be  ${app_u}  1

# ECQ-3175
CreateAppInstance - DeveloperViewer shall not be able to create/show/delete/update an appinst
   [Documentation]
   ...  - assign user to org as DeveloperViewer
   ...  - do CreateAppInst/ShowAppInst/DeleteAppInst/UpdateAppInst
   ...  - verify they fail

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}
   ${apps}=  Show App Instances  region=${region}
   Should Be Empty  ${apps}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update App Instance  region=${region}

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

