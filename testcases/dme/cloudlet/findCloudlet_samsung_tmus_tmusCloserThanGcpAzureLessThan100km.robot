*** Settings ***
Documentation   FindCloudlet Samsung - request shall return tmus with gcp/azure cloudlet provisioned and tmus closer and < 100km from request
...		tmus tmocloud-2 cloudlet at: 35 -95
...             gcp gcpcloud-1  cloudlet at: 37 -94
...             azure azurecloud-1  cloudlet at: 37 -95
...		find cloudlet closest to   : 35 -94
...                91.09km from tmus
...                222.39km  from gcp
...                239.89km  from azure
...             tmus closer than gcp/azure. return tmus cloudlet
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
...             - key:
...                 operatorkey:
...                   name: gcp
...                 name: gcpcloud-1
...               location:
...                 lat: 37
...                 long: -94
...

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure
${gcp_operator_name}  gcp
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
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

${azure_cloudlet_latitude}	  37
${azure_cloudlet longitude}	  -95
${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -94
${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95

*** Test Cases ***
# ECQ-1005
FindCloudlet Samsung - request shall return tmus with gcp/azure cloudlet provisioned and tmus closer and < 100km from request
    [Documentation]
    ...  registerClient with samsung app
    ...  send findcloudlet with tmus/gcp/azure provisioned. tmus closer and < 100km from request. return tmus
    ...             tmus tmocloud-2 cloudlet at: 35 -95
    ...             gcp gcpcloud-1  cloudlet at: 37 -94
    ...             azure azurecloud-1  cloudlet at: 37 -95
    ...             find cloudlet closest to   : 35 -94
    ...                91.09km from tmus
    ...                222.39km  from gcp
    ...                239.89km  from azure
    ...             tmus closer than gcp/azure. return tmus cloudlet
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
    ...             - key:
    ...                 operatorkey:
    ...                   name: gcp
    ...                 name: gcpcloud-1
    ...               location:
    ...                 lat: 37
    ...                 long: -94

      Register Client  developer_org_name=${developer_name_default}  app_name=${app_name_default}

      ${fqdn}=  Get App Official FQDN  latitude=35  longitude=-94

      ${decoded_client_token}=  Decoded Client Token
      Should Be Equal  ${decoded_client_token['AppKey']['organization']}  ${developer_name_default}
      Should Be Equal  ${decoded_client_token['AppKey']['name']}  ${app_name_default}
      Should Be Equal  ${decoded_client_token['AppKey']['version']}  ${app_version_default}
      Should Be Equal As Numbers  ${decoded_client_token['Location']['latitude']}  35
      Should Be Equal As Numbers  ${decoded_client_token['Location']['longitude']}  -94

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}	

      ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}

#      ${cloudlet}=  Find Cloudlet  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_name_default}  carrier_name=${tmus_operator_name}  latitude=35  longitude=-94

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}                         ${tmus_appinst.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${tmus_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${tmus_cloudlet_longitude}

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${tmus_appinst.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${tmus_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${tmus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${tmus_appinst.mapped_ports[0].fqdn_prefix}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}
    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    #Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    Create Cloudlet		cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    #Create Cluster		
    Create App			access_ports=tcp:1  official_fqdn=${samsung_uri}  #permits_platform_apps=${True}
    ${tmus_appinst}=            Create App Instance		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

    ${developer_name_default}=  Get Default Developer Name
    ${app_name_default}=  Get Default App Name

    Set Suite Variable  ${tmus_appinst}

    #Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    #Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_org_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    ${app_version_default}=     Get Default App Version
    Set Suite Variable  ${app_version_default}

    Set Suite Variable  ${tmus_appinst} 
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${app_name_default}

