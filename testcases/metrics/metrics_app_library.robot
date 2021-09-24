*** Settings ***
Documentation   App Metrics Library

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
Library  DateTime
Library  String
Library  Collections
		      
*** Variables ***
#${cloudlet_name_openstack_metrics}=   automationBonnCloudlet
#${operator}=                       TDG
#${clustername_k8s_shared}=  cluster1573768282-436812 
#${developer_name}=   developer1573768282-436812

${username_admin}=  ${admin_manager_username}
${password_admin}=  ${admin_manager_password}

#${username}=  mextester06
#${password}=  mextester06123
#${orgname}=   metricsorg

${region}=  US
	
*** Keywords ***
Get the last app metric on openstack
   [Arguments]  ${app}=${None}  ${dbapp}=${None}  ${cluster}=${None}  ${cloudlet}=${None}  ${operator}=${None}  ${developer}=${None}  ${selector}=${None}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=GROUP BY cluster ORDER BY DESC LIMIT 4  # last record
   log to console  ${metrics['data'][0]['Series']}
   log to console  ${metrics_influx}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}  ${metrics_influx}
	
Get the last 5 app metrics on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=5
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC LIMIT 7  # last 5
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  ${metrics_influx}

Get the last app metric on openstack with version
   [Arguments]  ${app}  ${version}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  app_version=${version}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1

   ${version_influx}=  Remove String  ${version}  .
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  app_version=${version_influx}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=GROUP BY cluster ORDER BY DESC LIMIT 4  # last record
   log to console  ${metrics['data'][0]['Series']}
   log to console  ${metrics_influx}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}  ${metrics_influx}

Get the last 5 app metrics on openstack with version
   [Arguments]  ${app}  ${version}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  app_version=${version}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=5
	
   ${version_influx}=  Remove String  ${version}  .	
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  app_version=${version_influx}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC LIMIT 6  # last 5
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   #Should Be Equal As Integers  ${num_readings}  5
   Should Be True  ${num_readings} <= 5

   [Return]  ${metrics}  ${metrics_influx}

Get the last 5 app metrics on openstack for multiple selectors
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   #${contains}=  Evaluate   "," in """${selector}""" or "*" in """${selector}"""

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=5
   #${metrics_influx}=  Run Keyword  Get Influx Cluster ${selector} Metrics  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC LIMIT 7  # last 5
   log to console  ${metrics}
   log to console  ${metrics['data'][0]['Series']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  #${metrics_influx}

Get the last app metrics on openstack for multiple selectors
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   #${contains}=  Evaluate   "," in """${selector}""" or "*" in """${selector}"""

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   #${metrics_influx}=  Run Keyword  Get Influx Cluster ${selector} Metrics  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC LIMIT 4  # last 5
   log to console  ${metrics}
   log to console  ${metrics['data'][0]['Series']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   [Return]  ${metrics}  #${metrics_influx}
	
Get the last 10 app metrics on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=10
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC LIMIT 12  # last 5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  10

   [Return]  ${metrics}  ${metrics_influx}

Get all app metrics on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${app}=  Convert To Lowercase  ${app}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC  # last 5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   [Return]  ${metrics}  ${metrics_influx}

Get more app metrics than exist on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${metricsall}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}
   ${num_readings_all}=  Get Length  ${metricsall['data'][0]['Series'][0]['values']}

#   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC  #LIMIT 101  # last 5

   ${more_readings}=  Evaluate  ${num_readings_all} + 100
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=${more_readings}

   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC  #LIMIT 101  # last 5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}

   ${num_readings_possible}=  Evaluate  ${num_readings_all} + 5   # could have read 5 more since it might take a while to read a lot of readings
   Should Be True  ${num_readings} >= ${num_readings_all} and ${num_readings} <= ${num_readings_possible}

   [Return]  ${metrics}  ${metrics_influx}

Get app metrics with starttime on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 2 mins earlier
   ${metricspre}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} - 120
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and 1st and last timestamp
   ${metrics}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit_first}=  Split String  ${datesplit_first[0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit_last}=  Split String  ${datesplit_last[0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   #Run Keyword If  'vm' not in '${app}'  Should Be True  (${epoch_first} - ${epoch_last}) > 50  # difference between 1st and last time should be about 2min
   #Run Keyword If  'vm' not in '${app}'  Should Be True  (${epoch_first} - ${epoch_last}) < 150  # difference between 1st and last time should be about 2min 
   Run Keyword If  'vm' not in '${app}'  Should Be True  ${epoch_first} >= ${epochpre} 
	
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}

Get vm app metrics with starttime on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 2 mins earlier
   ${metricspre}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} - 300
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and 1st and last timestamp
   ${metrics}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit_first}=  Split String  ${datesplit_first[0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit_last}=  Split String  ${datesplit_last[0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   Should Be True  (${epoch_first} - ${epoch_last}) == 300  # difference between 1st and last time should be about 2min
   #Should Be True  (${epoch_first} - ${epoch_last}) < 150  # difference between 1st and last time should be about 2min
   Should Be True  ${epoch_first} >= ${epochpre}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   [Return]  ${metrics}

Get app metrics with endtime on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get all metric and set endtime = 2 mins from 1st metric
   ${metricspre}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${end}=  Evaluate  ${epochpre} + 90
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ
	
   ${metrics}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  end_time=${end_date}
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit_first}=  Split String  ${datesplit_first[0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   # get 1st reading from influx
   #${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  cluster_instance_name=${clustername_k8s_shared}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=${developer_name}  condition=ORDER BY ASC LIMIT ${num_readings} 
   
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   Should Be True  ${num_readings} < 30 
   Should Be True  ${epoch_first} <= ${end}

   [Return]  ${metrics}

Get app metrics with starttime=lastrecord on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   #${metrics_influx}=  MexInfluxDB.Get Influx App Disk Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=ORDER BY DESC LIMIT 1  # last record
   #${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC LIMIT 4


   # get last metric
   ${metricspre}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   #log to console  ${metricspre['data'][0]['Series'][0]['values'][0][0]}

   # get readings and 1st and last timestamp
   ${metrics}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${metricspre['data'][0]['Series'][0]['values'][0][0]}
   #log to console  ${metrics}

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=ORDER BY DESC LIMIT ${num_readings+2}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   #Run Keyword If  '${selector}'=='connections'  Should Be True  ${num_readings}==1
   #...  ELSE  Should Be True  ${num_readings}==2 or ${num_readings}==4

   #Run Keyword If  '${selector}'=='connections'  Should Be True  '${metrics['data'][0]['Series'][0]['values'][0][0]}'=='${metricspre['data'][0]['Series'][0]['values'][0][0]}'
   Run Keyword If  ${num_readings}==1  Should Be True  '${metrics['data'][0]['Series'][0]['values'][0][0]}'>='${metricspre['data'][0]['Series'][0]['values'][0][0]}'
   Run Keyword If  ${num_readings}==2  Should Be True  '${metrics['data'][0]['Series'][0]['values'][0][0]}'>='${metricspre['data'][0]['Series'][0]['values'][0][0]}'
   Run Keyword If  ${num_readings}==4  Should Be True  '${metrics['data'][0]['Series'][0]['values'][2][0]}'>='${metricspre['data'][0]['Series'][0]['values'][0][0]}'

   #Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][0]}  ${metricspre['data'][0]['Series'][0]['values'][0][0]}

   [Return]  ${metrics}  ${metrics_influx}

Get app metrics with starttime > lastrecord on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}
	
   # get last metric
   ${metricspre}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 60
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Get app metrics with endtime=lastrecord on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   #EDGECLOUD-1648 Metrics - requesting metrics with endtime=lastrecord does not return the last record
	
   # get last metric
   ${metricspre}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   log to console  ${metricspre['data'][0]['Series'][0]['values'][0][0]}

   # get all metrics
   ${metrics_all}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}

   # get readings and 1st and last timestamp
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  end_time=${metrics_all['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit_first}=  Split String  ${datesplit_first[0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit_last}=  Split String  ${datesplit_last[0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings_all}=  Get Length  ${metrics_all['data'][0]['Series'][0]['values']}
   ${num_readings}=      Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings}==${num_readings_all} or ${num_readings}==${num_readings_all}+1

   #Should Be Equal  ${num_readings_all}  ${num_readings}
 
   Should Be Equal  ${metrics_all['data'][0]['Series'][0]['values'][0][0]}  ${metrics['data'][0]['Series'][0]['values'][0][0]}   #last metric should show

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   [Return]  ${metrics}
	
Get app metrics with endtime = firstrecord on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric
   ${metricspre}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 60
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Get app metrics with starttime > endtime on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${start_date}=  Set Variable  2019-09-02T01:01:01Z	
   ${end_date}=  Set Variable  2019-09-01T01:01:01Z

   # get readings and with starttime in the future
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Get app metrics with starttime and endtime > lastrecord on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric
   ${metricspre}=   Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${start}=  Evaluate  ${epochpre} + 60
   ${end}=  Evaluate  ${epochpre} + 120
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   # get readings and with starttime in the future
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}

   # readings should be empty
   Should Be Equal  ${metrics['data'][0]['Series']}  ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

Get app metrics with starttime and endtime on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=5
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 240
   ${end}=    Evaluate  ${epochpre} - 30
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit_first}=  Split String  ${datesplit_first[0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit_last}=  Split String  ${datesplit_last[0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   #Should Be True  (${epoch_first} - ${epoch_last}) < 60  # difference should be about 30min
   Should Be True  ${epoch_first} < ${epochpre}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be True  ${num_readings} < 50

   [Return]  ${metrics}

Get vm app metrics with starttime and endtime on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=5
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 600
   ${end}=    Evaluate  ${epochpre} - 300
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit_first}=  Split String  ${datesplit_first[0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit_last}=  Split String  ${datesplit_last[0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   Should Be True  (${epoch_first} - ${epoch_last}) == 300  # difference should be about 30min 
   #Should Be True  ${epoch_first} < ${epochpre}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be True  ${num_readings} < 25

   [Return]  ${metrics}
	
Get app metrics with starttime and endtime and last on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 240
   ${end}=    Evaluate  ${epochpre} - 30 
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}  last=1
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit_first}=  Split String  ${datesplit_first[0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit_last}=  Split String  ${datesplit_last[0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   #Should Be True  (${epoch_last} - ${epoch_first}) < 30  # difference should be about 30s
   Should Be True  ${epoch_last} < ${epochpre}
   Should Be True  (${end} - ${epoch_first}) - 60  #should be within 1 min of last requested

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   [Return]  ${metrics}

Get vm app metrics with starttime and endtime and last on openstack
   [Arguments]  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 600
   ${end}=    Evaluate  ${epochpre} - 300
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}  last=1
   @{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit_first}=  Split String  ${datesplit_first[0]}  .
   @{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit_last}=  Split String  ${datesplit_last[0]}  .
   ${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   ${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   log to console  ${epochpre}
   log to console  ${epoch_first}
   log to console  ${epoch_last}
   #Should Be True  (${epoch_last} - ${epoch_first}) == 300  # difference should be about 30s
   #Should Be True  ${epoch_last} < ${epochpre}
   #Should Be True  (${end} - ${epoch_first}) - 60  #should be within 1 min of last requested

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1
   log to console  ${num_readings}

   [Return]  ${metrics}

DeveloperManager shall be able to get app metrics
   [Arguments]  ${username}  ${password}  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   #Verify Email  email_address=${emailepoch}

   Run Keyword and Ignore Error  Create Org  orgname=${developer}  orgtype=developer

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   Adduser Role   orgname=${developer}   username=${epochusername}  role=DeveloperManager   token=${adminToken}  #use_defaults=${False}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=5  token=${userToken}
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=GROUP BY cluster ORDER BY DESC LIMIT 7 
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  ${metrics_influx}

DeveloperContributor shall be able to get app metrics
   [Arguments]  ${username}  ${password}  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   #Verify Email  email_address=${emailepoch}

   Run Keyword and Ignore Error  Create Org  orgname=${developer}  orgtype=developer

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   Adduser Role   orgname=${developer}   username=${epochusername}  role=DeveloperContributor   token=${adminToken}  #use_defaults=${False}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=5  token=${userToken}
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=GROUP BY cluster ORDER BY DESC LIMIT 7
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  ${metrics_influx}

DeveloperViewer shall be able to get app metrics
   [Arguments]  ${username}  ${password}  ${app}  ${dbapp}  ${cluster}  ${cloudlet}  ${operator}  ${developer}  ${selector}

   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   #Verify Email  email_address=${emailepoch}

   Run Keyword and Ignore Error  Create Org  orgname=${developer}  orgtype=developer

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   Adduser Role   orgname=${developer}   username=${epochusername}  role=DeveloperViewer   token=${adminToken}  #use_defaults=${False}

   ${metrics}=         Get App Metrics  region=${region}  app_name=${app}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=5  token=${userToken}
   ${metrics_influx}=  Run Keyword  Get Influx App ${selector} Metrics  app_name=${dbapp}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  condition=GROUP BY cluster ORDER BY DESC LIMIT 7
   log to console  ${metrics}
   log to console  ${metrics_influx}
   log to console  ${metrics['data'][0]['Series'][0]['values'][0][0]}
   log to console  ${metrics_influx[0]['time']}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}  ${metrics_influx}

Get app metrics with cloudlet/operator/developer only 
   [Arguments]  ${cloudlet}  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=20
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][-1][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   @{datesplit2}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit2}=  Split String  ${datesplit2[0]}  .
   ${epochpost}=  Convert Date  ${datesplit2[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   #${start}=  Evaluate  ${epochpre} - 14400
   #${end}=    Evaluate  ${epochpre} - 30
   ${start}=  Evaluate  ${epochpre} - 1
   ${end}=    Evaluate  ${epochpost} - 1
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get App Metrics  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}  last=5
   #@{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   #@{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
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

   Should Be Equal As Integers  ${num_readings}  5
	
   [Return]  ${metrics}

Get app metrics with cloudlet/developer only
   [Arguments]  ${cloudlet}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  cloudlet_name=${cloudlet}  developer_org_name=${developer}  selector=${selector}  last=20
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 10800
   ${end}=    Evaluate  ${epochpre} - 30
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
   ${metrics}=  Get App Metrics  region=${region}  cloudlet_name=${cloudlet}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}  last=5
   #@{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   #@{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
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

   Should Be Equal As Integers  ${num_readings}  5

   [Return]  ${metrics}

Get app metrics with operator/developer only
   [Arguments]  ${operator}  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  last=20
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 10800
   ${end}=    Evaluate  ${epochpre} - 30
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
#   ${metrics}=  Get App Metrics  region=${region}  operator_org_name=${operator}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}  last=20
   #@{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   #@{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   #${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   #log to console  ${epochpre}
   #log to console  ${epoch_first}
   #log to console  ${epoch_last}
   #Should Be True  (${epoch_last} - ${epoch_first}) < 30  # difference should be about 30s
   #Should Be True  ${epoch_last} < ${epochpre}
   #Should Be True  (${end} - ${epoch_first}) - 60  #should be within 1 min of last requested

   Should Be Equal  ${metricspre['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metricspre['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metricspre['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be Equal As Integers  ${num_readings}  20

   [Return]  ${metricspre}

Get app metrics with developer only
   [Arguments]  ${developer}  ${selector}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  developer_org_name=${developer}  selector=${selector}  last=20
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   @{datesplit}=  Split String  ${datesplit[0]}  .
   ${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 10800
   ${end}=    Evaluate  ${epochpre} - 30
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   ${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ

   log to console  ${start_date} ${end_date}

   # get readings with starttime and endtime
#   ${metrics}=  Get App Metrics  region=${region}  developer_org_name=${developer}  selector=${selector}  start_time=${start_date}  end_time=${end_date}  last=20
   #@{datesplit_first}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  Z
   #@{datesplit_last}=   Split String  ${metrics['data'][0]['Series'][0]['values'][-1][0]}  Z
   #${epoch_first}=  Convert Date  ${datesplit_first[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #${epoch_last}=   Convert Date  ${datesplit_last[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   #log to console  ${epochpre}
   #log to console  ${epoch_first}
   #log to console  ${epoch_last}
   #Should Be True  (${epoch_last} - ${epoch_first}) < 30  # difference should be about 30s
   #Should Be True  ${epoch_last} < ${epochpre}
   #Should Be True  (${end} - ${epoch_first}) - 60  #should be within 1 min of last requested

   Should Be Equal  ${metricspre['data'][0]['Messages']}  ${None}
   Dictionary Should Not Contain Key  ${metricspre['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metricspre['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   Should Be Equal As Integers  ${num_readings}  20

   [Return]  ${metricspre}

Get all app metrics with developer only
   [Arguments]  ${developer}  ${selector}  ${number_to_check}

   # get last metric and set starttime = 1 hour earlier
   ${metricspre}=  Get App Metrics  region=${region}  developer_org_name=${developer}  selector=${selector} 
   log to console  ${metricspre['data'][0]}
   #@{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  Z
   #@{datesplit}=  Split String  ${datesplit[0]}  .
   #${epochpre}=  Convert Date  ${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   #log to console  ${epochpre}
   #${start}=  Evaluate  ${epochpre} - 10800
   #${end}=    Evaluate  ${epochpre} - 30
   #${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   #${end_date}=  Convert Date  date=${end}  result_format=%Y-%m-%dT%H:%M:%SZ
#
#   log to console  ${start_date} ${end_date}
#
#   Should Be Equal  ${metricspre['data'][0]['Messages']}  ${None}
#   Dictionary Should Not Contain Key  ${metricspre['data'][0]['Series'][0]}  partial
#
   ${num_readings}=  Get Length  ${metricspre['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   #Should Be Equal As Integers  ${num_readings}  2000
   Should Be Equal As Integers  ${num_readings}  ${number_to_check}  # limit changed to 10000


   [Return]  ${metricspre}

Get all app metrics with developer/clusterorg only
   [Arguments]  ${developer}  ${clusterorg}  ${selector} 

   ${metricspre}=  Get App Metrics  region=${region}  developer_org_name=${developer}  cluster_instance_developer_org_name=${cluster_org}  selector=${selector}
   log to console  ${metricspre['data'][0]}

   ${num_readings}=  Get Length  ${metricspre['data'][0]['Series'][0]['values']}
   log to console  ${num_readings}

   [Return]  ${metricspre}

