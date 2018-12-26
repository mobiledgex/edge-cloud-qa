*** Settings ***
Documentation   findCloudlet with dmuus and gcp. dmuus farther but greater than 100km from gcp - return gcp
...		dmuus tmocloud-2 cloudlet at: 35 -95
...             gcp tmocloud-2  cloudlet at: 37 -95
...		find cloudlet closest to   : 37 -96
...                239.89km from dmuus
...                88.80km  from gcp
...             gcp is closer by 151.09km which is more than 100km closer. return gcp cloudlet
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
...                   name: gcp
...                 name: tmocloud-2
...               location:
...                 lat: 37
...                 long: -95
...
#edgectl controller --tls ~/localserver.crt CreateOperator --key-name gcp
#edgectl controller --tls ~/localserver.crt CreateCloudlet --key-name tmocloud-2 --key-operatorkey-name gcp --location-lat 50 --location-long 50 --numdynamicips 254
#edgectl controller --tls ~/localserver.crt CreateApp --key-name app2 --key-developerkey-name AcmeAppCo --key-version 1.0 --imagetype ImageTypeDocker --accessports tcp:1 --cluster-name SmallCluster --defaultflavor-name x1.small --ipaccess IpAccessDedicated

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String
	
Test Setup	Setup
#Test Teardown	Cleanup provisioning

*** Variables ***
#${dme_api_address}  127.0.0.1:50051
#${controller_api_address}  127.0.0.1:55001
${public_operator_name}  gcp
${operator_name}  dmuus
${public_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${dmuus_cloudlet_latitude}	  35
${dmuus_cloudlet longitude}	  -95
${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -95

*** Test Cases ***
FindCloudlet - findCloudlet shall return gcp with with gcp closer by more than 100km
    [Documentation]   
    ...  findCloudlet with dmuus and gcp. dmuus farther but greater than 100km from gcp - return gcp
    ...		dmuus tmocloud-2 cloudlet at: 35 -95
    ...         gcp tmocloud-2  cloudlet at: 37 -95
    ...
    ...		find cloudlet closest to   : 37 -96
    ...                239.89km from dmuus
    ...                88.80km  from gcp
    ...             gcp is closer by 151.09km which is more than 100km closer. return gcp cloudlet
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
    ...                   name: gcp
    ...                 name: tmocloud-2
    ...               location:
    ...                 lat: 37
    ...                 long: -95

      Show App Instances
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=37  longitude=-96

      ${fqdn}=                    Catenate  SEPARATOR=  ${developer_name}  ${app_name}  10  .  ${public_cloudlet_name}  .  ${public_operator_name}  .mobiledgex.net
      ${fqdn}=                    Convert to lowercase  ${fqdn}	
      Should Be Equal             ${cloudlet.FQDN}  ${fqdn}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}   ${gcp_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  ${gcp_cloudlet_longitude}

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  1
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  1
      ${fqdn_prefix}=             Catenate  SEPARATOR=  ${app_name}  -  tcp  .	
      Should Be Equal             ${cloudlet.ports[0].FQDN_prefix}  ${fqdn_prefix}

*** Keywords ***
Setup
    Create Operator             operator_name=${operator_name} 
    Create Operator             operator_name=${public_operator_name} 
    Create Developer            developer_name=${developer_name}
    Create Flavor
    Create Cloudlet		cloudlet_name=${public_cloudlet_name}  operator_name=${public_operator_name}  number_of_dynamic_ips=default  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name}  operator_name=${operator_name}  number_of_dynamic_ips=default  latitude=${dmuus_cloudlet_latitude}  longitude=${dmuus_cloudlet_longitude}
    #Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}
    Create Cluster Flavor

    #Create Cluster		cluster_name=default  default_flavor_name=${flavor}
    Create Cluster
    #Create App			app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  cluster_name=default  default_flavor_name=${flavor}
    #Create App			app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  default_flavor_name=${flavor}
    Create App			app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}  access_ports=tcp:1

    # create operator app instance
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${dmuus_cloudlet_name}  operator_name=${operator_name}
    # create public app instance
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${public_cloudlet_name}  operator_name=${public_operator_name}
