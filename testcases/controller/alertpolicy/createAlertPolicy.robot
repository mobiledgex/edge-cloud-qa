# -*- coding: robot -*-
*** Settings ***
Documentation  CreateAlertPolicy 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime
Library  String

Test Setup  Setup Test
Test Teardown  Cleanup Provisioning

*** Variables ***
${developer}=  automation_dev_org
${region}=  US
${region_US}=  US
${region_EU}=  EU
#use sleep second to check webui this give you time to reresh page to troubleshoot or inspect
${sleep_seconds}  0seconds
${operator}=  packet
${counter}=  ${0}
${policy_name}=  alertpolicyrobot
${alert_policy_name}=  alertpolicyname 
${sev_info}=      info
${sev_warning}=   warning
${sev_error}=     error
${trigger_time}=  30
${value_random}=  0
#Trigger measurement values
${cpu_percentage}=       1
${mem_percentage}=       1
${disk_percentage}=      1
${connections_active}=   1
${max_active}=           4294967295
${max_persentage}=       100
#active-connections range limit 4294967296
${out_of_range_active}=  4294967296
${out_of_range_percentage}=  101
#labels specific to a testcase
${label-key}=     COOLsoftware
${label-value}=   Demo App 1.0
${label-key2}=    Developer
${label-value2}=  Demo Inc
${labels}=        labels
#annotations are  specific if key is title or description
${anno_title_key}=     title
${anno_title-value}=   Alert title that replaces default name if not set
${anno_desc_key}=      description
${anno_desc_val}=      Official description of the alert that has fired
${anno}=               annotations
${alert_description}=  This is just the description of the alert to not presented in the annotations
#if you want to wrtie a hms converstion function go ahead  I could not get it to work properly
${version}=  latest
${tt_s}=     30s
${tt_h}=     1.5h
${tt_hm}=    2h45m
${tt_hms}=   5h59m59s
${tt_maxh}=  72h
${tt_s_convert}=     0h0m30s
${tt_h_convert}=     1h30m0s
${tt_hm_convert}=    2h45m0s
${tt_hms_convert}=   5h59m59s
${tt_maxh_convert}=  72h0m0s
#Errors
${error_400_no_name}=     (\'code=400\', \'error={"message":"Invalid alert policy name"}\')
${error_400_bad_org}=     (\'code=400\', \'error={"message":"Invalid alert policy organization"}\')
${error_400_measure}=     (\'code=400\', \'error={"message":"At least one of the measurements for alert should be set"}\')
${error_parse_bad_time}=   (\'code=400\', \'error={"message":"Invalid JSON data: Unmarshal duration \\\\"30\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')
${error_400_bad_region}=   (\'code=400\', \'error={"message":"Region \\\\"86\\\\" not found"}\')
${error_400_60s_time}=    Error: Bad Request (400), Trigger time cannot be less than 1m0s
${error_400_no_trigger}=  Error: Bad Request (400), At least one of the measurements for alert should be set
${error_400_cpu_range}=   Error: Bad Request (400), Cpu utilization limit is percent. Valid values 1-100%
${error_400_mem_range}=   Error: Bad Request (400), Memory utilization limit is percent. Valid values 1-100%
${error_400_disk_range}=  Error: Bad Request (400), Disk utilization limit is percent. Valid values 1-100%
${error_400_already}=     Error: Bad Request (400), AlertPolicy key
${error_400_mix_trig}=    (\'code=400\', \'error={"message":"Active Connection Alerts should not include any other triggers"}\')
${error_400_low_trig}=    ('code=400', 'error={"message":"Trigger time cannot be less than 30s"}') 
${error_400_delete_err}=  Error: Bad Request (400), AlertPolicy key {"organization":"automation_dev_org","name":"alertrpolicyNotFoundHere}"} not found
${error_range_parse}=     (\'code=400\', \'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number 4294967296 for field \\\\"AlertPolicy.active_conn_limit\\\\" at offset 162"}\')
${error_parse_annos}=     IndexError: list index out of range
${error_parse_labels}=    IndexError: list index out of range
${error_missing_args}=    Error: missing required args:
${error_data_parse}=      Error: parsing arg "cpu-measurement=50" failed: invalid argument: key "cpu-measurement" not found
${error_invalid_syntax}=  Error: parsing arg "active-connections=" failed: unable to parse "" as uint: invalid syntax
${error_custom_error}=    Error: put new fix here
# Required Args:
#  region              Region name
#  alert-org           Name of the organization for the app that this alert can be applied to
#  name                Alert Policy name
#  severity            Alert severity level - one of info, warning, error
#
# Optional Args:
#  cpu-utilization     Container or pod CPU utilization rate(percentage) across all nodes. Valid values 1-100
#  mem-utilization     Container or pod memory utilization rate(percentage) across all nodes. Valid values 1-100
#  disk-utilization    Container or pod disk utilization rate(percentage) across all nodes. Valid values 1-100
#  active-connections  Active Connections alert threshold. Valid values 1-4294967295
#  trigger-time        Duration for which alert interval is active (max 72 hours)
#  labels              Additional Labels, specify labels:empty=true to clear
#  annotations         Additional Annotations for extra information about the alert, specify annotations:empty=true to clear
#  description         Description of the alert policy
# alert_policy_name_automation = 'automation_api_alert_policy_name'
# ${alert_policy_name}  alert_policy_name
# ${policy_return}=  Create Alert Policy  region=${region}  token=${token}  policy_name=${policyname}  app_org_name=${developername}  severity=${sev_info}  cpu_utilization=${cpu_util}   trigger_time=${tt_s}

*** Test Cases ***
# ECQ-3941 
CreateAlertPolicy - shall be able to create update and show active connections US region
   [Documentation]
   ...  - send CreateAlertPolicy with active connections 
   ...  - verify policy is created
   ...  - send UpdateAlertPolicy with new values increase trigger time, connections, and change severity
   ...  - verify policy is updated
#   [Tags]  US  done

   ${policy_return}=  Create Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_info}  active_connections=${connections_active}   trigger_time=${tt_s}

   Sleep  ${sleep_seconds}

   Should Be Equal             ${policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${policy_return['data']['active_conn_limit']}        ${connections_active} 
   Should Be Equal             ${policy_return['data']['severity']}                 ${sev_info}
   Should Be Equal             ${policy_return['data']['trigger_time']}             ${tt_s}

   #UpdateAlertPolicy - shall be able to updat active connections and secerity warning

   ${connections_active} =    set variable    ${connections_active}
   ${new_connections} =       set variable    ${50}
   ${connections_active} =    Evaluate        ${connections_active}+${new_connections}
   ${trigger_time} =          set variable    ${trigger_time}
   ${new_trigger_time} =      set variable    ${5370}  
   ${new_trigger_time} =      Evaluate        ${trigger_time}+${new_trigger_time}

   ${update_policy_return}=  Update Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_warning}  active_connections=${connections_active}   trigger_time=${new_trigger_time}s

   #log to console  \n${update_policy_return}

   Sleep  ${sleep_seconds}

   Should Be Equal             ${update_policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${update_policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${update_policy_return['data']['active_conn_limit']}        ${connections_active}
   Should Not Be Equal         ${update_policy_return['data']['severity']}                 ${sev_info}
   Should Be Equal             ${update_policy_return['data']['severity']}                 ${sev_warning}
   Should Be Equal             ${update_policy_return['data']['trigger_time']}             ${tt_h_convert}
   Should Not Be Equal         ${update_policy_return['data']['trigger_time']}             ${tt_s}

  #ShowAlertPolicy - shall be able to show alertpolicy details from name and alert-org

   ${show_policy_return}=  Show Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}

   Sleep  ${sleep_seconds}
   ${alertname}=  Set Variable  ${show_policy_return[0]['data']['key']['name']} 
   Should Be Equal             ${alertname}        ${alert_policy_name}

# ECQ-3942
CreateAlertPolicy - shall be able to create update and show active connections EU region
   [Documentation]
   ...  - send CreateAlertPolicy with active connections
   ...  - verify policy is created
   ...  - send UpdateAlertPolicy with new values increase trigger time, connections, and change severity
   ...  - verify policy is updated

#   [Tags]  EU  done

   ${policy_return}=  Create Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_info}  active_connections=${connections_active}   trigger_time=${tt_s}

   Sleep  ${sleep_seconds}

   Should Be Equal             ${policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${policy_return['data']['active_conn_limit']}        ${connections_active}
   Should Be Equal             ${policy_return['data']['severity']}                 ${sev_info}
   Should Be Equal             ${policy_return['data']['trigger_time']}             ${tt_s}

   #UpdateAlertPolicy - shall be able to updat active connections and secerity warning

   ${connections_active} =    set variable    ${connections_active}
   ${new_connections} =       set variable    ${50}
   ${connections_active} =    Evaluate        ${connections_active}+${new_connections}
   ${trigger_time} =          set variable    ${trigger_time}
   ${new_trigger_time} =      set variable    ${9870}
   ${new_trigger_time} =      Evaluate        ${trigger_time}+${new_trigger_time}

   ${update_policy_return}=  Update Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_warning}  active_connections=${connections_active}   trigger_time=${new_trigger_time}s

   Sleep  ${sleep_seconds}

   Should Be Equal             ${update_policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${update_policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${update_policy_return['data']['active_conn_limit']}        ${connections_active}
   Should Not Be Equal         ${update_policy_return['data']['severity']}                 ${sev_info}
   Should Be Equal             ${update_policy_return['data']['severity']}                 ${sev_warning}
   Should Be Equal             ${update_policy_return['data']['trigger_time']}             ${tt_hm_convert}
   Should Not Be Equal         ${update_policy_return['data']['trigger_time']}             ${tt_s}

  #ShowAlertPolicy - shall be able to show alertpolicy details from name and alert-org

   ${show_policy_return}=  Show Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}

   Sleep  ${sleep_seconds}
   ${alertname}=  Set Variable  ${show_policy_return[0]['data']['key']['name']}
   Should Be Equal             ${alertname}        ${alert_policy_name}

#ECQ-3943
CreateAlertPolicy - shall be able to create update and show cpu mem disk US region
   [Documentation]
   ...  - send CreateAlertPolicy with mem disk cpu
   ...  - verify policy is created
   ...  - send UpdateAlertPolicy with new values and change severity
   ...  - verify policy is updated
#   [Tags]  US  mem  disk  cpu  

   ${policy_return}=  Create Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_warning}  mem_utilization=${mem_percentage}  cpu_utilization=${cpu_percentage}  disk_utilization=${disk_percentage}  trigger_time=${tt_s}

   Sleep  ${sleep_seconds}

   Should Be Equal             ${policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${policy_return['data']['cpu_utilization_limit']}    ${cpu_percentage}
   Should Be Equal As Numbers  ${policy_return['data']['mem_utilization_limit']}    ${mem_percentage}
   Should Be Equal As Numbers  ${policy_return['data']['disk_utilization_limit']}   ${disk_percentage}
   Should Be Equal             ${policy_return['data']['severity']}                 ${sev_warning}
   Should Be Equal             ${policy_return['data']['trigger_time']}             ${tt_s}

   #UpdateAlertPolicy - shall be able to update mem disk cpu trigger severity values

   ${new_percentage} =        set variable    ${50}
   ${mem_percentage} =        set variable    ${mem_percentage}
   ${new_mem_p} =             Evaluate        ${new_percentage}+${mem_percentage}
   ${cpu_percentage} =        set variable    ${cpu_percentage}
   ${new_cpu_p} =             Evaluate        ${new_percentage}+${cpu_percentage}
   ${disk_percentage} =       set variable    ${disk_percentage}
   ${new_disk_p} =            Evaluate        ${new_percentage}+${disk_percentage}
   ${trigger_time} =          set variable    ${trigger_time}
   ${new_trigger_t} =         set variable    ${5370}
   ${new_trigger_t} =         Evaluate        ${new_trigger_t}+${trigger_time}

   ${update_policy_return}=  Update Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_error}  mem_utilization=${new_mem_p}  cpu_utilization=${new_cpu_p}  disk_utilization=${new_disk_p}  trigger_time=${new_trigger_t}s 

   Sleep  ${sleep_seconds}

   Should Be Equal             ${update_policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${update_policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${update_policy_return['data']['cpu_utilization_limit']}    ${new_cpu_p}
   Should Be Equal As Numbers  ${update_policy_return['data']['mem_utilization_limit']}    ${new_mem_p}
   Should Be Equal As Numbers  ${update_policy_return['data']['disk_utilization_limit']}   ${new_disk_p}
   Should Be Equal             ${update_policy_return['data']['severity']}                 ${sev_error}
   Should Be Equal             ${update_policy_return['data']['trigger_time']}             ${tt_h_convert}
   Should Not Be Equal         ${update_policy_return['data']['trigger_time']}             ${tt_s}

  #ShowAlertPolicy - shall be able to show alertpolicy details from name and alert-org

   ${show_policy_return}=  Show Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}

   Sleep  ${sleep_seconds}
   ${alertname}=  Set Variable  ${show_policy_return[0]['data']['key']['name']}
   Should Be Equal              ${alertname}        ${alert_policy_name}

#ECQ-3944
CreateAlertPolicy - shall be able to create update and show cpu mem disk EU region
   [Documentation]
   ...  - send CreateAlertPolicy with mem disk cpu
   ...  - verify policy is created
   ...  - send UpdateAlertPolicy with new values and change severity
   ...  - verify policy is updated
#   [Tags]  EU  mem  disk  cpu

   ${policy_return}=  Create Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_warning}  mem_utilization=${mem_percentage}  cpu_utilization=${cpu_percentage}  disk_utilization=${disk_percentage}  trigger_time=${tt_s}

   Sleep  ${sleep_seconds}

   Should Be Equal             ${policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${policy_return['data']['cpu_utilization_limit']}    ${cpu_percentage}
   Should Be Equal As Numbers  ${policy_return['data']['mem_utilization_limit']}    ${mem_percentage}
   Should Be Equal As Numbers  ${policy_return['data']['disk_utilization_limit']}   ${disk_percentage}
   Should Be Equal             ${policy_return['data']['severity']}                 ${sev_warning}
   Should Be Equal             ${policy_return['data']['trigger_time']}             ${tt_s}

   #UpdateAlertPolicy - shall be able to update mem disk cpu trigger severity values

   ${new_percentage} =        set variable    ${70}
   ${mem_percentage} =        set variable    ${mem_percentage}
   ${new_mem_p} =             Evaluate        ${new_percentage}+${mem_percentage}
   ${cpu_percentage} =        set variable    ${cpu_percentage}
   ${new_cpu_p} =             Evaluate        ${new_percentage}+${cpu_percentage}
   ${disk_percentage} =       set variable    ${disk_percentage}
   ${new_disk_p} =            Evaluate        ${new_percentage}+${disk_percentage}
   ${trigger_time} =          set variable    ${trigger_time}
   ${new_trigger_t} =         set variable    ${9870}
   ${new_trigger_t} =         Evaluate        ${new_trigger_t}+${trigger_time}

   ${update_policy_return}=  Update Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_info}  mem_utilization=${new_mem_p}  cpu_utilization=${new_cpu_p}  disk_utilization=${new_disk_p}  trigger_time=${new_trigger_t}s

   Sleep  ${sleep_seconds}

   Should Be Equal             ${update_policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${update_policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${update_policy_return['data']['cpu_utilization_limit']}    ${new_cpu_p}
   Should Be Equal As Numbers  ${update_policy_return['data']['mem_utilization_limit']}    ${new_mem_p}
   Should Be Equal As Numbers  ${update_policy_return['data']['disk_utilization_limit']}   ${new_disk_p}
   Should Be Equal             ${update_policy_return['data']['severity']}                 ${sev_info}
   Should Be Equal             ${update_policy_return['data']['trigger_time']}             ${tt_hm_convert}
   Should Not Be Equal         ${update_policy_return['data']['trigger_time']}             ${tt_s}

  #ShowAlertPolicy - shall be able to show alertpolicy details from name and alert-org

   ${show_policy_return}=  Show Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}

   Sleep  ${sleep_seconds}
   ${alertname}=       Set Variable  ${show_policy_return[0]['data']['key']['name']}
   Should Be Equal              ${alertname}        ${alert_policy_name}

#ECQ-3945
CreateAlertPolicy - shall be able to create a US policy with annotations and labels 
   [Documentation]
   ...  - send CreateAlertPolicy with annotations and labels US region
   ...  - verify policy is created
   ...  - send ShowAlertPolicy to verify annotations and label descriptions
#   [Tags]  US  title  annotations
   #Note the annotations_vars are using : and the labels are using , as the seperator for adding multiple of either to build the dict in alertpolicy.py to force you not to mix them up. 
   ${policy_return}=  Create Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_error}  disk_utilization=${disk_percentage}  trigger_time=${tt_s}  annotations_vars=${anno_title_key}=${anno_title-value}:${anno_desc_key}=${anno_desc_val}  labels_vars=${label-key}=${label-value},${label-key2}=${label-value2} 

   ${show_return}=  Show Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}

   Sleep  ${sleep_seconds}

   Should Be Equal             ${policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${policy_return['data']['disk_utilization_limit']}   ${disk_percentage}
   Should Be Equal             ${policy_return['data']['severity']}                 ${sev_error}
   Should Be Equal             ${policy_return['data']['trigger_time']}             ${tt_s}
   ${labels_1}        Set Variable    ${show_return[0]['data']['labels']}
   Should Contain              ${labels_1}         ${label-key}    ${label-value}  ${label-key2}    ${label-value2}
   ${annotations_1}   Set Variable    ${show_return[0]['data']['annotations']}
   Should Contain              ${annotations_1}   ${anno_title_key}  ${anno_title-value}  ${anno_desc_key}  ${anno_desc_val}

#ECQ-3946
CreateAlertPolicy - shall be able to create a EU policy with annotations and labels
   [Documentation]
   ...  - send CreateAlertPolicy with annotations and labels EU region
   ...  - verify policy is created
   ...  - send ShowAlertPolicy to verify annotations and label descriptions
#   [Tags]  EU  title  annotations
   #Note the annotations_vars are using : and the labels are using , as the seperator for adding multiple of either to build the dict in alertpolicy.py to force you not to mix them up.
   ${policy_return}=  Create Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_error}  disk_utilization=${disk_percentage}  trigger_time=${tt_s}  annotations_vars=${anno_title_key}=${anno_title-value}:${anno_desc_key}=${anno_desc_val}  labels_vars=${label-key}=${label-value},${label-key2}=${label-value2}

   ${show_return}=  Show Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}

   Sleep  ${sleep_seconds}

   Should Be Equal             ${policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${policy_return['data']['disk_utilization_limit']}   ${disk_percentage}
   Should Be Equal             ${policy_return['data']['severity']}                 ${sev_error}
   Should Be Equal             ${policy_return['data']['trigger_time']}             ${tt_s}
   ${labels_1}        Set Variable   ${show_return[0]['data']['labels']}
   Should Contain              ${labels_1}         ${label-key}    ${label-value}  ${label-key2}    ${label-value2}
   ${annotations_1}   Set Variable   ${show_return[0]['data']['annotations']}
   Should Contain              ${annotations_1}   ${anno_title_key}  ${anno_title-value}  ${anno_desc_key}  ${anno_desc_val}

#ECQ-3947
CreateAlertPolicy - shall be able to create multiple annotations labels US region 
   [Documentation]
   ...  - send CreateAlertPolicy with multiple sets of labels and annotations
   ...  - verify policy is created
#   [Tags]  US  multiple  title  annotations
   #Note the annotations_vars are using : and the labels are using , as the seperator for adding multiple of either to build the dict in alertpolicy.py to force you not to mix them up.

   ${value1}=  Get Time  epoch + 1
   ${value2}=  Get Time  epoch + 2
   ${value3}=  Get Time  epoch + 3

   ${policy_return}=  Create Alert Policy  region=${region_US}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_error}  disk_utilization=${disk_percentage}  trigger_time=${tt_s}  description=${alert_description}
   ...  annotations_vars=${anno}${value1}=value${value1}:${anno}${value2}=value2${value2}:anno3${value3}=value3${value3}:${anno_title_key}=${anno_title-value}:${anno_desc_key}=${anno_desc_val}
   ...  labels_vars=label${value1}=value${value1},label2${value2}=value2${value2},label3${value3}=value3${value3},${label-key}=${label-value} 

   Sleep  ${sleep_seconds}

   Should Be Equal             ${policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${policy_return['data']['disk_utilization_limit']}   ${disk_percentage}
   Should Be Equal             ${policy_return['data']['severity']}                 ${sev_error}
   Should Be Equal             ${policy_return['data']['trigger_time']}             ${tt_s}
   Should Be Equal             ${policy_return['data']['description']}              ${alert_description}
   Should Contain              ${policy_return['data']['annotations']}              ${anno_desc_key}  ${anno_desc_val} 
   Should Contain              ${policy_return['data']['annotations']}              ${anno_title_key}  ${anno_title-value}
   Should Contain              ${policy_return['data']['labels']}                   ${label-key}  ${label-value}

#ECQ-3948
CreateAlertPolicy - shall be able to create multiple annotations labels EU region
   [Documentation]
   ...  - send CreateAlertPolicy with multiple sets of labels and annotations
   ...  - verify policy is created
#   [Tags]  US  multiple  title  annotations
   #Note the annotations_vars are using : and the labels are using , as the seperator for adding multiple of either to build the dict in alertpolicy.py to force you not to mix them up.

   ${value1}=  Get Time  epoch + 1
   ${value2}=  Get Time  epoch + 2
   ${value3}=  Get Time  epoch + 3

   ${policy_return}=  Create Alert Policy  region=${region_EU}  alertpolicy_name=${alert_policy_name}  alert_org=${developer}  severity=${sev_error}  disk_utilization=${disk_percentage}  trigger_time=${tt_s}  description=${alert_description}
   ...  annotations_vars=${anno}${value1}=value${value1}:${anno}${value2}=value2${value2}:anno3${value3}=value3${value3}:${anno_title_key}=${anno_title-value}:${anno_desc_key}=${anno_desc_val}
   ...  labels_vars=label${value1}=value${value1},label2${value2}=value2${value2},label3${value3}=value3${value3},${label-key}=${label-value}

   Sleep  ${sleep_seconds}

   Should Be Equal             ${policy_return['data']['key']['name']}              ${alert_policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}      ${developer}
   Should Be Equal As Numbers  ${policy_return['data']['disk_utilization_limit']}   ${disk_percentage}
   Should Be Equal             ${policy_return['data']['severity']}                 ${sev_error}
   Should Be Equal             ${policy_return['data']['trigger_time']}             ${tt_s}
   Should Be Equal             ${policy_return['data']['description']}              ${alert_description}
   Should Contain              ${policy_return['data']['annotations']}              ${anno_desc_key}  ${anno_desc_val}
   Should Contain              ${policy_return['data']['annotations']}              ${anno_title_key}  ${anno_title-value}
   Should Contain              ${policy_return['data']['labels']}                   ${label-key}  ${label-value}

# ECQ-3949
CreateAlertPolicy - shall be able to create alert policy connections US region
   [Documentation]
   ...  - send CreateAlertPolicy and verify with multiple arguments
   ...  - verify severity type, trigger time, active connections values
   ...  - send ShowAlertPolicy to verity arguments after policy is created
#   [Tags]  connections  US 

   [Template]  Create An Alert Policy Connections US
      # US active connections info
      region=${region_US}  alertpolicy_name=${alert_policy_name}1  alert_org=${developer}  severity=info  active_connections=1            trigger_time=${tt_s}
      region=${region_US}  alertpolicy_name=${alert_policy_name}2  alert_org=${developer}  severity=info  active_connections=10           trigger_time=${tt_h}
      region=${region_US}  alertpolicy_name=${alert_policy_name}3  alert_org=${developer}  severity=info  active_connections=100          trigger_time=${tt_hm}
      region=${region_US}  alertpolicy_name=${alert_policy_name}4  alert_org=${developer}  severity=info  active_connections=1000         trigger_time=${tt_hms}
      region=${region_US}  alertpolicy_name=${alert_policy_name}5  alert_org=${developer}  severity=info  active_connections=4294967295   trigger_time=${tt_maxh}
      # US active connections warning
      region=${region_US}  alertpolicy_name=${alert_policy_name}6  alert_org=${developer}  severity=warning  active_connections=1            trigger_time=${tt_s}
      region=${region_US}  alertpolicy_name=${alert_policy_name}7  alert_org=${developer}  severity=warning  active_connections=10           trigger_time=${tt_h}
      region=${region_US}  alertpolicy_name=${alert_policy_name}8  alert_org=${developer}  severity=warning  active_connections=100          trigger_time=${tt_hm}
      region=${region_US}  alertpolicy_name=${alert_policy_name}9  alert_org=${developer}  severity=warning  active_connections=1000         trigger_time=${tt_hms}
      region=${region_US}  alertpolicy_name=${alert_policy_name}a  alert_org=${developer}  severity=warning  active_connections=4294967295   trigger_time=${tt_maxh}
      # US active connections error 
      region=${region_US}  alertpolicy_name=${alert_policy_name}b  alert_org=${developer}  severity=error  active_connections=1            trigger_time=${tt_s}
      region=${region_US}  alertpolicy_name=${alert_policy_name}c  alert_org=${developer}  severity=error  active_connections=10           trigger_time=${tt_h}
      region=${region_US}  alertpolicy_name=${alert_policy_name}d  alert_org=${developer}  severity=error  active_connections=100          trigger_time=${tt_hm}
      region=${region_US}  alertpolicy_name=${alert_policy_name}e  alert_org=${developer}  severity=error  active_connections=1000         trigger_time=${tt_hms}
      region=${region_US}  alertpolicy_name=${alert_policy_name}f  alert_org=${developer}  severity=error  active_connections=4294967295   trigger_time=${tt_maxh}

# ECQ-3950
CreateAlertPolicy - shall be able to create alert policy connections EU region
   [Documentation]
   ...  - send CreateAlertPolicy and verify with multiple arguments
   ...  - verify severity type, trigger time, active connections values
   ...  - send ShowAlertPolicy to verity arguments after policy is created
#   [Tags]  connections  EU

   [Template]  Create An Alert Policy Connections EU

      # EU active connections info
      region=${region_EU}  alertpolicy_name=${alert_policy_name}1  alert_org=${developer}  severity=info  active_connections=1            trigger_time=${tt_s}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}2  alert_org=${developer}  severity=info  active_connections=10           trigger_time=${tt_h}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}3  alert_org=${developer}  severity=info  active_connections=100          trigger_time=${tt_hm}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}4  alert_org=${developer}  severity=info  active_connections=1000         trigger_time=${tt_hms}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}5  alert_org=${developer}  severity=info  active_connections=4294967295   trigger_time=${tt_maxh}
      # EU active connections warning
      region=${region_EU}  alertpolicy_name=${alert_policy_name}6  alert_org=${developer}  severity=warning  active_connections=1            trigger_time=${tt_s}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}7  alert_org=${developer}  severity=warning  active_connections=10           trigger_time=${tt_h}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}8  alert_org=${developer}  severity=warning  active_connections=100          trigger_time=${tt_hm}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}9  alert_org=${developer}  severity=warning  active_connections=1000         trigger_time=${tt_hms}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}a  alert_org=${developer}  severity=warning  active_connections=4294967295   trigger_time=${tt_maxh}
      # EU active connections error
      region=${region_EU}  alertpolicy_name=${alert_policy_name}b  alert_org=${developer}  severity=error  active_connections=1            trigger_time=${tt_s}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}c  alert_org=${developer}  severity=error  active_connections=10           trigger_time=${tt_h}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}d  alert_org=${developer}  severity=error  active_connections=100          trigger_time=${tt_hm}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}e  alert_org=${developer}  severity=error  active_connections=1000         trigger_time=${tt_hms}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}f  alert_org=${developer}  severity=error  active_connections=4294967295   trigger_time=${tt_maxh}


# ECQ-3951
CreateAlertPolicy - shall be able to create alert policy utilization US region
   [Documentation]
   ...  - send CreateAlertPolicy and verify with multiple arguments
   ...  - verify severity type, trigger time, cpu mem disk utilization values
   ...  - send ShowAlertPolicy to verity arguments after policy is created
#   [Tags]  cpu  mem  disk  US
   
   [Template]  Create An Alert Policy Utilization US
      # US active connections info
      region=${region_US}  alertpolicy_name=${alert_policy_name}1  alert_org=${developer}  severity=info  cpu_utilization=25   trigger_time=${tt_s}

      region=${region_US}  alertpolicy_name=${alert_policy_name}2  alert_org=${developer}  severity=info  mem_utilization=25   trigger_time=${tt_h}
      region=${region_US}  alertpolicy_name=${alert_policy_name}3  alert_org=${developer}  severity=info  disk_utilization=25  trigger_time=${tt_hm}
      region=${region_US}  alertpolicy_name=${alert_policy_name}4  alert_org=${developer}  severity=info  cpu_utilization=25   trigger_time=${tt_hms}
      region=${region_US}  alertpolicy_name=${alert_policy_name}5  alert_org=${developer}  severity=info  mem_utilization=25   trigger_time=${tt_maxh}
      # US active connections warning
      region=${region_US}  alertpolicy_name=${alert_policy_name}6  alert_org=${developer}  severity=warning  cpu_utilization=50   mem_utilization=50   trigger_time=${tt_s}
      region=${region_US}  alertpolicy_name=${alert_policy_name}7  alert_org=${developer}  severity=warning  mem_utilization=25   disk_utilization=50  trigger_time=${tt_h}
      region=${region_US}  alertpolicy_name=${alert_policy_name}8  alert_org=${developer}  severity=warning  disk_utilization=25  cpu_utilization=25   trigger_time=${tt_hm}
      region=${region_US}  alertpolicy_name=${alert_policy_name}9  alert_org=${developer}  severity=warning  cpu_utilization=25   mem_utilization=25   trigger_time=${tt_hms}
      region=${region_US}  alertpolicy_name=${alert_policy_name}0  alert_org=${developer}  severity=warning  mem_utilization=25   cpu_utilization=50   trigger_time=${tt_maxh}      
      # US active connections error
      region=${region_US}  alertpolicy_name=${alert_policy_name}a  alert_org=${developer}  severity=error  cpu_utilization=20   mem_utilization=50   disk_utilization=75  trigger_time=${tt_s}
      region=${region_US}  alertpolicy_name=${alert_policy_name}b  alert_org=${developer}  severity=error  mem_utilization=25   disk_utilization=50  cpu_utilization=75   trigger_time=${tt_h}
      region=${region_US}  alertpolicy_name=${alert_policy_name}c  alert_org=${developer}  severity=error  disk_utilization=25  cpu_utilization=50   mem_utilization=75   trigger_time=${tt_hm}
      region=${region_US}  alertpolicy_name=${alert_policy_name}d  alert_org=${developer}  severity=error  cpu_utilization=25   mem_utilization=50   disk_utilization=75  trigger_time=${tt_hms}
      region=${region_US}  alertpolicy_name=${alert_policy_name}e  alert_org=${developer}  severity=error  mem_utilization=25   cpu_utilization=50   disk_utilization=75  trigger_time=${tt_maxh}

# ECQ-3952
CreateAlertPolicy - shall be able to create alert policy utilization EU region
   [Documentation]
   ...  - send CreateAlertPolicy and verify with multiple arguments
   ...  - verify severity type, trigger time, cpu mem disk utilization values
   ...  - send ShowAlertPolicy to verity arguments after policy is created
#   [Tags]  cpu  mem  disk  EU

   [Template]  Create An Alert Policy Utilization EU
      # EU active connections info
      region=${region_EU}  alertpolicy_name=${alert_policy_name}1  alert_org=${developer}  severity=info  cpu_utilization=25   trigger_time=${tt_s}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}2  alert_org=${developer}  severity=info  mem_utilization=25   trigger_time=${tt_h}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}3  alert_org=${developer}  severity=info  disk_utilization=25  trigger_time=${tt_hm}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}4  alert_org=${developer}  severity=info  cpu_utilization=25   trigger_time=${tt_hms}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}5  alert_org=${developer}  severity=info  mem_utilization=25   trigger_time=${tt_maxh}
      # EU active connections warning
      region=${region_EU}  alertpolicy_name=${alert_policy_name}6  alert_org=${developer}  severity=warning  cpu_utilization=50   mem_utilization=50   trigger_time=${tt_s}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}7  alert_org=${developer}  severity=warning  mem_utilization=25   disk_utilization=50  trigger_time=${tt_h}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}8  alert_org=${developer}  severity=warning  disk_utilization=25  cpu_utilization=25   trigger_time=${tt_hm}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}9  alert_org=${developer}  severity=warning  cpu_utilization=25   mem_utilization=25   trigger_time=${tt_hms}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}0  alert_org=${developer}  severity=warning  mem_utilization=25   cpu_utilization=50   trigger_time=${tt_maxh}
      # EU active connections error
      region=${region_EU}  alertpolicy_name=${alert_policy_name}a  alert_org=${developer}  severity=error  cpu_utilization=20   mem_utilization=50   disk_utilization=75  trigger_time=${tt_s}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}b  alert_org=${developer}  severity=error  mem_utilization=25   disk_utilization=50  cpu_utilization=75   trigger_time=${tt_h}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}c  alert_org=${developer}  severity=error  disk_utilization=25  cpu_utilization=50   mem_utilization=75   trigger_time=${tt_hm}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}d  alert_org=${developer}  severity=error  cpu_utilization=25   mem_utilization=50   disk_utilization=75  trigger_time=${tt_hms}
      region=${region_EU}  alertpolicy_name=${alert_policy_name}e  alert_org=${developer}  severity=error  mem_utilization=25   cpu_utilization=50   disk_utilization=75  trigger_time=${tt_maxh}

# ECQ-3953 
CreateAlertPolicy - shall handle create alert policy failures
   [Documentation]
   ...  - send CreateAlertPolicy with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Alert Policy

      ${error_400_no_name}     ${error_missing_args}    region=US
      ${error_400_bad_org}     ${error_missing_args}    region=US  alertpolicy_name=err-policy
      ${error_400_no_name}     ${error_missing_args}    region=EU  alert_org=${developer}
      ${error_400_measure}     ${error_custom_error}    region=US  alert_org=${developer}  alertpolicy_name=err-policy-1
      ${error_400_measure}     ${error_custom_error}    region=EU  alert_org=${developer}  alertpolicy_name=err-policy-2  severity=info
      ${error_parse_bad_time}  ${error_custom_error}    region=US  alert_org=${developer}  alertpolicy_name=err-policy-3  severity=info    active_connections=1  trigger_time=30
      ${error_400_mix_trig}    ${error_data_parse}      region=EU  alert_org=${developer}  alertpolicy_name=err-policy-4  severity=info    active_connections=10  cpu_utilization=50  trigger_time=30s
      ${error_400_mix_trig}    ${error_custom_error}    region=US  alert_org=${developer}  alertpolicy_name=err-policy-5  severity=info    active_connections=10  cpu_utilization=50  trigger_time=30s
      ${error_parse_labels}    ${error_parse_annos}     region=EU  alert_org=${developer}  alertpolicy_name=err-policy-6  labels_vars=bad        severity=info  disk_utilization=49  trigger_time=30s
      ${error_parse_annos}     ${error_parse_labels}    region=US  alert_org=${developer}  alertpolicy_name=err-policy-7  annotations_vars=bad   severity=info  disk_utilization=49  trigger_time=30s
      ${error_400_no_trigger}  ${error_parse_bad_time}  region=EU  alert_org=${developer}  alertpolicy_name=err-policy-8  severity=info    mem_utilization=0  trigger_time=30
      ${error_range_parse}     ${error_400_mix_trig}    region=US  alert_org=${developer}  alertpolicy_name=err-policy-9  severity=info    active_connections=${out_of_range_active}  trigger_time=30s
      ${error_400_low_trig}    ${error_parse_bad_time}  region=EU  alert_org=${developer}  alertpolicy_name=err-policy-0  severity=info    mem_utilization=1
      ${error_400_low_trig}    ${error_parse_bad_time}  region=EU  alert_org=${developer}  alertpolicy_name=err-policy-a  severity=info    disk_utilization=1  trigger_time=20s
      ${error_400_low_trig}    ${error_parse_bad_time}  region=US  alert_org=${developer}  alertpolicy_name=err-policy-b  severity=info    cpu_utilization=1
      ${error_400_bad_region}  ${error_parse_bad_time}  region=86  alert_org=${developer}  alertpolicy_name=err-policy-c  severity=info    


*** Keywords ***
Setup
   Run mcctl  settings update alertpolicymintriggertime=30s region=EU
   Run mcctl  settings update alertpolicymintriggertime=30s region=US
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
   ${alert_policy_name}=  Get Default Alert Policy Name
   Set Suite Variable  ${alert_policy_name}

Setup Test
   Run mcctl  settings update alertpolicymintriggertime=30s region=EU
   Run mcctl  settings update alertpolicymintriggertime=30s region=US
   ${token}=  Get Super Token
   Set Test Variable  ${token}
   ${alert_policy_name}=  Get Default Alert Policy Name
   Set Test Variable  ${alert_policy_name}

Fail Create Alert Policy
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}
   ${policy}=    Run Keyword and Expect Error  *  Create Alert Policy  &{parms}  token=${token}  use_defaults=${False}
   Should Contain Any  ${policy}    ${error_msg}  ${error_msg2}

Create An Alert Policy Connections US
   [Arguments]  &{parms}
   &{parms}=     set variable  ${parms}
   ${counter}=   set variable  ${counter}
   ${counter}=   Evaluate      ${counter} + 1
   ${policy}=    Create Alert Policy  &{parms}  token=${token}  use_defaults=${False}
   ${show_US}=   Show Alert Policy    region=${region_US}  alertpolicy_name=${parms['alertpolicy_name']}  alert_org=${parms['alert_org']}

   Should Be Equal             ${policy['data']['key']['name']}              ${parms['alertpolicy_name']}
   Should Be Equal             ${policy['data']['key']['organization']}      ${parms['alert_org']}
   Should Be Equal As Numbers  ${policy['data']['active_conn_limit']}        ${parms['active_connections']}
   Should Be Equal             ${policy['data']['severity']})                ${parms['severity']})
   Should Contain Any          ${policy['data']['trigger_time']})            ${tt_s}  {tt_s_convert}  ${tt_h_convert}  ${tt_hm_convert}  ${tt_hms_convert}  ${tt_maxh_convert}
   ${policy_seconds} =    Set Variable    ${policy['data']['trigger_time']}

Create An Alert Policy Connections EU
   [Arguments]  &{parms}
   &{parms}=     set variable  ${parms}
   ${counter}=   set variable  ${counter}
   ${counter}=   Evaluate      ${counter} + 1
   ${policy}=    Create Alert Policy  &{parms}  token=${token}  use_defaults=${False}
   ${show_EU}=   Show Alert Policy    region=${region_EU}  alertpolicy_name=${parms['alertpolicy_name']}  alert_org=${parms['alert_org']}

   Should Be Equal             ${policy['data']['key']['name']}              ${parms['alertpolicy_name']}
   Should Be Equal             ${policy['data']['key']['organization']}      ${parms['alert_org']}
   Should Be Equal As Numbers  ${policy['data']['active_conn_limit']}        ${parms['active_connections']}
   Should Be Equal             ${policy['data']['severity']})                ${parms['severity']})
   Should Contain Any          ${policy['data']['trigger_time']})            ${tt_s}  {tt_s_convert}  ${tt_h_convert}  ${tt_hm_convert}  ${tt_hms_convert}  ${tt_maxh_convert}
   ${policy_seconds} =    Set Variable    ${policy['data']['trigger_time']}

Create An Alert Policy Utilization US
   [Arguments]  &{parms}
   &{parms}=     set variable  ${parms}
   ${counter}=   set variable  ${counter}
   ${counter}=   Evaluate      ${counter} + 1
   ${policy}=    Create Alert Policy  &{parms}  token=${token}  use_defaults=${False}
   ${show_US}=   Show Alert Policy    region=${region_US}  alertpolicy_name=${parms['alertpolicy_name']}  alert_org=${parms['alert_org']}

   Should Be Equal             ${policy['data']['key']['name']}              ${parms['alertpolicy_name']}
   Should Be Equal             ${policy['data']['key']['organization']}      ${parms['alert_org']}
   Should Be Equal             ${policy['data']['severity']})                ${parms['severity']})
   Should Contain Any          ${policy['data']['trigger_time']})            ${tt_s}  {tt_s_convert}  ${tt_h_convert}  ${tt_hm_convert}  ${tt_hms_convert}  ${tt_maxh_convert}
   Run Keyword If  'cpu_utilization' in ${parms}     Should Be Equal As Numbers  ${policy['data']['cpu_utilization_limit']}    ${show_US[0]['data']['cpu_utilization_limit']}
   Run Keyword If  'mem_utilization' in ${parms}     Should Be Equal As Numbers  ${policy['data']['mem_utilization_limit']}    ${show_US[0]['data']['mem_utilization_limit']}
   Run Keyword If  'disk_utilization' in ${parms}    Should Be Equal As Numbers  ${policy['data']['disk_utilization_limit']}   ${show_US[0]['data']['disk_utilization_limit']}
   ${policy_seconds} =    Set Variable    ${policy['data']['trigger_time']}

Create An Alert Policy Utilization EU
   [Arguments]  &{parms}
   &{parms}=     set variable  ${parms}
   ${counter}=   set variable  ${counter}
   ${counter}=   Evaluate      ${counter} + 1
   ${policy}=    Create Alert Policy  &{parms}  token=${token}  use_defaults=${False}
   ${show_EU}=   Show Alert Policy    region=${region_EU}  alertpolicy_name=${parms['alertpolicy_name']}  alert_org=${parms['alert_org']}

   Should Be Equal             ${policy['data']['key']['name']}              ${parms['alertpolicy_name']}
   Should Be Equal             ${policy['data']['key']['organization']}      ${parms['alert_org']}
   Should Be Equal             ${policy['data']['severity']})                ${parms['severity']})
   Should Contain Any          ${policy['data']['trigger_time']})            ${tt_s}  {tt_s_convert}  ${tt_h_convert}  ${tt_hm_convert}  ${tt_hms_convert}  ${tt_maxh_convert}
   Run Keyword If  'cpu_utilization' in ${parms}     Should Be Equal As Numbers  ${policy['data']['cpu_utilization_limit']}    ${show_EU[0]['data']['cpu_utilization_limit']}
   Run Keyword If  'mem_utilization' in ${parms}     Should Be Equal As Numbers  ${policy['data']['mem_utilization_limit']}    ${show_EU[0]['data']['mem_utilization_limit']}
   Run Keyword If  'disk_utilization' in ${parms}    Should Be Equal As Numbers  ${policy['data']['disk_utilization_limit']}   ${show_EU[0]['data']['disk_utilization_limit']}

Update Teardown
   Run mcctl  settings update alertpolicymintriggertime=30s region=EU
   Run mcctl  settings update alertpolicymintriggertime=30s region=US
