*** Settings ***
Documentation  use FQDN to access 2 apps on the same rootlb

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
#Test Teardown   Teardown

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_shared}  automationBonnCloudlet
${operator_name_openstack}  TDG
${latitude}=  1
${longitude}=  1

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
#${docker_command}  ./server_ping_threaded.py

${region}=  EU

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-2426
User shall be able to access TCP/UDP/HTTP ports for 2 apps on the same rootlb
   [Documentation]
   ...  - deploy a shared docker app with with 1 TCP/UDP/HTTP port
   ...  - deploy a shared k8s app with with 1 TCP/UDP/HTTP port
   ...  - verify all the port as accessible via fqdn

   Log to Console  \nCreating docker shared IP cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_docker}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker  #flavor_name=${flavor_name_medium}  developer_org_name=${developer_organization_name}
   Log to Console  \nCreating cluster instance done

   Log to Console  \nCreating k8s shared IP cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8s}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  #flavor_name=${flavor_name_small}  developer_org_name=${developer_organization_name}
   Log to Console  \nCreating cluster instance done

   Log To Console  Creating App and App Instance
   Create App  region=${region}  app_name=${app_name_docker}  deployment=docker  access_type=loadbalancer  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085   #command=${docker_command}  developer_org_name=${developer_organization_name}  default_flavor_name=${flavor_name_medium}
   Create App Instance  region=${region}  app_name=${app_name_docker}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_docker}
   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_docker}
   App Instance Should Exist  region=${region}  app_name=${app_name_docker}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Create App  region=${region}  app_name=${app_name_k8s}  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  #command=${docker_command}  developer_org_name=${developer_organization_name}  default_flavor_name=${flavor_name_small}
   Create App Instance  region=${region}  app_name=${app_name_k8s}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8s}
   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_k8s}
   App Instance Should Exist  region=${region}  app_name=${app_name_k8s}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Log To Console  Registering Client and Finding Cloudlet for docker
   Register Client  app_name=${app_name_docker}
   ${cloudlet1}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_tcp1}=  Catenate  SEPARATOR=  ${cloudlet1.ports[0].fqdn_prefix}  ${cloudlet1.fqdn}
   ${fqdn_udp1}=  Catenate  SEPARATOR=  ${cloudlet1.ports[1].fqdn_prefix}  ${cloudlet1.fqdn}
   ${fqdn_http1}=  Catenate  SEPARATOR=  ${cloudlet1.ports[2].fqdn_prefix}  ${cloudlet1.fqdn}

   Log To Console  Checking if port is alive
   TCP Port Should Be Alive  ${fqdn_tcp1}  ${cloudlet1.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_udp1}  ${cloudlet1.ports[1].public_port}
   HTTP Port Should Be Alive  ${fqdn_http1}  ${cloudlet1.ports[2].public_port} 

   Log To Console  Registering Client and Finding Cloudlet for k8s
   Register Client  app_name=${app_name_k8s}
   ${cloudlet2}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_tcp2}=  Catenate  SEPARATOR=  ${cloudlet2.ports[0].fqdn_prefix}  ${cloudlet2.fqdn}
   ${fqdn_udp2}=  Catenate  SEPARATOR=  ${cloudlet2.ports[1].fqdn_prefix}  ${cloudlet2.fqdn}
   ${fqdn_http2}=  Catenate  SEPARATOR=  ${cloudlet2.ports[2].fqdn_prefix}  ${cloudlet2.fqdn}

   Log To Console  Checking if port is alive
   TCP Port Should Be Alive  ${fqdn_tcp2}  ${cloudlet2.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_udp2}  ${cloudlet2.ports[1].public_port}
   HTTP Port Should Be Alive  ${fqdn_http2}  ${cloudlet2.ports[2].public_port} 

# ECQ-3113
User shall be able to access TCP/UDP ports for 2 k8s apps with same name but different versions on the same rootlb
   [Documentation]
   ...  - deploy 2 shared k8s apps with same name but different version with with 1 TCP/UDP/ port
   ...  - verify all the port as accessible via fqdn

   Log to Console  \nCreating k8s shared IP cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8s}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  #flavor_name=${flavor_name_small}  developer_org_name=${developer_organization_name}
   Log to Console  \nCreating cluster instance done

   Log To Console  Creating App and App Instance
   Create App  region=${region}  app_name=${app_name_k8s}  app_version=1.0  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}  access_ports=tcp:2015,udp:2015
   Create App Instance  region=${region}  app_name=${app_name_k8s}  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8s}
   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_k8s}  app_version=1.0
   #App Instance Should Exist  region=${region}  app_name=${app_name_docker}  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Create App  region=${region}  app_name=${app_name_k8s}  app_version=2.0  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2016,udp:2016
   Create App Instance  region=${region}  app_name=${app_name_k8s}  app_version=2.0  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8s}
   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_k8s}  app_version=2.0
   #App Instance Should Exist  region=${region}  app_name=${app_name_k8s}  app_version=2.0  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   Log To Console  Registering Client and Finding Cloudlet for docker
   Register Client  app_name=${app_name_k8s}  app_version=1.0
   ${cloudlet1}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_tcp1}=  Catenate  SEPARATOR=  ${cloudlet1.ports[0].fqdn_prefix}  ${cloudlet1.fqdn}
   ${fqdn_udp1}=  Catenate  SEPARATOR=  ${cloudlet1.ports[1].fqdn_prefix}  ${cloudlet1.fqdn}

   Log To Console  Checking if port is alive
   TCP Port Should Be Alive  ${fqdn_tcp1}  ${cloudlet1.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_udp1}  ${cloudlet1.ports[1].public_port}

   Log To Console  Registering Client and Finding Cloudlet for k8s
   Register Client  app_name=${app_name_k8s}  app_version=2.0
   ${cloudlet2}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_tcp2}=  Catenate  SEPARATOR=  ${cloudlet2.ports[0].fqdn_prefix}  ${cloudlet2.fqdn}
   ${fqdn_udp2}=  Catenate  SEPARATOR=  ${cloudlet2.ports[1].fqdn_prefix}  ${cloudlet2.fqdn}

   Log To Console  Checking if port is alive
   TCP Port Should Be Alive  ${fqdn_tcp2}  ${cloudlet2.ports[0].public_port}
   UDP Port Should Be Alive  ${fqdn_udp2}  ${cloudlet2.ports[1].public_port}

*** Keywords ***
Setup
   Create Flavor  region=${region}

   ${app_name_default}=  Get Default App Name
   ${cluster_name_default}=  Get Default Cluster Name

   ${app_name_docker}=  Catenate  SEPARATOR=  ${app_name_default}  dockershared
   ${app_name_k8s}=     Catenate  SEPARATOR=  ${app_name_default}  k8sshared

   ${cluster_name_docker}=  Catenate  SEPARATOR=  ${cluster_name_default}  dockershared
   ${cluster_name_k8s}=     Catenate  SEPARATOR=  ${cluster_name_default}  k8sshared
 
   Set Suite Variable  ${app_name_docker}
   Set Suite Variable  ${app_name_k8s}
   Set Suite Variable  ${cluster_name_docker}
   Set Suite Variable  ${cluster_name_k8s}

Teardown
   Cleanup provisioning
   App Instance Should Not Exist  region=${region}  app_name=${app_name_k8s}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}
   App Instance Should Not Exist  region=${region}  app_name=${app_name_docker}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

