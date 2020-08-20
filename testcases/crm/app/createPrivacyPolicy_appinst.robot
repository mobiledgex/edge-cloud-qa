*** Settings ***
Documentation  CreatePrivacyPolicy on openstack with autocluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack  environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV} 
Library  String
     
Test Setup  Setup
#Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  EU 
${developer}=  mobiledgex

${cloudlet_name_openstack_dedicated}=  automationMunichCloudlet
${operator}=  TDG

*** Test Cases ***
# ECQ-2018
CreatePrivacyPolicy - shall be able to create docker dedicated appinst autocluster with icmp/tcp/udp
   [Documentation]
   ...  send docker dedicated CreateAppInst with PrivacyPolicy with multiple icmp/tcp/udp rules
   ...  verify policy is created

   Create Flavor  region=${region}

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

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016,tcp:8085  image_type=ImageTypeDocker  deployment=docker
   ${app}=  Create App Instance  region=${region}  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator}  autocluster_ip_access=IpAccessDedicated  privacy_policy=${policy_return['data']['key']['name']}

   ${cloudname}=  Convert To Lowercase  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
   ${operator}=   Convert To Lowercase  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}
   ${openstack_group_name}=  Catenate  SEPARATOR=.  ${app['data']['key']['cluster_inst_key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg
   ${crmserver_name}=  Catenate  SEPARATOR=.  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  pf

   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/1'

   # get rules
   @{openstackrules}=  Get Security Group Rules  group_id=${openstacksecgroup['id']}
   ${num_rules}=  Get Length  ${openstackrules}

   Should Be Equal As Numbers  ${num_rules}  17

   #Rules Should Exist  ${rules}  ${openstackrules}

   @{serverlist}=  Get Server List  ${crmserver_name} 
   @{crm_ip}=  Split String  ${serverlist[0]['Networks']}  separator==

   # get normal 443 rule
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=8085:8085  ip=0.0.0.0/0
   #Rule Should Exist  ${openstackrules}  proto=tcp  port=443:443  ip=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=2015:2015  ip=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=2016:2016  ip=0.0.0.0/0

   # get normal 22 rule
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=${crm_ip[1]}/32
   Rule Should Exist  ${openstackrules}  proto=tcp  port=22:22  ip=${crm_ip[1]}/32

   # get ICMP rules
   @{openstackrules}=  Get Security Group Rules  protocol=icmp  group_id=${openstacksecgroup['id']}
   Rule Should Exist  ${openstackrules}  proto=icmp  port=${EMPTY}  ip=1.1.1.1/1
 
   # get UDP rules
   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.1.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=1001:2001  ip=3.1.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.2.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=1:2  ip=3.2.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.3.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=3:4  ip=3.3.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.4.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=5:5  ip=3.4.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.5.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=7:9  ip=3.5.1.1/1

   # get TCP rules
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.1.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=100:200  ip=2.1.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.2.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=101:102  ip=2.2.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.3.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=500:700  ip=2.3.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.4.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=1000:2000  ip=2.4.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.5.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=1:2  ip=2.5.1.1/1

# ECQ-2019
CreatePrivacyPolicy - shall be able to create k8s dedicated appinst autocluster with icmp/tcp/udp
   [Documentation]
   ...  send k8s dedicated CreateAppInst with PrivacyPolicy with multiple icmp/tcp/udp rules
   ...  verify policy is created

   Create Flavor  region=${region}

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

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes 
   ${app}=  Create App Instance  region=${region}  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator}  autocluster_ip_access=IpAccessDedicated  privacy_policy=${policy_return['data']['key']['name']}

   ${cloudname}=  Convert To Lowercase  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
   ${operator}=   Convert To Lowercase  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}
   ${openstack_group_name}=  Catenate  SEPARATOR=.  ${app['data']['key']['cluster_inst_key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg
   ${crmserver_name}=  Catenate  SEPARATOR=.  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  pf

   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/1'

   # get rules
   @{openstackrules}=  Get Security Group Rules  group_id=${openstacksecgroup['id']}
   ${num_rules}=  Get Length  ${openstackrules}

   Should Be Equal As Numbers  ${num_rules}  17

   #Rules Should Exist  ${rules}  ${openstackrules}

   @{serverlist}=  Get Server List  ${crmserver_name}
   @{crm_ip}=  Split String  ${serverlist[0]['Networks']}  separator==

   # get normal 443 rule
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=8085:8085  ip=0.0.0.0/0
   #Rule Should Exist  ${openstackrules}  proto=tcp  port=443:443  ip=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=2015:2015  ip=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=2016:2016  ip=0.0.0.0/0

   # get normal 22 rule
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=${crm_ip[1]}/32
   Rule Should Exist  ${openstackrules}  proto=tcp  port=22:22  ip=${crm_ip[1]}/32

   # get ICMP rules
   @{openstackrules}=  Get Security Group Rules  protocol=icmp  group_id=${openstacksecgroup['id']}
   Rule Should Exist  ${openstackrules}  proto=icmp  port=${EMPTY}  ip=1.1.1.1/1

   # get UDP rules
   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.1.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=1001:2001  ip=3.1.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.2.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=1:2  ip=3.2.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.3.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=3:4  ip=3.3.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.4.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=5:5  ip=3.4.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.5.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=7:9  ip=3.5.1.1/1

   # get TCP rules
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.1.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=100:200  ip=2.1.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.2.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=101:102  ip=2.2.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.3.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=500:700  ip=2.3.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.4.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=1000:2000  ip=2.4.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.5.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=1:2  ip=2.5.1.1/1

# ECQ-2020
CreatePrivacyPolicy - shall be able to create VM appinst with icmp/tcp/udp
   [Documentation]
   ...  send VM CreateAppInst with PrivacyPolicy with multiple icmp/tcp/udp rules
   ...  verify policy is created

   Create Flavor  region=${region}  disk=80

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

   Create App  region=${region}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016,tcp:8085  #default_flavor_name=${cluster_flavor_name}
   ${app}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator}  autocluster_ip_access=IpAccessDedicated  privacy_policy=${policy_return['data']['key']['name']}

   #${cloudname}=  Convert To Lowercase  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
   #${operator}=   Convert To Lowercase  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}
   #${openstack_group_name}=  Catenate  SEPARATOR=.  ${app['data']['key']['cluster_inst_key']['cluster_key']['name']}  ${cloudname}  ${operator}  mobiledgex.net-sg
   ${crmserver_name}=  Catenate  SEPARATOR=.  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  ${app['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  pf
   @{uri_split}=  Split String  ${app['data']['uri']}  .
   ${openstack_group_name}=  Catenate  SEPARATOR=-  ${uri_split[0]}  sg

   @{serverlist}=  Get Server List  ${crmserver_name}
   @{crm_ip}=  Split String  ${serverlist[0]['Networks']}  separator==

   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Contain   ${openstacksecgroup['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/1'

   # get rules
   @{openstackrules}=  Get Security Group Rules  group_id=${openstacksecgroup['id']}
   ${num_rules}=  Get Length  ${openstackrules}

   Should Be Equal As Numbers  ${num_rules}  16

   #Rules Should Exist  ${rules}  ${openstackrules}

   # get normal 443 rule
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=8085:8085  ip=0.0.0.0/0
   #Rule Should Exist  ${openstackrules}  proto=tcp  port=443:443  ip=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=2015:2015  ip=0.0.0.0/0
   Rule Should Exist  ${openstackrules}  proto=tcp  port=2016:2016  ip=0.0.0.0/0

   # get normal 22 rule
   #@{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=${crm_ip[1]}/32
   #Rule Should Exist  ${openstackrules}  proto=tcp  port=22:22  ip=${crm_ip[1]}/32

   # get ICMP rules
   @{openstackrules}=  Get Security Group Rules  protocol=icmp  group_id=${openstacksecgroup['id']}
   Rule Should Exist  ${openstackrules}  proto=icmp  port=${EMPTY}  ip=1.1.1.1/1

   # get UDP rules
   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.1.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=1001:2001  ip=3.1.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.2.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=1:2  ip=3.2.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.3.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=3:4  ip=3.3.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.4.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=5:5  ip=3.4.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=udp  group_id=${openstacksecgroup['id']}  ip_range=3.5.1.1/1
   Rule Should Exist  ${openstackrules}  proto=udp  port=7:9  ip=3.5.1.1/1

   # get TCP rules
   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.1.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=100:200  ip=2.1.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.2.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=101:102  ip=2.2.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.3.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=500:700  ip=2.3.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.4.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=1000:2000  ip=2.4.1.1/1

   @{openstackrules}=  Get Security Group Rules  protocol=tcp  group_id=${openstacksecgroup['id']}  ip_range=2.5.1.1/1
   Rule Should Exist  ${openstackrules}  proto=tcp  port=1:2  ip=2.5.1.1/1

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Privacy Policy Name
   ${developer_name}=  Get Default Developer Name
   ${app_name}=  Get Default App Name
   ${cluster_name}=  Set Variable  autocluster${app_name}
   
   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${cluster_name}

Rule Should Exist
   [Arguments]  ${rulelist}  ${proto}  ${port}  ${ip} 

   ${found}=  Set Variable  ${False}

   FOR  ${r}  IN  @{rulelist}
      ${found}=  Run Keyword If  '${ip}' == '${r['IP Range']}' and '${proto}' == '${r['IP Protocol']}' and '${port}' == '${r['Port Range']}'  Set Variable  ${True}
      ...  ELSE  Set Variable  ${found}
   END

   Should Be Equal  ${found}  ${True} 
