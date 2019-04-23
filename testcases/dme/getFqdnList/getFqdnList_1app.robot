*** Settings ***
Documentation   GetFqdnList - request shall return 1 app

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

*** Test Cases ***
GetFqdnList - request shall return 1 app
    [Documentation]
    ...  registerClient with samsung app
    ...  send GetFqdnList for 1 app
    ...  verify returns 1 result

      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
      ${appfqdns}=  Get Fqdn List

      Should Be Equal             ${appfqdns[0].AppName}  ${tmus_appinst.key.app_key.name}
      Should Be Equal             ${appfqdns[0].AppVers}  ${tmus_appinst.key.app_key.version}
      Should Be Equal             ${appfqdns[0].DevName}  ${tmus_appinst.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[0].FQDNs[0]}     ${tmus_appinst.uri}

      Length Should Be   ${appfqdns}  1

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cluster Flavor
    Create Cluster	
    Create App			access_ports=tcp:1  permits_platform_apps=${True}
    ${tmus_appinst}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst} 


