*** Settings ***
Documentation   CreateAppInst 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
CreateAppInst - autocluster shall be created when app instance is created with clustername='autocluster'
    [Documentation]
    ...  create an app instance with cluster name of 'autocluster'
    ...  verify autocluster is created in cluster instance table
    ...  delete the app instance
    ...  verify autocluster is deleted from cluster instance table

    Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

    Show Cluster Instances
    ${cluster_name}=  Catenate   SEPARATOR=  autocluster  ${app_name_default}
    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  liveness=LivenessDynamic
	
    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2  # LivenessDynamic
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${cluster_flavor_name_default}	
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}	
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}	
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.operator_key.name}  ${operator_name}	

    Length Should Be   ${clusterInst}  1

    Set Suite Variable  ${cluster_name} 

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cluster Flavor
    Create App			access_ports=tcp:1

Teardown
    Cleanup provisioning

    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  liveness=LivenessDynamic
    Length Should Be   ${clusterInst}  0

