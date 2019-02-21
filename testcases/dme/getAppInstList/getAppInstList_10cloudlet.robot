*** Settings ***
Documentation   GetAppInstList - request shall return 10 cloudlets

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
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

*** Test Cases ***
GetAppInstList - request shall return 10 cloudlets
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList for 10 cloudlets
    ...  verify returns 10 cloudlets

      Register Client
      ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest_1}=    Create List  ${appfqdns[0].GpsLocation.latitude}  ${appfqdns[0].GpsLocation.longitude}
      @{dest_2}=    Create List  ${appfqdns[1].GpsLocation.latitude}  ${appfqdns[1].GpsLocation.longitude}
      @{dest_3}=    Create List  ${appfqdns[2].GpsLocation.latitude}  ${appfqdns[2].GpsLocation.longitude}
      @{dest_4}=    Create List  ${appfqdns[3].GpsLocation.latitude}  ${appfqdns[3].GpsLocation.longitude}
      @{dest_5}=    Create List  ${appfqdns[4].GpsLocation.latitude}  ${appfqdns[4].GpsLocation.longitude}
      @{dest_6}=    Create List  ${appfqdns[5].GpsLocation.latitude}  ${appfqdns[5].GpsLocation.longitude}
      @{dest_7}=    Create List  ${appfqdns[6].GpsLocation.latitude}  ${appfqdns[6].GpsLocation.longitude}
      @{dest_8}=    Create List  ${appfqdns[7].GpsLocation.latitude}  ${appfqdns[7].GpsLocation.longitude}
      @{dest_9}=    Create List  ${appfqdns[8].GpsLocation.latitude}  ${appfqdns[8].GpsLocation.longitude}
      @{dest_10}=    Create List  ${appfqdns[9].GpsLocation.latitude}  ${appfqdns[9].GpsLocation.longitude}

      ${distance_1}=  Calculate Distance  ${origin}  ${dest_1} 
      ${distance_round_1}=  Convert To Number  ${distance_1}  1
      ${appfqdns_distance_round_1}=  Convert To Number  ${appfqdns[0].Distance}  1  
      ${distance_2}=  Calculate Distance  ${origin}  ${dest_2}
      ${distance_round_2}=  Convert To Number  ${distance_2}  1
      ${appfqdns_distance_round_2}=  Convert To Number  ${appfqdns[1].Distance}  1
      ${distance_3}=  Calculate Distance  ${origin}  ${dest_3}
      ${distance_round_3}=  Convert To Number  ${distance_3}  1
      ${appfqdns_distance_round_3}=  Convert To Number  ${appfqdns[2].Distance}  1
      ${distance_4}=  Calculate Distance  ${origin}  ${dest_4}
      ${distance_round_4}=  Convert To Number  ${distance_4}  1
      ${appfqdns_distance_round_4}=  Convert To Number  ${appfqdns[3].Distance}  1
      ${distance_5}=  Calculate Distance  ${origin}  ${dest_5}
      ${distance_round_5}=  Convert To Number  ${distance_5}  1
      ${appfqdns_distance_round_5}=  Convert To Number  ${appfqdns[4].Distance}  1
      ${distance_6}=  Calculate Distance  ${origin}  ${dest_6}
      ${distance_round_6}=  Convert To Number  ${distance_6}  1
      ${appfqdns_distance_round_6}=  Convert To Number  ${appfqdns[5].Distance}  1
      ${distance_7}=  Calculate Distance  ${origin}  ${dest_7}
      ${distance_round_7}=  Convert To Number  ${distance_7}  1
      ${appfqdns_distance_round_7}=  Convert To Number  ${appfqdns[6].Distance}  1
      ${distance_8}=  Calculate Distance  ${origin}  ${dest_8}
      ${distance_round_8}=  Convert To Number  ${distance_8}  1
      ${appfqdns_distance_round_8}=  Convert To Number  ${appfqdns[7].Distance}  1
      ${distance_9}=  Calculate Distance  ${origin}  ${dest_9}
      ${distance_round_9}=  Convert To Number  ${distance_9}  1
      ${appfqdns_distance_round_9}=  Convert To Number  ${appfqdns[8].Distance}  1
      ${distance_10}=  Calculate Distance  ${origin}  ${dest_10}
      ${distance_round_10}=  Convert To Number  ${distance_10}  1
      ${appfqdns_distance_round_10}=  Convert To Number  ${appfqdns[9].Distance}  1

      Should Be Equal             ${appfqdns[0].CarrierName}                             ${azure_appinst.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[0].CloudletName}                            ${azure_appinst.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].GpsLocation.latitude}                    ${azure_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].GpsLocation.longitude}                   ${azure_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_1}                           ${distance_round_1}
      Should Be Equal             ${appfqdns[0].Appinstances[0].AppName}                 ${azure_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].Appinstances[0].AppVers}                 ${azure_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].Appinstances[0].FQDN}                    ${azure_appinst.uri}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].proto}          ${azure_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].internal_port}  ${azure_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].public_port}    ${azure_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].FQDN_prefix}    ${azure_appinst.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[1].CarrierName}                             ${gcp_appinst.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[1].CloudletName}                            ${gcp_appinst.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[1].GpsLocation.latitude}                    ${gcp_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[1].GpsLocation.longitude}                   ${gcp_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_2}                           ${distance_round_2}
      Should Be Equal             ${appfqdns[1].Appinstances[0].AppName}                 ${gcp_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[1].Appinstances[0].AppVers}                 ${gcp_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[1].Appinstances[0].FQDN}                    ${gcp_appinst.uri}
      Should Be Equal             ${appfqdns[1].Appinstances[0].ports[0].proto}          ${gcp_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[1].Appinstances[0].ports[0].internal_port}  ${gcp_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[1].Appinstances[0].ports[0].public_port}    ${gcp_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[1].Appinstances[0].ports[0].FQDN_prefix}    ${gcp_appinst.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[2].CarrierName}                             ${tmus_appinst_1.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[2].CloudletName}                            ${tmus_appinst_1.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[2].GpsLocation.latitude}                    ${tmus_appinst_1.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[2].GpsLocation.longitude}                   ${tmus_appinst_1.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_3}                           ${distance_round_3}
      Should Be Equal             ${appfqdns[2].Appinstances[0].AppName}                 ${tmus_appinst_1.key.app_key.name}
      Should Be Equal             ${appfqdns[2].Appinstances[0].AppVers}                 ${tmus_appinst_1.key.app_key.version}
      Should Be Equal             ${appfqdns[2].Appinstances[0].FQDN}                    ${tmus_appinst_1.uri}
      Should Be Equal             ${appfqdns[2].Appinstances[0].ports[0].proto}          ${tmus_appinst_1.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[2].Appinstances[0].ports[0].internal_port}  ${tmus_appinst_1.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[2].Appinstances[0].ports[0].public_port}    ${tmus_appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[2].Appinstances[0].ports[0].FQDN_prefix}    ${tmus_appinst_1.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[3].CarrierName}                             ${tmus_appinst_2.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[3].CloudletName}                            ${tmus_appinst_2.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[3].GpsLocation.latitude}                    ${tmus_appinst_2.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[3].GpsLocation.longitude}                   ${tmus_appinst_2.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_4}                           ${distance_round_4}
      Should Be Equal             ${appfqdns[3].Appinstances[0].AppName}                 ${tmus_appinst_2.key.app_key.name}
      Should Be Equal             ${appfqdns[3].Appinstances[0].AppVers}                 ${tmus_appinst_2.key.app_key.version}
      Should Be Equal             ${appfqdns[3].Appinstances[0].FQDN}                    ${tmus_appinst_2.uri}
      Should Be Equal             ${appfqdns[3].Appinstances[0].ports[0].proto}          ${tmus_appinst_2.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[3].Appinstances[0].ports[0].internal_port}  ${tmus_appinst_2.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[3].Appinstances[0].ports[0].public_port}    ${tmus_appinst_2.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[3].Appinstances[0].ports[0].FQDN_prefix}    ${tmus_appinst_2.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[4].CarrierName}                             ${tmus_appinst_3.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[4].CloudletName}                            ${tmus_appinst_3.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[4].GpsLocation.latitude}                    ${tmus_appinst_3.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[4].GpsLocation.longitude}                   ${tmus_appinst_3.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_5}                           ${distance_round_5}
      Should Be Equal             ${appfqdns[4].Appinstances[0].AppName}                 ${tmus_appinst_3.key.app_key.name}
      Should Be Equal             ${appfqdns[4].Appinstances[0].AppVers}                 ${tmus_appinst_3.key.app_key.version}
      Should Be Equal             ${appfqdns[4].Appinstances[0].FQDN}                    ${tmus_appinst_3.uri}
      Should Be Equal             ${appfqdns[4].Appinstances[0].ports[0].proto}          ${tmus_appinst_3.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[4].Appinstances[0].ports[0].internal_port}  ${tmus_appinst_3.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[4].Appinstances[0].ports[0].public_port}    ${tmus_appinst_3.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[4].Appinstances[0].ports[0].FQDN_prefix}    ${tmus_appinst_3.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[5].CarrierName}                             ${tmus_appinst_4.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[5].CloudletName}                            ${tmus_appinst_4.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[5].GpsLocation.latitude}                    ${tmus_appinst_4.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[5].GpsLocation.longitude}                   ${tmus_appinst_4.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_6}                           ${distance_round_6}
      Should Be Equal             ${appfqdns[5].Appinstances[0].AppName}                 ${tmus_appinst_4.key.app_key.name}
      Should Be Equal             ${appfqdns[5].Appinstances[0].AppVers}                 ${tmus_appinst_4.key.app_key.version}
      Should Be Equal             ${appfqdns[5].Appinstances[0].FQDN}                    ${tmus_appinst_4.uri}
      Should Be Equal             ${appfqdns[5].Appinstances[0].ports[0].proto}          ${tmus_appinst_4.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[5].Appinstances[0].ports[0].internal_port}  ${tmus_appinst_4.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[5].Appinstances[0].ports[0].public_port}    ${tmus_appinst_4.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[5].Appinstances[0].ports[0].FQDN_prefix}    ${tmus_appinst_4.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[6].CarrierName}                             ${tmus_appinst_5.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[6].CloudletName}                            ${tmus_appinst_5.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[6].GpsLocation.latitude}                    ${tmus_appinst_5.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[6].GpsLocation.longitude}                   ${tmus_appinst_5.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_7}                           ${distance_round_7}
      Should Be Equal             ${appfqdns[6].Appinstances[0].AppName}                 ${tmus_appinst_5.key.app_key.name}
      Should Be Equal             ${appfqdns[6].Appinstances[0].AppVers}                 ${tmus_appinst_5.key.app_key.version}
      Should Be Equal             ${appfqdns[6].Appinstances[0].FQDN}                    ${tmus_appinst_5.uri}
      Should Be Equal             ${appfqdns[6].Appinstances[0].ports[0].proto}          ${tmus_appinst_5.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[6].Appinstances[0].ports[0].internal_port}  ${tmus_appinst_5.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[6].Appinstances[0].ports[0].public_port}    ${tmus_appinst_5.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[6].Appinstances[0].ports[0].FQDN_prefix}    ${tmus_appinst_5.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[7].CarrierName}                             ${tmus_appinst_6.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[7].CloudletName}                            ${tmus_appinst_6.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[7].GpsLocation.latitude}                    ${tmus_appinst_6.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[7].GpsLocation.longitude}                   ${tmus_appinst_6.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_8}                           ${distance_round_8}
      Should Be Equal             ${appfqdns[7].Appinstances[0].AppName}                 ${tmus_appinst_6.key.app_key.name}
      Should Be Equal             ${appfqdns[7].Appinstances[0].AppVers}                 ${tmus_appinst_6.key.app_key.version}
      Should Be Equal             ${appfqdns[7].Appinstances[0].FQDN}                    ${tmus_appinst_6.uri}
      Should Be Equal             ${appfqdns[7].Appinstances[0].ports[0].proto}          ${tmus_appinst_6.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[7].Appinstances[0].ports[0].internal_port}  ${tmus_appinst_6.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[7].Appinstances[0].ports[0].public_port}    ${tmus_appinst_6.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[7].Appinstances[0].ports[0].FQDN_prefix}    ${tmus_appinst_6.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[8].CarrierName}                             ${tmus_appinst_7.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[8].CloudletName}                            ${tmus_appinst_7.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[8].GpsLocation.latitude}                    ${tmus_appinst_7.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[8].GpsLocation.longitude}                   ${tmus_appinst_7.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_9}                           ${distance_round_9}
      Should Be Equal             ${appfqdns[8].Appinstances[0].AppName}                 ${tmus_appinst_7.key.app_key.name}
      Should Be Equal             ${appfqdns[8].Appinstances[0].AppVers}                 ${tmus_appinst_7.key.app_key.version}
      Should Be Equal             ${appfqdns[8].Appinstances[0].FQDN}                    ${tmus_appinst_7.uri}
      Should Be Equal             ${appfqdns[8].Appinstances[0].ports[0].proto}          ${tmus_appinst_7.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[8].Appinstances[0].ports[0].internal_port}  ${tmus_appinst_7.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[8].Appinstances[0].ports[0].public_port}    ${tmus_appinst_7.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[8].Appinstances[0].ports[0].FQDN_prefix}    ${tmus_appinst_7.mapped_ports[0].FQDN_prefix}

      Should Be Equal             ${appfqdns[9].CarrierName}                             ${tmus_appinst_8.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[9].CloudletName}                            ${tmus_appinst_8.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[9].GpsLocation.latitude}                    ${tmus_appinst_8.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[9].GpsLocation.longitude}                   ${tmus_appinst_8.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round_10}                          ${distance_round_10}
      Should Be Equal             ${appfqdns[9].Appinstances[0].AppName}                 ${tmus_appinst_8.key.app_key.name}
      Should Be Equal             ${appfqdns[9].Appinstances[0].AppVers}                 ${tmus_appinst_8.key.app_key.version}
      Should Be Equal             ${appfqdns[9].Appinstances[0].FQDN}                    ${tmus_appinst_8.uri}
      Should Be Equal             ${appfqdns[9].Appinstances[0].ports[0].proto}          ${tmus_appinst_8.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[9].Appinstances[0].ports[0].internal_port}  ${tmus_appinst_8.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[9].Appinstances[0].ports[0].public_port}    ${tmus_appinst_8.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[9].Appinstances[0].ports[0].FQDN_prefix}    ${tmus_appinst_8.mapped_ports[0].FQDN_prefix}

      Length Should Be   ${appfqdns}  10
      Length Should Be   ${appfqdns[0].Appinstances}  1
      Length Should Be   ${appfqdns[0].Appinstances[0].ports}  1

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cluster Flavor
    Create Cluster	
    Create Cloudlet	   cloudlet_name=${cloudlet_name3}  operator_name=${operator_name}  latitude=3  longitude=3
    Create Cloudlet        cloudlet_name=${cloudlet_name4}  operator_name=${operator_name}  latitude=4  longitude=4
    Create Cloudlet        cloudlet_name=${cloudlet_name5}  operator_name=${operator_name}  latitude=5  longitude=5
    Create Cloudlet        cloudlet_name=${cloudlet_name6}  operator_name=${operator_name}  latitude=6  longitude=6
    Create Cloudlet        cloudlet_name=${cloudlet_name7}  operator_name=${operator_name}  latitude=7  longitude=7
    Create Cloudlet        cloudlet_name=${cloudlet_name8}  operator_name=${operator_name}  latitude=8  longitude=8
    #Create Cloudlet        cloudlet_name=${cloudlet_name9}  operator_name=${operator_name}  latitude=9  longitude=9
    #Create Cloudlet        cloudlet_name=${cloudlet_name10}  operator_name=${operator_name}  latitude=10  longitude=10

    Create Cloudlet        cloudlet_name=${gcp_cloudlet_name}  operator_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create Cloudlet        cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}

    Create App			access_ports=tcp:1  permits_platform_apps=${True}
    ${tmus_appinst_1}=           Create App Instance  cloudlet_name=${cloudlet_name_1}  operator_name=${operator_name}
    ${tmus_appinst_2}=           Create App Instance  cloudlet_name=${cloudlet_name_2}  operator_name=${operator_name}
    ${tmus_appinst_3}=           Create App Instance  cloudlet_name=${cloudlet_name_3}  operator_name=${operator_name}
    ${tmus_appinst_4}=           Create App Instance  cloudlet_name=${cloudlet_name_4}  operator_name=${operator_name}
    ${tmus_appinst_5}=           Create App Instance  cloudlet_name=${cloudlet_name_5}  operator_name=${operator_name}
    ${tmus_appinst_6}=           Create App Instance  cloudlet_name=${cloudlet_name_6}  operator_name=${operator_name}
    ${tmus_appinst_7}=           Create App Instance  cloudlet_name=${cloudlet_name_7}  operator_name=${operator_name}
    ${tmus_appinst_8}=           Create App Instance  cloudlet_name=${cloudlet_name_8}  operator_name=${operator_name}
    #${tmus_appinst_9}=           Create App Instance  cloudlet_name=${cloudlet_name_9}  operator_name=${operator_name}
    #${tmus_appinst_10}=           Create App Instance  cloudlet_name=${cloudlet_name_10}  operator_name=${operator_name}

    ${gcp_appinst}=             Create App Instance         cloudlet_name=${gcp_cloudlet_name}  operator_name=${gcp_operator_name}
    ${azure_appinst}=           Create App Instance         cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}

    Set Suite Variable  ${tmus_appinst_1} 
    Set Suite Variable  ${tmus_appinst_2}
    Set Suite Variable  ${tmus_appinst_3}
    Set Suite Variable  ${tmus_appinst_4}
    Set Suite Variable  ${tmus_appinst_5}
    Set Suite Variable  ${tmus_appinst_6}
    Set Suite Variable  ${tmus_appinst_7}
    Set Suite Variable  ${tmus_appinst_8}
    #Set Suite Variable  ${tmus_appinst_9}
    #Set Suite Variable  ${tmus_appinst_10}

    Set Suite Variable  ${gcp_appinst}
    Set Suite Variable  ${azure_appinst}


