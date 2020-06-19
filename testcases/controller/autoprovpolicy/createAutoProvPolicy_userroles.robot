*** Settings ***
Documentation  CreateAutoProvPolicy for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  mextester06123

${region}=  US

*** Test Cases ***
CreateAutoProvPolicy - DeveloperManager shall be able to create a policy
   [Documentation]
   ...  assign user to org as DeveloperManager 
   ...  do CreateAutoProvPolicy
   ...  verify policy is created 

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   ${policy_return}=  Create Auto Provisioning Policy  region=US  token=${user_token2}  developer_org_name=${orgname}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist} 

   ${numcloudlets}=  Get Length  ${policy_return['data']['cloudlets']}

   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${orgname}

   Should Be Equal As Integers  ${policy_return['data']['max_instances']}         1 
   Should Be Equal As Integers  ${policy_return['data']['min_active_instances']}  1 

   Should Be Equal  ${policy_return['data']['cloudlets'][0]['key']['name']}          tmocloud-1 
   Should Be Equal  ${policy_return['data']['cloudlets'][0]['key']['organization']}  tmus 

   Should Be Equal As Integers  ${policy_return['data']['cloudlets'][0]['loc']['latitude']}     31 
   Should Be Equal As Integers  ${policy_return['data']['cloudlets'][0]['loc']['longitude']}    -91 

   Should Be Equal As Numbers  ${numcloudlets}  1

CreateAutoProvPolicy - DeveloperContributor shall be able to create a policy
   [Documentation]
   ...  assign user to org as DeveloperContributor
   ...  do CreateAutoProvPolicy
   ...  verify policy is created

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor   token=${user_token}     use_defaults=${False}

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   ${policy_return}=  Create Auto Provisioning Policy  region=US  token=${user_token2}  developer_org_name=${orgname}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}

   ${numcloudlets}=  Get Length  ${policy_return['data']['cloudlets']}

   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${orgname}

   Should Be Equal As Integers  ${policy_return['data']['max_instances']}         1
   Should Be Equal As Integers  ${policy_return['data']['min_active_instances']}  1

   Should Be Equal  ${policy_return['data']['cloudlets'][0]['key']['name']}          tmocloud-1
   Should Be Equal  ${policy_return['data']['cloudlets'][0]['key']['organization']}  tmus

   Should Be Equal As Integers  ${policy_return['data']['cloudlets'][0]['loc']['latitude']}     31
   Should Be Equal As Integers  ${policy_return['data']['cloudlets'][0]['loc']['longitude']}    -91

   Should Be Equal As Numbers  ${numcloudlets}  1

CreateAutoProvPolicy - DeveloperViewer shall not be able to create a policy
   [Documentation]
   ...  assign user to org as DeveloperViewer
   ...  do CreateAutoProvPolicy
   ...  verify error is received 

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer   token=${user_token}     use_defaults=${False}

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Create Auto Provisioning Policy  region=US  token=${user_token2}  developer_org_name=${orgname}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}


CreateAutoProvPolicy - OperatorManager shall not be able to create a policy
   [Documentation]
   ...  assign user to org as OperatorManager 
   ...  do CreateAutoProvPolicy
   ...  verify error is received

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager   token=${user_token}     use_defaults=${False}

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Create Auto Provisioning Policy  region=US  token=${user_token2}  developer_org_name=${orgname}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}

CreateAutoProvPolicy - OperatorContributor shall not be able to create a policy
   [Documentation]
   ...  assign user to org as OperatorContributor
   ...  do CreateAutoProvPolicy
   ...  verify error is received

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor   token=${user_token}     use_defaults=${False}

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Create Auto Provisioning Policy  region=US  token=${user_token2}  developer_org_name=${orgname}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}

CreateAutoProvPolicy - OperatorViewer shall not be able to create a policy
   [Documentation]
   ...  assign user to org as OperatorViewe
   ...  do CreateAutoProvPolicy
   ...  verify error is received 

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer   token=${user_token}     use_defaults=${False}

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Create Auto Provisioning Policy  region=US  token=${user_token2}  developer_org_name=${orgname}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}

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

   ${policy_name}=  Get Default Auto Provisioning Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}

   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}
