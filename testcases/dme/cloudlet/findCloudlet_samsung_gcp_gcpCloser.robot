*** Settings ***
Documentation   FindCloudlet Samsung - request shall return gcp with tmus farther and > 100km than gcp
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
#Variables       shared_variables.py
	
Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${gcp_operator_name}  gcp
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com
${access_ports}  tcp:1
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
# ECQ-998
FindCloudlet Samsung - request shall return gcp with tmus farther and > 100km farther than gcp
    [Documentation]  
    ...  registerClient with samsung app
    ...  findCloudlet with gcp closer by more than 100km. return gcp
    ...		tmus tmocloud-2 cloudlet at: 35 -95
    ...         gcp gcpcloud-1  cloudlet at: 37 -95
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

      Register Client  developer_org_name=${developer_name_default}  app_name=${app_name_default}  

      ${fqdn}=  Get App Official FQDN  latitude=37  longitude=-96
      ${decoded_client_token}=  Decoded Client Token
      Should Be Equal  ${decoded_client_token['AppKey']['organization']}  ${developer_name_default}
      Should Be Equal  ${decoded_client_token['AppKey']['name']}  ${app_name_default}
      Should Be Equal  ${decoded_client_token['AppKey']['version']}  ${app_version_default}
      Should Be Equal As Numbers  ${decoded_client_token['Location']['latitude']}  37
      Should Be Equal As Numbers  ${decoded_client_token['Location']['longitude']}  -96

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}

      ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}

#      ${cloudlet}=  Find Cloudlet  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_name_default}  carrier_name=${tmus_operator_name}  latitude=37  longitude=-96

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}                         ${gcp_appinst.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${gcp_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${gcp_cloudlet_longitude} 

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}               ${gcp_appinst.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}       ${gcp_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}         ${gcp_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}         ${gcp_appinst.mapped_ports[0].fqdn_prefix}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}


    #Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    #Create Cluster	
    Create App			access_ports=${access_ports}  official_fqdn=${samsung_uri}  #permits_platform_apps=${True} 
    ${gcp_appinst}=            Create App Instance		cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster

    ${developer_name_default}=  Get Default Developer Name
    ${app_name_default}=        Get Default App Name

    #Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1
    #Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_org_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    ${app_version_default}=     Get Default App Version
    Set Suite Variable  ${app_version_default}

    Set Suite Variable  ${gcp_appinst} 
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${app_name_default}

