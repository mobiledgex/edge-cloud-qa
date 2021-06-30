*** Settings ***
Documentation   UpdateAppInst 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String
#Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
#CreateAppInst - autocluster shall be created when app instance is created without clustername
#    [Documentation]
#    ...  create an app instance without specifying a cluster name
#    ...  verify autocluster is created in cluster instance table
#    ...  delete the app instance
#    ...  verify autocluster is deleted from cluster instance table
#
#    Create App		access_ports=udp:1	
#    Update App          access_ports=udp:1
#
#    ${epoch_time}=  Get Time  epoch
#    ${cluster_name}=  Catenate  SEPARATOR=  autocluster  ${epoch_time}
#	
#    Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}
#
#    Update App          access_ports=udp:1
#
#    ${app_instance}=  Show App Instances  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
#
#    ${app_name_default}=  Get Default App Name
#    ${flavor_name_default}=  Get Default Flavor Name
#	
#    #Show Cluster Instances
#    #${cluster_name}=  Catenate   SEPARATOR=  autocluster  ${app_name_default}
#    ${clusterInst}=  Show Cluster Instances  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  liveness=LivenessDynamic
#	
#    Should Be Equal As Integers  ${clusterInst[0].liveness}                            2
#    Should Be Equal              ${clusterInst[0].flavor.name}                         ${flavor_name_default}	
#    Should Be Equal              ${clusterInst[0].key.cluster_key.name}                ${cluster_name}	
#    Should Be Equal              ${clusterInst[0].key.cloudlet_key.name}               ${cloudlet_name}	
#    Should Be Equal              ${clusterInst[0].key.cloudlet_key.operator_key.name}  ${operator_name}	
#
#    Length Should Be   ${clusterInst}  1
#
#    Set Suite Variable  ${cluster_name} 

# ECQ-1172
AppInst - User shall be able to update the app accessports afer appInst delete
    [Documentation]
    ...  create an app with accessports udp:1
    ...  create app instance
    ...  delete the app instance
    ...  update app with accessports udp:2
    ...  create app instance again
    ...  verify mapped_ports is correct

    Create App          access_ports=udp:1

    ${epoch_time}=  Get Time  epoch
    ${cluster_name}=  Catenate  SEPARATOR=  autocluster  ${epoch_time}

    ${appInst_pre}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}  no_auto_delete=${True}
    Delete App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}

    Update App          access_ports=udp:2

    ${appInst_post}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${version}=  Set Variable  ${appInst_post.key.app_key.version}
    ${version}=  Remove String  ${version}  .
    #${appInst_post}=  Show App Instances  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
  
    ${app_name_default}=  Get Default App Name
 
    ${fqdn_prefix}=  Catenate  SEPARATOR=-  ${app_name_default}${version}  udp-
    Should Be Equal As Integers  ${appInst_pre.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_pre.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_pre.mapped_ports[0].proto}          2
    Should Be Equal              ${appInst_pre.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix} 

    Should Be Equal As Integers  ${appInst_post.mapped_ports[0].internal_port}  2
    Should Be Equal As Integers  ${appInst_post.mapped_ports[0].public_port}    2
    Should Be Equal As Integers  ${appInst_post.mapped_ports[0].proto}          2
    Should Be Equal              ${appInst_post.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor

