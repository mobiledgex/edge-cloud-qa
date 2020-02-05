*** Settings ***
Documentation  ShowOrgCloudlet for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
#Test Teardown  Cleanup Provisioning

*** Variables ***
&{cloudlet0}=  cloudlet=attcloud-1  operator=att
&{cloudlet1}=  cloudlet=tmocloud-1  operator=tmus
&{cloudlet2}=  cloudlet=tmocloud-2  operator=tmus
&{cloudlet3}=  cloudlet=automationGcpCentralCloudlet  operator=gcp
&{cloudlet4}=  cloudlet=automationAzureCentralCloudlet  operator=azure

@{cloudlets}=  &{cloudlet0}  &{cloudlet1}  &{cloudlet2}  &{cloudlet3}  &{cloudlet4}

${username}=  mextester06
${password}=  mextester06123

${region}=  US

*** Test Cases ***
ShowOrgCloudlet - developer org owner shall be able to see all cloudlets 
   [Documentation]
   ...  send ShowOrgCloudlet for org owner
   ...  verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Create Privacy Policy  token=${user_token2}  region=${region}  rule_list=${rulelist}

ShowOrgCloudlet - operator org owner shall be able to see all cloudlets
   [Documentation]
   ...  send ShowOrgCloudlet for org owner
   ...  verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['operator_key']['name']}
      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
   END

   ${expected_length}=  Get Length  ${cloudlets}
   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${expected_length}  ${pool_length}

ShowOrgCloudlet - DeveloperManager shall be able to see all cloudlets
   [Documentation]
   ...  send ShowOrgCloudlet for DeveloperManager user
   ...  verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager   token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['operator_key']['name']}
      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
   END

   ${expected_length}=  Get Length  ${cloudlets}
   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${expected_length}  ${pool_length}

ShowOrgCloudlet - DeveloperContributor shall be able to see all cloudlets
   [Documentation]
   ...  send ShowOrgCloudlet for DeveloperContributor user
   ...  verify all cloudlets are returned


   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperContributor   token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['operator_key']['name']}
      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
   END

   ${expected_length}=  Get Length  ${cloudlets}
   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${expected_length}  ${pool_length}

ShowOrgCloudlet - DeveloperViewer shall be able to see all cloudlets
   [Documentation]
   ...  send ShowOrgCloudlet for DeveloperViewer user
   ...  verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperViewer   token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['operator_key']['name']}
      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
   END

   ${expected_length}=  Get Length  ${cloudlets}
   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${expected_length}  ${pool_length}

ShowOrgCloudlet - OperatorManager shall be able to see all cloudlets
   [Documentation]
   ...  send ShowOrgCloudlet for OperatorManager user
   ...  verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['operator_key']['name']}
      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
   END

   ${expected_length}=  Get Length  ${cloudlets}
   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${expected_length}  ${pool_length}

ShowOrgCloudlet - OperatorContributor shall be able to see all cloudlets
   [Documentation]
   ...  send ShowOrgCloudlet for OperatorContributor user
   ...  verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorContributor  token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['operator_key']['name']}
      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
   END

   ${expected_length}=  Get Length  ${cloudlets}
   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${expected_length}  ${pool_length}

ShowOrgCloudlet - OperatorViewer shall be able to see all cloudlets
   [Documentation]
   ...  send ShowOrgCloudlet for OperatorViewer user
   ...  verify all cloudlets are returned

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorViewer  token=${user_token}

   ${pool_return}=        Show Org Cloudlet  region=US  token=${user_token2}  org_name=${orgname}

   FOR  ${pool_cloudlet}  IN  @{pool_return}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['operator_key']['name']}
      List Should Contain Value   ${cloudlets}  ${cloudlet_key}
   END

   ${expected_length}=  Get Length  ${cloudlets}
   ${pool_length}=      Get Length  ${pool_return}
   Should Be Equal  ${expected_length}  ${pool_length}

*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token

   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Verify Email  email_address=${emailepoch}
   Unlock User 
   ${user_token}=  Login  username=${epochusername}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   Verify Email  email_address=${emailepoch2}
   Unlock User 
   ${user_token2}=  Login  username=${epochusername2}  password=${password}

   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}
