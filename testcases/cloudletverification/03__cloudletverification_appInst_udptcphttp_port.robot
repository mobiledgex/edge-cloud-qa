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
	
${test_timeout_crm}  32 min

${region}=  EU
	
*** Test Cases ***
User shall be able to deploy App Instance on docker dedicated
   [Documentation]
   ...  deploy app instance on IpAccessDedicated docker with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  docker  dedicated  appinst

   Log To Console  \nCreate app instance for docker dedicated 

   Create App Instance  region=${region}  app_name=${app_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockerdedicated}

   Log To Console  \nCreate app instance done 

User shall be able to deploy App Instance on docker shared
   [Documentation]
   ...  deploy app instance on IpAccessShared docker with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  docker  shared  appinst

   Log To Console  \nCreate app instance for docker shared

   Create App Instance  region=${region}  app_name=${app_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockershared}

   Log To Console  \nCreate app instance done

User shall be able to deploy App Instance on k8s shared 
   [Documentation]
   ...  deploy app instance on k8s shared with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  k8s  shared  appinst

   Log To Console  \nCreate app instance for k8s shared 

   Create App Instance  region=${region}  app_name=${app_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8sshared}

   Log To Console  \nCreate app instance done

User shall be able to deploy App Instance on k8s dedicated 
   [Documentation]
   ...  deploy app instance on k8s dedicated with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  k8s  dedicated  appinst

   Log To Console  \nCreate app instance for k8s dedicated

   Create App Instance  region=${region}  app_name=${app_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8sdedicated}

   Log To Console  \nCreate app instance done

User shall be able to deploy a VM App Instance
   [Documentation]
   ...  deploy a VM app instance with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  vm  appinst

   Log To Console  \nCreate VM app instance

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}

   Log To Console  \nCreate app instance done

User shall be able to access UDP/TCP port on docker dedicated 
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  docker  dedicated  portaccess 

   Log To Console  \nRegistering Client and Finding Cloudlet for docker dedicated
   Register Client  app_name=${app_name_dockerdedicated}
   ${cloudlet}=  Find Cloudlet	 latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[0].path_prefix}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

User shall be able to access UDP/TCP port on docker shared
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  docker  shared  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for docker shared
   Register Client  app_name=${app_name_dockershared}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[0].path_prefix}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

User shall be able to access UDP/TCP/HTTP port on k8s dedicated
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  k8s  dedicated  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for k8s dedicated
   Register Client  app_name=${app_name_k8sdedicated}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

User shall be able to access UDP/TCP/HTTP port on k8s shared 
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  k8s  shared  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for k8s shared 
   Register Client  app_name=${app_name_k8sshared}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

User shall be able to access UDP/TCP/HTTP port on VM
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  vm  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for VM 
   Register Client  app_name=${app_name_vm}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  ${page}

*** Keywords ***
Setup
#    ${cluster_name_default}=  Get Default Cluster Name
#    ${app_name_default}=  Get Default App Name
#    ${app_name_dockerdedicated}=  Catenate  SEPARATOR=  ${app_name_default}  dockerdedicated
#    ${app_name_dockershared}=  Catenate  SEPARATOR=  ${app_name_default}  dockershared
#    ${app_name_k8sshared}=  Catenate  SEPARATOR=  ${app_name_default}  k8sshared 
#    ${app_name_k8sdedicated}=  Catenate  SEPARATOR=  ${app_name_default}  k8sdedicated
#    ${app_name_vm}=  Catenate  SEPARATOR=  ${app_name_default}  vm

#    ${cluster_name_dockerdedicated}=  Catenate  SEPARATOR=  ${cluster_name}  dockerdedicated
#    ${cluster_name_dockershared}=  Catenate  SEPARATOR=  ${cluster_name}  dockershared
#    ${cluster_name_k8sdedicated}=  Catenate  SEPARATOR=  ${cluster_name}  k8sdedicated
#    ${cluster_name_k8sshared}=  Catenate  SEPARATOR=  ${cluster_name}  k8sshared 

#    ${app_name_dockerdedicated}=  Set Variable  app1583790356-440759dockerdedicated
#    ${app_name_k8sdedicated}=  Set Variable  app1583790356-440759k8sdedicated
#    ${app_name_k8sshared}=  Set Variable  app1583790356-440759k8sshared

#    ${cluster_name_dockerdedicated}=  Set Variable  cluster1583790356.141469dockerdedicated 
#    ${cluster_name_k8sdedicated}=  Set Variable  cluster1583790356.141469k8sdedicated 
#    ${cluster_name_k8sshared}=  Set Variable  cluster1583790356.141469k8sshared 

#    Create Flavor  region=${region}  ram=1024  vcpus=1  disk=20    #Docker/K8s Flavor
    Create App  region=${region}  app_name=${app_name_dockerdedicated}  deployment=docker      image_path=${docker_image}       access_ports=tcp:2016,udp:2015,tcp:8085   command=${docker_command}
    Create App  region=${region}  app_name=${app_name_dockershared}     deployment=docker      image_path=${docker_image}       access_ports=tcp:2016,udp:2015,tcp:8085   command=${docker_command}
    Create App  region=${region}  app_name=${app_name_k8sdedicated}     deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}
    Create App  region=${region}  app_name=${app_name_k8sshared}        deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}

    ${flavor_default}=  Get Default Flavor Name
    Create Flavor  region=${region}  flavor_name=${flavor_default}vm  disk=80  #VM flavor
    Create App  region=${region}  app_name=${app_name_vm}               deployment=vm          image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015,tcp:8085   image_type=ImageTypeQCOW 

#    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
#    ${rootlb}=  Convert To Lowercase  ${rootlb}

#    Set Suite Variable  ${rootlb}
#    Set Suite Variable  ${cluster_name_default}
#    Set Suite Variable  ${cluster_name_dockerdedicated}
#    Set Suite Variable  ${cluster_name_dockershared}
#    Set Suite Variable  ${cluster_name_k8sdedicated}
#    Set Suite Variable  ${cluster_name_k8sshared}

#    Set Suite Variable  ${app_name_dockerdedicated}
#    Set Suite Variable  ${app_name_dockershared}
#    Set Suite Variable  ${app_name_k8sdedicated}
#    Set Suite Variable  ${app_name_k8sshared}
#    Set Suite Variable  ${app_name_vm}


