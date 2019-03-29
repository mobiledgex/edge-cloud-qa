*** Settings ***
Documentation   FindCloudlet - request shall return error when FindCloudlet app does not match Registered App

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
	
Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${access_ports}    tcp:80,http:443,udp:10002
${operator_name}   tmus

*** Test Cases ***
FindCloudlet - request shall return error when FindCloudlet app does not match Registered App
    [Documentation]
    ...  Register Client with app1
    ...  send FindCloudlet for app2
    ...  verify PERMISSION_DENIED is returned

      ${developer_name_default}=  Get Default Developer Name

      Register Client  app_name=${app_name_1}
      ${error_msg}=  Run Keyword and Expect Error  *  Find Cloudlet  app_name=${app_name_2}  app_version=1.0  developer_name=${developer_name_default}   carrier_name=${operator_name}  latitude=31  longitude=-91

      Should Contain  ${error_msg}  status = StatusCode.PERMISSION_DENIED
      Should Contain  ${error_msg}  details = "Access to requested app: Devname: ${developer_name_default} Appname: ${app_name_2} AppVers: 1.0 not allowed for the registered app: Devname: ${developer_name_default} Appname: ${app_name_1} Appvers: 1.0"

*** Keywords ***
Setup
    #Create Operator        operator_name=${operator_name} 
    Create Developer
    Create Flavor
    #Create Cloudlet	   cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}  latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    #Create Cloudlet	   cloudlet_name=${cloudlet_name2}  operator_name=${operator_name}  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}
    Create Cluster Flavor
    Create Cluster

    ${app_name_default}=  Get Default App Name
    ${app_name_1}=             Catenate  SEPARATOR=  ${app_name_default}  -1 
    ${app_name_2}=             Catenate  SEPARATOR=  ${app_name_default}  -2 

    Create App             app_name=${app_name_1}  access_ports=${access_ports} 
    Create App             app_name=${app_name_2}  access_ports=${access_ports}

    Set Suite Variable  ${app_name_1}
    Set Suite Variable  ${app_name_2}

