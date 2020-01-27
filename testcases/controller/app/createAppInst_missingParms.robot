*** Settings ***
Documentation   CreateAppInst with missing parms

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
AppInst - User shall be able to create an AppInst without a ClusterInst Developer
    [Documentation]
    ...  create an app instance with no cluster instance developer 
    ...  verify inst is created

    ${app_name_default}=        Get Default App Name
    ${developer_name_default}=  Get Default Developer Name
    ${cluster_name_default}=    Get Default Cluster Name
    ${flavor_name_default}=    Get Default Flavor Name

    Create App Instance  app_name=${app_name_default}  app_version=1.0  developer_name=${developer_name_default}  use_defaults=${False}   cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_name_default}  use_defaults=${False}

    #Show Cluster Instances
    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  developer_name=${developer_name_default}  liveness=LivenessStatic

    Should Be Equal As Integers  ${clusterInst[0].liveness}                            1  # LivenessStatic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name_default}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.operator_key.name}  ${operator_name}
    Should Be Equal              ${clusterInst[0].key.developer}                       ${developer_name_default}

    Length Should Be   ${clusterInst}  1

*** Keywords ***
Setup
    #Create Developer
    Create Flavor
    #Create Cluster
    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    #${epoch_time}=  Get Time  epoch
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  -  tcp  .

    Create App                  access_ports=tcp:1

