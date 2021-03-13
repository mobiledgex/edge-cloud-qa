*** Settings ***
Documentation  use FQDN to access VM app on openstack

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_VM_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
${region}  EU	
${cloudlet_name_openstack_vm}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhawkinscloudlet.gddt.mobiledgex.net

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${qcow_centos_image_notrunning}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c
${qcow_centos_openstack_image}  server_ping_threaded_centos7
${qcow_windows_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${vm_console_address}    https://hamedgecloud.telecom.de:6080/vnc_auto.html

${vm_public_key}  key

${server_ping_threaded_command}  /opt/rh/rh-python36/root/usr/bin/python3 /home/centos/server_ping_threaded.py

${server_ping_threaded_cloudconfig}  http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml
	
${test_timeout_crm}  15 min

*** Test Cases ***
User shall be able to access VM deployment UDP and TCP ports on openstack with new image
    [Documentation]
    ...  delete existing VM image on openstack
    ...  deploy VM app with 1 UDP and 1 TCP port
    ...  verify all ports are accessible via fqdn
	
    # https://mobiledgex.atlassian.net/browse/ECQ-1386
    
    Run Keyword and Ignore Error  Delete Image  ${qcow_centos_openstack_image}

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015   region=${region}   #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}

    # has been removed from appinst
    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client  
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

User shall be able to access VM deployment UDP and TCP ports on openstack with existing image
    [Documentation]
    ...  deploy VM app on openstack with 1 UDP and 1 TCP port with existing image
    ...  verify all ports are accessible via fqdn

    # https://mobiledgex.atlassian.net/browse/ECQ-1387

    ${image_list}=  Get Image List  ${qcow_centos_openstack_image}
    Should Be Equal  ${image_list[0]['Name']}   ${qcow_centos_openstack_image}
    Should Be Equal  ${image_list[0]['Status']}   active 

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015,tcp:8085  auth_public_key=${vm_public_key}  region=${region}  #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12} 
    #Should Match Regexp  https://hamedgecloud.telecom.de:6080/vnc_auto.html?token=***REMOVED***  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    ${developer_name_default}=  Get Default Developer Name
    ${app_version_default}=  Get Default App Version
    ${token}=  Generate Auth Token  app_name=${app_name_default}  app_version=${app_version_default}  developer_name=${developer_name_default}  #key_file=id_rsa_mex 

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client  auth_token=${token}
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
#     TCP Port Should Be Alive  developer1570561247-819531app1570561247-81953110.automationsunnydalecloudlet.gddt.mobiledgex.net  2016

# ECQ-2125
User shall be able to access VM/LB deployment UDP and TCP ports on openstack
    [Documentation]
    ...  deploy VM app with a Load Balancer on openstack with 1 UDP and 1 TCP port with existing image
    ...  verify all ports are accessible via fqdn

    # https://mobiledgex.atlassian.net/browse/ECQ-2125

    #${image_list}=  Get Image List  ${qcow_centos_openstack_image}
    #Should Be Equal  ${image_list[0]['Name']}   ${qcow_centos_openstack_image}
    #Should Be Equal  ${image_list[0]['Status']}   active 

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015,tcp:8085   access_type=loadbalancer    region=${region}   #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}   #autocluster_ip_access=IpAccessDedicated

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12} 
    #Should Match Regexp  https://hamedgecloud.telecom.de:6080/vnc_auto.html?token=***REMOVED***  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    ${developer_name_default}=  Get Default Developer Name
    ${app_version_default}=  Get Default App Version
    # ${token}=  Generate Auth Token  app_name=${app_name_default}  app_version=${app_version_default}  developer_name=${developer_name_default}  key_file=id_rsa_mex 

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client 
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}


User shall be able to access VM deployment UDP and TCP ports on openstack with command
    [Documentation]
    ...  deploy VM app on openstack with 1 UDP and 1 TCP port with command
    ...  verify all ports are accessible via fqdn

    # https://mobiledgex.atlassian.net/browse/ECQ-1388	

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image_notrunning}  access_ports=tcp:2016,udp:2015  command=${server_ping_threaded_command}   region=${region}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster   region=${region}

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

# ECQ-1389
User shall be able to access VM deployment UDP and TCP ports on openstack with cloud-config
    [Documentation]
    ...  deploy VM app on openstack with 1 UDP and 1 TCP port with cloud-config
    ...  verify all ports are accessible via fqdn

    # https://mobiledgex.atlassian.net/browse/ECQ-1389

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image_notrunning}  access_ports=tcp:2016,udp:2015  deployment_manifest=${server_ping_threaded_cloudconfig}   region=${region}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

User shall be able to access VM deployment UDP and TCP ports on openstack without clustername
    [Documentation]
    ...  deploy VM app on openstack with 1 UDP and 1 TCP port without clustername
    ...  verify all ports are accessible via fqdn

    # https://mobiledgex.atlassian.net/browse/ECQ-1459

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name
    ${developer_name_default}=  Get Default Developer Name
    ${app_version_default}=  Get Default App Version

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  region=${region}  #command=${server_ping_threaded_command}   
    ${app_inst}=  Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}   region=${region}

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

User shall be able to access windows VM deployment UDP and TCP ports on openstack
    [Documentation]
    ...  deploy windows VM app on openstack with 1 UDP and 1 TCP port without clustername
    ...  verify all ports are accessible via fqdn

    # https://mobiledgex.atlassian.net/browse/ECQ-1477

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name
    ${developer_name_default}=  Get Default Developer Name
    ${app_version_default}=  Get Default App Version

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_windows_image}  access_ports=tcp:2016,udp:2015    region=${region}
    ${app_inst}=  Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}   region=${region}   

    #Should Match Regexp  ${app_inst.runtime_info.console_url}  ^${vm_console_address}\\?token=[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    #TCP Port Should Be Alive  developer1567283863-034891app1567283863-03489110.automationhawkinscloudlet.gddt.mobiledgex.net  2016 
    #UDP Port Should Be Alive  developer1567283399-468097app1567283399-46809710.automationhawkinscloudlet.gddt.mobiledgex.net  2015

    Sleep  1m

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

User shall be able to access VM deployment UDP and TCP ports on openstack with port range 
    [Documentation]
    ...  deploy VM app on openstack with 1 UDP and 1 TCP port with port range
    ...  verify all ports are accessible via fqdn

    # https://mobiledgex.atlassian.net/browse/ECQ-1735

    #${image_list}=  Get Image List  ${qcow_centos_openstack_image}
    #Should Be Equal  ${image_list[0]['Name']}   ${qcow_centos_openstack_image}
    #Should Be Equal  ${image_list[0]['Status']}   active

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2000-2049,udp:2000-2049   region=${region}   #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster   region=${region}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    Should Be Equal As Integers  ${cloudlet.ports[0].public_port}  2000
    Should Be Equal As Integers  ${cloudlet.ports[0].end_port}     2049
    Should Be Equal As Integers  ${cloudlet.ports[1].public_port}  2000
    Should Be Equal As Integers  ${cloudlet.ports[1].end_port}     2049 

    TCP Port Should Be Alive  ${cloudlet.fqdn}  2015 
    UDP Port Should Be Alive  ${cloudlet.fqdn}  2015 
    TCP Port Should Be Alive  ${cloudlet.fqdn}  2016 
    UDP Port Should Be Alive  ${cloudlet.fqdn}  2016 

# ECQ-2902
User shall be able to access VM deployment UDP and TCP ports without cloudinit
    [Documentation]
    ...  - deploy VM app on openstack with port range without cloudinit
    ...  - verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image_nocloudinit}  access_ports=tcp:2000-2049,udp:2000-2049   region=${region}   #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster   region=${region}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    Should Be Equal As Integers  ${cloudlet.ports[0].public_port}  2000
    Should Be Equal As Integers  ${cloudlet.ports[0].end_port}     2049
    Should Be Equal As Integers  ${cloudlet.ports[1].public_port}  2000
    Should Be Equal As Integers  ${cloudlet.ports[1].end_port}     2049

    TCP Port Should Be Alive  ${cloudlet.fqdn}  2015
    UDP Port Should Be Alive  ${cloudlet.fqdn}  2015
    TCP Port Should Be Alive  ${cloudlet.fqdn}  2016
    UDP Port Should Be Alive  ${cloudlet.fqdn}  2016

# ECQ-2903
User shall be able to access VM/LB deployment UDP and TCP ports without cloudinit
    [Documentation]
    ...  - deploy VM app with a Load Balancer on openstack without cloudinit
    ...  - verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image_nocloudinit}  access_ports=tcp:2016,udp:2015,tcp:8085   access_type=loadbalancer    region=${region}   #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}   #autocluster_ip_access=IpAccessDedicated

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor  disk=80  region=${region}
	
