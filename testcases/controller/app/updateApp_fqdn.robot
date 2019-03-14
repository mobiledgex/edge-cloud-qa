*** Settings ***
Documentation   CreateAppInst 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
CreateAppInst - autocluster shall be created when app instance is created without clustername
    [Documentation]
    ...  create an app instance without specifying a cluster name
    ...  verify autocluster is created in cluster instance table
    ...  delete the app instance
    ...  verify autocluster is deleted from cluster instance table

    Create App		access_ports=udp:1	
    Update App          access_ports=udp:1
	
    Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

    Update App          access_ports=udp:1

    ${app_instance}=  Show App Instances  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
	
    Show Cluster Instances
    ${cluster_name}=  Catenate   SEPARATOR=  autocluster  ${app_name_default}
    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  liveness=LivenessDynamic
	
    Should Be Equal As Integers  ${clusterInst[0].liveness}                            1
    Should Be Equal              ${clusterInst[0].flavor.name}                         ${cluster_flavor_name_default}	
    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}	
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}	
    Should Be Equal              ${clusterInst[0].key.cloudlet_key.operator_key.name}  ${operator_name}	

    Length Should Be   ${clusterInst}  1

    Set Suite Variable  ${cluster_name} 

AppInst - User shall be able to update the app accessports afer appInst delete
    [Documentation]
    ...  create an app instance without specifying a cluster name
    ...  verify autocluster is created in cluster instance table
    ...  delete the app instance
    ...  verify autocluster is deleted from cluster instance table

    Create App          access_ports=udp:1

    ${appInst_pre}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster  no_auto_delete=${True}
    Delete App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    Update App          access_ports=udp:2

    ${appInst_post}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

    #${appInst_post}=  Show App Instances  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
   
    ${fqdn_prefix}=  Catenate  SEPARATOR=-  ${app_name_default}  udp.
    Should Be Equal As Integers  ${appInst_pre.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_pre.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_pre.mapped_ports[0].proto}          2
    Should Be Equal              ${appInst_pre.mapped_ports[0].FQDN_prefix}    ${fqdn_prefix} 

    Should Be Equal As Integers  ${appInst_post.mapped_ports[0].internal_port}  2
    Should Be Equal As Integers  ${appInst_post.mapped_ports[0].public_port}    2
    Should Be Equal As Integers  ${appInst_post.mapped_ports[0].proto}          2
    Should Be Equal              ${appInst_post.mapped_ports[0].FQDN_prefix}    ${fqdn_prefix}

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor
    Create Cluster Flavor

