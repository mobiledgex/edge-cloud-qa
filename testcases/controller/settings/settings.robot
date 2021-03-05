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
   Should Contain  ${settings}  create_app_inst_timeout
   Should Contain  ${settings}  create_cluster_inst_timeout
   Should Contain  ${settings}  delete_app_inst_timeout
   Should Contain  ${settings}  delete_cluster_inst_timeout
   Should Contain  ${settings}  influx_db_metrics_retention
   Should Contain  ${settings}  load_balancer_max_port_range
   Should Contain  ${settings}  master_node_flavor
   Should Contain  ${settings}  max_tracked_dme_clients
   Should Contain  ${settings}  shepherd_alert_evaluation_interval
   Should Contain  ${settings}  shepherd_health_check_interval
   Should Contain  ${settings}  shepherd_health_check_retries
   Should Contain  ${settings}  shepherd_metrics_collection_interval
   Should Contain  ${settings}  update_app_inst_timeout
   Should Contain  ${settings}  update_cluster_inst_timeout
   Should Contain  ${settings}  update_vm_pool_timeout
   Should Contain  ${settings}  update_trust_policy_timeout
   Should Contain  ${settings}  dme_api_metrics_collection_interval 
   Should Contain  ${settings}  persistent_connection_metrics_collection_interval 
   Should Contain  ${settings}  cleanup_reservable_auto_cluster_idletime

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
   Update Settings  region=${region}  shepherd_alert_evaluation_interval=1s 
   Update Settings  region=${region}  shepherd_health_check_retries=1 
   Update Settings  region=${region}  shepherd_health_check_interval=1s 

   Update Settings  region=${region}  influx_db_metrics_retention=0h0m0s

   Update Settings  region=${region}  auto_deploy_interval_sec=1   auto_deploy_offset_sec=1  auto_deploy_max_intervals=1

   Update Settings  region=${region}  create_app_inst_timeout=1m0s  update_app_inst_timeout=1m0s  delete_app_inst_timeout=1m0s  create_cluster_inst_timeout=1m0s   update_cluster_inst_timeout=1m0s   delete_cluster_inst_timeout=1m0s

   Update Settings  region=${region}  master_node_flavor=x1.medium  load_balancer_max_port_range=1  max_tracked_dme_clients=1  chef_client_interval=1m0s  influx_db_metrics_retention=1h0m0s  cloudlet_maintenance_timeout=1s  update_vm_pool_timeout=1s

   Update Settings  region=${region}  update_trust_policy_timeout=1s  dme_api_metrics_collection_interval=1s  persistent_connection_metrics_collection_interval=1s  cleanup_reservable_auto_cluster_idletime=1s

   ${settings_post}=   Show Settings  region=${region}

   Should Be Equal             ${settings_post['shepherd_metrics_collection_interval']}  1s
   Should Be Equal             ${settings_post['shepherd_alert_evaluation_interval']}    1s
   Should Be Equal As Numbers  ${settings_post['shepherd_health_check_retries']}         1
   Should Be Equal             ${settings_post['shepherd_health_check_interval']}        1s

   Should Be Equal As Numbers  ${settings_post['auto_deploy_interval_sec']}       1
   Should Be Equal As Numbers  ${settings_post['auto_deploy_max_intervals']}      1
   Should Be Equal As Numbers  ${settings_post['auto_deploy_offset_sec']}         1

   Should Be Equal  ${settings_post['create_app_inst_timeout']}      1m0s  
   Should Be Equal  ${settings_post['update_app_inst_timeout']}      1m0s
   Should Be Equal  ${settings_post['delete_app_inst_timeout']}      1m0s
   Should Be Equal  ${settings_post['create_cluster_inst_timeout']}  1m0s
   Should Be Equal  ${settings_post['update_cluster_inst_timeout']}  1m0s
   Should Be Equal  ${settings_post['delete_cluster_inst_timeout']}  1m0s

   Should Be Equal             ${settings_post['master_node_flavor']}            x1.medium 
   Should Be Equal As Numbers  ${settings_post['load_balancer_max_port_range']}  1  
   Should Be Equal As Numbers  ${settings_post['max_tracked_dme_clients']}       1  
   Should Be Equal             ${settings_post['chef_client_interval']}          1m0s  
   Should Be Equal             ${settings_post['influx_db_metrics_retention']}   1h0m0s 
   Should Be Equal             ${settings_post['cloudlet_maintenance_timeout']}  1s
   Should Be Equal             ${settings_post['update_vm_pool_timeout']}        1s
   Should Be Equal             ${settings_post['update_trust_policy_timeout']}   1s

   Should Be Equal             ${settings_post['dme_api_metrics_collection_interval']}   1s
   Should Be Equal             ${settings_post['persistent_connection_metrics_collection_interval']}   1s
   Should Be Equal             ${settings_post['cleanup_reservable_auto_cluster_idletime']}   1s

# ECQ-2990
Settings - UpdateSettings with bad parms shall return error
   [Documentation]
   ...  - call UpdateSettings for each setting with various errors
   ...  - verify error is received

   [Tags]  ReservableCluster

   # EDGECLOUD-4164 	UpdateSettings for autodeployintervalsec with large values give wrong error message 
   # fixed EDGECLOUD-4167 	UpdateSettings for loadbalancermaxportrange should only allow valid values 
   # fixed EDGECLOUD-4168 	UpdateSettings for maxtrackeddmeclients should only allow valid values 
   # fixed EDGECLOUD-4169 	UpdateSettings for chefclientinterval should only allow valid values 
   # fixed EDGECLOUD-4163 	UpdateSettings for influxdbmetricsretention should give better error message 
   [Template]  Fail Create UpdateSettings 
   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')  shepherd_metrics_collection_interval  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  shepherd_metrics_collection_interval  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')  shepherd_metrics_collection_interval  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')  shepherd_metrics_collection_interval  99999999h 
   ('code=400', 'error={"message":"Shepherd Metrics Collection Interval must be greater than 0"}')  shepherd_metrics_collection_interval  0s
   ('code=400', 'error={"message":"Shepherd Metrics Collection Interval must be greater than 0"}')  shepherd_metrics_collection_interval  -1s

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')  shepherd_alert_evaluation_interval  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  shepherd_alert_evaluation_interval  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')  shepherd_alert_evaluation_interval  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')  shepherd_alert_evaluation_interval  99999999h
   ('code=400', 'error={"message":"Shepherd Alert Evaluation Interval must be greater than 0"}')  shepherd_alert_evaluation_interval  0s
   ('code=400', 'error={"message":"Shepherd Alert Evaluation Interval must be greater than 0"}')  shepherd_alert_evaluation_interval  -1s 

   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=string, field=Settings.shepherd_health_check_retries, offset=51"}')  shepherd_health_check_retries  1x
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=string, field=Settings.shepherd_health_check_retries, offset=50"}')  shepherd_health_check_retries  x
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=number 9999999999999999999, field=Settings.shepherd_health_check_retries, offset=66"}')  shepherd_health_check_retries  9999999999999999999
   ('code=400', 'error={"message":"Shepherd Health Check Retries must be greater than 0"}')  shepherd_health_check_retries  0
   ('code=400', 'error={"message":"Shepherd Health Check Retries must be greater than 0"}')  shepherd_health_check_retries  -1 

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')  shepherd_health_check_interval  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  shepherd_health_check_interval  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')  shepherd_health_check_interval  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')  shepherd_health_check_interval  99999999h
   ('code=400', 'error={"message":"Shepherd Health Check Interval must be greater than 0"}')  shepherd_health_check_interval  0s
   ('code=400', 'error={"message":"Shepherd Health Check Interval must be greater than 0"}')  shepherd_health_check_interval  -1s 

   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=float64, got=string, field=Settings.auto_deploy_interval_sec, offset=46"}')  auto_deploy_interval_sec  1x
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=float64, got=string, field=Settings.auto_deploy_interval_sec, offset=45"}')  auto_deploy_interval_sec  x
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=number 9999999999999999999, field=Settings.shepherd_health_check_retries, offset=66"}')  auto_deploy_interval_sec  9999999999999999999
   ('code=400', 'error={"message":"Auto Deploy Interval Sec must be greater than 0"}')  auto_deploy_interval_sec  0
   ('code=400', 'error={"message":"Auto Deploy Interval Sec must be greater than 0"}')  auto_deploy_interval_sec  -1 

   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=uint32, got=string, field=Settings.auto_deploy_max_intervals, offset=47"}')  auto_deploy_max_intervals  1x
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=uint32, got=string, field=Settings.auto_deploy_max_intervals, offset=46"}')  auto_deploy_max_intervals  x
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=uint32, got=number 9999999999999999999, field=Settings.auto_deploy_max_intervals, offset=62"}')  auto_deploy_max_intervals  9999999999999999999
   ('code=400', 'error={"message":"Auto Deploy Max Intervals must be greater than 0"}')  auto_deploy_max_intervals  0
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=uint32, got=number -1, field=Settings.auto_deploy_max_intervals, offset=45"}')  auto_deploy_max_intervals  -1 

   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=float64, got=string, field=Settings.auto_deploy_offset_sec, offset=44"}')  auto_deploy_offset_sec  1x
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=float64, got=string, field=Settings.auto_deploy_offset_sec, offset=43"}')  auto_deploy_offset_sec  x

   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  create_app_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               create_app_inst_timeout  1
   ('code=400', 'error={"message":"Create App Inst Timeout must be greater than 0"}')                              create_app_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999999999999999s\\\\""}')   create_app_inst_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  update_app_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               update_app_inst_timeout  1
   ('code=400', 'error={"message":"Update App Inst Timeout must be greater than 0"}')                              update_app_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999999999999999s\\\\""}')   update_app_inst_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  delete_app_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               delete_app_inst_timeout  1
   ('code=400', 'error={"message":"Delete App Inst Timeout must be greater than 0"}')                              delete_app_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999999999999999s\\\\""}')   delete_app_inst_timeout  99999999999999999999s

   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  create_cluster_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               create_cluster_inst_timeout  1
   ('code=400', 'error={"message":"Create Cluster Inst Timeout must be greater than 0"}')                          create_cluster_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999999999999999s\\\\""}')   create_cluster_inst_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  update_cluster_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               update_cluster_inst_timeout  1
   ('code=400', 'error={"message":"Update Cluster Inst Timeout must be greater than 0"}')                          update_cluster_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999999999999999s\\\\""}')   update_cluster_inst_timeout  99999999999999999999s
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  delete_cluster_inst_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               delete_cluster_inst_timeout  1
   ('code=400', 'error={"message":"Delete Cluster Inst Timeout must be greater than 0"}')                          delete_cluster_inst_timeout  0s
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999999999999999s\\\\""}')   delete_cluster_inst_timeout  99999999999999999999s

   ('code=400', 'error={"message":"Flavor must preexist"}')  master_node_flavor  xx

   ('code=400', 'error={"message":"Load Balancer Max Port Range must be greater than 0"}  load_balancer_max_port_range  0
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=string, field=Settings.load_balancer_max_port_range, offset=49"}')  load_balancer_max_port_range  x
   ('code=400', 'error={"message":"Load Balancer Max Port Range must be greater than 0"}  load_balancer_max_port_range  -1
   ('code=400', 'error={"message":"Load Balancer Max Port Range must be less than 65536"}')  load_balancer_max_port_range  70000 
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=number 99999999999999999, field=Settings.load_balancer_max_port_range, offset=63"}')  load_balancer_max_port_range  99999999999999999 

   ('code=400', 'error={"message":"Max Tracked Dme Clients must be greater than 0"}')  max_tracked_dme_clients  0
   ('code=400', 'error={"message":"Max Tracked Dme Clients must be greater than 0"}')  max_tracked_dme_clients  -1
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=string, field=Settings.max_tracked_dme_clients, offset=44"}')                               max_tracked_dme_clients  x
   ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=number 9999999999999999999999999999, field=Settings.max_tracked_dme_clients, offset=69"}')  max_tracked_dme_clients  9999999999999999999999999999
 
   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')  chef_client_interval  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  chef_client_interval  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')  chef_client_interval  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')  chef_client_interval  99999999h
   ('code=400', 'error={"message":"Chef Client Interval must be greater than 0"}')  chef_client_interval  0s
   ('code=400', 'error={"message":"Chef Client Interval must be greater than 0"}')  chef_client_interval  -1s

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               influx_db_metrics_retention  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  influx_db_metrics_retention  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')                       influx_db_metrics_retention  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')               influx_db_metrics_retention  99999999h
   #('code=400', 'error={"message":"Shepherd Metrics Collection Interval must be greater than 0"}')                 influx_db_metrics_retention  0s      # now supported
   ('code=400', 'error={"message":"Error parsing query: found -, expected duration at line 1, char 61"}')          influx_db_metrics_retention  -1s
   ('code=400', 'error={"message":"Retention policy duration must be at least 1h0m0s"}')                           influx_db_metrics_retention  1s
   #('code=400', 'error={"message":"Retention policy duration must be at least 1h0m0s"}')                           influx_db_metrics_retention  1h0m0s  # now supported
   ('code=400', 'error={"message":"Retention policy duration must be at least 1h0m0s"}')                           influx_db_metrics_retention  0h59m0s

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               cloudlet_maintenance_timeout  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  cloudlet_maintenance_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')                       cloudlet_maintenance_timeout  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')               cloudlet_maintenance_timeout  99999999h
   ('code=400', 'error={"message":"Cloudlet Maintenance Timeout must be greater than 0"}')                         cloudlet_maintenance_timeout  0s
   ('code=400', 'error={"message":"Cloudlet Maintenance Timeout must be greater than 0"}')                         cloudlet_maintenance_timeout  -1s

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               update_vm_pool_timeout  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  update_vm_pool_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')                       update_vm_pool_timeout  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')               update_vm_pool_timeout  99999999h
   ('code=400', 'error={"message":"Update Vm Pool Timeout must be greater than 0"}')                               update_vm_pool_timeout  0s
   ('code=400', 'error={"message":"Update Vm Pool Timeout must be greater than 0"}')                               update_vm_pool_timeout  -1s

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               update_trust_policy_timeout  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  update_trust_policy_timeout  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')                       update_trust_policy_timeout  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')               update_trust_policy_timeout  99999999h
   ('code=400', 'error={"message":"Update Trust Policy Timeout must be greater than 0"}')                          update_trust_policy_timeout  0s
   ('code=400', 'error={"message":"Update Trust Policy Timeout must be greater than 0"}')                          update_trust_policy_timeout  -1s

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               dme_api_metrics_collection_interval  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  dme_api_metrics_collection_interval  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')                       dme_api_metrics_collection_interval  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')               dme_api_metrics_collection_interval  99999999h
   ('code=400', 'error={"message":"Dme Api Metrics Collection Interval must be greater than 0"}')                  dme_api_metrics_collection_interval  0s
   ('code=400', 'error={"message":"Dme Api Metrics Collection Interval must be greater than 0"}')                  dme_api_metrics_collection_interval  -1s

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               persistent_connection_metrics_collection_interval  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  persistent_connection_metrics_collection_interval  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')                       persistent_connection_metrics_collection_interval  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')               persistent_connection_metrics_collection_interval  99999999h
   ('code=400', 'error={"message":"Persistent Connection Metrics Collection Interval must be greater than 0"}')    persistent_connection_metrics_collection_interval  0s
   ('code=400', 'error={"message":"Persistent Connection Metrics Collection Interval must be greater than 0"}')    persistent_connection_metrics_collection_interval  -1s

   ('code=400', 'error={"message":"Invalid POST data, time: missing unit in duration \\\\"1\\\\""}')               cleanup_reservable_auto_cluster_idletime  1
   ('code=400', 'error={"message":"Invalid POST data, time: unknown unit \\\\"x\\\\" in duration \\\\"1x\\\\""}')  cleanup_reservable_auto_cluster_idletime  1x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"x\\\\""}')                       cleanup_reservable_auto_cluster_idletime  x
   ('code=400', 'error={"message":"Invalid POST data, time: invalid duration \\\\"99999999h\\\\""}')               cleanup_reservable_auto_cluster_idletime  99999999h
   ('code=400', 'error={"message":"Cleanup Reservable Auto Cluster Idletime must be greater than 0"}')             cleanup_reservable_auto_cluster_idletime  0s
   ('code=400', 'error={"message":"Cleanup Reservable Auto Cluster Idletime must be greater than 0"}')             cleanup_reservable_auto_cluster_idletime  -1s

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

   Should Be Equal  ${settings_post['create_app_inst_timeout']}      30m0s
   Should Be Equal  ${settings_post['update_app_inst_timeout']}      30m0s
   Should Be Equal  ${settings_post['delete_app_inst_timeout']}      20m0s
   Should Be Equal  ${settings_post['create_cluster_inst_timeout']}  30m0s
   Should Be Equal  ${settings_post['update_cluster_inst_timeout']}  20m0s
   Should Be Equal  ${settings_post['delete_cluster_inst_timeout']}  20m0s

   Should Not Contain          ${settings_post}  master_node_flavor

   Should Be Equal As Numbers  ${settings_post['load_balancer_max_port_range']}                        50
   Should Be Equal As Numbers  ${settings_post['max_tracked_dme_clients']}                             100
   Should Be Equal             ${settings_post['chef_client_interval']}                                10m0s
   Should Be Equal             ${settings_post['cloudlet_maintenance_timeout']}                        5m0s
   Should Be Equal             ${settings_post['update_vm_pool_timeout']}                              20m0s
   Should Be Equal             ${settings_post['update_trust_policy_timeout']}                         10m0s
   Should Be Equal             ${settings_post['dme_api_metrics_collection_interval']}                 30s
   Should Be Equal             ${settings_post['persistent_connection_metrics_collection_interval']}   1h0m0s 
   Should Be Equal             ${settings_post['influx_db_metrics_retention']}                         672h0m0s
   Should Be Equal             ${settings_post['cleanup_reservable_auto_cluster_idletime']}            30m0s

*** Keywords ***
Cleanup Settings
   [Arguments]  ${settings}

   FOR  ${key}  IN  @{settings.keys()}
      Update Settings  region=${region}  ${key}=${settings['${key}']}
   END

   Update Settings  region=${region}  master_node_flavor=${master_node_flavor_default}
   Update Settings  region=${region}  influx_db_metrics_retention=120h0m0s

   #Update Settings  region=${region}  @{parms_all}
   
Fail Create UpdateSettings
   [Arguments]  ${error_msg}  ${parm}  ${value}
   log to console  ${parm}
   ${std_create}=  Run Keyword and Expect Error  *  Update Settings  region=${region}  ${parm}=${value}
   Should Contain Any  ${std_create}  ${error_msg}

