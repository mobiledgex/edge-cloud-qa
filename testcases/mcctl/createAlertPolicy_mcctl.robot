# -*- coding: robot -*-
*** Settings ***
Documentation  CreateAlertPolicy mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  automation_dev_org
${alert_org}=  MobiledgeX
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
${max_active}=  4294967295
#activeconnections range limit 4294967296
${out_of_range}=  4294967296
${error_400_no_region}=   Error: Bad Request (400), Region "86" not found
${error_400_no_time}=     Error: Bad Request (400), Trigger time cannot be less than 30s
${error_400_60s_time}=    Error: Bad Request (400), Trigger time cannot be less than 1m0s
${error_400_no_trigger}=  Error: Bad Request (400), At least one of the measurements for alert should be set
${error_400_cpu_range}=   Error: Bad Request (400), Cpu utilization limit is percent. Valid values 1-100%
${error_400_mem_range}=   Error: Bad Request (400), Memory utilization limit is percent. Valid values 1-100%
${error_400_disk_range}=  Error: Bad Request (400), Disk utilization limit is percent. Valid values 1-100%
${error_400_already}=     Error: Bad Request (400), AlertPolicy key
${error_400_mix_trig}=    Error: Bad Request (400), Active Connection Alerts should not include any other triggers 
${error_400_delete_err}=  Error: Bad Request (400), AlertPolicy key {"organization":"automation_dev_org","name":"alertrpolicyNotFoundHere}"} not found
${error_parse_bad_time}=  Error: parsing arg "triggertime\=30" failed: unable to parse "30" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc
${error_range_parse}=     Error: parsing arg "activeconnections=4294967296" failed: unable to parse "4294967296" as uint: value out of range
${error_parse_annos}=     Error: parsing arg "annotations=bad" failed: value "bad" must be formatted as key=value
${error_parse_labels}=    Error: parsing arg "labels=bad" failed: value "bad" must be formatted as key=value
${error_missing_args}=    Error: missing required args:
${error_data_parse}=      Error: parsing arg "cpu-measurement=50" failed: invalid argument: key "cpu-measurement" not found
${error_invalid_syntax}=  Error: parsing arg "activeconnections=" failed: unable to parse "" as uint: invalid syntax
${error_custom_error}=    Error: put new fix here

#updated test 02-1102022
#Required Args:
#  region             Region name
#  alertorg           Name of the organization for the app that this alert can be applied to
#  name               Alert Policy name
#  severity           Alert severity level - one of info, warning, error
#
#Optional Args:
#  cpuutilization     Container or pod CPU utilization rate(percentage) across all nodes. Valid values 1-100
#  memutilization     Container or pod memory utilization rate(percentage) across all nodes. Valid values 1-100
#  diskutilization    Container or pod disk utilization rate(percentage) across all nodes. Valid values 1-100
#  activeconnections  Active Connections alert threshold. Valid values 1-4294967295
#  triggertime        Duration for which alert interval is active (max 72 hours)
#  labels             Additional Labels, specify labels:empty=true to clear
#  annotations        Additional Annotations for extra information about the alert, specify annotations:empty=true to clear
#  description        Description of the alert policy
#
# OLD FORMAT for reference this was prior to dash change
#  region              Region name
#  alert-org           Name of the organization for the app that this alert can be applied to
#  name                Alert Policy name
#  severity            Alert severity level - one of info, warning, error
#
#Optional Args:
#  cpu-utilization     Container or pod CPU utilization rate(percentage) across all nodes. Valid values 1-100
#  mem-utilization     Container or pod memory utilization rate(percentage) across all nodes. Valid values 1-100
#  disk-utilization    Container or pod disk utilization rate(percentage) across all nodes. Valid values 1-100
#  active-connections  Active Connections alert threshold. Valid values 1-4294967295
#  trigger-time        Duration for which alert interval is active (max 72 hours)
#  labels              Additional Labels, specify labels:empty=true to clear
#  annotations         Additional Annotations for extra information about the alert, specify annotations:empty=true to clear
#  description         Description of the alert policy

#Note you cannot mix typ utilization cpu,mem,disk with type activeconnections as trigger measurements for an alert policy

*** Test Cases ***
# ECQ-3829
CreateAlertPolicy - mcctl shall be able to create/show/delete alert policy
   [Documentation]
   ...  - send CreateAlertPolicy via mcctl with required and optional arguments
   ...  - verify alertpolicy create show and delete

   [Template]  Success Create/Show/Delete Alert Policy Via mcctl 
      # info
      name=${recv_name}  alertorg=${developer}  severity=info     activeconnections=1           triggertime=30s
      name=${recv_name}  alertorg=${developer}  severity=info     cpuutilization=25             triggertime=${tt_h}
      name=${recv_name}  alertorg=${developer}  severity=info     memutilization=25             triggertime=${tt_hm}
      name=${recv_name}  alertorg=${developer}  severity=info     diskutilization=25            triggertime=${tt_hms}
      name=${recv_name}  alertorg=${developer}  severity=info     activeconnections=${max_active}  triggertime=${tt_maxh}
      name=${recv_name}  alertorg=${developer}  severity=info     cpuutilization=25  memutilization=25  diskutilization=25  triggertime=${tt_maxh}  labels=labelname=labelvalue-info  annotations=title=titlename-info  description=description-info
      name=${recv_name}  alertorg=${developer}  severity=info     activeconnections=1000000  triggertime=${tt_s}  labels=labelname=labelvalue-info  annotations=title=titlename-info  description=description-info
      # warning
      name=${recv_name}  alertorg=${developer}  severity=warning  activeconnections=2           triggertime=${tt_s}
      name=${recv_name}  alertorg=${developer}  severity=warning  cpuutilization=50             triggertime=${tt_h}
      name=${recv_name}  alertorg=${developer}  severity=warning  memutilization=50             triggertime=${tt_hm}
      name=${recv_name}  alertorg=${developer}  severity=warning  diskutilization=50            triggertime=${tt_hms}
      name=${recv_name}  alertorg=${developer}  severity=warning  activeconnections=${max_active}  triggertime=${tt_maxh}
      name=${recv_name}  alertorg=${developer}  severity=warning  cpuutilization=50  memutilization=50  diskutilization=50  triggertime=${tt_maxh}  labels=labelname=labelvalue-warning  annotations=title=titlename-warning  description=description-warning
      name=${recv_name}  alertorg=${developer}  severity=warning     activeconnections=2000000  triggertime=${tt_s}  labels=labelname=labelvalue-warning  annotations=title=titlename-warning  description=description-warning
      # connections error
      name=${recv_name}  alertorg=${developer}  severity=error    activeconnections=3            triggertime=${tt_s}
      name=${recv_name}  alertorg=${developer}  severity=error    cpuutilization=100             triggertime=${tt_h}
      name=${recv_name}  alertorg=${developer}  severity=error    memutilization=100             triggertime=${tt_hm}
      name=${recv_name}  alertorg=${developer}  severity=error    diskutilization=100            triggertime=${tt_hms}
      name=${recv_name}  alertorg=${developer}  severity=error    activeconnections=${max_active}  triggertime=${tt_maxh}
      name=${recv_name}  alertorg=${developer}  severity=error  cpuutilization=100  memutilization=100  diskutilization=100  triggertime=${tt_maxh}  labels=labelname=labelvalue-error  annotations=title=titlename-error  description=description-error
      name=${recv_name}  alertorg=${developer}  severity=error     activeconnections=3000000  triggertime=${tt_s}  labels=labelname=labelvalue-error  annotations=title=titlename-error  description=description-error

# ECQ-3830
CreateAlertPolicy - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateAlertPolicy via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Alert Policy Via mcctl

      ${error_missing_args}    ${error_custom_error}    #not sending any args with mcctl
      ${error_missing_args}    ${error_custom_error}    name=${recv_name}
      ${error_missing_args}    ${error_custom_error}    alertorg=${developer}
      ${error_missing_args}    ${error_custom_error}    alertorg=${developer}  name=${recv_name}
      ${error_400_no_time}     ${error_400_no_trigger}  alertorg=${developer}  name=${recv_name}  severity=info
      ${error_parse_bad_time}  ${error_custom_error}    alertorg=${developer}  name=${recv_name}  severity=info    activeconnections=1  triggertime=30
      ${error_data_parse}      ${error_custom_error}    alertorg=${developer}  name=${recv_name}  severity=info    activeconnections=10  cpu-measurement=50  triggertime=30s
      ${error_400_mix_trig}    ${error_custom_error}    alertorg=${developer}  name=${recv_name}  severity=info    activeconnections=10  cpuutilization=50  triggertime=30s
      ${error_parse_labels}    ${error_parse_annos}     alertorg=${developer}  name=${recv_name}  labels=bad       severity=info  diskutilization=49  triggertime=30s
      ${error_parse_annos}     ${error_parse_labels}    alertorg=${developer}  name=${recv_name}  annotations=bad  severity=info  diskutilization=49  triggertime=30s
      ${error_400_no_trigger}  ${error_parse_bad_time}  alertorg=${developer}  name=${recv_name}  severity=info    memutilization=0  triggertime=30
      ${error_range_parse}     ${error_400_mix_trig}    alertorg=${developer}  name=${recv_name}  severity=info    activeconnections=${out_of_range}  triggertime=30s
      ${error_400_no_trigger}  ${error_parse_bad_time}  alertorg=${developer}  name=${recv_name}  severity=info    memutilization=0
      ${error_400_no_trigger}  ${error_parse_bad_time}  alertorg=${developer}  name=${recv_name}  severity=info    diskutilization=0
      ${error_400_no_trigger}  ${error_parse_bad_time}  alertorg=${developer}  name=${recv_name}  severity=info    cpuutilization=0
      ${error_400_no_region}   ${error_parse_bad_time}  alertorg=${developer}  name=${recv_name}  severity=info    region=86

# ECQ-3831
DeleteAlertPolicy - mcctl shall handle delete failures
   [Documentation]
   ...  - send DeleteAlertPolicy via mcctl with various error cases
   ...  - verify proper error is received

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Fail Delete Alert Policy Via mcctl

      # removed the args since they comeback in different order
      ${error_missing_args}    ${error_custom_error}    #not sending any args with mcctl
      ${error_missing_args}    ${error_custom_error}    name=${recv_name}NotFoundHere
      ${error_missing_args}    ${error_custom_error}    alertorg=NoOrgHere${recv_name}
      ${error_400_delete_err}  ${error_missing_args}    alertorg=${developer}  name=alertrpolicyNotFoundHere}

# ECQ-3832
UpdateAlertPolicy - mcctl shall handle update success type utilization Alert Policy
   [Documentation]
   ...  - send UpdateAlertPolicy type utilization via mcctl with various args
   ...  - verify policy is updated

   [Setup]  Update Setup     #setup is needed because intial alertpolicy is of type measurements and cannot mix mactch with connections
   [Teardown]  Update Teardown

   [Template]  Success Update/Show Type Utilization Alert Policy Via mcctl

      # Update all values
      name=${recv_name}  alertorg=${developer}  severity=info  cpuutilization=80  memutilization=100  diskutilization=100  labels=labelname=labelvalue  annotations=title=titlename  triggertime=${tt_h}  description=description1
      # update all but measurement triggers
      name=${recv_name}  alertorg=${developer}  severity=warning  labels=labelname2=labelvalue2  annotations=title2=titlename2 triggertime=${tt_h}  description=description2
      # update two measurements cpu and mem and change trigger time
      name=${recv_name}  alertorg=${developer}  severity=error  cpuutilization=25  memutilization=25  triggertime=${tt_hm}
      # update severity to info
      name=${recv_name}  alertorg=${developer}  severity=info
      # update severity to info
      name=${recv_name}  alertorg=${developer}  severity=warning
      # update severity to info
      name=${recv_name}  alertorg=${developer}  severity=error
      # update title in annotations only
      name=${recv_name}  alertorg=${developer}  annotations=title3=titleupdate3
      # update labele in annotations only
      name=${recv_name}  alertorg=${developer}  labels=labels3=labelname3

# ECQ-3833
UpdateAlertPolicy - mcctl shall handle update success type connections Alert Policy
   [Documentation]
   ...  - send UpdateAlertPolicy type connections via mcctl with various args
   ...  - verify policy is updated

   [Setup]  Update Setup2    #second setup is needed because intial alertpolicy is of type connections cannot mix match with measurements
   [Teardown]  Update Teardown

   [Template]  Success Update/Show Type Connection Alert Policy Via mcctl

      # Update all values
      name=${recv_name}  alertorg=${developer}  severity=info   activeconnections=10  labels=labelname=labelvalue  annotations=title=titlename  triggertime=${tt_h}  description=description2
      # update all but measurement triggers
      name=${recv_name}  alertorg=${developer}  severity=warning  labels=labelname2=labelvalue2  annotations=title2=titlename2 triggertime=${tt_h}  description=description2
      # update connections and change trigger time
      name=${recv_name}  alertorg=${developer}  severity=error  activeconnections=210  triggertime=${tt_hm}
      # update severity to info
      name=${recv_name}  alertorg=${developer}  severity=info
      # update severity to info
      name=${recv_name}  alertorg=${developer}  severity=warning
      # update severity to info
      name=${recv_name}  alertorg=${developer}  severity=error
      # update title in annotations only
      name=${recv_name}  alertorg=${developer}  annotations=title3=titleupdate3
      # update labele in annotations only
      name=${recv_name}  alertorg=${developer}  labels=labels3=labelname3

# ECQ-3834
UpdateAlertPolicy - mcctl shall handle update failure type utilization Alert Policy 
   [Documentation]
   ...  - send UpdateAlertPolicy via mcctl to handle failed update error conditions
   ...  - verify policy is not updated and returns error

   [Setup]  Update Setup3    #setup is needed because intial alertpolicy cannot mix match measurements 
   [Teardown]  Update Teardown

   [Template]  Fail Update Alert Policy Type Utilization Via mcctl
      # Try to update existing AlertPolicy with non compatible  measurement activeconnections
      ${error_400_mix_trig}  ${error_custom_error}  name=${recv_name}  alertorg=${developer}  severity=warning  activeconnections=86 labels=labelname2=measurements  annotations=title=measurements triggertime=${tt_h}  description=description3
      # triggertime set too low based on mc settings
      ${error_400_60s_time}  ${error_400_no_time}  name=${recv_name}  alertorg=${developer}  severity=warning  labels=labelname3=measurement  annotations=title2=titlename  triggertime=${tt_s}  description=description2
      # udate measurement out of range
      ${error_400_cpu_range}   ${error_custom_error}  name=${recv_name}  alertorg=${developer}  severity=warning  cpuutilization=999   triggertime=${tt_hms}  description=change-cpuutilization
      ${error_400_mem_range}   ${error_custom_error}  name=${recv_name}  alertorg=${developer}  severity=warning  memutilization=1000  description=change-diskutilization
      # note if at least one valid utilization measurement exists and you try to update with 0 another measurement it will just be ignored and dropped
      ${error_400_no_trigger}  ${error_missing_args}  name=${recv_name}  alertorg=${developer}  severity=info  diskutilization=0  memutilization=0  cpuutilization=0 

# ECQ-3835
UpdateAlertPolicy - mcctl shall handle update failure type connections Alert Policy
   [Documentation]
   ...  - send UpdateAlertPolicy via mcctl to handle failed update error conditions
   ...  - verify policy is not updated and returns error

   [Setup]  Update Setup4    #setup is needed because intial alertpolicy cannot mix match measurements
   [Teardown]  Update Teardown

   [Template]  Fail Update Alert Policy Type Connection Via mcctl
      # Try to update existing AlertPolicy with non compatible  measurement type utilization cpu
      ${error_400_mix_trig}  ${error_custom_error}  name=${recv_name}  alertorg=${developer}  severity=warning  cpuutilization=50  labels=labelname=connections  annotations=title=connections triggertime=${tt_h}  description=description4
      # triggertime set too low based on mc settings 
      ${error_400_60s_time}  ${error_400_no_time}  name=${recv_name}  alertorg=${developer}  severity=warning  labels=labelname3=connections  annotations=title2=titlename2  triggertime=${tt_s}  description=description3
      # udate measurement out of range
      ${error_range_parse}   ${error_custom_error}  name=${recv_name}  alertorg=${developer}  severity=warning   activeconnections=${out_of_range}  description=change-connections-count
      # update measurement no value
      ${error_invalid_syntax}   ${error_400_no_trigger}  name=${recv_name}  alertorg=${developer}  severity=warning   activeconnections=   description=change-connections-count

*** Keywords ***
Setup
   ${recv_name}=  Get Default Alert Policy Name
   Set Suite Variable  ${recv_name}
   # Set deafulat values in case vaules not default
   Run mcctl  settings update alertpolicymintriggertime=30s region=EU
   Run mcctl  settings update alertpolicymintriggertime=30s region=US

Success Create/Show/Delete Alert Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   # ${parmss} = name=alertrpolicy163034614119946 alertorg=automation_dev_org severity=info activeconnections=1 triggertime=30s 

   Run mcctl  alertpolicy create region=${region} ${parmss}  version=${version}
   ${show}=  Run mcctl  alertpolicy show region=${region} ${parmss}  version=${version}
   # ${show} = [{'key': {'organization': 'automation_dev_org', 'name': 'alertrpolicy163034614119946'}, 'active_conn_limit': 1, 'severity': 'info', 'triggertime': '30s'}]
   Run mcctl  alertpolicy delete region=${region} ${parmss}  version=${version}
   Should Be Equal               ${show[0]['key']['name']}          ${parms['name']}
   Should Be Equal               ${show[0]['key']['organization']}  ${parms['alertorg']}
   Should Be Equal               ${show[0]['severity']})            ${parms['severity']})

   Run Keyword If  'tt_s' in ${parms}  Should Be Equal   ${show[0]['triggertime']}      ${tt_s_convert}
   Run Keyword If  'tt_h' in ${parms}  Should Be Equal   ${show[0]['triggertime']}      ${tt_s_convert}
   Run Keyword If  'tt_hm' in ${parms}  Should Be Equal   ${show[0]['triggertime']}     ${tt_s_convert}
   Run Keyword If  'tt_hms' in ${parms}  Should Be Equal   ${show[0]['triggertime']}    ${tt_s_convert}
   Run Keyword If  'tt_maxh' in ${parms}  Should Be Equal   ${show[0]['triggertime']}   ${tt_s_convert}
   Run Keyword If  'activeconnections' in ${parms}  Should Be Equal As Numbers    ${show[0]['active_conn_limit']}        ${parms['activeconnections']}
   Run Keyword If  'cpuutilization' in ${parms}  Should Be Equal As Numbers       ${show[0]['cpu_utilization_limit']}    ${parms['cpuutilization']}
   Run Keyword If  'memutilization' in ${parms}  Should Be Equal As Numbers       ${show[0]['mem_utilization_limit']}    ${parms['memutilization']}
   Run Keyword If  'diskutilization' in ${parms}  Should Be Equal As Numbers       ${show[0]['disk_utilization_limit']}    ${parms['diskutilization']}

   ${labels_split}         Run Keyword If  'labels' in ${parms}         Set Variable    ${parms['labels']}
   ${labels}               Run Keyword If  'labels' in ${parms}         Split String    ${labels_split}    =
   ${annotations_split}    Run Keyword If  'annotations' in ${parms}    Set Variable    ${parms['annotations']}
   ${annotations}          Run Keyword If  'annotations' in ${parms}    Split String    ${annotations_split}    =

   Run Keyword If  'labels' in ${parms}        Should Contain Any       ${show[0]['labels']}         ${labels[0]}        ${labels[1]}
   Run Keyword If  'annotations' in ${parms}   Should Contain Any       ${show[0]['annotations']}    ${annotations[0]}   ${annotations[1]}

Fail Create Alert Policy Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=   Run Keyword and Expect Error  *  Run mcctl  alertpolicy create region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Delete Alert Policy Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=   Run Keyword and Expect Error  *  Run mcctl  alertpolicy delete region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Success Update/Show Type Utilization Alert Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  alertpolicy update region=${region} ${parmss}    version=${version}
   ${show}=  Run mcctl  alertpolicy show region=${region} ${parmss}    version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['alertorg']}
   Run Keyword If  'activeconnections' in ${parms}  Should Be Equal As Numbers    ${show[0]['active_conn_limit']}        ${parms['activeconnections']}
   Run Keyword If  'cpuutilization' in ${parms}  Should Be Equal As Numbers       ${show[0]['cpu_utilization_limit']}    ${parms['cpuutilization']}
   Run Keyword If  'memutilization' in ${parms}  Should Be Equal As Numbers       ${show[0]['mem_utilization_limit']}    ${parms['memutilization']}
   Run Keyword If  'diskutilization' in ${parms}  Should Be Equal As Numbers      ${show[0]['disk_utilization_limit']}    ${parms['diskutilization']}

   ${labels_split}         Run Keyword If  'labels' in ${parms}         Set Variable    ${parms['labels']}  
   ${labels}               Run Keyword If  'labels' in ${parms}         Split String    ${labels_split}    =
   ${annotations_split}    Run Keyword If  'annotations' in ${parms}    Set Variable    ${parms['annotations']}
   ${annotations}          Run Keyword If  'annotations' in ${parms}    Split String    ${annotations_split}    =

   Run Keyword If  'labels' in ${parms}        Should Contain Any       ${show[0]['labels']}         ${labels[0]}        ${labels[1]}
   Run Keyword If  'annotations' in ${parms}   Should Contain Any       ${show[0]['annotations']}    ${annotations[0]}   ${annotations[1]}


Success Update/Show Type Connection Alert Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  alertpolicy update region=${region} ${parmss}    version=${version}
   ${show}=  Run mcctl  alertpolicy show region=${region} ${parmss}    version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['alertorg']}
   Run Keyword If  'activeconnections' in ${parms}  Should Be Equal As Numbers    ${show[0]['active_conn_limit']}        ${parms['activeconnections']}
   Run Keyword If  'cpuutilization' in ${parms}  Should Be Equal As Numbers       ${show[0]['cpu_utilization_limit']}    ${parms['cpuutilization']}
   Run Keyword If  'memutilization' in ${parms}  Should Be Equal As Numbers       ${show[0]['mem_utilization_limit']}    ${parms['memutilization']}
   Run Keyword If  'diskutilization' in ${parms}  Should Be Equal As Numbers      ${show[0]['disk_utilization_limit']}    ${parms['diskutilization']}

   ${labels_split}         Run Keyword If  'labels' in ${parms}         Set Variable    ${parms['labels']}
   ${labels}               Run Keyword If  'labels' in ${parms}         Split String    ${labels_split}    =
   ${annotations_split}    Run Keyword If  'annotations' in ${parms}    Set Variable    ${parms['annotations']}
   ${annotations}          Run Keyword If  'annotations' in ${parms}    Split String    ${annotations_split}    =

   Run Keyword If  'labels' in ${parms}        Should Contain Any       ${show[0]['labels']}         ${labels[0]}        ${labels[1]}
   Run Keyword If  'annotations' in ${parms}   Should Contain Any       ${show[0]['annotations']}    ${annotations[0]}   ${annotations[1]}

Fail Update Alert Policy Type Utilization Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  alertpolicy update region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Update Alert Policy Type Connection Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  alertpolicy update region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Update Setup     #Utilization for update success cpu,mem,disk measurement type
   Run mcctl  alertpolicy create region=${region} name=${recv_name} alertorg=${developer} name=${recv_name} alertorg=${developer} severity=info cpuutilization=100 memutilization=100 diskutilization=100 labels=labelvalue=labelname annotations=title=alerttitle triggertime=${tt_h} description=descriptionsetup   version=${version}

Update Setup2    #Connections for update success active-connection measurement type
   Run mcctl  alertpolicy create region=${region} name=${recv_name} alertorg=${developer} name=${recv_name} alertorg=${developer} severity=info activeconnections=10 labels=labelvalue=labelname annotations=title=alerttitle triggertime=${tt_h} description=descriptionsetup2   version=${version}

Update Setup3    #UtilizationFail for measurement cpu,mem,disk and return alertpolicymintriggertime=60s test boundry
   Run mcctl  alertpolicy create region=${region} name=${recv_name} alertorg=${developer} name=${recv_name} alertorg=${developer} severity=info cpuutilization=100 memutilization=100 diskutilization=100 labels=labelvalue=labelname annotations=title=alerttitle triggertime=${tt_h} description=descriptionesetup3   version=${version}
   Run mcctl  settings update alertpolicymintriggertime=60s region=EU
   Run mcctl  settings update alertpolicymintriggertime=60s region=US

Update Setup4    #ConnectionsFail for measurement activeconnections and return alertpolicymintriggertime=30s default setting
   Run mcctl  alertpolicy create region=${region} name=${recv_name} alertorg=${developer} name=${recv_name} alertorg=${developer} severity=info activeconnections=10 labels=labelvalue=labelname annotations=title=alerttitle triggertime=${tt_h} description=descriptionesetup4   version=${version}
   Run mcctl  settings update alertpolicymintriggertime=60s region=EU
   Run mcctl  settings update alertpolicymintriggertime=60s region=US

Update Teardown
   Run mcctl  settings update alertpolicymintriggertime=30s region=EU
   Run mcctl  settings update alertpolicymintriggertime=30s region=US
   Run mcctl  alertpolicy delete region=${region} name=${recv_name} alertorg=${developer}    version=${version}


