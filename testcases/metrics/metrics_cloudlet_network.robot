*** Settings ***
Documentation   Cloudlet Network Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
Library  DateTime
Library  String
Library  Collections
		      
#Test Setup       Setup
#Test Teardown    Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBonnCloudlet
${operator}=                       TDG
	
*** Test Cases ***
Metrics - Shall be able to get the last network metric on openstack
   [Documentation]
   ...  create a new user with various name
   ...  get user/current info
   ...  verify info is correct
   ...  delete the user

   ${metrics_influx}=  MexInfluxDB.Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=GROUP BY * ORDER BY DESC LIMIT 1  # last record
   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network  last=1
   log to console  ${metrics['data'][0]['Series']}
   log to console  ${metrics_influx}

   # verify against influxdb request
   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][0]}  ${metrics_influx[0]['time']}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][2]}  ${metrics_influx[0]['diskMax']}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][3]}  ${metrics_influx[0]['diskUsed']}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][4]}  ${metrics_influx[0]['memMax']}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][5]}  ${metrics_influx[0]['memUsed']}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][7]}  ${metrics_influx[0]['vCpuMax']}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][0][8]}  ${metrics_influx[0]['vCpuUsed']}

   # verify headings
   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  diskMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  diskUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  memMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  memUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  operator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  vCpuMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  vCpuUsed

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  1

   # verify values
   Should Match Regexp          ${metrics['data'][0]['Series'][0]['values'][0][0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   Should Be Equal              ${metrics['data'][0]['Series'][0]['values'][0][1]}  ${cloudlet_name_openstack_metrics}                        #cloudlet name
   Should Be Equal As Integers  ${metrics['data'][0]['Series'][0]['values'][0][2]}  5000                                                   # disk size
   Should Be True               ${metrics['data'][0]['Series'][0]['values'][0][3]} < 5000                                                  # disk used
   Should Be Equal As Integers  ${metrics['data'][0]['Series'][0]['values'][0][4]}  512000                                                 # ram size
   Should Be True               ${metrics['data'][0]['Series'][0]['values'][0][5]} < 512000                                                # ram used
   Should Be Equal              ${metrics['data'][0]['Series'][0]['values'][0][6]}  ${operator}                                            # operator name
   Should Be Equal As Integers  ${metrics['data'][0]['Series'][0]['values'][0][7]}  200                                                    # number of cpus
   Should Be True               ${metrics['data'][0]['Series'][0]['values'][0][8]} < 200                                                   # cpus used

Metrics - Shall be able to get the last 5 network metrics on bonn openstack
   [Documentation]
   ...  create a new user with various name
   ...  get user/current info
   ...  verify info is correct
   ...  delete the user

   ${metrics_influx}=  MexInfluxDB.Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=GROUP BY * ORDER BY DESC LIMIT 5  # last 5
   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network  last=5
   log to console  ${metrics}
   log to console  ${metrics_influx}

   # verify against influxdb request
   ${index}=  Set Variable  0
   : FOR  ${reading}  IN  @{metrics_influx}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][2]}  ${reading['diskMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][3]}  ${reading['diskUsed']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][4]}  ${reading['memMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][5]}  ${reading['memUsed']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][7]}  ${reading['vCpuMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][8]}  ${reading['vCpuUsed']}
   \  ${index}=  Evaluate  ${index}+1

   # verify heading
   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  diskMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  diskUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  memMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  memUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  operator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  vCpuMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  vCpuUsed

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   ${epochlast}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S

   # verify values
   : FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
   \  @{datesplit}=  Split String  ${reading[0]}  .
   \  ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   \  ${epoch}=  Convert Date  date=${datesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
   \  ${epoch2}=  Evaluate  ${epoch} + 5
   \  Should Be True               ${epoch} <= ${epochlast}
   \  Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   \  Should Be Equal              ${reading[1]}  ${cloudlet_name_openstack_metrics}                        #cloudlet name
   \  Should Be Equal As Integers  ${reading[2]}  5000                                                   # disk size
   \  Should Be True               ${reading[3]} < 5000                                                  # disk used
   \  Should Be Equal As Integers  ${reading[4]}  512000                                                 # ram size
   \  Should Be True               ${reading[5]} < 512000                                                # ram used
   \  Should Be Equal              ${reading[6]}  ${operator}                                            # operator name
   \  Should Be Equal As Integers  ${reading[7]}  200                                                    # number of cpus
   \  Should Be True               ${reading[8]} < 200                                                   # cpus used
   \  ${epochlast}=  Set Variable  ${epoch}


Metrics - Shall be able to get the last 100 network metrics on bonn openstack
   [Documentation]
   ...  create a new user with various name
   ...  get user/current info
   ...  verify info is correct
   ...  delete the user

   ${metrics_influx}=  MexInfluxDB.Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  condition=GROUP BY * ORDER BY DESC LIMIT 100  # last 100
   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network  last=100
   log to console  ${metrics['data'][0]}

   # verify against influxdb request
   ${index}=  Set Variable  0
   : FOR  ${reading}  IN  @{metrics_influx}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][0]}  ${reading['time']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][2]}  ${reading['diskMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][3]}  ${reading['diskUsed']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][4]}  ${reading['memMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][5]}  ${reading['memUsed']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][7]}  ${reading['vCpuMax']}
   \  Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][${index}][8]}  ${reading['vCpuUsed']}
   \  ${index}=  Evaluate  ${index}+1

   # verify headings
   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  diskMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  diskUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  memMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  memUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  operator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  vCpuMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  vCpuUsed

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  100

   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   ${epochlast}=  Convert Date  ${date}  epoch

   # verify values
   : FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
   \  @{datesplit}=  Split String  ${reading[0]}  .
   \  ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   \  ${epoch}=  Convert Date  ${date}  epoch
   \  ${epoch2}=  Evaluate  ${epoch} + 5
   \  Should Be True               ${epoch} <= ${epochlast}
   \  Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   \  Should Be Equal              ${reading[1]}  ${cloudlet_name_openstack_metrics}                        #cloudlet name
   \  Should Be Equal As Integers  ${reading[2]}  5000                                                   # disk size
   \  Should Be True               ${reading[3]} < 5000                                                  # disk used
   \  Should Be Equal As Integers  ${reading[4]}  512000                                                 # ram size
   \  Should Be True               ${reading[5]} < 512000                                                # ram used
   \  Should Be Equal              ${reading[6]}  ${operator}                                            # operator name
   \  Should Be Equal As Integers  ${reading[7]}  200                                                    # number of cpus
   \  Should Be True               ${reading[8]} < 200                                                   # cpus used


Metrics - Shall be able to get all network metrics on bonn openstack
   [Documentation]
   ...  create a new user with various name
   ...  get user/current info
   ...  verify info is correct
   ...  delete the user

   ${metrics}=  Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Log To Console  ${num_readings}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  diskMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  diskUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  memMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  memUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  operator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  vCpuMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  vCpuUsed

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}

   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   ${epochlast}=  Convert Date  ${date}  epoch

   : FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
   \  @{datesplit}=  Split String  ${reading[0]}  .
   \  ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   \  ${epoch}=  Convert Date  ${date}  epoch
   \  ${epoch2}=  Evaluate  ${epoch} + 5

   \  Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   \  Should Be Equal              ${reading[1]}  ${cloudlet_name_openstack_metrics}                        #cloudlet name
   \  Should Be Equal As Integers  ${reading[2]}  5000                                                   # disk size
   \  Should Be True               ${reading[3]} < 5000                                                  # disk used
   \  Should Be Equal As Integers  ${reading[4]}  512000                                                 # ram size
   \  Should Be True               ${reading[5]} < 512000                                                # ram used
   \  Should Be Equal              ${reading[6]}  ${operator}                                            # operator name
   \  Should Be Equal As Integers  ${reading[7]}  200                                                    # number of cpus
   \  Should Be True               ${reading[8]} < 200                                                   # cpus used


Metrics - Shall be able to request more network metrics than exist on bonn openstack
   [Documentation]
   ...  create a new user with various name
   ...  get user/current info
   ...  verify info is correct
   ...  delete the user

   ${metricsall}=  Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network
   ${num_readings_all}=  Get Length  ${metricsall['data'][0]['Series'][0]['values']}

   ${more_readings}=  Evaluate  ${num_readings_all} + 100
   ${metrics}=  Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network  last=${more_readings}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  diskMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  diskUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  memMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  memUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  operator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  vCpuMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  vCpuUsed

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['partial']}  ${True}
	
   ${num_readings_all}=  Get Length  ${metricsall['data'][0]['Series'][0]['values']}
   ${num_readings}=      Get Length  ${metrics['data'][0]['Series'][0]['values']}

   ${num_readings_possible}=  Evaluate  ${num_readings_all} + 5   # could have read 5 more since it might take a while to read a lot of readings
   Should Be True  ${num_readings} >= ${num_readings_all} and ${num_readings} <= ${num_readings_possible}
	
   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   ${epochlast}=  Convert Date  ${date}  epoch

   : FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
   \  @{datesplit}=  Split String  ${reading[0]}  .
   \  ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   \  ${epoch}=  Convert Date  ${date}  epoch
   \  ${epoch2}=  Evaluate  ${epoch} + 5

   \  Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   \  Should Be Equal              ${reading[1]}  ${cloudlet_name_openstack_metrics}                        #cloudlet name
   \  Should Be Equal As Integers  ${reading[2]}  5000                                                   # disk size
   \  Should Be True               ${reading[3]} < 5000                                                  # disk used
   \  Should Be Equal As Integers  ${reading[4]}  512000                                                 # ram size
   \  Should Be True               ${reading[5]} < 512000                                                # ram used
   \  Should Be Equal              ${reading[6]}  ${operator}                                            # operator name
   \  Should Be Equal As Integers  ${reading[7]}  200                                                    # number of cpus
   \  Should Be True               ${reading[8]} < 200                                                   # cpus used

Metrics - Shall be able to get the network metrics with starttime on bonn openstack
   [Documentation]
   ...  create a new user with various name
   ...  get user/current info
   ...  verify info is correct
   ...  delete the user

   ${current_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
   log to console  ${current_date}

   ${metricspre}=  Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network  last=1
   log to console  ${metricspre['data'][0]}
   @{datesplit}=  Split String  ${metricspre['data'][0]['Series'][0]['values'][0][0]}  .
   #${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   ${epochpre}=  Convert Date  ${datesplit[0]}  epoch  date_format=%Y-%m-%dT%H:%M:%S
   log to console  ${epochpre}
   ${start}=  Evaluate  ${epochpre} - 3600
   ${start_date}=  Convert Date  date=${start}  result_format=%Y-%m-%dT%H:%M:%SZ
   log to console  ${start_date}
	
   ${metrics}=  Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network  start_time=${start_date}   #end_time=${current_date}
   log to console  ${metrics['data'][0]}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  diskMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  diskUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  memMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  memUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  operator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  vCpuMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  vCpuUsed

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
	
   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal As Integers  ${num_readings}  5

   @{datesplit}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][0]}  .
   ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   ${epochlast}=  Convert Date  ${date}  epoch

   : FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
   \  @{datesplit}=  Split String  ${reading[0]}  .
   \  ${date}=  Convert Date  ${datesplit[0]}  date_format=%Y-%m-%dT%H:%M:%S
   \  ${epoch}=  Convert Date  ${date}  epoch
   \  ${epoch2}=  Evaluate  ${epoch} + 5

   \  Should Be True               ${epoch} <= ${epochlast}
   \  Should Match Regexp          ${reading[0]}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{1,9}Z  #time
   \  Should Be Equal              ${reading[1]}  ${cloudlet_name_openstack_metrics}                        #cloudlet name
   \  Should Be Equal As Integers  ${reading[2]}  5000                                                   # disk size
   \  Should Be True               ${reading[3]} < 5000                                                  # disk used
   \  Should Be Equal As Integers  ${reading[4]}  512000                                                 # ram size
   \  Should Be True               ${reading[5]} < 512000                                                # ram used
   \  Should Be Equal              ${reading[6]}  ${operator}                                            # operator name
   \  Should Be Equal As Integers  ${reading[7]}  200                                                    # number of cpus
   \  Should Be True               ${reading[8]} < 200                                                   # cpus used
   \  ${epochlast}=  Set Variable  ${epoch}
