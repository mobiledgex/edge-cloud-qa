*** Settings ***
Documentation   Latency Edge Event Tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections

Test Setup	Setup
Test Teardown	Teardown Settings

Test Timeout    180s

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3241
DMEPersistentConnection - Latency edge event shall return statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event with samples
    ...  - verify response has correct stats

    [Tags]  DMEPersistentConnection

    ${settings_pre}=   Show Settings  region=${region}

    [Teardown]  Teardown Settings  ${settings_pre}

    @{collection_intervals}=  Create List  10s  1m10s  2m10s
    Update Settings  region=${region}  edge_events_metrics_collection_interval=10s  edge_events_metrics_continuous_queries_collection_intervals=@{collection_intervals}

    ${r}=  Register Client  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}	
    ${cloudlet}=  Find Cloudlet	 carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    @{samples}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${170.45}

    ${average}=  Evaluate  round(statistics.mean(@{samples}))  statistics
    ${stdev}=  Evaluate  round(statistics.stdev(@{samples}))  statistics
    ${variance}=  Evaluate  round(statistics.variance(@{samples}))  statistics
    ${num_samples}=  Get Length  ${samples}
    ${min}=  Evaluate  min(@{samples})
    ${max}=  Evaluate  max(@{samples})

    Create DME Persistent Connection  carrier_name=${operator_name_fake}  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${latency}=  Send Latency Edge Event  carrier_name=${operator_name_fake}  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  samples=${samples}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75

    ${latency_avg}=  Evaluate  round(${latency.statistics.avg})
    ${latency_std_dev}=  Evaluate  round(${latency.statistics.std_dev})
    ${latency_variance}=  Evaluate  round(${latency.statistics.variance})

    Should Be Equal  ${latency_avg}  ${average}
    Should Be Equal  ${latency.statistics.min}  ${min}
    Should Be Equal  ${latency.statistics.max}  ${max}
    Should Be Equal  ${latency_std_dev}  ${stdev}
    Should Be Equal  ${latency_variance}  ${variance}
    Should Be Equal  ${latency.statistics.num_samples}  ${num_samples}
    Should Be True   ${latency.statistics.timestamp.seconds} > 0
    Should Be True   ${latency.statistics.timestamp.nanos} > 0

    Sleep  20s
#    ${metrics1}=  Get Client App Metrics  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

    Sleep  60s
#    ${metrics2}=  Get Client App Metrics  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency
    
    Sleep  70s
    ${metrics3}=  Get Client App Metrics  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

    Should Be Equal  ${metrics3['data'][0]['Series'][0]['name']}  latency-metric-2m10s
    Should Be Equal  ${metrics3['data'][0]['Series'][1]['name']}  latency-metric-1m10s
    Should Be Equal  ${metrics3['data'][0]['Series'][2]['name']}  latency-metric-10s
    
    Metrics Headings Should Be Correct  ${metrics3['data'][0]['Series'][0]['columns']}
    Metrics Headings Should Be Correct  ${metrics3['data'][0]['Series'][1]['columns']}
    Metrics Headings Should Be Correct  ${metrics3['data'][0]['Series'][2]['columns']}

    Values Should Be Correct  ${metrics3['data'][0]['Series'][0]['values']}  ${latency.statistics.max}  ${latency.statistics.min}  ${latency.statistics.avg}  ${latency.statistics.std_dev}  ${latency.statistics.variance}  ${num_samples} 
    Values Should Be Correct  ${metrics3['data'][0]['Series'][1]['values']}  ${latency.statistics.max}  ${latency.statistics.min}  ${latency.statistics.avg}  ${latency.statistics.std_dev}  ${latency.statistics.variance}  ${num_samples}
    Values Should Be Correct  ${metrics3['data'][0]['Series'][2]['values']}  ${latency.statistics.max}  ${latency.statistics.min}  ${latency.statistics.avg}  ${latency.statistics.std_dev}  ${latency.statistics.variance}  ${num_samples}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${app_name}=  Get Default App Name

    Create Flavor  region=${region}
    Create App  region=${region}  access_ports=tcp:1
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster
    
    Set Suite Variable  ${app_name}

Teardown Settings
   [Arguments]  ${settings}

   @{collection_intervals}=  Create List  ${settings['edge_events_metrics_continuous_queries_collection_intervals'][0]['interval']}  ${settings['edge_events_metrics_continuous_queries_collection_intervals'][1]['interval']}  ${settings['edge_events_metrics_continuous_queries_collection_intervals'][2]['interval']}
   Update Settings  region=${region}  edge_events_metrics_collection_interval=${settings['appinst_client_cleanup_interval']}  edge_events_metrics_continuous_queries_collection_intervals=@{collection_intervals}

   Teardown

Teardown
   Terminate DME Persistent Connection
   Cleanup Provisioning

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics[0]}  time
   Should Be Equal  ${metrics[1]}  app
   Should Be Equal  ${metrics[2]}  apporg
   Should Be Equal  ${metrics[3]}  ver
   Should Be Equal  ${metrics[4]}  cluster
   Should Be Equal  ${metrics[5]}  clusterorg
   Should Be Equal  ${metrics[6]}  cloudlet
   Should Be Equal  ${metrics[7]}  cloudletorg
   Should Be Equal  ${metrics[8]}  signalstrength
   Should Be Equal  ${metrics[9]}  0s
   Should Be Equal  ${metrics[10]}  5ms
   Should Be Equal  ${metrics[11]}  10ms
   Should Be Equal  ${metrics[12]}  25ms
   Should Be Equal  ${metrics[13]}  50ms
   Should Be Equal  ${metrics[14]}  100ms
   Should Be Equal  ${metrics[15]}  max
   Should Be Equal  ${metrics[16]}  min
   Should Be Equal  ${metrics[17]}  avg
   Should Be Equal  ${metrics[18]}  variance 
   Should Be Equal  ${metrics[19]}  stddev
   Should Be Equal  ${metrics[20]}  numsamples
   Should Be Equal  ${metrics[21]}  locationtile

Values Should Be Correct
   [Arguments]  ${metrics}  ${max}  ${min}  ${avg}  ${variance}  ${stddev}  ${numsamples}

   Should Be Equal  ${metrics[0][1]}  ${app_name}
   Should Be Equal  ${metrics[0][2]}  ${developer_org_name_automation}
   Should Be Equal  ${metrics[0][3]}  1.0
   Should Be Equal  ${metrics[0][4]}  autocluster
   Should Be Equal  ${metrics[0][5]}  MobiledgeX
   Should Be Equal  ${metrics[0][6]}  ${cloudlet_name_fake}
   Should Be Equal  ${metrics[0][7]}  ${operator_name_fake}
#   Should Be Equal  ${metrics[0][8]}  75 

   Should Be Equal As Numbers  ${metrics[0][9]}   2
   Should Be Equal As Numbers  ${metrics[0][10]}  1
   Should Be Equal As Numbers  ${metrics[0][11]}  1 
   Should Be Equal As Numbers  ${metrics[0][12]}  1 
   Should Be Equal As Numbers  ${metrics[0][13]}  0 
   Should Be Equal As Numbers  ${metrics[0][14]}  2

   Should Be Equal  ${metrics[0][15]}  ${max}
   Should Be Equal  ${metrics[0][16]}  ${min}
   Should Be Equal  ${metrics[0][17]}  ${avg} 
#   Should Be Equal  ${metrics[0][18]}  ${variance}
#   Should Be Equal  ${metrics[0][19]}  ${stddev}
   Should Be Equal  ${metrics[0][20]}  ${numsamples}
   Should Be Equal  ${metrics[0][21]}  2-1990,53432


