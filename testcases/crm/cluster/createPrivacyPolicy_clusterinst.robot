*** Settings ***
Documentation  CreatePrivacyPolicy on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack  environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV} 
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  EU 
${developer}=  mobiledgex

${cloudlet_name_openstack_dedicated}=  automationMunichCloudlet
${operator_name_openstack}=  TDG

*** Test Cases ***
# combined this with all protocols in 1 testcase
CreatePrivacyPolicy - shall be able to create docker cluster with icmp
   [Documentation]
   ...  send CreatePrivacyPolicy with policy and developer name only
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist} 

   ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated  privacy_policy=${policy_return['data']['key']['name']}

   ${cloudname}=  Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['name']}
   ${operator}=   Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['operator_key']['name']}
   ${openstack_group_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg 

#   ${openstack_group_name}=  Set Variable  cluster1580499248-811533.automationmunichcloudlet.tdg.mobiledgex.net-sg 
   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/1'

   @{openstackrules}=  Get Security Group Rules  protocol=icmp  group_id=${openstacksecgroup['id']}
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            icmp
   Should Be Equal  ${openstackrules[0]['IP Range']}               1.1.1.1/1 
   Should Be Equal  ${openstackrules[0]['Port Range']}             ${EMPTY} 
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None} 

# combined this with all protocols in 1 testcase
CreatePrivacyPolicy - shall be able to create docker cluster with tcp 
   [Documentation]
   ...  send CreatePrivacyPolicy with policy and developer name only
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=100  port_range_maximum=200  remote_cidr=2.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated  privacy_policy=${policy_return['data']['key']['name']}

   ${cloudname}=  Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['name']}
   ${operator}=   Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['operator_key']['name']}
   ${openstack_group_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg

#   ${openstack_group_name}=  Set Variable  cluster1580499248-811533.automationmunichcloudlet.tdg.mobiledgex.net-sg
   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.1.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp 
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             100:200 
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

# combined this with all protocols in 1 testcase
CreatePrivacyPolicy - shall be able to create docker cluster with udp
   [Documentation]
   ...  send CreatePrivacyPolicy with policy and developer name only
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated  privacy_policy=${policy_return['data']['key']['name']}

   ${cloudname}=  Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['name']}
   ${operator}=   Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['operator_key']['name']}
   ${openstack_group_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg

   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3.1.1.1/1'

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.1.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1001:2001
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

# ECQ-1823
CreatePrivacyPolicy - shall be able to create docker cluster with icmp/tcp/udp
   [Documentation]
   ...  send docker CreateClusterInst with PrivacyPolicy with multiple icmp/tcp/udp rules
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=100  port_range_maximum=200  remote_cidr=2.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=102  remote_cidr=2.2.1.1/1
   &{rule5}=  Create Dictionary  protocol=tcp  port_range_minimum=500  port_range_maximum=700  remote_cidr=2.3.1.1/1
   &{rule6}=  Create Dictionary  protocol=tcp  port_range_minimum=1000  port_range_maximum=2000  remote_cidr=2.4.1.1/1
   &{rule7}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=2.5.1.1/1
   &{rule8}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=2  remote_cidr=3.2.1.1/1
   &{rule9}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=4  remote_cidr=3.3.1.1/1
   &{rule10}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=5  remote_cidr=3.4.1.1/1
   &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=7  port_range_maximum=9  remote_cidr=3.5.1.1/1

   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}  ${rule7}  ${rule8}  ${rule9}  ${rule10}  ${rule11}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated  privacy_policy=${policy_return['data']['key']['name']}

   ${cloudname}=  Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['name']}
   ${operator}=   Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['organization']}
   ${openstack_group_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg
   ${crmserver_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cloudlet_key']['name']}  ${cluster['data']['key']['cloudlet_key']['organization']}  pf

   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/1'

   # get rules
   @{openstackrules}=  Get Security Group Rules  group_id=${openstacksecgroup['id']}
   ${num_rules}=  Get Length  ${openstackrules}

   Should Be Equal As Numbers  ${num_rules}  12

   #Rules Should Exist  ${rules}  ${openstackrules}

   @{serverlist}=  Get Server List  ${crmserver_name} 
   @{crm_ip}=  Split String  ${serverlist[0]['Networks']}  separator==

   # get normal 22 rule
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=${crm_ip[1]}/32
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               ${crm_ip[1]}/32
   Should Be Equal  ${openstackrules[0]['Port Range']}             22:22
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   # get ICMP rules
   @{openstackrules}=  Get Security Group Rules  protocol=icmp  group_id=${openstacksecgroup['id']}
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            icmp
   Should Be Equal  ${openstackrules[0]['IP Range']}               1.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             ${EMPTY}
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}
 
   # get UDP rules
   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.1.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1001:2001
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.2.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.2.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1:2
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.3.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.3.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             3:4
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.4.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.4.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             5:5
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.5.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.5.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             7:9
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   # get TCP rules
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.1.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             100:200
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.2.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.2.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             101:102
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.3.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.3.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             500:700
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.4.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.4.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1000:2000
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.5.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.5.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1:2
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

CreatePrivacyPolicy - shall be able to create k8s dedicated cluster with icmp/tcp/udp
   [Documentation]
   ...  send k8s dedicated CreateClusterInst with PrivacyPolicy with multiple icmp/tcp/udp rules 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=100  port_range_maximum=200  remote_cidr=2.1.1.1/1
   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=102  remote_cidr=2.2.1.1/1
   &{rule5}=  Create Dictionary  protocol=tcp  port_range_minimum=500  port_range_maximum=700  remote_cidr=2.3.1.1/1
   &{rule6}=  Create Dictionary  protocol=tcp  port_range_minimum=1000  port_range_maximum=2000  remote_cidr=2.4.1.1/1
   &{rule7}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=2.5.1.1/1
   &{rule8}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=2  remote_cidr=3.2.1.1/1
   &{rule9}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=4  remote_cidr=3.3.1.1/1
   &{rule10}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=5  remote_cidr=3.4.1.1/1
   &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=7  port_range_maximum=9  remote_cidr=3.5.1.1/1

   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}  ${rule7}  ${rule8}  ${rule9}  ${rule10}  ${rule11}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1  privacy_policy=${policy_return['data']['key']['name']}

   ${cloudname}=  Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['name']}
   ${operator}=   Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['organization']}
   ${openstack_group_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg
   ${crmserver_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cloudlet_key']['name']}  ${cluster['data']['key']['cloudlet_key']['organization']}  pf

   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/1'

   # get rules
   @{openstackrules}=  Get Security Group Rules  group_id=${openstacksecgroup['id']}
   ${num_rules}=  Get Length  ${openstackrules}

   Should Be Equal As Numbers  ${num_rules}  12

   #Rules Should Exist  ${rules}  ${openstackrules}

   @{serverlist}=  Get Server List  ${crmserver_name}
   @{crm_ip}=  Split String  ${serverlist[0]['Networks']}  separator==

   # get normal 22 rule
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=${crm_ip[1]}/32
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               ${crm_ip[1]}/32
   Should Be Equal  ${openstackrules[0]['Port Range']}             22:22
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   # get ICMP rules
   @{openstackrules}=  Get Security Group Rules  protocol=icmp  group_id=${openstacksecgroup['id']}
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            icmp
   Should Be Equal  ${openstackrules[0]['IP Range']}               1.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             ${EMPTY}
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   # get UDP rules
   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.1.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1001:2001
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.2.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.2.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1:2
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.3.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.3.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             3:4
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.4.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.4.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             5:5
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.5.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.5.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             7:9
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   # get TCP rules
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.1.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             100:200
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.2.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.2.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             101:102
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.3.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.3.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             500:700
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.4.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.4.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1000:2000
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.5.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.5.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             1:2
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

CreatePrivacyPolicy - shall be able to create cluster after policy update 
   [Documentation]
   ...  send CreatePrivacyPolicy on openstack after a policy update 
   ...  verify policy is created

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=100  port_range_maximum=200  remote_cidr=2.1.1.1/1
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=2001  port_range_maximum=3001  remote_cidr=3.2.1.1/1
   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/2
   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=100  port_range_maximum=201  remote_cidr=2.1.1.1/1
   @{rulelist2}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${policy_return2}=  Update Privacy Policy  region=${region}  rule_list=${rulelist2}

   ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessDedicated  privacy_policy=${policy_return['data']['key']['name']}

   ${cloudname}=  Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['name']}
   ${operator}=   Convert To Lowercase  ${cluster['data']['key']['cloudlet_key']['organization']}
   ${openstack_group_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg
   ${crmserver_name}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cloudlet_key']['name']}  ${cluster['data']['key']['cloudlet_key']['organization']}  pf

   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='3001', port_range_min='2001', protocol='udp', remote_ip_prefix='3.2.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='201', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/2'

   # get rules
   @{openstackrules}=  Get Security Group Rules  group_id=${openstacksecgroup['id']}
   ${num_rules}=  Get Length  ${openstackrules}

   Should Be Equal As Numbers  ${num_rules}  4

   @{serverlist}=  Get Server List  ${crmserver_name}
   @{crm_ip}=  Split String  ${serverlist[0]['Networks']}  separator==

   # get normal 22 rule
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=${crm_ip[1]}/32
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               ${crm_ip[1]}/32
   Should Be Equal  ${openstackrules[0]['Port Range']}             22:22
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   # get ICMP rules
   @{openstackrules}=  Get Security Group Rules  protocol=icmp  group_id=${openstacksecgroup['id']}
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            icmp
   Should Be Equal  ${openstackrules[0]['IP Range']}               1.1.1.1/2
   Should Be Equal  ${openstackrules[0]['Port Range']}             ${EMPTY}
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   # get UDP rules
   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.2.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            udp
   Should Be Equal  ${openstackrules[0]['IP Range']}               3.2.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             2001:3001
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

   # get TCP rules
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.1.1.1/1
   Should Be Equal  ${openstackrules[0]['IP Protocol']}            tcp
   Should Be Equal  ${openstackrules[0]['IP Range']}               2.1.1.1/1
   Should Be Equal  ${openstackrules[0]['Port Range']}             100:201
   Should Be Equal  ${openstackrules[0]['Remote Security Group']}  ${None}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Privacy Policy Name
   ${developer_name}=  Get Default Developer Name
   
   Create Flavor  region=${region}

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
