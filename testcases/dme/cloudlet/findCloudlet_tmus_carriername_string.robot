*** Settings ***
Documentation   FindCloudlet - request shall return tmus with no gcp/azure cloudlet provisioned

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library  String
Variables      shared_variables.py

Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication   #has to match crm process startup parms
${region}  US
#${code}  qwerty
${developer_name}  AcmeAppCo
${app_version}  1.0
${access_ports}    tcp:80,tcp:443,udp:10002
${operator_name}   tmus
${cloudlet_name1}  tmocloud-1
${cloudlet_lat1}   31
${cloudlet_long1}  -91
${cloudlet_name2}  tmocloud-2
${cloudlet_lat2}   35
${cloudlet_long2}  -95

*** Test Cases ***
FindCloudlet - request shall return tmus with no gcp/azure provisioned ond same coord as tmocloud-1
    [Documentation]
    ...  send findCloudlet with same coord as tmocloud-1 and no gcp/azure provisioned. return tmocloud-1
      log to console  ${appinst_1}
      Register Client
      ${cloudlet}=  Find Cloudlet  carrier_name=${code}  latitude=31  longitude=-91

      ${fqdn_prefix_tcp}=             Catenate  SEPARATOR=  ${app_name_default}  -  tcp  .
      ${fqdn_prefix_udp}=             Catenate  SEPARATOR=  ${app_name_default}  -  udp  .
      ${fqdn_prefix_http}=            Catenate  SEPARATOR=  ${app_name_default}  -  tcp  .

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${appinst_1['data']['uri']}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          1
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst_1['data']['mapped_ports'][0]['internal_port']}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst_1['data']['mapped_ports'][0]['public_port']}
      #Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${appinst_1['data']['mapped_ports'][0]['fqdn_prefix']}

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}          1 
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  ${appinst_1['data']['mapped_ports'][1]['internal_port']}
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}    ${appinst_1['data']['mapped_ports'][1]['public_port']}
      #Should Be Equal             ${cloudlet.ports[1].fqdn_prefix}    ${appinst_1['data']['mapped_ports'][1]['fqdn_prefix']}

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}          2 
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  ${appinst_1['data']['mapped_ports'][2]['internal_port']}
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}    ${appinst_1['data']['mapped_ports'][2]['public_port']}
      #Should Be Equal             ${cloudlet.ports[2].fqdn_prefix}    ${appinst_1['data']['mapped_ports'][2]['fqdn_prefix']}

*** Keywords ***
Setup
    ${code}=  Generate Random String  length=5
    Create Operator Code     operator_org_name=${operator_name}  code=${code}  region=${region}
    #Create Developer
    Create Flavor  region=${region}
#    CreateOperatorCode  region=${region}
    #Create Cloudlet	   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    #Create Cloudlet	   cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}
    #Create Cluster
    Create App             access_ports=${access_ports}  region=${region}
     #${appinst_1}=          Create App Instance    region=${region}  app_name=automation_api_app  app_version=1.0  developer_name=automation_api  cluster_instance_name=autoclusterAutomatio  cluster_instance_developer_name=automation_api  cloudlet_name=tmocloud-1  operator_org_name=tmus  flavor_name=automation_api_flavor
     ${appinst_1}=          Create App Instance    region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
     ${appinst_2}=          Create App Instance    region=${region}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${appinst_1}
    Set Suite Variable  ${appinst_2}
    Set Suite Variable  ${code}

