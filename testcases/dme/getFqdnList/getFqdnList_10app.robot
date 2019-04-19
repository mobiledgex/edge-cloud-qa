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

      Should Be Equal             ${appfqdns[0].AppName}  ${appinst_1.key.app_key.name}
      Should Be Equal             ${appfqdns[0].AppVers}  ${appinst_1.key.app_key.version}
      Should Be Equal             ${appfqdns[0].DevName}  ${appinst_1.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[0].FQDNs[0]}     ${appinst_1.uri}

      Should Be Equal             ${appfqdns[1].AppName}  ${appinst_2.key.app_key.name}
      Should Be Equal             ${appfqdns[1].AppVers}  ${appinst_2.key.app_key.version}
      Should Be Equal             ${appfqdns[1].DevName}  ${appinst_2.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[1].FQDNs[0]}     ${appinst_2.uri}

      Should Be Equal             ${appfqdns[2].AppName}  ${appinst_3.key.app_key.name}
      Should Be Equal             ${appfqdns[2].AppVers}  ${appinst_3.key.app_key.version}
      Should Be Equal             ${appfqdns[2].DevName}  ${appinst_3.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[2].FQDNs[0]}     ${appinst_3.uri}

      Should Be Equal             ${appfqdns[3].AppName}  ${appinst_4.key.app_key.name}
      Should Be Equal             ${appfqdns[3].AppVers}  ${appinst_4.key.app_key.version}
      Should Be Equal             ${appfqdns[3].DevName}  ${appinst_4.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[3].FQDNs[0]}     ${appinst_4.uri}

      Should Be Equal             ${appfqdns[4].AppName}  ${appinst_5.key.app_key.name}
      Should Be Equal             ${appfqdns[4].AppVers}  ${appinst_5.key.app_key.version}
      Should Be Equal             ${appfqdns[4].DevName}  ${appinst_5.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[4].FQDNs[0]}     ${appinst_5.uri}

      Should Be Equal             ${appfqdns[5].AppName}  ${appinst_6.key.app_key.name}
      Should Be Equal             ${appfqdns[5].AppVers}  ${appinst_6.key.app_key.version}
      Should Be Equal             ${appfqdns[5].DevName}  ${appinst_6.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[5].FQDNs[0]}     ${appinst_6.uri}

      Should Be Equal             ${appfqdns[6].AppName}  ${appinst_7.key.app_key.name}
      Should Be Equal             ${appfqdns[6].AppVers}  ${appinst_7.key.app_key.version}
      Should Be Equal             ${appfqdns[6].DevName}  ${appinst_7.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[6].FQDNs[0]}     ${appinst_7.uri}

      Should Be Equal             ${appfqdns[7].AppName}  ${appinst_8.key.app_key.name}
      Should Be Equal             ${appfqdns[7].AppVers}  ${appinst_8.key.app_key.version}
      Should Be Equal             ${appfqdns[7].DevName}  ${appinst_8.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[7].FQDNs[0]}     ${appinst_8.uri}

      Should Be Equal             ${appfqdns[8].AppName}  ${appinst_9.key.app_key.name}
      Should Be Equal             ${appfqdns[8].AppVers}  ${appinst_9.key.app_key.version}
      Should Be Equal             ${appfqdns[8].DevName}  ${appinst_9.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[8].FQDNs[0]}     ${appinst_9.uri}

      Should Be Equal             ${appfqdns[9].AppName}  ${appinst_10.key.app_key.name}
      Should Be Equal             ${appfqdns[9].AppVers}  ${appinst_10.key.app_key.version}
      Should Be Equal             ${appfqdns[9].DevName}  ${appinst_10.key.app_key.developer_key.name}
      Should Be Equal             ${appfqdns[9].FQDNs[0]}     ${appinst_10.uri}

      Length Should Be   ${appfqdns}  10 

*** Keywords ***
Setup
    Create Flavor
    Create Cluster Flavor
    Create Cluster	

    ${dev_1}                 Catenate  ${developer_name_default}  01
    ${dev_2}                 Catenate  ${developer_name_default}  02
    ${dev_3}                 Catenate  ${developer_name_default}  03
    ${dev_4}                 Catenate  ${developer_name_default}  04
    ${dev_5}                 Catenate  ${developer_name_default}  05
    ${dev_6}                 Catenate  ${developer_name_default}  06
    ${dev_7}                 Catenate  ${developer_name_default}  07
    ${dev_8}                 Catenate  ${developer_name_default}  08
    ${dev_9}                 Catenate  ${developer_name_default}  09
    ${dev_10}                 Catenate  ${developer_name_default} 10 


    Create Developer         developer_name=${dev_1}
    Create App		     access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_1}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_1}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_2}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_2}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_2}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_3}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_3}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_3}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_4}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_4}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_4}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_5}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_5}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_5}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_6}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_6}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_6}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_7}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_7}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_7}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_8}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_8}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_8}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_9}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_9}=            Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_9}  cluster_instance_name=autocluster

    Create Developer         developer_name=${dev_10}
    Create App               access_ports=tcp:1  permits_platform_apps=${True}
    ${appinst_10}=           Create App Instance  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${uri_10}  cluster_instance_name=autocluster


    Create Developer            developer_name=${samsung_developer_name}
    Create App			developer_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${appinst_1} 
    Set Suite Variable  ${appinst_2}
    Set Suite Variable  ${appinst_3}
    Set Suite Variable  ${appinst_4}
    Set Suite Variable  ${appinst_5}
    Set Suite Variable  ${appinst_6}
    Set Suite Variable  ${appinst_7}
    Set Suite Variable  ${appinst_8}
    Set Suite Variable  ${appinst_9}
    Set Suite Variable  ${appinst_10}



