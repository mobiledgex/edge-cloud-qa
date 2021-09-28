*** Settings ***
Documentation   App Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp

Suite Setup  Setup
#Suite Teardown  Teardown 

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBerlinCloudletStage 
${operator_name_openstack}=           TDG
${docker_image}=  dockerimage
${region}=  US

*** Keywords ***
Setup
   ${flavorname}=  Get Default Flavor Name
   ${appname}=     Get Default App Name
 
   #${clustername}=  Get Default Cluster Name
   #${clustername_k8s_dedicated}=  Catenate  SEPARATOR=-  ${clustername}  k8sdedicated
   #${clustername_k8s_shared}=  Catenate  SEPARATOR=-  ${clustername}  k8sshared
   #${clustername_docker}=  Catenate  SEPARATOR=-  ${clustername}  docker 

   ${appname_docker}=  Catenate  SEPARATOR=  ${appname}  docker
   ${appname_k8s}=     Catenate  SEPARATOR=  ${appname}  k8s

   ${t}=  Get Default Time Stamp
   ${clustername_docker}=  Catenate  SEPARATOR=-  autocluster  ${t}  docker
   ${clustername_k8s_shared}=  Catenate  SEPARATOR=-  autocluster  ${t}  k8sshared
   ${clustername_k8s_dedicated}=  Catenate  SEPARATOR=-  autocluster  ${t}  k8sdedicated
 
   Set Suite Variable  ${clustername_k8s_dedicated}
   Set Suite Variable  ${clustername_k8s_shared}
   Set Suite Variable  ${clustername_docker}
   Set Suite Variable  ${flavorname}

   Create Flavor  region=${region}  flavor_name=${flavorname}
 
   Create App  region=${region}  app_name=${appname_docker}  deployment=docker      image_path=${docker_image}  access_ports=tcp:2015,udp:2015  
   Create App  region=${region}  app_name=${appname_k8s}     deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2015,udp:2015

   ${handle1}=  Create App Instance  region=${region}  app_name=${appname_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}   cluster_instance_name=${clustername_docker}  use_thread=${True}
   ${handle2}=  Create App Instance  region=${region}  app_name=${appname_k8s}  cluster_instance_name=${clustername_k8s_shared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}  autocluster_ip_access=IpAccessShared  use_thread=${True}
   ${handle3}=  Create App Instance  region=${region}  app_name=${appname_k8s}  cluster_instance_name=${clustername_k8s_dedicated}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}  autocluster_ip_access=IpAccessDedicated  use_thread=${True}

   Log To Console  Waiting for AppInst threads
   Wait For Replies  ${handle1}  ${handle2}  ${handle3}
#   Wait For Replies  ${handle3} 

   #${appname_k8s}=  Set Variable  app1576004798-848067k8s 
   ${appinst_k8s_shared}=  Show App Instances  region=${region}  app_name=${appname_k8s}  cluster_instance_name=${clustername_k8s_shared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}
   ${fqdn_k8s_shared_tcp}=  Catenate  SEPARATOR=  ${appinst_k8s_shared[0]['data']['mapped_ports'][0]['fqdn_prefix']}  ${appinst_k8s_shared[0]['data']['uri']}
   ${fqdn_k8s_shared_udp}=  Catenate  SEPARATOR=  ${appinst_k8s_shared[0]['data']['mapped_ports'][1]['fqdn_prefix']}  ${appinst_k8s_shared[0]['data']['uri']}

   ${appinst_k8s_dedicated}=  Show App Instances  region=${region}  app_name=${appname_k8s}  cluster_instance_name=${clustername_k8s_dedicated}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}
   ${fqdn_k8s_dedicated_tcp}=  Catenate  SEPARATOR=  ${appinst_k8s_dedicated[0]['data']['mapped_ports'][0]['fqdn_prefix']}  ${appinst_k8s_dedicated[0]['data']['uri']}
   ${fqdn_k8s_dedicated_udp}=  Catenate  SEPARATOR=  ${appinst_k8s_dedicated[0]['data']['mapped_ports'][1]['fqdn_prefix']}  ${appinst_k8s_dedicated[0]['data']['uri']}

   ${appinst_docker}=  Show App Instances  region=${region}  app_name=${appname_docker}  cluster_instance_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}
   ${fqdn_docker_tcp}=  Set Variable  ${appinst_docker[0]['data']['uri']}
   ${fqdn_docker_udp}=  Set Variable  ${appinst_docker[0]['data']['uri']}

   Log to Console  Wait and connect to TCP/UDP ports
   Sleep  5 mins
   UDP Port Should Be Alive  ${fqdn_k8s_shared_udp}  ${appinst_k8s_shared[0]['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${fqdn_k8s_shared_tcp}  ${appinst_k8s_shared[0]['data']['mapped_ports'][0]['public_port']}  wait_time=20
   UDP Port Should Be Alive  ${fqdn_k8s_dedicated_udp}  ${appinst_k8s_dedicated[0]['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${fqdn_k8s_dedicated_tcp}  ${appinst_k8s_dedicated[0]['data']['mapped_ports'][0]['public_port']}  wait_time=20
   UDP Port Should Be Alive  ${fqdn_docker_udp}  ${appinst_docker[0]['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${fqdn_docker_tcp}  ${appinst_docker[0]['data']['mapped_ports'][0]['public_port']}  wait_time=20

   Log to Console  Waiting for metrics to be collected
   Sleep  5 mins

Teardown
   Cleanup Provisioning

   #Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}   cluster_instance_name=${clustername_docker}

   #Delete App  region=${region}

   #Delete Flavor region=${region} flavor_name=${flavorname}

