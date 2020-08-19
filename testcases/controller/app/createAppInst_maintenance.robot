*** Settings ***
Documentation   CreateClusterInst with cloudlet maintenance failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
#Test Teardown  Teardown

*** Variables ***
${region}=  US

*** Test Cases ***
AppInst - error shall be recieved when creating a docker/direct/shared autocluster app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance mode
   ...  - create a docker/direct/shared autocluster app instance on the cloudlet 
   ...  - verify proper error is received

   ${policy}=  Create Auto Provisioning Policy  region=${region}  developer_org_name=${operator_name}  deploy_client_count=10  deploy_interval_count=3
   Add Auto Provisioning Policy Cloudlet  region=${region}  developer_org_name=${operator_name}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}
   Add Auto Provisioning Policy Cloudlet  region=${region}  developer_org_name=${operator_name}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker

   Create App  region=${region}  auto_prov_policy=${policy['data']['key']['name']}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=${operator_name}  cluster_instance_name=${cluster1}  cluster_instance_developer_org_name=MobiledgeX

#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#


*** Keywords ***
Setup
   Create Flavor  region=${region}

   ${cluster_name}=  Get Default Cluster Name
   ${cluster1}=  Catenate  SEPARATOR=  ${cluster_name}  1
   ${cluster2}=  Catenate  SEPARATOR=  ${cluster_name}  1

   ${cloudlet_name}=  Get Default Cloudlet Name
   ${cloudlet_name1}=  Catenate  SEPARATOR=  ${cloudlet_name}  1
   ${cloudlet_name2}=  Catenate  SEPARATOR=  ${cloudlet_name}  2

   Create Org
   Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name1}
   Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name2}

   ${operator_name}=  Get Default Organization Name
   ${flavor_name_default}=  Get Default Flavor Name
   Set Suite Variable  ${flavor_name_default}
   Set Suite Variable  ${operator_name}
   Set Suite Variable  ${cloudlet_name1}
   Set Suite Variable  ${cloudlet_name2}
   Set Suite Variable  ${cluster1}
   Set Suite Variable  ${cluster2}



Teardown
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Cleanup Provisioning
