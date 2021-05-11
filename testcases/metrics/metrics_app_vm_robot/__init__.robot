*** Settings ***
Documentation   VM App Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp

#Suite Setup  Setup
#Suite Teardown  Teardown 

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBeaconCloudletStage 
${operator_name_openstack}=           GDDT
${docker_image}=  dockerimage
${region}=  EU

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

${test_timeout_crm}=  32mins

*** Keywords ***
Setup
   ${flavorname}=  Get Default Flavor Name
   ${appname}=     Get Default App Name
 
   ${appname}=     Catenate  SEPARATOR=  ${appname}  vm

   ${t}=  Get Default Time Stamp
   ${clustername_k8sshared}=  Catenate  SEPARATOR=-  cluster  ${t}  k8sshared
 
   Set Suite Variable  ${clustername_k8sshared}
   Set Suite Variable  ${flavorname}

   Create Flavor  region=${region}  flavor_name=${flavorname}  disk=80

   Create App  region=${region}  app_name=${app_name}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  developer_org_name=${developer_org_name_automation}
   ${app_inst}=  Create App Instance  region=${region}  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}
 
   #${appname_k8s}=  Set Variable  app1576004798-848067k8s 
   #${appinst}=  Show App Instances  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}

   Log to Console  Wait and connect to TCP/UDP ports
   Sleep  7 mins
#   UDP Port Should Be Alive  ${appinst[0]['data']['uri']}  ${appinst[0]['data']['mapped_ports'][1]['public_port']}
   TCP Port Should Be Alive  ${app_inst['data']['uri']}  ${app_inst['data']['mapped_ports'][0]['public_port']}  wait_time=20

   Log to Console  Waiting for metrics to be collected
   Sleep  5 mins

Teardown
   Cleanup Provisioning

   #Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator_name_openstack}   cluster_instance_name=${clustername_docker}

   #Delete App  region=${region}

   #Delete Flavor region=${region} flavor_name=${flavorname}

