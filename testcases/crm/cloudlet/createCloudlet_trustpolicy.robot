*** Settings ***
Documentation  CreateCloudlet with trust policy on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack  environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV} 
Library  MexApp
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${cloudlet_name_openstack_dedicated}=  automationSunnydaleCloudlet
${operator_name_openstack}=  GDDT

${operator_name_openstack_packet}  packet
${physical_name_openstack_packet}  packet

${region_update}=  EU
${cloudlet1}=  automationBuckhornCloudlet
${cloudlet2}=  automationFairviewCloudlet
${env_file1}=  openrc_${cloudlet1}.mex
${env_file2}=  openrc_${cloudlet2}.mex

${trust_policy_server}=  35.199.188.102

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3135
CreateCloudlet - shall be able to create/update cloudlet with icmp/tcp/udp trust policy
   [Documentation]
   ...  - send CreateCloudlet with trust policy with multiple icmp/tcp/udp rules
   ...  - verify rules are updated
   ...  - updated the trust policy rules
   ...  - verify security policy is updated on openstack

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
   &{rule12}=  Create Dictionary  protocol=tcp  port_range_minimum=2015  port_range_maximum=2015  remote_cidr=35.199.188.102/32  # where port server is running
   &{rule13}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # docker-qa for download of app

   #&{rule13}=  Create Dictionary  protocol=tcp  port_range_minimum=22  port_range_maximum=22  remote_cidr=80.187.140.28/32     # docker for download of envoy
   &{rule14}=  Create Dictionary  protocol=udp  port_range_minimum=53  port_range_maximum=53  remote_cidr=0.0.0.0/0  # dns resolution for docker-qa
   #&{rule15}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # docker-qa for download of app
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}  ${rule7}  ${rule8}  ${rule9}  ${rule10}  ${rule11}  ${rule12}  ${rule13}  ${rule14}  #${rule15}

   &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   &{rule21}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   &{rule31}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=201  remote_cidr=2.1.1.1/1
   &{rule41}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=102  remote_cidr=2.2.1.2/1
   &{rule51}=  Create Dictionary  protocol=tcp  port_range_minimum=501  port_range_maximum=701  remote_cidr=2.3.1.2/1
   &{rule71}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=21  remote_cidr=2.5.1.1/1
   &{rule81}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=2  remote_cidr=3.2.1.2/1
   &{rule91}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=4  remote_cidr=3.3.1.1/1
   &{rule101}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=5  remote_cidr=3.4.1.1/1
   &{rule121}=  Create Dictionary  protocol=tcp  port_range_minimum=2016  port_range_maximum=2016  remote_cidr=35.199.188.102/32  # where port server is running
   &{rule131}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # chef.mobiledgex.net
   #&{rule131}=  Create Dictionary  protocol=tcp  port_range_minimum=22  port_range_maximum=22  remote_cidr=80.187.140.28/32     # docker for download of envoy
   &{rule141}=  Create Dictionary  protocol=udp  port_range_minimum=53  port_range_maximum=53  remote_cidr=0.0.0.0/0  # dns resolution for docker-qa
   #&{rule151}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # chef.mobiledgex.net
   @{rulelist1}=  Create List  ${rule11}  ${rule21}  ${rule31}  ${rule41}  ${rule51}  ${rule71}  ${rule81}  ${rule91}  ${rule101}  ${rule121}  ${rule131}  ${rule141}  #${rule151}

   # create truste policy
   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_openstack_packet}  token=${tokenop}

   # create cloudlet with trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  trust_policy=${policy_return['data']['key']['name']}  token=${tokenop}  use_thread=${True}
   ${cloudlet2}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}2  operator_org_name=${operator_name_openstack_packet}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  trust_policy=${policy_return['data']['key']['name']}  token=${tokenop}  use_thread=${True}

   Wait For Replies  ${cloudlet}  ${cloudlet2}

   # create app/appinst for testing the policy
   &{apprule1}=  Create Dictionary  protocol=udp  port=1001  remote_ip=3.9.5.10
   @{app_rulelist}=  Create List  ${apprule1}
   ${app}=  Create App  region=${region}  developer_org_name=${org_name_dev}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image_porttest}  access_ports=tcp:3015  trusted=${True}  required_outbound_connections_list=${app_rulelist}  token=${tokendev}
   Create App Instance  region=${region}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}   operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app['data']['key']['name']}  token=${tokendev}
   ${fqdn}=  Set Variable  autocluster${app['data']['key']['name']}.${cloudlet_name}.${operator_name_openstack_packet}.mobiledgex.net

   # openstack security group show cloudlet1609891618-9118872.packet.mobiledgex.net-sg
   ${cloudname}=  Convert To Lowercase  ${cloudlet_name}
   ${operator}=   Convert To Lowercase  ${operator_name_openstack_packet}
   ${openstack_group_name}=  Catenate  SEPARATOR=-  ${cloudname}  ${operator}  cloudlet-sg
   
   # verify cloudlet has trust policy rules
   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   #Should Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress'.+remote_ip_prefix='0\.0\.0\.0\/32'
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/1' 
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2\.3\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2\.4\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3\.5\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2015', port_range_min='2015', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
   Should Not Contain       ${openstacksecgroup['rules']}  remote_ip_prefix='0.0.0.0/32
   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'

   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016

   # udpdate policy with new policy and verify rules are updated
   Update Trust Policy  region=${region}  rule_list=${rulelist1}  operator_org_name=${operator_name_openstack_packet}  token=${tokenop}
   ${openstacksecgroup_update}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup_update['name']}   ${openstack_group_name}
   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2.2.1.1/1'
   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2.3.1.1/1'
   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2.4.1.1/1'
   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2.5.1.1/1'
   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3.2.1.1/1'
   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3.5.1.1/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='201', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.2\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='701', port_range_min='501', protocol='tcp', remote_ip_prefix='2\.3\.1\.2\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='21', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.2\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='2016', port_range_min='2016', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
   Should Not Contain   ${openstacksecgroup_update['rules']}  .port_range_max='2015', port_range_min='2015'
   Should Not Contain       ${openstacksecgroup_update['rules']}  remote_ip_prefix='0.0.0.0/32
   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'
#   Should Not Match Regexp  ${openstacksecgroup_update['rules']}  .+direction='egress'.+remote_ip_prefix='0\.0\.0\.0\/0'

   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015

   # update with same rules and veriy they are not changed
   Update Trust Policy  region=${region}  rule_list=${rulelist1}  operator_org_name=${operator_name_openstack_packet}  token=${tokenop}
   ${openstacksecgroup_update1}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup_update1['name']}   ${openstack_group_name}
   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2.2.1.1/1'
   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2.3.1.1/1'
   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2.4.1.1/1'
   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2.5.1.1/1'
   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3.2.1.1/1'
   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3.5.1.1/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='201', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.2\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='701', port_range_min='501', protocol='tcp', remote_ip_prefix='2\.3\.1\.2\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='21', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.2\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='2016', port_range_min='2016', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
   Should Not Contain       ${openstacksecgroup_update1['rules']}  remote_ip_prefix='0.0.0.0/32
   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'
#   Should Not Match Regexp  ${openstacksecgroup_update1['rules']}  .+direction='egress'.+remote_ip_prefix='0\.0\.0\.0\/0'

   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015

   # remove required connections from app so we can remove all rules from policy
   Update App  region=${region}  token=${token}  app_name=${app_name}  app_version=1.0  developer_org_name=${org_name_dev}  required_outbound_connections_list=empty  use_defaults=${False}  token=${tokendev}

   # update policy with empty rules and verify all rules are deleted
   @{rulelistempty}=  Create List  empty
   Update Trust Policy  region=${region}  rule_list=${rulelistempty}  operator_org_name=${operator_name_openstack_packet}  token=${tokenop}
   ${openstacksecgroup_update2}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup_update2['name']}   ${openstack_group_name}
   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3.1.1.1/1'
   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='201', port_range_min='101', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
   Should Not Contain   ${openstacksecgroup_update2['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/1'
   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2.2.1.2/1'
   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='701', port_range_min='501', protocol='tcp', remote_ip_prefix='2.3.1.2/1'
   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='21', port_range_min='1', protocol='tcp', remote_ip_prefix='2.5.1.1/1'
   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3.2.1.2/1'
   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3.3.1.1/1'
   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3.4.1.1/1'
   Should Match Regexp  ${openstacksecgroup_update2['rules']}  .+direction='egress'.+remote_ip_prefix='0.0.0.0/32     # blocks all egress traffic

   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015

   # remove policy from cloudlet
   ${cloudlet_update}=  Update Cloudlet  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  trust_policy=${Empty}  use_defaults=${False}  token=${tokenop}
   ${openstacksecgroup_update3}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup_update3['name']}   ${openstack_group_name}
   Should Match Regexp  ${openstacksecgroup_update3['rules']}  .+direction='egress'.+remote_ip_prefix='0.0.0.0/0'     # all traffic open again

   Egress port should be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
   Egress port should be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015

   # add original policy back to cloudlet
   Update Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_openstack_packet}  token=${tokenop}
   ${cloudlet}=  Update Cloudlet  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  trust_policy=${policy_return['data']['key']['name']}  use_defaults=${False}  token=${tokenop}
   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2\.3\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2\.4\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3\.5\.1\.1\/1'
   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2015', port_range_min='2015', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
   Should Not Contain       ${openstacksecgroup['rules']}  remote_ip_prefix='0.0.0.0/32
   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'
#   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress'.+remote_ip_prefix='0\.0\.0\.0\/0'

   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Trust Policy Name
   ${developer_name}=  Get Default Developer Name
   ${app_name}=  Get Default App Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${org_name}=  Get Default Organization Name
   ${org_name_dev}=  Set Variable  ${org_name}_dev
 
   Create Flavor  region=${region}

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com
   ${usernamedev_epoch}=  Catenate  SEPARATOR=  ${username}  dev  ${epoch}
   ${emaildev}=  Catenate  SEPARATOR=  ${username}  dev  +  ${epoch}  @gmail.com

   Create Org  orgname=${org_name_dev}  orgtype=developer

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Skip Verify Email
   Create User  username=${usernamedev_epoch}  password=${password}  email_address=${emaildev}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack_packet}  role=OperatorManager  
   Adduser Role  username=${usernamedev_epoch}  orgname=${org_name_dev}  role=DeveloperContributor

   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}
   ${tokendev}=  Login  username=${usernamedev_epoch}  password=${password}

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${app_name}
   Set Suite Variable  ${cloudlet_name}

   Set Suite Variable  ${tokenop}
   Set Suite Variable  ${tokendev}

   Set Suite Variable  ${org_name_dev}

