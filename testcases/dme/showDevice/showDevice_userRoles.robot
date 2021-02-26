*** Settings ***
Documentation   showDevice/showDeviceReport userroles

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${platos_app_name}  NotplatosEnablingLayer2
${developer_name}  MobiledgeX
${platos_org}  platos
${region}  US

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
#ECQ-3223
showDevice - OperatorManager shall be not able to ShowDevice/ShowDeviceReport
   [Documentation]
   ...  - assign user to org as OperatorManager
   ...  - do ShowDevice and ShowDeviceReport
   ...  - verify they fail

   ${epoch}=  Get Time  epoch

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device         token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device Report  token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}

#ECQ-3224
showDevice - OperatorContributor shall be not able to ShowDevice/ShowDeviceReport
   [Documentation]
   ...  - assign user to org as OperatorContributor
   ...  - do ShowDevice and ShowDeviceReport
   ...  - verify they fail

   ${epoch}=  Get Time  epoch

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device         token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device Report  token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}

#ECQ-3225
showDevice - OperatorViewer shall be not able to ShowDevice/ShowDeviceReport
   [Documentation]
   ...  - assign user to org as OperatorViewer
   ...  - do ShowDevice and ShowDeviceReport
   ...  - verify they fail

   ${epoch}=  Get Time  epoch

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device         token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device Report  token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}

#ECQ-3226
showDevice - DeveloperManager shall be not able to ShowDevice/ShowDeviceReport
   [Documentation]
   ...  - assign user to org as DeveloperManager
   ...  - do ShowDevice and ShowDeviceReport
   ...  - verify they fail

   ${epoch}=  Get Time  epoch

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device         token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device Report  token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}

#ECQ-3227
showDevice - DeveloperContributor shall be not able to ShowDevice/ShowDeviceReport
   [Documentation]
   ...  - assign user to org as DeveloperContributor
   ...  - do ShowDevice and ShowDeviceReport
   ...  - verify they fail

   ${epoch}=  Get Time  epoch

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device         token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device Report  token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}

#ECQ-3228
showDevice - DeveloperViewer shall be not able to ShowDevice/ShowDeviceReport
   [Documentation]
   ...  - assign user to org as DeveloperViewer
   ...  - do ShowDevice and ShowDeviceReport
   ...  - verify they fail

   ${epoch}=  Get Time  epoch

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device         token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device Report  token=${user_token2}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}

#ECQ-3229
showDevice - AdminManager shall be able to ShowDevice/ShowDeviceReport
   [Documentation]
   ...  - login as admin manager
   ...  - do ShowDevice and ShowDeviceReport
   ...  - verify they pass

   [Setup]  Admin Setup

   ${epoch}=  Get Time  epoch

   Register Client  developer_org_name=${developer_org_name_automation}  app_name=${app_name_automation}  unique_id=${epoch}  unique_id_type=${platos_org}

   ${device}=  Show Device         token=${admin_token}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}
   ${device_report}=   Show Device Report  token=${admin_token}  region=${region}  unique_id=${epoch}  unique_id_type=${platos_org}

   Length Should Be   ${device}  1
   Length Should Be   ${device_report}  1

*** Keywords ***
Admin Setup
   ${admin_token}=  Login  username=${admin_manager_username}  password=${admin_manager_password}
   Set Suite Variable  ${admin_token}

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

