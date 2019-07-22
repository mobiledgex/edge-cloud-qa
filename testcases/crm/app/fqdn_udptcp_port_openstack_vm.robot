*** Settings ***
Documentation  use FQDN to access VM app on openstack

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhawkinscloudlet.gddt.mobiledgex.net

${qcow_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${qcow_openstack_image}  server_ping_threaded_centos7
	
${test_timeout_crm}  15 min

*** Test Cases ***
User shall be able to access VM deployment UDP and TCP ports on openstack with new image
    [Documentation]
    ...  delete existing VM image on openstack
    ...  deploy VM app with 1 UDP and 1 TCP port
    ...  verify all ports are accessible via fqdn

    Run Keyword and Ignore Error  Delete Openstack Image  ${qcow_openstack_image}

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_image}  access_ports=tcp:2016,udp:2015  #default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=dummycluster

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

    ${image_list}=  Get Openstack Image List  ${qcow_openstack_image}
    Should Be Equal  ${image_list[0]['Name']}   ${qcow_openstack_image}
    Should Be Equal  ${image_list[0]['Status']}   active 

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_image}  access_ports=tcp:2016,udp:2015  #default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=dummycluster

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

*** Keywords ***
Setup
    Create Developer
    Create Flavor  disk=80
	
