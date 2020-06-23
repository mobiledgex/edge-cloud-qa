*** Settings ***
Documentation  Privacy Policy

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  auto_login=${False}
#Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexApp
Library  String

Suite Setup      Setup

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack}  automationMunichCloudlet
${operator_name_openstack}  TDG
${mobiledgex_domain}  mobiledgex.net
${region}  EU

${test_timeout_crm}  32 min

*** Test Cases ***
User shall be able to privacy policy on docker dedicated 
   [Documentation]
   ...  do RunCommand on k8s shared app 
   ...  verify RunCommand works 
   [Tags]  docker  dedicated  privacypolicy 

#   &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=2015  port_range_maximum=2015  remote_cidr=35.199.188.102/32  # where port server is running
#   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=34.94.223.108/32     # docker-qa for download of app
##   &{rule3}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=35.247.68.151/32     # docker for download of envoy
#   &{rule4}=  Create Dictionary  protocol=udp  port_range_minimum=53  port_range_maximum=53  remote_cidr=0.0.0.0/0  # dns resolution for docker-qa 
#   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=443  port_range_maximum=443  remote_cidr=0.0.0.0/0     # docker-qa for download of app
#
#   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule4}  #${rule4}
#
#   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}
#
#   Log To Console  \nCreate cluster instance for docker dedicated with privacy policy
#   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_dockerdedicated_privacypolicy}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor_name_small}  privacy_policy=${policy_return['data']['key']['name']}
#   Log To Console  \nCreate cluster instance done
#
#   Log To Console  \nCreate app instance for docker dedicated
#   Create App Instance  region=${region}  app_name=${app_name_dockerdedicated_privacypolicy}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockerdedicated_privacypolicy}
#   Log To Console  \nCreate app instance done

   Register Client  app_name=${app_name_dockerdedicated_privacypolicy}
   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

   Egress port should be accessible      vm=${fqdn_0}  host=${privacy_policy_server}  protocol=tcp  port=2015
   Egress port should not be accessible  vm=${fqdn_0}  host=${privacy_policy_server}  protocol=tcp  port=2016


*** Keywords ***
Setup
   Login  username=${username}  password=${password}

   Create App  region=${region}  app_name=${app_name_dockerdedicated_privacypolicy}  deployment=docker   image_path=${docker_image_privacypolicy}       access_ports=tcp:3015   default_flavor_name=${flavor_name_small}
