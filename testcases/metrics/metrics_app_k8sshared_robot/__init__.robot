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
   ${flavorname}=  Get Default Flavor Name
   ${appname}=     Get Default App Name
 
   ${appname}=     Catenate  SEPARATOR=  ${appname}  k8s

   ${t}=  Get Default Time Stamp
   ${clustername_k8sshared}=  Catenate  SEPARATOR=-  cluster  ${t}  k8sshared
 
   Set Suite Variable  ${clustername_k8sshared}
   Set Suite Variable  ${flavorname}

   Create Flavor  region=${region}  flavor_name=${flavorname}

   Create Cluster Instance  region=${region}  cluster_name=${clustername_k8sshared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  number_nodes=1
 
   Create App  region=${region}  app_name=${appname}     deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2015,udp:2015

   Create App Instance  region=${region}  app_name=${appname}  cluster_instance_name=${clustername_k8sshared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  #autocluster_ip_access=IpAccessDedicated

   #${appname_k8s}=  Set Variable  app1576004798-848067k8s 
   ${appinst}=  Show App Instances  region=${region}  app_name=${appname}  cluster_instance_name=${clustername_k8sshared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}
   ${fqdn_tcp}=  Set Variable  ${appinst[0]['data']['uri']}
   ${fqdn_udp}=  Set Variable  ${appinst[0]['data']['uri']}

   Log to Console  Wait and connect to TCP/UDP ports
   Sleep  5 mins
   UDP Port Should Be Alive  ${fqdn_udp}  ${appinst[0]['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${fqdn_tcp}  ${appinst[0]['data']['mapped_ports'][0]['public_port']}  wait_time=180

   Log to Console  Waiting for metrics to be collected
   Sleep  3 mins

Teardown
   Cleanup Provisioning

   #Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}   cluster_instance_name=${clustername_docker}

   #Delete App  region=${region}

   #Delete Flavor region=${region} flavor_name=${flavorname}

