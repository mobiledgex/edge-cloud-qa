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
	      
Test Setup       Setup
#Test Teardown    Cleanup provisioning
Test Timeout  ${test_timeout}

*** Variables ***
${operator}=  tmus 

${cloudlet_name}=  tmocloud-1
${cloudlet_name_dme}=  mexplat-qa-cloudlet
${operator_org_name_dme}=  TDG

${app_name}=  automation_api_app
${app_version}=  1.0
${developer_org_name}=  MobiledgeX

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  mextester06
${password}=  mextester06123

${test_timeout}=  32 min

${region}=  US

# ECQ-2054
*** Test Cases ***
DMEMetrics - Shall be able to get the last DME FindCloudlet metric on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with last=1 
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last dme metric on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}
	
   Metrics Headings Should Be Correct  ${metrics}
	
   Values Should Be In Range  ${metrics}
   
DMEMetrics - Shall be able to get the last 5 DME FindCloudlet metrics on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with last=5
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 5 dme metrics on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get the last 10 DME FindCloudlet metrics on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with last=10
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 10 dme metrics on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get all DME FindCloudlet metrics on openstack
   [Documentation]
   ...  request all DME FindCloudlet metrics
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get all dme metrics on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to request more DME FindCloudlet metrics than exist on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with last=<greater than total number of metrics
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get more dme metrics than exist on openstack   selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get DME FindCloudlet metrics with starttime on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with starttime 
   ...  verify info is correct

   ${metrics}=  Get dme metrics with starttime on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get DME FindCloudlet metrics with endtime on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with endtime 
   ...  verify info is correct

   ${metrics}=  Get dme metrics with endtime on openstack   selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}  

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime=lastrecord on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with starttime=lastrecord 
   ...  verify info is correct

   #edgecloud-1338 Metrics - requesting cloudlet metrics with starttime=<time> does not return the reading with that time

   ${metrics}  ${metrics_influx}=  Get dme metrics with starttime=lastrecord on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics} 

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime in the future
   ...  verify empty list is returned

   Get dme metrics with starttime > lastrecord on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with endtime=lastrecord on openstack
   [Documentation]
   ...  request DME FindCloudlet metrics with endtime=lastrecord
   ...  verify info is correct

   #EDGECLOUD-1648 Metrics - requesting metrics with endtime=lastrecord does not return the last record

   ${metrics}=  Get dme metrics with endtime=lastrecord on openstack   selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with endtime = firstrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with endtime = firstrecord 
   ...  verify empty list is returned

   Get dme metrics with endtime = firstrecord on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

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

   ${metrics}=  Get dme metrics with starttime and endtime on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - Shall be able to get the DME FindCloudlet metrics with starttime and endtime and last on openstack
   [Documentation]
   ...  request all DME FindCloudlet metrics with starttime and endtime and last on openstack
   ...  verify info is correct

   ${metrics}=  Get dme metrics with starttime and endtime and last on openstack  selector=FindCloudlet  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - DeveloperManager shall be able to get DME FindCloudlet metrics
   [Documentation]
   ...  request the DME FindCloudlet metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperManager shall be able to get dme metrics  selector=FindCloudlet  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - DeveloperContributor shall be able to get DME FindCloudlet metrics
   [Documentation]
   ...  request the DME FindCloudlet metrics as DeveloperContributor
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperContributor shall be able to get dme metrics  selector=FindCloudlet  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - DeveloperViewer shall be able to get DME FindCloudlet metrics
   [Documentation]
   ...  request the DME FindCloudlet metrics as DeveloperViewer
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperViewer shall be able to get dme metrics  selector=FindCloudlet  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

*** Keywords ***
Setup
   ${developer_name}=  Get Default Developer Name 

   Register Client  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_name}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        dme-api 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  100ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  10ms 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  25ms 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  50ms 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  5ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  cellID
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][11]}  dev
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][12]}  errs 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][13]}  foundCloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][14]}  foundOperator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][15]}  inf
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][16]}  method
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][17]}  oper
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][18]}  reqs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][19]}  ver

 

Values Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
	
   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} >= 0
      Should Be True   ${reading[2]} >= 0
      Should Be True   ${reading[3]} >= 0
      Should Be True   ${reading[4]} >= 0
      Should Be True   ${reading[5]} >= 0
      Should Be Equal  ${reading[6]}  ${appname}
      Should Be Equal  ${reading[7]}  ${developer_org_name} 
      Should Be True   ${reading[8]} == 0
      Should Be Equal  ${reading[9]}  ${cloudlet_name_dme}
      Should Be Equal  ${reading[10]}  ${operator_org_name_dme}
      Should Be Equal  ${reading[11]}  ${None}
      Should Be True   ${reading[12]} >= 0
      #Run Keyword If  '${reading[12]}' == '0'  Check Found Cloudlet  ${reading[13]}  ${reading[14]}
      #...  ELSE  Check Not Found Cloudlet  ${reading[13]}  ${reading[14]}
      Should Be True  '${reading[13]}' == '${cloudlet_name}' or '${reading[13]}' == '${None}' 
      Should Be True  '${reading[14]}' == '${operator}' or '${reading[14]}' == '${None}'
      Should Be True   ${reading[15]} == 0
      Should Be Equal  ${reading[16]}  FindCloudlet 
      Should Be Equal  ${reading[17]}  ${None}
      Should Be True   ${reading[18]} > 0
      Should Be True   ${reading[19]} >= 0
   END

#Check Found Cloudlet
#   [Arguments]  ${name}  ${operator}
#
#   Should Be Equal  ${name}  ${cloudlet_name}
#   Should Be Equal  ${operator}  ${operator}

#Check Not Found Cloudlet
#   [Arguments]  ${name}  ${operator}
#
#   Should Be True  ${name} == ${None}
#   Should Be True  ${operator} == ${None} 

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
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
      Should Be Equal  ${metrics_influx_t[${index}]['100ms']}   ${reading[1]}
      Should Be Equal  ${metrics_influx_t[${index}]['10ms']}   ${reading[2]}
      Should Be Equal  ${metrics_influx_t[${index}]['25ms']}   ${reading[3]}
      Should Be Equal  ${metrics_influx_t[${index}]['50ms']}   ${reading[4]}
      Should Be Equal  ${metrics_influx_t[${index}]['5ms']}   ${reading[5]}
      Should Be Equal  ${metrics_influx_t[${index}]['app']}   ${reading[6]}
      Should Be Equal  ${metrics_influx_t[${index}]['apporg']}   ${reading[7]}
      Should Be Equal  ${metrics_influx_t[${index}]['cellID']}   ${reading[8]}
      Should Be Equal  ${metrics_influx_t[${index}]['cloudlet']}   ${reading[9]}
      Should Be Equal  ${metrics_influx_t[${index}]['cloudletorg']}   ${reading[10]}
      Should Be Equal  ${metrics_influx_t[${index}]['dev']}   ${reading[11]}
      Should Be Equal  ${metrics_influx_t[${index}]['errs']}   ${reading[12]}
      Should Be Equal  ${metrics_influx_t[${index}]['foundCloudlet']}   ${reading[13]}
      Should Be Equal  ${metrics_influx_t[${index}]['foundOperator']}   ${reading[14]}
      Should Be Equal  ${metrics_influx_t[${index}]['inf']}   ${reading[15]}
      Should Be Equal  ${metrics_influx_t[${index}]['method']}   ${reading[16]}
      Should Be Equal  ${metrics_influx_t[${index}]['oper']}   ${reading[17]}
      Should Be Equal  ${metrics_influx_t[${index}]['reqs']}   ${reading[18]}
      Should Be Equal  ${metrics_influx_t[${index}]['ver']}   ${reading[19]}

      ${index}=  Evaluate  ${index}+1
   END
