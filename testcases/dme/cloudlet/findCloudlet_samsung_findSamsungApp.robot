*** Settings ***
Documentation   FindCloudlet Samsung - send findCloudlet requesting Samsung app
...  verify FIND_NOTFOUND is received


Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${azure_cloudlet_latitude}	  35
${azure_cloudlet longitude}	  -95
${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95

*** Test Cases ***
FindCloudlet Samsung - request shall return FIND_NOTFOUND when registering samsung app and sending findCloudlet without overriding the appname
    [Documentation]
    ...  registerClient with samsung app
    ...  findCloudlet with no app name
    ...  verify FIND_NOTFOUND is returned since cant search for own app 
    
      #  EDGECLOUD-352 - FindCloudlet - request should return FIND_NOTFOUND when searching for the samsung app - fixed
      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
      ${error_msg}=  Run Keyword and Expect Error  *  Find Cloudlet	carrier_name=${tmus_operator_name}  latitude=36  longitude=-95

      Should Be Equal  ${error_msg}  find cloudlet not found:status: FIND_NOTFOUND\ncloudlet_location {\n}\n

FindCloudlet Samsung - request shall return FIND_NOTFOUND when registering samsung app and sending findCloudlet overriding the appname with samsung app
    [Documentation]
    ...  registerClient with samsung app
    ...  findCloudlet with samsung app name
    ...  verify FIND_NOTFOUND is returned since cant search for own app

      #  EDGECLOUD-352 - FindCloudlet - request should return FIND_NOTFOUND when searching for the samsung app - fixed
      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
      ${error_msg}=  Run Keyword and Expect Error  *  Find Cloudlet	app_name=${samsung_app_name}  app_version=1.0  developer_name=${samsung_developer_name}  carrier_name=${tmus_operator_name}  latitude=36  longitude=-95

      Should Be Equal  ${error_msg}  find cloudlet not found:status: FIND_NOTFOUND\ncloudlet_location {\n}\n

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cluster	
    Create Cluster Instance	
    Create App			access_ports=tcp:1
    ${tmus_appinst}=            Create App Instance		cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  cluster_instance_name=autocluster

    Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    ${samsung_appinst}=         Create App Instance  app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst} 
    Set Suite Variable  ${samsung_appinst} 
