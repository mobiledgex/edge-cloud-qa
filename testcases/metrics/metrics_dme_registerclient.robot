*** Settings ***
Documentation  DME RegisterClient Metrics 

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
${cloudlet_name_dme}=  mexplat-qa-cloudlet
${operator_org_name_dme}=  TDG

${app_name}=  automation_api_app
${app_version}=  1.0
${developer_org_name}=  MobiledgeX

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${test_timeout}=  32 min

${region}=  US

# ECQ-2055	
*** Test Cases ***
DMEMetrics - Shall be able to get the last DME RegisterClient metric on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with last=1 
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last dme metric on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}
	
   Metrics Headings Should Be Correct  ${metrics}
	
   Values Should Be In Range  ${metrics}
   
DMEMetrics - Shall be able to get the last 5 DME RegisterClient metrics on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with last=5
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 5 dme metrics on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get the last 10 DME RegisterClient metrics on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with last=10
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 10 dme metrics on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get all DME RegisterClient metrics on openstack
   [Documentation]
   ...  request all DME RegisterClient metrics
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get all dme metrics on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to request more DME RegisterClient metrics than exist on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with last=<greater than total number of metrics>
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get more dme metrics than exist on openstack   selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get DME RegisterClient metrics with starttime on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with starttime 
   ...  verify info is correct

   ${metrics}=  Get dme metrics with starttime on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get DME RegisterClient metrics with endtime on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with endtime 
   ...  verify info is correct

   ${metrics}=  Get dme metrics with endtime on openstack   selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Headings Should Be Correct  ${metrics}  

   Values Should Be In Range  ${metrics}

DMEMetrics - Shall be able to get the DME RegisterClient metrics with starttime=lastrecord on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with starttime=lastrecord 
   ...  verify info is correct

   #edgecloud-1338 Metrics - requesting cloudlet metrics with starttime=<time> does not return the reading with that time

   ${metrics}  ${metrics_influx}=  Get dme metrics with starttime=lastrecord on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics} 

DMEMetrics - Shall be able to get the DME RegisterClient metrics with starttime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime in the future
   ...  verify empty list is returned

   Get dme metrics with starttime > lastrecord on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

DMEMetrics - Shall be able to get the DME RegisterClient metrics with endtime=lastrecord on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with endtime=lastrecord
   ...  verify info is correct

   #EDGECLOUD-1648 Metrics - requesting metrics with endtime=lastrecord does not return the last record

   ${metrics}=  Get dme metrics with endtime=lastrecord on openstack   selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - Shall be able to get the DME RegisterClient metrics with endtime = firstrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with endtime = firstrecord 
   ...  verify empty list is returned

   Get dme metrics with endtime = firstrecord on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

DMEMetrics - Shall be able to get the DME RegisterClient metrics with starttime > endtime on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime > endtime
   ...  verify empty list is returned

   Get dme metrics with starttime > endtime on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

DMEMetrics - Shall be able to get the DME RegisterClient metrics with starttime and endtime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime/endtime in the future
   ...  verify empty list is returned

   Get dme metrics with starttime and endtime > lastrecord on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

DMEMetrics - Shall be able to get the DME RegisterClient metrics with starttime and endtime on openstack
   [Documentation]
   ...  request DME RegisterClient metrics with starttime and endtime on openstack
   ...  verify info is correct

   ${metrics}=  Get dme metrics with starttime and endtime on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - Shall be able to get the DME RegisterClient metrics with starttime and endtime and last on openstack
   [Documentation]
   ...  request all DME RegisterClient metrics with starttime and endtime and last on openstack
   ...  verify info is correct

   ${metrics}=  Get dme metrics with starttime and endtime and last on openstack  selector=RegisterClient  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - DeveloperManager shall be able to get DME RegisterClient metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperManager shall be able to get dme metrics  selector=RegisterClient  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - DeveloperContributor shall be able to get DME RegisterClient metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperContributor
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperContributor shall be able to get dme metrics  selector=RegisterClient  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

DMEMetrics - DeveloperViewer shall be able to get DME RegisterClient metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperViewer
   ...  verify metrics are returned

   ${metrics}  ${metrics_influx}=  DeveloperViewer shall be able to get dme metrics  selector=RegisterClient  username=${username}  password=${password}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should be in Range  ${metrics}

*** Keywords ***
Setup
   ${developer_org_name}=  Get Default Developer Name 

   Register Client  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}

   Set Suite Variable  ${developer_org_name}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        dme-api 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  0s
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  100ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  10ms 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  25ms 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  50ms 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  5ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  cellID
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][11]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][12]}  errs 
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][13]}  foundCloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][14]}  foundOperator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][15]}  method
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][16]}  reqs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][17]}  ver

 

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
      Should Be True   ${reading[6]} >= 0
      Should Be Equal  ${reading[7]}  ${appname}
      Should Be Equal  ${reading[8]}  ${developer_org_name} 
      Should Be True   ${reading[9]} == 0
      Should Be Equal  ${reading[10]}  ${cloudlet_name_dme}
      Should Be Equal  ${reading[11]}  ${operator_org_name_dme}
      Should Be True   ${reading[12]} >= 0
      Should Be True   ${reading[13]} == ${None} 
      Should Be True   ${reading[14]} == ${None}
      Should Be Equal  ${reading[15]}  RegisterClient 
      Should Be True   ${reading[16]} > 0
      Should Be True   ${reading[17]} >= 0
   END

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
      Should Be Equal  ${metrics_influx_t[${index}]['0s']}   ${reading[1]}
      Should Be Equal  ${metrics_influx_t[${index}]['100ms']}   ${reading[2]}
      Should Be Equal  ${metrics_influx_t[${index}]['10ms']}   ${reading[3]}
      Should Be Equal  ${metrics_influx_t[${index}]['25ms']}   ${reading[4]}
      Should Be Equal  ${metrics_influx_t[${index}]['50ms']}   ${reading[5]}
      Should Be Equal  ${metrics_influx_t[${index}]['5ms']}   ${reading[6]}
      Should Be Equal  ${metrics_influx_t[${index}]['app']}   ${reading[7]}
      Should Be Equal  ${metrics_influx_t[${index}]['apporg']}   ${reading[8]}
      Should Be Equal  ${metrics_influx_t[${index}]['cellID']}   ${reading[9]}
      Should Be Equal  ${metrics_influx_t[${index}]['cloudlet']}   ${reading[10]}
      Should Be Equal  ${metrics_influx_t[${index}]['cloudletorg']}   ${reading[11]}
      Should Be Equal  ${metrics_influx_t[${index}]['errs']}   ${reading[12]}
      Should Be Equal  ${metrics_influx_t[${index}]['foundCloudlet']}   ${reading[13]}
      Should Be Equal  ${metrics_influx_t[${index}]['foundOperator']}   ${reading[14]}
      Should Be Equal  ${metrics_influx_t[${index}]['method']}   ${reading[15]}
      Should Be Equal  ${metrics_influx_t[${index}]['reqs']}   ${reading[16]}
      Should Be Equal  ${metrics_influx_t[${index}]['ver']}   ${reading[17]}

      ${index}=  Evaluate  ${index}+1
   END
