*** Settings ***
Documentation   findCloudlet without carrier with att and tmus and gcp. tmus farther but greater than 100km from gcp - return gcp
...		tmus tmocloud-2 cloudlet at: 35 -95
...             gcp gcpcloud-1  cloudlet at: 37 -95
...		find cloudlet closest to   : 37 -96
...                239.89km from tmus
...                88.80km  from gcp
...             gcp is closer by 151.09km which is more than 100km closer. return gcp cloudlet
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
#edgectl controller --tls ~/localserver.crt CreateOperator --key-name gcp
#edgectl controller --tls ~/localserver.crt CreateCloudlet --key-name tmocloud-2 --key-operatorkey-name gcp --location-lat 50 --location-long 50 --numdynamicips 254
#edgectl controller --tls ~/localserver.crt CreateApp --key-name app2 --key-developerkey-name AcmeAppCo --key-version 1.0 --imagetype ImageTypeDocker --accessports tcp:1 --cluster-name SmallCluster --defaultflavor-name x1.small --ipaccess IpAccessDedicated

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
	
Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
#${dme_api_address}  127.0.0.1:50051
#${controller_api_address}  127.0.0.1:55001
${azure_operator_name}  azure
${tmus_operator_name}  tmus
${att_operator_name}  att 
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${att_cloudlet_name}  attcloud-1  #has to match crm process startup parms

${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95
${azure_cloudlet_latitude}	  37
${azure_cloudlet longitude}	  -95
${att_cloudlet_latitude}         35
${att_cloudlet longitude}        -96

*** Test Cases ***
# ECQ-2109
FindCloudlet - findCloudlet without carrier shall return cloudlet regardless of carrier
    [Documentation]   
    ...  findCloudlet without carrier name and with att and tmus and azure.
    ...  verify returns each appinst based on location only
    ...		tmus tmocloud-2 cloudlet at: 35 -95
    ...         azure azurecloud-1  cloudlet at: 37 -95
    ...
    ...		find cloudlet closest to   : 37 -96
    ...                239.89km from tmus
    ...                88.80km  from azure
    ...             azure is closer by 151.09km which is more than 100km closer. return azure cloudlet
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
    ...                 lat: 37
    ...                 long: -95

    # find azure
    ${reg}=  Register Client	
    ${cloudlet}=  Find Cloudlet  session_cookie=${reg.session_cookie}  latitude=37  longitude=-96  use_defaults=${False}

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

    Should Be Equal             ${cloudlet.fqdn}  ${azure_appinst.uri}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${azure_cloudlet_latitude}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${azure_cloudlet_longitude}

    Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  ${azure_appinst.mapped_ports[0].proto}  #LProtoTCP
    Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${azure_appinst.mapped_ports[0].internal_port}
    Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  ${azure_appinst.mapped_ports[0].public_port}
    Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}  ${azure_appinst.mapped_ports[0].fqdn_prefix}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    # find att
    ${reg}=  Register Client
    ${cloudlet}=  Find Cloudlet  session_cookie=${reg.session_cookie}  latitude=35  longitude=-96  use_defaults=${False}

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

    Should Be Equal             ${cloudlet.fqdn}  ${att_appinst.uri}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${att_cloudlet_latitude}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${att_cloudlet_longitude}

    Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  ${att_appinst.mapped_ports[0].proto}  #LProtoTCP
    Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${att_appinst.mapped_ports[0].internal_port}
    Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  ${att_appinst.mapped_ports[0].public_port}
    Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}  ${att_appinst.mapped_ports[0].fqdn_prefix}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    # find tmus
    ${reg}=  Register Client
    ${cloudlet}=  Find Cloudlet  session_cookie=${reg.session_cookie}  latitude=35  longitude=-95  use_defaults=${False}

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

    Should Be Equal             ${cloudlet.fqdn}  ${tmus_appinst.uri}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${tmus_cloudlet_latitude}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${tmus_cloudlet_longitude}

    Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  ${tmus_appinst.mapped_ports[0].proto}  #LProtoTCP
    Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${tmus_appinst.mapped_ports[0].internal_port}
    Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  ${tmus_appinst.mapped_ports[0].public_port}
    Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}  ${tmus_appinst.mapped_ports[0].fqdn_prefix}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    #Create Operator             operator_name=${tmus_operator_name} 
    #Create Operator             operator_name=${gcp_operator_name} 
    #Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    #Create Cluster
    #Create App			app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  cluster_name=default  default_flavor_name=${flavor}
    #Create App			app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  default_flavor_name=${flavor}
    Create App			access_ports=tcp:1

    # create operator app instance
    ${tmus_appinst}=               Create App Instance  cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster
    ${att_appinst}=                Create App Instance  cloudlet_name=${att_cloudlet_name}    operator_org_name=${att_operator_name}  cluster_instance_name=autocluster

    # create public app instance
    ${azure_appinst}=               Create App Instance   cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${azure_appinst} 
    Set Suite Variable  ${att_appinst}
    Set Suite Variable  ${tmus_appinst}

