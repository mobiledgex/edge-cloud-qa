*** Settings ***
Documentation   findCloudlet Samsung - with tmus and azure. tmus farther but greater than 100km from azure - return azure
...		tmus tmocloud-2 cloudlet at: 35 -95
...             azure azurecloud-1  cloudlet at: 37 -95
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
...
#edgectl controller --tls ~/localserver.crt CreateOperator --key-name azure
#edgectl controller --tls ~/localserver.crt CreateCloudlet --key-name tmocloud-2 --key-operatorkey-name azure --location-lat 50 --location-long 50 --numdynamicips 254
#edgectl controller --tls ~/localserver.crt CreateApp --key-name app2 --key-developerkey-name AcmeAppCo --key-version 1.0 --imagetype ImageTypeDocker --accessports tcp:1 --cluster-name SmallCluster --defaultflavor-name x1.small --ipaccess IpAccessDedicated

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
	
Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure
${tmus_operator_name}  tmus
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com
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

*** Test Cases ***
FindCloudlet Samsung - findCloudlet shall return azure with with azure cloudlet provisioned and closer by more than 100km
    [Documentation]  
    ...  registerClient with samsung app 
    ...  findCloudlet with tmus and azure. tmus farther but greater than 100km from azure - return azure
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

      #${developer_name_default}=  Get Default Developer Name
      #${app_name_default}=        Get Default App Name

      Register Client  developer_name=${samsung_developer_name}  app_name=${samsung_app_name}	
      ${cloudlet}=  Find Cloudlet  app_name=${app_name_default}  app_version=1.0  developer_name=${developer_name_default}  carrier_name=${tmus_operator_name}  latitude=37  longitude=-96

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${azure_appinst.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${azure_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${azure_cloudlet_longitude}

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  ${azure_appinst.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${azure_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  ${azure_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}  ${azure_appinst.mapped_ports[0].fqdn_prefix}

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    Create Cluster
    Create App			access_ports=tcp:1  permits_platform_apps=${True}

    # create operator app instance
    ${tmus_appinst}=               Create App Instance  cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}  cluster_instance_name=autocluster
    # create public app instance
    ${azure_appinst}=               Create App Instance   cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  cluster_instance_name=autocluster

    ${developer_name_default}=  Get Default Developer Name
    ${app_name_default}=        Get Default App Name

    Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${azure_appinst} 
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${app_name_default}

