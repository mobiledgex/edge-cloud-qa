*** Settings ***
Documentation   FindCloudlet - request shall return tmus with gcp/azure cloudlet provisioned and tmus farther but < 100km from gcp/azure
...		tmus tmocloud-2 cloudlet at: 35 -95
...             gcp tmocloud-2  cloudlet at: 36 -95
...             azure tmocloud-2  cloudlet at: 37 -95
...		find cloudlet closest to   : 36 -96
...                143.38km from tmus
...                89.96km  from gcp
...                142.67km  from azure
...             tmus farther than gcp/azure but less than 100km closer. return tmus cloudlet
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
...                 name: tmocloud-2
...               location:
...                 lat: 37
...                 long: -95
...             - key:
...                 operatorkey:
...                   name: gcp
...                 name: tmocloud-2
...               location:
...                 lat: 36
...                 long: -95
...

Library         MexDme  dme_address=${dme_api_address}
Library		MexController  controller_address=${controller_api_address}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${controller_api_address}  127.0.0.1:55001
${public_azure_operator_name}  azure
${public_gcp_operator_name}  gcp
${operator_name}  tmus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${azure_cloudlet_latitude}	  37
${azure_cloudlet longitude}	  -95
${gcp_cloudlet_latitude}	  36
${gcp_cloudlet longitude}	  -95

*** Test Cases ***
findCloudlet with with tmus and gcp/azure
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=36  longitude=-96

      Should Be Equal             ${cloudlet.FQDN}  acmeappcosomeapplication210.tmocloud-2.tmus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  35.0
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  -95.0

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  1
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  1

*** Keywords ***
Setup
    Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${public_azure_operator_name}  number_of_dynamic_ips=default  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${public_gcp_operator_name}  number_of_dynamic_ips=default  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}
    Create Cluster		cluster_name=default  default_flavor_name=${flavor}
    Create App			app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  cluster_name=default  default_flavor_name=${flavor}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${public_azure_operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${public_gcp_operator_name}
