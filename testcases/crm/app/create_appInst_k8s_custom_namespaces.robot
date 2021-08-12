*** Settings ***
Documentation  k8 with custom namesapces

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_crm}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${http_page}       automation.html

${test_timeout_crm}  15 min

${namespace_manifest}=  http://35.199.188.102/apps/automation_server_ping_threaded_namespaces.yml

${region}=  EU

*** Test Cases ***
# ECQ-3360
User shall be able to create a k8s app instance with with custom namespaces
   [Documentation]
   ...  - deploy k8s app with custom namespaces
   ...  - verify all ports are accessible

   Log To Console  Creating App and App Instance
   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,tcp:8085  image_path=no_default  deployment_manifest=${namespace_manifest}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=kubernetes  #default_flavor_name=${cluster_flavor_name}
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  timeout=1200

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

   TCP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[0].public_port}
   TCP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port} 

   UDP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port} 

   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[3].public_port}  ${http_page}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

*** Keywords ***
Setup
    Create Flavor  region=${region}  ram=4096
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1  deployment=kubernetes
    Log To Console  Done Creating Cluster Instance

    ${app_name}=  Get Default App Name
    ${cluster_name}=  Get Default Cluster Name

    Set Suite Variable  ${app_name}
    Set Suite Variable  ${cluster_name}
