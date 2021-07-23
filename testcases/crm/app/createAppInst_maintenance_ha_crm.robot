*** Settings ***
Documentation   Openstack CRM cloudlet maintenance tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDmeRest         dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library  String

#Test Setup  Setup
#Test Teardown  Teardown

Test Timeout  ${test_timeout_crm}

*** Variables ***
${region}=  EU
${appinst_timeout}=  600

*** Test Cases ***
# ECQ-2550
AppInst - appinst shall start for k8s/lb/shared app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 openstack cloudlets
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

   [Setup]     Setup     cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}
   [Teardown]  Teardown  cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name_openstack_ha1}  operator_org_name=${operator_name_openstack}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name_openstack_ha2}  operator_org_name=${operator_name_openstack}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   #AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cloudlet_name_openstack_ha1}.${operator_name_openstack}.mobiledgex.net  cloudlet2_fqdn=${cloudlet_name_openstack_ha2}.${operator_name_openstack}.mobiledgex.net

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet1_fqdn=shared.${cloudlet_name_openstack_ha1}.${operator_name_openstack}.mobiledgex.net  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}  cloudlet2_fqdn=shared.${cloudlet_name_openstack_ha2}.${operator_name_openstack}.mobiledgex.net

# ECQ-2551
AppInst - appinst shall start for docker/lb/dedicated app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 openstack cloudlets
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

   [Setup]     Setup     cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}
   [Teardown]  Teardown  cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name_openstack_ha1}  operator_org_name=${operator_name_openstack}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name_openstack_ha2}  operator_org_name=${operator_name_openstack}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   #AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cluster1}.${cloudlet_name_openstack_ha1}.${operator_name_openstack}.mobiledgex.net  cloudlet2_fqdn=${cluster2}.${cloudlet_name_openstack_ha2}.${operator_name_openstack}.mobiledgex.net

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet1_fqdn=${cluster1}.${cloudlet_name_openstack_ha1}.${operator_name_openstack}.mobiledgex.net  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}  cloudlet2_fqdn=${cluster2}.${cloudlet_name_openstack_ha2}.${operator_name_openstack}.mobiledgex.net

# ECQ-2552
AppInst - appinst shall start for helm/dedicated/lb app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 openstack cloudlets
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

   [Setup]     Setup     cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}
   [Teardown]  Teardown  cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name_openstack_ha1}  operator_org_name=${operator_name_openstack}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=kubernetes
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name_openstack_ha2}  operator_org_name=${operator_name_openstack}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=kubernetes

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1_fqdn=${cluster1}.${cloudlet_name_openstack_ha1}.${operator_name_openstack}.mobiledgex.net  cloudlet2_fqdn=${cluster2}.${cloudlet_name_openstack_ha2}.${operator_name_openstack}.mobiledgex.net  cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha2}  operator2=${operator_name_openstack}

# ECQ-2553
AppInst - openstack-to-vmpool appinst shall start for docker/direct/dedicated app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets. 1 in openstack and 1 on vmpool
   ...  - create 2 reservable clusterInst with docker/dedicated
   ...  - create docker/direct app with privacy policy
   ...  - verify appinst starts on openstack cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on openstack cloudlet1
   ...  - put openstack cloudlet1 in maintenance mode
   ...  - verify appinst starts on vmpool cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on vmpool cloudlet2
   ...  - remove vmpool cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add vmpool cloudlet2 back to pool
   ...  - put openstack cloudlet1 in maintenance mode
   ...  - verify appinst starts on vmpool cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on vmpool cloudlet2

   [Setup]     Setup     cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_vmpool}  operator2=${operator_name_openstack}
   [Teardown]  Teardown  cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_vmpool}  operator2=${operator_name_openstack} 

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name_openstack_ha1}  operator_org_name=${operator_name_openstack}  developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name_vmpool}    operator_org_name=${operator_name_openstack}    developer_org_name=MobiledgeX  ip_access=IpAccessDedicated  deployment=docker

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1=${cloudlet_name_openstack_ha1}  operator1=${operator_name_openstack}  cloudlet1_fqdn=${cluster1}.${cloudlet_name_openstack_ha1}.${operator_name_openstack}.mobiledgex.net  cloudlet2=${cloudlet_name_vmpool}  operator2=${operator_name_openstack}  cloudlet2_fqdn=${cluster2}.${cloudlet_name_vmpool}.${operator_name_openstack}.mobiledgex.net

# ECQ-2554
AppInst - vmpool-to-openstack appinst shall start for k8s/lb/shared app inst when cloudlet is maintenance mode
   [Documentation]
   ...  - create privacy policy with 2 cloudlets. 1 in vmpool and 1 on openstack
   ...  - create 2 reservable clusterInst with k8s/shared 
   ...  - create k8s/lb app with privacy policy
   ...  - verify appinst starts on vmpool cloudlet1
   ...  - verify RegisterClient/FindCloudlet returns appinst on vmpool cloudlet1
   ...  - put vmpool cloudlet1 in maintenance mode
   ...  - verify appinst starts on openstack cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on openstack cloudlet2
   ...  - remove openstack cloudlet2 from pool and bring cloudlet1 back online
   ...  - verify RegisterClient/FindCloudlet returns appinst on cloudlet1
   ...  - add openstack cloudlet2 back to pool
   ...  - put vmpool cloudlet1 in maintenance mode
   ...  - verify appinst starts on openstack cloudlet2
   ...  - verify RegisterClient/FindCloudlet returns appinst on openstack cloudlet2

   [Setup]     Setup     cloudlet1=${cloudlet_name_vmpool}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha1}  operator2=${operator_name_openstack}
   [Teardown]  Teardown  cloudlet1=${cloudlet_name_vmpool}  operator1=${operator_name_openstack}  cloudlet2=${cloudlet_name_openstack_ha1}  operator2=${operator_name_openstack}

   Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_openstack}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes
   Create Cluster Instance  region=${region}  cluster_name=${cluster2}  reservable=${True}   cloudlet_name=${cloudlet_name_openstack_ha1}    operator_org_name=${operator_name_openstack}    developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes

   Create App  region=${region}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   AppInst Should Start When Cloudlet Goes To Maintenance Mode  cloudlet1=${cloudlet_name_vmpool}  operator1=${operator_name_openstack}  cloudlet1_fqdn=shared.${cloudlet_name_vmpool}.${operator_name_openstack}.mobiledgex.net  cloudlet2=${cloudlet_name_openstack_ha1}  operator2=${operator_name_openstack}  cloudlet2_fqdn=shared.${cloudlet_name_openstack_ha1}.${operator_name_openstack}.mobiledgex.net

*** Keywords ***
Setup
   [Arguments]  ${cloudlet1}  ${operator1}  ${cloudlet2}  ${operator2}

   Create Flavor  region=${region}

   ${cluster_name}=  Get Default Cluster Name
   ${cluster1}=  Catenate  SEPARATOR=  ${cluster_name}  1
   ${cluster2}=  Catenate  SEPARATOR=  ${cluster_name}  2

   #Create Org

   ${operator_name}=  Get Default Developer Name
   ${flavor_name_default}=  Get Default Flavor Name
   ${app_name_default}=  Get Default App Name

   &{cloudlet1}=  Create Dictionary  name=${cloudlet1}  organization=${operator1}
   &{cloudlet2}=  Create Dictionary  name=${cloudlet2}  organization=${operator2}
   @{cloudlets}=  Create List  ${cloudlet1}  ${cloudlet2}
   ${policy}=  Create Auto Provisioning Policy  region=${region}  developer_org_name=${operator_name}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudlets}
   @{policy_list}=  Create List  ${policy['data']['key']['name']}

   Set Suite Variable  ${flavor_name_default}
   Set Suite Variable  ${operator_name}
   Set Suite Variable  ${cluster1}
   Set Suite Variable  ${app_name_default}
   Set Suite Variable  ${cluster2}
   Set Suite Variable  ${policy}
   Set Suite Variable  @{policy_list}

Teardown
   [Arguments]  ${cloudlet1}  ${operator1}  ${cloudlet2}  ${operator2}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet1}  operator_org_name=${operator1}  maintenance_state=NormalOperation
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet2}  operator_org_name=${operator1}  maintenance_state=NormalOperation
   Cleanup Provisioning

AppInst Should Start When Cloudlet Goes To Maintenance Mode
   [Arguments]  ${cloudlet1}  ${cloudlet1_fqdn}  ${operator1}  ${cloudlet2}  ${cloudlet2_fqdn}  ${operator2}

   ${cloudlet1_fqdn}=  Convert To Lowercase  ${cloudlet1_fqdn}
   ${cloudlet2_fqdn}=  Convert To Lowercase  ${cloudlet2_fqdn}

   # appinst will create automatically
   Wait For App Instance To Be Ready   region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet1}  timeout=${appinst_timeout}

   # verify it returns the appinst on the 1st cloudlet
   Register Client  app_name=${app_name_default}  developer_org_name=${operator_name}
   ${findcloudlet_1}=  Find Cloudlet      latitude=31  longitude=-91
   Should Be Equal              ${findcloudlet_1['fqdn']}  ${cloudlet1_fqdn}

   # put cloudlet in maintenance mode
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet1}  operator_org_name=${operator1}  maintenance_state=MaintenanceStart

   # appinst should spin up on other cloudlet
   App Instance Should Exist           region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet1}  operator_org_name=${operator1}
   Wait For App Instance To Be Ready   region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet2}  operator_org_name=${operator2}  timeout=${appinst_timeout}

   # verify it returns the new cloudlet
   ${findcloudlet_2}=  Find Cloudlet      latitude=31  longitude=-91
   Should Be Equal              ${findcloudlet_2['fqdn']}  ${cloudlet2_fqdn}

   # remove 2nd cloudlet to remove the 2nd appinst
   Remove Auto Provisioning Policy Cloudlet  region=${region}  developer_org_name=${operator_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator2}
   App Instance Should Exist             region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet1}  operator_org_name=${operator1}
   Wait For App Instance To Be Deleted   region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet2}  operator_org_name=${operator2}  timeout=${appinst_timeout}

   # put cloudlet back online
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet1}  operator_org_name=${operator1}  maintenance_state=NormalOperation

   # verify it returns the 1st cloudlet
   ${findcloudlet_3}=  Find Cloudlet      latitude=31  longitude=-91
   Should Be Equal              ${findcloudlet_3['fqdn']}  ${cloudlet1_fqdn}

   # add 2nd cloudlet back
   Add Auto Provisioning Policy Cloudlet  region=${region}  developer_org_name=${operator_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator2}
   App Instance Should Exist      region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet1}  operator_org_name=${operator1}
   App Instance Should Not Exist  region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet2}  operator_org_name=${operator2}

   # put cloudlet in maintenance mode no failover
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet1}  operator_org_name=${operator1}  maintenance_state=MaintenanceStartNoFailover

   App Instance Should Exist           region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet1}  operator_org_name=${operator1}
   Wait For App Instance To Be Ready   region=${region}  app_name=${app_name_default}  cloudlet_name=${cloudlet2}  operator_org_name=${operator2}  timeout=${appinst_timeout}

   # verify it returns the new cloudlet
   ${findcloudlet_4}=  Find Cloudlet      latitude=31  longitude=-91
   Should Be Equal              ${findcloudlet_4['fqdn']}  ${cloudlet2_fqdn}

