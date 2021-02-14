*** Settings ***
Documentation   CreateAppInst 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
AppInst - autocluster shall be created when app instance is created with clustername='autocluster'
    [Documentation]
    ...  create an app instance with cluster name of 'autocluster'
    ...  verify autocluster is created in cluster instance table
    ...  delete the app instance
    ...  verify autocluster is deleted from cluster instance table

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}

    Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}

    Show Cluster Instances
    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_name_default}  liveness=LivenessDynamic

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}	
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}	
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}	
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.organization}       ${operator_name}	
    Should Be Equal              ${clusterInst[0].key.organization}                    ${developer_name_default}

    Length Should Be   ${clusterInst}  1
    #sleep  5s

# not supported anymore since cluster inst developer is now required for reservable clusters
#AppInst - autocluster shall be created when app instance is created with clustername='autocluster' and no developer
#    [Documentation]
#    ...  create an app instance with cluster name of 'autocluster' and no developer
#    ...  verify autocluster is created in cluster instance table
#    ...  delete the app instance
#    ...  verify autocluster is deleted from cluster instance table
#
#    ${epoch_time}=  Get Time  epoch
#
#    ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}
#
#    ${appInst}=  Create App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_org_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}  use_defaults=${False}  no_auto_delete=${True}
#
#    Show Cluster Instances
#    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_name_default}  liveness=LivenessDynamic
#    ${cluster_name}=  Set Variable  ${clusterInst[0].key.cluster_key.name}
#
#    Should Be Equal              ${appInst.key.app_key.organization}             ${developer_name_default}
#    Should Be Equal              ${appInst.key.cluster_inst_key.organization}             ${developer_name_default}
#
#    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2  # LivenessDynamic
#    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}
#    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}
#    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}
#    Should Be Equal              ${clusterInst[0].key.cloudlet_key.organization}  ${operator_name}
#    Should Be Equal              ${clusterInst[0].key.organization}                       ${developer_name_default}
#
#    Length Should Be   ${clusterInst}  1
#
#    Delete App Instance  app_name=${app_name_default}  developer_org_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_developer_org_name=${developer_name_default}  cluster_instance_name=${cluster_name}
    

AppInst - appinst shall be created when app instance is created without cluster developer
    [Documentation]
    ...  create an app instance with cluster name and no cluster developer
    ...  verify appinst is created with cluster developer

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  cluster  ${epoch_time}

    Create Cluster Instance  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  no_auto_delete=${True}

    ${appInst}=  Create App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_org_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}  use_defaults=${False}  no_auto_delete=${True}

    Show Cluster Instances
    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_name_default}  liveness=LivenessStatic

    Delete App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_org_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}
    Delete Cluster Instance  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

    Should Be Equal              ${appInst.key.app_key.organization}             ${developer_name_default}
    Should Be Equal              ${appInst.key.cluster_inst_key.organization}             ${developer_name_default}

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            1  # LivenessStatic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.organization}  ${operator_name}
    Should Be Equal              ${clusterInst[0].key.organization}                       ${developer_name_default}

    Length Should Be   ${clusterInst}  1

AppInst - appinst shall be created when app instance is created with auto-cluster and autoclusteripaccess=IpAccessDedicated
    [Documentation]
    ...  create an app instance with autocluster and autoclusteripaccess=IpAccessDedicated 
    ...  verify appinst is created with autocluster with ipaccess=IpAccessDedicated

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}

    ${appInst}=  Create App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_org_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}  autocluster_ip_access=IpAccessDedicated

    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_name_default}  use_defaults=${False}

    Should Be Equal              ${appInst.key.app_key.organization}             ${developer_name_default}
    Should Be Equal              ${appInst.key.cluster_inst_key.organization}             ${developer_name_default}

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.organization}  ${operator_name}
    Should Be Equal              ${clusterInst[0].key.organization}                       ${developer_name_default}
    Should Be Equal As Integers  ${clusterInst[0].ip_access}                           1  # IpAccessDedicated
    Should Be Equal              ${clusterInst[0].deployment}                          kubernetes 
    Should Be Equal As Integers  ${clusterInst[0].num_masters}                         1 
    Should Be Equal As Integers  ${clusterInst[0].num_masters}                         1 

    Length Should Be   ${clusterInst}  1

AppInst - appinst shall be created when app instance is created with auto-cluster and autoclusteripaccess=IpAccessShared
    [Documentation]
    ...  create an app instance with autocluster and autoclusteripaccess=IpAccessShared
    ...  verify appinst is created with autocluster with ipaccess=IpAccessShared

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}

    ${appInst}=  Create App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_org_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}  autocluster_ip_access=IpAccessShared

    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_name_default}  use_defaults=${False}

    Should Be Equal              ${appInst.key.app_key.organization}             ${developer_name_default}
    Should Be Equal              ${appInst.key.cluster_inst_key.organization}             ${developer_name_default}

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.organization}  ${operator_name}
    Should Be Equal              ${clusterInst[0].key.organization}                       ${developer_name_default}
    Should Be Equal As Integers  ${clusterInst[0].ip_access}                           3  # IpAccessShared
    Should Be Equal              ${clusterInst[0].deployment}                          kubernetes
    Should Be Equal As Integers  ${clusterInst[0].num_masters}                         1
    Should Be Equal As Integers  ${clusterInst[0].num_masters}                         1

    Length Should Be   ${clusterInst}  1

AppInst - appinst shall be created when app instance is created with auto-cluster and autoclusteripaccess=IpAccessDedicatedOrShared
    [Documentation]
    ...  create an app instance with autocluster and autoclusteripaccess=IpAccessDedicatedOrShared
    ...  verify appinst is created with autocluster with ipaccess=IpAccessShared

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}

    ${appInst}=  Create App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_org_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}  autocluster_ip_access=IpAccessDedicatedOrShared

    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_name_default}  use_defaults=${False}

    Should Be Equal              ${appInst.key.app_key.organization}             ${developer_name_default}
    Should Be Equal              ${appInst.key.cluster_inst_key.organization}             ${developer_name_default}

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.organization}  ${operator_name}
    Should Be Equal              ${clusterInst[0].key.organization}                       ${developer_name_default}
    Should Be Equal As Integers  ${clusterInst[0].ip_access}                           3  # IpAccessShared
    Should Be Equal              ${clusterInst[0].deployment}                          kubernetes
    Should Be Equal As Integers  ${clusterInst[0].num_masters}                         1
    Should Be Equal As Integers  ${clusterInst[0].num_masters}                         1

    Length Should Be   ${clusterInst}  1

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor
    #Create Cloudlet  cloudlet_name=tmocloud-10  operator_org_name=tmus
    Create App			access_ports=tcp:1

    ${app_name_default}=  Get Default App Name
    ${app_version_default}=  Get Default App Version
    ${developer_name_default}=  Get Default Developer Name
    ${flavor_name_default}=  Get Default Flavor Name
  
    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${app_version_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${flavor_name_default}

Teardown
    Cleanup provisioning

    ${clusterInst}=  Show Cluster Instances  cluster_name=autocluster  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_name_default}  liveness=LivenessDynamic
    Length Should Be   ${clusterInst}  0

