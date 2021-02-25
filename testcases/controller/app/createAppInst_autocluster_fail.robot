*** Settings ***
Documentation   CreateAppInst with autocluster failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-2

${region}=  US

*** Test Cases ***
# ECQ-3189
CreateAppInst - User shall not be able to create an autocluster AppInst without default flavor
    [Documentation]
    ...  - send CreateApp without default flavor for docker/k8s/helm
    ...  - send autocluster CreateAppInst
    ...  - verify proper error is received

    [Tags]  ReservableCluster

    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer  use_defaults=${False}
    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"For auto-provisioning or auto-clusters, App must have default flavor defined"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-2  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer  use_defaults=${False}
    ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor
    Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"For auto-provisioning or auto-clusters, App must have default flavor defined"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-3  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer  use_defaults=${False}
    ${error_msg3}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor
    Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"For auto-provisioning or auto-clusters, App must have default flavor defined"}')

# direct not supported
# ECQ-3190
#CreateAppInst - User shall not be able to create an autocluster AppInst with direct access
#    [Documentation]
#    ...  - send CreateApp with direct access
#    ...  - send autocluster CreateAppInst
#    ...  - verify proper error is received
#
#    [Tags]  ReservableCluster
#
#    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=direct
#    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor
#    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"For auto-provisioning or auto-clusters, App access type direct is not supported"}')

# ECQ-3191
CreateAppInst - User shall not be able to create an autocluster VM AppInst
    [Documentation]
    ...  - send CreateApp with deployment=vm
    ...  - send autocluster CreateAppInst
    ...  - verify proper error is received

    [Tags]  ReservableCluster

    # EDGECLOUD-4440  able to do VM CreateAppInst with autocluster and realclustername
    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:8008,tcp:8011
    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autoclustervm  flavor_name=automation_api_flavor 
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"No cluster required for App deployment type vm, cannot use cluster name autocluster which attempts to use or create a ClusterInst"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.1  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeQcow  deployment=vm  access_type=default  image_path=${qcow_centos_image}  access_ports=tcp:8008,tcp:8011
    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autoclustervm  flavor_name=automation_api_flavor
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"No cluster required for App deployment type vm, cannot use cluster name autocluster which attempts to use or create a ClusterInst"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.2  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer  image_path=${qcow_centos_image}  access_ports=tcp:8008,tcp:8011
    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autoclustervm  flavor_name=automation_api_flavor
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"No cluster required for App deployment type vm, cannot use cluster name autocluster which attempts to use or create a ClusterInst"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.3  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:8008,tcp:8011
    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autoclustervm  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"No cluster required for App deployment type vm, cannot use cluster name autocluster which attempts to use or create a ClusterInst"}')

# ECQ-3192
CreateAppInst - User shall not be able to create an AppInst with autocluster_ip_access
    [Documentation]
    ...  - send CreateApp with different deployment types
    ...  - send CreateAppInst with autocluster_ip_access
    ...  - verify proper error is received

    [Tags]  ReservableCluster

    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer 
    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  autocluster_ip_access=1
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid field specified: AutoClusterIpAccess, this field is only for internal use"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-2  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer  
    ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  autocluster_ip_access=1
    Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Invalid field specified: AutoClusterIpAccess, this field is only for internal use"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-3  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer 
    ${error_msg3}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  autocluster_ip_access=1
    Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Invalid field specified: AutoClusterIpAccess, this field is only for internal use"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-4  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:8008,tcp:8011
    ${error_msg4}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autoclustervm  flavor_name=automation_api_flavor  autocluster_ip_access=1
    Should Be Equal  ${error_msg4}  ('code=400', 'error={"message":"Invalid field specified: AutoClusterIpAccess, this field is only for internal use"}')

# ECQ-3201
CreateAppInst - User shall not be able to create an AppInst with reservable cluster already reserved
    [Documentation]
    ...  - send CreateApp with different deployment types
    ...  - send CreateAppInst with real_cluster_name which is already in use
    ...  - verify proper error is received

    [Tags]  ReservableCluster

    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg11}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    ${error_msg12}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=xxx  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    Should Be Equal  ${error_msg11}  ('code=400', 'error={"message":"Specified ClusterInst is already reserved by another AppInst"}')
    Should Be Equal  ${error_msg12}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')
 
    Create App  region=${region}  token=${token}  app_name=${app_name_default}-2  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg21}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    ${error_msg22}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=xxx  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    Should Be Equal  ${error_msg21}  ('code=400', 'error={"message":"Specified ClusterInst is already reserved by another AppInst"}')
    Should Be Equal  ${error_msg22}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-3  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg31}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    ${error_msg32}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=xxx  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    Should Be Equal  ${error_msg31}  ('code=400', 'error={"message":"Specified ClusterInst is already reserved by another AppInst"}')
    Should Be Equal  ${error_msg32}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-4  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg41}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    ${error_msg42}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=xxx  flavor_name=automation_api_flavor  real_cluster_name=reservable0
    Should Be Equal  ${error_msg41}  ('code=400', 'error={"message":"Specified ClusterInst is already reserved by another AppInst"}')
    Should Be Equal  ${error_msg42}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')

# ECQ-3202
CreateAppInst - User shall not be able to create an AppInst with bad real_cluster_name
    [Documentation]
    ...  - send CreateApp with different deployment types
    ...  - send CreateAppInst with real_cluster_name which is already in use
    ...  - verify proper error is received

    [Tags]  ReservableCluster

    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg11}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=xxx
    ${error_msg12}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=xxx  flavor_name=automation_api_flavor  real_cluster_name=xxx
    Should Be Equal  ${error_msg11}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')
    Should Be Equal  ${error_msg12}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-2  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg21}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=xxx
    ${error_msg22}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=xxx  flavor_name=automation_api_flavor  real_cluster_name=xxx
    Should Be Equal  ${error_msg21}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')
    Should Be Equal  ${error_msg22}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-3  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg31}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=xxx
    ${error_msg32}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=xxx  flavor_name=automation_api_flavor  real_cluster_name=xxx
    Should Be Equal  ${error_msg31}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')
    Should Be Equal  ${error_msg32}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')

    Create App  region=${region}  token=${token}  app_name=${app_name_default}-4  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg41}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=xxx
    ${error_msg42}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=xxx  flavor_name=automation_api_flavor  real_cluster_name=xxx
    Should Be Equal  ${error_msg41}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')
    Should Be Equal  ${error_msg42}  ('code=400', 'error={"message":"Specified ClusterInst not found"}')

# ECQ-3203
CreateAppInst - User shall not be able to create a reservable cluster on a mismatched deployment
    [Documentation]
    ...  - send CreateApp/CreateAppInst with different deployment types
    ...  - delete the appinst
    ...  - send CreateApp/CreateAppInst with on the cluster with a different deployment type
    ...  - verify proper error is received

    [Tags]  ReservableCluster

    # create k8s cluster
    Create App  region=${region}  token=${token}  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}  flavor_name=automation_api_flavor   auto_delete=${False}
    Delete App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}  cluster_instance_developer_org_name=MobiledgeX

    # attemt deploy of docker inst in the k8s cluster
    Create App  region=${region}  token=${token}  app_name=${app_name_default}docker  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg11}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=${appinst['data']['real_cluster_name']}
    Should Be Equal  ${error_msg11}  ('code=400', 'error={"message":"Cannot deploy docker App into kubernetes ClusterInst"}')

    # create docker cluster
    Create App  region=${region}  token=${token}  app_name=${app_name_default}-2  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}  flavor_name=automation_api_flavor   auto_delete=${False}
    Delete App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name_default}  cluster_instance_developer_org_name=MobiledgeX

    # attempt deploy of k8s in docker cluster
    Create App  region=${region}  token=${token}  app_name=${app_name_default}-2docker  app_version=1.0  developer_org_name=${developer_org_name_automation}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:8008,tcp:8011  access_type=loadbalancer
    ${error_msg12}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster  flavor_name=automation_api_flavor  real_cluster_name=${appinst['data']['real_cluster_name']}
    Should Be Equal  ${error_msg12}  ('code=400', 'error={"message":"Cannot deploy kubernetes App into docker ClusterInst"}')

*** Keywords ***
Setup
    Create Flavor  region=${region}  #disk=80

    ${token}=  Get Super Token

    ${app_name_default}=  Get Default App Name
    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${token}

