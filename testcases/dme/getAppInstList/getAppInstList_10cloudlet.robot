*** Settings ***
Documentation   GetAppInstList - request shall return 10 cloudlets

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name_1}  tmocloud-1
${cloudlet_name_2}  tmocloud-2
${cloudlet_name_3}  tmocloud-3
${cloudlet_name_4}  tmocloud-4
${cloudlet_name_5}  tmocloud-5
${cloudlet_name_6}  tmocloud-6
${cloudlet_name_7}  tmocloud-7
${cloudlet_name_8}  tmocloud-8
#${cloudlet_name_9}  tmocloud-9
#${cloudlet_name_10}  tmocloud-10

${gcp_operator_name}  gcp
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms

${azure_operator_name}  azure
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms

${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -95
${azure_cloudlet_latitude}	  38
${azure_cloudlet longitude}	  -95

${mobile_latitude}  1
${mobile_longitude}  1

${distance_offset}=  100

*** Test Cases ***
# ECQ-1054
GetAppInstList - request shall return 10 cloudlets
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList for 10 cloudlets
    ...  verify returns 10 cloudlets

      Register Client
      ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=10

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest_1}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      @{dest_2}=    Create List  ${appfqdns[1].gps_location.latitude}  ${appfqdns[1].gps_location.longitude}
      @{dest_3}=    Create List  ${appfqdns[2].gps_location.latitude}  ${appfqdns[2].gps_location.longitude}
      @{dest_4}=    Create List  ${appfqdns[3].gps_location.latitude}  ${appfqdns[3].gps_location.longitude}
      @{dest_5}=    Create List  ${appfqdns[4].gps_location.latitude}  ${appfqdns[4].gps_location.longitude}
      @{dest_6}=    Create List  ${appfqdns[5].gps_location.latitude}  ${appfqdns[5].gps_location.longitude}
      @{dest_7}=    Create List  ${appfqdns[6].gps_location.latitude}  ${appfqdns[6].gps_location.longitude}
      @{dest_8}=    Create List  ${appfqdns[7].gps_location.latitude}  ${appfqdns[7].gps_location.longitude}
      @{dest_9}=    Create List  ${appfqdns[8].gps_location.latitude}  ${appfqdns[8].gps_location.longitude}
      @{dest_10}=    Create List  ${appfqdns[9].gps_location.latitude}  ${appfqdns[9].gps_location.longitude}

      ${distance_1}=  Calculate Distance  ${origin}  ${dest_1} 
      ${distance_round_1}=  Convert To Number  ${distance_1}  1
      ${appfqdns_distance_round_1}=  Convert To Number  ${appfqdns[0].distance}  1  
      ${distance_2}=  Calculate Distance  ${origin}  ${dest_2}
      ${distance_round_2}=  Convert To Number  ${distance_2}  1
      ${appfqdns_distance_round_2}=  Convert To Number  ${appfqdns[1].distance}  1
      ${distance_3}=  Calculate Distance  ${origin}  ${dest_3}
      ${distance_round_3}=  Convert To Number  ${distance_3}  1
      ${appfqdns_distance_round_3}=  Convert To Number  ${appfqdns[2].distance}  1
      ${distance_4}=  Calculate Distance  ${origin}  ${dest_4}
      ${distance_round_4}=  Convert To Number  ${distance_4}  1
      ${appfqdns_distance_round_4}=  Convert To Number  ${appfqdns[3].distance}  1
      ${distance_5}=  Calculate Distance  ${origin}  ${dest_5}
      ${distance_round_5}=  Convert To Number  ${distance_5}  1
      ${appfqdns_distance_round_5}=  Convert To Number  ${appfqdns[4].distance}  1
      ${distance_6}=  Calculate Distance  ${origin}  ${dest_6}
      ${distance_round_6}=  Convert To Number  ${distance_6}  1
      ${appfqdns_distance_round_6}=  Convert To Number  ${appfqdns[5].distance}  1
      ${distance_7}=  Calculate Distance  ${origin}  ${dest_7}
      ${distance_round_7}=  Convert To Number  ${distance_7}  1
      ${appfqdns_distance_round_7}=  Convert To Number  ${appfqdns[6].distance}  1
      ${distance_8}=  Calculate Distance  ${origin}  ${dest_8}
      ${distance_round_8}=  Convert To Number  ${distance_8}  1
      ${appfqdns_distance_round_8}=  Convert To Number  ${appfqdns[7].distance}  1
      ${distance_9}=  Calculate Distance  ${origin}  ${dest_9}
      ${distance_round_9}=  Convert To Number  ${distance_9}  1
      ${appfqdns_distance_round_9}=  Convert To Number  ${appfqdns[8].distance}  1
      ${distance_10}=  Calculate Distance  ${origin}  ${dest_10}
      ${distance_round_10}=  Convert To Number  ${distance_10}  1
      ${appfqdns_distance_round_10}=  Convert To Number  ${appfqdns[9].distance}  1

      # response is sorted by distance with shortest distance first

      Should Be Equal             ${appfqdns[8].carrier_name}                             ${azure_appinst.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[8].cloudlet_name}                            ${azure_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[8].gps_location.latitude}                    ${azure_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[8].gps_location.longitude}                   ${azure_appinst.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_9} == (${distance_round_9} + ${distance_offset})
      Should Be Equal             ${appfqdns[8].appinstances[0].app_name}                 ${azure_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[8].appinstances[0].app_vers}                 ${azure_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[8].appinstances[0].fqdn}                    ${azure_appinst.uri}
      Should Be Equal             ${appfqdns[8].appinstances[0].ports[0].proto}          ${azure_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[8].appinstances[0].ports[0].internal_port}  ${azure_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[8].appinstances[0].ports[0].public_port}    ${azure_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[8].appinstances[0].ports[0].fqdn_prefix}    ${azure_appinst.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[8].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${azure_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${azure_appinst.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${azure_appinst.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${azure_appinst.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[9].carrier_name}                             ${gcp_appinst.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[9].cloudlet_name}                            ${gcp_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[9].gps_location.latitude}                    ${gcp_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[9].gps_location.longitude}                   ${gcp_appinst.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_10} == (${distance_round_10} + ${distance_offset})
      Should Be Equal             ${appfqdns[9].appinstances[0].app_name}                 ${gcp_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[9].appinstances[0].app_vers}                 ${gcp_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[9].appinstances[0].fqdn}                    ${gcp_appinst.uri}
      Should Be Equal             ${appfqdns[9].appinstances[0].ports[0].proto}          ${gcp_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[9].appinstances[0].ports[0].internal_port}  ${gcp_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[9].appinstances[0].ports[0].public_port}    ${gcp_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[9].appinstances[0].ports[0].fqdn_prefix}    ${gcp_appinst.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[9].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${gcp_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${gcp_appinst.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${gcp_appinst.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${gcp_appinst.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[6].carrier_name}                             ${dmuus_appinst_1.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[6].cloudlet_name}                            ${dmuus_appinst_1.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[6].gps_location.latitude}                    ${dmuus_appinst_1.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[6].gps_location.longitude}                   ${dmuus_appinst_1.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_7} == (${distance_round_7} + 0)
      Should Be Equal             ${appfqdns[6].appinstances[0].app_name}                 ${dmuus_appinst_1.key.app_key.name}
      Should Be Equal             ${appfqdns[6].appinstances[0].app_vers}                 ${dmuus_appinst_1.key.app_key.version}
      Should Be Equal             ${appfqdns[6].appinstances[0].fqdn}                    ${dmuus_appinst_1.uri}
      Should Be Equal             ${appfqdns[6].appinstances[0].ports[0].proto}          ${dmuus_appinst_1.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[6].appinstances[0].ports[0].internal_port}  ${dmuus_appinst_1.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[6].appinstances[0].ports[0].public_port}    ${dmuus_appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[6].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst_1.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[6].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${dmuus_appinst_1.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${dmuus_appinst_1.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${dmuus_appinst_1.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${dmuus_appinst_1.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[7].carrier_name}                             ${dmuus_appinst_2.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[7].cloudlet_name}                            ${dmuus_appinst_2.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[7].gps_location.latitude}                    ${dmuus_appinst_2.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[7].gps_location.longitude}                   ${dmuus_appinst_2.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_8} == (${distance_round_8} + 0)
      Should Be Equal             ${appfqdns[7].appinstances[0].app_name}                 ${dmuus_appinst_2.key.app_key.name}
      Should Be Equal             ${appfqdns[7].appinstances[0].app_vers}                 ${dmuus_appinst_2.key.app_key.version}
      Should Be Equal             ${appfqdns[7].appinstances[0].fqdn}                    ${dmuus_appinst_2.uri}
      Should Be Equal             ${appfqdns[7].appinstances[0].ports[0].proto}          ${dmuus_appinst_2.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[7].appinstances[0].ports[0].internal_port}  ${dmuus_appinst_2.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[7].appinstances[0].ports[0].public_port}    ${dmuus_appinst_2.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[7].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst_2.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[7].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${dmuus_appinst_2.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${dmuus_appinst_2.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${dmuus_appinst_2.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${dmuus_appinst_2.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[0].carrier_name}                             ${dmuus_appinst_3.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${dmuus_appinst_3.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${dmuus_appinst_3.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${dmuus_appinst_3.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_1} == (${distance_round_1} + 0)
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${dmuus_appinst_3.key.app_key.name}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${dmuus_appinst_3.key.app_key.version}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${dmuus_appinst_3.uri}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${dmuus_appinst_3.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${dmuus_appinst_3.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${dmuus_appinst_3.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst_3.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[0].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${dmuus_appinst_3.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${dmuus_appinst_3.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${dmuus_appinst_3.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${dmuus_appinst_3.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[1].carrier_name}                             ${dmuus_appinst_4.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[1].cloudlet_name}                            ${dmuus_appinst_4.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[1].gps_location.latitude}                    ${dmuus_appinst_4.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[1].gps_location.longitude}                   ${dmuus_appinst_4.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_2} == (${distance_round_2} + 0)
      Should Be Equal             ${appfqdns[1].appinstances[0].app_name}                 ${dmuus_appinst_4.key.app_key.name}
      Should Be Equal             ${appfqdns[1].appinstances[0].app_vers}                 ${dmuus_appinst_4.key.app_key.version}
      Should Be Equal             ${appfqdns[1].appinstances[0].fqdn}                    ${dmuus_appinst_4.uri}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].proto}          ${dmuus_appinst_4.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].internal_port}  ${dmuus_appinst_4.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].public_port}    ${dmuus_appinst_4.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst_4.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[1].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${dmuus_appinst_4.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${dmuus_appinst_4.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${dmuus_appinst_4.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${dmuus_appinst_4.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[2].carrier_name}                             ${dmuus_appinst_5.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[2].cloudlet_name}                            ${dmuus_appinst_5.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[2].gps_location.latitude}                    ${dmuus_appinst_5.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[2].gps_location.longitude}                   ${dmuus_appinst_5.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_3} == (${distance_round_3} + 0)
      Should Be Equal             ${appfqdns[2].appinstances[0].app_name}                 ${dmuus_appinst_5.key.app_key.name}
      Should Be Equal             ${appfqdns[2].appinstances[0].app_vers}                 ${dmuus_appinst_5.key.app_key.version}
      Should Be Equal             ${appfqdns[2].appinstances[0].fqdn}                    ${dmuus_appinst_5.uri}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].proto}          ${dmuus_appinst_5.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].internal_port}  ${dmuus_appinst_5.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].public_port}    ${dmuus_appinst_5.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst_5.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[2].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${dmuus_appinst_5.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${dmuus_appinst_5.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${dmuus_appinst_5.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${dmuus_appinst_5.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[3].carrier_name}                             ${dmuus_appinst_6.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[3].cloudlet_name}                            ${dmuus_appinst_6.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[3].gps_location.latitude}                    ${dmuus_appinst_6.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[3].gps_location.longitude}                   ${dmuus_appinst_6.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_4} == (${distance_round_4} + 0)
      Should Be Equal             ${appfqdns[3].appinstances[0].app_name}                 ${dmuus_appinst_6.key.app_key.name}
      Should Be Equal             ${appfqdns[3].appinstances[0].app_vers}                 ${dmuus_appinst_6.key.app_key.version}
      Should Be Equal             ${appfqdns[3].appinstances[0].fqdn}                    ${dmuus_appinst_6.uri}
      Should Be Equal             ${appfqdns[3].appinstances[0].ports[0].proto}          ${dmuus_appinst_6.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[3].appinstances[0].ports[0].internal_port}  ${dmuus_appinst_6.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[3].appinstances[0].ports[0].public_port}    ${dmuus_appinst_6.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[3].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst_6.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[3].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${dmuus_appinst_6.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${dmuus_appinst_6.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${dmuus_appinst_6.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${dmuus_appinst_6.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[4].carrier_name}                             ${dmuus_appinst_7.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[4].cloudlet_name}                            ${dmuus_appinst_7.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[4].gps_location.latitude}                    ${dmuus_appinst_7.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[4].gps_location.longitude}                   ${dmuus_appinst_7.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_5} == (${distance_round_5} + 0)
      Should Be Equal             ${appfqdns[4].appinstances[0].app_name}                 ${dmuus_appinst_7.key.app_key.name}
      Should Be Equal             ${appfqdns[4].appinstances[0].app_vers}                 ${dmuus_appinst_7.key.app_key.version}
      Should Be Equal             ${appfqdns[4].appinstances[0].fqdn}                    ${dmuus_appinst_7.uri}
      Should Be Equal             ${appfqdns[4].appinstances[0].ports[0].proto}          ${dmuus_appinst_7.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[4].appinstances[0].ports[0].internal_port}  ${dmuus_appinst_7.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[4].appinstances[0].ports[0].public_port}    ${dmuus_appinst_7.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[4].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst_7.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[4].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${dmuus_appinst_7.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${dmuus_appinst_7.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${dmuus_appinst_7.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${dmuus_appinst_7.key.cluster_inst_key.organization}

      Should Be Equal             ${appfqdns[5].carrier_name}                             ${dmuus_appinst_8.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[5].cloudlet_name}                            ${dmuus_appinst_8.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[5].gps_location.latitude}                    ${dmuus_appinst_8.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[5].gps_location.longitude}                   ${dmuus_appinst_8.cloudlet_loc.longitude}
      Should Be True              ${appfqdns_distance_round_6} == (${distance_round_6} + 0)
      Should Be Equal             ${appfqdns[5].appinstances[0].app_name}                 ${dmuus_appinst_8.key.app_key.name}
      Should Be Equal             ${appfqdns[5].appinstances[0].app_vers}                 ${dmuus_appinst_8.key.app_key.version}
      Should Be Equal             ${appfqdns[5].appinstances[0].fqdn}                    ${dmuus_appinst_8.uri}
      Should Be Equal             ${appfqdns[5].appinstances[0].ports[0].proto}          ${dmuus_appinst_8.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[5].appinstances[0].ports[0].internal_port}  ${dmuus_appinst_8.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[5].appinstances[0].ports[0].public_port}    ${dmuus_appinst_8.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[5].appinstances[0].ports[0].fqdn_prefix}    ${dmuus_appinst_8.mapped_ports[0].fqdn_prefix}
      ${decoded_edge_cookie}=  Decode Cookie  ${appfqdns[5].appinstances[0].edge_events_cookie}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
      Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
      Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${dmuus_appinst_8.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${dmuus_appinst_8.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${dmuus_appinst_8.key.cluster_inst_key.cluster_key.name}
      Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${dmuus_appinst_8.key.cluster_inst_key.organization}

      Length Should Be   ${appfqdns}  10
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${cloudlet_name_3}=  Catenate  SEPARATOR=  ${cloudlet_name_3}  ${epoch}
    ${cloudlet_name_4}=  Catenate  SEPARATOR=  ${cloudlet_name_4}  ${epoch}
    ${cloudlet_name_5}=  Catenate  SEPARATOR=  ${cloudlet_name_5}  ${epoch}
    ${cloudlet_name_6}=  Catenate  SEPARATOR=  ${cloudlet_name_6}  ${epoch}
    ${cloudlet_name_7}=  Catenate  SEPARATOR=  ${cloudlet_name_7}  ${epoch}
    ${cloudlet_name_8}=  Catenate  SEPARATOR=  ${cloudlet_name_8}  ${epoch}
    #${cloudlet_name_9}=  Catenate  SEPARATOR=  ${cloudlet_name_9}  ${epoch}
    #${cloudlet_name_10}=  Catenate  SEPARATOR=  ${cloudlet_name_10}  ${epoch}
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}
    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    #Create Developer            
    Create Flavor
    #Create Cluster	
    Create Cloudlet	   cloudlet_name=${cloudlet_name3}  operator_org_name=${operator_name}  latitude=3  longitude=3
    Create Cloudlet        cloudlet_name=${cloudlet_name4}  operator_org_name=${operator_name}  latitude=4  longitude=4
    Create Cloudlet        cloudlet_name=${cloudlet_name5}  operator_org_name=${operator_name}  latitude=5  longitude=5
    Create Cloudlet        cloudlet_name=${cloudlet_name6}  operator_org_name=${operator_name}  latitude=6  longitude=6
    Create Cloudlet        cloudlet_name=${cloudlet_name7}  operator_org_name=${operator_name}  latitude=7  longitude=7
    Create Cloudlet        cloudlet_name=${cloudlet_name8}  operator_org_name=${operator_name}  latitude=8  longitude=8
    #Create Cloudlet        cloudlet_name=${cloudlet_name9}  operator_org_name=${operator_name}  latitude=9  longitude=9
    #Create Cloudlet        cloudlet_name=${cloudlet_name10}  operator_org_name=${operator_name}  latitude=10  longitude=10

    Create Cloudlet        cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create Cloudlet        cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}

    Create App			access_ports=tcp:1  #permits_platform_apps=${True}
    ${dmuus_appinst_1}=           Create App Instance  cloudlet_name=${cloudlet_name_1}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_2}=           Create App Instance  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_3}=           Create App Instance  cloudlet_name=${cloudlet_name_3}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_4}=           Create App Instance  cloudlet_name=${cloudlet_name_4}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_5}=           Create App Instance  cloudlet_name=${cloudlet_name_5}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_6}=           Create App Instance  cloudlet_name=${cloudlet_name_6}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_7}=           Create App Instance  cloudlet_name=${cloudlet_name_7}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_8}=           Create App Instance  cloudlet_name=${cloudlet_name_8}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    #${dmuus_appinst_9}=           Create App Instance  cloudlet_name=${cloudlet_name_9}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    #${dmuus_appinst_10}=           Create App Instance  cloudlet_name=${cloudlet_name_10}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    ${gcp_appinst}=             Create App Instance         cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster
    ${azure_appinst}=           Create App Instance         cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${dmuus_appinst_1} 
    Set Suite Variable  ${dmuus_appinst_2}
    Set Suite Variable  ${dmuus_appinst_3}
    Set Suite Variable  ${dmuus_appinst_4}
    Set Suite Variable  ${dmuus_appinst_5}
    Set Suite Variable  ${dmuus_appinst_6}
    Set Suite Variable  ${dmuus_appinst_7}
    Set Suite Variable  ${dmuus_appinst_8}
    #Set Suite Variable  ${dmuus_appinst_9}
    #Set Suite Variable  ${dmuus_appinst_10}

    Set Suite Variable  ${gcp_appinst}
    Set Suite Variable  ${azure_appinst}


