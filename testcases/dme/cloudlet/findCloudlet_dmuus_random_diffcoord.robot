*** Settings ***
Documentation   FindCloudlet with cloudlets at diff coord witin 1km

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name2}  tmocloud-2  #has to match crm process startup parms
${dmuus_cloudlet_name1}  tmocloud-1  #has to match crm process startup parms

${num_found_1}=  ${0}
${num_found_2}=  ${0}
${num_finds}=  ${0}

*** Test Cases ***
# ECQ-2797
FindCloudlet - request shall return random cloudlet when 2 cloudlets are within 1k
    [Documentation]
    ...  - provision cloudlet with coord withinin 1km as tmocloud-2
    ...  - create same appinst on both cloudlets
    ...  - send FindCloudlet with same coord as cloudlets and within 1km
    ...  - verify it returns each of the cloudlets at about 50% ratio 

    [Template]  Find Cloudlet for dmuus closest to latitude ${lat} longitude ${long} should return ${expected_cloudlet} with latitude ${expected_lat} longitude ${expected_long}
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95.01  ${appinst_2.uri}      35  -95
        35  -95.01  ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95.01   ${appinst_2.uri}      35  -95
        35  -95.01  ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95
        35  -95   ${appinst_2.uri}      35  -95

*** Keywords ***
Find Cloudlet for dmuus closest to latitude ${lat} longitude ${long} should return ${expected_cloudlet} with latitude ${expected_lat} longitude ${expected_long}
      ${cloudlet}=  Find Cloudlet	carrier_name=${dmuus_operator_name}  latitude=${lat}  longitude=${long}

      ${num_finds}=  Evaluate  ${num_finds} + 1
      Set Test Variable  ${num_finds}

      ${num_found_1}=  Set Variable If  '${cloudlet.fqdn}' == '${appinst_2.uri}'  ${num_found_1+1}  ${num_found_1}
      Set Test Variable  ${num_found_1}

      ${num_found_2}=  Set Variable If  '${cloudlet.fqdn}' == '${appinst_3.uri}'  ${num_found_2+1}  ${num_found_2}
      Set Test Variable  ${num_found_2}

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
      Should Be True  '${cloudlet.fqdn}' == '${appinst_2.uri}' or '${cloudlet.fqdn}' == '${appinst_3.uri}'
      Should Not Be Equal  ${cloudlet.fqdn}  ${appinst_4.uri}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  8888 
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  8888 
    
    
Setup
    ${epoch}=  Get Time  epoch
    ${t3}=  Catenate  SEPARATOR=  tmocloud-3  ${epoch}
    ${t4}=  Catenate  SEPARATOR=  tmocloud-4  ${epoch}

    Create Flavor

    Create Cloudlet		cloudlet_name=${t3}  operator_org_name=dmuus  latitude=35  longitude=-95.01
    Create Cloudlet             cloudlet_name=${t4}  operator_org_name=dmuus  latitude=35  longitude=-95.1  # more than 1k from other 2 cloudlets

    Create App			access_ports=tcp:8888  
    ${appinst_1}=               Create App Instance		cloudlet_name=${dmuus_cloudlet_name1}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_2}=               Create App Instance		cloudlet_name=${dmuus_cloudlet_name2}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_3}=               Create App Instance		cloudlet_name=${t3}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_4}=               Create App Instance             cloudlet_name=${t4}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster

    Register Client	

    Set Suite Variable  ${appinst_1} 
    Set Suite Variable  ${appinst_2} 
    Set Suite Variable  ${appinst_3} 
    Set Suite Variable  ${appinst_4}

Teardown
    Cleanup provisioning
    Should Be True  ${num_found_1}/${num_finds}*100 > 35
    Should Be True  ${num_found_2}/${num_finds}*100 > 35
 
