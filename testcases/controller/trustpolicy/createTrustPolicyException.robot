*** Settings ***
Documentation  CreateTrustPolicyException

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${operator_name}=  tmus

*** Test Cases ***
# security rules are now required 
## ECQ-4133
#CreateTrustPolicyException - shall be able to create exception without rules
#   [Documentation]
#   ...  - send CreateTrustPolicyException without rules
#   ...  - verify policy is created
#
#   [Tags]  TrustPolicyException
#
#   ${name}=  Generate Random String  length=10
#
#   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  policy_name=${name}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  use_defaults=${False}
#
#   Verify Key  ${policy_return}  ${name}
#
#   Should Be Equal  ${policy_return['data']['outbound_security_rules']}  ${None}

# ECQ-4134
CreateTrustPolicyException - shall be able to create exception with long policy name 
   [Documentation]
   ...  - send CreateTrustPolicyException with long policy name 
   ...  - verify policy is created 

   [Tags]  TrustPolicyException

   ${name}=  Generate Random String  length=100

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  policy_name=${name}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

   Verify Key  ${policy_return}  ${name}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        ICMP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_max

# ECQ-4135
CreateTrustPolicyException - shall be able to create exception with numbers in policy name 
   [Documentation]
   ...  - send CreateTrustPolicyException with numbers in policy name
   ...  - verify policy is created 

   [Tags]  TrustPolicyException

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   @{rulelist}=  Create List  ${rule1}
   
   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  policy_name=${epoch}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}  ${epoch}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        ICMP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_max

# ECQ-4136
CreateTrustPolicyException - shall be able to create exception with icmp 
   [Documentation]
   ...  - send CreateTrustPolicyException with icmp 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}     ICMP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}  1.1.1.1/1 

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4137
CreateTrustPolicyException - shall be able to create exception with tcp and no maxport
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp and no maxport 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        TCP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  5

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4138
CreateTrustPolicyException - shall be able to create exception with tcp and maxport=0
   [Documentation]
   ...  - send CreateTrustPolicyExcption with tcp and maxport=0 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=9  port_range_maximum=0  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        TCP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  9
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  9

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4139
CreateTrustPolicyException - shall be able to create exception with tcp and minport/maxport
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp and minport/maxport 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        TCP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  55

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4140
CreateTrustPolicyException - shall be able to create exception with tcp and min/max port numbers
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp and min/max port numbers 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65535  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        TCP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65535 

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4141
CreateTrustPolicyException - shall be able to create exception with udp and no maxport
   [Documentation]
   ...  - send CreateTrustPolicyException with udp and no maxport 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        UDP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  1

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4142
CreateTrustPolicyException - shall be able to create exception with udp and maxport=0
   [Documentation]
   ...  - send CreateTrustPolicyException with udp and maxport=0 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=100  port_range_maximum=0  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        UDP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  100

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4143
CreateTrustPolicyException - shall be able to create exception with udp and minport/maxport
   [Documentation]
   ...  - send CreateTrustPolicyException with udp and minport/maxport 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=55  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        UDP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  55

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4144
CreateTrustPolicyException - shall be able to create exception with udp and min/max port numbers
   [Documentation]
   ...  - send CreateTrustPolicyException with udp and min/max port numbers 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65535  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        UDP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65535

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  1

# ECQ-4145
CreateTrustPolicyException - shall be able to create exception with tcp/udp/icmp 
   [Documentation]
   ...  - send CreateTrustPolicyException with tcp/udp/icmp 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        ICMP 
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['protocol']}        TCP 
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][1]['port_range_min']}  1 
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][1]['port_range_max']}  65

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['protocol']}        UDP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][2]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][2]['port_range_max']}  6

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  3

# ECQ-4146
CreateTrustPolicyException - shall be able to create exception with duplicate policy items
   [Documentation]
   ...  - send CreateTrustPolicyException with duplicate policy items 
   ...  - verify policy is created

   [Tags]  TrustPolicyException

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule5}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   &{rule6}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Verify Key  ${policy_return}

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        ICMP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][0]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['protocol']}        ICMP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][1]['remote_cidr']}     1.1.1.1/3
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][1]}  port_range_min
   Should Not Contain  ${policy_return['data']['outbound_security_rules'][1]}  port_range_max

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['protocol']}        TCP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][2]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][2]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][2]['port_range_max']}  65

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][3]['protocol']}        TCP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][3]['remote_cidr']}     1.1.1.1/1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][3]['port_range_min']}  1
   Should Be Equal As Numbers   ${policy_return['data']['outbound_security_rules'][3]['port_range_max']}  65

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][4]['protocol']}        UDP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][4]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][4]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][4]['port_range_max']}  6

   Should Be Equal  ${policy_return['data']['outbound_security_rules'][5]['protocol']}        UDP
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][5]['remote_cidr']}     1.1.1.1/2
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][5]['port_range_min']}  3
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][5]['port_range_max']}  6

   Length Should Be  ${policy_return['data']['outbound_security_rules']}  6

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}
   Set Suite Variable  ${pool}

   ${policy_name}=  Get Default Trust Policy Name
   ${operator_name}=  Get Default Operator Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${operator_name}

Verify Key
   [Arguments]  ${policy_return}  ${name}=${policy_name}

   Should Be Equal  ${policy_return['data']['key']['name']}       ${name}

   Should Be Equal  ${policy_return['data']['key']['app_key']['name']}          ${app_name_automation_trusted}
   Should Be Equal  ${policy_return['data']['key']['app_key']['organization']}  ${developer_org_name_automation}
   Should Be Equal  ${policy_return['data']['key']['app_key']['version']}       1.0

   Should Be Equal  ${policy_return['data']['key']['cloudlet_pool_key']['name']}          ${pool['data']['key']['name']}
   Should Be Equal  ${policy_return['data']['key']['cloudlet_pool_key']['organization']}  ${pool['data']['key']['organization']}

   Should Be Equal  ${policy_return['data']['state']}  ApprovalRequested

