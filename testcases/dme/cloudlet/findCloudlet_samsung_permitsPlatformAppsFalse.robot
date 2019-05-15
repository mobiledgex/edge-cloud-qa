*** Settings ***
Documentation   FindCloudlet - request shall return error when sending FindCloudlet for app with permits_platform_apps=False

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

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

${azure_cloudlet_latitude}	  35
${azure_cloudlet longitude}	  -95
${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95

*** Test Cases ***
FindCloudlet Samsung - request shall return error when sending FindCloudlet for app with permits_platform_apps=False
    [Documentation]
    ...  send FindCloudlet for app with permits_platform_apps=False
    ...  verify Access to requested app not allowed error is received

      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
       ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  app_name=${app_name_default}  app_version=1.0  developer_name=${developer_name_default}  carrier_name=${tmus_operator_name}  latitude=36  longitude=-95

      Should Contain  ${error_msg}  status = StatusCode.PERMISSION_DENIED
      Should Contain  ${error_msg}  details = "Access to requested app: Devname: ${developer_name_default} Appname: ${app_name_default} AppVers: 1.0 not allowed for the registered app: Devname: Samsung Appname: SamsungEnablingLayer Appvers: 1.0" 

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    Create Cluster	
    Create Cluster Instance	
    Create App			access_ports=tcp:1  permits_platform_apps=${False}
    ${tmus_appinst}=            Create App Instance		cloudlet_name=${tmus_cloudlet_name}  operator_name=${tmus_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  cluster_instance_name=autocluster

    ${developer_name_default}=  Get Default Developer Name
    ${app_name_default}=        Get Default App Name

    Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    ${samsung_appinst}=         Create App Instance  app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst} 
    Set Suite Variable  ${samsung_appinst} 
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${app_name_default}

