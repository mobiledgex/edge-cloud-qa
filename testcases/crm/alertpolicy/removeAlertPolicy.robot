#-*- coding: robot -*-

*** Settings ***
Documentation  CreateAlertPolicy on CRM

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}    #auto_login=${False}
Library  MexApp
Library  String
Library  DateTime

#Suite Setup     Setup
#Suite Teardown  Cleanup Provisioning
Test Timeout  30m

*** Variables ***
${developer_org_name}  automation_dev_org
${developer_org_name_automation}  ${developer_org_name}
${alert_org}=  ${developer_org_name_automation}           
${app_org}=    ${developer_org_name_automation}
${flavor_name}           alertflavor
${app_name}              alertapp101
${mobiledgex_domain}     mobiledgex.net
${docker_image_alerts}   docker-qa.mobiledgex.net/automation_dev_org/images/jmeterplus8086:13.8.6
${docker_image}=  ${docker_image_alerts}
${access_tcp_port}       tcp:8086
${ip_access_type}        IpAccessShared
#${ip_access_type}   IpAccessDedicated
${ip_access}             ${ip_access_type}
${num_master}       1
${num_nodes}        0
#default alert_policy_min_trigger_time
${tt_30s}=           30s
${tt_32s}=           32s
${test_timeout_crm}  15 min
#ALERT POLICY RECEIVER INFO
${CPU_policy}   CPUpolicyErr
${MEM_policy}   MEMpolicyErr
${DSK_policy}   DSKpolicyErr
${ACX_policy}   ACXpolicyErr
${err}=     error
${wrn}=     warning
${inf}=     info
${region}=  US
${jmp8086_ver}=  13.8.6
${app_version}=  ${jmp8086_ver}
${tt_policy}       ${tt_30s}
${tt_policy32}     ${tt_32s} 
${util_val}=  100
${cpu_util_val}=  18
${mem_util_val}=  19
${dsk_util_val}=  20
${acx_util_val}=  21

*** Test Cases ***
   
#ECQ-XXX1
Set mc settings alertpolicymintriggertime to 30s
   [Documentation]
   ...  - Setting for mc alertpolicytrigger can be updated
   ...  - Verify new trigger time is updated

   Log To Console  ${\n}Resetting mc trigger time policy to 30s
   Run Keyword  Reset Trigger Time Policy 30s

#ECQ-XXX2
Create new alert policies for cpu mem disk and active-connections
   [Documentation]
   ...  - User shall be able to create new alert policies 
   ...  - Verify that new alert policies are created
   ...  - Create a k8s app to add and remove alert policy to and from
   [Setup]  Setup

   Log To Console  ${\n} Creating app and alert  policies
   Run Keyword  Create Policies

#ECQ-XXX3
Update existing alert policies with new values
   [Documentation]
   ...  - User shall be able to update existing alertpolicy values
   ...  - Update utilization severity and trigger time
   ...  - Verify existing policies have been updated

   Log To Console  ${\n}Updating policies severity to warning and trigger time to 32s
   Run Keyword  Update Policies Severity Warning Trigger32

#ECQ-XXX4
Add alert policies to k8s app
   [Documentation]
   ...  - User shall be able to add alert policies to an app
   ...  - Verify that alert policies have been added to an app

   Log To Console  ${\n}Adding policies To app
   Run Keyword  Add Policies To App

#ECQ-XXX5
Show alert policies added to k8s app
   [Documentation]
   ...  - User shall be able to view existing alert policies added to an app
   ...  - Verify alert policies show for app

   Log To Console  ${\n} Showing alert policies from app
   Run Keyword  Show Alert Policies From App
#ECQ-XXX6
Remove alert policies from app
   [Documentation]
   ...  - User shall be able to Remove alert policies from an app
   ...  - Verify the removal of alert policies from an app

   Log To Console  ${\n}Removing policies from app
   Run Keyword  Remove Alert Policies From App
#ECQ-XXX7
Add back alert policies to app that have been previously removed
   [Documentation]
   ...  - User shall be able to re-add previously removed alert policies back to app
   ...  - Verify that the same alert policies have been added again to app

   Log To Console  ${\n}Adding exising policies to once removed policies on app
   Run Keyword  Add Policies To App
#ECQ-XXX8
Remove alert policers from app delete alert polices k8s app and flavor
   [Documentation]
   ...  - User shall be able to Remove alert policies and delete app
   ...  - Verify the removal of alert policies from an app
   ...  - Delete alert polices
   ...  - Delete app and flavor

   Run Keyword  Remove Alert Policies From App
   Run Keyword  Delete Policies
   Run Keyword  Delete App
   Run Keyword  Delete Flavor

*** Keywords ***
Setup
    ${super_token}  Get Super Token
    Set Suite Variable  ${super_token}
    ${date}=         Get Current Date  result_format=epoch  exclude_millis=no
    Set Suite Variable  ${date} 
    ${epoch}=        Convert Date    ${date}    epoch  exclude_millis=yes   
    ${epoch}=        Convert To String  ${epoch}
    ${epoch}=        Remove String   ${epoch}  .0   
    ${app_name}=      Catenate  ${app_name}-${epoch}
    Set Suite Variable  ${app_name}
    ${flavor_name}=      Catenate  ${flavor_name}-${epoch}
    Set Suite Variable  ${flavor_name}
    ${CPU_policy}=  Catenate  ${CPU_policy}-${epoch}
    ${MEM_policy}=  Catenate  ${MEM_policy}-${epoch}
    ${DSK_policy}=  Catenate  ${DSK_policy}-${epoch}
    ${ACX_policy}=  Catenate  ${ACX_policy}-${epoch}
    Set Suite Variable  ${CPU_policy}
    Set Suite Variable  ${MEM_policy}
    Set Suite Variable  ${DSK_policy}
    Set Suite Variable  ${ACX_policy}
    Set Suite Variable  ${err}          error
    Set Suite Variable  ${wrn}          warning
    Set Suite Variable  ${inf}          info
    Set Suite Variable  ${region}       US
    #Log naming to console checking webui manually durring testing
    Log To Console  ${\n}${CPU_policy}
    Log To Console  ${\n}${MEM_policy}
    Log To Console  ${\n}${DSK_policy}
    Log To Console  ${\n}${ACX_policy}
    Log To Console  ${\n}${app_name}
    Log To Console  ${\n}${flavor_name}

    Log To Console  ${\n}Creating Flavor ${flavor_name}
    Create Flavor  token=${super_token}  region=${region}  flavor_name=${flavor_name} 

    Log To Console  Creating App ${app_name}

    Create App  token=${super_token}  region=${region}  image_path=${docker_image_alerts}  app_version=${jmp8086_ver}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  developer_org_name=${developer_org_name}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=kubernetes  app_name=${app_name}  #flavor_name=${cluster_flavor_name}  #allow_serverless=${allow_serverless}  #default_flavor_name=${cluster_flavor_name}
    Log To Console  ${\n}Done Creating App


Delete Flavor
    Run mcctl  flavor delete region=${region} name=${flavor_name}
    ${policy_show_flav}=  Run Keyword  Show Flavors  token=${super_token}  region=${region}  flavor_name=${flavor_name}
    ${len_flav}=  Get Length  ${policy_show_flav}
    Run Keywords   Should Be True  ${len_flav} <= 0   AND   Log To Console  Flavor ${flavor_name} deleted

Delete App

    Run mcctl  app delete region=${region} app-org=${developer_org_name} appname=${app_name} appvers=${jmp8086_ver}
    Log To Console  ${\n}Deleteing app
    ${policy_show_app}=  Run Keyword  Show Apps  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}
    ${len_app}=  Get Length  ${policy_show_app}
    Run Keywords   Should Be True  ${len_app} <= 0   AND   Log To Console  App ${app_name} deleted


Reset Trigger Time Policy 30s
   ${super_token}  Get Super Token
   Set Suite Variable  ${super_token}
   ${set_tt_us}=  Run Keyword  Update Settings  token=${super_token}  region=US  alert_policy_min_trigger_time=${tt_30s}
   ${set_tt_eu}=  Run Keyword  Update Settings  token=${super_token}  region=EU  alert_policy_min_trigger_time=${tt_30s}
   ${show_us}=  Run Keyword  Show Settings  token=${super_token}  region=US
   ${show_eu}=  Run Keyword  Show Settings  token=${super_token}  region=EU
   ${tt_us}=  Set Variable  ${show_us['alert_policy_min_trigger_time']}
   ${tt_eu}=  Set Variable  ${show_eu['alert_policy_min_trigger_time']}
   Run Keywords    Should Be Equal As Strings  ${tt_us}  ${tt_30s}  AND  Log To Console  ${\n}alert_policy_min_trigger_time US= ${tt_us}
   Run Keywords    Should Be Equal As Strings  ${tt_eu}  ${tt_30s}  AND  Log To Console  ${\n}alert_policy_min_trigger_time EU= ${tt_eu}

Create Policies
   #Creating Alert Policies if exists already test will not error and status of exists or created will be displayed
   ${cpu_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${CPUpolicy}\\\\\\\\"} already exists"}\\\')\')
   ${mem_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${MEMpolicy}\\\\\\\\"} already exists"}\\\')\')
   ${dsk_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${DSKpolicy}\\\\\\\\"} already exists"}\\\')\')
   ${acx_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${ACXpolicy}\\\\\\\\"} already exists"}\\\')\')
#CPU AlertPolicy
  ${cpu_policy_name}=  Run Keyword And Ignore Error  Create Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}  severity=${err}  trigger_time=${tt_30s}  alert_org=${alert_org}     cpu_utilization=${util_val}  labels_vars=Error=CPU  annotations_vars=description=[CPU] Error on 8086 critical consumption app needs 1.21 gigawatts of CPU power  description=description-cpu
   ${nogo}=  Run Keyword If  ${cpu_err}==${cpu_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${CPU_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${cpu_err}!=${cpu_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${CPU_policy} was created
   ${cpu_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}
   ${cpu_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['severity']}
   ${cpu_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_sev}   ${err}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_trig}  ${tt_policy}
#MEM AlertPolicy
   ${mem_policy_name}=  Run Keyword And Ignore Error    Create Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}  severity=${err}  trigger_time=${tt_30s}  alert_org=${alert_org}     mem_utilization=${util_val}  labels_vars=Error=MEM  annotations_vars=description=[MEM] Error on 8086 critical consumption app needs 1.21 gigawatts of MEM power  description=description-mem
   ${nogo}=  Run Keyword If  ${mem_err}==${mem_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${MEM_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${mem_err}!=${mem_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${MEM_policy} was created
   ${mem_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}
   ${mem_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['severity']}
   ${mem_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_sev}   ${err}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_trig}  ${tt_policy}
#DSK AlertPolicy
   ${dsk_policy_name}=  Run Keyword And Ignore Error    Create Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}  severity=${err}  trigger_time=${tt_30s}  alert_org=${alert_org}    disk_utilization=${util_val}  labels_vars=Error=DSK  annotations_vars=description=[DSK] Error on 8086 critical consumption app needs 1.21 gigawatts of DSK power  description=description-dsk
   ${nogo}=  Run Keyword If  ${dsk_err}==${dsk_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${DSK_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${dsk_err}!=${dsk_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${DSK_policy} was created
   ${dsk_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}
   ${dsk_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['severity']}
   ${dsk_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_sev}   ${err}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_trig}  ${tt_policy}
#ACX AlertPolicy
   ${acx_policy_name}=  Run Keyword And Ignore Error    Create Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}  severity=${err}  trigger_time=${tt_30s}  alert_org=${alert_org}  active_connections=${util_val}  labels_vars=Error=ACX  annotations_vars=description=[ACX] Error on 8086 critical consumption app needs 1.21 gigawatts of ACX power  description=description-acx
   ${nogo}=  Run Keyword If  ${acx_err}==${acx_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${ACX_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${acx_err}!=${acx_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${ACX_policy} was created
   ${acx_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}
   ${acx_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['severity']}
   ${acx_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_sev}   ${err}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_trig}  ${tt_policy}

Delete Policies
#Deleting alert policies if exists - not used in suite testing as teardown will remove policies leaving this keyword for not suite tests
   ${cpu_err}      Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${CPU_policy}\\\\\\\\"} not found"}\\\')\') 
   ${mem_err}      Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${MEM_policy}\\\\\\\\"} not found"}\\\')\') 
   ${dsk_err}      Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${DSK_policy}\\\\\\\\"} not found"}\\\')\')
   ${acx_err}      Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${ACX_policy}\\\\\\\\"} not found"}\\\')\')
   ${cpu_err2}     Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert is in use by App"}\\\')\')
   ${mem_err2}     Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert is in use by App"}\\\')\')
   ${dsk_err2}     Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert is in use by App"}\\\')\')
   ${acx_err2}     Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert is in use by App"}\\\')\')
   ${cpu_deleted}  Set Variable  (added to app)
#CPU AlertPolicy
   ${cpu_policy_name}=  Run Keyword And Ignore Error  Delete Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}  alert_org=${alert_org}
   Run Keyword If     ${cpu_err}==${cpu_policy_name}     Log To Console  ${\n}${CPU_policy} does not exist not deleted
   Run Keyword If     ${cpu_err2}==${cpu_policy_name}    Log To Console  ${\n}${CPU_policy} is in use by App not deleted
   Run Keyword If     ${cpu_err}!=${cpu_policy_name}     Log To Console  ${\n}${CPU_policy} was deleted
#MEM AlertPolicy
   ${mem_policy_name}=  Run Keyword And Ignore Error  Delete Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}  alert_org=${alert_org}
   Run Keyword If     ${mem_err}==${mem_policy_name}     Log To Console  ${\n}${MEM_policy} does not exist not deleted
   Run Keyword If     ${mem_err2}==${mem_policy_name}    Log To Console  ${\n}${MEM_policy} is in use by App not deleted
   Run Keyword If     ${mem_err}!=${mem_policy_name}     Log To Console  ${\n}${MEM_policy} was deleted
#DSK AlertPolicy  
   ${dsk_policy_name}=  Run Keyword And Ignore Error  Delete Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}  alert_org=${alert_org}
   Run Keyword If     ${dsk_err}==${dsk_policy_name}     Log To Console  ${\n}${DSK_policy} does not exist not deleted
   Run Keyword If     ${dsk_err2}==${dsk_policy_name}    Log To Console  ${\n}${DSK_policy} is in use by App not deleted
   Run Keyword If     ${dsk_err}!=${dsk_policy_name}     Log To Console  ${\n}${DSK_policy} was deleted
#ACX AlertPolicy
   ${acx_policy_name}=  Run Keyword And Ignore Error  Delete Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}  alert_org=${alert_org}
   Run Keyword If     ${acx_err}==${acx_policy_name}     Log To Console  ${\n}${ACX_policy} does not exist not deleted
   Run Keyword If     ${acx_err2}==${acx_policy_name}    Log To Console  ${\n}${ACX_policy} is in use by App not deleted
   Run Keyword If     ${acx_err}!=${acx_policy_name}     Log To Console  ${\n}${ACX_policy} was deleted

Update Policies Severity Warning Trigger32
#Update Alert Policies intial trigger has to be updated with 30s until the mc settings is changed to 3s 
#Updating alert policies if exists
   ${cpu_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${CPUpolicy}\\\\\\\\"} not found"}\\\')\')
   ${mem_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${MEMpolicy}\\\\\\\\"} not found"}\\\')\')
   ${dsk_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${DSKpolicy}\\\\\\\\"} not found"}\\\')\')
   ${acx_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${ACXpolicy}\\\\\\\\"} not found"}\\\')\')
#CPU AlertPolicy
   ${cpu_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}  severity=${wrn}  trigger_time=${tt_32s}  alert_org=${alert_org}     cpu_utilization=${cpu_util_val}  labels_vars=Error=CPU  annotations_vars=description=[CPU] Error on 8086 critical consumption app needs 1.21 gigawatts of CPU power  description=description-cpu
   ${nogo}=  Run Keyword If  ${cpu_err}==${cpu_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${CPU_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${cpu_err}!=${cpu_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${CPU_policy} was updated
   ${cpu_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}
   ${cpu_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['severity']}
   ${cpu_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_trig}  ${tt_policy32}
#MEM AlertPolicy
   ${mem_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}  severity=${wrn}  trigger_time=${tt_32s}  alert_org=${alert_org}     mem_utilization=${mem_util_val}  labels_vars=Error=MEM  annotations_vars=description=[MEM] Error on 8086 critical consumption app needs 1.21 gigawatts of MEM power  description=description-mem
   ${nogo}=  Run Keyword If  ${mem_err}==${mem_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${MEM_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${mem_err}!=${mem_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${MEM_policy} was updated
   ${mem_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}
   ${mem_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['severity']}
   ${mem_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_trig}  ${tt_policy32}
#DSK AlertPolicy
   ${dsk_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}  severity=${wrn}  trigger_time=${tt_32s}  alert_org=${alert_org}    disk_utilization=${dsk_util_val}  labels_vars=Error=DSK  annotations_vars=description=[DSK] Error on 8086 critical consumption app needs 1.21 gigawatts of DSK power  description=description-dsk
   ${nogo}=  Run Keyword If  ${dsk_err}==${dsk_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${DSK_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${dsk_err}!=${dsk_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${DSK_policy} was updated
   ${dsk_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}
   ${dsk_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['severity']}
   ${dsk_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_trig}  ${tt_policy32}
#ACX AlertPolicy
   ${acx_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}  severity=${wrn}  trigger_time=${tt_32s}  alert_org=${alert_org}  active_connections=${acx_util_val}  labels_vars=Error=ACX  annotations_vars=description=[ACX] Error on 8086 critical consumption app needs 1.21 gigawatts of ACX power  description=description-acx
   ${nogo}=  Run Keyword If  ${acx_err}==${acx_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${ACX_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${acx_err}!=${acx_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${ACX_policy} was updated
   ${acx_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}
   ${acx_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['severity']}
   ${acx_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_trig}  ${tt_policy32}
   Sleep  2seconds

Add Policies To App
#Adding alert policies to app if does not  exist
   ${cpu_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert ${CPUpolicy} already monitored on App"}\\\')\') 
   ${mem_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert ${MEMpolicy} already monitored on App"}\\\')\')
   ${dsk_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert ${DSKpolicy} already monitored on App"}\\\')\')
   ${acx_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert ${ACXpolicy} already monitored on App"}\\\')\') 
#CPU AlertPolicy
   ${cpu_policy_add}=  Run Keyword And Ignore Error    Add Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${CPU_policy}  app_org=${app_org}
   Run Keyword If      ${cpu_err}==${cpu_policy_add}    Log To Console  ${\n}${CPU_policy} already added not adding to app ${app_name}
   Run Keyword If      ${cpu_err}!=${cpu_policy_add}    Log To Console  ${\n}${CPU_policy} added to ${app_name}
#MEM AlertPolicy
   ${mem_policy_add}=  Run Keyword And Ignore Error    Add Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${MEM_policy}  app_org=${app_org}
   Run Keyword If      ${mem_err}==${mem_policy_add}    Log To Console  ${\n}${MEM_policy} already added not adding to app ${app_name}
   Run Keyword If      ${mem_err}!=${mem_policy_add}    Log To Console  ${\n}${MEM_policy} added to ${app_name}
#DSK AlertPolicy
   ${dsk_policy_add}=  Run Keyword And Ignore Error    Add Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${DSK_policy}  app_org=${app_org}
   Run Keyword If      ${dsk_err}==${dsk_policy_add}    Log To Console  ${\n}${DSK_policy} already added not adding to app ${app_name}
   Run Keyword If      ${dsk_err}!=${dsk_policy_add}    Log To Console  ${\n}${DSK_policy} added to ${app_name}
#ACX AlertPolicy
   ${acx_policy_add}=  Run Keyword And Ignore Error    Add Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${ACX_policy}  app_org=${app_org}
   Run Keyword If      ${acx_err}==${acx_policy_add}    Log To Console  ${\n}${ACX_policy} already added not adding to app ${app_name}
   Run Keyword If      ${acx_err}!=${acx_policy_add}    Log To Console  ${\n}${ACX_policy} added to ${app_name}

Show Alert Policies From App
    ${super_token}  Get Super Token
    Set Suite Variable  ${super_token}
    ${policy_show_app}=  Run Keyword  Show Apps  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}
    ${app_alerts_added}  Convert To String  ${policy_show_app[0]['data']['alert_policies']}
    Set Variable  ${app_alerts_added}
    @{alert_list}  Create List  ${app_alerts_added}
    Run Keyword  Should Contain   @{alert_list}  ${CPU_policy}
    Run Keyword  Should Contain   @{alert_list}  ${MEM_policy}
    Run Keyword  Should Contain   @{alert_list}  ${DSK_policy}
    Run Keyword  Should Contain   @{alert_list}  ${ACX_policy}
    Log To Console  ${app_alerts_added}


Remove Alert Policies From App
#This keyword can not be run in a suite because teardown already does this but leaving this keyword to use in a different testcase.   
   ${alert_pass}  Set Variable       4
   ${alert_no_remove}  Set Variable  4
   ${alert_remove}  Set Variable     4

   ${cpu_err1}  Set Variable  (\'PASS\', {}) 
   ${cpu_err2}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {} not found"}\\\')\')
   ${cpu_err3}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"App key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${app_name}\\\\\\\\",\\\\\\\\"version\\\\\\\\":\\\\\\\\"11.8.6\\\\\\\\"} not found"}\\\')\')
   ${mem_err1}  Set Variable  (\'PASS\', {}) 
   ${mem_err2}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {} not found"}\\\')\')
   ${mem_err3}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"App key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${app_name}\\\\\\\\",\\\\\\\\"version\\\\\\\\":\\\\\\\\"11.8.6\\\\\\\\"} not found"}\\\')\')
   ${dsk_err1}  Set Variable  (\'PASS\', {})
   ${dsk_err2}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {} not found"}\\\')\')
   ${dsk_err3}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"App key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${app_name}\\\\\\\\",\\\\\\\\"version\\\\\\\\":\\\\\\\\"11.8.6\\\\\\\\"} not found"}\\\')\')
   ${acx_err1}  Set Variable  (\'PASS\', {})
   ${acx_err2}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {} not found"}\\\')\')
   ${acx_err3}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"App key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${app_name}\\\\\\\\",\\\\\\\\"version\\\\\\\\":\\\\\\\\"11.8.6\\\\\\\\"} not found"}\\\')\')
#CPU AlertPolicy
   ${cpu_policy_add}=  Run Keyword And Ignore Error    Remove Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${CPU_policy}  app_org=${app_org}
   Run Keyword If  ${cpu_err1}==${cpu_policy_add}  Run Keywords   Log To Console  ${\n}${CPU_policy} monitored policy removed from app ${app_name}  AND  Set Variable Pass  AND  Should Be Equal  ${alert_pass}  1
   Run Keyword If  ${cpu_err2}==${cpu_policy_add}  Run Keywords   Log To Console  ${\n}${CPU_policy} no policies to remove from app ${app_name}  AND  Set Variable Noremove  AND   Should Not Be Equal  ${alert_no_remove}  2
   Run Keyword If  ${cpu_err3}==${cpu_policy_add}  Run Keywords   Log To Console  ${\n}${CPU_policy} no policy found to remove from app ${app_name}  AND  Set Variable Remove  AND  Should Not Be Equal  ${alert_remove}  3
#MEM AlertPolicy
   ${mem_policy_add}=  Run Keyword And Ignore Error    Remove Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${MEM_policy}  app_org=${app_org}
   Run Keyword If  ${mem_err1}==${mem_policy_add}  Run Keywords   Log To Console  ${\n}${MEM_policy} monitored policy removed from app ${app_name}  AND  Set Variable Pass  AND  Should Be Equal  ${alert_pass}  1
   Run Keyword If  ${cpu_err2}==${mem_policy_add}  Run Keywords   Log To Console  ${\n}${MEM_policy} no policies to remove from app ${app_name}  AND  Set Variable Noremove  AND   Should Not Be Equal  ${alert_no_remove}  2
   Run Keyword If  ${cpu_err3}==${mem_policy_add}  Run Keywords   Log To Console  ${\n}${MEM_policy} no policy found to remove from app ${app_name}  AND  Set Variable Remove  AND  Should Not Be Equal  ${alert_remove}  3
#DSK AlertPolicy
   ${dsk_policy_add}=  Run Keyword And Ignore Error    Remove Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${DSK_policy}  app_org=${app_org}
   Run Keyword If  ${dsk_err1}==${dsk_policy_add}  Run Keywords   Log To Console  ${\n}${DSK_policy} monitored policy removed from app ${app_name}  AND  Set Variable Pass  AND  Should Be Equal  ${alert_pass}  1
   Run Keyword If  ${dsk_err2}==${dsk_policy_add}  Run Keywords   Log To Console  ${\n}${DSK_policy} no policies to remove from app ${app_name}  AND  Set Variable Noremove  AND   Should Not Be Equal  ${alert_no_remove}  2
   Run Keyword If  ${dsk_err3}==${dsk_policy_add}  Run Keywords   Log To Console  ${\n}${DSK_policy} no policy found to remove from app ${app_name}  AND  Set Variable Remove  AND  Should Not Be Equal  ${alert_remove}  3
#ACX AlertPolicy
   ${acx_policy_add}=  Run Keyword And Ignore Error    Remove Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${ACX_policy}  app_org=${app_org}
   Run Keyword If  ${acx_err1}==${acx_policy_add}  Run Keywords   Log To Console  ${\n}${ACX_policy} monitored policy removed from app ${app_name}  AND  Set Variable Pass  AND  Should Be Equal  ${alert_pass}  1
   Run Keyword If  ${acx_err2}==${acx_policy_add}  Run Keywords   Log To Console  ${\n}${ACX_policy} no policies to remove from app ${app_name}  AND  Set Variable Noremove  AND   Should Not Be Equal  ${alert_no_remove}  2
   Run Keyword If  ${acx_err3}==${acx_policy_add}  Run Keywords   Log To Console  ${\n}${ACX_policy} no policy found to remove from app ${app_name}  AND  Set Variable Remove  AND  Should Not Be Equal  ${alert_remove}  3

Set Variable Pass
  Set Suite Variable  ${alert_pass}       1
Set Variable Noremove
  Set Suite Variable  ${alert_no_remove}  2
Set Variable Remove
  Set Suite Variable  ${alert_remove}     3
