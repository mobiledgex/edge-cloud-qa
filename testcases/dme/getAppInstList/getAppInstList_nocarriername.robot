*** Settings ***
Documentation   GetAppInstList - without carriername 

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
${operator_name2}  tmus
${operator_name3}  att 

${cloudlet_name}  tmocloud-1
${cloudlet_name2}  tmocloud-2
${cloudlet_name3}  attcloud-1

${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
# ECQ-2112
GetAppInstList - request without carriername shall return 3 apps
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList without carrier name 
    ...  verify returns 3 result

      Register Client
      ${appfqdns}=  Get App Instance List  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest0}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      @{dest1}=    Create List  ${appfqdns[1].gps_location.latitude}  ${appfqdns[1].gps_location.longitude}
      @{dest2}=    Create List  ${appfqdns[2].gps_location.latitude}  ${appfqdns[2].gps_location.longitude}

      ${distance0}=  Calculate Distance  ${origin}  ${dest0} 
      ${distance_round0}=  Convert To Number  ${distance0}  1
      ${appfqdns_distance_round0}=  Convert To Number  ${appfqdns[0].distance}  1 

      ${distance1}=  Calculate Distance  ${origin}  ${dest1}
      ${distance_round1}=  Convert To Number  ${distance1}  1
      ${appfqdns_distance_round1}=  Convert To Number  ${appfqdns[1].distance}  1

      ${distance2}=  Calculate Distance  ${origin}  ${dest2}
      ${distance_round2}=  Convert To Number  ${distance2}  1
      ${appfqdns_distance_round2}=  Convert To Number  ${appfqdns[2].distance}  1
 

      Should Be Equal             ${appfqdns[0].carrier_name}                             ${att_appinst.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${att_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${att_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${att_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round0}                             ${distance_round0}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${att_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${att_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${att_appinst.uri}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${att_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${att_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${att_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${att_appinst.mapped_ports[0].fqdn_prefix}

      Should Be Equal             ${appfqdns[1].carrier_name}                             ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[1].cloudlet_name}                            ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[1].gps_location.latitude}                    ${tmus_appinst_1.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[1].gps_location.longitude}                   ${tmus_appinst_1.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round1}                             ${distance_round1}
      Should Be Equal             ${appfqdns[1].appinstances[0].app_name}                 ${tmus_appinst_1.key.app_key.name}
      Should Be Equal             ${appfqdns[1].appinstances[0].app_vers}                 ${tmus_appinst_1.key.app_key.version}
      Should Be Equal             ${appfqdns[1].appinstances[0].fqdn}                    ${tmus_appinst_1.uri}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].proto}          ${tmus_appinst_1.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].internal_port}  ${tmus_appinst_1.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].public_port}    ${tmus_appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst_1.mapped_ports[0].fqdn_prefix}

      Should Be Equal             ${appfqdns[2].carrier_name}                             ${tmus_appinst_2.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[2].cloudlet_name}                            ${tmus_appinst_2.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[2].gps_location.latitude}                    ${tmus_appinst_2.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[2].gps_location.longitude}                   ${tmus_appinst_2.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round2}                             ${distance_round2}
      Should Be Equal             ${appfqdns[2].appinstances[0].app_name}                 ${tmus_appinst_2.key.app_key.name}
      Should Be Equal             ${appfqdns[2].appinstances[0].app_vers}                 ${tmus_appinst_2.key.app_key.version}
      Should Be Equal             ${appfqdns[2].appinstances[0].fqdn}                    ${tmus_appinst_2.uri}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].proto}          ${tmus_appinst_2.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].internal_port}  ${tmus_appinst_2.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].public_port}    ${tmus_appinst_2.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst_2.mapped_ports[0].fqdn_prefix}

      Length Should Be   ${appfqdns}  3
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

      Length Should Be   ${appfqdns[1].appinstances}  1
      Length Should Be   ${appfqdns[1].appinstances[0].ports}  1

      Length Should Be   ${appfqdns[2].appinstances}  1
      Length Should Be   ${appfqdns[2].appinstances[0].ports}  1

# ECQ-2114
GetAppInstList - request without carriername and large limit shall return all apps
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList without carrier name and large limit
    ...  verify returns 3 result

      Register Client
      ${appfqdns}=  Get App Instance List  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=100000

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest0}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      @{dest1}=    Create List  ${appfqdns[1].gps_location.latitude}  ${appfqdns[1].gps_location.longitude}
      @{dest2}=    Create List  ${appfqdns[2].gps_location.latitude}  ${appfqdns[2].gps_location.longitude}

      ${distance0}=  Calculate Distance  ${origin}  ${dest0}
      ${distance_round0}=  Convert To Number  ${distance0}  1
      ${appfqdns_distance_round0}=  Convert To Number  ${appfqdns[0].distance}  1

      ${distance1}=  Calculate Distance  ${origin}  ${dest1}
      ${distance_round1}=  Convert To Number  ${distance1}  1
      ${appfqdns_distance_round1}=  Convert To Number  ${appfqdns[1].distance}  1

      ${distance2}=  Calculate Distance  ${origin}  ${dest2}
      ${distance_round2}=  Convert To Number  ${distance2}  1
      ${appfqdns_distance_round2}=  Convert To Number  ${appfqdns[2].distance}  1


      Should Be Equal             ${appfqdns[0].carrier_name}                             ${att_appinst.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${att_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${att_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${att_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round0}                             ${distance_round0}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${att_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${att_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${att_appinst.uri}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${att_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${att_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${att_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${att_appinst.mapped_ports[0].fqdn_prefix}

      Should Be Equal             ${appfqdns[1].carrier_name}                             ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[1].cloudlet_name}                            ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[1].gps_location.latitude}                    ${tmus_appinst_1.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[1].gps_location.longitude}                   ${tmus_appinst_1.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round1}                             ${distance_round1}
      Should Be Equal             ${appfqdns[1].appinstances[0].app_name}                 ${tmus_appinst_1.key.app_key.name}
      Should Be Equal             ${appfqdns[1].appinstances[0].app_vers}                 ${tmus_appinst_1.key.app_key.version}
      Should Be Equal             ${appfqdns[1].appinstances[0].fqdn}                    ${tmus_appinst_1.uri}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].proto}          ${tmus_appinst_1.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].internal_port}  ${tmus_appinst_1.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].public_port}    ${tmus_appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst_1.mapped_ports[0].fqdn_prefix}

      Should Be Equal             ${appfqdns[2].carrier_name}                             ${tmus_appinst_2.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[2].cloudlet_name}                            ${tmus_appinst_2.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[2].gps_location.latitude}                    ${tmus_appinst_2.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[2].gps_location.longitude}                   ${tmus_appinst_2.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round2}                             ${distance_round2}
      Should Be Equal             ${appfqdns[2].appinstances[0].app_name}                 ${tmus_appinst_2.key.app_key.name}
      Should Be Equal             ${appfqdns[2].appinstances[0].app_vers}                 ${tmus_appinst_2.key.app_key.version}
      Should Be Equal             ${appfqdns[2].appinstances[0].fqdn}                    ${tmus_appinst_2.uri}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].proto}          ${tmus_appinst_2.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].internal_port}  ${tmus_appinst_2.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].public_port}    ${tmus_appinst_2.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[2].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst_2.mapped_ports[0].fqdn_prefix}

      Length Should Be   ${appfqdns}  3
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

      Length Should Be   ${appfqdns[1].appinstances}  1
      Length Should Be   ${appfqdns[1].appinstances[0].ports}  1

      Length Should Be   ${appfqdns[2].appinstances}  1
      Length Should Be   ${appfqdns[2].appinstances[0].ports}  1

# ECQ-2113
GetAppInstList - request without carriername and limit shall return right apps
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList with limit 
    ...  verify returns right number of apps 

      Register Client
      ${appfqdns}=  Get App Instance List  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=2

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest0}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      @{dest1}=    Create List  ${appfqdns[1].gps_location.latitude}  ${appfqdns[1].gps_location.longitude}

      ${distance0}=  Calculate Distance  ${origin}  ${dest0}
      ${distance_round0}=  Convert To Number  ${distance0}  1
      ${appfqdns_distance_round0}=  Convert To Number  ${appfqdns[0].distance}  1

      ${distance1}=  Calculate Distance  ${origin}  ${dest1}
      ${distance_round1}=  Convert To Number  ${distance1}  1
      ${appfqdns_distance_round1}=  Convert To Number  ${appfqdns[1].distance}  1

      Should Be Equal             ${appfqdns[0].carrier_name}                             ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${tmus_appinst_1.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${tmus_appinst_1.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round0}                             ${distance_round0}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${tmus_appinst_1.key.app_key.name}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${tmus_appinst_1.key.app_key.version}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${tmus_appinst_1.uri}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${tmus_appinst_1.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${tmus_appinst_1.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${tmus_appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst_1.mapped_ports[0].fqdn_prefix}

      Should Be Equal             ${appfqdns[1].carrier_name}                             ${tmus_appinst_2.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[1].cloudlet_name}                            ${tmus_appinst_2.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[1].gps_location.latitude}                    ${tmus_appinst_2.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[1].gps_location.longitude}                   ${tmus_appinst_2.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round1}                             ${distance_round1}
      Should Be Equal             ${appfqdns[1].appinstances[0].app_name}                 ${tmus_appinst_2.key.app_key.name}
      Should Be Equal             ${appfqdns[1].appinstances[0].app_vers}                 ${tmus_appinst_2.key.app_key.version}
      Should Be Equal             ${appfqdns[1].appinstances[0].fqdn}                    ${tmus_appinst_2.uri}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].proto}          ${tmus_appinst_2.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].internal_port}  ${tmus_appinst_2.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].public_port}    ${tmus_appinst_2.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[1].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst_2.mapped_ports[0].fqdn_prefix}

      Length Should Be   ${appfqdns}  2
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

      Length Should Be   ${appfqdns[1].appinstances}  1
      Length Should Be   ${appfqdns[1].appinstances[0].ports}  1

      Register Client
      ${appfqdns}=  Get App Instance List  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=1

      Should Be Equal             ${appfqdns[0].carrier_name}                             ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.organization}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${tmus_appinst_1.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${tmus_appinst_1.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round0}                             ${distance_round0}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${tmus_appinst_1.key.app_key.name}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${tmus_appinst_1.key.app_key.version}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${tmus_appinst_1.uri}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${tmus_appinst_1.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${tmus_appinst_1.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${tmus_appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst_1.mapped_ports[0].fqdn_prefix}

      Length Should Be   ${appfqdns}  1
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

# ECQ-2115
GetAppInstList - request with invalid limit shall return error 
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList with invalid limit
    ...  verify returns right error 

      Register Client
      Run Keyword and Expect Error  ValueError: Value out of range: -1  Get App Instance List  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=-1

*** Keywords ***
Setup
    Create Flavor

    Create App			 access_ports=tcp:1 
    ${tmus_appinst_1}=           Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    #${appname_2}=                Catenate  SEPARATOR=  ${app_name_default}  _2    
    #Create App                   app_version=2.0  access_ports=tcp:1
    ${tmus_appinst_2}=           Create App Instance  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name2}  cluster_instance_name=autocluster2

    #${appname_3}=                Catenate  SEPARATOR=  ${app_name_default}  _3
    #Create App                   app_version=3.0  access_ports=tcp:1
    ${att_appinst}=           Create App Instance  cloudlet_name=${cloudlet_name3}  operator_org_name=${operator_name3}  cluster_instance_name=autocluster3

    Set Suite Variable  ${tmus_appinst_1} 
    Set Suite Variable  ${tmus_appinst_2}
    Set Suite Variable  ${att_appinst}


