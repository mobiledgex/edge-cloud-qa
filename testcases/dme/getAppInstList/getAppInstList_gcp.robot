*** Settings ***
Documentation   GetAppInstList - request shall return GCP app

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${gcp_operator_name}  gcp
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms

${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -95

${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
GetAppInstList - request shall return GCP app
    [Documentation]
    ...  add GCP app
    ...  registerClient
    ...  send GetAppInstList for GCP app
    ...  verify returns GCP result

      Register Client  
      ${appfqdns}=  Get App Instance List  latitude=${mobile_latitude}  longitude=${mobile_longitude}

      @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}
      @{dest}=    Create List  ${appfqdns[0].gps_location.latitude}  ${appfqdns[0].gps_location.longitude}
      ${distance}=  Calculate Distance  ${origin}  ${dest} 
      ${distance_round}=  Convert To Number  ${distance}  1
      ${appfqdns_distance_round}=  Convert To Number  ${appfqdns[0].distance}  1  

      Should Be Equal             ${appfqdns[0].carrier_name}                             ${gcp_appinst.key.cluster_inst_key.cloudlet_key.operator_key.name}
      Should Be Equal             ${appfqdns[0].cloudlet_name}                            ${gcp_appinst.key.cluster_inst_key.cloudlet_key.name}
      Should Be Equal             ${appfqdns[0].gps_location.latitude}                    ${gcp_appinst.cloudlet_loc.latitude}
      Should Be Equal             ${appfqdns[0].gps_location.longitude}                   ${gcp_appinst.cloudlet_loc.longitude}
      Should Be Equal             ${appfqdns_distance_round}                             ${distance_round}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_name}                 ${gcp_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].appinstances[0].app_vers}                 ${gcp_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].appinstances[0].fqdn}                    ${gcp_appinst.uri}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].proto}          ${gcp_appinst.mapped_ports[0].proto}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].internal_port}  ${gcp_appinst.mapped_ports[0].internal_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].public_port}    ${gcp_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${appfqdns[0].appinstances[0].ports[0].fqdn_prefix}    ${gcp_appinst.mapped_ports[0].fqdn_prefix}

      Length Should Be   ${appfqdns}  1
      Length Should Be   ${appfqdns[0].appinstances}  1
      Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

*** Keywords ***
Setup
    #Create Operator             operator_name=${tmus_operator_name} 
    #Create Operator             operator_name=${gcp_operator_name} 
    Create Developer
    Create Flavor
    Create Cloudlet		cloudlet_name=${gcp_cloudlet_name}  operator_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    #Create Cluster
    Create App                  access_ports=tcp:1 
    ${gcp_appinst}=             Create App Instance         cloudlet_name=${gcp_cloudlet_name}  operator_name=${gcp_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${gcp_appinst} 
