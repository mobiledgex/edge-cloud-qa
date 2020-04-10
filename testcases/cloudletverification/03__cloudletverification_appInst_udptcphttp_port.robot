*** Settings ***
Documentation  use FQDN to access app on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexApp
Library  String

Suite Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationMunichCloudlet
${operator_name_openstack}  TDG
${cloudlet_latitude}       32.7767
${cloudlet_longitude}      -96.7970

${cluster_name}  cluster

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml
${manifest_url_sharedvolumesize}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_shared_volumemount.yml
	
${test_timeout_crm}  32 min

${region}=  EU
	
*** Test Cases ***
User shall be able to deploy App Instance on docker dedicated
   [Documentation]
   ...  deploy app instance on IpAccessDedicated docker with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  docker  dedicated  appinst

   Log To Console  \nCreate app instance for docker dedicated 

   Create App Instance  region=${region}  app_name=${app_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockerdedicated}

   Log To Console  \nCreate app instance done 

User shall be able to deploy App Instance on docker shared
   [Documentation]
   ...  deploy app instance on IpAccessShared docker with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  docker  shared  appinst

   Log To Console  \nCreate app instance for docker shared

   Create App Instance  region=${region}  app_name=${app_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockershared}

   Log To Console  \nCreate app instance done

User shall be able to deploy App Instance on k8s shared 
   [Documentation]
   ...  deploy app instance on k8s shared with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  k8s  shared  appinst

   Log To Console  \nCreate app instance for k8s shared 

   Create App Instance  region=${region}  app_name=${app_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8sshared}

   Log To Console  \nCreate app instance done

User shall be able to deploy App Instance on k8s dedicated 
   [Documentation]
   ...  deploy app instance on k8s dedicated with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  k8s  dedicated  appinst

   Log To Console  \nCreate app instance for k8s dedicated

   Create App Instance  region=${region}  app_name=${app_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8sdedicated}

   Log To Console  \nCreate app instance done

User shall be able to deploy App Instance on k8s shared with sharedvolumesize
   [Documentation]
   ...  deploy app instance on k8s shared with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  k8s  shared  appinst  sharedvolumesize

   Log To Console  \nCreate app instance for k8s shared with sharedvolumesize

   Create App Instance  region=${region}  app_name=${app_name_k8ssharedvolumesize}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8ssharedvolumesize}

   Log To Console  \nCreate app instance done

User shall be able to deploy a VM App Instance
   [Documentation]
   ...  deploy a VM app instance with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  vm  appinst

   Log To Console  \nCreate VM app instance

   ${vm_starttime}=  Get Time  epoch
   Create App Instance  region=${region}  app_name=${app_name_vm}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_vm}
   ${vm_endtime}=  Get Time  epoch

   Log To Console  \nCreate app instance done

   Set Global Variable  ${vm_starttime}
   Set Global Variable  ${vm_endtime}

User shall be able to deploy VM App Instance with cloud-config
   [Documentation]
   ...  deploy VM app on openstack with 1 UDP and 1 TCP port with cloud-config
   ...  verify all ports are accessible via fqdn
   [Tags]  app  vm  appinst

   Log To Console  \nCreate VM app instance with cloud-config

   ${vmcloudconfig_starttime}=  Get Time  epoch
   ${app_inst}=  Create App Instance  region=${region}  app_name=${app_name_vm_cloudconfig}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_vm}
   ${vmcloudconfig_endtime}=  Get Time  epoch

   Log To Console  \nCreate app instance done

   Set Global Variable  ${vmcloudconfig_starttime}
   Set Global Variable  ${vmcloudconfig_endtime}

User shall be able to access UDP/TCP port on docker dedicated 
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  docker  dedicated  portaccess 

   Log To Console  \nRegistering Client and Finding Cloudlet for docker dedicated
   Register Client  app_name=${app_name_dockerdedicated}
   ${cloudlet}=  Find Cloudlet	 latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

User shall be able to access UDP/TCP port on docker shared
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  docker  shared  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for docker shared
   Register Client  app_name=${app_name_dockershared}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

User shall be able to access UDP/TCP/HTTP port on k8s dedicated
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  k8s  dedicated  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for k8s dedicated
   Register Client  app_name=${app_name_k8sdedicated}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

User shall be able to access UDP/TCP/HTTP port on k8s shared 
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  k8s  shared  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for k8s shared 
   Register Client  app_name=${app_name_k8sshared}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

User shall be able to access UDP/TCP/HTTP port on VM
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  vm  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for VM 
   Register Client  app_name=${app_name_vm}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${http_page}

User shall be able to access UDP/TCP/HTTP port on VM with cloudconfig
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  vm  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for VM with cloudconfig
   Register Client  app_name=${app_name_vm_cloudconfig}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${http_page}

*** Keywords ***
Setup
    Create App  region=${region}  app_name=${app_name_dockerdedicated}  deployment=docker      image_path=${docker_image}       access_ports=tcp:2016,udp:2015,tcp:8085   command=${docker_command}
    Create App  region=${region}  app_name=${app_name_dockershared}     deployment=docker      image_path=${docker_image}       access_ports=tcp:2016,udp:2015,tcp:8085   command=${docker_command}
    Create App  region=${region}  app_name=${app_name_k8sdedicated}     deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}
    Create App  region=${region}  app_name=${app_name_k8sshared}        deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}
    Create App  region=${region}  app_name=${app_name_k8ssharedvolumesize}        deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015  deployment_manifest=${manifest_url_sharedvolumesize} 

    Create App  region=${region}  app_name=${app_name_vm}              deployment=vm  image_path=${qcow_centos_image}             access_ports=tcp:2016,udp:2015,tcp:8085  image_type=ImageTypeQCOW  default_flavor_name=${flavor_name_vm}
    Create App  region=${region}  app_name=${app_name_vm_cloudconfig}  deployment=vm  image_path=${qcow_centos_image_notrunning}  access_ports=tcp:2016,udp:2015,tcp:8085  image_type=ImageTypeQCOW  deployment_manifest=${vm_cloudconfig}


