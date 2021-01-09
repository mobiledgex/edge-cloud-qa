*** Settings ***
Documentation  TrustPolicy for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

*** Test Cases ***
# ECQ-3045
CreateTrustPolicy - user not in an org shall get an error when creating a trust policy 
   [Documentation]
   ...  - send CreateTrustPolicy for user not in an org 
   ...  - verify proper error is received 

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy  token=${user_token}  region=${region}  rule_list=${rulelist}

# ECQ-3046
DeleteTrustPolicy - user not in an org shall get an error when deleting a trust policy
   [Documentation]
   ...  - send DeleteTrustPolicy for user not in an org
   ...  - verify proper error is received

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy  token=${user_token}  region=${region}  rule_list=${rulelist}

# ECQ-3047
ShowTrustPolicy - user not in an org shall get an empty list when showing a trust policy
   [Documentation]
   ...  - send ShowTrustPolicy for user not in an org
   ...  - verify empty list is returned 

   [Tags]  TrustPolicy

   ${result}=  Show Trust Policy  token=${user_token}  region=${region}

   ${len}=  Get Length  ${result}

   Should Be Equal As Numbers  ${len}  0

# ECQ-3076
CreateTrustPolicy - user shall not be able to create a policy in a developer org
   [Documentation]
   ...  - create a developer org
   ...  - send CreateTrustPolicy with the org
   ...  - verify error is returned

   [Tags]  TrustPolicy

   ${orgname}=  Create Org  orgname=${organization_name}_1  token=${user_token}  orgtype=developer

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy  token=${user_token}  region=${region}  rule_list=${rulelist}

# ECQ-3077
CreateTrustPolicy - user shall be able to create a policy in an operator org
   [Documentation]
   ...  - create an operator org
   ...  - send CreateTrustPolicy with the org
   ...  - verify policy is created

   [Tags]  TrustPolicy

   ${orgname}=  Create Org  orgname=${organization_name}_2  token=${user_token}  orgtype=operator

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Trust Policy  token=${user_token}  region=${region}  rule_list=${rulelist}
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${orgname}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][1]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][1]['port_range_max']}  65

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][2]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][2]['port_range_max']}  6

   Should Be Equal As Numbers  ${numrules}  3

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch

   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   # No longer need to verify email to create user accounts EDC-2163 has been added using Skip Verify Config
   Skip Verify Email 
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   # Verify Email  email_address=${emailepoch}
   Unlock User

   ${user_token}=  Login  username=${epochusername}  password=${password}

   ${policy_name}=  Get Default Trust Policy Name
   ${organization_name}=  Get Default Organization Name

   Set Suite Variable  ${organization_name}
   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${user_token}
