*** Settings ***
Documentation   Cluster Metrics Library

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
#LIbrary  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  DateTime
Library  String
Library  Collections
		      
*** Variables ***
#${cloudlet_name_openstack_metrics}=   automationBuckhornCloudlet
#${operator}=                       GDDT
#${clustername_k8s_shared}=  cluster1573768282-436812 
#${developer_name}=   developer1573768282-436812

#${username_admin}=  mexadmin
#${password_admin}=  mexadmin123

#${username}=  mextester06
#${password}=  mextester06123
#${orgname}=   metricsorg

${region}=  EU
	
*** Keywords ***
Get the last dme metric on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC LIMIT 2  # last record

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}  ${metrics_influx}

Get the last client app usage metric
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

Get the last client cloudlet usage metric
   [Arguments]  ${cloudlet_name}  ${operator_org_name}  ${selector}

   ${metrics}=  Get Client Cloudlet Usage Metrics  region=${region}  selector=${selector}  operator_org_name=${operator_org_name}  cloudlet_name=${cloudlet_name}  last=1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

Get client app usage metrics with locationtile
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}  ${location_tile}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  location_tile=${location_tile}  last=1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

Get client app usage metrics with rawdata
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  raw_data=${True}  last=1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

Get client app usage metrics with deviceinfo
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}  ${device_os}=${None}  ${device_model}=${None}  ${data_network_type}=${None}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  device_os=${device_os}  device_model=${device_model}  data_network_type=${data_network_type}  last=1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}
	
Get the last 5 dme metrics on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=5
   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC LIMIT 6  # last record

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  ${metrics_influx}

Get the last 5 dme metrics on openstack for multiple selectors
   [Arguments]  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   #${contains}=  Evaluate   "," in """${selector}""" or "*" in """${selector}"""

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=5

   #${metrics_influx}=  Run Keyword  Get Influx Cluster ${selector} Metrics  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=GROUP BY * ORDER BY DESC LIMIT 6  # last 5
   log to console  ${metrics}
   log to console  ${metrics['data'][0]['Series']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  #${metrics_influx}
	
Get the last 10 dme metrics on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=10
   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC LIMIT 11  # last record

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  10

   [Return]  ${metrics}  ${metrics_influx}

Get all dme metrics on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version} 
   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC 

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}  ${metrics_influx}

Get all client app usage metrics
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}

Get more dme metrics than exist on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${metricsall}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}
   ${num_readings_all}=  Get Length  ${metricsall['data'][0]['Series'][0]['values']}

   ${more_readings}=  Evaluate  ${num_readings_all} + 100
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=${more_readings}
   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}

   ${num_readings_possible}=  Evaluate  ${num_readings_all} + 5   # could have read 5 more since it might take a while to read a lot of readings
   ${num_readings_possible2}=  Evaluate  ${num_readings} + 5   # could have read 5 more since it might take a while to read a lot of readings

   Run Keyword If   ${num_readings_all} < 2000  Should Be True  ${num_readings} >= ${num_readings_all} and ${num_readings} <= ${num_readings_possible}
   ...  ELSE  Should Be True  ${num_readings} >= ${num_readings_all} and ${num_readings} <= ${num_readings_possible2}

   [Return]  ${metrics}  ${metrics_influx}

Get dme metrics with starttime on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   # get last metric and set starttime = 2 mins earlier
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} - 600
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and 1st and last timestamp
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}
   Should Be True  len(${metrics['data'][0]['Series'][0]['values']}) > 1
   #@{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   #@{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   #${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   #Should Be True  (${epoch_first} - ${epoch_last}) > 5  # difference between 1st and last time should be about 2min
   #Should Be True  (${epoch_first} - ${epoch_last}) < 240  # difference between 1st and last time should be about 4min 
   #Should Be True  ${epoch_first} >= ${epochpre} 
	
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}

Get client app usage metrics with starttime
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   # get last metric and set starttime = 2 mins earlier
   ${metricspre}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   log to console  ${metricspre['data'][0]}
   ${datez}=  Get Substring  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  0  -1
   @{datesplit}=  Split String  ${datez}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} - 600
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and 1st and last timestamp
   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}
   #Should Be True  len(${metrics['data'][0]['Series'][0]['values']}) > 1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}

Get dme metrics with endtime on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   # get all metric and set endtime = 2 mins from 1st metric
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${end}=  Evaluate  ${epochpre} + 90
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  end_time=${end_date} 
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   # get 1st reading from influx
   #${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  cluster_instance_name=${clustername_k8s_shared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=${developer_name}  condition=GROUP BY * ORDER BY ASC LIMIT ${num_readings} 
   
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   Should Be True  ${num_readings} > 10 
   Should Be True  ${epoch_first} <= ${end}

   [Return]  ${metrics}

Get client app usage metrics with endtime
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   # get last metric and set starttime = 2 mins earlier
   ${metricspre}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   log to console  ${metricspre['data'][0]}
   ${datez}=  Get Substring  ${metricspre['data'][0]['Series'][0]['values'][-1][0]}  0  -1
   @{datesplit}=  Split String  ${datez}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${end}=  Evaluate  ${epochpre} + 180
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and 1st and last timestamp
   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  end_time=${end_date}
   #Should Be True  len(${metrics['data'][0]['Series'][0]['values']}) > 1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}

Get dme metrics with starttime=lastrecord on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}
   # get last metric
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1

   # get readings and 1st and last timestamp
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${metricspre['data'][0]['Series'][0]['values'][0][0]} 
   #log to console  ${metrics}

   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC LIMIT 2

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be True  ${num_readings}==1 or ${num_readings}==2
   Run Keyword If  ${num_readings}==1  Should Be True  '${metrics['data'][0]['Series'][0]['values'][0][0]}'=='${metricspre['data'][0]['Series'][0]['values'][0][0]}'
   ...  ELSE  Should Be True  '${metrics['data'][0]['Series'][0]['values'][1][0]}'=='${metricspre['data'][0]['Series'][0]['values'][0][0]}'

   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][0]}  ${metricspre['data'][0]['Series'][0]['values'][0][0]}

   [Return]  ${metrics}  ${metrics_influx}

Get dme metrics with starttime > lastrecord on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}
	
   # get last metric
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 90
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date} 

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Get dme metrics with endtime=lastrecord on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   #EDGECLOUD-1648 Metrics - requesting metrics with endtime=lastrecord does not return the last record
	
   # get last metric
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   log to console  ${metricspre['data'][0]['Series'][0]['values'][0][0]}

   # get all metrics
   ${metrics_all}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}

   # get readings and 1st and last timestamp
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  end_time=${metrics_all['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings_all}=  Get Length  ${metrics_all['data'][0]['Series'][0]['values']}
   ${num_readings}=      Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings}==${num_readings_all} or ${num_readings}==${num_readings_all}+1
 
   Should Be Equal  ${metrics_all['data'][0]['Series'][0]['values'][0][0]}  ${metrics['data'][0]['Series'][0]['values'][0][0]}   #last metric should show

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   [Return]  ${metrics}
	
Get dme metrics with endtime = firstrecord on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   # get last metric
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 60
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date} 

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Get dme metrics with starttime > endtime on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   ${start_date}=  Set Variable  2019-09-02T01:01:01Z	
   ${end_date}=  Set Variable  2019-09-01T01:01:01Z

   # get readings and with starttime in the future
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}  end_time=${end_date} 

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Get dme metrics with starttime and endtime > lastrecord on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   # get last metric
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 60
   ${end}=  Evaluate  ${epochpre} + 120
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}  end_time=${end_date} 

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Get dme metrics with starttime and endtime on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=5
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 900 
   ${end}=    Evaluate  ${epochpre} - 30
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}  end_time=${end_date} 
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   Should Be True  (${epoch_first} - ${epoch_last}) < 1000  # difference should be about 30min 
   Should Be True  ${epoch_first} < ${epochpre}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be True  ${num_readings} < 100 

   [Return]  ${metrics}

Get client app usage metrics with starttime and endtime
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   # get last metric and set starttime = 2 mins earlier
   ${metricspre}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   log to console  ${metricspre['data'][0]}
   ${datez}=  Get Substring  ${metricspre['data'][0]['Series'][0]['values'][-1][0]}  0  -1
   @{datesplit}=  Split String  ${datez}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} - 900
   ${end}=  Evaluate  ${epochpre} + 120
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and 1st and last timestamp
   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}  end_time=${end_date}
   #Should Be True  len(${metrics['data'][0]['Series'][0]['values']}) > 1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}
	
Get dme metrics with starttime and endtime and last on openstack
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 900
   ${end}=    Evaluate  ${epochpre} - 30 
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}  end_time=${end_date}  last=1
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   Should Be True  (${epoch_last} - ${epoch_first}) < 30  # difference should be about 30s
   Should Be True  ${epoch_last} < ${epochpre}
   Should Be True  (${end} - ${epoch_first}) <= 620  #should be within 10 min of last requested

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   [Return]  ${metrics}

Get client app usage metrics with starttime and endtime and last
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   # get last metric and set starttime = 2 mins earlier
   ${metricspre}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1
   log to console  ${metricspre['data'][0]}
   ${datez}=  Get Substring  ${metricspre['data'][0]['Series'][0]['values'][-1][0]}  0  -1
   @{datesplit}=  Split String  ${datez}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} - 900
   ${end}=  Evaluate  ${epochpre} + 120
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and 1st and last timestamp
   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}  end_time=${end_date}  last=1
   #Should Be True  len(${metrics['data'][0]['Series'][0]['values']}) > 1

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}

DeveloperManager shall be able to get dme metrics
   [Arguments]  ${username}  ${password}  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   ##${epoch}=  Get Time  epoch
   #${epoch}=  Evaluate  str(time.time()).replace('.', '')  modules=time
   #${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   #${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   #Skip Verify Email
   #Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   #Unlock User
   ##Verify Email  email_address=${emailepoch}

   Run Keyword and Ignore Error  Create Org  orgname=${developer}  orgtype=developer

   ${userToken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   #Adduser Role   orgname=${developer_org_name}   username=${dev_manager_user_automation}  role=DeveloperManager   token=${adminToken}  #use_defaults=${False}

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=5  token=${userToken} 
   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC LIMIT 6 
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  ${metrics_influx}

DeveloperManager shall be able to get client app usage metrics
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${userToken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1  token=${userToken}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

DeveloperContributor shall be able to get client app usage metrics
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${userToken}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1  token=${userToken}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

DeveloperViewer shall be able to get client app usage metrics
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${selector}

   ${userToken}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=1  token=${userToken}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

OperatorManager shall be able to get client app usage metrics
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${operator_org_name}  ${selector}

   ${userToken}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  operator_org_name=${operator_org_name}  last=1  token=${userToken}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

OperatorContributor shall be able to get client app usage metrics
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${operator_org_name}  ${selector}

   ${userToken}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  operator_org_name=${operator_org_name}  last=1  token=${userToken}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

OperatorViewer shall be able to get client app usage metrics
   [Arguments]  ${app_name}  ${app_version}  ${developer_org_name}  ${operator_org_name}  ${selector}

   ${userToken}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

   ${metrics}=  Get Client App Usage Metrics  region=${region}  selector=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  operator_org_name=${operator_org_name}  last=1  token=${userToken}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}

DeveloperContributor shall be able to get dme metrics
   [Arguments]  ${username}  ${password}  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   ##${epoch}=  Get Time  epoch
   #${epoch}=  Evaluate  str(time.time()).replace('.', '')  modules=time

   #${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   #${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   #Skip Verify Email
   #Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   #Unlock User
   ##Verify Email  email_address=${emailepoch}

   Run Keyword and Ignore Error  Create Org  orgname=${developer}  orgtype=developer

   #${userToken}=  Login  username=${epochusername}  password=${password}
   ${userToken}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   #Adduser Role   orgname=${developer_org_name}   username=${dev_contributor_user_automation}  role=DeveloperContributor   token=${adminToken}  #use_defaults=${False}

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=5  token=${userToken}
   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC LIMIT 6
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  ${metrics_influx}

DeveloperViewer shall be able to get dme metrics
   [Arguments]  ${username}  ${password}  ${app_name}  ${app_version}  ${developer_org_name}  ${selector} 

   ##${epoch}=  Get Time  epoch
   #${epoch}=  Evaluate  str(time.time()).replace('.', '')  modules=time

   #${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   #${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   
   #Skip Verify Email
   #Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   #Unlock User
   ##Verify Email  email_address=${emailepoch}

   Run Keyword and Ignore Error  Create Org  orgname=${developer}  orgtype=developer

   #${userToken}=  Login  username=${epochusername}  password=${password}
   ${userToken}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   #Adduser Role   orgname=${developer_org_name}   username=${epochusername}  role=DeveloperViewer   token=${adminToken}  #use_defaults=${False}

   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=5  token=${userToken}
   ${metrics_influx}=  Run Keyword  Get Influx ${selector} Metrics  app_name=${app_name}  developer_org_name=${developer_org_name}  app_version=${app_version}  condition=ORDER BY DESC LIMIT 6
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  ${metrics_influx}

Get cluster metrics with cloudlet/operator/developer only 
   [Arguments]  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=5  token=${userToken}

   ${metricspre}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  last=20
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 3600
   ${end}=    Evaluate  ${epochpre} - 30
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get DME Metrics  region=${region}  method=${selector}  developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  start_time=${start_date}  end_time=${end_date}  last=20
   #@{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   #@{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   #${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   #log to console  ${epochpre}
   #log to console  ${epoch_first}
   #log to console  ${epoch_last}
   #Should Be True  (${epoch_last} - ${epoch_first}) < 30  # difference should be about 30s
   #Should Be True  ${epoch_last} < ${epochpre}
   #Should Be True  (${end} - ${epoch_first}) - 60  #should be within 1 min of last requested

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be Equal As Integers  ${num_readings}  20
	
   [Return]  ${metrics}

Get cluster metrics with cloudlet/developer only
   [Arguments]  ${cloudlet}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get Cluster Metrics  region=${region}  cloudlet_name=${cloudlet}  developer_org_name=${developer}  selector=${selector}  last=20
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 3600
   ${end}=    Evaluate  ${epochpre} - 30
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get Cluster Metrics  region=${region}  cloudlet_name=${cloudlet}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}  last=20
   #@{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   #@{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   #${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   #log to console  ${epochpre}
   #log to console  ${epoch_first}
   #log to console  ${epoch_last}
   #Should Be True  (${epoch_last} - ${epoch_first}) < 30  # difference should be about 30s
   #Should Be True  ${epoch_last} < ${epochpre}
   #Should Be True  (${end} - ${epoch_first}) - 60  #should be within 1 min of last requested

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be Equal As Integers  ${num_readings}  20

   [Return]  ${metrics}

Get cluster metrics with operator/developer only
   [Arguments]  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get Cluster Metrics  region=${region}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=20
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 3600
   ${end}=    Evaluate  ${epochpre} - 30
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get Cluster Metrics  region=${region}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}  last=20
   #@{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   #@{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  .
   #${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   #log to console  ${epochpre}
   #log to console  ${epoch_first}
   #log to console  ${epoch_last}
   #Should Be True  (${epoch_last} - ${epoch_first}) < 30  # difference should be about 30s
   #Should Be True  ${epoch_last} < ${epochpre}
   #Should Be True  (${end} - ${epoch_first}) - 60  #should be within 1 min of last requested

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be Equal As Integers  ${num_readings}  20

   [Return]  ${metrics}
