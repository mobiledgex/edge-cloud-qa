*** Settings ***
Documentation   GetFqdnList - request shall return 0 apps when permits_platform_apps=False

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${platos_app_name}  platosEnablingLayer
${platos_developer_name}  platos
${platos_cloudlet_name}  default
${platos_operator_name}  developer
${platos_uri}  automation.platos.com

${uri_1}  automation01.platos.com
${uri_2}  automation02.platos.com

*** Test Cases ***
GetFqdnList - request for apps with permits_platform_apps=False shall return 0 apps
    [Documentation]
    ...  registerClient with platos app
    ...  send GetFqdnList for 0 apps since permits_platform_apps=False
    ...  verify returns empty result

      Register Client	developer_name=${platos_developer_name}  app_name=${platos_app_name}
      ${appfqdns}=  Get Fqdn List

      Length Should Be   ${appfqdns}  0

*** Keywords ***
Setup
    ${dev_1}                 Catenate  ${developer_name_default}  01
    ${dev_2}                 Catenate  ${developer_name_default}  02

    Create Flavor
    Create Cluster Flavor
    Create Cluster	

    Create Developer         developer_name=${dev_1}
    Create App               access_ports=tcp:1  permits_platform_apps=${False}
    ${appinst_1}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_1}

    Create Developer         developer_name=${dev_2}
    Create App               access_ports=tcp:1  permits_platform_apps=${False}
    ${appinst_2}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_2}

    Create Developer            developer_name=${platos_developer_name}
    Create App			developer_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  
    Create App Instance         app_name=${platos_app_name}  developer_name=${platos_developer_name}  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${platos_uri}

    #Set Suite Variable  ${dmuus_appinst} 


