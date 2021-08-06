*** Settings ***
Documentation  ShowApp for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  Collections

#Test Setup  Setup
#Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

*** Test Cases ***
# ECQ-3677
ShowApp - Operator with cloudletpool shall not be able to show app for invite with no reponse
   [Documentation]
   ...  - Operator creates a pool and an invite
   ...  - Developer does not repond
   ...  - verify ShowApp fails

   [Template]  ShowApp with invite only

   OperatorManager
   OperatorContributor
   OperatorViewer

# ECQ-3678
ShowApp - Operator with cloudletpool shall not be able to show app for rejected invite
   [Documentation]
   ...  - Operator creates a pool and an invite
   ...  - Developer rejects the invite
   ...  - verify ShowApp fails

   [Template]  ShowApp with rejected invite

   OperatorManager
   OperatorContributor
   OperatorViewer

# ECQ-3679
ShowApp - Operator with cloudletpool shall be able to show app for org with accepted invite
   [Documentation]
   ...  - Operator creates a pool and an invite
   ...  - Developer accepts the invite
   ...  - verify ShowApp returns only the apps for the org in the pool

   [Template]  ShowApp with accepted invite

   OperatorManager
   OperatorContributor
   OperatorViewer

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
   #${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   #${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token

   ${org_name}=  Get Default Organization Name

   ${devorgname}=  Create Org  token=${super_token}  orgname=dev_${org_name}  orgtype=developer
   ${oporgname}=   Create Org  token=${super_token}  orgname=op_${org_name}  orgtype=operator

   # No longer need to verify email to create user accounts EDC-2163 has been added using Skip Verify Config
#   Skip Verify Email  token=${super_token}  
#   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
#   # Verify Email  email_address=${emailepoch}
#   Unlock User 
#   ${owner_token}=  Login  username=${epochusername}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   # Verify Email  email_address=${emailepoch2}
   Unlock User 
   #${user_token}=  Login  username=${epochusername2}  password=${password}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${super_token}
   Set Suite Variable  ${devorgname}
   Set Suite Variable  ${oporgname}

#  Set Suite Variable  ${user_token}
#   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}

Apps Should Be in Pool Only
   [Arguments]  ${apps}  ${pools}

   @{pool_orgs}=  Create List
   FOR  ${p}  IN  @{pools}
      ${resp}=  Show Cloudlet Pool Access Response  cloudlet_pool_name=${p['data']['key']['name']}
      IF  len(@{resp}) > 0
         IF  '${resp[0]['Decision']}' == 'accept'
            Append To List  ${pool_orgs}  ${resp[0]['Org']}
         END
      END
   END

   FOR  ${a}  IN  @{apps}
      Run Keyword If  '${a['data']['key']['organization']}' not in @{pool_orgs}  Fail  Org=${a['data']['key']['organization']} not in a pool @{pool_orgs}
      Run Keyword If  '${a['data']['key']['organization']}' == '${devorgname}'  Fail  Org=${a['data']['key']['organization']} is not accepted
   END

Add Role and Create Invitation
   [Arguments]  ${role}

   Run Keyword and Ignore Error  Removeuser Role  orgname=${oporgname}   username=${epochusername2}  role=OperatorManager
   Adduser Role   orgname=${oporgname}   username=${epochusername2}  role=${role}  token=${super_token}
   ${user_token}=  Login  username=${epochusername2}  password=${password}

   # create an invitation that is not accepted
   ${pool}=  Create Cloudlet Pool  region=${region}  token=${super_token}  cloudlet_pool_name=${pool_name}  operator_org_name=${oporgname}  #operator_org_name=${operator_name_fake}
   Create Cloudlet Pool Access Invitation  region=${region}  token=${super_token}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${oporgname}  developer_org_name=${devorgname}

   Set Suite Variable  ${pool}
   Set Suite Variable  ${user_token}

ShowApp with invite only
   [Arguments]  ${role}

   [Teardown]  Cleanup Provisioning

   Setup

   Add Role and Create Invitation  ${role}

   # should get forbidden since devorg has not accepted invite
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Apps   region=${region}  token=${user_token}

ShowApp with rejected invite
   [Arguments]  ${role}

   [Teardown]  Cleanup Provisioning

   Setup

   Add Role and Create Invitation  ${role}

   Create Cloudlet Pool Access Response  region=${region}  token=${super_token}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${oporgname}  developer_org_name=${devorgname}  decision=reject 
   # should get forbidden since devorg has not rejected invite
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Apps   region=${region}  token=${user_token}

ShowApp with accepted invite
   [Arguments]  ${role}

   [Teardown]  Cleanup Provisioning

   Setup

   Add Role and Create Invitation  ${role}

   Create Cloudlet Pool Access Response  region=${region}  token=${super_token}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${oporgname}  developer_org_name=${devorgname}  decision=accept

   ${apps}=  Show Apps  region=${region}  token=${user_token}
   Length Should Be   ${apps}  0

   ${app_name}=  Get Default App Name

   ${devuser_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   Adduser Role   orgname=${devorgname}   username=${dev_manager_user_automation}  role=DeveloperManager  token=${super_token}

   Create Flavor  region=${region}  token=${super_token}
   Create App  region=${region}  image_type=ImageTypeQCOW  app_name=${app_name}vm  developer_org_name=${devorgname}  deployment=vm  image_path=${qcow_centos_image}  token=${devuser_token}
   Create App  region=${region}  image_type=ImageTypeDocker  app_name=${app_name}docker  developer_org_name=${devorgname}  deployment=docker  image_path=${docker_image}  token=${devuser_token}
   Create App  region=${region}  image_type=ImageTypeDocker  app_name=${app_name}k8s  developer_org_name=${devorgname}  deployment=kubernetes  image_path=${docker_image}  token=${devuser_token}
   Create App  region=${region}  image_type=ImageTypeHelm  app_name=${app_name}helm  developer_org_name=${devorgname}  deployment=helm  image_path=${docker_image}  token=${devuser_token}

   ${apps}=  Show Apps  region=${region}  token=${user_token}
   Length Should Be   ${apps}  4

   FOR  ${a}  IN  @{apps}
      Run Keyword If  '${a['data']['key']['organization']}' != '${devorgname}'  Fail  expected=${devorgname} found=${a['data']['key']['organization']} 
   END

