*** Settings ***
Documentation  AutoProvPolicy for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  mextester06123

${region}=  US

*** Test Cases ***
CreateAutoProvPolicy - user not in an org shall get an error when creating a policy 
   [Documentation]
   ...  send CreateAutoProvPolicy for user not in an org 
   ...  verify proper error is received 

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Create Auto Provisioning Policy  region=${region}  token=${user_token}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}

DeleteAutoProvPolicy - user not in an org shall get an error when deleting a policy
   [Documentation]
   ...  send DeleteAutoProvPolicy for user not in an org
   ...  verify proper error is received

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Delete Auto Provisioning Policy  region=${region}  token=${user_token}  

ShowAutoProvPolicy - user not in an org shall get an empty list when showing a policy
   [Documentation]
   ...  send ShowAutoProvPolicy for user not in an org
   ...  verify empty list is returned 

   ${result}=  Show Auto Provisioning Policy  token=${user_token}  region=${region}

   ${len}=  Get Length  ${result}

   Should Be Equal As Numbers  ${len}  0

*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   # No longer need to verify email to create user accounts EDC-2163 has been added using Skip Verify Config
   Skip Verify Email 
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   # Verify Email  email_address=${emailepoch}
   Unlock User

   ${userToken}=  Login  username=${epochusername}  password=${password}

   Set Suite Variable  ${userToken}
