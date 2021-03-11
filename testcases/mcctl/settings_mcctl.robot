*** Settings ***
Documentation  ShowSettings mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-2984
Settings - mcctl shall be able to show the settings
   [Documentation]
   ...  - send ShowSettings via mcctl
   ...  - verify settings are returned

   ${settings}=  Run mcctl  region ShowSettings region=${region} 

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

# ECQ-2985
Settings - mcctl shall be able to update the settings
   [Documentation]
   ...  - send UpdateSettings via mcctl
   ...  - verify settings are updated

   ${settings}=  Run mcctl  region ShowSettings region=${region} 
   [Teardown]  Cleanup Settings  ${settings}

   Run mcctl  region UpdateSettings region=${region} shepherdmetricscollectioninterval=1s
   Run mcctl  region UpdateSettings region=${region} shepherdalertevaluationinterval=1s
   Run mcctl  region UpdateSettings region=${region} shepherdhealthcheckretries=1
   Run mcctl  region UpdateSettings region=${region} shepherdhealthcheckinterval=1s
   Run mcctl  region UpdateSettings region=${region} autodeployintervalsec=1 autodeployoffsetsec=1 autodeploymaxintervals=1
   Run mcctl  region UpdateSettings region=${region} createappinsttimeout=1m0s updateappinsttimeout=1m0s deleteappinsttimeout=1m0s createclusterinsttimeout=1m0s updateclusterinsttimeout=1m0s deleteclusterinsttimeout=1m0s
   Run mcctl  region UpdateSettings region=${region} masternodeflavor=x1.medium loadbalancermaxportrange=1 maxtrackeddmeclients=1 chefclientinterval=1m0s influxdbmetricsretention=100h0m0s cloudletmaintenancetimeout=1s updatevmpooltimeout=1s

   ${settings_post}=  Run mcctl  region ShowSettings region=${region}

   Should Be Equal             ${settings_post['shepherd_alert_evaluation_interval']}    1s
   Should Be Equal             ${settings_post['shepherd_health_check_interval']}        1s
   Should Be Equal As Numbers  ${settings_post['shepherd_health_check_retries']}         1
   Should Be Equal             ${settings_post['shepherd_metrics_collection_interval']}  1s

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
   Should Be Equal             ${settings_post['influx_db_metrics_retention']}   100h0m0s
   Should Be Equal             ${settings_post['cloudlet_maintenance_timeout']}  1s
   Should Be Equal             ${settings_post['update_vm_pool_timeout']}        1s

# ECQ-2986
Settings - mcctl shall handle update settings failures
   [Documentation]
   ...  - send UpdateSettings via mcctl with various error cases
   ...  - verify proper error is received

   # EDGECLOUD-4164 	UpdateSettings for autodeployintervalsec with large values give wrong error message 
   # EDGECLOUD-4167 	UpdateSettings for loadbalancermaxportrange should only allow valid values  - closed
   # EDGECLOUD-4168 	UpdateSettings for maxtrackeddmeclients should only allow valid values - closed
   # EDGECLOUD-4169 	UpdateSettings for chefclientinterval should only allow valid values  - closed
   # EDGECLOUD-4163 	UpdateSettings for influxdbmetricsretention should give better error message - closed

   [Template]  Fail UpdateSettings Via mcctl
      error decoding \\\'Settings.ShepherdMetricsCollectionInterval\\\': time: missing unit in duration "1"       shepherdmetricscollectioninterval=1
      error decoding \\\'Settings.ShepherdMetricsCollectionInterval\\\': time: unknown unit "x" in duration "1x"  shepherdmetricscollectioninterval=1x
      error decoding \\\'Settings.ShepherdMetricsCollectionInterval\\\': time: invalid duration "x"               shepherdmetricscollectioninterval=x
      Shepherd Metrics Collection Interval must be greater than 0                                                 shepherdmetricscollectioninterval=0s

      error decoding \\\'Settings.ShepherdAlertEvaluationInterval\\\': time: missing unit in duration "1"       shepherdalertevaluationinterval=1
      error decoding \\\'Settings.ShepherdAlertEvaluationInterval\\\': time: unknown unit "x" in duration "1x"  shepherdalertevaluationinterval=1x
      error decoding \\\'Settings.ShepherdAlertEvaluationInterval\\\': time: invalid duration "x"               shepherdalertevaluationinterval=x
      Shepherd Alert Evaluation Interval must be greater than 0                                                 shepherdalertevaluationinterval=0s

      Unable to parse "shepherdhealthcheckretries" value "1x" as int: invalid syntax                                shepherdhealthcheckretries=1x
      Unable to parse "shepherdhealthcheckretries" value "9999999999999999999999999999" as int: value out of range  shepherdhealthcheckretries=9999999999999999999999999999
      Shepherd Health Check Retries must be greater than 0                                                          shepherdhealthcheckretries=0

      error decoding \\\'Settings.ShepherdHealthCheckInterval\\\': time: missing unit in duration "1"       shepherdhealthcheckinterval=1
      error decoding \\\'Settings.ShepherdHealthCheckInterval\\\': time: unknown unit "x" in duration "1x"  shepherdhealthcheckinterval=1x
      error decoding \\\'Settings.ShepherdHealthCheckInterval\\\': time: invalid duration "x"               shepherdhealthcheckinterval=x
      Shepherd Health Check Interval must be greater than 0                                                 shepherdhealthcheckinterval=0s

      Unable to parse "autodeployintervalsec" value "x" as float64: invalid syntax  autodeployintervalsec=x
      Unmarshal type error: expected=int32, got=number 9999999999999999999, field=Settings.shepherd_health_check_retries, offset=66"}')  autodeployintervalsec=9999999999999999999
      Auto Deploy Interval Sec must be greater than 0  autodeployintervalsec=0

      Unable to parse "autodeploymaxintervals" value "x" as uint: invalid syntax                        autodeploymaxintervals=x
      Unable to parse "autodeploymaxintervals" value "9999999999999999999" as uint: value out of range  autodeploymaxintervals=9999999999999999999
      Auto Deploy Max Intervals must be greater than 0                                                  autodeploymaxintervals=0

      Unable to parse "autodeployoffsetsec" value "1x" as float64: invalid syntax  autodeployoffsetsec=1x

      error decoding \\\'Settings.CreateAppInstTimeout\\\': time: unknown unit "x" in duration "1x"        createappinsttimeout=1x
      error decoding \\\'Settings.CreateAppInstTimeout\\\': time: missing unit in duration "1"             createappinsttimeout=1
      Create App Inst Timeout must be greater than 0                                                       createappinsttimeout=0s
      error decoding \\\'Settings.CreateAppInstTimeout\\\': time: invalid duration "99999999999999999999s  createappinsttimeout=99999999999999999999s
      error decoding \\\'Settings.UpdateAppInstTimeout\\\': time: unknown unit "x" in duration "1x"        updateappinsttimeout=1x
      error decoding \\\'Settings.UpdateAppInstTimeout\\\': time: missing unit in duration "1"             updateappinsttimeout=1
      Update App Inst Timeout must be greater than 0                                                       updateappinsttimeout=0s
      error decoding \\\'Settings.UpdateAppInstTimeout\\\': time: invalid duration "99999999999999999999s  updateappinsttimeout=99999999999999999999s
      error decoding \\\'Settings.DeleteAppInstTimeout\\\': time: unknown unit "x" in duration "1x"        deleteappinsttimeout=1x
      error decoding \\\'Settings.DeleteAppInstTimeout\\\': time: missing unit in duration "1"             deleteappinsttimeout=1
      Delete App Inst Timeout must be greater than 0                                                       deleteappinsttimeout=0s
      error decoding \\\'Settings.DeleteAppInstTimeout\\\': time: invalid duration "99999999999999999999s  deleteappinsttimeout=99999999999999999999s


      error decoding \\\'Settings.CreateClusterInstTimeout\\\': time: unknown unit "x" in duration "1x"        createclusterinsttimeout=1x
      error decoding \\\'Settings.CreateClusterInstTimeout\\\': time: missing unit in duration "1"             createclusterinsttimeout=1
      Create Cluster Inst Timeout must be greater than 0                                                       createclusterinsttimeout=0s
      error decoding \\\'Settings.CreateClusterInstTimeout\\\': time: invalid duration "99999999999999999999s  createclusterinsttimeout=99999999999999999999s
      error decoding \\\'Settings.UpdateClusterInstTimeout\\\': time: unknown unit "x" in duration "1x"        updateclusterinsttimeout=1x
      error decoding \\\'Settings.UpdateClusterInstTimeout\\\': time: missing unit in duration "1"             updateclusterinsttimeout=1
      Update Cluster Inst Timeout must be greater than 0                                                       updateclusterinsttimeout=0s
      error decoding \\\'Settings.UpdateClusterInstTimeout\\\': time: invalid duration "99999999999999999999s  updateclusterinsttimeout=99999999999999999999s
      error decoding \\\'Settings.DeleteClusterInstTimeout\\\': time: unknown unit "x" in duration "1x"        deleteclusterinsttimeout=1x
      error decoding \\\'Settings.DeleteClusterInstTimeout\\\': time: missing unit in duration "1"             deleteclusterinsttimeout=1
      Delete Cluster Inst Timeout must be greater than 0                                                       deleteclusterinsttimeout=0s
      error decoding \\\'Settings.DeleteClusterInstTimeout\\\': time: invalid duration "99999999999999999999s  deleteclusterinsttimeout=99999999999999999999s

      Flavor must preexist  masternodeflavor=xx

      Load Balancer Max Port Range must be greater than 0  loadbalancermaxportrange=0
      Unable to parse "loadbalancermaxportrange" value "x" as int: invalid syntax  loadbalancermaxportrange=x
      Load Balancer Max Port Range must be greater than 0  loadbalancermaxportrange=-1
      Load Balancer Max Port Range must be less than 65536  loadbalancermaxportrange=70000
      Unable to parse "loadbalancermaxportrange" value "99999999999999999" as int: value out of range  loadbalancermaxportrange=99999999999999999

      Max Tracked Dme Clients must be greater than 0  maxtrackeddmeclients=0
      Max Tracked Dme Clients must be greater than 0  maxtrackeddmeclients=-1
      Unable to parse "maxtrackeddmeclients" value "x" as int: invalid syntax  maxtrackeddmeclients=x

      error decoding \\\'Settings.ChefClientInterval\\\': time: missing unit in duration "1"  chefclientinterval=1
      error decoding \\\'Settings.ChefClientInterval\\\': time: unknown unit "x" in duration "1x"  chefclientinterval=1x
      error decoding \\\'Settings.ChefClientInterval\\\': time: invalid duration "x"  chefclientinterval=x
      Chef Client Interval must be greater than 0  chefclientinterval=-1s

      error decoding \\\'Settings.InfluxDbMetricsRetention\\\': time: missing unit in duration "1"  influxdbmetricsretention=1
      error decoding \\\'Settings.InfluxDbMetricsRetention\\\': time: unknown unit "x" in duration "1x"  influxdbmetricsretention=1x
      error decoding \\\'Settings.InfluxDbMetricsRetention\\\': time: invalid duration "x"  influxdbmetricsretention=x
      #Influx Db Metrics Retention must be greater than 0  influxdbmetricsretention=0s  supported
      Error parsing query: found -, expected duration at line 1, char 61  influxdbmetricsretention=-1s
      Retention policy duration must be at least 1h0m0s  influxdbmetricsretention=1s

      error decoding \\\'Settings.CloudletMaintenanceTimeout\\\': time: missing unit in duration "1"       cloudletmaintenancetimeout=1
      error decoding \\\'Settings.CloudletMaintenanceTimeout\\\': time: unknown unit "x" in duration "1x"  cloudletmaintenancetimeout=1x
      error decoding \\\'Settings.CloudletMaintenanceTimeout\\\': time: invalid duration "x"               cloudletmaintenancetimeout=x
      Cloudlet Maintenance Timeout must be greater than 0                                                  cloudletmaintenancetimeout=0s

      error decoding \\\'Settings.UpdateVmPoolTimeout\\\': time: missing unit in duration "1"       updatevmpooltimeout=1
      error decoding \\\'Settings.UpdateVmPoolTimeout\\\': time: unknown unit "x" in duration "1x"  updatevmpooltimeout=1x
      error decoding \\\'Settings.UpdateVmPoolTimeout\\\': time: invalid duration "x"               updatevmpooltimeout=x
      Update Vm Pool Timeout must be greater than 0                                                 updatevmpooltimeout=0s

# ECQ-2987
Settings - mcctl shall be able to reset the settings
   [Documentation]
   ...  - send ResetSettings via mcctl
   ...  - verify settings are reset

   # EDGECLOUD-4156 	ResetSettings removes the influxdbmetricsretention setting  - closed

   ${settings}=  Run mcctl  region ShowSettings region=${region}
   [Teardown]  Cleanup Settings  ${settings}

   Run mcctl  region ResetSettings region=${region}

   ${settings_post}=  Run mcctl  region ShowSettings region=${region}

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

   Should Be Equal As Numbers  ${settings_post['load_balancer_max_port_range']}  50 
   Should Be Equal As Numbers  ${settings_post['max_tracked_dme_clients']}       100
   Should Be Equal             ${settings_post['chef_client_interval']}          10m0s
   Should Be Equal             ${settings_post['cloudlet_maintenance_timeout']}  5m0s 
   Should Be Equal             ${settings_post['update_vm_pool_timeout']}        20m0s 
   Should Be Equal             ${settings_post['influx_db_metrics_retention']}   672h0m0s

*** Keywords ***
Fail UpdateSettings Via mcctl
   [Arguments]  ${error_msg}  ${parms}

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  region UpdateSettings region=${region} ${parms}
   Should Contain  ${std_create}  ${error_msg}

Cleanup Settings
   [Arguments]  ${settings}

   ${settings_pre}=  Run mcctl  region ShowSettings region=${region}

   ${parms_all}=  Set Variable  ${Empty}
   FOR  ${key}  IN  @{settings.keys()}
      ${parm}=  Replace String  ${key}  _  ${Empty}
      ${parms_all}=  Catenate  SEPARATOR=${SPACE}  ${parms_all}  ${parm}=${settings['${key}']} 
   END

   Run mcctl  region UpdateSettings region=${region} ${parms_all}

   ${settings_post}=  Run mcctl  region ShowSettings region=${region}

