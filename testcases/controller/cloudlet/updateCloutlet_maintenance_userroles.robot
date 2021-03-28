*** Settings ***
Documentation   UpdateCloudlet with maintenance states and user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup     Setup
Test Teardown  Teardown

*** Variables ***
${cloudlet}=  tmocloud-1
${operator}=  tmus
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

*** Test Cases ***
# ECQ-2447
UpdateCloudlet - operator manager shall be able to put cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet with maintenance mode as OperatorManager
   ...  - verify UpdateCloudlet succeeds

   Adduser Role   orgname=${operator}   username=${epochusername2}  role=OperatorManager   token=${user_token}

   Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover  
   Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation 

# ECQ-2448
UpdateCloudlet - operator contributor shall be able to put cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet with maintenance mode as OperatorContributor
   ...  - verify UpdateCloudlet succeeds

   Adduser Role   orgname=${operator}   username=${epochusername2}  role=OperatorContributor   token=${user_token}

   Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover
   Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation

# ECQ-2449
UpdateCloudlet - operator viewer shall not be able to put cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet with maintenance mode as OperatorViewer
   ...  - verify UpdateCloudlet fails

   Adduser Role   orgname=${operator}   username=${epochusername2}  role=OperatorViewer   token=${user_token}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation

# ECQ-2450
UpdateCloudlet - developer manager shall not be able to put cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet with maintenance mode as DeveloperManager
   ...  - verify UpdateCloudlet fails

   ${org}=  Create Org  orgname=${operator}2  orgtype=developer  token=${user_token}
   Adduser Role   orgname=${org}   username=${epochusername2}  role=DeveloperManager   token=${user_token}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation

# ECQ-2451
UpdateCloudlet - developer contributor shall not be able to put cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet with maintenance mode as DeveloperContributor
   ...  - verify UpdateCloudlet fails

   ${org}=  Create Org  orgname=${operator}2  orgtype=developer  token=${user_token}
   Adduser Role   orgname=${org}   username=${epochusername2}  role=DeveloperContributor   token=${user_token}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation

# ECQ-2452
UpdateCloudlet - developer viewer shall not be able to put cloudlet in maintenance mode
   [Documentation]
   ...  - send UpdateCloudlet with maintenance mode as DeveloperViewer
   ...  - verify UpdateCloudlet fails

   ${org}=  Create Org  orgname=${operator}2  orgtype=developer  token=${user_token}
   Adduser Role   orgname=${org}   username=${epochusername2}  role=DeveloperViewer   token=${user_token}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStart
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=MaintenanceStartNoFailover
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Cloudlet  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}     maintenance_state=NormalOperation

*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   Create Flavor  region=${region}  token=${super_token}

   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   ${user_token}=  Login  username=${epochusername}  password=${password}

   Create Org  orgtype=operator
   RestrictedOrg Update
   Create Cloudlet  region=${region}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   Unlock User
   ${user_token2}=  Login  username=${epochusername2}  password=${password}

   ${operator}=  Get Default Organization Name
   ${cloudlet}=  Get Default Cloudlet Name
   Set Suite Variable  ${operator}
   Set Suite Variable  ${cloudlet}
   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${super_token}
   Set Suite Variable  ${epochusername2}

Teardown
   Run Keyword and Ignore Error  Update Cloudlet  region=${region}  token=${super_token}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  maintenance_state=NormalOperation
   Cleanup Provisioning
