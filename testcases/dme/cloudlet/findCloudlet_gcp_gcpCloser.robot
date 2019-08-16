*** Settings ***
Documentation   FindCloudlet - request shall return gcp with dmuus farther and > 100km than gcp
...		dmuus tmocloud-2 cloudlet at: 35 -95
...             gcp gcpcloud-1  cloudlet at: 37 -95
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
Variables       shared_variables.py
	
Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${gcp_operator_name}  gcp
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
${access_ports}  tcp:1
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
FindCloudlet - request shall return gcp with dmuus farther and > 100km farther than gcp
    [Documentation]  
    ...  findCloudlet with gcp closer by more than 100km. return gcp
    ...		dmuus tmocloud-2 cloudlet at: 35 -95
    ...         gcp gcpcloud-1  cloudlet at: 37 -95
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
    ...                 name: gcpcloud-1
    ...               location:
    ...                 lat: 37
    ...                 long: -95

      Register Client	
      ${cloudlet}=  Find Cloudlet  carrier_name=${dmuus_operator_name}  latitude=37  longitude=-96

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}                         ${gcp_appinst.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${gcp_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${gcp_cloudlet_longitude} 

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}               ${gcp_appinst.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}       ${gcp_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}         ${gcp_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}         ${gcp_appinst.mapped_ports[0].fqdn_prefix}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}


    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}

    #Create Operator             operator_name=${dmuus_operator_name} 
    #Create Operator             operator_name=${gcp_operator_name} 
    Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${gcp_cloudlet_name}  operator_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name}  operator_name=${dmuus_operator_name}  latitude=${dmuus_cloudlet_latitude}  longitude=${dmuus_cloudlet_longitude}
    #Create Cluster	
    Create App			access_ports=${access_ports}  ip_access=IpAccessDedicatedOrShared
    ${gcp_appinst}=            Create App Instance		cloudlet_name=${gcp_cloudlet_name}  operator_name=${gcp_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${dmuus_cloudlet_name}  operator_name=${dmuus_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${gcp_appinst} 
