*** Settings ***
Documentation   FindCloudlet - request shall return dmuus with gcp cloudlet provisioned and dmuus and gcp same coord
...		dmuus tmocloud-2 cloudlet at: 35 -95
...             gcp tmocloud-2  cloudlet at: 35 -95
...		find cloudlet closest to   : 36 -95
...                111.19km from dmuus
...                111.19km  from gcp
...             dmuus and gcp are same coord/distance. return dmuus cloudlet
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
...                 lat: 35
...                 long: -95
...

Library         MexDme  dme_address=${dme_api_address}
Library		MexController  controller_address=${controller_api_address}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${controller_api_address}  127.0.0.1:55001
${public_operator_name}  gcp
${operator_name}  dmuus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${gcp_cloudlet_latitude}	  35
${gcp_cloudlet longitude}	  -95

*** Test Cases ***
findCloudlet with with dmuus and gcp same coord
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=36  longitude=-95

      Should Be Equal             ${cloudlet.FQDN}  acmeappcosomeapplication210.tmocloud-2.dmuus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  35.0
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  -95.0

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  1
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  1

*** Keywords ***
Setup
    Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${public_operator_name}  number_of_dynamic_ips=default  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}
    Create Cluster		cluster_name=default  default_flavor_name=${flavor}
    Create App			app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  cluster_name=default  default_flavor_name=${flavor}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${public_operator_name}
