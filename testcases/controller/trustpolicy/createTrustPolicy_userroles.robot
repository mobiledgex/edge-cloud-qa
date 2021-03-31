*** Settings ***
Documentation  CreateTrustPolicy for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

# EDGECLOUD-4193 CreateTrustPolicy should be allowed for Operators and denied for Developers

*** Test Cases ***
# ECQ-3070
CreateTrustPolicy - OperatorManager shall be able to create/show/delete a trust policy
   [Documentation]
   ...  - assign user to org as OperatorManager 
   ...  - do CreateTrustPolicy/ShowTrustPolicy/DeleteTrustPolicy
   ...  - verify all 3 work

   [Tags]  TrustPolicy

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorManager    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}  rule_list=${rulelist}  auto_delete=${False}

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

   # number of trust policies be should equal to the number of cloudlets that have a trust policy plus the new policy just created
   ${cloudlets}=  Show Cloudlets  token=${user_token2}  region=${region}  use_defaults=${False}
   ${show}=  Show Trust Policy  token=${user_token2}  region=${region}  use_defaults=${False}
   ${num_trust_policys}=  Get Length  ${show}
   ${num_cloudlets_with_trustpolicy}=  Get Number Of Cloudlets with Trust Policy  ${cloudlets}
   Should Be Equal  ${num_trust_policys}  ${num_cloudlets_with_trustpolicy+1}
   Should Be True  ${num_trust_policys} > 0

# ECQ-3071
CreateTrustPolicy - OperatorContributor shall be able to create/show/delete a trust policy
   [Documentation]
   ...  - assign user to org as OperatorContributor
   ...  - do CreateTrustPolicy/ShowTrustPolicy/DeleteTrustPolicy
   ...  - verify all 3 work

   [Tags]  TrustPolicy

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   Set Suite Variable  ${orgname}
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorContributor    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}  rule_list=${rulelist}  auto_delete=${False}

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

   # number of trust policies be should equal to the number of cloudlets that have a trust policy plus the new policy just created
   ${cloudlets}=  Show Cloudlets  token=${user_token2}  region=${region}  use_defaults=${False}
   ${show}=  Show Trust Policy  token=${user_token2}  region=${region}  use_defaults=${False}
   ${num_trust_policys}=  Get Length  ${show}
   ${num_cloudlets_with_trustpolicy}=  Get Number Of Cloudlets with Trust Policy  ${cloudlets}
   Should Be Equal  ${num_trust_policys}  ${num_cloudlets_with_trustpolicy+1}
   Should Be True  ${num_trust_policys} > 0

# ECQ-3072
CreateTrustPolicy - OperatorViewer shall not be able to create/delete but view a trust policy
   [Documentation]
   ...  - assign user to org as OperatorViewer
   ...  - do CreateTrustPolicy/DeleteTrustPolicy
   ...  - verify error is returned 
   ...  - do CreateTrust policy as org owner
   ...  - do ShowTrustPolicy as OperatorViewer
   ...  - verify policy is listed

   [Tags]  TrustPolicy

   [Teardown]  Teardown Forbidden

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=OperatorViewer    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   # create as user2 should be forbidden
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}  rule_list=${rulelist}

   # create policy as org owner
   ${policy_return}=  Create Trust Policy  operator_org_name=${orgname}  token=${user_token}  region=${region}  rule_list=${rulelist}

   # show as user2 should return policy
   ${show}=  Show Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}
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
 
   Length Should Be  ${show}  1

   # number of trust policies be should equal to the number of cloudlets that have a trust policy plus the new policy just created
   ${cloudlets}=  Show Cloudlets  token=${user_token2}  region=${region}  use_defaults=${False}
   ${show}=  Show Trust Policy  token=${user_token2}  region=${region}  use_defaults=${False}
   ${num_trust_policys}=  Get Length  ${show}
   ${num_cloudlets_with_trustpolicy}=  Get Number Of Cloudlets with Trust Policy  ${cloudlets}
   Should Be Equal  ${num_trust_policys}  ${num_cloudlets_with_trustpolicy+1}
   Should Be True  ${num_trust_policys} > 0

   # show/delete as user2 should be forbidden
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}

# ECQ-3073
CreateTrustPolicy - DeveloperManager shall not be able to create/delete but view a trust policy
   [Documentation]
   ...  - assign user to org as DeveloperManager
   ...  - attempt to do CreateTrustPolicy/DeleteTrustPolicy 
   ...  - verify proper error is returned 
   ...  - do CreateTrust policy as org owner
   ...  - do ShowTrustPolicy as DeveloperManager
   ...  - verify policy is listed

   [Tags]  TrustPolicy

   [Teardown]  Teardown Forbidden

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   # create as user2 should be forbidden
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}  rule_list=${rulelist}

   # create policy as org owner
   ${orgname_op}=  Create Org  token=${user_token}  orgname=${orgname}_op  orgtype=operator
   RestrictedOrg Update  org_name=${orgname_op}
   #${adduser}=   Adduser Role   orgname=${orgname_op}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   ${policy_return}=  Create Trust Policy  operator_org_name=${orgname}_op  token=${user_token}  region=${region}  rule_list=${rulelist}

   # show as user2 should return empty list since policy is not tied to a cloudlet 
   ${show}=  Show Trust Policy  operator_org_name=${orgname}_op  token=${user_token2}  region=${region}
   Length Should Be  ${show}  0

   # tie the policy to a cloudlet
   Create Cloudlet  region=${region}  token=${user_token}  operator_org_name=${orgname}_op  trust_policy=${policy_return['data']['key']['name']}

   # show as user2 should return policy
   ${show}=  Show Trust Policy  operator_org_name=${orgname}_op  token=${user_token2}  region=${region}
   Length Should Be  ${show}  1

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${show[0]['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${show[0]['data']['key']['organization']}                              ${orgname}_op
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${show[0]['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${show[0]['data']['outbound_security_rules'][0]}  port_range_max
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${show[0]['data']['outbound_security_rules'][1]['port_range_min']}  1
   Should Be Equal As Numbers   ${show[0]['data']['outbound_security_rules'][1]['port_range_max']}  65
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][2]['protocol']}        udp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][2]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${show[0]['data']['outbound_security_rules'][2]['port_range_min']}  3
   Should Be Equal As Numbers  ${show[0]['data']['outbound_security_rules'][2]['port_range_max']}  6
   Should Be Equal As Numbers  ${numrules}  3

   # number of trust policies be should equal to the number of cloudlets that have a trust policy
   ${cloudlets}=  Show Org Cloudlet  token=${user_token2}  region=${region}  org_name=${orgname}  use_defaults=${False}
   ${show}=  Show Trust Policy  token=${user_token2}  region=${region}  use_defaults=${False}
   ${num_trust_policys}=  Get Length  ${show}
   ${num_cloudlets_with_trustpolicy}=  Get Number Of Cloudlets with Trust Policy  ${cloudlets}
   Should Be Equal  ${num_trust_policys}  ${num_cloudlets_with_trustpolicy}
   Should Be True  ${num_trust_policys} > 0

   # show/delete as user2 should be forbidden
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}

# ECQ-3074
CreateTrustPolicy - DeveloperContributor shall not be able to create/delete but view a trust policy
   [Documentation]
   ...  - assign user to org as DeveloperContributor
   ...  - attempt to do CreateTrustPolicy/DeleteTrustPolicy
   ...  - verify proper error is returned
   ...  - do CreateTrust policy as org owner
   ...  - do ShowTrustPolicy as DeveloperContributor
   ...  - verify policy is listed

   [Tags]  TrustPolicy

   [Teardown]  Teardown Forbidden

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperContributor    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   # create as user2 should be forbidden
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}  rule_list=${rulelist}

   # create policy as org owner
   ${orgname_op}=  Create Org  token=${user_token}  orgname=${orgname}_op  orgtype=operator
   RestrictedOrg Update  org_name=${orgname_op}
   ${policy_return}=  Create Trust Policy  operator_org_name=${orgname}_op  token=${user_token}  region=${region}  rule_list=${rulelist}

   # show as user2 should return empty list since policy is not tied to a cloudlet
   ${show}=  Show Trust Policy  operator_org_name=${orgname}_op  token=${user_token2}  region=${region}
   Length Should Be  ${show}  0

   # tie the policy to a cloudlet
   Create Cloudlet  region=${region}  token=${user_token}  operator_org_name=${orgname}_op  trust_policy=${policy_return['data']['key']['name']}

   # show as user2 should return policy
   ${show}=  Show Trust Policy  operator_org_name=${orgname}_op  token=${user_token2}  region=${region}
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${show[0]['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${show[0]['data']['key']['organization']}                              ${orgname}_op

   Should Be Equal  ${show[0]['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${show[0]['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${show[0]['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${show[0]['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${show[0]['data']['outbound_security_rules'][1]['port_range_min']}  1
   Should Be Equal As Numbers   ${show[0]['data']['outbound_security_rules'][1]['port_range_max']}  65

   Should Be Equal  ${show[0]['data']['outbound_security_rules'][2]['protocol']}        udp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][2]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${show[0]['data']['outbound_security_rules'][2]['port_range_min']}  3
   Should Be Equal As Numbers  ${show[0]['data']['outbound_security_rules'][2]['port_range_max']}  6

   Should Be Equal As Numbers  ${numrules}  3

   Length Should Be  ${show}  1

   # number of trust policies be should equal to the number of cloudlets that have a trust policy
   ${cloudlets}=  Show Org Cloudlet  token=${user_token2}  region=${region}  org_name=${orgname}  use_defaults=${False}
   ${show}=  Show Trust Policy  token=${user_token2}  region=${region}  use_defaults=${False}
   ${num_trust_policys}=  Get Length  ${show}
   ${num_cloudlets_with_trustpolicy}=  Get Number Of Cloudlets with Trust Policy  ${cloudlets}
   Should Be Equal  ${num_trust_policys}  ${num_cloudlets_with_trustpolicy}
   Should Be True  ${num_trust_policys} > 0

   # show/delete as user2 should be forbidden
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}

# ECQ-3075
CreateTrustPolicy - DeveloperViewer shall not be able to create/delete but view a trust policy
   [Documentation]
   ...  - assign user to org as DeveloperViewer
   ...  - attempt to do CreateTrustPolicy/DeleteTrustPolicy
   ...  - verify proper error is returned
   ...  - do CreateTrust policy as org owner
   ...  - do ShowTrustPolicy as DeveloperViewer
   ...  - verify policy is listed

   [Tags]  TrustPolicy

   [Teardown]  Teardown Forbidden

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperViewer    token=${user_token}     use_defaults=${False}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   # create as user2 should be forbidden
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}  rule_list=${rulelist}

   # create policy as org owner
   ${orgname_op}=  Create Org  token=${user_token}  orgname=${orgname}_op  orgtype=operator
   RestrictedOrg Update  org_name=${orgname_op}
   ${policy_return}=  Create Trust Policy  operator_org_name=${orgname}_op  token=${user_token}  region=${region}  rule_list=${rulelist}

   # show as user2 should return empty list since policy is not tied to a cloudlet
   ${show}=  Show Trust Policy  operator_org_name=${orgname}_op  token=${user_token2}  region=${region}
   Length Should Be  ${show}  0

   # tie the policy to a cloudlet
   Create Cloudlet  region=${region}  token=${user_token}  operator_org_name=${orgname}_op  trust_policy=${policy_return['data']['key']['name']}

   # show as user2 should return policy
   ${show}=  Show Trust Policy  operator_org_name=${orgname}_op  token=${user_token2}  region=${region}
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${show[0]['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${show[0]['data']['key']['organization']}                              ${orgname}_op

   Should Be Equal  ${show[0]['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${show[0]['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${show[0]['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${show[0]['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${show[0]['data']['outbound_security_rules'][1]['port_range_min']}  1
   Should Be Equal As Numbers   ${show[0]['data']['outbound_security_rules'][1]['port_range_max']}  65

   Should Be Equal  ${show[0]['data']['outbound_security_rules'][2]['protocol']}        udp
   Should Be Equal  ${show[0]['data']['outbound_security_rules'][2]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${show[0]['data']['outbound_security_rules'][2]['port_range_min']}  3
   Should Be Equal As Numbers  ${show[0]['data']['outbound_security_rules'][2]['port_range_max']}  6

   Should Be Equal As Numbers  ${numrules}  3

   Length Should Be  ${show}  1

   # number of trust policies be should equal to the number of cloudlets that have a trust policy
   ${cloudlets}=  Show Org Cloudlet  token=${user_token2}  region=${region}  org_name=${orgname}  use_defaults=${False}
   ${show}=  Show Trust Policy  token=${user_token2}  region=${region}  use_defaults=${False}
   ${num_trust_policys}=  Get Length  ${show}
   ${num_cloudlets_with_trustpolicy}=  Get Number Of Cloudlets with Trust Policy  ${cloudlets}
   Should Be Equal  ${num_trust_policys}  ${num_cloudlets_with_trustpolicy}
   Should Be True  ${num_trust_policys} > 0

   # show/delete as user2 should be forbidden
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy  operator_org_name=${orgname}  token=${user_token2}  region=${region}

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

   ${policy_name}=  Get Default Trust Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}

Teardown
   Delete Trust Policy  region=${region}  operator_org_name=${orgname}  token=${user_token2}
   Cleanup Provisioning

Teardown Forbidden
   Cleanup Provisioning

Get Number Of Cloudlets with Trust Policy
   [Arguments]  ${cloudlets}

   ${counter}=  Set Variable  ${0}
   FOR  ${C}  IN  @{cloudlets}
      log to console  ${c}
      ${c2}=  Run Keyword If  'data' in ${c}  Set Variable  ${c['data']}
      ...  ELSE  Set Variable  ${c}
      ${counter}=  Run Keyword If  'trust_policy' in ${c2}  Set Variable  ${counter+1}
      ...  ELSE  Set Variable  ${counter}

   END
   [Return]  ${counter}
