*** Settings ***
Documentation   Latency Edge Event Tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections

Resource  /Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/metrics/metrics_dme_library.robot

Suite Setup	Setup
Suite Teardown	Teardown Settings  ${settings_pre}

Test Timeout    240s

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3241
DMEMetrics - Shall be able to get the last DME Client App metric
   [Documentation]
   ...  request DME RegisterClient metrics with last=1
   ...  verify info is correct

#   [Teardown]  Teardown Settings  ${settings_pre}

   ${metrics}=  Get the last client app usage metric  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - Shall be able to get all DME Client App metric
   [Documentation]
   ...  request DME RegisterClient metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get all client app usage metrics  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - Shall be able to get DME Client App metrics with starttime
   [Documentation]
   ...  request DME RegisterClient metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - Shall be able to get DME Client App metrics with endtime
   [Documentation]
   ...  request DME RegisterClient metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with endtime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - Shall be able to get DME Client App metrics with starttime and endtime
   [Documentation]
   ...  request DME RegisterClient metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime and endtime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - Shall be able to get DME Client App metrics with starttime and endtime and last
   [Documentation]
   ...  request DME RegisterClient metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime and endtime and last   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - Shall be able to get DME Client App metrics with locationtile
   [Documentation]
   ...  request DME RegisterClient metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with locationtile   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - Shall be able to get DME Client App metrics with rawdata
   [Documentation]
   ...  request DME RegisterClient metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with rawdata   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

DMEMetrics - DeveloperManager shall be able to get DME Client App metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}=  DeveloperManager shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - DeveloperContributor shall be able to get DME Client App metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}=  DeveloperContributor shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - DeveloperViewer shall be able to get DME Client App metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}=  DeveloperViewer shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6

DMEMetrics - OperatorManager shall be able to get DME Client App metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}=  OperatorManager shall not be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}3  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=tmocloud-2

DMEMetrics - OperatorContributor shall be able to get DME Client App metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}=  OperatorContributor shall not be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}3  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=tmocloud-2

DMEMetrics - OperatorViewer shall be able to get DME Client App metrics
   [Documentation]
   ...  request the DME RegisterClient metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}=  OperatorViewer shall not be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be Correct  ${app_name}3  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=tmocloud-2

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${app_name}=  Get Default App Name

    Create Flavor  region=${region}

    @{cloudlet_list}=  Create List  tmocloud-2
    ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  cloudlet_list=${cloudlet_list}

    Create App  region=${region}  app_name=${app_name}1  access_ports=tcp:1
    Create App Instance  region=${region}  app_name=${app_name}1  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster

    Create App  region=${region}  app_name=${app_name}2  access_ports=tcp:1
    Create App Instance  region=${region}  app_name=${app_name}2  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster

    Create App  region=${region}  app_name=${app_name}3  access_ports=tcp:1
    Create App Instance  region=${region}  app_name=${app_name}3  cloudlet_name=tmocloud-2  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster

    Set Suite Variable  ${app_name}

    ${settings_pre}=   Show Settings  region=${region}

#    [Teardown]  Teardown Settings  ${settings_pre}

    @{collection_intervals}=  Create List  10s  1m10s  2m10s
    Update Settings  region=${region}  edge_events_metrics_collection_interval=10s  edge_events_metrics_continuous_queries_collection_intervals=@{collection_intervals}

    ${r1}=  Register Client  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}	
    ${cloudlet1}=  Find Cloudlet	 carrier_name=${operator_name_fake}  latitude=36  longitude=-96
    Should Be Equal As Numbers  ${cloudlet1.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet1.edge_events_cookie}') > 100

    ${r2}=  Register Client  app_name=${app_name}2  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet2}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96
    Should Be Equal As Numbers  ${cloudlet2.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.edge_events_cookie}') > 100

    ${r3}=  Register Client  app_name=${app_name}3  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet3}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96
    Should Be Equal As Numbers  ${cloudlet3.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet3.edge_events_cookie}') > 100

    @{samples1}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${170.45}
    ${num_samples1}=  Get Length  ${samples1}

    #${average1}=  Evaluate  round(statistics.mean(@{samples}))  statistics
    #${stdev}=  Evaluate  round(statistics.stdev(@{samples1}))  statistics
    #${variance}=  Evaluate  round(statistics.variance(@{samples1}))  statistics
    #${num_samples}=  Get Length  ${samples}
    #${min}=  Evaluate  min(@{samples})
    #${max}=  Evaluate  max(@{samples})

    Create DME Persistent Connection  carrier_name=${operator_name_fake}  session_cookie=${r1.session_cookie}  edge_events_cookie=${cloudlet1.edge_events_cookie}  latitude=36  longitude=-96
    ${latency11}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
    ${latency21}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
    ${latency31}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
    ${latency41}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
    ${latency51}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
    ${latency61}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
#    Terminate DME Persistent Connection

    Create DME Persistent Connection  carrier_name=${operator_name_fake}  session_cookie=${r2.session_cookie}  edge_events_cookie=${cloudlet2.edge_events_cookie}  latitude=36  longitude=-96
    ${latency12}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
    ${latency22}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
#    Terminate DME Persistent Connection
#
    Create DME Persistent Connection  carrier_name=${operator_name_fake}  session_cookie=${r3.session_cookie}  edge_events_cookie=${cloudlet3.edge_events_cookie}  latitude=36  longitude=-96
    ${latency13}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
    ${latency23}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  latitude=36  longitude=-96  samples=${samples1}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75
    #Terminate DME Persistent Connection

    #${latency_avg}=  Evaluate  round(${latency.statistics.avg})
    #${latency_std_dev}=  Evaluate  round(${latency.statistics.std_dev})
    #${latency_variance}=  Evaluate  round(${latency.statistics.variance})

    #Should Be Equal  ${latency_avg}  ${average}
    #Should Be Equal  ${latency.statistics.min}  ${min}
    #Should Be Equal  ${latency.statistics.max}  ${max}
    #Should Be Equal  ${latency_std_dev}  ${stdev}
    #Should Be Equal  ${latency_variance}  ${variance}
    #Should Be Equal  ${latency.statistics.num_samples}  ${num_samples}
    #Should Be True   ${latency.statistics.timestamp.seconds} > 0
    #Should Be True   ${latency.statistics.timestamp.nanos} > 0

    Sleep  20s
#    ${metrics1}=  Get Client App Metrics  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

    Sleep  60s
#    ${metrics2}=  Get Client App Metrics  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency
    
    Sleep  70s
#    ${metrics31}=  Get Client App Metrics  region=${region}  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency
#    ${metrics32}=  Get Client App Metrics  region=${region}  app_name=${app_name}2  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency
#    ${metrics33}=  Get Client App Metrics  region=${region}  app_name=${app_name}3  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency
#
#    Should Be Equal  ${metrics31['data'][0]['Series'][0]['name']}  latency-metric-2m10s
#    Should Be Equal  ${metrics31['data'][0]['Series'][1]['name']}  latency-metric-1m10s
#    Should Be Equal  ${metrics31['data'][0]['Series'][2]['name']}  latency-metric-10s
#    Should Be Equal  ${metrics32['data'][0]['Series'][0]['name']}  latency-metric-2m10s
#    Should Be Equal  ${metrics32['data'][0]['Series'][1]['name']}  latency-metric-1m10s
#    Should Be Equal  ${metrics32['data'][0]['Series'][2]['name']}  latency-metric-10s
#    Should Be Equal  ${metrics33['data'][0]['Series'][0]['name']}  latency-metric-2m10s
#    Should Be Equal  ${metrics33['data'][0]['Series'][1]['name']}  latency-metric-1m10s
#    Should Be Equal  ${metrics33['data'][0]['Series'][2]['name']}  latency-metric-10s
#    
#    Metrics Headings Should Be Correct  ${metrics31['data'][0]['Series'][0]['columns']}
#    Metrics Headings Should Be Correct  ${metrics32['data'][0]['Series'][1]['columns']}
#    Metrics Headings Should Be Correct  ${metrics33['data'][0]['Series'][2]['columns']}
#
#    Values Should Be Correct  ${app_name}1  ${metrics31['data'][0]['Series'][0]['values']}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6
#    Values Should Be Correct  ${app_name}2  ${metrics32['data'][0]['Series'][1]['values']}  ${latency12.statistics.max}  ${latency12.statistics.min}  ${latency12.statistics.avg}  ${latency12.statistics.std_dev}  ${latency12.statistics.variance}  ${num_samples1}  2
#    Values Should Be Correct  ${app_name}3  ${metrics33['data'][0]['Series'][2]['values']}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2

    Set Suite Variable  ${latency11}
    Set Suite Variable  ${latency13}
    Set Suite Variable  ${num_samples1}
    Set Suite Variable  ${settings_pre}

#*** Keywords ***
#Setup
#    ${epoch}=  Get Time  epoch
#
#    ${app_name}=  Get Default App Name
#
#    Create Flavor  region=${region}
#  
#    Create App  region=${region}  app_name=${app_name}1  access_ports=tcp:1
#    Create App Instance  region=${region}  app_name=${app_name}1  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster
# 
#    Create App  region=${region}  app_name=${app_name}2  access_ports=tcp:1
#    Create App Instance  region=${region}  app_name=${app_name}2  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster
#
#    Create App  region=${region}  app_name=${app_name}3  access_ports=tcp:1
#    Create App Instance  region=${region}  app_name=${app_name}3  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster
#   
#    Set Suite Variable  ${app_name}

Teardown Settings
   [Arguments]  ${settings}

   Login

   @{collection_intervals}=  Create List  ${settings['edge_events_metrics_continuous_queries_collection_intervals'][0]['interval']}  ${settings['edge_events_metrics_continuous_queries_collection_intervals'][1]['interval']}  ${settings['edge_events_metrics_continuous_queries_collection_intervals'][2]['interval']}
   Update Settings  region=${region}  edge_events_metrics_collection_interval=${settings['appinst_client_cleanup_interval']}  edge_events_metrics_continuous_queries_collection_intervals=@{collection_intervals}

   Teardown

Teardown
   Terminate DME Persistent Connection
   Cleanup Provisioning

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}  ${raw}=${False}

   Run Keyword If   not ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  latency-metric-2m10s
   Run Keyword If   not ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][1]['name']}  latency-metric-1m10s
   Run Keyword If   not ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][2]['name']}  latency-metric-10s
   ${count}=  Run Keyword If   not ${raw}  Set Variable  3
   ...   ELSE  Set Variable  1

   Run Keyword If   ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  latency-metric

   FOR  ${i}  IN RANGE  0  ${count} 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][0]}  time
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][1]}  app
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][2]}  apporg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][3]}  ver
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][4]}  cluster
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][5]}  clusterorg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][6]}  cloudlet
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][7]}  cloudletorg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][8]}  signalstrength
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][9]}  0s
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][10]}  5ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][11]}  10ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][12]}  25ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][13]}  50ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][14]}  100ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][15]}  max
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][16]}  min
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][17]}  avg
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][18]}  variance 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][19]}  stddev
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][20]}  numsamples
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][21]}  locationtile
   END

Values Should Be Correct
   [Arguments]  ${app_name}  ${metrics}  ${max}  ${min}  ${avg}  ${variance}  ${stddev}  ${numsamples}  ${numrequests}  ${cloudlet}=${cloudlet_name_fake}  ${raw}=${False}

   ${count}=  Run Keyword If   not ${raw}  Set Variable  3
   ...   ELSE  Set Variable  1

   FOR  ${i}  IN RANGE  0  ${count}
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][1]}  ${app_name}
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][2]}  ${developer_org_name_automation}
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][3]}  1.0
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][4]}  autocluster
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][5]}  MobiledgeX
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][6]}  ${cloudlet}
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][7]}  ${operator_name_fake}
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][8]}  75 

      ${r9}=  Evaluate  ${2}*${numrequests}
      ${r10}=  Evaluate  ${1}*${numrequests}
      ${r11}=  Evaluate  ${1}*${numrequests}
      ${r12}=  Evaluate  ${1}*${numrequests}
      ${r13}=  Evaluate  ${0}*${numrequests}
      ${r14}=  Evaluate  ${2}*${numrequests}
      ${r20}=  Evaluate  ${numsamples}*${numrequests}

      Should Be Equal As Numbers  ${metrics['data'][0]['Series'][${i}]['values'][0][9]}   ${r9}
      Should Be Equal As Numbers  ${metrics['data'][0]['Series'][${i}]['values'][0][10]}  ${r10}
      Should Be Equal As Numbers  ${metrics['data'][0]['Series'][${i}]['values'][0][11]}  ${r11}
      Should Be Equal As Numbers  ${metrics['data'][0]['Series'][${i}]['values'][0][12]}  ${r12}
      Should Be Equal As Numbers  ${metrics['data'][0]['Series'][${i}]['values'][0][13]}  ${r13}
      Should Be Equal As Numbers  ${metrics['data'][0]['Series'][${i}]['values'][0][14]}  ${r14}

      ${latency_avg}=  Evaluate  round(${avg})
      ${metrics_avg}=  Evaluate  round(${metrics['data'][0]['Series'][${i}]['values'][0][17]})

      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][15]}  ${max}
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][16]}  ${min}
      Should Be Equal  ${metrics_avg}  ${latency_avg} 
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][18]}  ${variance}
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][19]}  ${stddev}
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][20]}  ${r20}
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][21]}  2-1990,5343-2
   END


