*** Settings ***
Documentation   GetAppInstList - request shall return azure app

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure 
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms

${azure_cloudlet_latitude}	  37
${azure_cloudlet longitude}	  -95

${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
GetAppInstList - request shall return azure app
    [Documentation]
    ...  add azure app
    ...  registerClient
    ...  send GetAppInstList for azure app
    ...  verify returns azure result

      Register Client  
      ${appfqdns}=  Get App Instance List  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest}=    Create List  ${appfqdns[0].GpsLocation.latitude}  ${appfqdns[0].GpsLocation.longitude}
      ${distance}=  Calculate Distance  ${origin}  ${dest} 
      ${distance_round}=  Convert To Number  ${distance}  1
      ${appfqdns_distance_round}=  Convert To Number  ${appfqdns[0].Distance}  1  

      Should Be Equal             ${appfqdns[0].CarrierName}                             ${azure_appinst.key.cluster_inst_key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[0].CloudletName}                            ${azure_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].GpsLocation.latitude}                    ${azure_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].GpsLocation.longitude}                   ${azure_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round}                             ${distance_round}
      Should Be Equal             ${appfqdns[0].Appinstances[0].AppName}                 ${azure_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].Appinstances[0].AppVers}                 ${azure_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].Appinstances[0].FQDN}                    ${azure_appinst.uri}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].proto}          ${azure_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].internal_port}  ${azure_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].public_port}    ${azure_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].Appinstances[0].ports[0].FQDN_prefix}    ${azure_appinst.mapped_ports[0].FQDN_prefix}

      Length Should Be   ${appfqdns}  1
      Length Should Be   ${appfqdns[0].Appinstances}  1
      Length Should Be   ${appfqdns[0].Appinstances[0].ports}  1

*** Keywords ***
Setup
    #Create Operator             operator_name=${tmus_operator_name} 
    #Create Operator             operator_name=${gcp_operator_name} 
    Create Developer
    Create Flavor
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    Create Cluster
    Create App                  access_ports=tcp:1 
    ${azure_appinst}=             Create App Instance         cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${azure_appinst} 
