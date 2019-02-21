*** Settings ***
Documentation   GetAppInstList - request shall not return default cloudlet apps

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms

${dmuus_cloudlet_latitude}	  35
${dmuus_cloudlet longitude}	  -95

${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
GetAppInstList - request shall not return default cloudlet apps
    [Documentation]
    ...  create an appinst with cloudlet_name=tmocloud-2 and operator_name=dmuus
    ...  create an appinst with cloudlet_name=default and operator_name=developer
    ...  registerClient
    ...  send GetAppInstList
    ...  verify returns only tmocloud-2 app and not default cloudlet app
      
      Register Client  
      ${appfqdns}=  Get App Instance List  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest}=    Create List  ${appfqdns[0].GpsLocation.latitude}  ${appfqdns[0].GpsLocation.longitude}
      ${distance}=  Calculate Distance  ${origin}  ${dest} 
      ${distance_round}=  Convert To Number  ${distance}  1
      ${appfqdns_distance_round}=  Convert To Number  ${appfqdns[0].Distance}  1  

      Should Be Equal             ${appfqdns[0].CarrierName}                             ${dmuus_appinst.key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[0].CloudletName}                            ${dmuus_appinst.key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].GpsLocation.latitude}                    ${dmuus_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].GpsLocation.longitude}                   ${dmuus_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round}                             ${distance_round}
      Should Be Equal             ${appfqdns[0].Appinstances[0].AppName}                 ${dmuus_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].Appinstances[0].AppVers}                 ${dmuus_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].Appinstances[0].FQDN}                    ${dmuus_appinst.uri}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].proto}          ${dmuus_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].internal_port}  ${dmuus_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].public_port}    ${dmuus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].FQDN_prefix}    ${dmuus_appinst.mapped_ports[0].FQDN_prefix}

      Length Should Be   ${appfqdns}  1
      Length Should Be   ${appfqdns[0].Appinstances}  1
      Length Should Be   ${appfqdns[0].Appinstances[0].ports}  1

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor
    Create Cluster
    Create App                  access_ports=tcp:1  
    ${dmuus_appinst}=            Create App Instance         cloudlet_name=${dmuus_cloudlet_name}  operator_name=${dmuus_operator_name}
    Create App Instance         cloudlet_name=default  operator_name=developer  uri=http://andy.com

    Set Suite Variable  ${dmuus_appinst} 
