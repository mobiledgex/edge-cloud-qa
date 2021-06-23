*** Settings ***
Documentation   App Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp

Suite Setup  Setup
Suite Teardown  Teardown 

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBerlinCloudletStage 
${operator_name_openstack}=           TDG
${docker_image}=  dockerimage
${region}=  EU

${test_timeout_crm}=  32mins

*** Keywords ***
Setup
   ${t}=  Get Default Time Stamp

   ${flavorname}=  Get Default Flavor Name
   #${appname}=     Get Default App Name
 
   ${appname}=     Catenate  SEPARATOR=  AppMetricsDocker  ${t}  docker

   ${clustername_docker}=  Catenate  SEPARATOR=-  cluster  ${t}  docker
 
   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${flavorname}

   Create Flavor  region=${region}  flavor_name=${flavorname}

   Create Cluster Instance  region=${region}  cluster_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessShared 
 
   Create App  region=${region}  app_name=${appname}     deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,udp:2015

   Create App Instance  region=${region}  app_name=${appname}  cluster_instance_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  #autocluster_ip_access=IpAccessDedicated

   #${appname_k8s}=  Set Variable  app1576004798-848067k8s 
   ${appinst}=  Show App Instances  region=${region}  app_name=${appname}  cluster_instance_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}

   Log to Console  Wait and connect to TCP/UDP ports
   Sleep  5 mins
   UDP Port Should Be Alive  ${appinst[0]['data']['uri']}  ${appinst[0]['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${appinst[0]['data']['uri']}  ${appinst[0]['data']['mapped_ports'][0]['public_port']}  wait_time=180

   Log to Console  Waiting for metrics to be collected
   Sleep  3 mins

Teardown
   Cleanup Provisioning

   #Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}   cluster_instance_name=${clustername_docker}

   #Delete App  region=${region}

   #Delete Flavor region=${region} flavor_name=${flavorname}

