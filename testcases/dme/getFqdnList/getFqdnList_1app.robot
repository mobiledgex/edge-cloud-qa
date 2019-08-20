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

      Should Be Equal             ${appfqdns[0].app_name}  ${app.key.name}
      Should Be Equal             ${appfqdns[0].app_vers}  ${app.key.version}
      Should Be Equal             ${appfqdns[0].dev_name}  ${app.key.developer_key.name}
      Should Be Equal             ${appfqdns[0].fqdns[0]}  ${app.official_fqdn}

      Length Should Be   ${appfqdns}  1

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    #Create Cluster	
    ${app}=  Create App			access_ports=tcp:1  official_fqdn=${platos_uri}
    #${dmuus_appinst}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${platos_uri}  cluster_instance_name=autocluster

    Create Developer            developer_name=${platos_developer_name}
    Create App			developer_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  official_fqdn=${platos_uri} 
    #Create App Instance         app_name=${platos_app_name}  developer_name=${platos_developer_name}  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${platos_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${app} 


