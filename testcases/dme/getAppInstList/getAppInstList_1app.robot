*** Settings ***
Documentation   GetAppInstList - request shall return 1 app

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
# ECQ-1055
GetAppInstList - request shall return 1 app
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList for 1 app
    ...  verify returns 1 result

      Register Client
      ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      ${distance}=  Calculate Distance  ${origin}  ${dest} 
      ${distance_round}=  Convert To Number  ${distance}  1
      ${appfqdns_distance_round}=  Convert To Number  ${appfqdns[0].distance}  1  

      Should Be Equal             ${appfqdns[0].carrier_name}                             ${tmus_appinst.key.cluster_inst_key.cloudlet_key.organization}
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

      Length Should Be   ${appfqdns}  1
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[0].appinstances[0].edge_events_cookie}

      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${tmus_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${tmus_appinst.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${tmus_appinst.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${tmus_appinst.key.cluster_inst_key.organization}

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor
    #Create Cluster	
    Create App			access_ports=tcp:1  #permits_platform_apps=${True}
    ${tmus_appinst}=           Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst} 


