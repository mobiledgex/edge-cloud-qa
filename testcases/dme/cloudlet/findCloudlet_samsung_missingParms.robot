*** Settings ***
Documentation   FindCloudlet Samsung - send findCloudlet with various missing override parms
...  verify correct error is received

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${tmus_operator_name}  tmus
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com
${app_version}  1.0

*** Test Cases ***
FindCloudlet Samsung - request shall return error when registering samsung app and sending findCloudlet overriding appname only
    [Documentation]
    ...  send FindCloudlet request overriding appname only. dont send appversion or developer name
    ...  verify "Access to requested app not allowed" error is received

      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
      ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  app_name=${samsung_app_name}  carrier_name=${tmus_operator_name}  latitude=36  longitude=-95

      Should Contain  ${error_msg}  status = StatusCode.PERMISSION_DENIED
      Should Contain  ${error_msg}  details = "Access to requested app: Devname: \ Appname: SamsungEnablingLayer AppVers: \ not allowed for the registered app: Devname: Samsung Appname: SamsungEnablingLayer Appvers: 1.0"

FindCloudlet Samsung - request shall return error when registering samsung app and sending findCloudlet overriding appvers only
    [Documentation]
    ...  send FindCloudlet request overriding appvers only. dont send appname or developer name
    ...  verify "Access to requested app not allowed" error is received

      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
      ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  app_version=${app_version}  carrier_name=${tmus_operator_name}  latitude=36  longitude=-95

      Should Contain  ${error_msg}  status = StatusCode.PERMISSION_DENIED
      Should Contain  ${error_msg}  details = "Access to requested app: Devname: \ Appname: \ AppVers: 1.0 not allowed for the registered app: Devname: Samsung Appname: SamsungEnablingLayer Appvers: 1.0"

FindCloudlet Samsung - request shall return error when registering samsung app and sending findCloudlet overriding developername only
    [Documentation]
    ...  send FindCloudlet request overriding developername only. dont send appname or appvers
    ...  verify "Access to requested app not allowed" error is received

      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
      ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  developer_name=${samsung_developer_name}  carrier_name=${tmus_operator_name}  latitude=36  longitude=-95

      Should Contain  ${error_msg}  status = StatusCode.PERMISSION_DENIED
      Should Contain  ${error_msg}  details = "Access to requested app: Devname: Samsung Appname: \ AppVers: \ not allowed for the registered app: Devname: Samsung Appname: SamsungEnablingLayer Appvers: 1.0"



*** Keywords ***
Setup
    Create Flavor
    Create Cluster	
    Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

