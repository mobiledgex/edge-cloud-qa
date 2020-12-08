*** Settings ***
Documentation   Cluster Metrics K8s Shared

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Teardown 

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBerlinCloudletStage 
${operator_name_openstack}=                       TDG

${region}=  EU

${test_timeout_crm}=  32 min

*** Keywords ***
Setup
   Create Flavor  region=${region}
   
   ${clustername}=  Get Default Cluster Name
   ${clustername_k8shared}=  Catenate  SEPARATOR=-  ${clustername}  k8sshared

   Set Suite Variable  ${clustername_k8shared}

   ${t}=  Get Default Time Stamp

   Create Cluster Instance  region=${region}  cluster_name=${clustername_k8shared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared  number_masters=1  number_nodes=1

   Log to Console  Waiting for metrics to be collected
   Sleep  15 mins

Teardown
   Cleanup Provisioning

   #Delete Cluster Instance  region=${region}  cluster_name=${clustername_k8shared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  

