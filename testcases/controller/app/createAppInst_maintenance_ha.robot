*** Settings ***
Documentation   Cloudlet maintenance controller HA tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDmeRest         dme_address=%{AUTOMATION_DME_REST_ADDRESS}

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-2458
AppInst - appinst shall start for k8s/lb/shared app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets
   ...  - create 2 reservable clusterInst with k8s/shared
   ...  - create k8s/lb app with privacy policy
   ...  - verify appinst starts on cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2
   ...  - remove cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add cloudlet2 back to pool
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cloudlet_name1}.${operator_name}.mobiledgex.net  cloudlet2_fqdn=${cloudlet_name2}.${operator_name}.mobiledgex.net

# ECQ-2459
AppInst - appinst shall start for k8s/lb/dedicated app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets
   ...  - create 2 reservable clusterInst with k8s/dedicated
   ...  - create k8s/lb app with privacy policy
   ...  - verify appinst starts on cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2
   ...  - remove cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add cloudlet2 back to pool
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=kubernetes
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=kubernetes

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cluster1}.${cloudlet_name1}.${operator_name}.mobiledgex.net  cloudlet2_fqdn=${cluster2}.${cloudlet_name2}.${operator_name}.mobiledgex.net

# ECQ-2460
AppInst - appinst shall start for docker/lb/dedicated app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets
   ...  - create 2 reservable clusterInst with docker/dedicated
   ...  - create docker/lb app with privacy policy
   ...  - verify appinst starts on cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2
   ...  - remove cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add cloudlet2 back to pool
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cluster1}.${cloudlet_name1}.${operator_name}.mobiledgex.net  cloudlet2_fqdn=${cluster2}.${cloudlet_name2}.${operator_name}.mobiledgex.net

# ECQ-2461
AppInst - appinst shall start for docker/lb/shared app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets
   ...  - create 2 reservable clusterInst with docker/shared
   ...  - create docker/lb app with privacy policy
   ...  - verify appinst starts on cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2
   ...  - remove cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add cloudlet2 back to pool
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=docker
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=docker

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cloudlet_name1}.${operator_name}.mobiledgex.net  cloudlet2_fqdn=${cloudlet_name2}.${operator_name}.mobiledgex.net

# ECQ-2462
AppInst - appinst shall start for docker/direct/dedicated app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets
   ...  - create 2 reservable clusterInst with docker/dedicated
   ...  - create docker/direct app with privacy policy
   ...  - verify appinst starts on cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2
   ...  - remove cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add cloudlet2 back to pool
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cluster1}.${cloudlet_name1}.${operator_name}.mobiledgex.net  cloudlet2_fqdn=${cluster2}.${cloudlet_name2}.${operator_name}.mobiledgex.net

# ECQ-2463
AppInst - appinst shall start for helm/shared/lb app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets
   ...  - create 2 reservable clusterInst with kubernetes/shared
   ...  - create helm/loadbalancer app with privacy policy
   ...  - verify appinst starts on cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2
   ...  - remove cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add cloudlet2 back to pool
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2

   #EDGECLOUD-3540 AutoProv not working for helm

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cloudlet_name1}.${operator_name}.mobiledgex.net  cloudlet2_fqdn=${cloudlet_name2}.${operator_name}.mobiledgex.net

# ECQ-2464
AppInst - appinst shall start for helm/dedicated/lb app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets
   ...  - create 2 reservable clusterInst with kubernetes/dedicated
   ...  - create helm/loadbalancer app with privacy policy
   ...  - verify appinst starts on cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2
   ...  - remove cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add cloudlet2 back to pool
   ...  - put cloudlet1 in maintenance mode
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet2

   #EDGECLOUD-3540 AutoProv not working for helm

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=kubernetes
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=kubernetes

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cluster1}.${cloudlet_name1}.${operator_name}.mobiledgex.net  cloudlet2_fqdn=${cluster2}.${cloudlet_name2}.${operator_name}.mobiledgex.net

# ECQ-2465
AppInst - appinst shall not start for docker/direct/shared app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets and minactiveinstances=1
   ...  - create 2 reservable clusterInst with docker/dedicated
   ...  - set cloudlet2 to maintenance mode
   ...  - create docker/direct app with privacy policy
   ...  - verify appinst starts on cloudlet1
   ...  - update privacy policy with minactiveinstances=2
   ...  - verify appinst does not start on cloudlet2
   ...  - put cloudlet2 in normal operation
   ...  - verify appinst starts on cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker

   # put cloudlet2 in maint mode
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}

   # update policy to include both cloudlet1(not maint mode) and cloudlet2(maint mode). Verify appinst 2 does not start on cloudlet2
   Update Auto Provisioning Policy  region=${region}  developer_org_name=${operator_name}  min_active_instances=2
   App Instance Should Not Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}

   # put cloudlet2 back in operation
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  maintenance_state=NormalOperation

   # verify both appinst exist
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}

   # verify it returns the appinst on the 1st cloudlet
   Register Client  app_name=${app_name_default}  developer_org_name=${operator_name}
   ${cloudlet_1}=  Find Cloudlet      latitude=31  longitude=-91
   #Should Be Equal              ${cloudlet_1['fqdn']}  ${cluster1}.${cloudlet_name1}.${operator_name}.mobiledgex.net
   # it now returns a random order so it could be either cloudlet
   Should Be True              '${cloudlet_1['fqdn']}'=='${cluster1}.${cloudlet_name1}.${operator_name}.mobiledgex.net' or '${cloudlet_1['fqdn']}'=='${cluster1}.${cloudlet_name2}.${operator_name}.mobiledgex.net'


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
   ${app_name_default}=  Get Default App Name

   &{cloudlet1}=  Create Dictionary  name=${cloudlet_name1}  organization=${operator_name}
   &{cloudlet2}=  Create Dictionary  name=${cloudlet_name2}  organization=${operator_name}
   @{cloudlets}=  Create List  ${cloudlet1}  ${cloudlet2}
   ${policy}=  Create Auto Provisioning Policy  region=${region}  developer_org_name=${operator_name}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudlets}
   #Add Auto Provisioning Policy Cloudlet  region=${region}  developer_org_name=${operator_name}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}
   #Add Auto Provisioning Policy Cloudlet  region=${region}  developer_org_name=${operator_name}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}

   @{policy_list}=  Create List  ${policy['data']['key']['name']}

   Set Suite Variable  ${flavor_name_default}
   Set Suite Variable  ${operator_name}
   Set Suite Variable  ${cloudlet_name1}
   Set Suite Variable  ${cloudlet_name2}
   Set Suite Variable  ${cluster1}
   Set Suite Variable  ${app_name_default}
   Set Suite Variable  ${cluster2}
   Set Suite Variable  ${policy}
   Set Suite Variable  @{policy_list}

Teardown
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Cleanup Provisioning

AppInst Should Start When Cloudlet Goes To Maintenance Mode
   [Arguments]  ${cloudlet1_fqdn}  ${cloudlet2_fqdn}

   # appinst will create automatically
#   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  developer_org_name=${operator_name}  cluster_instance_name=${cluster1}  cluster_instance_developer_org_name=MobiledgeX
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}

   # verify it returns the appinst on the 1st cloudlet
   Register Client  app_name=${app_name_default}  developer_org_name=${operator_name}
   ${cloudlet_1}=  Find Cloudlet      latitude=31  longitude=-91
   Should Be Equal              ${cloudlet_1['fqdn']}  ${cloudlet1_fqdn}

   # put cloudlet in maintenance mode
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart

   # appinst should spin up on other cloudlet
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}

   # verify it returns the new cloudlet
   ${cloudlet_2}=  Find Cloudlet      latitude=31  longitude=-91
   Should Be Equal              ${cloudlet_2['fqdn']}  ${cloudlet2_fqdn}

   # remove 2nd cloudlet to remove the 2nd appinst
   Remove Auto Provisioning Policy Cloudlet  region=${region}  developer_org_name=${operator_name}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}
   App Instance Should Not Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}

   # put cloudlet back online
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  maintenance_state=NormalOperation

   # verify it returns the 1st cloudlet
   ${cloudlet_3}=  Find Cloudlet      latitude=31  longitude=-91
   Should Be Equal              ${cloudlet_3['fqdn']}  ${cloudlet1_fqdn}

   # add 2nd cloudlet back
   Add Auto Provisioning Policy Cloudlet  region=${region}  developer_org_name=${operator_name}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}
   App Instance Should Not Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}

   # put cloudlet in maintenance mode no failover
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover

   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}
   App Instance Should Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}

   # verify it returns the new cloudlet
   ${cloudlet_4}=  Find Cloudlet      latitude=31  longitude=-91
   Should Be Equal              ${cloudlet_4['fqdn']}  ${cloudlet2_fqdn}
