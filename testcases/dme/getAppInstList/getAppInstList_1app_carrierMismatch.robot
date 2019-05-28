*** Settings ***
Documentation   GetAppInstList - request shall return only app that match carrier

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${cloudlet_name}  tmocloud-1
${operator_name}  dmuus
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
GetAppInstList - request shall return only app that matches carrier
    [Documentation]
    ...  registerClient 
    ...  send GetAppInstList for 1 app
    ...  verify returns only appinst that matches carrier

      Register Client
      ${appfqdns}=  Get App Instance List  carrier_name=dmuus  latitude=1  longitude=1

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      ${distance}=  Calculate Distance  ${origin}  ${dest}
      ${distance_round}=  Convert To Number  ${distance}  1
      ${appfqdns_distance_round}=  Convert To Number  ${appfqdns[0].distance}  1

      Should Be Equal             ${appfqdns[0].carrier_name}                             ${operator_name}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${cloudlet_name}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${dmuus_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${dmuus_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round}                             ${distance_round}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${dmuus_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${dmuus_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${dmuus_appinst.uri}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${dmuus_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${dmuus_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${dmuus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst.mapped_ports[0].fqdn_prefix}

      Length Should Be   ${appfqdns}  1
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cluster	
    Create App			access_ports=tcp:1
    ${dmuus_appinst}=           Create App Instance  cloudlet_name=tmocloud-1  operator_name=dmuus  cluster_instance_name=autocluster
    Create App Instance         cloudlet_name=attcloud-1  operator_name=att  cluster_instance_name=autocluster

    Set Suite Variable  ${dmuus_appinst} 


