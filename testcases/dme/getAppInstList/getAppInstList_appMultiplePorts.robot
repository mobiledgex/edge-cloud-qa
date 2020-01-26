*** Settings ***
Documentation   GetAppInstList - request shall return app with multiple ports

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
GetAppInstList - request shall return app with mulitple ports
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList for app with multiple ports
    ...  verify returns 1 result with multiple ports

      Register Client
      ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      ${distance}=  Calculate Distance  ${origin}  ${dest} 
      ${distance_round}=  Convert To Number  ${distance}  1
      ${appfqdns_distance_round}=  Convert To Number  ${appfqdns[0].distance}  1  

      Should Be Equal             ${appfqdns[0].carrier_name}                             ${tmus_appinst.key.cluster_inst_key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${tmus_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${tmus_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${tmus_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round}                             ${distance_round}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${tmus_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${tmus_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${tmus_appinst.uri}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${tmus_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${tmus_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${tmus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst.mapped_ports[0].fqdn_prefix}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[1].proto}          ${tmus_appinst.mapped_ports[1].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[1].internal_port}  ${tmus_appinst.mapped_ports[1].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[1].public_port}    ${tmus_appinst.mapped_ports[1].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[1].fqdn_prefix}    ${tmus_appinst.mapped_ports[1].fqdn_prefix}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[2].proto}          ${tmus_appinst.mapped_ports[2].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[2].internal_port}  ${tmus_appinst.mapped_ports[2].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[2].public_port}    ${tmus_appinst.mapped_ports[2].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[2].fqdn_prefix}    ${tmus_appinst.mapped_ports[2].fqdn_prefix}

      Length Should Be   ${appfqdns}  1
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  3

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor
    #Create Cluster	
    Create App			access_ports=tcp:1,udp:2,http:3
    ${tmus_appinst}=           Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst} 


