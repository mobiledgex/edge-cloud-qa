*** Settings ***
Documentation  DeleteIdleReservableClusterInstances for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${username}=  mextester06
${password}=  mextester06_gmail_password 

${cloudlet_name}=  tmocloud-1
${operator_name}=  dmuus
${region}=  US

*** Test Cases ***
# ECQ-3195
DeleteIdleReservableClusterInstances - Developer/Operator Manager/Contributor/Viewer shall not be able to delete idle clusters
   [Documentation]
   ...  - send DeleteIdleReservableClusterInstances for Developer/Operator Manager/Contributor/Viewer
   ...  - verify forbidden is returned

   [Tags]  ReservableCluster

   [Template]  Dev/Op user shall not be able to do DeleteIdleReservableClusterInstances

   orgtype=developer  role=DeveloperManager
   orgtype=developer  role=DeveloperViewer
   orgtype=developer  role=DeveloperContributor

   orgtype=operator  role=OperatorManager
   orgtype=operator  role=OperatorViewer
   orgtype=operator  role=OperatorContributor

*** Keywords ***
Setup
   ${super_token}=  Get Super Token

   Create Flavor  token=${super_token}  region=${region}

   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token
 
   Skip Verify Email  token=${super_token} 
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   #Verify Email  email_address=${emailepoch}
   Unlock User 
   ${user_token}=  Login  username=${epochusername}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   #Verify Email  email_address=${emailepoch2}
   Unlock User 
   ${user_token2}=  Login  username=${epochusername2}  password=${password}

   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${super_token}
   Set Suite Variable  ${epochusername2}

Dev/Op user shall not be able to do DeleteIdleReservableClusterInstances
   [Arguments]  ${orgtype}  ${role}

   Setup 
   [Teardown]  Cleanup Provisioning

   ${orgname}=  Create Org  token=${user_token}  orgtype=${orgtype}

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=${role}   token=${user_token}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Idle Reservable Cluster Instances  region=${region}  token=${user_token2}
   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Idle Reservable Cluster Instances  region=${region}  token=${user_token2}  idle_time=10s

