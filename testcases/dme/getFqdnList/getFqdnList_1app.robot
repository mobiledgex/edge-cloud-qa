*** Settings ***
Documentation   GetFqdnList - request shall return 1 app

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

*** Test Cases ***
GetFqdnList - request shall return 1 app
    [Documentation]
    ...  registerClient with platos app
    ...  send GetFqdnList for 1 app
    ...  verify returns 1 result

      Register Client	developer_name=${platos_developer_name}  app_name=${platos_app_name}
      ${appfqdns}=  Get Fqdn List

      Should Be Equal             ${appfqdns[0].AppName}  ${dmuus_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].AppVers}  ${dmuus_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].DevName}  ${dmuus_appinst.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[0].FQDNs[0]}     ${dmuus_appinst.uri}

      Length Should Be   ${appfqdns}  1

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cluster	
    Create App			access_ports=tcp:1  permits_platform_apps=${True}
    ${dmuus_appinst}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${platos_uri}  cluster_instance_name=autocluster

    Create Developer            developer_name=${platos_developer_name}
    Create App			developer_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  
    Create App Instance         app_name=${platos_app_name}  developer_name=${platos_developer_name}  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${platos_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${dmuus_appinst} 


