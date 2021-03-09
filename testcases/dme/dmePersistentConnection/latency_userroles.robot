*** Settings ***
Documentation  RequestAppInstLatency for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

*** Test Cases ***
# ECQ-3232
RequestAppInstLatency - OperatorManager shall not be able to request latency
   [Documentation]
   ...  - assign user to org as OperatorManager 
   ...  - attempt to do RequestAppInstLatency
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Request App Instance Latency  token=${user_token2}  region=${region}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

# ECQ-3233
RequestAppInstLatency - OperatorContributor shall not be able to request latency
   [Documentation]
   ...  - assign user to org as OperatorContributor
   ...  - attempt to do RequestAppInstLatency
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Request App Instance Latency  token=${user_token2}  region=${region}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

# ECQ-3234
RequestAppInstLatency - OperatorViewer shall not be able to request latency
   [Documentation]
   ...  - assign user to org as OperatorViewer
   ...  - attempt to do RequestAppInstLatency
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Request App Instance Latency  token=${user_token2}  region=${region}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

# ECQ-3235
RequestAppInstLatency - DeveloperManager shall be able to request latency
   [Documentation]
   ...  - assign user to org as DeveloperManager
   ...  - attempt to do RequestAppInstLatency
   ...  - verify request is successful

   [Tags]  DMEPersistentConnection

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   Create Flavor    token=${super_token}  region=${region} 
   Create App  token=${user_token2}  region=${region}  developer_org_name=${orgname}  access_ports=tcp:1
   ${appinst}=  Create App Instance  token=${user_token2}  region=${region}  developer_org_name=${orgname}  cluster_instance_developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster

   ${result}=  Request App Instance Latency  token=${user_token2}  region=${region}  app_name=${appinst['data']['key']['app_key']['name']}  app_version=${appinst['data']['key']['app_key']['version']}  developer_org_name=${appinst['data']['key']['app_key']['organization']}  cloudlet_name=${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  operator_org_name=${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cluster_instance_name=${appinst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${appinst['data']['key']['cluster_inst_key']['organization']}

   Should Be Equal  ${result['message']}  successfully sent latency request

# ECQ-3236
RequestAppInstLatency - DeveloperContributor shall be able to request latency
   [Documentation]
   ...  - assign user to org as DeveloperContributor
   ...  - attempt to do RequestAppInstLatency
   ...  - verify request is successful

   [Tags]  DMEPersistentConnection

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token}     use_defaults=${False}

   Create Flavor    token=${super_token}  region=${region}
   Create App  token=${user_token2}  region=${region}  developer_org_name=${orgname}  access_ports=tcp:1
   ${appinst}=  Create App Instance  token=${user_token2}  region=${region}  developer_org_name=${orgname}  cluster_instance_developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster

   ${result}=  Request App Instance Latency  token=${user_token2}  region=${region}  app_name=${appinst['data']['key']['app_key']['name']}  app_version=${appinst['data']['key']['app_key']['version']}  developer_org_name=${appinst['data']['key']['app_key']['organization']}  cloudlet_name=${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  operator_org_name=${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cluster_instance_name=${appinst['data']['key']['cluster_inst_key']['cluster_key']['name']}  cluster_instance_developer_org_name=${appinst['data']['key']['cluster_inst_key']['organization']}

   Should Be Equal  ${result['message']}  successfully sent latency request

# ECQ-3237
RequestAppInstLatency - DeveloperViewer shall not be able to request latency
   [Documentation]
   ...  - assign user to org as DeveloperViewer
   ...  - attempt to do RequestAppInstLatency
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer    token=${user_token}     use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Request App Instance Latency  token=${user_token2}  region=${region}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${orgname}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

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

   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${developer_name}

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}
