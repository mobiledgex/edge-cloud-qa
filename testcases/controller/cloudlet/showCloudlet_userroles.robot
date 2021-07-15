*** Settings ***
Documentation   ShowCloudlet user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  Collections

#Test Setup     Setup
Test Teardown  Teardown

*** Variables ***
${cloudlet}=  automationParadiseCloudlet
${operator}=  GDDT
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

*** Test Cases ***
# ECQ-3217
ShowCloudlet - operator shall be able to show all cloudlet details
   [Documentation]
   ...  - send ShowCloudlet as Operator Manager/Contributor/Viewer
   ...  - verify all details are returned
  
   [Setup]  Setup

   [Template]  Operator Should See All Details

   OperatorManager
   OperatorContributor
   OperatorViewer

# ECQ-3218
ShowCloudlet - developer shall show only minimal details
   [Documentation]
   ...  - send ShowCloudlet as Developer Manager/Contributor/Viewer
   ...  - verify minimum details are returned

   [Setup]  Developer Setup

   [Template]  Developer Should See Minimal Details

   DeveloperManager
   DeveloperContributor
   DeveloperViewer

*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  .2

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

Developer Setup
   Setup
   ${developer_org}=  Create Org  orgname=${operator}2  orgtype=developer  token=${user_token}
   Set Suite Variable  ${developer_org}

Operator Should See All Details
   [Arguments]  ${role}

   [Teardown]  Teardown Userrole  username=${epochusername2}  orgname=${operator}  role=${role}

   Adduser Role   orgname=${operator}   username=${epochusername2}  role=${role}   token=${user_token}

   ${show}=  Show Cloudlets  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}

   ${key_length}=  Get Length  ${show[0]['data']['crm_access_public_key']}
   Should Be True  len("${show[0]['data']['container_version']}") > 0
   Should Be True  ${show[0]['data']['created_at']['seconds']} > 0
   Should Be True  ${show[0]['data']['created_at']['nanos']} > 0
   Should Be True  ${key_length} > 0
   Should Be True  ${show[0]['data']['default_resource_alert_threshold']} > 0
   Should Be True  len("${show[0]['data']['deployment']}") > 0
   Should Be True  len("${show[0]['data']['flavor']}") > 0
   Should Be Equal  ${show[0]['data']['ip_support']}  Dynamic
   Should Be Equal  ${show[0]['data']['key']['name']}  ${cloudlet}
   Should Be Equal  ${show[0]['data']['key']['organization']}  ${operator}
   Should Be True  ${show[0]['data']['location']['latitude']} > 0
   Should Be True  ${show[0]['data']['location']['longitude']} > 0
   Should Be True  ${show[0]['data']['num_dynamic_ips']} > 0
   Should Be True  len("${show[0]['data']['notify_srv_addr']}") > 0
   Should Be Equal  ${show[0]['data']['physical_name']}  ${cloudlet}
   Should Be Equal  ${show[0]['data']['state']}  Ready
   Should Be Equal  ${show[0]['data']['trust_policy_state']}  NotPresent

Developer Should See Minimal Details
   [Arguments]  ${role}

   [Teardown]  Teardown Userrole  username=${epochusername2}  orgname=${developer_org}  role=${role}

   Adduser Role   orgname=${developer_org}   username=${epochusername2}  role=${role}   token=${user_token}

   ${show}=  Show Cloudlets  region=${region}  token=${user_token2}  operator_org_name=${operator}     cloudlet_name=${cloudlet}

   Dictionary Should Not Contain Key  ${show[0]['data']}  container_version
   Should Be Empty  ${show[0]['data']['created_at']}
   Dictionary Should Not Contain Key  ${show[0]['data']}  default_resource_alert_threshold
   Dictionary Should Not Contain Key  ${show[0]['data']}  deployment
   Should Be Empty  ${show[0]['data']['flavor']}
   Dictionary Should Not Contain Key  ${show[0]['data']}  notify_srv_addr
   Dictionary Should Not Contain Key  ${show[0]['data']}  physical_name

   Should Be Equal  ${show[0]['data']['ip_support']}  Dynamic
   Should Be Equal  ${show[0]['data']['key']['name']}  ${cloudlet}
   Should Be Equal  ${show[0]['data']['key']['organization']}  ${operator}
   Should Be True  ${show[0]['data']['location']['latitude']} > 0
   Should Be True  ${show[0]['data']['location']['longitude']} > 0
   Should Be Equal  ${show[0]['data']['state']}  Ready
   Should Be True  ${show[0]['data']['num_dynamic_ips']} > 0
   Should Be Equal  ${show[0]['data']['trust_policy_state']}  NotPresent

Teardown Userrole
   [Arguments]  ${username}  ${orgname}  ${role}
   RemoveUser Role  username=${username}  orgname=${orgname}  role=${role}  token=${user_token}

Teardown
   Cleanup Provisioning
