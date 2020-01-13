*** Settings ***
Documentation  use FQDN to access VM app on openstack

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_VM_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationMunichCloudlet
${operator_name_openstack}  TDG
${cloudlet_latitude}       32.7767
${cloudlet_longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${qcow_centos_image_notrunning}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c
${qcow_centos_openstack_image}  server_ping_threaded_centos7
${qcow_windows_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${vm_console_address}    https://hamedgecloud.telekom.de:6080/vnc_auto.html

${server_ping_threaded_command}  /opt/rh/rh-python36/root/usr/bin/python3 /home/centos/server_ping_threaded.py

${server_ping_threaded_cloudconfig}  http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml
	
${test_timeout_crm}  32 min

*** Test Cases ***
User shall be able to access VM deployment UDP and TCP ports on openstack with existing image
    [Documentation]
    ...  deploy VM app on openstack with 1 UDP and 1 TCP port with existing image
    ...  verify all ports are accessible via fqdn

    ${image_list}=  Get Image List  ${qcow_centos_openstack_image}
    Should Be Equal  ${image_list[0]['Name']}   ${qcow_centos_openstack_image}
    Should Be Equal  ${image_list[0]['Status']}   active 

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=dummycluster

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12} 
    #Should Match Regexp  https://hamedgecloud.telekom.de:6080/vnc_auto.html?token=a7a0df63-709e-4c21-b5ec-a718dc9df900  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
#     TCP Port Should Be Alive  developer1570561247-819531app1570561247-81953110.automationmunichcloudlet.tdg.mobiledgex.net  2016
	
User shall be able to access VM deployment UDP and TCP ports on openstack with command
    [Documentation]
    ...  deploy VM app on openstack with 1 UDP and 1 TCP port with command
    ...  verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image_notrunning}  access_ports=tcp:2016,udp:2015  command=${server_ping_threaded_command}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=dummycluster

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}


User shall be able to access windows VM deployment UDP and TCP ports on openstack
    [Documentation]
    ...  deploy windows VM app on openstack with 1 UDP and 1 TCP port without clustername
    ...  verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name
    ${developer_name_default}=  Get Default Developer Name
    ${app_version_default}=  Get Default App Version

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_windows_image}  access_ports=tcp:2016,udp:2015  
    ${app_inst}=  Create App Instance  app_name=${app_name_default}  developer_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  use_defaults=${False}

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    #TCP Port Should Be Alive  developer1567283863-034891app1567283863-03489110.automationhamburgcloudlet.tdg.mobiledgex.net  2016 
    #UDP Port Should Be Alive  developer1567283399-468097app1567283399-46809710.automationhamburgcloudlet.tdg.mobiledgex.net  2015

    Sleep  1m

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor  disk=80
	
