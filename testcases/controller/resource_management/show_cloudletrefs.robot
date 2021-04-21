*** Settings ***
Documentation  ShowCloudletRefs for Resource Usage

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US
${developer}=  mobiledgex
${operator_name_fake}=  dmuus
${developer_org_name_automation}=  automation_dev_org
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:9.0
${qcow_centos_image}  https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:8d8f9c268fd419b16084c9ba054b483a
${helm_image}     https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge

*** Test Cases ***
# ECQ-3344
ShowCloudletRefs displays details of appinst/clusterinst
   [Documentation]
   ...  - send CreateTrustPolicy without rules
   ...  - update the policy by adding rules 
   ...  - verify policy is updated

   Create App  region=${region}  app_name=${app_name1}  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015 
   Create App  region=${region}  app_name=${app_name2}  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2015
   Create App  region=${region}  app_name=${app_name3}  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2015
   Create App  region=${region}  app_name=${app_name4}  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeHelm  deployment=helm  image_path=${helm_image}  access_ports=udp:2015

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}  
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}1  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=docker  flavor_name=${flavor}  
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}2  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=kubernetes  flavor_name=${flavor}
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}3  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=kubernetes  flavor_name=${flavor}
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}4  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=helm  flavor_name=${flavor}
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}5  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=helm  flavor_name=${flavor}
   Create App Instance  region=${region}  app_name=${app_name3}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=dummycluster  
   Create App Instance  region=${region}  app_name=${app_name1}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name1}  
   Create App Instance  region=${region}  app_name=${app_name2}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name2}  

   ${cloudletrefs}=  Show CloudletRefs  region=${region}  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}
   Log To Console  ${cloudletrefs}

   ${len}=  Get Length  ${cloudletrefs[0]['data']['cluster_insts']}
   ${index}=  Evaluate  ${len}-2

   FOR  ${x}  IN RANGE  0   ${index} 
      Should Be Equal  ${cloudletrefs[0]['data']['cluster_insts'][${x}]['organization']}  ${developer_org_name_automation}
   END

   Should Be Equal  ${cloudletrefs[0]['data']['cluster_insts'][-1]['organization']}  MobiledgeX

   Should Be Equal  ${cloudletrefs[0]['data']['cluster_insts'][0]['cluster_key']['name']}  ${cluster_name}
   Should Be Equal  ${cloudletrefs[0]['data']['cluster_insts'][1]['cluster_key']['name']}  ${cluster_name}1
   Should Be Equal  ${cloudletrefs[0]['data']['cluster_insts'][2]['cluster_key']['name']}  ${cluster_name}2
   Should Be Equal  ${cloudletrefs[0]['data']['cluster_insts'][3]['cluster_key']['name']}  ${cluster_name}3
   Should Be Equal  ${cloudletrefs[0]['data']['cluster_insts'][4]['cluster_key']['name']}  ${cluster_name}4
   Should Be Equal  ${cloudletrefs[0]['data']['cluster_insts'][5]['cluster_key']['name']}  ${cluster_name}5

   Should Be Equal  ${cloudletrefs[0]['data']['vm_app_insts'][0]['app_key']['name']}  ${app_name3}
   Should Be Equal  ${cloudletrefs[0]['data']['vm_app_insts'][0]['app_key']['organization']}  ${developer_org_name_automation}
   Should Be Equal  ${cloudletrefs[0]['data']['vm_app_insts'][0]['cluster_inst_key']['cluster_key']['name']}  dummycluster
   Should Be Equal  ${cloudletrefs[0]['data']['vm_app_insts'][0]['cluster_inst_key']['organization']}  ${developer_org_name_automation}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${flavor}=  Get Default Flavor Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${cluster_name}=  Get Default Cluster Name
   ${app_name1}=  Get Default App Name
   ${app_name2}=  Catenate  SEPARATOR=  ${app_name1}  1
   ${app_name3}=  Catenate  SEPARATOR=  ${app_name1}  2
   ${app_name4}=  Catenate  SEPARATOR=  ${app_name1}  3

   Create Flavor  region=${region}
   Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

   Set Suite Variable  ${token}
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}
   Set Suite Variable  ${app_name1}
   Set Suite Variable  ${app_name2}
   Set Suite Variable  ${app_name3}
   Set Suite Variable  ${app_name4}
   Set Suite Variable  ${flavor}

Teardown
   Cleanup Provisioning
   Delete Idle Reservable Cluster Instances  region=${region}
