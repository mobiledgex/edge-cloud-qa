*** Settings ***
Documentation  UpdateTrustPolicy

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex
${operator_name_fake}=  tmus

*** Test Cases ***
# ECQ-3048
UpdateTrustPolicy - shall be able to add rules
   [Documentation]
   ...  - send CreateTrustPolicy without rules
   ...  - update the policy by adding rules 
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   ${policy_return}=  Create Trust Policy  region=${region}

   Should Be Equal  ${policy_return['data']['key']['name']}              ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}      ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules']}  ${None}

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=6  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule1}   ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   ${numrules}=  Get Length  ${policy_return2['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  6

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][1]['protocol']}     icmp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][1]['remote_cidr']}  2.1.1.1/1

   Should Be Equal As Numbers  ${numrules}  2

# ECQ-3049
UpdateTrustPolicy - shall be able to delete rules
   [Documentation]
   ...  - send CreateTrustPolicy with rules
   ...  - update the policy by deleting the rules
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=6  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule1}   ${rule2}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                           ${operator_name}
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  6

   Should Be Equal             ${policy_return['data']['outbound_security_rules'][1]['protocol']}     icmp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}  2.1.1.1/1

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal As Numbers  ${numrules}  2

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=6  remote_cidr=1.1.1.1/1 
   @{rulelist2}=  Create List  ${rule1}

   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   ${numrules}=  Get Length  ${policy_return2['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  6

   Should Be Equal As Numbers  ${numrules}  1

# ECQ-3050
UpdateTrustPolicy - update with no rules shall not change the rules 
   [Documentation]
   ...  - send CreateTrustPolicy with rules
   ...  - update the policy with no rules 
   ...  - verify policy is not updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=6  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule1}   ${rule2}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                           ${operator_name}
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  6

   Should Be Equal             ${policy_return['data']['outbound_security_rules'][1]['protocol']}     icmp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}  2.1.1.1/1

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal As Numbers  ${numrules}  2

   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}

   ${numrules}=  Get Length  ${policy_return2['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  6

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][1]['protocol']}     icmp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][1]['remote_cidr']}  2.1.1.1/1

   Should Be Equal As Numbers  ${numrules}  2

# ECQ-3051
UpdateTrustPolicy - shall be able to update icmp cidr
   [Documentation]
   ...  - send CreateTrustPolicy with icmp 
   ...  - update the cidr
   ...  - verify policy is updated 

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                           ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}     icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}  1.1.1.1/1 

   Should Be Equal As Numbers  ${numrules}  1

   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2} 

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}     icmp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}  2.1.1.1/1

# ECQ-3052
UpdateTrustPolicy - shall be able to update with tcp and no maxport
   [Documentation]
   ...  - send CreateTrustPolicy with tcp and no maxport 
   ...  - update the port
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=15  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}  ${rule2}

   ${policy_return}=  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp 
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][1]['port_range_min']}  15
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][1]['port_range_max']}  15

   Should Be Equal As Numbers  ${numrules}  2

   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=6  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  6
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  6

# ECQ-3053
UpdateTrustPolicy - shall be able to create with tcp and maxport=0
   [Documentation]
   ...  - send CreateTrustPolicy with tcp and maxport=0 
   ...  - update the policy with maxport=0
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=9  port_range_maximum=0  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  9
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  9

   Should Be Equal As Numbers  ${numrules}  1

   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=6  port_range_maximum=0  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  6
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  6

# ECQ-3054
UpdateTrustPolicy - shall be able to update with tcp and minport/maxport
   [Documentation]
   ...  - send CreateTrustPolicy with tcp and minport/maxport 
   ...  - update the ports
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  55

   Should Be Equal As Numbers  ${numrules}  1

   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=6  port_range_maximum=66  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  6
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  66

   ${numrules2}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules2}  1

# ECQ-3055
UpdateTrustPolicy - shall be able to update with tcp and min/max port numbers
   [Documentation]
   ...  - send CreateTrustPolicy with tcp 
   ...  - update the port and max portss
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=16  port_range_maximum=65  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  16
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65 

   Should Be Equal As Numbers  ${numrules}  1

   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65535  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65535 

   ${numrules2}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules2}  1

# ECQ-3056
UpdateTrustPolicy - shall be able to update with udp and no maxport
   [Documentation]
   ...  - send CreateTrustPolicy with udp and no maxport 
   ...  - update the port
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  1

   Should Be Equal As Numbers  ${numrules}  1

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=100  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  100 

   ${numrules2}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules2}  1

# ECQ-3057
UpdateTrustPolicy - shall be able to update with udp and maxport=0
   [Documentation]
   ...  - send CreateTrustPolicy with udp and maxport=0 
   ...  - update the port
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=100  port_range_maximum=0  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  100

   Should Be Equal As Numbers  ${numrules}  1

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=100  port_range_maximum=0  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  100

   ${numrules2}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules2}  1

# ECQ-3058
UpdateTrustPolicy - shall be able to update with udp and minport/maxport
   [Documentation]
   ...  - send CreateTrustPolicy with udp and minport/maxport 
   ...  - update the ports
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=55  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  55

   Should Be Equal As Numbers  ${numrules}  1

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=100  port_range_maximum=155  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  155

   ${numrules2}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules2}  1

# ECQ-3059
UpdateTrustPolicy - shall be able to update with udp and min/max port numbers
   [Documentation]
   ...  - send CreateTrustPolicy with udp 
   ...  - update with min/max port numbers
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=12  port_range_maximum=65  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  12
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65

   Should Be Equal As Numbers  ${numrules}  1

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65535  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist2}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                           ${operator_name}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65535 

   ${numrules2}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules2}  1

# ECQ-3060
UpdateTrustPolicy - shall be able to update with tcp/udp/icmp 
   [Documentation]
   ...  - send CreateTrustPolicy with tcp/udp/icmp 
   ...  - update the rules
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}
   
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

   &{rule11}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/3
   &{rule21}=  Create Dictionary  protocol=tcp  port_range_minimum=11  port_range_maximum=651  remote_cidr=3.1.1.1/1
   &{rule31}=  Create Dictionary  protocol=udp  port_range_minimum=31  port_range_maximum=61   remote_cidr=4.1.1.1/2
   @{rulelist}=  Create List  ${rule11}  ${rule21}  ${rule31}

   ${policy_return}=  Update Trust Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][1]['port_range_min']}  11
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][1]['port_range_max']}  651

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['remote_cidr']}     4.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][2]['port_range_min']}  31
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][2]['port_range_max']}  61

   Should Be Equal As Numbers  ${numrules}  3

# ECQ-3061
UpdateTrustPolicy - shall be able to update with duplicate policy items
   [Documentation]
   ...  - send CreateTrustPolicy with duplicate policy items 
   ...  - update the policy
   ...  - verify policy is updated

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule5}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   &{rule6}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['protocol']}        icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][1]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][1]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][2]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][2]['port_range_max']}  65

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][3]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][3]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][3]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][3]['port_range_max']}  65

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][4]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][4]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][4]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][4]['port_range_max']}  6

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][5]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][5]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][5]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][5]['port_range_max']}  6

   Should Be Equal As Numbers  ${numrules}  6

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/3
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=2.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=2.1.1.1/1
   &{rule5}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=2.1.1.1/2
   &{rule6}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=2.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}

   ${policy_return}=  Update Trust Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['protocol']}        icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}     2.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][1]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][1]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['remote_cidr']}     2.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][2]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][2]['port_range_max']}  65

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][3]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][3]['remote_cidr']}     2.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][3]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][3]['port_range_max']}  65

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][4]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][4]['remote_cidr']}     2.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][4]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][4]['port_range_max']}  6

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][5]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][5]['remote_cidr']}     2.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][5]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][5]['port_range_max']}  6

   Should Be Equal As Numbers  ${numrules}  6

# ECQ-3062
UpdateTrustPolicy - shall be able to update with same rules 
   [Documentation]
   ...  - send CreateTrustPolicy with tcp/udp/icmp
   ...  - update the rules to the same rules
   ...  - verify policy is the same 

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}                              ${operator_name}

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

   ${policy_return2}=  Update Trust Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return2['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return2['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return2['data']['key']['organization']}                              ${operator_name}

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return2['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return2['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][1]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][1]['port_range_max']}  65

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][2]['protocol']}        udp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][2]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][2]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][2]['port_range_max']}  6

   Should Be Equal As Numbers  ${numrules}  3

# ECQ-3063
UpdateTrustPolicy - shall be able to update policy in use by cloudlet
   [Documentation]
   ...  - send CreateTrustPolicy 
   ...  - send CreateCloudlet witht the policy
   ...  - update the policy which is in use by the cloudlet
   ...  - verify the policy is updated
   ...  - verify the cloudlet is assinged the policy

   [Tags]  TrustPolicy

   Create Flavor  region=${region}

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${operator_name_fake}

   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${policy_return['data']['key']['name']}
   Should Be Equal             ${cloudlet['data']['trust_policy']}  ${policy_return['data']['key']['name']}
   Should Be Equal As Numbers  ${cloudlet['data']['trust_policy_state']}  5

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=3001  port_range_maximum=4001  remote_cidr=3.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=3002  port_range_maximum=4002  remote_cidr=3.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=icmp  remote_cidr=4.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}  ${rule3}  ${rule4}

   ${policy_post}=  Update Trust Policy  region=${region}  token=${token}  operator_org_name=${operator_name_fake}  rule_list=${rulelist2}
   Should Be Equal  ${policy_post['data']['key']['name']}           ${policy_name}
   Should Be Equal  ${policy_post['data']['key']['organization']}   ${operator_name_fake}

   Should Be Equal  ${policy_post['data']['outbound_security_rules'][2]['protocol']}        icmp 
   Should Be Equal  ${policy_post['data']['outbound_security_rules'][2]['remote_cidr']}     4.1.1.1/1
   Should Not Contain  ${policy_post['data']['outbound_security_rules'][2]}  port_range_min
   Should Not Contain  ${policy_post['data']['outbound_security_rules'][2]}  port_range_max

   Should Be Equal  ${policy_post['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${policy_post['data']['outbound_security_rules'][1]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers   ${policy_post['data']['outbound_security_rules'][1]['port_range_min']}  3002
   Should Be Equal As Numbers   ${policy_post['data']['outbound_security_rules'][1]['port_range_max']}  4002

   Should Be Equal  ${policy_post['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_post['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_post['data']['outbound_security_rules'][0]['port_range_min']}  3001 
   Should Be Equal As Numbers  ${policy_post['data']['outbound_security_rules'][0]['port_range_max']}  4001 

   ${numrules_post}=  Get Length  ${policy_post['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules_post}  3

   ${cloudlet_post}=  Show Cloudlets  region=${region}  operator_org_name=${operator_name_fake}
   Should Be Equal             ${cloudlet_post[0]['data']['trust_policy']}  ${policy_return['data']['key']['name']}
   Should Be Equal As Numbers  ${cloudlet_post[0]['data']['trust_policy_state']}  5

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Trust Policy Name
   ${operator_name}=  Get Default Organization Name

   Create Org

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${operator_name}
