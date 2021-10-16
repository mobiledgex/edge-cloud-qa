*** Settings ***
Documentation   DME FindCloudlet Metrics

#Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
#Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
#Library  DateTime
#Library  String
#Library  Collections
Library         MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}

Resource  metrics_dme_library.robot
	      
Suite Setup       Setup
#Test Teardown    Cleanup provisioning
Test Timeout  ${test_timeout}

*** Variables ***
${operator}=  tmus 

${cloudlet_name}=  tmocloud-1
${cloudlet_name_dme}=  mexplat-qa-cloudlet
${operator_org_name_dme}=  TDG

${app_name}=  ${app_name_automation}
${app_version}=  1.0
${developer_org_name}=  ${developer_org_name_automation}

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${test_timeout}=  32 min

${region}=  US

${api_collection_timer}=  30

# ECQ-2054
*** Test Cases ***
DMEMetrics - Shall be able to get the last DME FindCloudlet metric on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with last=1 
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last dme metric on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}
	
   Metrics Headings Should Be Correct  ${metrics}
	
   Values Should Be In Range  ${metrics}
   
DMEMetrics - Shall be able to get the last 5 DME FindCloudlet metrics on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with last=5
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 5 dme metrics on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get the last 10 DME FindCloudlet metrics on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with last=10
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 10 dme metrics on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get all DME FindCloudlet metrics on openstack
   [Documentation]
   ...  request all DME FindCloudlet metrics
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get all dme metrics on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to request more DME FindCloudlet metrics than exist on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with last=<greater than total number of metrics
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get more dme metrics than exist on openstack   selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get DME FindCloudlet metrics with starttime on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with starttime 
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get dme metrics with starttime on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}  ${time_diff}

DMEMetrics - Shall be able to get DME FindCloudlet metrics with endtime on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with endtime 
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get dme metrics with endtime on openstack   selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}  

   Values Should Be In Range  ${metrics}  ${time_diff}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime=lastrecord on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with starttime=lastrecord 
   ...  verify info is correct

   #edgecloud-1338 Metrics - requesting cloudlet metrics with starttime=<time> does not return the reading with that time

   ${metrics}  ${time_diff}=  Get dme metrics with starttime=lastrecord on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}  ${time_diff}

# now returns an error when starttime is in the future
#DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime > lastrecord on openstack
#   [Documentation]
#   ...  request cloudlet metrics with starttime in the future
#   ...  verify empty list is returned
#
#   Get dme metrics with starttime > lastrecord on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with endtime=lastrecord on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with endtime=lastrecord
   ...  verify info is correct

   #EDGECLOUD-1648 Metrics - requesting metrics with endtime=lastrecord does not return the last record

   ${metrics}  ${time_diff}=  Get dme metrics with endtime=lastrecord on openstack   selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}  ${time_diff}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with endtime = firstrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with endtime = firstrecord 
   ...  verify empty list is returned

   ${metrics}  ${time_diff}=  Get dme metrics with endtime = firstrecord on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}  ${time_diff}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime > endtime on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime > endtime
   ...  verify empty list is returned

   Get dme metrics with starttime > endtime on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime and endtime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime/endtime in the future
   ...  verify empty list is returned

   Get dme metrics with starttime and endtime > lastrecord on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime and endtime on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with starttime and endtime on openstack
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get dme metrics with starttime and endtime on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}  ${time_diff}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime and endtime and last on openstack
   [Documentation]
   ...  request all DME FindCloudlet metrics with starttime and endtime and last on openstack
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get dme metrics with starttime and endtime and last on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}  ${time_diff}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with startage
   [Documentation]
   ...  request all DME FindCloudlet metrics with startage
   ...  verify info is correct

   ${metrics}=  Get dme metrics with startage  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with endage
   [Documentation]
   ...  request all DME FindCloudlet metrics with endage
   ...  verify info is correct

   ${metrics}=  Get dme metrics with endage  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with startage and endage
   [Documentation]
   ...  request all DME FindCloudlet metrics with startage and endage
   ...  verify info is correct

   ${metrics}=  Get dme metrics with startage and endage  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with numsamples
   [Documentation]
   ...  request all DME FindCloudlet metrics with numsamples
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get dme metrics with numsamples  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}  ${time_diff}  ${10}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with numsamples and starttime/endtime
   [Documentation]
   ...  request all DME FindCloudlet metrics with numsamples and startime/endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get dme metrics with numsamples and starttime/endtime  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}  ${time_diff}  ${5}

DMEMetrics - DeveloperManager shall be able to get DME FindCloudlet metrics
   [Documentation]
   ...  request the DME FindCloudlet metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperManager shall be able to get dme metrics  selector=FindCloudlet  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - DeveloperContributor shall be able to get DME FindCloudlet metrics
   [Documentation]
   ...  request the DME FindCloudlet metrics as DeveloperContributor
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperContributor shall be able to get dme metrics  selector=FindCloudlet  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - DeveloperViewer shall be able to get DME FindCloudlet metrics
   [Documentation]
   ...  request the DME FindCloudlet metrics as DeveloperViewer
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperViewer shall be able to get dme metrics  selector=FindCloudlet  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   #Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - OperatorManager shall be able to get DME FindCloudlet metrics with cloudlet-org only
   [Documentation]
   ...  request the DME FindCloudlet metrics as OperatorManager
   ...  verify metrics are returned

   @{cloudlet_list}=  Create List  tmocloud-2
   ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  cloudlet_list=${cloudlet_list}
   Create Cloudlet Pool Access Invitation  region=${region}  cloudlet_pool_name=${pool_return['data']['key']['name']}  cloudlet_pool_org_name=${operator_name_fake}  developer_org_name=${developer_org_name_automation}
   Create Cloudlet Pool Access Response    region=${region}  cloudlet_pool_name=${pool_return['data']['key']['name']}  cloudlet_pool_org_name=${operator_name_fake}  developer_org_name=${developer_org_name_automation}  decision=accept

   ${metrics}=  OperatorManager shall be able to get client api usage metrics  selector=FindCloudlet  operator_org_name=${operator_name_fake}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

*** Keywords ***
Setup
   ${developer_name}=  Get Default Developer Name 

   Update Settings  region=${region}  dme_api_metrics_collection_interval=${api_collection_timer}s
   Set Max Metrics Data Points Config  100

   Register Client  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_name}
   Find Cloudlet	carrier_name=tmus  latitude=36  longitude=-95
   Sleep  30 seconds
   Find Cloudlet	carrier_name=tmus  latitude=36  longitude=-95
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        dme-api
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  reqs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  errs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cellID
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  foundCloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  foundOperator
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  errs
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  0s
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  5ms
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  10ms
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  25ms
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  50ms
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  100ms

   Should Be True  'apporg' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'app' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'ver' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cloudletorg' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cloudlet' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'dmeId' in ${metrics['data'][0]['Series'][0]['tags']}
   #Should Be True  'cellID' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'method' in ${metrics['data'][0]['Series'][0]['tags']}
   #Should Be True  'foundCloudlet' in ${metrics['data'][0]['Series'][0]['tags']}
   #Should Be True  'foundOperator' in ${metrics['data'][0]['Series'][0]['tags']}

Values Should Be In Range
  [Arguments]  ${metrics}  ${time_diff}=${None}  ${numsamples}=${100}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${developer_org_name}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${appname}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${appversion}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   #Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['cellID']}') == 0
   #Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundCloudlet']}') == 0
   #Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundOperator']}') == 0
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  FindCloudlet

   IF  ${time_diff} != ${None}
      ${time_def}=  Evaluate  ${time_diff}/${numsamples}

      ${time_check}=  Set Variable  ${api_collection_timer}
      IF  ${time_def} > ${api_collection_timer}
         ${time_check}=  Set Variable  ${time_def}
      END

      ${datez}=  Get Substring  ${metrics['data'][0]['Series'][0]['values'][0][0]}  0  -1
      @{datesplit}=  Split String  ${datez}  .
      ${epochpre}=  Evaluate  calendar.timegm(time.strptime('${datesplit[0]}', '%Y-%m-%dT%H:%M:%S'))  modules=calendar
      ${start}=  Evaluate  ${epochpre} + ${time_check}
   END
	
   # verify values
   FOR  ${reading}  IN  @{values}
      IF  ${reading[1]} != ${None}    # dont check null readings which be removed later
         Should Be True   ${reading[1]} > 0
         Should Be True   ${reading[2]} >= 0
         Should Be Equal  ${reading[3]}  0
         Should Be True   len('${reading[4]}') > 0
         Should Be True   len('${reading[5]}') > 0
         #Should Be True   ${reading[3]} >= 0
         #Should Be True   ${reading[4]} >= 0
         #Should Be True   ${reading[5]} >= 0
         #Should Be True   ${reading[6]} >= 0
         #Should Be True   ${reading[7]} >= 0
         #Should Be True   ${reading[8]} >= 0
      END

      IF  ${time_diff} != ${None}
         ${datez}=  Get Substring  ${reading[0]}  0  -1
         @{vdatesplit}=  Split String  ${datez}  .
         ${vepochpre}=  Evaluate  calendar.timegm(time.strptime('${vdatesplit[0]}', '%Y-%m-%dT%H:%M:%S'))  modules=calendar
         #${vepochpre}=  Convert Date  ${vdatesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
         ${epoch_diff}=  Evaluate  ${start}-${vepochpre}
         #Should Be True  ${epoch_diff} <= ${time_check}+1 and ${epoch_diff} >= ${time_check}-1
         Should Be True  ${time_check}-1 <= ${epoch_diff} <= ${time_check}+1
         ${start}=  Set Variable  ${vepochpre}
      END
   END

Check Found Cloudlet
   [Arguments]  ${name}  ${operator}

   Should Be True  '${name}' == '${cloudlet_name}' or '${name}' == '${None}'
   Should Be True  '${operator}' == '${operator}' or '${operator}' == '${None}'

   #Should Be Equal  ${name}  ${cloudlet_name}
   #Should Be Equal  ${operator}  ${operator}

Check Not Found Cloudlet
   [Arguments]  ${name}  ${operator}

   Should Be True  ${name} == ${None}
   Should Be True  ${operator} == ${None} 

Metrics Should Match Influxdb
   [Arguments]  ${metrics}  ${metrics_influx}

   ${metrics_influx_t}=  Set Variable  ${metrics_influx}
   ${index}=  Set Variable  0
   FOR  ${reading}  IN  @{metrics_influx}
      @{datesplit1}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][${index}]}  .
      ${metricsepoch}=  Convert Date  ${datesplit1[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      @{datesplit2}=  Split String  ${reading['time']}  .
      ${influxepoch}=  Convert Date  ${datesplit2[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      Run Keyword If  '${metricsepoch}' < '${influxepoch}'  Remove From List  ${metrics_influx_t}  ${index}
      ...  ELSE  Exit For Loop  
   END
 
   #Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][0]}' != '${metrics_influx[0]['time']}'  Remove From List  ${metrics_influx}  0  #remove 1st item if newer than ws
   #...  ELSE  Remove From List  ${metrics_influx}  -1  #remove last item
   log to console  ${metrics_influx_t}

   ${index}=  Set Variable  0
#   : FOR  ${reading}  IN  @{metrics_influx_t}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
#   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][5]}  ${reading['cpu']}
#   \  ${index}=  Evaluate  ${index}+1
   FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}           ${reading[0]}
      Should Be Equal  ${metrics_influx_t[${index}]['apporg']}         ${reading[1]}
      Should Be Equal  ${metrics_influx_t[${index}]['app']}            ${reading[2]}
      Should Be Equal  ${metrics_influx_t[${index}]['ver']}            ${reading[3]}
      Should Be Equal  ${metrics_influx_t[${index}]['cloudletorg']}    ${reading[4]}
      Should Be Equal  ${metrics_influx_t[${index}]['cloudlet']}       ${reading[5]}
      Should Be Equal  ${metrics_influx_t[${index}]['dmeId']}          ${reading[6]}
      Should Be Equal  ${metrics_influx_t[${index}]['cellID']}         ${reading[7]}
      Should Be Equal  ${metrics_influx_t[${index}]['method']}         ${reading[8]}
      Should Be Equal  ${metrics_influx_t[${index}]['foundCloudlet']}  ${reading[9]}
      Should Be Equal  ${metrics_influx_t[${index}]['foundOperator']}  ${reading[10]}
      Should Be Equal  ${metrics_influx_t[${index}]['reqs']}           ${reading[11]}
      Should Be Equal  ${metrics_influx_t[${index}]['errs']}           ${reading[12]}
      Should Be Equal  ${metrics_influx_t[${index}]['0s']}             ${reading[13]}
      Should Be Equal  ${metrics_influx_t[${index}]['5ms']}            ${reading[14]}
      Should Be Equal  ${metrics_influx_t[${index}]['10ms']}           ${reading[15]}
      Should Be Equal  ${metrics_influx_t[${index}]['25ms']}           ${reading[16]}
      Should Be Equal  ${metrics_influx_t[${index}]['50ms']}           ${reading[17]}
      Should Be Equal  ${metrics_influx_t[${index}]['100ms']}          ${reading[18]}

      ${index}=  Evaluate  ${index}+1
   END
