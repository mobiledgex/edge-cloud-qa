*** Settings ***
Documentation   GetFqdnList - request shall only return apps with permit=True

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
${uri_3}  automation03.platos.com
${uri_4}  automation04.platos.com
${uri_5}  automation05.platos.com
${uri_6}  automation06.platos.com
${uri_7}  automation07.platos.com
${uri_8}  automation08.platos.com
${uri_9}  automation09.platos.com
${uri_10}  automation10.platos.com

*** Test Cases ***
# ECQ-1024
GetFqdnList - request shall only return apps with permits_platform_apps=True
    [Documentation]
    ...  registerClient with platos app
    ...  send GetFqdnList 
    ...  verify only returns apps with permits_platform_apps=True

      Register Client	developer_org_name=${platos_developer_name}  app_name=${platos_app_name}
      ${appfqdns}=  Get Fqdn List

      ${appindex}=  Set Variable  ${0}
      FOR  ${a}  IN  @{appfqdns}
         Exit For Loop IF  '${a.app_name}' == '${app_1.key.name}'
         ${appindex}=  Evaluate  ${appindex}+1
      END

      Should Be Equal             ${appfqdns[${appindex}+0].app_name}  ${app_1.key.name}
      Should Be Equal             ${appfqdns[${appindex}+0].app_vers}  ${app_1.key.version}
      Should Be Equal             ${appfqdns[${appindex}+0].org_name}  ${app_1.key.organization}
      Should Be Equal             ${appfqdns[${appindex}+0].fqdns[0]}     ${app_1.official_fqdn}

      Should Be Equal             ${appfqdns[${appindex}+1].app_name}  ${app_3.key.name}
      Should Be Equal             ${appfqdns[${appindex}+1].app_vers}  ${app_3.key.version}
      Should Be Equal             ${appfqdns[${appindex}+1].org_name}  ${app_3.key.organization}
      Should Be Equal             ${appfqdns[${appindex}+1].fqdns[0]}     ${app_3.official_fqdn}

      Should Be Equal             ${appfqdns[${appindex}+2].app_name}  ${app_4.key.name}
      Should Be Equal             ${appfqdns[${appindex}+2].app_vers}  ${app_4.key.version}
      Should Be Equal             ${appfqdns[${appindex}+2].org_name}  ${app_4.key.organization}
      Should Be Equal             ${appfqdns[${appindex}+2].fqdns[0]}     ${app_4.official_fqdn}

      Should Be Equal             ${appfqdns[${appindex}+3].app_name}  ${app_7.key.name}
      Should Be Equal             ${appfqdns[${appindex}+3].app_vers}  ${app_7.key.version}
      Should Be Equal             ${appfqdns[${appindex}+3].org_name}  ${app_7.key.organization}
      Should Be Equal             ${appfqdns[${appindex}+3].fqdns[0]}     ${app_7.official_fqdn}

      Should Be Equal             ${appfqdns[${appindex}+4].app_name}  ${app_8.key.name}
      Should Be Equal             ${appfqdns[${appindex}+4].app_vers}  ${app_8.key.version}
      Should Be Equal             ${appfqdns[${appindex}+4].org_name}  ${app_8.key.organization}
      Should Be Equal             ${appfqdns[${appindex}+4].fqdns[0]}     ${app_8.official_fqdn}

      Should Be Equal             ${appfqdns[${appindex}+5].app_name}  ${app_9.key.name}
      Should Be Equal             ${appfqdns[${appindex}+5].app_vers}  ${app_9.key.version}
      Should Be Equal             ${appfqdns[${appindex}+5].org_name}  ${app_9.key.organization}
      Should Be Equal             ${appfqdns[${appindex}+5].fqdns[0]}     ${app_9.official_fqdn}

      Length Should Be   ${appfqdns}  ${appcount} 

*** Keywords ***
Setup
    Create Flavor  
    #Create Cluster	

    ${dev_1}                 Catenate  SEPARATOR=  ${developer_name_default}  01
    ${dev_2}                 Catenate  SEPARATOR=  ${developer_name_default}  02
    ${dev_3}                 Catenate  SEPARATOR=  ${developer_name_default}  03
    ${dev_4}                 Catenate  SEPARATOR=  ${developer_name_default}  04
    ${dev_5}                 Catenate  SEPARATOR=  ${developer_name_default}  05
    ${dev_6}                 Catenate  SEPARATOR=  ${developer_name_default}  06
    ${dev_7}                 Catenate  SEPARATOR=  ${developer_name_default}  07
    ${dev_8}                 Catenate  SEPARATOR=  ${developer_name_default}  08
    ${dev_9}                 Catenate  SEPARATOR=  ${developer_name_default}  09
    ${dev_10}                 Catenate  SEPARATOR=  ${developer_name_default}  10 

    #Create Developer         developer_name=${dev_1}
    ${app_1}=  Create App     developer_org_name=${dev_1}  access_ports=tcp:1  official_fqdn=${uri_1}  #permits_platform_apps=${True}
    #${appinst_1}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_1}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_2}
    ${app_2}=  Create App     developer_org_name=${dev_2}  access_ports=tcp:1  #permits_platform_apps=${False}
    #${appinst_2}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_2}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_3}
    ${app_3}=  Create App     developer_org_name=${dev_3}  access_ports=tcp:1  official_fqdn=${uri_3}  #permits_platform_apps=${True}
    #${appinst_3}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_3}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_4}
    ${app_4}=  Create App     developer_org_name=${dev_4}  access_ports=tcp:1  official_fqdn=${uri_4}  #permits_platform_apps=${True}
    #${appinst_4}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_4}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_5}
    ${app_5}=  Create App     developer_org_name=${dev_5}  access_ports=tcp:1   
    #${appinst_5}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_5}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_6}
    ${app_6}=  Create App     developer_org_name=${dev_6}   access_ports=tcp:1  #permits_platform_apps=${False}
    #${appinst_6}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_6}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_7}
    ${app_7}=  Create App     developer_org_name=${dev_7}  access_ports=tcp:1  official_fqdn=${uri_7}  #permits_platform_apps=${True}
    #${appinst_7}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_7}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_8}
    ${app_8}=  Create App     developer_org_name=${dev_8}  access_ports=tcp:1  official_fqdn=${uri_8}  #permits_platform_apps=${True}
    #${appinst_8}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_8}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_9}
    ${app_9}=  Create App     developer_org_name=${dev_9}  access_ports=tcp:1  official_fqdn=${uri_9}  #permits_platform_apps=${True}
    #${appinst_9}=            Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_9}  cluster_instance_name=autocluster

    #Create Developer         developer_name=${dev_10}
    ${app_10}=  Create App    developer_org_name=${dev_10}  access_ports=tcp:1   
    #${appinst_10}=           Create App Instance  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${uri_10}  cluster_instance_name=autocluster


    #Create Developer            developer_name=${platos_developer_name}
    Run Keyword and Ignore Error  Create App  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  
    #Create App Instance         app_name=${platos_app_name}  developer_name=${platos_developer_name}  cloudlet_name=${platos_cloudlet_name}  operator_name=${platos_operator_name}  uri=${platos_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${app_1} 
    Set Suite Variable  ${app_2}
    Set Suite Variable  ${app_3}
    Set Suite Variable  ${app_4}
    Set Suite Variable  ${app_5}
    Set Suite Variable  ${app_6}
    Set Suite Variable  ${app_7}
    Set Suite Variable  ${app_8}
    Set Suite Variable  ${app_9}
    Set Suite Variable  ${app_10}

    ${apps}=  Show Apps
    ${appcount}=  Set Variable  0
    FOR  ${a}  IN  @{apps}
       ${contains}=  Get Length  ${a.official_fqdn}
       ${appcount}=  Run Keyword If  ${contains} > 0  Evaluate  ${appcount} + 1  ELSE  Set Variable  ${appcount}
    END
    Set Suite Variable  ${appcount}

