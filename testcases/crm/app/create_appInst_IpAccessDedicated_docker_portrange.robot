*** Settings ***
Documentation  docker and IpAccessDedicated with port range

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet
${operator_name_openstack}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${test_timeout_crm}  15 min

${region}=  EU

*** Test Cases ***
# ECQ-2169
User shall be able to create app with large port range on openstack with docker and access_type=loadbalancer
   [Documentation]
   ...  deploy app with large port range with docker
   ...  verify ports are added to security group

   ${cluster_name_default}=  Get Default Cluster Name
   ${app_name_default}=  Get Default App Name

   Log To Console  Creating App and App Instance
   Create App  region=${region}  image_path=${docker_image}  access_ports=udp:1-10000,tcp:2000-2999  skip_hc_ports=tcp:2000-2014,tcp:2017-2999  command=${docker_command}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=docker  #default_flavor_name=${cluster_flavor_name}
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

   ${server_info_crm}=      Get Server List  name=${cloudlet_name_openstack_dedicated}.${operator_name_openstack}.pf
   ${crm_networks}=  Split String  ${server_info_crm[0]['Networks']}  =
   ${crm_ip}=  Fetch From Left  ${crm_networks[1]}  "

   ${server_show}=  Get Server Show  name=${rootlb}
   Security Groups Should Contain  ${server_show['security_groups']}  ${rootlb}-sg
	
   ${openstacksecgroup}=  Get Security Groups  name=${rootlb}-sg
   Should Be Equal  ${openstacksecgroup['name']}   ${rootlb}-sg
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='egress', ethertype='IPv4', id='.*', updated_at
   #Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='443', port_range_min='443', protocol='tcp', remote_ip_prefix='0.0.0.0/0', updated_at
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='22', port_range_min='22', protocol='tcp', remote_ip_prefix='${crm_ip}/32', updated_at=
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='10000', port_range_min='1', protocol='udp', remote_ip_prefix='0.0.0.0/0', updated_at=
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='2999', port_range_min='2000', protocol='tcp', remote_ip_prefix='0.0.0.0/0', updated_at=

   @{sec_groups}=  Split To Lines  ${openstacksecgroup['rules']}
   Length Should Be  ${sec_groups}  4

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

   TCP Port Should Be Alive  ${fqdn_0}  2015
   TCP Port Should Be Alive  ${fqdn_0}  2016

   UDP Port Should Be Alive  ${fqdn_1}  2015
   UDP Port Should Be Alive  ${fqdn_1}  2016



*** Keywords ***
Setup
    Create Flavor  region=${region}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  number_masters=0  number_nodes=0  deployment=docker
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cluster_name}=  Get Default Cluster Name
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
    
    Set Suite Variable  ${rootlb}

Security Groups Should Contain
   [Arguments]  ${grouplist}  ${group}

   ${found}=  Set Variable  ${False}

   @{sec_groups}=  Split To Lines  ${grouplist}

   FOR  ${g}  IN  @{sec_groups}
      @{namelist}=  Split String  ${g}  =
      ${name}=  Strip String  ${namelist[1]}  characters='
      ${found}=  Run Keyword If  '${name}' == '${group}'  Set Variable  ${True}
      ...  ELSE  Set Variable  ${found}
   END

   Should Be True  ${found}  Did not find security group ${group}

