*** Settings ***
Documentation   CreateAppInst on 2 cloudlets

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${cloudlet_name2}  tmocloud-2

${mobile_latitude}  1
${mobile_longitude}  1

${region}=  US

*** Test Cases ***
# ECQ-2425
AppInst - Shall be able to create to 2 AppInsts of the same app on 2 different cloudlets
    [Documentation]
    ...  - create 1 app
    ...  - create 2 app instance of the app on 2 different cloudlets
    ...  - verify both apps are created

    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster  
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster 

    ${appInst}=  Show App Instances  region=${region}  app_name=${app_name_default}  use_defaults=${False}

    Should Be Equal              ${appInst[0]['data']['key']['app_key']['name']}    ${app_name_default}	
    Should Be Equal              ${appInst[1]['data']['key']['app_key']['name']}    ${app_name_default}

    Should Be True  '${appInst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}'=='${cloudlet_name}' or '${appInst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}'=='${cloudlet_name2}'
    Should Be True  '${appInst[1]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}'=='${cloudlet_name}' or '${appInst[1]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}'=='${cloudlet_name2}'

    Length Should Be   ${appInst}  2

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${developer_name_1}=  Catenate  SEPARATOR=  dev  ${epoch_time}  _1
    Set Suite Variable  ${developer_name_1}

    Create Org
    Create Flavor  region=${region}
    Create App	  region=${region}  access_ports=tcp:1

    ${app_name_default}=  Get Default App Name
    Set Suite Variable  ${app_name_default}

    ${flavor_name_default}=  Get Default Flavor Name
    Set Suite Variable  ${flavor_name_default}

Teardown
    Cleanup provisioning

