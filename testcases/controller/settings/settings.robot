*** Settings ***
Documentation   MasterController Org Create as Admin

Library  MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  Collections

#Test Setup      Setup
#Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=    mextester06
${password}=    H31m8@W8maSfg
${adminuser}=   mextester06admin
${adminpass}=   mexadminfastedgecloudinfra

${region}=  US
@{collection_intervals}=  1s  1s  1s

*** Test Cases ***
# ECQ-2988
Settings - ShowSettings should return the settings

   [Tags]  ReservableCluster

   [Documentation]
   ...  - call ShowSettings
   ...  - verify the settings items are returned

   ${settings}=   Show Settings  region=${region}

   Should Contain  ${settings}  auto_deploy_interval_sec
   Should Contain  ${settings}  auto_deploy_max_intervals
   Should Contain  ${settings}  auto_deploy_offset_sec
   Should Contain  ${settings}  chef_client_interval
   Should Contain  ${settings}  cloudlet_maintenance_timeout
   Should Contain  ${settings}  create_cloudlet_timeout
   Should Contain  ${settings}  create_app_inst_timeout
   Should Contain  ${settings}  create_cluster_inst_timeout
   Should Contain  ${settings}  delete_app_inst_timeout
   Should Contain  ${settings}  delete_cluster_inst_timeout
   Should Contain  ${settings}  influx_db_metrics_retention
   Should Contain  ${settings}  influx_db_cloudlet_usage_metrics_retention
   Should Contain  ${settings}  influx_db_downsampled_metrics_retention
   Should Contain  ${settings}  influx_db_edge_events_metrics_retention
#   Should Contain  ${settings}  load_balancer_max_port_range
   Should Contain  ${settings}  master_node_flavor
   Should Contain  ${settings}  max_tracked_dme_clients
   Should Contain  ${settings}  shepherd_alert_evaluation_interval
   Should Contain  ${settings}  shepherd_health_check_interval
   Should Contain  ${settings}  shepherd_health_check_retries
   Should Contain  ${settings}  shepherd_metrics_collection_interval
   Should Contain  ${settings}  update_cloudlet_timeout
   Should Contain  ${settings}  update_app_inst_timeout
   Should Contain  ${settings}  update_cluster_inst_timeout
   Should Contain  ${settings}  update_vm_pool_timeout
   Should Contain  ${settings}  update_trust_policy_timeout
   Should Contain  ${settings}  dme_api_metrics_collection_interval 
   Should Contain  ${settings}  edge_events_metrics_collection_interval 
   Should Contain  ${settings}  edge_events_metrics_continuous_queries_collection_intervals
   Should Contain  ${settings}  cleanup_reservable_auto_cluster_idletime
   Should Contain  ${settings}  location_tile_side_length_km
   Should Contain  ${settings}  appinst_client_cleanup_interval
   Should Contain  ${settings}  cluster_auto_scale_averaging_duration_sec
   Should Contain  ${settings}  cluster_auto_scale_retry_delay         
   Should Contain  ${settings}  alert_policy_min_trigger_time   
#   Should Contain  ${settings}  disable_rate_limit                 
   Should Contain  ${settings}  max_num_per_ip_rate_limiters         

# ECQ-2989
Settings - UpdateSettings should update the settings
   [Documentation]
   ...  - call UpdateSettings for each setting
   ...  - verify the settings items are changed

   [Tags]  ReservableCluster

   ${settings}=   Show Settings  region=${region}

   [Teardown]  Cleanup Settings  ${settings}

   FOR  ${key}  IN  @{settings.keys()}
      log to console  ${key} ${settings['${key}']}
   END

   Update Settings  region=${region}  shepherd_metrics_collection_interval=1s
   Update Settings  region=${region}  shepherd_alert_evaluation_interval=100s 
   Update Settings  region=${region}  shepherd_health_check_retries=1 
   Update Settings  region=${region}  shepherd_health_check_interval=1s 

   Update Settings  region=${region}  influx_db_metrics_retention=0h0m0s  influx_db_cloudlet_usage_metrics_retention=0h0m0s
   Update Settings  region=${region}  influx_db_metrics_retention=1h0m0s  influx_db_cloudlet_usage_metrics_retention=1h0m0s

   Update Settings  region=${region}  auto_deploy_interval_sec=1   auto_deploy_offset_sec=1  auto_deploy_max_intervals=1

   Update Settings  region=${region}  create_app_inst_timeout=1m0s  update_app_inst_timeout=1m0s  delete_app_inst_timeout=1m0s  create_cluster_inst_timeout=1m0s   update_cluster_inst_timeout=1m0s   delete_cluster_inst_timeout=1m0s  create_cloudlet_timeout=1m0s  update_cloudlet_timeout=1m0s

   #Update Settings  region=${region}  master_node_flavor=x1.medium  load_balancer_max_port_range=1  max_tracked_dme_clients=1  chef_client_interval=1m0s  influx_db_metrics_retention=1h0m0s  influx_db_downsampled_metrics_retention=1h0m0s  influx_db_edge_events_metrics_retention=1h0m0s  cloudlet_maintenance_timeout=1s  update_vm_pool_timeout=1s
   Update Settings  region=${region}  master_node_flavor=x1.medium  max_tracked_dme_clients=1  chef_client_interval=1m0s  influx_db_metrics_retention=1h0m0s  influx_db_downsampled_metrics_retention=1h0m0s  influx_db_edge_events_metrics_retention=1h0m0s  cloudlet_maintenance_timeout=1s  update_vm_pool_timeout=1s

   @{collection_intervals}=  Create List  1s  1s  1s 
   Update Settings  region=${region}  update_trust_policy_timeout=1s  dme_api_metrics_collection_interval=1s  edge_events_metrics_collection_interval=1s  edge_events_metrics_continuous_queries_collection_intervals=@{collection_intervals}  cleanup_reservable_auto_cluster_idletime=31s  location_tile_side_length_km=1  appinst_client_cleanup_interval=1h

   Update Settings  region=${region}  cluster_auto_scale_averaging_duration_sec=1  cluster_auto_scale_retry_delay=1s  alert_policy_min_trigger_time=1s  disable_rate_limit=${True}  max_num_per_ip_rate_limiters=1  resource_snapshot_thread_interval=31s

   ${settings_post}=   Show Settings  region=${region}

   Should Be Equal             ${settings_post['shepherd_metrics_collection_interval']}  1s
   Should Be Equal             ${settings_post['shepherd_alert_evaluation_interval']}    1m40s
   Should Be Equal As Numbers  ${settings_post['shepherd_health_check_retries']}         1
   Should Be Equal             ${settings_post['shepherd_health_check_interval']}        1s

   Should Be Equal As Numbers  ${settings_post['auto_deploy_interval_sec']}       1
   Should Be Equal As Numbers  ${settings_post['auto_deploy_max_intervals']}      1
   Should Be Equal As Numbers  ${settings_post['auto_deploy_offset_sec']}         1

   Should Be Equal  ${settings_post['create_cloudlet_timeout']}      1m0s
   Should Be Equal  ${settings_post['update_cloudlet_timeout']}      1m0s
   Should Be Equal  ${settings_post['create_app_inst_timeout']}      1m0s  
   Should Be Equal  ${settings_post['update_app_inst_timeout']}      1m0s
   Should Be Equal  ${settings_post['delete_app_inst_timeout']}      1m0s
   Should Be Equal  ${settings_post['create_cluster_inst_timeout']}  1m0s
   Should Be Equal  ${settings_post['update_cluster_inst_timeout']}  1m0s
   Should Be Equal  ${settings_post['delete_cluster_inst_timeout']}  1m0s

   Should Be Equal             ${settings_post['master_node_flavor']}            x1.medium 
#   Should Be Equal As Numbers  ${settings_post['load_balancer_max_port_range']}  1  
   Should Be Equal As Numbers  ${settings_post['max_tracked_dme_clients']}       1  
   Should Be Equal             ${settings_post['chef_client_interval']}          1m0s  
   Should Be Equal             ${settings_post['influx_db_metrics_retention']}   1h0m0s 
   Should Be Equal             ${settings_post['influx_db_cloudlet_usage_metrics_retention']}   1h0m0s
   Should Be Equal             ${settings_post['influx_db_downsampled_metrics_retention']}   1h0m0s
   Should Be Equal             ${settings_post['influx_db_edge_events_metrics_retention']}   1h0m0s
   Should Be Equal             ${settings_post['cloudlet_maintenance_timeout']}  1s
   Should Be Equal             ${settings_post['update_vm_pool_timeout']}        1s
   Should Be Equal             ${settings_post['update_trust_policy_timeout']}   1s

   Should Be Equal             ${settings_post['dme_api_metrics_collection_interval']}   1s
   Should Be Equal             ${settings_post['edge_events_metrics_collection_interval']}   1s
   Should Be Equal             ${settings_post['edge_events_metrics_continuous_queries_collection_intervals'][0]['interval']}   1s
   Should Be Equal             ${settings_post['edge_events_metrics_continuous_queries_collection_intervals'][1]['interval']}   1s
   Should Be Equal             ${settings_post['edge_events_metrics_continuous_queries_collection_intervals'][2]['interval']}   1s
   Should Be Equal             ${settings_post['cleanup_reservable_auto_cluster_idletime']}   31s
   Should Be Equal As Numbers  ${settings_post['location_tile_side_length_km']}               1
   Should Be Equal             ${settings_post['appinst_client_cleanup_interval']}   1h0m0s

   Should Be Equal As Numbers  ${settings_post['cluster_auto_scale_averaging_duration_sec']}  1 
   Should Be Equal             ${settings_post['cluster_auto_scale_retry_delay']}  1s 
   Should Be Equal             ${settings_post['alert_policy_min_trigger_time']}  1s
   Should Be True              ${settings_post['disable_rate_limit']} 
   Should Be Equal As Numbers  ${settings_post['max_num_per_ip_rate_limiters']}  1
   Should Be Equal             ${settings_post['resource_snapshot_thread_interval']}  31s

# ECQ-2990
Settings - UpdateSettings with bad parms shall return error
   [Documentation]
   ...  - call UpdateSettings for each setting with various errors
   ...  - verify error is received

   [Tags]  ReservableCluster

   # fixed EDGECLOUD-4164 	UpdateSettings for autodeployintervalsec with large values give wrong error message 
   # fixed EDGECLOUD-4167 	UpdateSettings for loadbalancermaxportrange should only allow valid values 
   # fixed EDGECLOUD-4168 	UpdateSettings for maxtrackeddmeclients should only allow valid values 
   # fixed EDGECLOUD-4169 	UpdateSettings for chefclientinterval should only allow valid values 
   # fixed EDGECLOUD-4163 	UpdateSettings for influxdbmetricsretention should give better error message 
   # fixed EDGECLOUD-4631  settings update for appinstclientcleanupinterval give bad error message
   # fixed EDGECLOUD-4633  UpdateSettings for autodeployintervalsec with values <= 0 give bad error message

   [Template]  Fail Create UpdateSettings 
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          shepherd_metrics_collection_interval  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')         shepherd_metrics_collection_interval  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          shepherd_metrics_collection_interval  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')  shepherd_metrics_collection_interval  99999999h 
   ('code=400', 'error={"message":"Shepherd Metrics Collection Interval must be greater than 0s"}')                                                     shepherd_metrics_collection_interval  0s
   ('code=400', 'error={"message":"Shepherd Metrics Collection Interval must be greater than 0s"}')                                                     shepherd_metrics_collection_interval  -1s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          shepherd_alert_evaluation_interval  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')         shepherd_alert_evaluation_interval  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          shepherd_alert_evaluation_interval  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')  shepherd_alert_evaluation_interval  99999999h
   ('code=400', 'error={"message":"Shepherd Alert Evaluation Interval must be greater than 0s"}')                                                       shepherd_alert_evaluation_interval  0s
   ('code=400', 'error={"message":"Shepherd Alert Evaluation Interval must be greater than 0s"}')                                                       shepherd_alert_evaluation_interval  -1s 

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int32, but got string for field \\\\"Settings.shepherd_health_check_retries\\\\" at offset 51"}\')                      shepherd_health_check_retries  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int32, but got string for field \\\\"Settings.shepherd_health_check_retries\\\\" at offset 50"}\')                      shepherd_health_check_retries  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int32, but got number 9999999999999999999 for field \\\\"Settings.shepherd_health_check_retries\\\\" at offset 66"}\')  shepherd_health_check_retries  9999999999999999999
   ('code=400', 'error={"message":"Shepherd Health Check Retries must be greater than 0"}')                                                                                                             shepherd_health_check_retries  0
   ('code=400', 'error={"message":"Shepherd Health Check Retries must be greater than 0"}')                                                                                                             shepherd_health_check_retries  -1 

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          shepherd_health_check_interval  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')         shepherd_health_check_interval  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          shepherd_health_check_interval  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')  shepherd_health_check_interval  99999999h
   ('code=400', 'error={"message":"Shepherd Health Check Interval must be greater than 0s"}')                                                           shepherd_health_check_interval  0s
   ('code=400', 'error={"message":"Shepherd Health Check Interval must be greater than 0s"}')                                                           shepherd_health_check_interval  -1s 

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected float64, but got string for field \\\\"Settings.auto_deploy_interval_sec\\\\" at offset 46"}')  auto_deploy_interval_sec  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected float64, but got string for field \\\\"Settings.auto_deploy_interval_sec\\\\" at offset 45"}')  auto_deploy_interval_sec  x
   ('code=400', 'error={"message":"Auto Deploy Interval Sec must be greater than 0"}')                                                                                          auto_deploy_interval_sec  0
   ('code=400', 'error={"message":"Auto Deploy Interval Sec must be greater than 0"}')                                                                                          auto_deploy_interval_sec  -1 

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"Settings.auto_deploy_max_intervals\\\\" at offset 47"}')                      auto_deploy_max_intervals  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"Settings.auto_deploy_max_intervals\\\\" at offset 46"}')                      auto_deploy_max_intervals  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number 9999999999999999999 for field \\\\"Settings.auto_deploy_max_intervals\\\\" at offset 62"}')  auto_deploy_max_intervals  9999999999999999999
   ('code=400', 'error={"message":"Auto Deploy Max Intervals must be greater than 0"}')                                                                                                             auto_deploy_max_intervals  0
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"Settings.auto_deploy_max_intervals\\\\" at offset 45"}')                   auto_deploy_max_intervals  -1 

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected float64, but got string for field \\\\"Settings.auto_deploy_offset_sec\\\\" at offset 44"}')  auto_deploy_offset_sec  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected float64, but got string for field \\\\"Settings.auto_deploy_offset_sec\\\\" at offset 43"}')  auto_deploy_offset_sec  x

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      create_app_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       create_app_inst_timeout  1
   ('code=400', 'error={"message":"Create App Inst Timeout must be greater than 0s"}')                                                                               create_app_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999999999999999s\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   create_app_inst_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      update_app_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       update_app_inst_timeout  1
   ('code=400', 'error={"message":"Update App Inst Timeout must be greater than 0s"}')                                                                               update_app_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999999999999999s\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   update_app_inst_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      delete_app_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       delete_app_inst_timeout  1
   ('code=400', 'error={"message":"Delete App Inst Timeout must be greater than 0s"}')                                                                               delete_app_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999999999999999s\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   delete_app_inst_timeout  99999999999999999999s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      create_cluster_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       create_cluster_inst_timeout  1
   ('code=400', 'error={"message":"Create Cluster Inst Timeout must be greater than 0s"}')                                                                           create_cluster_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999999999999999s\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   create_cluster_inst_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      update_cluster_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       update_cluster_inst_timeout  1
   ('code=400', 'error={"message":"Update Cluster Inst Timeout must be greater than 0s"}')                                                                           update_cluster_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999999999999999s\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   update_cluster_inst_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      delete_cluster_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       delete_cluster_inst_timeout  1
   ('code=400', 'error={"message":"Delete Cluster Inst Timeout must be greater than 0s"}')                                                                           delete_cluster_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999999999999999s\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   delete_cluster_inst_timeout  99999999999999999999s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      create_cloudlet_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       create_cloudlet_timeout  1
   ('code=400', 'error={"message":"Create Cloudlet Timeout must be greater than 0s"}')                                                                               create_cloudlet_timeout  0s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999999999999999s\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   create_cloudlet_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      update_cloudlet_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       update_cloudlet_timeout  1
   ('code=400', 'error={"message":"Update Cloudlet Timeout must be greater than 0s"}')                                                                               update_cloudlet_timeout  0s
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999999999999999s\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   update_cloudlet_timeout  99999999999999999999s

   ('code=400', 'error={"message":"Flavor must preexist"}')  master_node_flavor  xx

# these have been removed from settings
#   ('code=400', 'error={"message":"Load Balancer Max Port Range must be greater than 0"}  load_balancer_max_port_range  0
#   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=string, field=Settings.load_balancer_max_port_range, offset=49"}')  load_balancer_max_port_range  x
#   ('code=400', 'error={"message":"Load Balancer Max Port Range must be greater than 0"}  load_balancer_max_port_range  -1
#   ('code=400', 'error={"message":"Load Balancer Max Port Range must be less than 65536"}')  load_balancer_max_port_range  70000 
#   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=number 99999999999999999, field=Settings.load_balancer_max_port_range, offset=63"}')  load_balancer_max_port_range  99999999999999999 

   ('code=400', 'error={"message":"Max Tracked Dme Clients must be greater than 0"}')                                                                                                                      max_tracked_dme_clients  0
   ('code=400', 'error={"message":"Max Tracked Dme Clients must be greater than 0"}')                                                                                                                      max_tracked_dme_clients  -1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int32, but got string for field \\\\"Settings.max_tracked_dme_clients\\\\" at offset 44"}\')                               max_tracked_dme_clients  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int32, but got number 9999999999999999999999999999 for field \\\\"Settings.max_tracked_dme_clients\\\\" at offset 69"}\')  max_tracked_dme_clients  9999999999999999999999999999
 
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          chef_client_interval  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')         chef_client_interval  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          chef_client_interval  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')  chef_client_interval  99999999h
   ('code=400', 'error={"message":"Chef Client Interval must be greater than 0s"}')                                                                     chef_client_interval  0s
   ('code=400', 'error={"message":"Chef Client Interval must be greater than 0s"}')                                                                     chef_client_interval  -1s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       influx_db_metrics_retention  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      influx_db_metrics_retention  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       influx_db_metrics_retention  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               influx_db_metrics_retention  99999999h
   #('code=400', 'error={"message":"Shepherd Metrics Collection Interval must be greater than 0"}')                                                                  influx_db_metrics_retention  0s      # now supported
   ('code=400', 'error={"message":"Error parsing query: found -, expected duration at line 1, char 65"}')                                                            influx_db_metrics_retention  -1s
   ('code=400', 'error={"message":"Retention policy duration must be at least 1h0m0s"}')                                                                             influx_db_metrics_retention  1s
   #('code=400', 'error={"message":"Retention policy duration must be at least 1h0m0s"}')                                                                            influx_db_metrics_retention  1h0m0s  # now supported
   ('code=400', 'error={"message":"Retention policy duration must be at least 1h0m0s"}')                                                                             influx_db_metrics_retention  0h59m0s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       influx_db_cloudlet_usage_metrics_retention  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                      influx_db_cloudlet_usage_metrics_retention  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')                       influx_db_cloudlet_usage_metrics_retention  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               influx_db_cloudlet_usage_metrics_retention  99999999h
   ('code=400', 'error={"message":"Error parsing query: found -, expected duration at line 1, char 97"}')                                                            influx_db_cloudlet_usage_metrics_retention  -1s
   ('code=400', 'error={"message":"Retention policy duration must be at least 1h0m0s"}')                                                                             influx_db_cloudlet_usage_metrics_retention  1s
   ('code=400', 'error={"message":"Retention policy duration must be at least 1h0m0s"}')                                                                             influx_db_cloudlet_usage_metrics_retention  0h59m0s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               cloudlet_maintenance_timeout  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')              cloudlet_maintenance_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               cloudlet_maintenance_timeout  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')       cloudlet_maintenance_timeout  99999999h
   ('code=400', 'error={"message":"Cloudlet Maintenance Timeout must be greater than 0s"}')                                                                  cloudlet_maintenance_timeout  0s
   ('code=400', 'error={"message":"Cloudlet Maintenance Timeout must be greater than 0s"}')                                                                  cloudlet_maintenance_timeout  -1s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               update_vm_pool_timeout  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')              update_vm_pool_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               update_vm_pool_timeout  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')       update_vm_pool_timeout  99999999h
   ('code=400', 'error={"message":"Update Vm Pool Timeout must be greater than 0s"}')                                                                        update_vm_pool_timeout  0s
   ('code=400', 'error={"message":"Update Vm Pool Timeout must be greater than 0s"}')                                                                        update_vm_pool_timeout  -1s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               update_trust_policy_timeout  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')              update_trust_policy_timeout  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               update_trust_policy_timeout  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')       update_trust_policy_timeout  99999999h
   ('code=400', 'error={"message":"Update Trust Policy Timeout must be greater than 0s"}')                                                                   update_trust_policy_timeout  0s
   ('code=400', 'error={"message":"Update Trust Policy Timeout must be greater than 0s"}')                                                                   update_trust_policy_timeout  -1s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               dme_api_metrics_collection_interval  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')              dme_api_metrics_collection_interval  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               dme_api_metrics_collection_interval  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')       dme_api_metrics_collection_interval  99999999h
   ('code=400', 'error={"message":"Dme Api Metrics Collection Interval must be greater than 0s"}')                                                           dme_api_metrics_collection_interval  0s
   ('code=400', 'error={"message":"Dme Api Metrics Collection Interval must be greater than 0s"}')                                                           dme_api_metrics_collection_interval  -1s

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               edge_events_metrics_collection_interval  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')              edge_events_metrics_collection_interval  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')               edge_events_metrics_collection_interval  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')       edge_events_metrics_collection_interval  99999999h
   ('code=400', 'error={"message":"Edge Events Metrics Collection Interval must be greater than 0s"}')                                                       edge_events_metrics_collection_interval  0s
   ('code=400', 'error={"message":"Edge Events Metrics Collection Interval must be greater than 0s"}')                                                       edge_events_metrics_collection_interval  -1s
   ('code=400', 'error={"message":"All EdgeEvents continuous query collection intervals must be greater than the EdgeEventsMetricsCollectionInterval"}')     edge_events_metrics_collection_interval  1000h

   ('code=400', 'error={"message":"All EdgeEvents continuous query collection intervals must be greater than the EdgeEventsMetricsCollectionInterval"}')     edge_events_metrics_continuous_queries_collection_intervals  ${collection_intervals}

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')              cleanup_reservable_auto_cluster_idletime  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')             cleanup_reservable_auto_cluster_idletime  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')              cleanup_reservable_auto_cluster_idletime  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')      cleanup_reservable_auto_cluster_idletime  99999999h
   ('code=400', 'error={"message":"Cleanup Reservable Auto Cluster Idletime must be greater than 30s"}')                                                    cleanup_reservable_auto_cluster_idletime  0s
   ('code=400', 'error={"message":"Cleanup Reservable Auto Cluster Idletime must be greater than 30s"}')                                                    cleanup_reservable_auto_cluster_idletime  -1s

   ('code=400', 'error={"message":"Location Tile Side Length Km must be greater than 0"}')               location_tile_side_length_km  0
   ('code=400', 'error={"message":"Location Tile Side Length Km must be greater than 0"}')               location_tile_side_length_km  -1
   ValueError: invalid literal for int() with base 10: 'x'                                               location_tile_side_length_km  x
   ValueError: invalid literal for int() with base 10: '1h'                                              location_tile_side_length_km  1h

   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')           appinst_client_cleanup_interval  1
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"1x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')          appinst_client_cleanup_interval  1x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')           appinst_client_cleanup_interval  x
   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"99999999h\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}\')   appinst_client_cleanup_interval  99999999h
   ('code=400', 'error={"message":"Appinst Client Cleanup Interval must be greater than 2s"}')                                                           appinst_client_cleanup_interval  0s
   ('code=400', 'error={"message":"Appinst Client Cleanup Interval must be greater than 2s"}')                                                           appinst_client_cleanup_interval  1s
   ('code=400', 'error={"message":"Appinst Client Cleanup Interval must be greater than 2s"}')                                                           appinst_client_cleanup_interval  -1s

# ECQ-2991
Settings - user shall be able to reset the settings
   [Documentation]
   ...  - send ResetSettings 
   ...  - verify settings are reset

   [Tags]  ReservableCluster

   # fixed EDGECLOUD-4156     ResetSettings removes the influxdbmetricsretention setting

   ${settings}=   Show Settings  region=${region}

   [Teardown]  Cleanup Settings  ${settings}

   FOR  ${key}  IN  @{settings.keys()}
      log to console  ${key} ${settings['${key}']}
   END

   Reset Settings  region=${region}

   ${settings_post}=   Show Settings  region=${region}

   Should Be Equal             ${settings_post['shepherd_alert_evaluation_interval']}    15s
   Should Be Equal             ${settings_post['shepherd_health_check_interval']}        5s
   Should Be Equal As Numbers  ${settings_post['shepherd_health_check_retries']}         3
   Should Be Equal             ${settings_post['shepherd_metrics_collection_interval']}  5s

   Should Be Equal As Numbers  ${settings_post['auto_deploy_interval_sec']}       300
   Should Be Equal As Numbers  ${settings_post['auto_deploy_max_intervals']}      10
   Should Be Equal As Numbers  ${settings_post['auto_deploy_offset_sec']}         20

   Should Be Equal  ${settings_post['create_cloudlet_timeout']}      30m0s
   Should Be Equal  ${settings_post['update_cloudlet_timeout']}      20m0s
   Should Be Equal  ${settings_post['create_app_inst_timeout']}      30m0s
   Should Be Equal  ${settings_post['update_app_inst_timeout']}      30m0s
   Should Be Equal  ${settings_post['delete_app_inst_timeout']}      20m0s
   Should Be Equal  ${settings_post['create_cluster_inst_timeout']}  30m0s
   Should Be Equal  ${settings_post['update_cluster_inst_timeout']}  20m0s
   Should Be Equal  ${settings_post['delete_cluster_inst_timeout']}  20m0s

   Should Not Contain          ${settings_post}  master_node_flavor

#   Should Be Equal As Numbers  ${settings_post['load_balancer_max_port_range']}                        50
   Should Be Equal As Numbers  ${settings_post['max_tracked_dme_clients']}                             100
   Should Be Equal             ${settings_post['chef_client_interval']}                                10m0s
   Should Be Equal             ${settings_post['cloudlet_maintenance_timeout']}                        5m0s
   Should Be Equal             ${settings_post['update_vm_pool_timeout']}                              20m0s
   Should Be Equal             ${settings_post['update_trust_policy_timeout']}                         10m0s
   Should Be Equal             ${settings_post['dme_api_metrics_collection_interval']}                 30s
   Should Be Equal             ${settings_post['edge_events_metrics_collection_interval']}   1h0m0s
   Should Be Equal             ${settings_post['edge_events_metrics_continuous_queries_collection_intervals'][0]['interval']}   24h0m0s
   Should Be Equal             ${settings_post['edge_events_metrics_continuous_queries_collection_intervals'][1]['interval']}   168h0m0s  
   Should Be Equal             ${settings_post['edge_events_metrics_continuous_queries_collection_intervals'][2]['interval']}   672h0m0s 
   Should Be Equal             ${settings_post['influx_db_metrics_retention']}                         672h0m0s
   Should Be Equal             ${settings_post['influx_db_cloudlet_usage_metrics_retention']}          8760h0m0s
   Should Be Equal             ${settings_post['influx_db_downsampled_metrics_retention']}          8760h0m0s
   Should Be Equal             ${settings_post['influx_db_edge_events_metrics_retention']}          672h0m0s
   Should Be Equal             ${settings_post['cleanup_reservable_auto_cluster_idletime']}            30m0s
   Should Be Equal             ${settings_post['appinst_client_cleanup_interval']}            24h0m0s

   Should Be Equal As Numbers  ${settings_post['cluster_auto_scale_averaging_duration_sec']}  60
   Should Be Equal             ${settings_post['cluster_auto_scale_retry_delay']}  1m0s
   Should Be Equal             ${settings_post['alert_policy_min_trigger_time']}  30s
   Should Not Contain          ${settings_post}  disable_rate_limit
   Should Be Equal As Numbers  ${settings_post['max_num_per_ip_rate_limiters']}  10000

   Should Be Equal             ${settings_post['alert_policy_min_trigger_time']}  30s

   Should Be Equal             ${settings_post['resource_snapshot_thread_interval']}  10m0s

*** Keywords ***
Cleanup Settings
   [Arguments]  ${settings}

   Update Settings  region=${region}  master_node_flavor=${master_node_flavor_default}
   Update Settings  region=${region}  influx_db_metrics_retention=120h0m0s
   Update Settings  region=${region}  influx_db_cloudlet_usage_metrics_retention=120h0m0s

   FOR  ${key}  IN  @{settings.keys()}
      @{int_list}=  Run Keyword If  '${key}' == 'edge_events_metrics_continuous_queries_collection_intervals'  Create List  ${settings['${key}'][0]['interval']}  ${settings['${key}'][1]['interval']}  ${settings['${key}'][2]['interval']}
      Run Keyword If  '${key}' == 'edge_events_metrics_continuous_queries_collection_intervals'  Update Settings  region=${region}  ${key}=${int_list} 
      ...  ELSE  Update Settings  region=${region}  ${key}=${settings['${key}']}
   END

   Update Settings  region=${region}  master_node_flavor=${master_node_flavor_default}
   Update Settings  region=${region}  influx_db_metrics_retention=120h0m0s
   Update Settings  region=${region}  influx_db_cloudlet_usage_metrics_retention=120h0m0s
   Update Settings  region=${region}  disable_rate_limit=${False}

Fail Create UpdateSettings
   [Arguments]  ${error_msg}  ${parm}  ${value}
   log to console  ${parm}
   ${std_create}=  Run Keyword and Expect Error  *  Update Settings  region=${region}  ${parm}=${value}
   Should Contain Any  ${std_create}  ${error_msg}

