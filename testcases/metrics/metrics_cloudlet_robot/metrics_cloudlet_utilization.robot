*** Settings ***
Documentation   Cloudlet Utilization Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
LIbrary  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_METRICS_ENV}
Library  DateTime
Library  String
Library  Collections
		      
Test Setup       Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationSunnydaleCloudletStage
${operator}=                       GDDT

${region}=  EU

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  mextester06
${password}=  mextester06123
${orgname}=   metricsorg

*** Test Cases ***
Metrics - Shall be able to get the last cloudlet utilization metric on openstack
   [Documentation]
   ...  request the last cloudlet utilization metric 
   ...  verify info is correct

   ${last}=  Set Variable  1
   ${lastdb}=  Evaluate  ${last} + 1
	
   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=${last}
   ${metrics_influx}=  MexInfluxDB.Get Influx Cloudlet Utilization Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=ORDER BY DESC LIMIT ${lastdb}  # last record
   log to console  ${metrics['data'][0]['Series']}
   log to console  ${metrics_influx}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}
	
   Metrics Headings Should Be Correct  ${metrics}
	
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   Metrics Should Match Openstack  ${metrics}
	
Metrics - Shall be able to get the last 5 cloudlet utilization metrics on openstack
   [Documentation]
   ...  request the last 5 cloudlet utilization metrics
   ...  verify info is correct

   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=5
   ${metrics_influx}=  MexInfluxDB.Get Influx Cloudlet Utilization Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=ORDER BY DESC LIMIT 6  # last 5
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Metrics Should Match Openstack  ${metrics}
	
Metrics - Shall be able to get the last 100 cloudlet utilization metrics on openstack
   [Documentation]
   ...  request the last 100 cloudlet utilization metrics
   ...  verify info is correct

   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=100
   ${metrics_influx}=  MexInfluxDB.Get Influx Cloudlet Utilization Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=GROUP BY * ORDER BY DESC LIMIT 100  # last 101

   log to console  ${metrics}
   log to console  ${metrics_influx}

   #@{datesplit1}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   #${metricsepoch}=  Convert Date  ${datesplit1[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #@{datesplit2}=  Split String  ${metrics_influx[0]['time']}  .
   #${influxepoch}=  Convert Date  ${datesplit2[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #Run Keyword If  '${metricsepoch}' < '${influxepoch}'  Remove From List  ${metrics_influx}  ${index}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  100

   Metrics Should Match Openstack  ${metrics}

Metrics - Shall be able to get all cloudlet utilization metrics on openstack
   [Documentation]
   ...  request all cloudlet utilization metrics
   ...  verify info is correct

    EDGECLOUD-1836 Metrics - cloudlet metrics for maxTotalVolumeGigabytes and totalGigabytesUsed are wrong
    EDGECLOUD-1339 Metrics - shepherd should be able to handle erroneous data	
    EDGECLOUD-1337 Metrics - cloudlet metrics return old data from previous versions of the cloudlet

   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Log To Console  ${num_readings}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}

   Metrics Should Match Openstack  ${metrics}

Metrics - Shall be able to request more utilization metrics than exist on openstack
   [Documentation]
   ...  request more cloudlet utilization metrics than exist by using last=<greater than total metrics>
   ...  verify info is correct

    EDGECLOUD-1836 Metrics - cloudlet metrics for maxTotalVolumeGigabytes and totalGigabytesUsed are wrong
    EDGECLOUD-1339 Metrics - shepherd should be able to handle erroneous data
    EDGECLOUD-1337 Metrics - cloudlet metrics return old data from previous versions of the cloudlet

   ${metricsall}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization
   ${num_readings_all}=  Get Length  ${metricsall['data'][0]['Series'][0]['values']}

   ${more_readings}=  Evaluate  ${num_readings_all} + 100
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=${more_readings}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['partial']}  ${True}
	
   ${num_readings_all}=  Get Length  ${metricsall['data'][0]['Series'][0]['values']}
   ${num_readings}=      Get Length  ${metrics['data'][0]['Series'][0]['values']}

   ${num_readings_possible}=  Evaluate  ${num_readings_all} + 5   # could have read 5 more since it might take a while to read a lot of readings
   Should Be True  ${num_readings} >= ${num_readings_all} and ${num_readings} <= ${num_readings_possible}

   Metrics Should Match Openstack  ${metrics}
	
Metrics - Shall be able to get the cloudlet utilization metrics with starttime on openstack
   [Documentation]
   ...  request cloudlet utilization metrics with starttime on openstack
   ...  verify info is correct

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 3600
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   log to console  ${start_date}

   # get readings with starttime 
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  start_time=${start_date}
   log to console  ${metrics['data'][0]}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   #Should Be True  (${epoch_last} - ${epoch_first}) > 3500  # difference between 1st and last time should be about 1hr
   Should Be True  (${epoch_first} - ${epoch_last}) > 3500  # difference between 1st and last time should be about 1hr
   #Should Be True  ${epoch_last} >= ${epochpre} 
   Should Be True  ${epoch_first} >= ${epochpre}
	
   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}
	
   Metrics Should Match Openstack  ${metrics}  #reverse=${True}

Metrics - Shall be able to get the cloudlet utilization metrics with endtime on openstack
   [Documentation]
   ...  request cloudlet utilization metrics with endtime on openstack
   ...  verify info is correct

    EDGECLOUD-1836 Metrics - cloudlet metrics for maxTotalVolumeGigabytes and totalGigabytesUsed are wrong
    EDGECLOUD-1339 Metrics - shepherd should be able to handle erroneous data
    EDGECLOUD-1337 Metrics - cloudlet metrics return old data from previous versions of the cloudlet

   # get last metric and set endtime = 1 hour earlier
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${end}=  Evaluate  ${epochpre} - 3600
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ
   log to console  ${end_date}
	
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  end_time=${end_date}
   log to console  ${metrics['data'][0]}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal As Integers  ${num_readings}  5

   Metrics Should Match Openstack  ${metrics}  reverse=${True}

Metrics - Shall be able to get the cloudlet utilization metrics with starttime=lastrecord on openstack
   [Documentation]
   ...  request cloudlet utilization metrics with starttime=lastrecord on openstack
   ...  verify info is correct

   ${metrics_influx}=  MexInfluxDB.Get Influx Cloudlet Utilization Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=GROUP BY * ORDER BY DESC LIMIT 2  # last record
	
   # get last metric
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   log to console  ${metricspre['data'][0]['Series'][0]['values'][0][0]}

   # get readings and 1st and last timestamp
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  start_time=${metricspre['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}
	
   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   log to console  ${num_readings}
	
   Metrics Should Match Openstack  ${metrics} 

Metrics - Shall be able to get the cloudlet utilization metrics with starttime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime in the future
   ...  verify empty list is returned

   # get last metric
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 60
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  start_time=${start_date}

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Metrics - Shall be able to get the cloudlet utilization metrics with endtime=lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with endtime=lastrecord 
   ...  verify only last record is received

   # get last metric
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   log to console  ${metricspre['data'][0]['Series'][0]['values'][0][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #log to console  ${epochpre}
   #${start}=  Evaluate  ${epochpre} - 3600
   #${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   #log to console  ${start_date}

   # get readings and 1st and last timestamp
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  end_time=${metricspre['data'][0]['Series'][0]['values'][0][0]}  last=5
   log to console  ${metrics}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   Should Be True  (${epoch_first} - ${epoch_last}) < 100 
   Should Be True  ${epoch_first} >= ${epochpre} 
	
   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be Equal As Integers  ${num_readings}  5
	
   Metrics Should Match Openstack  ${metrics}

Metrics - Shall be able to get the cloudlet utilization metrics with endtime = firstrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with endtime = firstrecord
   ...  verify empty list is returned

   # get last metric
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 60
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  start_time=${start_date}

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Metrics - Shall be able to get the cloudlet utilization metrics with starttime > endtime on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime > endtime
   ...  verify empty list is returned

   ${start_date}=  Set Variable  2019-09-02T01:01:01Z	
   ${end_date}=  Set Variable  2019-09-01T01:01:01Z

   # get readings and with starttime in the future
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  start_time=${start_date}  end_time=${end_date}

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Metrics - Shall be able to get the cloudlet utilization metrics with starttime and endtime > lastrecord on openstack
   [Documentation]
   ...  request cloudlet metrics with starttime and endtime > lastrecord 
   ...  verify empty list is returned

   # get last metric
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 60
   ${end}=  Evaluate  ${epochpre} + 120
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  start_time=${start_date}  end_time=${end_date}

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Metrics - Shall be able to get the cloudlet utilization metrics with starttime and endtime on openstack
   [Documentation]
   ...  request cloudlet utilization metrics with starttime and endtime on openstack
   ...  verify info is correct

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 3600
   ${end}=    Evaluate  ${epochpre} - 1800
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  start_time=${start_date}  end_time=${end_date}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   Should Be True  (${epoch_first} - ${epoch_last}) < 1800  # difference should be about 30min 
   Should Be True  ${epoch_first} < ${epochpre}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Metrics Should Match Openstack  ${metrics}

Metrics - Shall be able to get the cloudlet utilization metrics with starttime and endtime and last on openstack
   [Documentation]
   ...  request all cloudlet utilization metrics with starttime and endtime and last on openstack
   ...  verify info is correct

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 3600
   ${end}=    Evaluate  ${epochpre} - 1800
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  start_time=${start_date}  end_time=${end_date}  last=5
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   Should Be True  (${epoch_last} - ${epoch_first}) < 30  # difference should be about 30s
   Should Be True  ${epoch_last} < ${epochpre}
   Should Be True  (${end} - ${epoch_first}) - 60  #should be within 1 min of last requested

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Metrics Should Match Openstack  ${metrics}  #reverse=${True}

Metrics - OperatorManager shall be able to get cloudlet utilization metrics
   [Documentation]
   ...  request the cloudlet utilization metrics as OperatorManager
   ...  verify metrics are returned

   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   #Verify Email  email_address=${emailepoch}

   #Create Org  orgname=${orgname}  orgtype=operator

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   Adduser Role   orgname=${operator}   username=${epochusername}  role=OperatorManager   token=${adminToken}  #use_defaults=${False}

   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=5  token=${userToken}
   ${metrics_influx}=  MexInfluxDB.Get Influx Cloudlet Utilization Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=GROUP BY * ORDER BY DESC LIMIT 6  # last 5
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Metrics Should Match Openstack  ${metrics}

Metrics - OperatorViewer shall be able to get cloudlet utilization metrics
   [Documentation]
   ...  request the cloudlet utilization metrics as OperatorViewer
   ...  verify metrics are returned

   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   #Verify Email  email_address=${emailepoch}

   #Create Org  orgname=${orgname}  orgtype=operator

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   Adduser Role   orgname=${operator}   username=${epochusername}  role=OperatorViewer   token=${adminToken}  #use_defaults=${False}

   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=5  token=${userToken}
   ${metrics_influx}=  MexInfluxDB.Get Influx Cloudlet Utilization Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=GROUP BY * ORDER BY DESC LIMIT 6  # last 5
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Metrics Should Match Openstack  ${metrics}

Metrics - OperatorContributor shall be able to get cloudlet utilization metrics
   [Documentation]
   ...  request the cloudlet utilization metrics as OperatorContributor
   ...  verify metrics are returned

   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   #Verify Email  email_address=${emailepoch}

   #Create Org  orgname=${orgname}  orgtype=operator

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   Adduser Role   orgname=${operator}   username=${epochusername}  role=OperatorContributor   token=${adminToken}  #use_defaults=${False}

   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  last=5  token=${userToken}
   ${metrics_influx}=  MexInfluxDB.Get Influx Cloudlet Utilization Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=GROUP BY * ORDER BY DESC LIMIT 6  # last 5
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Metrics Should Match Openstack  ${metrics}

Metrics - Shall be able to get the cloudlet utilization metrics without cloudlet name on openstack
   [Documentation]
   ...  request the utilization metric without cloudlet name
   ...  verify info is correct

   ${last}=  Set Variable  10
   ${lastdb}=  Evaluate  ${last} + 1

   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  operator_org_name=${operator}  selector=utilization  last=${last}
   ${metrics_influx}=  MexInfluxDB.Get Influx Cloudlet Utilization Metrics  operator_org_name=${operator}  condition=ORDER BY DESC LIMIT ${lastdb}  # last record
   log to console  ${metrics['data'][0]['Series']}
   log to console  ${metrics_influx}

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  10

   Metrics Should Match Openstack With Different Cloudlet Names  ${metrics}

*** Keywords ***
Setup
   ${limits}=  Get limits
   Set Suite Variable  ${limits}

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  vCpuUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  vCpuMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  memUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  memMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  diskUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  diskMax

Metrics Should Match Openstack
   [Arguments]  ${metrics}  ${reverse}=${False}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   Run Keyword If  ${reverse}  Reverse List  ${values}
	
   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   log to console  @{datesplit}
   ${epochlast}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   # verify values
   #: FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
   : FOR  ${reading}  IN  @{values}
   \  @{datesplit}=  Split String  ${reading[0]}  .
   \  log to console  ${reading[0]}
   \  ${epoch}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #\  ${epoch2}=  Evaluate  ${epoch} + 5
   \  Should Be True               ${epoch} <= ${epochlast}
   \  Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   \  Should Be Equal              ${reading[1]}  ${cloudlet_name_openstack_metrics}                        #cloudlet name
   \  Should Be Equal              ${reading[2]}  ${operator}                                            # operator name
   \  Should Be Equal As Integers  ${reading[8]}  ${limits['maxTotalVolumeGigabytes']}                                                   # disk size
   \  Should Be Equal As Integers  ${reading[7]}  ${limits['totalGigabytesUsed']}                                                  # disk used
   \  Should Be Equal As Integers  ${reading[6]}  ${limits['maxTotalRAMSize']}                                                  # ram size
   \  Should Be True               ${reading[5]}  ${limits['totalRAMUsed']}                                                 # ram used
   \  Should Be Equal As Integers  ${reading[4]}  ${limits['maxTotalCores']}                                                     # number of cpus
   \  Should Be True               ${reading[3]} < ${limits['maxTotalCores']}                                                    # cpus used
   \  ${epochlast}=  Set Variable  ${epoch}

Metrics Should Match Openstack With Different Cloudlet Names
   [Arguments]  ${metrics}  ${reverse}=${False}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   Run Keyword If  ${reverse}  Reverse List  ${values}

   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   log to console  @{datesplit}
   ${epochlast}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   ${found_own_cloudlet}=  Set Variable  ${False}
   ${found_other_cloudlet}=  Set Variable  ${False}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  @{datesplit}=  Split String  ${reading[0]}  .
   \  log to console  ${reading[0]}
   \  ${epoch}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   \  Should Be True               ${epoch} <= ${epochlast}
   \  Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   \  ${found_own_cloudlet}=  Run Keyword If  '${reading[1]}' == '${cloudlet_name_openstack_metrics}'   Set Variable  ${True}
   \  ...                                 ELSE  Set Variable  ${found_own_cloudlet}
   \  ${found_other_cloudlet}=  Run Keyword If  '${reading[1]}' != '${cloudlet_name_openstack_metrics}'   Set Variable  ${True} 
   \  ...                                 ELSE  Set Variable  ${found_other_cloudlet}
   #\  Should Be Equal              ${reading[1]}  ${cloudlet_name_openstack_metrics}                        #cloudlet name
   \  Should Be Equal              ${reading[2]}  ${operator}                                            # operator name
   #\  Should Be Equal As Integers  ${reading[8]}  ${limits['maxTotalVolumeGigabytes']}                                                   # disk size
   #\  Should Be Equal As Integers  ${reading[7]}  ${limits['totalGigabytesUsed']}                                                  # disk used
   #\  Should Be Equal As Integers  ${reading[6]}  ${limits['maxTotalRAMSize']}                                                  # ram size
   #\  Should Be True               ${reading[5]}  ${limits['totalRAMUsed']}                                                 # ram used
   #\  Should Be Equal As Integers  ${reading[4]}  ${limits['maxTotalCores']}                                                     # number of cpus
   #\  Should Be True               ${reading[3]} < ${limits['maxTotalCores']}                                                    # cpus used
   \  ${epochlast}=  Set Variable  ${epoch}

   Should Be True  ${found_own_cloudlet}
   Should Be True  ${found_other_cloudlet}

Metrics Should Match Influxdb
   [Arguments]  ${metrics}  ${metrics_influx}

   Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][0]}' != '${metrics_influx[0]['time']}'  Remove From List  ${metrics_influx}  0  #remove 1st item if newer than ws
   ...  ELSE  Remove From List  ${metrics_influx}  -1  #remove last item
   log to console  ${metrics_influx}

   ${index}=  Set Variable  0
   : FOR  ${reading}  IN  @{metrics_influx}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][8]}  ${reading['diskMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][7]}  ${reading['diskUsed']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][6]}  ${reading['memMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][5]}  ${reading['memUsed']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][4]}  ${reading['vCpuMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][3]}  ${reading['vCpuUsed']}
   \  ${index}=  Evaluate  ${index}+1

   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][0]}  ${metrics_influx[0]['time']}
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][2]}  ${metrics_influx[0]['diskMax']}
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][3]}  ${metrics_influx[0]['diskUsed']}
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][4]}  ${metrics_influx[0]['memMax']}
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][5]}  ${metrics_influx[0]['memUsed']}
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][7]}  ${metrics_influx[0]['vCpuMax']}
   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][8]}  ${metrics_influx[0]['vCpuUsed']}
