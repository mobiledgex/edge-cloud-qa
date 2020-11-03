*** Settings ***
Documentation   GetAppInstList - request shall return 1 app with operator code

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_wifi_name}  wifi 
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1
${region}  US

*** Test Cases ***
GetAppInstList - request with opertor code mapping shall return 1 app
    [Documentation]
    ...  registerClient
    ...  send GetAppInstList with operator code for 1 app
    ...  verify returns 1 result

      Register Client
      ${appfqdns}=  Get App Instance List  carrier_name=${operator_wifi_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      ${distance}=  Calculate Distance  ${origin}  ${dest} 
      ${distance_round}=  Convert To Number  ${distance}  1
      ${appfqdns_distance_round}=  Convert To Number  ${appfqdns[0].distance}  1  
      log to console  ${tmus_appinst}
      Should Be Equal             ${appfqdns[0].carrier_name}                             ${tmus_appinst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${tmus_appinst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${tmus_appinst[0]['data']['cloudlet_loc']['latitude']}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${tmus_appinst[0]['data']['cloudlet_loc']['longitude']}
      Should Be Equal             ${appfqdns_distance_round}                             ${distance_round}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${tmus_appinst[0]['data']['key']['app_key']['name']}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${tmus_appinst[0]['data']['key']['app_key']['version']}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${tmus_appinst[0]['data']['uri']}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${tmus_appinst[0]['data']['mapped_ports'][0]['proto']}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${tmus_appinst[0]['data']['mapped_ports'][0]['internal_port']}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${tmus_appinst[0]['data']['mapped_ports'][0]['public_port']}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${tmus_appinst[0]['data']['mapped_ports'][0]['fqdn_prefix']}

      Should Be Equal             ${appfqdns[0].carrier_name}  ${operator_name}

      Length Should Be   ${appfqdns}  1
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

*** Keywords ***
Setup
    Create Flavor  region=${region}
    Create App		region=${region}  access_ports=tcp:1  #permits_platform_apps=${True}
    ${tmus_appinst}=           Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    Create Operator Code  region=${region}  operator_org_name=${operator_name}  code=${operator_wifi_name}

    Set Suite Variable  ${tmus_appinst} 


