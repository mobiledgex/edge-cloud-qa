*** Settings ***
Documentation   DeleteIdleReservableClusterInst

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3198
DeleteIdleReservableClusterInst - shall be able to delete idle cluster instances
   [Documentation]
   ...  - create 3 reservable clusters
   ...  - delete idle clusters and verify none are deleted
   ...  - delete 1 of the app instances
   ...  - delete idle clusters and verify only 1 is deleted
   ...  - delete the other 2 app instances
   ...  - delete idle clusters and verify the othe 2 are deleted 

   [Tags]  ReservableCluster

   Create App  region=${region}   app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-1  auto_delete=${False}

   Create App  region=${region}   app_name=${app_name_default}-2  developer_org_name=${developer_org_name_automation}  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-2  auto_delete=${False}

   Create App  region=${region}   app_name=${app_name_default}-3  developer_org_name=${developer_org_name_automation}  deployment=helm  image_type=ImageTypeHelm  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst3}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-3  auto_delete=${False}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Delete Idle Reservable Cluster Instances  region=${region}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Delete App Instance  region=${region}  app_name=${app_name_default}-2  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-2  cluster_instance_developer_org_name=MobiledgeX

   Delete Idle Reservable Cluster Instances  region=${region}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  0
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Delete App Instance  region=${region}  app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-1  cluster_instance_developer_org_name=MobiledgeX
   Delete App Instance  region=${region}  app_name=${app_name_default}-3  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-3  cluster_instance_developer_org_name=MobiledgeX

   Delete Idle Reservable Cluster Instances  region=${region}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  0
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  0
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  0

   Delete Idle Reservable Cluster Instances  region=${region}

# ECQ-3199
DeleteIdleReservableClusterInst - shall be able to delete idle cluster instances with idletime
   [Documentation]
   ...  - create 3 reservable clusters
   ...  - delete idle clusters and verify none are deleted
   ...  - delete 1 of the app instances
   ...  - wait 10s and delete idle clusters with 30s and verify none are deleted
   ...  - wait 30s and delete idle clusters with 30s and verify 1 cluster is deleted
   ...  - delete the other 2 app instances
   ...  - wait 40s and delete idle clusters with 1m and verify none are deleted
   ...  - wait 60s and delete idle clusters with 1m and verify 2 are deleted

   [Tags]  ReservableCluster

   Create App  region=${region}   app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-1  auto_delete=${False}

   Create App  region=${region}   app_name=${app_name_default}-2  developer_org_name=${developer_org_name_automation}  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-2  auto_delete=${False}

   Create App  region=${region}   app_name=${app_name_default}-3  developer_org_name=${developer_org_name_automation}  deployment=helm  image_type=ImageTypeHelm  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst3}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-3  auto_delete=${False}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Delete Idle Reservable Cluster Instances  region=${region}  idle_time=30s

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Delete App Instance  region=${region}  app_name=${app_name_default}-2  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-2  cluster_instance_developer_org_name=MobiledgeX

   Sleep  10s

   Delete Idle Reservable Cluster Instances  region=${region}  idle_time=30s

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Sleep  30s

   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1

   Delete Idle Reservable Cluster Instances  region=${region}  idle_time=30s

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  0
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Delete App Instance  region=${region}  app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-1  cluster_instance_developer_org_name=MobiledgeX
   Delete App Instance  region=${region}  app_name=${app_name_default}-3  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-3  cluster_instance_developer_org_name=MobiledgeX

   Sleep  10s

   Delete Idle Reservable Cluster Instances  region=${region}  idle_time=1m

   Sleep  30s

   Delete Idle Reservable Cluster Instances  region=${region}  idle_time=1m

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  0
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Sleep  60s

   Delete Idle Reservable Cluster Instances  region=${region}  idle_time=1m

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  0
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  0
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  0

   Delete Idle Reservable Cluster Instances  region=${region}  idle_time=0

# ECQ-3200
DeleteIdleReservableClusterInst - settings timer cleanup_reservable_auto_cluster_idletime shall delete idle cluster instances
   [Documentation]
   ...  - set cleanup_reservable_auto_cluster_idletime=10s
   ...  - create 3 reservable clusters
   ...  - delete 1 of the app instances
   ...  - wait for timeer to pop and verify only 1 is deleted
   ...  - delete the other 2 app instances
   ...  - wait for timeer to pop and verify other 2 are deleted

   [Tags]  ReservableCluster

   [Setup]  Settings Setup
   [Teardown]  Settings Teardown

   Update Settings  region=${region}  cleanup_reservable_auto_cluster_idletime=10s

   Create App  region=${region}   app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-1  auto_delete=${False}

   Create App  region=${region}   app_name=${app_name_default}-2  developer_org_name=${developer_org_name_automation}  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-2  auto_delete=${False}

   Create App  region=${region}   app_name=${app_name_default}-3  developer_org_name=${developer_org_name_automation}  deployment=helm  image_type=ImageTypeHelm  image_path=${docker_image}  access_ports=tcp:1
   ${app_inst3}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-3  auto_delete=${False}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Delete App Instance  region=${region}  app_name=${app_name_default}-2  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-2  cluster_instance_developer_org_name=MobiledgeX

   Sleep  3m

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  0
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  1

   Delete App Instance  region=${region}  app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-1  cluster_instance_developer_org_name=MobiledgeX
   Delete App Instance  region=${region}  app_name=${app_name_default}-3  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}-3  cluster_instance_developer_org_name=MobiledgeX

   Sleep  15s

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  0
   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst2['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  0
   ${cluster_inst3}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst3['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst3}  0

*** Keywords ***
Setup
   Create Flavor  region=${region}

   ${app_name_default}=  Get Default App Name

   Set Suite Variable  ${app_name_default}

Settings Setup
   Setup

   ${settings}=   Show Settings  region=${region}

   Set Suite Variable  ${settings}

Settings Teardown
   Cleanup Provisioning
   Update Settings  region=${region}  cleanup_reservable_auto_cluster_idletime=${settings['cleanup_reservable_auto_cluster_idletime']}

Teardown
   Cleanup Provisioning

