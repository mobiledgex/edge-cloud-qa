*** Settings ***
Documentation   FindCloudlet - request shall return dmuus with no gcp/azure cloudlet provisioned

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables      shared_variables.py
	
Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0
${access_ports}    tcp:80,tcp:443,udp:10002
${operator_name}   dmuus
${cloudlet_name1}  tmocloud-1
${cloudlet_lat1}   31
${cloudlet_long1}  -91
${cloudlet_name2}  tmocloud-2
${cloudlet_lat2}   35
${cloudlet_long2}  -95

*** Test Cases ***
FindCloudlet - request shall return dmuus with no gcp/azure provisioned ond same coord as tmocloud-1
    [Documentation]
    ...  send findCloudlet with same coord as tmocloud-1 and no gcp/azure provisioned. return tmocloud-1

      Register Client
      ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name}  latitude=31  longitude=-91

      ${fqdn_prefix_tcp}=             Catenate  SEPARATOR=  ${app_name_default}  -  tcp  .	
      ${fqdn_prefix_udp}=             Catenate  SEPARATOR=  ${app_name_default}  -  udp  .	
      ${fqdn_prefix_http}=            Catenate  SEPARATOR=  ${app_name_default}  -  http  .	

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${appinst_1.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${appinst_1.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst_1.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${appinst_1.mapped_ports[0].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}          ${appinst_1.mapped_ports[1].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  ${appinst_1.mapped_ports[1].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}    ${appinst_1.mapped_ports[1].public_port}
      Should Be Equal             ${cloudlet.ports[1].fqdn_prefix}    ${appinst_1.mapped_ports[1].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}          ${appinst_1.mapped_ports[2].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  ${appinst_1.mapped_ports[2].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}    ${appinst_1.mapped_ports[2].public_port}
      Should Be Equal             ${cloudlet.ports[2].fqdn_prefix}    ${appinst_1.mapped_ports[2].fqdn_prefix}

FindCloudlet - request shall return dmuus with no gcp/azure provisioned ond same coord as tmocloud-2
    [Documentation]
    ...  send findCloudlet with same coord as tmocloud-2 and no gcp/azure provisioned. return tmocloud-2
      
      Register Client
      ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name}  latitude=35  longitude=-95

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${appinst_2.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${appinst_2.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst_2.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst_2.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${appinst_2.mapped_ports[0].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}          ${appinst_2.mapped_ports[1].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  ${appinst_2.mapped_ports[1].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}    ${appinst_2.mapped_ports[1].public_port}
      Should Be Equal             ${cloudlet.ports[1].fqdn_prefix}    ${appinst_2.mapped_ports[1].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}          ${appinst_2.mapped_ports[2].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  ${appinst_2.mapped_ports[2].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}    ${appinst_2.mapped_ports[2].public_port}
      Should Be Equal             ${cloudlet.ports[2].fqdn_prefix}    ${appinst_2.mapped_ports[2].fqdn_prefix}

FindCloudlet - request shall return dmuus with no gcp/azure provisioned ond coord closer to tmocloud-1
    [Documentation]
    ...  send findCloudlet with coord closer to tmocloud-1 and no gcp/azure provisioned. return tmocloud-1
      
      Register Client	
      ${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=23  longitude=-4

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${appinst_1.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${appinst_1.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst_1.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${appinst_1.mapped_ports[0].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}          ${appinst_1.mapped_ports[1].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  ${appinst_1.mapped_ports[1].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}    ${appinst_1.mapped_ports[1].public_port}
      Should Be Equal             ${cloudlet.ports[1].fqdn_prefix}    ${appinst_1.mapped_ports[1].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}          ${appinst_1.mapped_ports[2].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  ${appinst_1.mapped_ports[2].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}    ${appinst_1.mapped_ports[2].public_port}
      Should Be Equal             ${cloudlet.ports[2].fqdn_prefix}    ${appinst_1.mapped_ports[2].fqdn_prefix}

FindCloudlet - request shall return dmuus with no gcp/azure provisioned ond coord closer to tmocloud-2
    [Documentation]
    ...  send findCloudlet with coord closer to tmocloud-2 and no gcp/azure provisioned. return tmocloud-2
      
      Register Client	
      ${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=35  longitude=-96

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${appinst_2.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${appinst_2.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst_2.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst_2.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${appinst_2.mapped_ports[0].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}          ${appinst_2.mapped_ports[1].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  ${appinst_2.mapped_ports[1].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}    ${appinst_2.mapped_ports[1].public_port}
      Should Be Equal             ${cloudlet.ports[1].fqdn_prefix}    ${appinst_2.mapped_ports[1].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}          ${appinst_2.mapped_ports[2].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  ${appinst_2.mapped_ports[2].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}    ${appinst_2.mapped_ports[2].public_port}
      Should Be Equal             ${cloudlet.ports[2].fqdn_prefix}    ${appinst_2.mapped_ports[2].fqdn_prefix}

FindCloudlet - request shall return dmuus with no gcp/azure provisioned ond coord of max distance 
    [Documentation]
    ...  send findCloudlet with coord of max distance and no gcp/azure provisioned. return tmocloud-1
     
      # EDGECLOUD-348 - FindCloudlet - request should not allow invalid GPS coordinates

      # tmocloud-1  31/-91 distance from -90/180 is 13454.59km (closer)
      # tmocloud-2  35/-95 distance from -90/180 is 13899.37km
	
      Register Client	
      #${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=35000000000  longitude=-96000000000
      ${cloudlet}=  Find Cloudlet      carrier_name=${operator_name}  latitude=-90  longitude=180

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
  
      Should Be Equal             ${cloudlet.fqdn}  ${appinst_1.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${appinst_1.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst_1.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${appinst_1.mapped_ports[0].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}          ${appinst_1.mapped_ports[1].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  ${appinst_1.mapped_ports[1].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}    ${appinst_1.mapped_ports[1].public_port}
      Should Be Equal             ${cloudlet.ports[1].fqdn_prefix}    ${appinst_1.mapped_ports[1].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}          ${appinst_1.mapped_ports[2].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  ${appinst_1.mapped_ports[2].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}    ${appinst_1.mapped_ports[2].public_port}
      Should Be Equal             ${cloudlet.ports[2].fqdn_prefix}    ${appinst_1.mapped_ports[2].fqdn_prefix}

FindCloudlet - request shall return dmuus with no gcp/azure provisioned ond coord of min distance
    [Documentation]
    ...  send findCloudlet with coord of min distance and no gcp/azure provisioned. return tmocloud-1
      
      Register Client	
      ${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=0.0000001  longitude=0.0000001

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${appinst_1.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${appinst_1.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst_1.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst_1.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${appinst_1.mapped_ports[0].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}          ${appinst_1.mapped_ports[1].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  ${appinst_1.mapped_ports[1].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}    ${appinst_1.mapped_ports[1].public_port}
      Should Be Equal             ${cloudlet.ports[1].fqdn_prefix}    ${appinst_1.mapped_ports[1].fqdn_prefix}

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}          ${appinst_1.mapped_ports[2].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  ${appinst_1.mapped_ports[2].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}    ${appinst_1.mapped_ports[2].public_port}
      Should Be Equal             ${cloudlet.ports[2].fqdn_prefix}    ${appinst_1.mapped_ports[2].fqdn_prefix}

*** Keywords ***
Setup
    #Create Operator        operator_org_name=${operator_name} 
    #Create Developer
    Create Flavor
    #Create Cloudlet	   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    #Create Cloudlet	   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}
    #Create Cluster
    Create App             access_ports=${access_ports} 
    ${appinst_1}=          Create App Instance    cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${appinst_2}=          Create App Instance    cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${appinst_1} 
    Set Suite Variable  ${appinst_2}


