*** Settings ***
Documentation   GetFqdnList - request shall return 10 apps

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
${uri_3}  automation03.samsung.com
${uri_4}  automation04.samsung.com
${uri_5}  automation05.samsung.com
${uri_6}  automation06.samsung.com
${uri_7}  automation07.samsung.com
${uri_8}  automation08.samsung.com
${uri_9}  automation09.samsung.com
${uri_10}  automation10.samsung.com

*** Test Cases ***
GetFqdnList - request shall return 10 apps
    [Documentation]
    ...  registerClient with samsung app
    ...  send GetFqdnList for 10 apps
    ...  verify returns 10 results

      Register Client	developer_name=${samsung_developer_name}  app_name=${samsung_app_name}
      ${appfqdns}=  Get Fqdn List

      Log to console  ${app_1}
      log to console  ${app_2}
      
      Should Be Equal             ${appfqdns[0].app_name}  ${app_1.key.name}
      Should Be Equal             ${appfqdns[0].app_vers}  ${app_1.key.version}
      Should Be Equal             ${appfqdns[0].dev_name}  ${app_1.key.developer_key.name}
      Should Be Equal             ${appfqdns[0].fqdns[0]}     ${app_1.official_fqdn}

      Should Be Equal             ${appfqdns[1].app_name}  ${app_2.key.name}
      Should Be Equal             ${appfqdns[1].app_vers}  ${app_2.key.version}
      Should Be Equal             ${appfqdns[1].dev_name}  ${app_2.key.developer_key.name}
      Should Be Equal             ${appfqdns[1].fqdns[0]}     ${app_2.official_fqdn}

      Should Be Equal             ${appfqdns[2].app_name}  ${app_3.key.name}
      Should Be Equal             ${appfqdns[2].app_vers}  ${app_3.key.version}
      Should Be Equal             ${appfqdns[2].dev_name}  ${app_3.key.developer_key.name}
      Should Be Equal             ${appfqdns[2].fqdns[0]}     ${app_3.official_fqdn}

      Should Be Equal             ${appfqdns[3].app_name}  ${app_4.key.name}
      Should Be Equal             ${appfqdns[3].app_vers}  ${app_4.key.version}
      Should Be Equal             ${appfqdns[3].dev_name}  ${app_4.key.developer_key.name}
      Should Be Equal             ${appfqdns[3].fqdns[0]}     ${app_4.official_fqdn}

      Should Be Equal             ${appfqdns[4].app_name}  ${app_5.key.name}
      Should Be Equal             ${appfqdns[4].app_vers}  ${app_5.key.version}
      Should Be Equal             ${appfqdns[4].dev_name}  ${app_5.key.developer_key.name}
      Should Be Equal             ${appfqdns[4].fqdns[0]}     ${app_5.official_fqdn}

      Should Be Equal             ${appfqdns[5].app_name}  ${app_6.key.name}
      Should Be Equal             ${appfqdns[5].app_vers}  ${app_6.key.version}
      Should Be Equal             ${appfqdns[5].dev_name}  ${app_6.key.developer_key.name}
      Should Be Equal             ${appfqdns[5].fqdns[0]}     ${app_6.official_fqdn}

      Should Be Equal             ${appfqdns[6].app_name}  ${app_7.key.name}
      Should Be Equal             ${appfqdns[6].app_vers}  ${app_7.key.version}
      Should Be Equal             ${appfqdns[6].dev_name}  ${app_7.key.developer_key.name}
      Should Be Equal             ${appfqdns[6].fqdns[0]}     ${app_7.official_fqdn}

      Should Be Equal             ${appfqdns[7].app_name}  ${app_8.key.name}
      Should Be Equal             ${appfqdns[7].app_vers}  ${app_8.key.version}
      Should Be Equal             ${appfqdns[7].dev_name}  ${app_8.key.developer_key.name}
      Should Be Equal             ${appfqdns[7].fqdns[0]}     ${app_8.official_fqdn}

      Should Be Equal             ${appfqdns[8].app_name}  ${app_9.key.name}
      Should Be Equal             ${appfqdns[8].app_vers}  ${app_9.key.version}
      Should Be Equal             ${appfqdns[8].dev_name}  ${app_9.key.developer_key.name}
      Should Be Equal             ${appfqdns[8].fqdns[0]}     ${app_9.official_fqdn}

      Should Be Equal             ${appfqdns[9].app_name}  ${app_10.key.name}
      Should Be Equal             ${appfqdns[9].app_vers}  ${app_10.key.version}
      Should Be Equal             ${appfqdns[9].dev_name}  ${app_10.key.developer_key.name}
      Should Be Equal             ${appfqdns[9].fqdns[0]}     ${app_10.official_fqdn}

      Length Should Be   ${appfqdns}  10 

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


    Create Developer         developer_name=${dev_1}
    ${app_1}=  Create App		     access_ports=tcp:1  official_fqdn=${uri_1}  #permits_platform_apps=${True}
    #${appinst_1}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_1}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_2}
    ${app_2}=  Create App               access_ports=tcp:1  official_fqdn=${uri_2}  #permits_platform_apps=${True}
    #${appinst_2}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_2}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_3}
    ${app_3}=  Create App               access_ports=tcp:1  official_fqdn=${uri_3}  #permits_platform_apps=${True}
    #${appinst_3}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_3}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_4}
    ${app_4}=  Create App               access_ports=tcp:1  official_fqdn=${uri_4}  #permits_platform_apps=${True}
    #${appinst_4}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_4}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_5}
    ${app_5}=  Create App               access_ports=tcp:1  official_fqdn=${uri_5}  #permits_platform_apps=${True}
    #${appinst_5}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_5}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_6}
    ${app_6}=  Create App               access_ports=tcp:1  official_fqdn=${uri_6}  #permits_platform_apps=${True}
    #${appinst_6}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_6}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_7}
    ${app_7}=  Create App               access_ports=tcp:1  official_fqdn=${uri_7}  #permits_platform_apps=${True}
    #${appinst_7}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_7}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_8}
    ${app_8}=  Create App               access_ports=tcp:1  official_fqdn=${uri_8}  #permits_platform_apps=${True}
    #${appinst_8}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_8}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_9}
    ${app_9}=  Create App               access_ports=tcp:1  official_fqdn=${uri_9}  #permits_platform_apps=${True}
    #${appinst_9}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_9}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_10}
    ${app_10}=  Create App               access_ports=tcp:1  official_fqdn=${uri_10}  #permits_platform_apps=${True}
    #${appinst_10}=           Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_10}  cluster_instance_name=autocluster


    Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  official_fqdn=${samsung_uri} 
    #Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

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



