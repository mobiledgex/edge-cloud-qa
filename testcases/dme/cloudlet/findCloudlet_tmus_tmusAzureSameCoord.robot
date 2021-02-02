*** Settings ***
Documentation   FindCloudlet - request shall return tmus with azure cloudlet provisioned and tmus and azure same coord
...		tmus tmocloud-2 cloudlet at: 35 -95
...             azure azurecloud-1  cloudlet at: 35 -95
...		find cloudlet closest to   : 36 -95
...                111.19km from tmus
...                111.19km  from azure
...             tmus and azure are same coord/distance. return tmus cloudlet
...
...             ShowCloudlet
...             - key:
...                 operatorkey:
...                   name: tmus
...                 name: tmocloud-2
...               location:
...                 lat: 35
...                 long: -95
...             - key:
...                 operatorkey:
...                   name: azure
...                 name: azurecloud-1
...               location:
...                 lat: 35
...                 long: -95
...

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${azure_cloudlet_latitude}	  35
${azure_cloudlet longitude}	  -95
${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95

*** Test Cases ***
FindCloudlet - request shall return tmus with azure cloudlet provisioned and tmus and azure same coord
    [Documentation]
    ...  findCloudlet with tmus and azure provisioned. tmus and azure same coord. return tmus
    ...             tmus tmocloud-2 cloudlet at: 35 -95
    ...             azure azurecloud-1  cloudlet at: 35 -95
    ...             find cloudlet closest to   : 36 -95
    ...                111.19km from tmus
    ...                111.19km  from azure
    ...             tmus and azure are same coord/distance. return tmus cloudlet
    ...
    ...             ShowCloudlet
    ...             - key:
    ...                 operatorkey:
    ...                   name: tmus
    ...                 name: tmocloud-2
    ...               location:
    ...                 lat: 35
    ...                 long: -95
    ...             - key:
    ...                 operatorkey:
    ...                   name: azure
    ...                 name: azurecloud-1
    ...               location:
    ...                 lat: 35
    ...                 long: -95

      Register Client	
      ${cloudlet}=  Find Cloudlet	carrier_name=${tmus_operator_name}  latitude=36  longitude=-95

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}                         ${tmus_appinst.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${tmus_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${tmus_cloudlet_longitude}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${tmus_appinst.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${tmus_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${tmus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${tmus_appinst.mapped_ports[0].fqdn_prefix}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    #Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    #Create Cluster		
    Create App			access_ports=tcp:1  
    ${tmus_appinst}=            Create App Instance		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst} 
