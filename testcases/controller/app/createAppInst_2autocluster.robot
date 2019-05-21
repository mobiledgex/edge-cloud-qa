*** Settings ***
Documentation   CreateAppInst with 2 autoclusters 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
AppInst - Shall be able to create to AppInsts with autocluster on the same app with different developer 
    [Documentation]
    ...  create 2 apps of the same name but different developer
    ...  create an app instance with cluster name of 'autocluster' on each app
    ...  verify autocluster is created in cluster instance table with proper developer name

    Create App Instance  developer_name=${developer_name_1}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster
    Create App Instance  developer_name=${developer_name_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

    #${cluster_flavor_name_default}=  Get Default Cluster Flavor Name
    #${app_name_default}=  Get Default App Name

    Show Cluster Instances
    #${cluster_name}=  Catenate   SEPARATOR=  autocluster  ${app_name_default}
    ${clusterInst_1}=  Show Cluster Instances  developer_name=${developer_name_1}  cluster_name=autocluster  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  liveness=LivenessDynamic
    ${clusterInst_2}=  Show Cluster Instances  developer_name=${developer_name_2}  cluster_name=autocluster  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  liveness=LivenessDynamic

    Should Be Equal As Integers  ${clusterInst_1[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst_1[0].flavor.name}                         ${flavor_name_default}	
    Should Be Equal              ${clusterInst_1[0].key.cluster_key.name}                autocluster	
    Should Be Equal              ${clusterInst_1[0].key.cloudlet_key.name}               ${cloudlet_name}	
    Should Be Equal              ${clusterInst_1[0].key.cloudlet_key.operator_key.name}  ${operator_name}	
    Should Be Equal              ${clusterInst_1[0].key.developer}                       ${developer_name_1}
    Length Should Be   ${clusterInst_1}  1

    Should Be Equal As Integers  ${clusterInst_2[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst_2[0].flavor.name}                         ${flavor_name_default}
    Should Be Equal              ${clusterInst_2[0].key.cluster_key.name}                autocluster
    Should Be Equal              ${clusterInst_2[0].key.cloudlet_key.name}               ${cloudlet_name}
    Should Be Equal              ${clusterInst_2[0].key.cloudlet_key.operator_key.name}  ${operator_name}
    Should Be Equal              ${clusterInst_2[0].key.developer}                       ${developer_name_2}
    Length Should Be   ${clusterInst_2}  1

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${developer_name_1}=  Catenate  SEPARATOR=  dev  ${epoch_time}  _1
    ${developer_name_2}=  Catenate  SEPARATOR=  dev  ${epoch_time}  _2
    Set Suite Variable  ${developer_name_1}
    Set Suite Variable  ${developer_name_2}

    Create Developer  developer_name=${developer_name_1}          
    Create Developer  developer_name=${developer_name_2}  
    Create Flavor
    Create App			developer_name=${developer_name_1}  access_ports=tcp:1
    Create App                  developer_name=${developer_name_2}  access_ports=tcp:1

    ${flavor_name_default}=  Get Default Flavor Name
    Set Suite Variable  ${flavor_name_default}

Teardown
    Cleanup provisioning

    ${clusterInst}=  Show Cluster Instances  cluster_name=autocluster  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  liveness=LivenessDynamic
    Length Should Be   ${clusterInst}  0

