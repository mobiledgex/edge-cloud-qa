*** Settings ***
Documentation   Create AppInst with singlekubernetesclusterowner 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String
Library  DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${app_counter}=  ${0}

${region}=  US
${operator_name_fake}=  dmuus

*** Test Cases ***
# ECQ-4366
CreateAppInst - User shall be able to create a k8s/helm appinst on cloudlet with singlekubernetesclusterowner
   [Documentation]
   ...  - create k8s/helm lb appinst on cloudlet with singlekubernetesclusterowner
   ...  - verify app is created

   [Tags]  SingleKubernetesClusterOwner

   [Template]  Create SingleKubernetesClusterOwner AppInst

   image_type=Docker  deployment=kubernetes  access_type=loadbalancer  image_path=${docker_image}       
   image_type=Helm    deployment=helm        access_type=loadbalancer  image_path=${docker_image}   

# ECQ-4367
CreateAppInst - Error shall be received for docker/vm appinst on cloudlet with singlekubernetesclusterowner
   [Documentation]
   ...  - create docker/vm lb appinst on cloudlet with singlekubernetesclusterowner 
   ...  - verify appInst fails with error

   [Tags]  SingleKubernetesClusterOwner

   [Template]  Fail Create AppInst with SingleKubernetesClusterOwner

   error=('code=400', 'error={"message":"Cannot deploy docker app to single kubernetes cloudlet"}')  image_type=Docker  deployment=docker  access_type=loadbalancer  image_path=${docker_image}
   error=('code=400', 'error={"message":"Cannot deploy vm app to single kubernetes cloudlet"}')      image_type=Qcow    deployment=vm        access_type=loadbalancer  image_path=${qcow_centos_image}

# ECQ-4368
CreateAppInst - Error shall be received when realclustername != defaultclust for cloudlet singlekubernetesclusterowner
   [Documentation]
   ...  - create appinst with realclustername != defaultclust on cloudlet with singlekubernetesclusterowner
   ...  - verify appInst fails with error

   [Tags]  SingleKubernetesClusterOwner

   Create App  region=${region}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid RealClusterName for single kubernetes cluster cloudlet, should be left blank"}')   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  real_cluster_name=cluster

# ECQ-4369
CreateAppInst - Error shall be received when clustername = defaultclust for cloudlet singlekubernetesclusterowner
   [Documentation]
   ...  - create appinst with clustername = defaultclust on cloudlet with singlekubernetesclusterowner
   ...  - verify appInst fails with error

   [Tags]  SingleKubernetesClusterOwner

   Create App  region=${region}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cannot use blank or default Cluster name when ClusterInst is required"}')   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=defaultclust

# ECQ-4370
CreateAppInst - Error shall be received for apporg not matching cloudlet singlekubernetesclusterowner
   [Documentation]
   ...  - create appinst with apporg not matching cloudlet singlekubernetesclusterowner on cloudlet with singlekubernetesclusterowner
   ...  - verify appInst fails with error

   [Tags]  SingleKubernetesClusterOwner

   ${org}=  Create Org  orgtype=developer

   Create App  region=${region}  developer_org_name=${org}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"ClusterInst organization must be set to ${developer_org_name_automation}"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${org}

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch

   Create Flavor  region=${region}
   ${appname}=  Set Variable  app${epoch}
 
   ${cloudlet_name}=  Set Variable  cloudlet${epoch}
   ${cluster_name}=  Get Default Cluster Name

   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  platform_type=FakeSingleCluster  single_kubernetes_cluster_owner=${developer_org_name_automation}

   Set Suite Variable  ${appname}  
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}

Create singlekubernetesclusterowner AppInst
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   ${app}=  Create App  region=${region}  app_name=${appname}-${app_counter}  developer_org_name=${developer_org_name_automation}  image_type=${parms['image_type']}  access_type=${parms['access_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016 

   ${cluster_name}=  Catenate  SEPARATOR=-  utocluster  ${appname}  ${app_counter}

   ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name_automation}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${appname}-${app_counter}
   Should Be Equal  ${appinst['data']['real_cluster_name']}    defaultclust

Fail Create AppInst with SingleKubernetesClusterOwner
   [Arguments]  &{parms}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   Create App  region=${region}  app_name=${appname}-${app_counter}  developer_org_name=${developer_org_name_automation}  image_type=${parms['image_type']}  access_type=${parms['access_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016

   ${cluster_name}=  Catenate  SEPARATOR=-  utocluster  ${appname}  ${app_counter}

   Run Keyword and Expect Error  ${parms['error']}   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name_automation}

