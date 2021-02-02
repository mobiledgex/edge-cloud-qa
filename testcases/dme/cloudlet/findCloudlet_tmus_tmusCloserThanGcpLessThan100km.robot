*** Settings ***
Documentation   FindCloudlet - request shall return tmus with gcp cloudlet provisioned and tmus closer and < 100km from request
...		tmus tmocloud-2 cloudlet at: 35 -95
...             gcp gcpcloud-1  cloudlet at: 37 -95
...		find cloudlet closest to   : 35 -94
...                91.09km from tmus
...                239.89km  from gcp
...             tmus closer than and gcp but less than 100km. return tmus cloudlet
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
...                   name: gcp
...                 name: gcpcloud-1
...               location:
...                 lat: 37
...                 long: -95
...

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${gcp_operator_name}  gcp
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95
${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -95

*** Test Cases ***
FindCloudlet - request shall return tmus with gcp cloudlet provisioned and tmus closer and < 100km from request
    [Documentation]
    ...  findCloudlet with with tmus and gcp. tmus closer and < 100km from request - return tmus
    ...		tmus tmocloud-2 cloudlet at: 35 -95
    ...         gcp gcpcloud-1  cloudlet at: 37 -95
    ...		find cloudlet closest to   : 35 -94
    ...                91.09km from tmus
    ...                239.89km  from gcp
    ...             tmus closer than and gcp but less than 100km. return tmus cloudlet
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
    ...                   name: gcp
    ...                 name: gcpcloud-1
    ...               location:
    ...                 lat: 37
    ...                 long: -95
      #Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      #${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=35  longitude=-94

      Register Client  
      ${cloudlet}=  Find Cloudlet  carrier_name=${tmus_operator_name}  latitude=35  longitude=-94

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${tmus_appinst.uri}  #acmeappcosomeapplication210.tmocloud-2.tmus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}  ${tmus_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${tmus_cloudlet_longitude}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${tmus_appinst.mapped_ports[0].proto}   #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${tmus_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${tmus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${tmus_appinst.mapped_ports[0].fqdn_prefix}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}


    #Create Operator             operator_org_name=${tmus_operator_name} 
    #Create Operator             operator_org_name=${gcp_operator_name} 
    #Create Developer
    Create Flavor
    Create Cloudlet		cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    #Create Cluster
    Create App
    ${tmus_appinst}=            Create App Instance         cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster
    Create App Instance         cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst} 

    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_org_name=${public_operator_name}  number_of_dynamic_ips=default  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    #Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}

    #Create Cluster		cluster_name=default  default_flavor_name=${flavor}
    #Create App			app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  cluster_name=default  default_flavor_name=${flavor}
    #Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
    #Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_org_name=${public_operator_name}
