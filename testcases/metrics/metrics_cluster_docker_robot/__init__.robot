*** Settings ***
Documentation   Cluster Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Teardown 

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBerlinCloudletStage 
${operator}=                       TDG

${region}=  EU

${test_timeout}=  32 min

*** Keywords ***
Setup
   Create Flavor  region=${region}
   
   ${clustername}=  Get Default Cluster Name
   ${clustername_docker}=  Catenate  SEPARATOR=-  ${clustername}  docker 

   Set Suite Variable  ${clustername_docker}

   ${t}=  Get Default Time Stamp

   Create Cluster Instance  region=${region}  cluster_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  deployment=docker  ip_access=IpAccessDedicated 

   Log to Console  Waiting for metrics to be collected
   Sleep  20 mins

Teardown
   Cleanup Provisioning

   #Delete Cluster Instance  region=${region}  cluster_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  

