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

    Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_name}

    Show Cluster Instances
    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  developer_name=${developer_name_default}  liveness=LivenessDynamic

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}	
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}	
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}	
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.operator_key.name}  ${operator_name}	
    Should Be Equal              ${clusterInst[0].key.developer}                       ${developer_name_default}

    Length Should Be   ${clusterInst}  1

AppInst - autocluster shall be created when app instance is created with clustername='autocluster' and no developer
    [Documentation]
    ...  create an app instance with cluster name of 'autocluster' and no developer
    ...  verify autocluster is created in cluster instance table
    ...  delete the app instance
    ...  verify autocluster is deleted from cluster instance table

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}

    ${appInst}=  Create App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_name}  use_defaults=${False}

    Show Cluster Instances
    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  developer_name=${developer_name_default}  liveness=LivenessDynamic

    Should Be Equal              ${appInst.key.app_key.developer_key.name}             ${developer_name_default}
    Should Be Equal              ${appInst.key.cluster_inst_key.developer}             ${developer_name_default}

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.operator_key.name}  ${operator_name}
    Should Be Equal              ${clusterInst[0].key.developer}                       ${developer_name_default}

    Length Should Be   ${clusterInst}  1

AppInst - appinst shall be created when app instance is created without cluster developer
    [Documentation]
    ...  create an app instance with cluster name and no cluster developer
    ...  verify appinst is created with cluster developer

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  cluster  ${epoch_time}

    Create Cluster Instance  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  no_auto_delete=${True}

    ${appInst}=  Create App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_name}  use_defaults=${False}  no_auto_delete=${True}

    Show Cluster Instances
    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  developer_name=${developer_name_default}  liveness=LivenessStatic

    Delete App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_name}
    Delete Cluster Instance  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    Should Be Equal              ${appInst.key.app_key.developer_key.name}             ${developer_name_default}
    Should Be Equal              ${appInst.key.cluster_inst_key.developer}             ${developer_name_default}

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            1  # LivenessStatic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.operator_key.name}  ${operator_name}
    Should Be Equal              ${clusterInst[0].key.developer}                       ${developer_name_default}

    Length Should Be   ${clusterInst}  1

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    #Create Cloudlet  cloudlet_name=tmocloud-10  operator_name=tmus
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

    ${clusterInst}=  Show Cluster Instances  cluster_name=autocluster  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  developer_name=${developer_name_default}  liveness=LivenessDynamic
    Length Should Be   ${clusterInst}  0

