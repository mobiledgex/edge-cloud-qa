*** Settings ***
Documentation  CreatePrivacyPolicy

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

*** Test Cases ***
CreatePrivacyPolicy - shall be able to create with policy and developer name only
   [Documentation]
   ...  send CreatePrivacyPolicy with policy and developer name only
   ...  verify policy is created

   ${name}=  Generate Random String  length=10

   ${policy_return}=  Create Privacy Policy  region=${region}  token=${token}  policy_name=${name}  developer_name=${developer}  use_defaults=${False}

   Should Be Equal  ${policy_return['data']['key']['name']}       ${name}
   Should Be Equal  ${policy_return['data']['key']['developer']}  ${developer}

CreatePrivacyPolicy - shall be able to create with long policy name 
   [Documentation]
   ...  send CreatePrivacyPolicy with long policy name 
   ...  verify policy is created 

   ${name}=  Generate Random String  length=100

   ${policy_return}=  Create Privacy Policy  region=US  token=${token}  policy_name=${name}  developer_name=${developer} 

   Should Be Equal  ${policy_return['data']['key']['name']}  ${name} 

CreatePrivacyPolicy - shall be able to create with numbers in policy name 
   [Documentation]
   ...  send CreatePrivacyPolicy with numbers in policy name
   ...  verify policy is created 

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}
   
   ${policy_return}=  Create Privacy Policy  region=US  token=${token}  policy_name=${epoch}  developer_name=${developer}  use_defaults=False

   Should Be Equal  ${policy_return['data']['key']['name']}  ${epoch} 

CreatePrivacyPolicy - shall be able to create with icmp 
   [Documentation]
   ...  send CreatePrivacyPolicy with icmp 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                           ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}     icmp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}  1.1.1.1/1 

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with tcp and no maxport
   [Documentation]
   ...  send CreatePrivacyPolicy with tcp and no maxport 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp 
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  5

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with tcp and maxport=0
   [Documentation]
   ...  send CreatePrivacyPolicy with tcp and maxport=0 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=9  port_range_maximum=0  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  9
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  9

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with tcp and minport/maxport
   [Documentation]
   ...  send CreatePrivacyPolicy with tcp and minport/maxport 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  55

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with tcp and min/max port numbers
   [Documentation]
   ...  send CreatePrivacyPolicy with tcp and min/max port numbers 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65535  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        tcp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65535 

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with udp and no maxport
   [Documentation]
   ...  send CreatePrivacyPolicy with udp and no maxport 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  1

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with udp and maxport=0
   [Documentation]
   ...  send CreatePrivacyPolicy with udp and maxport=0 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=100  port_range_maximum=0  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  100
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  100

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with udp and minport/maxport
   [Documentation]
   ...  send CreatePrivacyPolicy with udp and minport/maxport 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=55  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  5
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  55

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with udp and min/max port numbers
   [Documentation]
   ...  send CreatePrivacyPolicy with udp and min/max port numbers 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65535  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist} 

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal  ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     1.1.1.1/1

   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  65535

   Should Be Equal As Numbers  ${numrules}  1

CreatePrivacyPolicy - shall be able to create with tcp/udp/icmp 
   [Documentation]
   ...  send CreatePrivacyPolicy with tcp/udp/icmp 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}
   
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

CreatePrivacyPolicy - shall be able to create with duplicate policy items
   [Documentation]
   ...  send CreatePrivacyPolicy with duplicate policy items 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule5}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   &{rule6}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}

   Should Be Equal  ${policy_return['data']['key']['name']}                                   ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['developer']}                              ${developer_name}

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


*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Privacy Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
