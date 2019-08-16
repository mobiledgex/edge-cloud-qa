*** Settings ***
Documentation   GetFqdnList - request shall return 0 apps when permits_platform_apps does not exist

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com

${uri_1}  automation01.samsung.com
${uri_2}  automation02.samsung.com

*** Test Cases ***
GetFqdnList - request for apps with no permits_platform_apps shall return 0 apps
    [Documentation]
    ...  registerClient with samsung app
    ...  send GetFqdnList for 0 apps since permits_platform_apps parm is not set
    ...  verify returns empty result

      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
      ${appfqdns}=  Get Fqdn List

      Length Should Be   ${appfqdns}  0

*** Keywords ***
Setup
    ${dev_1}                 Catenate  SEPARATOR=  ${developer_name_default}  01
    ${dev_2}                 Catenate  SEPARATOR=  ${developer_name_default}  02

    Create Flavor
    #Create Cluster	

    Create Developer         developer_name=${dev_1}
    Create App               access_ports=tcp:1  
    #${appinst_1}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_1}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_2}
    Create App               access_ports=tcp:1  
    #${appinst_2}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_2}  cluster_instance_name=autocluster

    Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    #Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    #Set Suite Variable  ${tmus_appinst} 


