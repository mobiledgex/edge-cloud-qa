*** Settings ***
Documentation  VM deployment 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_VM_ENV}
Library  MexApp
Library  String
Library  Collections

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
${region}  EU	
${cloudlet_name_openstack_vm}  automationBonnCloudlet
${operator_name_openstack}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${qcow_centos_image_notrunning}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c
${qcow_centos_openstack_image}  server_ping_threaded_centos7
${qcow_windows_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${vm_console_address}    https://hamedgecloud.telekom.de:6080/vnc_auto.html

${vm_public_key}  key

${server_ping_threaded_command}  /opt/rh/rh-python36/root/usr/bin/python3 /home/centos/server_ping_threaded.py

${server_ping_threaded_cloudconfig}  http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml
	
${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-2167
User shall be able to create VM/LB deployment on openstack
    [Documentation]
    ...  deploy VM app with a Load Balancer on openstack 
    ...  verify security groups are correct

    [Teardown]  Teardown  ${openstack_image}

    ${server_info_crm}=      Get Server List  name=${cloudlet_name_openstack_vm}.${operator_name_openstack}.pf
    ${crm_networks}=  Split String  ${server_info_crm[0]['Networks']}  =
    ${crm_ip}=  Fetch From Left  ${crm_networks[1]}  "
 
    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015,tcp:8085   access_type=loadbalancer    region=${region}   #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}   #autocluster_ip_access=IpAccessDedicated

   # verify md5 in createappinst stream
   ${app_inst_stream_output}=  Get Create App Instance Stream
   Stream Should Contain  ${app_inst_stream_output}  Creating VM Image from URL: ${openstack_image}

   # verify image is downloaded with md5 in imagename
   @{image_list}=  Get Image List  name=${openstack_image}
   Should Be Equal  ${image_list[0]['Status']}  active
   Length Should Be  ${image_list}  1

   # verify dedicated cluster as it own security group
   ${server_show}=  Get Server Show  name=${vm_lb}
   Security Groups Should Contain  ${server_show['security_groups']}  ${vm_lb}-sg
   ${openstacksecgroup}=  Get Security Groups  name=${vm_lb}-sg
   Should Be Equal  ${openstacksecgroup['name']}   ${vm_lb}-sg
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='egress', ethertype='IPv4', id='.*', updated_at
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='2016', port_range_min='2016', protocol='tcp', remote_ip_prefix='0.0.0.0/0', updated_at
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='2015', port_range_min='2015', protocol='udp', remote_ip_prefix='0.0.0.0/0', updated_at=
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='8085', port_range_min='8085', protocol='tcp', remote_ip_prefix='0.0.0.0/0', updated_at=
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='22', port_range_min='22', protocol='tcp', remote_ip_prefix='${crm_ip}/32', updated_at=
   @{sec_groups}=  Split To Lines  ${openstacksecgroup['rules']}
   Length Should Be  ${sec_groups}  5

   @{sec_groups}=  Split To Lines  ${server_show['security_groups']}
   Length Should Be  ${sec_groups}  2

# direct not supported
# ECQ-2168
#User shall be able to create VM deployment on openstack
#    [Documentation]
#    ...  deploy VM app on openstack 
#    ...  verify security groups are correct
#
#    [Teardown]  Teardown  ${openstack_image}
# 
#    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:23-2016,udp:2015-40000   access_type=direct    region=${region}   #default_flavor_name=${cluster_flavor_name}
#    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}   #autocluster_ip_access=IpAccessDedicated
#
#   # verify md5 in createappinst stream
#   ${app_inst_stream_output}=  Get Create App Instance Stream
#   Stream Should Contain  ${app_inst_stream_output}  Creating VM Image from URL: ${openstack_image}
#
#   # verify image is downloaded with md5 in imagename
#   @{image_list}=  Get Image List  name=${openstack_image}
#   Should Be Equal  ${image_list[0]['Status']}  active
#   Length Should Be  ${image_list}  1
# 
#   # verify dedicated cluster as it own security group
#   ${server_show}=  Get Server Show  name=${vm}
#   Security Groups Should Contain  ${server_show['security_groups']}  ${vm}-sg
#   ${openstacksecgroup}=  Get Security Groups  name=${vm}-sg
#   Should Be Equal  ${openstacksecgroup['name']}   ${vm}-sg
#   Should Match Regexp  ${openstacksecgroup['rules']}  direction='egress', ethertype='IPv4', id='.*', updated_at
#   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='2016', port_range_min='23', protocol='tcp', remote_ip_prefix='0.0.0.0/0', updated_at
#   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='40000', port_range_min='2015', protocol='udp', remote_ip_prefix='0.0.0.0/0', updated_at=
#   @{sec_groups}=  Split To Lines  ${openstacksecgroup['rules']}
#   Length Should Be  ${sec_groups}  3
#
#   @{sec_groups}=  Split To Lines  ${server_show['security_groups']} 
#   Length Should Be  ${sec_groups}  2

# update after controller is fixed for artifactoryFQDN value
User shall be able to create VM deployment with md5 argument on openstack
    [Documentation]
    ...  deploy VM app on openstack
    ...  verify security groups are correct

    [Teardown]  Teardown  ${openstack_image}

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:23-2016,udp:2015-40000   access_type=direct    region=${region}   #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}   autocluster_ip_access=IpAccessDedicated

   # verify md5 in createappinst stream
   ${app_inst_stream_output}=  Get Create App Instance Stream
   Stream Should Contain  ${app_inst_stream_output}  Creating VM Image from URL: ${openstack_image}

   # verify image is downloaded with md5 in imagename
   @{image_list}=  Get Image List  name=${openstack_image}
   Should Be Equal  ${image_list[0]['Status']}  active
   Length Should Be  ${image_list}  1

   # verify dedicated cluster as it own security group
   ${server_show}=  Get Server Show  name=${vm}
   Security Groups Should Contain  ${server_show['security_groups']}  ${vm}-sg
   ${openstacksecgroup}=  Get Security Groups  name=${vm}-sg
   Should Be Equal  ${openstacksecgroup['name']}   ${vm}-sg
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='egress', ethertype='IPv4', id='.*', updated_at
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='2016', port_range_min='23', protocol='tcp', remote_ip_prefix='0.0.0.0/0', updated_at
   Should Match Regexp  ${openstacksecgroup['rules']}  direction='ingress', ethertype='IPv4', id='.*', port_range_max='40000', port_range_min='2015', protocol='udp', remote_ip_prefix='0.0.0.0/0', updated_at=
   @{sec_groups}=  Split To Lines  ${openstacksecgroup['rules']}
   Length Should Be  ${sec_groups}  3

   @{sec_groups}=  Split To Lines  ${server_show['security_groups']}
   Length Should Be  ${sec_groups}  2
 
*** Keywords ***
Setup
   Create Flavor  disk=80  region=${region}

   ${cluster_name_default}=  Get Default Cluster Name
   ${app_name_default}=  Get Default App Name
   ${developer_name_default}=  Get Default Developer Name
   ${version_default}=  Get Default App Version

   ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_vm}  ${operator_name_openstack}  ${mobiledgex_domain}
   ${rootlb}=  Convert To Lowercase  ${rootlb}
   ${vm}=  Convert To Lowercase  ${developer_name_default}${app_name_default}${version_default}
   ${vm}=  Remove String  ${vm}  .
   ${vm_lb}=  Catenate  SEPARATOR=.  ${vm}  ${rootlb}

   @{image_split}=  Split String  ${qcow_centos_image}  /
   @{image_md5_split}=  Split String  ${image_split[-1]}  \#md5:
   @{image_name_split}=  Split String  ${image_md5_split[0]}  .
   ${openstack_image}=  Catenate  SEPARATOR=-  ${image_name_split[0]}  ${image_md5_split[1]}

   Set Suite Variable  ${vm}
   Set Suite Variable  ${vm_lb}
   Set Suite Variable  ${openstack_image}

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

Stream Should Contain
   [Arguments]  ${stream}  ${msg}

   ${found}=  Set Variable  ${False}

   FOR  ${g}  IN  @{stream}
      ${found}=  Run Keyword If  '${g['data']['message']}' == '${msg}'  Set Variable  ${True}
      ...  ELSE  Set Variable  ${found}
   END

   Should Be True  ${found}  Did not find ${msg}

Teardown
   [Arguments]  ${openstack_image}

   Cleanup Provisioning
   # verify image is deleted 
   @{image_list}=  Get Image List  name=${openstack_image}
   Length Should Be  ${image_list}  0
	
