*** Settings ***
Documentation   FindCloudlet REST - request with timestamp shall return dmuus
...		dmuus tmocloud-2 cloudlet at: 35 -95
...             azure azurecloud-1  cloudlet at: 37 -95
...		find cloudlet closest to   : 34 -96
...                144.09km from dmuus
...                345.64km  from azure
...             dmuus closer than azure. return dmuus cloudlet
...
...             ShowCloudlet
...             - key:
...                 operatorkey:
...                   name: dmuus
...                 name: tmocloud-2
...               location:
...                 lat: 35
...                 long: -95
...             - key:
...                 operatorkey:
...                   name: azure
...                 name: azurecloud-1
...               location:
...                 lat: 37
...                 long: -95
...

Library         MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure
${dmuus_operator_name}   dmuus
${dmuus_cloudlet_name}   tmocloud-2  #has to match crm process startup parms
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms

${azure_cloudlet_latitude}	  37
${azure_cloudlet longitude}	  -95
${dmuus_cloudlet_latitude}	  35
${dmuus_cloudlet longitude}	  -95

*** Test Cases ***
FindCloudlet REST - request with timestamp shall return dmuus
    [Documentation]
    ...  findCloudlet rest with dmuus and azure provisioned. dmuus closer and > 100km from request. return dmuus
    ...             dmuus tmocloud-2 cloudlet at: 35 -95
    ...             azure azurecloud-1  cloudlet at: 37 -95
    ...             find cloudlet closest to   : 34 -96
    ...                144.09km from dmuus
    ...                345.64km  from azure
    ...             dmuus closer than azure. return dmuus cloudlet
    ...
    ...             ShowCloudlet
    ...             - key:
    ...                 operatorkey:
    ...                   name: dmuus
    ...                 name: tmocloud-2
    ...               location:
    ...                 lat: 35
    ...                 long: -95
    ...             - key:
    ...                 operatorkey:
    ...                   name: azure
    ...                 name: azurecloud-1
    ...               location:
    ...                 lat: 37
    ...                 long: -95

      Register Client	
      Log to console  after register
      ${cloudlet}=  Find Cloudlet	carrier_name=${dmuus_operator_name}  latitude=34  longitude=-96  seconds=10  nanos=1

      Should Be Equal  ${cloudlet['status']}  FIND_FOUND

      Should Be Equal             ${cloudlet['fqdn']}                         ${dmuus_appinst.uri}
      Should Be Equal As Numbers  ${cloudlet['cloudlet_location']['latitude']}   ${dmuus_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet['cloudlet_location']['longitude']}  ${dmuus_cloudlet_longitude}

      Should Be Equal   ${cloudlet['ports'][0]['proto']}                         L_PROTO_TCP 
      Should Be Equal As Numbers  ${cloudlet['ports'][0]['internal_port']}       ${dmuus_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet['ports'][0]['public_port']}         ${dmuus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet['ports'][0]['fqdn_prefix']}         ${dmuus_appinst.mapped_ports[0].fqdn_prefix}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    #Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name}  operator_org_name=${dmuus_operator_name}  latitude=${dmuus_cloudlet_latitude}  longitude=${dmuus_cloudlet_longitude}
    #Create Cluster	
    Create App			access_ports=tcp:1 
    ${dmuus_appinst}=            Create App Instance  cloudlet_name=${dmuus_cloudlet_name}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${dmuus_appinst} 

