*** Settings ***
Documentation   CreateAppInst Reservable Cluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup	Setup
Test Teardown   Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1
${qcow_centos_image}  qcowimage

${region}=  US

*** Test Cases ***
# ECQ-3204
CreateAppInst - deployment with autocluster shall create reservable cluster
   [Documentation]
   ...  - create an App/AppInstance with autocluster for various deployment types
   ...  - verify reservable cluster is created

   [Tags]  ReservableCluster

   [Template]  Reservable Cluster Should Be Created

   developer_org_name=MobiledgeX  deployment=docker      access_type=${None}  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=MobiledgeX  deployment=kubernetes  access_type=${None}  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=MobiledgeX  deployment=helm        access_type=${None}  image_type=ImageTypeHelm    image_path=${docker_image}
 
   developer_org_name=automation_dev_org  deployment=docker      access_type=${None}  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=kubernetes  access_type=${None}  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=helm        access_type=${None}  image_type=ImageTypeHelm    image_path=${docker_image}

   developer_org_name=automation_dev_org  deployment=docker      access_type=loadbalancer  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=kubernetes  access_type=loadbalancer  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=helm        access_type=loadbalancer  image_type=ImageTypeHelm    image_path=${docker_image}

   developer_org_name=automation_dev_org  deployment=docker      access_type=default  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=kubernetes  access_type=default  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=helm        access_type=default  image_type=ImageTypeHelm    image_path=${docker_image}

# ECQ-3205
CreateAppInst - delete autocluster appinst shall not delete reservable cluster
   [Documentation]
   ...  - create an App/AppInstance with autocluster for various deployment types
   ...  - verify reservable cluster is created
   ...  - delete the appinst
   ...  - verify reservable cluster is not deleted

   [Tags]  ReservableCluster

   [Template]  DeleteAppInst Should Not Delete Reservable Cluster

   developer_org_name=automation_dev_org  deployment=docker      image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=helm        image_type=ImageTypeHelm    image_path=${docker_image}

# ECQ-3206
CreateAppInst - reservable clusters shall be able to be reused
   [Documentation]
   ...  - create an App/AppInstance with autocluster for various deployment types
   ...  - verify reservable cluster is created
   ...  - delete and recreate the appinst
   ...  - verify the same reserable cluster is used

   [Tags]  ReservableCluster

   [Template]  Reservable Cluster Shall Be Reused

   developer_org_name=automation_dev_org  deployment=docker      image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=helm        image_type=ImageTypeHelm    image_path=${docker_image}

# ECQ-3207
CreateAppInst - shall be able to create multiple reservable clusters
   [Documentation]
   ...  - create multiple App/AppInstances with autocluster for various deployment types
   ...  - verify all reservable cluster are created

   [Tags]  ReservableCluster

   [Template]  Shall Create Multiple Reservable Clusters

   developer_org_name=automation_dev_org  deployment=docker      image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}
   developer_org_name=automation_dev_org  deployment=helm        image_type=ImageTypeHelm    image_path=${docker_image}

# ECQ-3208
CreateAppInst - shall be able to create app inst with real_cluster_name
   [Documentation]
   ...  - create an App/AppInstance with autocluster for various deployment types
   ...  - verify reservable cluster is created
   ...  - delete the appinst
   ...  - recreate the appinst using the real_cluster_name parm
   ...  - verify cluster is created on the cluster specified

   [Tags]  ReservableCluster

   [Template]  Shall CreatAppInst with Real Cluster Name

   #cluster_name=autocluster${app_name_default}  developer_org_name=automation_dev_org  deployment=docker      image_type=ImageTypeDocker  image_path=${docker_image}
   #cluster_name=autocluster${app_name_default}  developer_org_name=automation_dev_org  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}
   #cluster_name=autocluster${app_name_default}  developer_org_name=automation_dev_org  deployment=helm        image_type=ImageTypeHelm    image_path=${docker_image}

   cluster_name=cluster${app_name_default}  developer_org_name=automation_dev_org  deployment=docker      image_type=ImageTypeDocker  image_path=${docker_image}
   cluster_name=cluster${app_name_default}  developer_org_name=automation_dev_org  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}
   cluster_name=cluster${app_name_default}  developer_org_name=automation_dev_org  deployment=helm        image_type=ImageTypeHelm    image_path=${docker_image}

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

Shall CreatAppInst with Real Cluster Name
   [Arguments]  ${cluster_name}  ${developer_org_name}  ${deployment}  ${image_type}  ${image_path}

   [Teardown]  Cleanup Provisioning

   Create Flavor  region=${region}

   Create App  region=${region}   developer_org_name=${developer_org_name}  deployment=${deployment}  image_type=${image_type}  image_path=${image_path}  access_ports=tcp:1

   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}  auto_delete=${False}
   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}-2  auto_delete=${False}
   Delete App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}  cluster_instance_developer_org_name=MobiledgeX
   Delete App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}-2  cluster_instance_developer_org_name=MobiledgeX

   ${app_inst3}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${app_inst2['data']['real_cluster_name']}  cluster_instance_developer_org_name=MobiledgeX  real_cluster_name=${app_inst2['data']['real_cluster_name']}  auto_delete=${False}
   Delete App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${app_inst2['data']['real_cluster_name']}  cluster_instance_developer_org_name=MobiledgeX

   ${app_inst4}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${app_inst1['data']['real_cluster_name']}  cluster_instance_developer_org_name=MobiledgeX  real_cluster_name=${app_inst1['data']['real_cluster_name']}  

   Delete Cluster Instance  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX

   Should Be Equal  ${app_inst3['data']['real_cluster_name']}  ${app_inst2['data']['real_cluster_name']}
   Should Be Equal  ${app_inst4['data']['real_cluster_name']}  ${app_inst1['data']['real_cluster_name']}

Shall Create Multiple Reservable Clusters
   [Arguments]  ${developer_org_name}  ${deployment}  ${image_type}  ${image_path}

   [Teardown]  Cleanup Provisioning

   Create Flavor  region=${region}

   Create App  region=${region}   developer_org_name=${developer_org_name}  deployment=${deployment}  image_type=${image_type}  image_path=${image_path}  access_ports=tcp:1

   ${app_inst}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}
   Should Match Regexp  ${app_inst['data']['real_cluster_name']}  reservable[0-9]
   ${cluster_num}=  Split String  ${app_inst['data']['real_cluster_name']}  separator=reservable

   ${num_clusters}=  Set Variable  2
   ${start}=  Evaluate  ${cluster_num[1]}+${1}
   ${end}=  Evaluate  ${start}+${num_clusters}

   FOR  ${x}  IN RANGE  ${start}  ${end}
      ${app_instx}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}-${x} 
      Should Match Regexp  ${app_instx['data']['real_cluster_name']}  reservable[0-9]
 
      Should Be Equal  ${app_instx['data']['real_cluster_name']}  reservable${x}

      ${cluster_inst}=  Show Cluster Instances  region=${region}  cluster_name=${app_instx['data']['real_cluster_name']}  developer_org_name=MobiledgeX
      Length Should Be  ${cluster_inst}  1
   END

Reservable Cluster Shall Be Reused
   [Arguments]  ${developer_org_name}  ${deployment}  ${image_type}  ${image_path}

   [Teardown]  Cleanup Provisioning

   Create Flavor  region=${region}

   Create App  region=${region}   developer_org_name=${developer_org_name}  deployment=${deployment}  image_type=${image_type}  image_path=${image_path}  access_ports=tcp:1

   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}  auto_delete=${False}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   Should Be True  ${cluster_inst1[0]['data']['reservable']}
   Should Be Equal  ${cluster_inst1[0]['data']['reserved_by']}  ${developer_org_name_automation}
   Should Be True  ${cluster_inst1[0]['data']['reservation_ended_at']['seconds']} > 0
   Should Be True  ${cluster_inst1[0]['data']['reservation_ended_at']['nanos']} > 0

   Delete App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}  cluster_instance_developer_org_name=MobiledgeX

   ${cluster_inst11}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst11}  1
   Dictionary Should Not Contain Key  ${cluster_inst11[0]['data']}  reserved_by
   Should Be True  ${cluster_inst11[0]['data']['reservation_ended_at']['seconds']} > ${cluster_inst1[0]['data']['reservation_ended_at']['seconds']}
   Should Be True  ${cluster_inst11[0]['data']['reservation_ended_at']['nanos']} > 0
   Should Be True  ${cluster_inst11[0]['data']['created_at']['seconds']} == ${cluster_inst1[0]['data']['created_at']['seconds']}
   Should Be True  ${cluster_inst11[0]['data']['created_at']['nanos']} == ${cluster_inst1[0]['data']['created_at']['nanos']}

   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default} 
   Should Be Equal  ${app_inst1['data']['real_cluster_name']}  ${app_inst2['data']['real_cluster_name']}

   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   Should Be True  ${cluster_inst2[0]['data']['reservable']}
   Should Be Equal  ${cluster_inst2[0]['data']['reserved_by']}  ${cluster_inst1[0]['data']['reserved_by']}
   Should Be True  ${cluster_inst2[0]['data']['reservation_ended_at']['seconds']} == ${cluster_inst11[0]['data']['reservation_ended_at']['seconds']}
   Should Be True  ${cluster_inst2[0]['data']['reservation_ended_at']['nanos']} == ${cluster_inst11[0]['data']['reservation_ended_at']['nanos']}

DeleteAppInst Should Not Delete Reservable Cluster
   [Arguments]  ${developer_org_name}  ${deployment}  ${image_type}  ${image_path}

   [Teardown]  Cleanup Provisioning

   Create Flavor  region=${region}

   Create App  region=${region}   developer_org_name=${developer_org_name}  deployment=${deployment}  image_type=${image_type}  image_path=${image_path}  access_ports=tcp:1

   ${app_inst}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}  auto_delete=${False}

   ${cluster_inst}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst}  1

   ${uri}=  Run Keyword If  '${deployment}' == 'docker'  Set Variable  ${app_inst['data']['real_cluster_name']}.${cloudlet_name}.${operator_name}.mobiledgex.net
   ...  ELSE  Set Variable  shared.${cloudlet_name}.${operator_name}.mobiledgex.net

   Should Be Equal  ${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  autocluster${app_name_default}
   Should Match Regexp  ${app_inst['data']['real_cluster_name']}  ^reservable\\d$
   Should Be Equal  ${app_inst['data']['uri']}  ${uri}  #${app_inst['data']['real_cluster_name']}.${cloudlet_name}.${operator_name}.mobiledgex.net

   Delete App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}  cluster_instance_developer_org_name=MobiledgeX

   ${cluster_inst_post}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst_post}  1
   Dictionary Should Not Contain Key  ${cluster_inst_post[0]['data']}  reserved_by

   Delete Cluster Instance  region=${region}  cluster_name=${app_inst['data']['real_cluster_name']}  developer_org_name=MobiledgeX

Reservable Cluster Should Be Created
   [Arguments]  ${developer_org_name}  ${deployment}  ${access_type}  ${image_type}  ${image_path}

   [Teardown]  Cleanup Provisioning

   Create Flavor  region=${region}

   Create App  region=${region}   developer_org_name=${developer_org_name}  deployment=${deployment}  access_type=${access_type}  image_type=${image_type}  image_path=${image_path}  access_ports=tcp:1

   ${app_inst}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${app_name_default}

   ${cluster_inst}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst}  1

   ${uri}=  Run Keyword If  '${deployment}' == 'docker'  Set Variable  ${app_inst['data']['real_cluster_name']}.${cloudlet_name}.${operator_name}.mobiledgex.net
   ...  ELSE  Set Variable  shared.${cloudlet_name}.${operator_name}.mobiledgex.net

   Should Be Equal  ${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  autocluster${app_name_default}
   Should Match Regexp  ${app_inst['data']['real_cluster_name']}  ^reservable\\d$
   Should Be Equal  ${app_inst['data']['uri']}  ${uri}  #${app_inst['data']['real_cluster_name']}.${cloudlet_name}.${operator_name}.mobiledgex.net
   
   Should Be True  ${cluster_inst[0]['data']['reservable']}  
   Should Be Equal  ${cluster_inst[0]['data']['reserved_by']}  ${developer_org_name}
   Should Be True   ${cluster_inst[0]['data']['reservation_ended_at']['nanos']} > 0
   Should Be True   ${cluster_inst[0]['data']['reservation_ended_at']['seconds']} > 0
 

