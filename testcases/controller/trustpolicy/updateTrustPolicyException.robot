*** Settings ***
Documentation  UpdateTrustPolicyException

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${operator_name}=  tmus

*** Test Cases ***
# ECQ-4147
UpdateTrustPolicyException - shall be able to add rules 
   [Documentation]
   ...  - send CreateTrustPolicyException without rules
   ...  - send UpdateTrustPolicyException to add rules
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']} 

   Verify Key  ${policy_return} 

   Should Be Equal   ${policy_return['data']['outbound_security_rules']}  ${None}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_updated}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_updated}

   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][0]['protocol']}        icmp 
   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Length Should Be   ${policy_updated['data']['outbound_security_rules']}  1

# ECQ-4148
UpdateTrustPolicyException - shall be able to delete rules
   [Documentation]
   ...  - send CreateTrustPolicyException with rules
   ...  - send UpdateTrustPolicyException to remove some rules
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=6  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/1
   @{rulelist}=  Create List  ${rule1}   ${rule2}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return} 

   Length Should Be   ${policy_return['data']['outbound_security_rules']}  2

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=6  remote_cidr=1.1.1.1/1
   @{rulelist2}=  Create List  ${rule1}

   ${policy_updated}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   rule_list=${rulelist2}

   Verify Key  ${policy_updated}

   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][0]['protocol']}        tcp 
   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  6

   Length Should Be   ${policy_updated['data']['outbound_security_rules']}  1

# ECQ-4149
UpdateTrustPolicyException - shall be able to delete all rules
   [Documentation]
   ...  - send CreateTrustPolicyException with rules
   ...  - send UpdateTrustPolicyException to remove all rules
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=6  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/1
   @{rulelist}=  Create List  ${rule1}   ${rule2}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Length Should Be   ${policy_return['data']['outbound_security_rules']}  2

   @{rulelist2}=  Create List  empty

   ${policy_updated}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   rule_list=${rulelist2}

   Verify Key  ${policy_updated}

   Should Be Equal  ${policy_updated['data']['outbound_security_rules']}  ${None}

# ECQ-4150
UpdateTrustPolicyException - update with no rules shall not change the rules
   [Documentation]
   ...  - send CreateTrustPolicyException with rules
   ...  - send UpdateTrustPolicyException with no rules
   ...  - verify policy is not updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=6  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/1
   @{rulelist}=  Create List  ${rule1}   ${rule2}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  6
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['protocol']}        icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}     2.1.1.1/1

   Length Should Be   ${policy_return['data']['outbound_security_rules']}  2

   ${policy_updated}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']} 

   Verify Key  ${policy_updated}

   Length Should Be   ${policy_return['data']['outbound_security_rules']}  2

   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_updated['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_updated['data']['outbound_security_rules'][0]['port_range_max']}  6
   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][1]['protocol']}        icmp
   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][1]['remote_cidr']}     2.1.1.1/1

# ECQ-4151
UpdateTrustPolicyException - shall be able to update icmp cidr
   [Documentation]
   ...  - send CreateTrustPolicyException with icmp
   ...  - send UpdateTrustPolicyException to update cidr
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Length Should Be   ${policy_return['data']['outbound_security_rules']}  1

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}

   ${policy_updated}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_updated}

   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_updated['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/1

   Length Should Be   ${policy_updated['data']['outbound_security_rules']}  1

# ECQ-4152
UpdateTrustPolicyException - shall be able to update with tcp and no maxport
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp and no maxport
   ...  - update the port
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=15  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}  ${rule2}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][1]['port_range_min']}  15
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][1]['port_range_max']}  15

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   2

   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=6  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  6
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  6

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   1

# ECQ-4153
UpdateTrustPolicyException - shall be able to update with tcp and maxport=0
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp and maxport=0
   ...  - update the port with maxport=0
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=0  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1} 

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  5

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   1

   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=6  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  6
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  6

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   1

# ECQ-4154
UpdateTrustPolicyException - shall be able to update with tcp and minport/maxport
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp and minport/maxport
   ...  - update the ports
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}
   
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  55

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   1

   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=6  port_range_maximum=66  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  6
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  66

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   1

# ECQ-4155
UpdateTrustPolicyException - shall be able to update with tcp and min/max port numbers
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp
   ...  - update the port and max ports
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=16  port_range_maximum=65  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  16
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   1

   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65535  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65535

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   1

# ECQ-4156
UpdateTrustPolicyException - shall be able to update with udp and no maxport
   [Documentation]
   ...  - send CreateTrustPolicyException with udp and no maxport
   ...  - update the port
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  1

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   1

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=100  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  100

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   1

# ECQ-4157
UpdateTrustPolicyException - shall be able to update with udp and maxport=0
   [Documentation]
   ...  - send CreateTrustPolicyException with udp and maxport=0
   ...  - update the port
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=100  port_range_maximum=0  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  100

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   1

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=100  port_range_maximum=0  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  100

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   1

# ECQ-4158
UpdateTrustPolicyException - shall be able to update with udp and min/max port numbers
   [Documentation]
   ...  - send CreateTrustPolicyException with udp
   ...  - update with min/max port numbers
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=12  port_range_maximum=65  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  12
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   1

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65535  remote_cidr=6.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     6.1.1.1/1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65535

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   1

# ECQ-4159
UpdateTrustPolicyException - shall be able to update with tcp/udp/icmp
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp/udp/icmp
   ...  - update the rules
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

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

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   3

   &{rule11}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/3
   &{rule21}=  Create Dictionary  protocol=tcp  port_range_minimum=11  port_range_maximum=651  remote_cidr=3.1.1.1/1
   &{rule31}=  Create Dictionary  protocol=udp  port_range_minimum=31  port_range_maximum=61   remote_cidr=4.1.1.1/2
   @{rulelist2}=  Create List  ${rule11}  ${rule21}  ${rule31}

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/3
   Should Not Contain  ${policy_return2['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return2['data']['outbound_security_rules'][0]}  port_range_max
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][1]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][1]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][1]['port_range_min']}  11
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][1]['port_range_max']}  651
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][2]['protocol']}        udp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][2]['remote_cidr']}     4.1.1.1/2
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][2]['port_range_min']}  31
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][2]['port_range_max']}  61

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   3

# ECQ-4160
UpdateTrustPolicy - shall be able to update with duplicate policy items
   [Documentation]
   ...  - send CreateTrustPolicy with duplicate policy items
   ...  - update the policy
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule5}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   &{rule6}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

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

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   6

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=2.1.1.1/3
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=2.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=2.1.1.1/1
   &{rule5}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=2.1.1.1/2
   &{rule6}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=2.1.1.1/2
   @{rulelist2}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist2}

   Verify Key  ${policy_return2}

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        icmp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     2.1.1.1/3
   Should Not Contain  ${policy_return2['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return2['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][1]['protocol']}        icmp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][1]['remote_cidr']}     2.1.1.1/3
   Should Not Contain  ${policy_return2['data']['outbound_security_rules'][1]}  port_range_min
   Should Not Contain  ${policy_return2['data']['outbound_security_rules'][1]}  port_range_max

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][2]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][2]['remote_cidr']}     2.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][2]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][2]['port_range_max']}  65

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][3]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][3]['remote_cidr']}     2.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][3]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][3]['port_range_max']}  65

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][4]['protocol']}        udp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][4]['remote_cidr']}     2.1.1.1/2
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][4]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][4]['port_range_max']}  6

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][5]['protocol']}        udp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][5]['remote_cidr']}     2.1.1.1/2
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][5]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return2['data']['outbound_security_rules'][5]['port_range_max']}  6

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   6

# ECQ-4161
UpdateTrustPolicyException - shall be able to update with same rules
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp/udp/icmp
   ...  - update the rules to the same rules
   ...  - verify policy is the same

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

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

   Length Should Be  ${policy_return['data']['outbound_security_rules']}   3

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return2}

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

   Length Should Be  ${policy_return2['data']['outbound_security_rules']}   3

# ECQ-4162
UpdateTrustPolicyException - operator shall be able to update to Active
   [Documentation]
   ...  - developer sends CreateTrustPolicyException with tcp/udp/icmp
   ...  - operator sends update with state=Active
   ...  - verify state is updated

   [Tags]  TrustPolicyException

   ${optoken}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${optoken}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  state=Active

   Verify Key  ${policy_return2}  state=Active

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${optoken}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  state=Active

   Verify Key  ${policy_return2}  state=Active

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65

# ECQ-4163
UpdateTrustPolicyException - operator shall be able to update to Rejected
   [Documentation]
   ...  - developer sends CreateTrustPolicyException with tcp/udp/icmp
   ...  - operator sends update with state=Rejected
   ...  - verify state is updated

   [Tags]  TrustPolicyException

   ${optoken}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${optoken}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  state=Rejected

   Verify Key  ${policy_return2}  state=Rejected

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${optoken}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  state=Rejected

   Verify Key  ${policy_return2}  state=Rejected

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65

# ECQ-4164
UpdateTrustPolicyException - operator shall be able to update to Active/Rejected
   [Documentation]
   ...  - developer sends CreateTrustPolicyException with tcp/udp/icmp
   ...  - operator sends update with state=Active
   ...  - operator sends update with state=Rejected
   ...  - operator sends update with state=Active
   ...  - verify state is updated

   [Tags]  TrustPolicyException

   ${optoken}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${optoken}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  state=Active

   Verify Key  ${policy_return2}  state=Active

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${optoken}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  state=Rejected

   Verify Key  ${policy_return2}  state=Rejected

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65

   ${policy_return2}=  Update Trust Policy Exception  region=${region}  token=${optoken}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  state=Active

   Verify Key  ${policy_return2}  state=Active

   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return2['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return2['data']['outbound_security_rules'][0]['port_range_max']}  65

*** Keywords ***
Setup
   ${supertoken}=  Get Super Token
   ${token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   Set Suite Variable  ${token}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${supertoken}
   Set Suite Variable  ${pool}

   ${policy_name}=  Get Default Trust Policy Name
   ${operator_name}=  Get Default Operator Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${operator_name}

Verify Key
   [Arguments]  ${policy_return}  ${name}=${policy_name}  ${state}=ApprovalRequested

   Should Be Equal  ${policy_return['data']['key']['name']}       ${name}

   Should Be Equal  ${policy_return['data']['key']['app_key']['name']}          ${app_name_automation}
   Should Be Equal  ${policy_return['data']['key']['app_key']['organization']}  ${developer_org_name_automation}
   Should Be Equal  ${policy_return['data']['key']['app_key']['version']}       1.0

   Should Be Equal  ${policy_return['data']['key']['cloudlet_pool_key']['name']}          ${pool['data']['key']['name']}
   Should Be Equal  ${policy_return['data']['key']['cloudlet_pool_key']['organization']}  ${pool['data']['key']['organization']}

   Should Be Equal  ${policy_return['data']['state']}  ${state}

