*** Settings ***
Documentation   CreateAppInst Reservable Cluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown   Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1
${qcow_centos_image}  qcowimage

${region}=  US

*** Test Cases ***
CreateAppInst - deployment with autocluster shall create reservable cluster
   [Documentation]
   ...  create an App/AppInstance with autocluster for various deployment types
   ...  verify reservable cluster is created

  [Template]  Reservable Cluster Should Be Created

  developer_org_name=MobiledgeX  deployment=docker      image_type=ImageTypeDocker  image_path=${docker_image}
  developer_org_name=MobiledgeX  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}
  developer_org_name=MobiledgeX  deployment=helm        image_type=ImageTypeHelm    image_path=${docker_image}

  developer_org_name=automation_dev_org  deployment=docker      image_type=ImageTypeDocker  image_path=${docker_image}
  developer_org_name=automation_dev_org  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}
  developer_org_name=automation_dev_org  deployment=helm        image_type=ImageTypeHelm    image_path=${docker_image}

*** Keywords ***
Setup
    #Create Flavor  region=${region}

    ${app_name_default}=  Get Default App Name
    ${app_version_default}=  Get Default App Version
    ${developer_name_default}=  Get Default Developer Name
    ${flavor_name_default}=  Get Default Flavor Name
  
    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${app_version_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${flavor_name_default}

Reservable Cluster Should Be Created
   [Arguments]  ${developer_org_name}  ${deployment}  ${image_type}  ${image_path}

   [Teardown]  Cleanup Provisioning

   Create Flavor  region=${region}

   Create App  region=${region}   developer_org_name=${developer_org_name}  deployment=${deployment}  image_type=${image_type}  image_path=${image_path}  access_ports=tcp:1

   ${app_inst}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}

   ${cluster_inst}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst}  1

   ${uri}=  Run Keyword If  '${deployment}' == 'docker'  Set Variable  ${app_inst['data']['real_cluster_name']}.${cloudlet_name}.${operator_name}.mobiledgex.net
   ...  ELSE  Set Variable  ${cloudlet_name}.${operator_name}.mobiledgex.net

   Should Be Equal  ${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  autocluster${app_name_default}
   Should Match Regexp  ${app_inst['data']['real_cluster_name']}  ^reservable\\d$
   Should Be Equal  ${app_inst['data']['uri']}  ${uri}  #${app_inst['data']['real_cluster_name']}.${cloudlet_name}.${operator_name}.mobiledgex.net

