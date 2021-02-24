*** Settings ***
Documentation  ShowOrgCloudlet for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
#&{cloudlet0}=  cloudlet=attcloud-1  operator=att
#&{cloudlet1}=  cloudlet=tmocloud-1  operator=dmuus
#&{cloudlet2}=  cloudlet=tmocloud-2  operator=dmuus
#&{cloudlet3}=  cloudlet=automationGcpCentralCloudlet  operator=gcp
#&{cloudlet4}=  cloudlet=automationAzureCentralCloudlet  operator=azure
#&{cloudlet5}=  cloudlet=andy  operator=Packet

#@{cloudlets}=  &{cloudlet0}  &{cloudlet1}  &{cloudlet2}  &{cloudlet3}  &{cloudlet4}  &{cloudlet5}

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-1700
ShowOrgCloudlet - developer org owner shall be able to see all cloudlets 
   [Documentation]
   ...  - send ShowOrgCloudlet for org owner
   ...  - verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      Developer Cloudlet Info Should Be Correct  ${pool_cloudlet}
   END

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${num_public_cloudlets}  ${pool_length}

#   FOR  ${pool_cloudlet}  IN  @{pool_return}
#      log to console  xxxxx ${cloudlets}
#      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
#      List Should Contain Value   ${cloudlets}  ${cloudlet_key}  
#   END

#   ${expected_length}=  Get Length  ${cloudlets}
#   ${pool_length}=      Get Length  ${pool_return}
#   Should Be Equal  ${expected_length}  ${pool_length}

# ECQ-1701
ShowOrgCloudlet - operator org owner shall be able to see all cloudlets
   [Documentation]
   ...  - send ShowOrgCloudlet for org owner
   ...  - verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      Developer Cloudlet Info Should Be Correct  ${pool_cloudlet}
   END

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${num_public_cloudlets}  ${pool_length}

#   FOR  ${pool_cloudlet}  IN  @{pool_return}
#      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
#      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
#   END

#   ${expected_length}=  Get Length  ${cloudlets}
#   ${pool_length}=      Get Length  ${pool_return}
#   Should Be Equal  ${expected_length}  ${pool_length}

# ECQ-1702
ShowOrgCloudlet - DeveloperManager shall be able to see all cloudlets
   [Documentation]
   ...  - send ShowOrgCloudlet for DeveloperManager user
   ...  - verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager   token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      Developer Cloudlet Info Should Be Correct  ${pool_cloudlet}
   END

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${num_public_cloudlets}  ${pool_length}

#   FOR  ${pool_cloudlet}  IN  @{pool_return}
#      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
#      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
#   END

#   ${expected_length}=  Get Length  ${cloudlets}
#   ${pool_length}=      Get Length  ${pool_return}
#   Should Be Equal  ${expected_length}  ${pool_length}

# ECQ-1703
ShowOrgCloudlet - DeveloperContributor shall be able to see all cloudlets
   [Documentation]
   ...  - send ShowOrgCloudlet for DeveloperContributor user
   ...  - verify all cloudlets are returned


   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperContributor   token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      Developer Cloudlet Info Should Be Correct  ${pool_cloudlet}
   END

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${num_public_cloudlets}  ${pool_length}

#   FOR  ${pool_cloudlet}  IN  @{pool_return}
#      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
#      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
#   END

#   ${expected_length}=  Get Length  ${cloudlets}
#   ${pool_length}=      Get Length  ${pool_return}
#   Should Be Equal  ${expected_length}  ${pool_length}

# ECQ-1704
ShowOrgCloudlet - DeveloperViewer shall be able to see all cloudlets
   [Documentation]
   ...  - send ShowOrgCloudlet for DeveloperViewer user
   ...  - verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperViewer   token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      Developer Cloudlet Info Should Be Correct  ${pool_cloudlet}
   END

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${num_public_cloudlets}  ${pool_length}

#   FOR  ${pool_cloudlet}  IN  @{pool_return}
#      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
#      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
#   END

#   ${expected_length}=  Get Length  ${cloudlets}
#   ${pool_length}=      Get Length  ${pool_return}
#   Should Be Equal  ${expected_length}  ${pool_length}

# ECQ-1705
ShowOrgCloudlet - OperatorManager shall be able to see all cloudlets
   [Documentation]
   ...  - send ShowOrgCloudlet for OperatorManager user
   ...  - verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      Run Keyword If  "${pool_cloudlet['key']['organization']}" == "${orgname}"  Operator Cloudlet Info Should Be Correct  ${pool_cloudlet}
      ...  ELSE  Developer Cloudlet Info Should Be Correct  ${pool_cloudlet}
   END

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${num_public_cloudlets}  ${pool_length}

#   FOR  ${pool_cloudlet}  IN  @{pool_return}
#      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
#      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
#   END
#
#   ${expected_length}=  Get Length  ${cloudlets}
#   ${pool_length}=      Get Length  ${pool_return}
#   Should Be Equal  ${expected_length}  ${pool_length}

# ECQ-1706
ShowOrgCloudlet - OperatorContributor shall be able to see all cloudlets
   [Documentation]
   ...  - send ShowOrgCloudlet for OperatorContributor user
   ...  - verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorContributor  token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      Run Keyword If  "${pool_cloudlet['key']['organization']}" == "${orgname}"  Operator Cloudlet Info Should Be Correct  ${pool_cloudlet}
      ...  ELSE  Developer Cloudlet Info Should Be Correct  ${pool_cloudlet}
   END

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${num_public_cloudlets}  ${pool_length}

#   FOR  ${pool_cloudlet}  IN  @{pool_return}
#      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
#      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
#   END

#   ${expected_length}=  Get Length  ${cloudlets}
#   ${pool_length}=      Get Length  ${pool_return}
#   Should Be Equal  ${expected_length}  ${pool_length}

# ECQ-1707
ShowOrgCloudlet - OperatorViewer shall be able to see all cloudlets
   [Documentation]
   ...  - send ShowOrgCloudlet for OperatorViewer user
   ...  - verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorViewer  token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      Run Keyword If  "${pool_cloudlet['key']['organization']}" == "${orgname}"  Operator Cloudlet Info Should Be Correct  ${pool_cloudlet}
      ...  ELSE  Developer Cloudlet Info Should Be Correct  ${pool_cloudlet}
   END

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${num_public_cloudlets}  ${pool_length}

#   FOR  ${pool_cloudlet}  IN  @{pool_return}
#      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
#      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
#   END

#   ${expected_length}=  Get Length  ${cloudlets}
#   ${pool_length}=      Get Length  ${pool_return}
#   Should Be Equal  ${expected_length}  ${pool_length}

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token
 
   @{cloudlets}=  Create List
   ${cloudlet_list}=  Show Cloudlets  region=US  token=${super_token}  use_defaults=${False}
   FOR  ${cloud}  IN  @{cloudlet_list}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${cloud['data']['key']['name']}  operator=${cloud['data']['key']['organization']}
      Append To List  ${cloudlets}  ${cloudlet_key}
   END
      
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
   Set Suite Variable  ${epochusername2}
   Set Suite Variable  ${cloudlets}

Developer Cloudlet Info Should Be Correct
   [Arguments]  ${show}

   Dictionary Should Not Contain Key  ${show}  container_version
   Should Be Empty  ${show['created_at']}
   Dictionary Should Not Contain Key  ${show}  default_resource_alert_threshold
   Dictionary Should Not Contain Key  ${show}  deployment
   Should Be Empty  ${show['flavor']}
   Dictionary Should Not Contain Key  ${show}  notify_srv_addr
   Dictionary Should Not Contain Key  ${show}  physical_name

   Should Be True  ${show['ip_support']} > 0
   Should Not Be Empty  ${show['key']['name']}
   Should Not Be Empty  ${show['key']['organization']}
   Should Be True  ${show['location']['latitude']} >= -90 and ${show['location']['latitude']} <= 90
   Should Not Be Empty  ${show['location']['longitude']} >= -180 and ${show['location']['longitude']} <= 180
   Should Be True  ${show['state']} > 0
   Should Be True  ${show['num_dynamic_ips']} > 0
   #Should Be True  'trust_policy_state' in ${show} or 'trust_policy' in ${show}
   Run Keyword If  'trust_policy_state' in ${show}  Should Be True  ${show['trust_policy_state']} > 0
   Run Keyword If  'trust_policy' in ${show}  Should Not Be Empty  ${show['trust_policy']}

Operator Cloudlet Info Should Be Correct
   [Arguments]  ${show}

   ${key_length}=  Get Length  ${show['crm_access_public_key']}
   Should Be True  len("${show['container_version']}") > 0
   Should Be True  ${show['created_at']['seconds']} > 0
   Should Be True  ${show['created_at']['nanos']} > 0
   Should Be True  ${key_length} > 0
   Should Be True  ${show['default_resource_alert_threshold']} > 0
   Should Be True  len("${show['deployment']}") > 0
   Should Be True  len("${show['flavor']}") > 0
   Should Be True  ${show['ip_support']} > 0
   Should Be Equal  ${show['key']['name']}  ${cloudlet}
   Should Be Equal  ${show['key']['organization']}  ${operator}
   Should Be True  ${show['location']['latitude']} > 0
   Should Be True  ${show['location']['longitude']} > 0
   Should Be True  ${show['num_dynamic_ips']} > 0
   Should Be True  len("${show['notify_srv_addr']}") > 0
   Should Be Equal  ${show['physical_name']}  ${cloudlet}
   Should Be Equal As Numbers  ${show['state']}  5
   Should Be Equal As Numbers  ${show['trust_policy_state']}  1

