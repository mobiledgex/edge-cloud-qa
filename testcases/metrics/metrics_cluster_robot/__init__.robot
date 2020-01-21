*** Settings ***
Documentation   Cluster Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup  Setup
Suite Teardown  Teardown 

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBerlinCloudletStage 
${operator}=                       TDG

*** Keywords ***
Setup
   Create Flavor  region=US
   
   ${clustername}=  Get Default Cluster Name
   ${clustername_k8s_dedicated}=  Catenate  SEPARATOR=-  ${clustername}  k8sdedicated
   ${clustername_k8s_shared}=  Catenate  SEPARATOR=-  ${clustername}  k8sshared
   ${clustername_docker}=  Catenate  SEPARATOR=-  ${clustername}  docker 

   Set Suite Variable  ${clustername_k8s_dedicated}
   Set Suite Variable  ${clustername_k8s_shared}
   Set Suite Variable  ${clustername_docker}

   ${t}=  Get Default Time Stamp
   log to console  ${clustername} ${clustername_k8s_shared} ${t}

   ${handle1}=  Create Cluster Instance  region=US  cluster_name=${clustername_k8s_dedicated}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  deployment=kubernetes  ip_access=IpAccessDedicated  use_thread=${True}
   ${handle2}=  Create Cluster Instance  region=US  cluster_name=${clustername_k8s_shared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  deployment=kubernetes  ip_access=IpAccessShared  use_thread=${True}
   ${handle3}=  Create Cluster Instance  region=US  cluster_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  deployment=docker  ip_access=IpAccessDedicated  use_thread=${True}

   Log To Console  Waiting for Cluster threads
   Wait For Replies  ${handle1}  ${handle2}  ${handle3}
   #Wait For Replies  ${handle2} 

   #Create Cluster Instance  operator_name=${operator}  cloudlet_name=${cloudlet_name_openstack_metrics}

   Log to Console  Waiting for metrics to be collected
   Sleep  20 mins

Teardown
   Cleanup Provisioning

   Delete Cluster Instance  region=US  cluster_name=${clustername_k8s_dedicated}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}
   Delete Cluster Instance  region=US  cluster_name=${clustername_k8s_shared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  
   Delete Cluster Instance  region=US  cluster_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  

