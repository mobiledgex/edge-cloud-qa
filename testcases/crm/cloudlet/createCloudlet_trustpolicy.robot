*** Settings ***
Documentation  CreateCloudlet with trust policy on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexOpenstack  environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV} 
Library  MexApp
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${cloudlet_name_openstack_dedicated}=  automationMunichCloudlet
${operator_name_openstack}=  TDG

${operator_name_openstack_packet}  packet
${physical_name_openstack_packet}  packet
${physical_name_crm}  bonn

${region_update}=  EU
${cloudlet1}=  automationBonnCloudlet
${cloudlet2}=  automationFrankfurtCloudlet
${env_file1}=  openrc_${cloudlet1}.mex
${env_file2}=  openrc_${cloudlet2}.mex

${trust_policy_server}=  35.199.188.102

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3135
#CreateCloudlet - shall be able to create/update cloudlet with icmp/tcp/udp trust policy
#   [Documentation]
#   ...  - send 2 trusted CreateCloudlets with trust policy with multiple icmp/tcp/udp rules and opening a single port to an external test server
#   ...  - verify rules are updated
#   ...  - send trusted CreateApp and CreateAppInst on one of the cloudlets
#   ...  - verify external access to the open port is accessible via the app and the other ports are closed
#   ...  - send UpdateTrustPolicy to close the open port and open a different port
#   ...  - verify external access to the new open port is accessible via the app and the previously open  port is closed
#   ...  - send UpdateTrustPolicy with the same rules and verify nothing changed
#   ...  - send UpdateTrustPolicy with an empty list to close all ports
#   ...  - verify external access to both previously open ports are closed
#   ...  - send UpdateCloudlet to remove the trust policy
#   ...  - verify external access to both previously closed ports are now open
#   ...  - send UpdateTrustPolicy with the original rules
#   ...  - send UpdateCloudlet to add the original policy back to the cloudlet
#   ...  - verify external access to the open port is accessible via the app and the other ports are closed as first tested
#   ...  - verify security policy is updated on openstack in all cases above
#
#   [Tags]  trustpolicy
#
#   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
#   &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
#   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=100  port_range_maximum=200  remote_cidr=2.1.1.1/1
#   &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=102  remote_cidr=2.2.1.1/1
#   &{rule5}=  Create Dictionary  protocol=tcp  port_range_minimum=500  port_range_maximum=700  remote_cidr=2.3.1.1/1
#   &{rule6}=  Create Dictionary  protocol=tcp  port_range_minimum=1000  port_range_maximum=2000  remote_cidr=2.4.1.1/1
#   &{rule7}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=2.5.1.1/1
#   &{rule8}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=2  remote_cidr=3.2.1.1/1
#   &{rule9}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=4  remote_cidr=3.3.1.1/1
#   &{rule10}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=5  remote_cidr=3.4.1.1/1
#   &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=7  port_range_maximum=9  remote_cidr=3.5.1.1/1
#   &{rule12}=  Create Dictionary  protocol=tcp  port_range_minimum=2015  port_range_maximum=2015  remote_cidr=35.199.188.102/32  # where port server is running
#   &{rule13}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # docker-qa for download of app
#
#   #&{rule13}=  Create Dictionary  protocol=tcp  port_range_minimum=22  port_range_maximum=22  remote_cidr=80.187.140.28/32     # docker for download of envoy
#   &{rule14}=  Create Dictionary  protocol=udp  port_range_minimum=53  port_range_maximum=53  remote_cidr=0.0.0.0/0  # dns resolution for docker-qa
#   #&{rule15}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # docker-qa for download of app
#   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}  ${rule7}  ${rule8}  ${rule9}  ${rule10}  ${rule11}  ${rule12}  ${rule13}  ${rule14}  #${rule15}
#
#   &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
#   &{rule21}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
#   &{rule31}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=201  remote_cidr=2.1.1.1/1
#   &{rule41}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=102  remote_cidr=2.2.1.2/1
#   &{rule51}=  Create Dictionary  protocol=tcp  port_range_minimum=501  port_range_maximum=701  remote_cidr=2.3.1.2/1
#   &{rule71}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=21  remote_cidr=2.5.1.1/1
#   &{rule81}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=2  remote_cidr=3.2.1.2/1
#   &{rule91}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=4  remote_cidr=3.3.1.1/1
#   &{rule101}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=5  remote_cidr=3.4.1.1/1
#   &{rule121}=  Create Dictionary  protocol=tcp  port_range_minimum=2016  port_range_maximum=2016  remote_cidr=35.199.188.102/32  # where port server is running
#   &{rule131}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # chef.mobiledgex.net
#   #&{rule131}=  Create Dictionary  protocol=tcp  port_range_minimum=22  port_range_maximum=22  remote_cidr=80.187.140.28/32     # docker for download of envoy
#   &{rule141}=  Create Dictionary  protocol=udp  port_range_minimum=53  port_range_maximum=53  remote_cidr=0.0.0.0/0  # dns resolution for docker-qa
#   #&{rule151}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # chef.mobiledgex.net
#   @{rulelist1}=  Create List  ${rule11}  ${rule21}  ${rule31}  ${rule41}  ${rule51}  ${rule71}  ${rule81}  ${rule91}  ${rule101}  ${rule121}  ${rule131}  ${rule141}  #${rule151}
#
#   # create truste policy
#   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_crm}  token=${tokenop}
#
#   # create cloudlet with trust policy
#   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_crm}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_crm}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  trust_policy=${policy_return['data']['key']['name']}  env_vars=${env_vars}  token=${tokenop}  use_thread=${True} 
#   ${cloudlet2}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}2  operator_org_name=${operator_name_crm}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_crm}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  trust_policy=${policy_return['data']['key']['name']}  env_vars=${env_vars}  token=${tokenop}  use_thread=${True}
#
#   Wait For Replies  ${cloudlet}  ${cloudlet2}
#
#   # create app/appinst for testing the policy
#   &{apprule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=1001  remote_cidr=3.1.1.1/1  #remote_ip=3.9.5.10
#   @{app_rulelist}=  Create List  ${apprule1}
#   ${app}=  Create App  region=${region}  developer_org_name=${org_name_dev}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image_porttest}  access_ports=tcp:3015  trusted=${True}  required_outbound_connections_list=${app_rulelist}  token=${tokendev}
#   ${appInst}=  Create App Instance  region=${region}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}   operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app['data']['key']['name']}  token=${tokendev}
#   #${real_cluster_name}=  Set Variable  ${appInst['data']['real_cluster_name']}  
#   #${fqdn}=  Set Variable  ${real_cluster_name}.${cloudlet_name}.${operator_name_crm}.mobiledgex.net
#   ${fqdn}=  Set Variable  ${appInst['data']['uri']}
#
#   # openstack security group show cloudlet1609891618-9118872.packet.mobiledgex.net-sg
#   #${cloudname}=  Convert To Lowercase  ${cloudlet_name}
#   #${operator}=   Convert To Lowercase  ${operator_name_crm}
#   #${openstack_group_name}=  Catenate  SEPARATOR=-  ${cloudname}  ${operator}  cloudlet-sg
#   ${openstack_group_name}=  Catenate  SEPARATOR=-  ${cloudlet_name}  ${operator_name_crm}  cloudlet-sg
# 
#   # verify cloudlet has trust policy rules
#   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
#   #Should Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress'.+remote_ip_prefix='0\.0\.0\.0\/32'
#   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/1' 
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2\.3\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2\.4\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3\.5\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2015', port_range_min='2015', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
#   Should Not Contain       ${openstacksecgroup['rules']}  remote_ip_prefix='0.0.0.0/32
#   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'
#
#   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
#   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
#
#   # udpdate policy with new policy and verify rules are updated
#   Update Trust Policy  region=${region}  rule_list=${rulelist1}  operator_org_name=${operator_name_crm}  token=${tokenop}
#   ${openstacksecgroup_update}=  Get Security Groups  name=${openstack_group_name}
#   Should Be Equal  ${openstacksecgroup_update['name']}   ${openstack_group_name}
#   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2.2.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2.3.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2.4.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2.5.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3.2.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update['rules']}  port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3.5.1.1/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='201', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.2\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='701', port_range_min='501', protocol='tcp', remote_ip_prefix='2\.3\.1\.2\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='21', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.2\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update['rules']}  .+direction='egress'.+port_range_max='2016', port_range_min='2016', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
#   Should Not Contain   ${openstacksecgroup_update['rules']}  .port_range_max='2015', port_range_min='2015'
#   Should Not Contain       ${openstacksecgroup_update['rules']}  remote_ip_prefix='0.0.0.0/32
#   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'
##   Should Not Match Regexp  ${openstacksecgroup_update['rules']}  .+direction='egress'.+remote_ip_prefix='0\.0\.0\.0\/0'
#
#   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
#   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
#
#   # update with same rules and veriy they are not changed
#   Update Trust Policy  region=${region}  rule_list=${rulelist1}  operator_org_name=${operator_name_crm}  token=${tokenop}
#   ${openstacksecgroup_update1}=  Get Security Groups  name=${openstack_group_name}
#   Should Be Equal  ${openstacksecgroup_update1['name']}   ${openstack_group_name}
#   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2.2.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2.3.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2.4.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2.5.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3.2.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update1['rules']}  port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3.5.1.1/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='201', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.2\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='701', port_range_min='501', protocol='tcp', remote_ip_prefix='2\.3\.1\.2\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='21', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.2\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup_update1['rules']}  .+direction='egress'.+port_range_max='2016', port_range_min='2016', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
#   Should Not Contain       ${openstacksecgroup_update1['rules']}  remote_ip_prefix='0.0.0.0/32
#   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'
##   Should Not Match Regexp  ${openstacksecgroup_update1['rules']}  .+direction='egress'.+remote_ip_prefix='0\.0\.0\.0\/0'
#
#   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
#   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
#
#   # remove required connections from app so we can remove all rules from policy
#   Update App  region=${region}  token=${token}  app_name=${app_name}  app_version=1.0  developer_org_name=${org_name_dev}  required_outbound_connections_list=empty  use_defaults=${False}  token=${tokendev}
#
#   # update policy with empty rules and verify all rules are deleted
#   @{rulelistempty}=  Create List  empty
#   Update Trust Policy  region=${region}  rule_list=${rulelistempty}  operator_org_name=${operator_name_crm}  token=${tokenop}
#   ${openstacksecgroup_update2}=  Get Security Groups  name=${openstack_group_name}
#   Should Be Equal  ${openstacksecgroup_update2['name']}   ${openstack_group_name}
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3.1.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='201', port_range_min='101', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  protocol='icmp', remote_ip_prefix='1.1.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2.2.1.2/1'
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='701', port_range_min='501', protocol='tcp', remote_ip_prefix='2.3.1.2/1'
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='21', port_range_min='1', protocol='tcp', remote_ip_prefix='2.5.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3.2.1.2/1'
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3.3.1.1/1'
#   Should Not Contain   ${openstacksecgroup_update2['rules']}  port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3.4.1.1/1'
#   Should Match Regexp  ${openstacksecgroup_update2['rules']}  .+direction='egress'.+remote_ip_prefix='0.0.0.0/32     # blocks all egress traffic
#
#   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
#   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
#
#   # remove policy from cloudlet
#   ${cloudlet_update}=  Update Cloudlet  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_crm}  trust_policy=${Empty}  use_defaults=${False}  token=${tokenop}
#   ${openstacksecgroup_update3}=  Get Security Groups  name=${openstack_group_name}
#   Should Be Equal  ${openstacksecgroup_update3['name']}   ${openstack_group_name}
#   Should Match Regexp  ${openstacksecgroup_update3['rules']}  .+direction='egress'.+remote_ip_prefix='0.0.0.0/0'     # all traffic open again
#
#   Egress port should be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
#   Egress port should be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
#
#   # add original policy back to cloudlet
#   Update Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_crm}  token=${tokenop}
#   ${cloudlet}=  Update Cloudlet  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_crm}  trust_policy=${policy_return['data']['key']['name']}  use_defaults=${False}  token=${tokenop}
#   ${openstacksecgroup}=  Get Security Groups  name=${openstack_group_name}
#   Should Be Equal  ${openstacksecgroup['name']}   ${openstack_group_name}
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2\.3\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2\.4\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3\.5\.1\.1\/1'
#   Should Match Regexp   ${openstacksecgroup['rules']}  .+direction='egress'.+port_range_max='2015', port_range_min='2015', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
#   Should Not Contain       ${openstacksecgroup['rules']}  remote_ip_prefix='0.0.0.0/32
#   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'
##   Should Not Match Regexp  ${openstacksecgroup['rules']}  .+direction='egress'.+remote_ip_prefix='0\.0\.0\.0\/0'
#
#   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
#   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016

CreateCloudlet - shall be able to create/update cloudlet with icmp/tcp/udp trust policy
   [Documentation]
   ...  - create trusted CreateCloudlet with trust policy with multiple icmp/tcp/udp rules and opening a single port to an external test server
   ...  - verify rules are updated
   ...  - send trusted CreateApp and CreateAppInst on one of the cloudlets
   ...  - verify external access to the open port is accessible via the app and the other ports are closed
   ...  - send UpdateTrustPolicy to close the open port and open a different port
   ...  - verify external access to the new open port is accessible via the app and the previously open  port is closed
   ...  - send UpdateTrustPolicy with the same rules and verify nothing changed
   ...  - send UpdateTrustPolicy with an empty list to close all ports
   ...  - verify external access to both previously open ports are closed
   ...  - send UpdateCloudlet to remove the trust policy
   ...  - verify external access to both previously closed ports are now open
   ...  - send UpdateTrustPolicy with the original rules
   ...  - send UpdateCloudlet to add the original policy back to the cloudlet
   ...  - verify external access to the open port is accessible via the app and the other ports are closed as first tested
   ...  - verify security policy is updated on openstack in all cases above

   [Tags]  trustpolicy

   ${rulelist1}  ${rulelist2}=  Build Trust Policy Rule Dict
   ${num_rules1}=  Get Length  ${rulelist1}
   ${num_rules2}=  Get Length  ${rulelist2}

   Run Keyword and Ignore Error  Adduser Role  orgname=${operator_name_crm}  username=${op_manager_user_automation}   role=OperatorManager  token=${supertoken}

   # create truste policy
   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist1}  operator_org_name=${operator_name_crm}  token=${tokenop}

   # create cloudlet with trust policy
   IF  '${platform_type_crm}' == 'Vcd'
       ${env_vars}=  Set Variable  MEX_CATALOG=qa2-cat,MEX_ENABLE_VCD_DISK_RESIZE=false,MEX_EXT_NETWORK=external-network-qa2,MEX_IMAGE_DISK_FORMAT=vmdk,MEX_VM_APP_IMAGE_CLEANUP_ON_DELETE=yes,VCD_NSX_TYPE=NSX-V,VCD_TEMPLATE_ARTIFACTORY_IMPORT_ENABLED=true,VCD_OVERRIDE_VCPU_SPEED=1000,MEX_SHARED_ROOTLB_RAM=3072,MEX_SHARED_ROOTLB_VCPUS=2,MEX_SHARED_ROOTLB_DISK=20   #,MEX_OS_IMAGE=mobiledgex-v4.8.1
       ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_crm}  platform_type=${platform_type_crm}  physical_name=${physical_name_crm}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  trust_policy=${policy_return['data']['key']['name']}  env_vars=${env_vars}  token=${tokenop}  timeout=900  #override_policy_container_version=${True} 
       ${access_cloudlet_cmd}=  Set Variable  sudo iptables -S | grep "label trust-policy"
       ${num_rules1}=  Evaluate  ${num_rules1} * 2  # times 2 for FORWARD and OUTPUT rules
       ${num_rules2}=  Evaluate  ${num_rules2} * 2  # times 2 for FORWARD and OUTPUT rules
   ELSE IF  '${platform_type_crm}' == 'Openstack'
       ${env_vars}=  Set Variable  FLAVOR_MATCH_PATTERN=m4,MEX_EXT_NETWORK=external-network-02   #,MEX_OS_IMAGE=mobiledgex-v4.8.1
       ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_crm}  platform_type=${platform_type_crm}  physical_name=${physical_name_crm}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  trust_policy=${policy_return['data']['key']['name']}  env_vars=${env_vars}  token=${tokenop}  timeout=900  #override_policy_container_version=${True}
       #${cloudlet_name}=  Set Variable  cloudlet1646266123-812292
       ${access_cloudlet_cmd}=  Set Variable  openstack security group show ${cloudlet_name}-${operator_name_crm}-cloudlet-sg
       ${num_rules1}=  Evaluate  ${num_rules1} + 2  # 2 extra egress rules are added
       ${num_rules2}=  Evaluate  ${num_rules2} + 2  # 2 extra egress rules are added
   ELSE
       Fail  unknown platform_type_crm ${platform_type_crm}
   END
  
   # create app/appinst for testing the policy
   &{apprule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=1001  remote_cidr=3.1.1.1/32  #remote_ip=3.9.5.10
   @{app_rulelist}=  Create List  ${apprule1}
   ${app}=  Create App  region=${region}  developer_org_name=${org_name_dev}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image_porttest}  access_ports=tcp:3015  trusted=${True}  required_outbound_connections_list=${app_rulelist}  token=${tokendev}
   ${appInst}=  Create App Instance  region=${region}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}   operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app['data']['key']['name']}  token=${tokendev}
   ${fqdn}=  Set Variable  ${appInst['data']['uri']}
#    ${fqdn}=  Set Variable  reservable0-mobiledgex.cloudlet1646230507-642154-packet.us.mobiledgex.net
 
   Verify Original Trust Policy Rules  command=${access_cloudlet_cmd}  num_rules=${num_rules1}

   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016

   # udpdate policy with new policy and verify rules are updated
   #${policy_name}=  Set Variable  trustpolicy1646266123-812292
   Update Trust Policy  region=${region}  policy_name=${policy_name}  rule_list=${rulelist2}  operator_org_name=${operator_name_crm}  token=${tokenop}
   Verify Update Trust Policy Rules  command=${access_cloudlet_cmd}  num_rules=${num_rules2}

   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015

   # update with same rules and veriy they are not changed
   Update Trust Policy  region=${region}  policy_name=${policy_name}  rule_list=${rulelist2}  operator_org_name=${operator_name_crm}  token=${tokenop}
   Verify Update Trust Policy Rules  command=${access_cloudlet_cmd}  num_rules=${num_rules2}

   Egress port should be accessible      vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015

   # remove required connections from app so we can remove all rules from policy
   #${app_name}=  Set Variable  app1646230507-642154
   Update App  region=${region}  token=${token}  app_name=${app_name}  app_version=1.0  developer_org_name=${org_name_dev}  required_outbound_connections_list=empty  use_defaults=${False}  token=${tokendev}

   # update policy with empty rules and verify all rules are deleted
   @{rulelistempty}=  Create List  empty
   Update Trust Policy  region=${region}  policy_name=${policy_name}  rule_list=${rulelistempty}  operator_org_name=${operator_name_crm}  token=${tokenop}

   Verify Empty Trust Policy Rules  command=${access_cloudlet_cmd}  num_rules=2

   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2016
   Egress port should not be accessible  vm=${fqdn}  host=${trust_policy_server}  protocol=tcp  port=2015

   # add original policy back to cloudlet
   Update Trust Policy  region=${region}  policy_name=${policy_name}  rule_list=${rulelist1}  operator_org_name=${operator_name_crm}  token=${tokenop}
   Verify Original Trust Policy Rules  command=${access_cloudlet_cmd}  num_rules=${num_rules1}

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
   #${org_name_dev}=  Set Variable  ${org_name}_dev
   ${org_name_dev}=  Set Variable  ${developer_org_name_automation}
   ${operator_name_crm_lc}=  Convert To Lowercase  ${operator_name_crm}

   Create Flavor  region=${region}

   IF  'Bonn' in '${cloudlet_name_crm}'
      ${env_vars}=  Set Variable  FLAVOR_MATCH_PATTERN=m4,MEX_EXT_NETWORK=external-network-02
   ELSE
      ${env_vars}=  Set Variable  ${None}
   END

   Run Keyword and Ignore Error  Adduser Role   orgname=${operator_name_crm}   username=${op_manager_user_automation}   role=OperatorManager
   ${tokenop}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
   ${tokendev}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}
   ${supertoken}=  Get Super Token
  
   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${app_name}
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${operator_name_crm_lc}

   Set Suite Variable  ${tokenop}
   Set Suite Variable  ${tokendev}
   Set Suite Variable  ${supertoken}

   Set Suite Variable  ${org_name_dev}
   Set Suite Variable  ${env_vars}

Build Trust Policy Rule Dict
    &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/32
    &{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/32
    &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=100  port_range_maximum=200  remote_cidr=2.1.1.1/1
    &{rule4}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=102  remote_cidr=2.2.1.1/32
    &{rule5}=  Create Dictionary  protocol=tcp  port_range_minimum=500  port_range_maximum=700  remote_cidr=2.3.1.1/32
    &{rule6}=  Create Dictionary  protocol=tcp  port_range_minimum=1000  port_range_maximum=2000  remote_cidr=2.4.1.1/32
    &{rule7}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=2.5.1.1/32
    &{rule8}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=2  remote_cidr=3.2.1.1/32
    &{rule9}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=4  remote_cidr=3.3.1.1/32
    &{rule10}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=5  remote_cidr=3.4.1.1/32
    &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=7  port_range_maximum=9  remote_cidr=3.5.1.1/32
    &{rule12}=  Create Dictionary  protocol=tcp  port_range_minimum=2015  port_range_maximum=2015  remote_cidr=35.199.188.102/32  # where port server is running
    &{rule13}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # docker-qa for download of app
 
    #&{rule13}=  Create Dictionary  protocol=tcp  port_range_minimum=22  port_range_maximum=22  remote_cidr=80.187.140.28/32     # docker for download of envoy
    &{rule14}=  Create Dictionary  protocol=udp  port_range_minimum=53  port_range_maximum=53  remote_cidr=0.0.0.0/0  # dns resolution for docker-qa
    #&{rule15}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # docker-qa for download of app
    @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}  ${rule4}  ${rule5}  ${rule6}  ${rule7}  ${rule8}  ${rule9}  ${rule10}  ${rule11}  ${rule12}  ${rule13}  ${rule14}  #${rule15}
 
    &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/32
    &{rule21}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/32
    &{rule31}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=201  remote_cidr=2.1.1.1/32
    &{rule41}=  Create Dictionary  protocol=tcp  port_range_minimum=101  port_range_maximum=102  remote_cidr=2.2.1.2/1
    &{rule51}=  Create Dictionary  protocol=tcp  port_range_minimum=501  port_range_maximum=701  remote_cidr=2.3.1.2/32
    &{rule71}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=21  remote_cidr=2.5.1.1/32
    &{rule81}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=2  remote_cidr=3.2.1.2/32
    &{rule91}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=4  remote_cidr=3.3.1.1/32
    &{rule101}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=5  remote_cidr=3.4.1.1/32
    &{rule121}=  Create Dictionary  protocol=tcp  port_range_minimum=2016  port_range_maximum=2016  remote_cidr=35.199.188.102/32  # where port server is running
    &{rule131}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # chef.mobiledgex.net
    #&{rule131}=  Create Dictionary  protocol=tcp  port_range_minimum=22  port_range_maximum=22  remote_cidr=80.187.140.28/32     # docker for download of envoy
    &{rule141}=  Create Dictionary  protocol=udp  port_range_minimum=53  port_range_maximum=53  remote_cidr=0.0.0.0/0  # dns resolution for docker-qa
    #&{rule151}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # chef.mobiledgex.net
    @{rulelist1}=  Create List  ${rule11}  ${rule21}  ${rule31}  ${rule41}  ${rule51}  ${rule71}  ${rule81}  ${rule91}  ${rule101}  ${rule121}  ${rule131}  ${rule141}  #${rule151}

    [Return]  ${rulelist}  ${rulelist1}

Verify Original Trust Policy Rules
    [Arguments]  ${command}  ${num_rules}

    #${cloudlet_name}=  Set Variable  cloudlet1646266123-812292

    IF  '${platform_type_crm}' == 'Vcd'
        ${output}=  Access Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_crm}  node_name=${cloudlet_name}.${operator_name_crm_lc}.mobiledgex.net  node_type=sharedrootlb  command=${command}  token=${super_token}

        @{actions}=  Create List  FORWARD  OUTPUT
        FOR  ${x}  IN  @{actions}
            Should Contain  ${output}  -A ${x} -d 3.1.1.1/32 -p udp -m udp --dport 1001:2001 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 1.1.1.1/32 -p icmp -m icmp --icmp-type any -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 0.0.0.0/1 -p tcp -m tcp --dport 100:200 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 2.2.1.1/32 -p tcp -m tcp --dport 101:102 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 2.3.1.1/32 -p tcp -m tcp --dport 500:700 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 2.4.1.1/32 -p tcp -m tcp --dport 1000:2000 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 2.5.1.1/32 -p tcp -m tcp --dport 1:2 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 3.2.1.1/32 -p udp -m udp --dport 1:2 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 3.3.1.1/32 -p udp -m udp --dport 3:4 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 3.4.1.1/32 -p udp -m udp --dport 5 -m comment --comment "label trust-policy" -j ACCEPT 
            Should Contain  ${output}  -A ${x} -d 3.5.1.1/32 -p udp -m udp --dport 7:9 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 35.199.188.102/32 -p tcp -m tcp --dport 2015 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -p tcp -m tcp --dport 443 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -p udp -m udp --dport 53 -m comment --comment "label trust-policy" -j ACCEPT
        END

        Should Not Contain  ${output}  --dport 2016
        #Should Not Contain  ${output}  -A OUTPUT -p tcp -m tcp --dport 1:65535  uncomment after bug fixed
        Should Not Contain  ${output}  0.0.0.0/32  #remote_ip_prefix='0.0.0.0/32
        Should Not Contain  ${output}  0.0.0.0/0  #.+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'

        ${lines}=  Split To Lines  ${output}
        Length Should Be  ${lines}  ${num_rules}
   ELSE IF  '${platform_type_crm}' == 'Openstack'
       ${output}=  Run Debug  cloudlet_name=${cloudlet_name}  node_type=crm  command=oscmd  timeout=90s  args=${command}  token=${super_token}
       ${openstacksecgroup}=  Get Lines Containing String  ${output[0]['data']['output']}  egress
        
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/1'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2\.3\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2\.4\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3\.5\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='2015', port_range_min='2015', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
       Should Not Contain       ${openstacksecgroup}  remote_ip_prefix='0.0.0.0/32
       Should Not Match Regexp  ${openstacksecgroup}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'

       ${lines}=  Split To Lines  ${openstacksecgroup}
       Length Should Be  ${lines}  ${num_rules}
   ELSE
       Fail  Unknown platform type ${platform_type_crm}
   END

Verify Update Trust Policy Rules
    [Arguments]  ${command}  ${num_rules}

    #${cloudlet_name}=  Set Variable  cloudlet1646266123-812292

    IF  '${platform_type_crm}' == 'Vcd'
        ${output}=  Access Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_crm}  node_name=${cloudlet_name}.${operator_name_crm_lc}.mobiledgex.net  node_type=sharedrootlb  command=${command}  token=${super_token}

        @{actions}=  Create List  FORWARD  OUTPUT
        FOR  ${x}  IN  @{actions} 
            Should Contain  ${output}  -A ${x} -d 3.1.1.1/32 -p udp -m udp --dport 1001:2001 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 1.1.1.1/32 -p icmp -m icmp --icmp-type any -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 2.1.1.1/32 -p tcp -m tcp --dport 101:201 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 0.0.0.0/1 -p tcp -m tcp --dport 101:102 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 2.3.1.2/32 -p tcp -m tcp --dport 501:701 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 2.5.1.1/32 -p tcp -m tcp --dport 1:21 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 3.2.1.2/32 -p udp -m udp --dport 1:2 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 3.3.1.1/32 -p udp -m udp --dport 3:4 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 3.4.1.1/32 -p udp -m udp --dport 5 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -d 35.199.188.102/32 -p tcp -m tcp --dport 2016 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -p tcp -m tcp --dport 443 -m comment --comment "label trust-policy" -j ACCEPT
            Should Contain  ${output}  -A ${x} -p udp -m udp --dport 53 -m comment --comment "label trust-policy" -j ACCEPT
        END
        Should Not Contain  ${output}  --dport 7:9
        Should Not Contain  ${output}  --dport 2015
        #Should Not Contain  ${output}  -A OUTPUT -p tcp -m tcp --dport 1:65535  uncomment after bug fixed
        Should Not Contain  ${output}  0.0.0.0/32  #remote_ip_prefix='0.0.0.0/32
        Should Not Contain  ${output}  0.0.0.0/0  #.+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'
   
        ${lines}=  Split To Lines  ${output} 
        Length Should Be  ${lines}  ${num_rules}
   ELSE IF  '${platform_type_crm}' == 'Openstack'
       ${output}=  Run Debug  cloudlet_name=${cloudlet_name}  node_type=crm  command=oscmd  timeout=90s  args=${command}  token=${super_token}
       ${openstacksecgroup}=  Get Lines Containing String  ${output[0]['data']['output']}  egress

       Should Not Contain   ${openstacksecgroup}  port_range_max='200', port_range_min='100', protocol='tcp', remote_ip_prefix='2.1.1.1/1'
       Should Not Contain   ${openstacksecgroup}  port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2.2.1.1/32'
       Should Not Contain   ${openstacksecgroup}  port_range_max='700', port_range_min='500', protocol='tcp', remote_ip_prefix='2.3.1.1/32'
       Should Not Contain   ${openstacksecgroup}  port_range_max='2000', port_range_min='1000', protocol='tcp', remote_ip_prefix='2.4.1.1/32'
       Should Not Contain   ${openstacksecgroup}  port_range_max='2', port_range_min='1', protocol='tcp', remote_ip_prefix='2.5.1.1/32'
       Should Not Contain   ${openstacksecgroup}  port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3.2.1.1/32'
       Should Not Contain   ${openstacksecgroup}  port_range_max='9', port_range_min='7', protocol='udp', remote_ip_prefix='3.5.1.1/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='2001', port_range_min='1001', protocol='udp', remote_ip_prefix='3\.1\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='201', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.1\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+protocol='icmp', remote_ip_prefix='1\.1\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='102', port_range_min='101', protocol='tcp', remote_ip_prefix='2\.2\.1\.2\/1'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='701', port_range_min='501', protocol='tcp', remote_ip_prefix='2\.3\.1\.2\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='21', port_range_min='1', protocol='tcp', remote_ip_prefix='2\.5\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='2', port_range_min='1', protocol='udp', remote_ip_prefix='3\.2\.1\.2\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='4', port_range_min='3', protocol='udp', remote_ip_prefix='3\.3\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='5', port_range_min='5', protocol='udp', remote_ip_prefix='3\.4\.1\.1\/32'
       Should Match Regexp   ${openstacksecgroup}  .+direction='egress'.+port_range_max='2016', port_range_min='2016', protocol='tcp', remote_ip_prefix='35.199.188.102/32'
       Should Not Contain       ${openstacksecgroup}  remote_ip_prefix='0.0.0.0/32
       Should Not Match Regexp  ${openstacksecgroup}  .+direction='egress', ethertype='IPv4', id='.{36}', remote_ip_prefix='0\.0\.0\.0\/0'

       ${lines}=  Split To Lines  ${openstacksecgroup}
       Length Should Be  ${lines}  ${num_rules}
   ELSE
       Fail  Unknown platform type ${platform_type_crm}
   END

Verify Empty Trust Policy Rules
    [Arguments]  ${command}  ${num_rules}

    #${cloudlet_name}=  Set Variable  cloudlet1646230507-642154

    IF  '${platform_type_crm}' == 'Vcd'
        ${output}=  Access Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_crm}  node_name=${cloudlet_name}.${operator_name_crm_lc}.mobiledgex.net  node_type=sharedrootlb  command=${command}  token=${super_token}

        Should Contain  ${output}  -A FORWARD -m comment --comment "label trust-policy" -j ACCEPT
        Should Contain  ${output}  -A OUTPUT -m comment --comment "label trust-policy" -j ACCEPT

        ${lines}=  Split To Lines  ${output}
        Length Should Be  ${lines}  ${num_rules}
   ELSE IF  '${platform_type_crm}' == 'Openstack'
       ${output}=  Run Debug  cloudlet_name=${cloudlet_name}  node_type=crm  command=oscmd  timeout=90s  args=${command}  token=${super_token}
       ${openstacksecgroup}=  Set Variable  ${output[0]['data']['output']}
   ELSE
       Fail  Unknown platform type ${platform_type_crm}
   END
