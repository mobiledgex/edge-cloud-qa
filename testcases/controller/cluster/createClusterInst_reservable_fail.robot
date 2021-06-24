*** Settings ***
Documentation   CreateClusterInst with reservable cluster failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3186
CreateClusterInst - admin shall not be able to CreateClusterInst with name=reservable0
   [Documentation]
   ...  - send CreateClusterInst with name=reservable0 as admin
   ...  - verify it fails

   [Tags]  ReservableCluster

   [Setup]  Setup
   [Template]  Cluster Name Reservable0 shall Fail

   deployment=docker      ip_access=IpAccessShared     token=${super_token}   org=MobiledgeX
   deployment=docker      ip_access=IpAccessDedicated  token=${super_token}   org=MobiledgeX
   deployment=kubernetes  ip_access=IpAccessShared     token=${super_token}   org=MobiledgeX
   deployment=kubernetes  ip_access=IpAccessDedicated  token=${super_token}   org=MobiledgeX

   deployment=docker      ip_access=IpAccessShared     token=${super_token}   org=MobiledgeX  reservable=${False}
   deployment=docker      ip_access=IpAccessDedicated  token=${super_token}   org=MobiledgeX  reservable=${False}
   deployment=kubernetes  ip_access=IpAccessShared     token=${super_token}   org=MobiledgeX  reservable=${False}
   deployment=kubernetes  ip_access=IpAccessDedicated  token=${super_token}   org=MobiledgeX  reservable=${False}
 
   deployment=docker      ip_access=IpAccessShared     token=${super_token}  org=MobiledgeX  reservable=${True}
   deployment=docker      ip_access=IpAccessDedicated  token=${super_token}  org=MobiledgeX  reservable=${True}
   deployment=kubernetes  ip_access=IpAccessShared     token=${super_token}  org=MobiledgeX  reservable=${True}
   deployment=kubernetes  ip_access=IpAccessDedicated  token=${super_token}  org=MobiledgeX  reservable=${True}

# ECQ-3187
CreateClusterInst - developer shall not be able to CreateClusterInst with name=reservable0
   [Documentation]
   ...  - send CreateClusterInst with name=reservable0 as developer
   ...  - verify it fails

   [Tags]  ReservableCluster

   [Setup]  Developer Setup
   [Template]  Cluster Name Reservable0 shall Fail

   deployment=docker      ip_access=IpAccessShared     token=${user_token}  org=${orgname}
   deployment=docker      ip_access=IpAccessDedicated  token=${user_token}  org=${orgname}
   deployment=kubernetes  ip_access=IpAccessShared     token=${user_token}  org=${orgname}
   deployment=kubernetes  ip_access=IpAccessDedicated  token=${user_token}  org=${orgname}

   deployment=docker      ip_access=IpAccessShared     token=${user_token}  org=${orgname}  reservable=${False}
   deployment=docker      ip_access=IpAccessDedicated  token=${user_token}  org=${orgname}  reservable=${False}
   deployment=kubernetes  ip_access=IpAccessShared     token=${user_token}  org=${orgname}  reservable=${False}
   deployment=kubernetes  ip_access=IpAccessDedicated  token=${user_token}  org=${orgname}  reservable=${False}

   deployment=docker      ip_access=IpAccessShared     token=${user_token}  org=${orgname}  reservable=${True}
   deployment=docker      ip_access=IpAccessDedicated  token=${user_token}  org=${orgname}  reservable=${True}
   deployment=kubernetes  ip_access=IpAccessShared     token=${user_token}  org=${orgname}  reservable=${True}
   deployment=kubernetes  ip_access=IpAccessDedicated  token=${user_token}  org=${orgname}  reservable=${True}

# ECQ-3188
CreateClusterInst - shall not be able to create reservable cluster with non-MobildedgeX org
   [Documentation]
   ...  - send reservable CreateClusterInst with non-MobildedgeX org
   ...  - verify it fails

   [Tags]  ReservableCluster

   [Setup]  Setup
   [Template]  Non-MobiledgeX Reservable cluster shall Fail

   deployment=docker      ip_access=IpAccessShared     
   deployment=docker      ip_access=IpAccessDedicated 
   deployment=kubernetes  ip_access=IpAccessShared   
   deployment=kubernetes  ip_access=IpAccessDedicated

*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   Set Suite Variable  ${super_token}

Developer Setup
   Setup

   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User

   ${orgname}=  Create Org  orgtype=developer
   Create Billing Org  billing_org_name=${orgname}  token=${super_token}
   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperManager  

   ${user_token}=  Login  username=${epochusername}  password=${password}

   Set Suite Variable  ${user_token}
   Set Suite Variable  ${orgname}

Cluster Name Reservable0 shall Fail
   [Arguments]  ${deployment}  ${ip_access}  ${org}  ${token}  ${reservable}=${None}

   ${error_msg1}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cluster_name=reservable0  developer_org_name=${org}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=${deployment}  ip_access=${ip_access}  reservable=${reservable}  token=${token}
   Should Be Equal  ${error_msg1}  ('code=400', 'error={"message":"Invalid cluster name, format \\\\"reservable[digits]\\\\" is reserved for internal use"}')

Non-MobiledgeX Reservable cluster shall Fail
   [Arguments]  ${deployment}  ${ip_access} 

   ${error_msg1}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cluster_name=myclusterreserved  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=${deployment}  ip_access=${ip_access}  reservable=${True}  token=${super_token}
   Should Be Equal  ${error_msg1}  ('code=400', 'error={"message":"Only MobiledgeX ClusterInsts may be reservable"}')

Teardown
   Cleanup Provisioning

