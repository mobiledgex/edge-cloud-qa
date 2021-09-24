*** Settings ***
Documentation   Cluster Shared Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Teardown 

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBerlinCloudletStage 
${operator_name_openstack}=                       TDG

${region}=  US

${test_timeout}=  32 min

# ECQ-2002
*** Keywords ***
Setup
   Create Flavor  region=${region}
   
   ${clustername}=  Get Default Cluster Name
   ${clustername_docker}=  Catenate  SEPARATOR=-  ${clustername}  dockershared 

   Set Suite Variable  ${clustername_docker}

   ${t}=  Get Default Time Stamp

   Create Cluster Instance  region=${region}  cluster_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator_name_openstack}  deployment=docker  ip_access=IpAccessShared 

   Log to Console  Waiting for metrics to be collected
   Sleep  20 mins

Teardown
   Cleanup Provisioning

   #Delete Cluster Instance  region=${region}  cluster_name=${clustername_docker}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  

