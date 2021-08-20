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
# removed checks for load_balancer_max_port_range. It was removed when started restricing the upd/tcp ports to different values
# ECQ-2984
Settings - mcctl shall be able to show the settings
   [Documentation]
   ...  - send ShowSettings via mcctl
   ...  - verify settings are returned

   ${settings}=  Run mcctl  settings show region=${region} 

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
#   Should Contain  ${settings}  load_balancer_max_port_range
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

   ${settings}=  Run mcctl  settings show region=${region}
   Remove from Dictionary  ${settings}  edge_events_metrics_continuous_queries_collection_intervals 
   [Teardown]  Cleanup Settings  ${settings}

   Run mcctl  settings update region=${region} shepherdmetricscollectioninterval=1s
   Run mcctl  settings update region=${region} shepherdalertevaluationinterval=111s
   Run mcctl  settings update region=${region} shepherdhealthcheckretries=1
   Run mcctl  settings update region=${region} shepherdhealthcheckinterval=1s
   Run mcctl  settings update region=${region} autodeployintervalsec=1 autodeployoffsetsec=1 autodeploymaxintervals=1
   Run mcctl  settings update region=${region} createappinsttimeout=1m0s updateappinsttimeout=1m0s deleteappinsttimeout=1m0s createclusterinsttimeout=1m0s updateclusterinsttimeout=1m0s deleteclusterinsttimeout=1m0s
#   Run mcctl  settings update region=${region} masternodeflavor=x1.medium loadbalancermaxportrange=1 maxtrackeddmeclients=1 chefclientinterval=1m0s influxdbmetricsretention=100h0m0s cloudletmaintenancetimeout=1s updatevmpooltimeout=1s
   Run mcctl  settings update region=${region} masternodeflavor=x1.medium maxtrackeddmeclients=1 chefclientinterval=1m0s influxdbmetricsretention=100h0m0s cloudletmaintenancetimeout=1s updatevmpooltimeout=1s


   ${settings_post}=  Run mcctl  settings show region=${region}

   Should Be Equal             ${settings_post['shepherd_alert_evaluation_interval']}    1m51s
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
#   Should Be Equal As Numbers  ${settings_post['load_balancer_max_port_range']}  1
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
      Error: parsing arg "shepherdmetricscollectioninterval=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc       shepherdmetricscollectioninterval=1
      Error: parsing arg "shepherdmetricscollectioninterval=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  shepherdmetricscollectioninterval=1x
      Error: parsing arg "shepherdmetricscollectioninterval=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc               shepherdmetricscollectioninterval=x
      Shepherd Metrics Collection Interval must be greater than 0                                                 shepherdmetricscollectioninterval=0s

      Error: parsing arg "shepherdalertevaluationinterval=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc       shepherdalertevaluationinterval=1
      Error: parsing arg "shepherdalertevaluationinterval=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  shepherdalertevaluationinterval=1x
      Error: parsing arg "shepherdalertevaluationinterval=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc               shepherdalertevaluationinterval=x
      Shepherd Alert Evaluation Interval must be greater than 0                                                 shepherdalertevaluationinterval=0s

      Error: parsing arg "shepherdhealthcheckretries=1x" failed: unable to parse "1x" as int: invalid syntax                                shepherdhealthcheckretries=1x
      Error: parsing arg "shepherdhealthcheckretries=9999999999999999999999999999" failed: unable to parse "9999999999999999999999999999" as int: value out of range  shepherdhealthcheckretries=9999999999999999999999999999
      Shepherd Health Check Retries must be greater than 0                                                          shepherdhealthcheckretries=0

      Error: parsing arg "shepherdhealthcheckinterval=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc      shepherdhealthcheckinterval=1
      Error: parsing arg "shepherdhealthcheckinterval=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  shepherdhealthcheckinterval=1x
      Error: parsing arg "shepherdhealthcheckinterval=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc               shepherdhealthcheckinterval=x
      Shepherd Health Check Interval must be greater than 0                                                 shepherdhealthcheckinterval=0s

      Error: parsing arg "autodeployintervalsec=x" failed: unable to parse "x" as float64: invalid syntax  autodeployintervalsec=x
      #Unmarshal type error: expected=int32, got=number 9999999999999999999, field=Settings.shepherd_health_check_retries, offset=66"}')  autodeployintervalsec=9999999999999999999
      Auto Deploy Interval Sec must be greater than 0  autodeployintervalsec=0

      Error: parsing arg "autodeploymaxintervals=x" failed: unable to parse "x" as uint: invalid syntax                        autodeploymaxintervals=x
      Error: parsing arg "autodeploymaxintervals=9999999999999999999" failed: unable to parse "9999999999999999999" as uint: value out of range  autodeploymaxintervals=9999999999999999999
      Auto Deploy Max Intervals must be greater than 0                                                  autodeploymaxintervals=0

      Error: parsing arg "autodeployoffsetsec=1x" failed: unable to parse "1x" as float64: invalid syntax  autodeployoffsetsec=1x

      Error: parsing arg "createappinsttimeout=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc        createappinsttimeout=1x
      Error: parsing arg "createappinsttimeout=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc             createappinsttimeout=1
      Create App Inst Timeout must be greater than 0                                                       createappinsttimeout=0s
      Error: parsing arg "createappinsttimeout=99999999999999999999s" failed: unable to parse "99999999999999999999s" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  createappinsttimeout=99999999999999999999s
      Error: parsing arg "updateappinsttimeout=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc        updateappinsttimeout=1x
      Error: parsing arg "updateappinsttimeout=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc             updateappinsttimeout=1
      Update App Inst Timeout must be greater than 0                                                       updateappinsttimeout=0s
      Error: parsing arg "updateappinsttimeout=99999999999999999999s" failed: unable to parse "99999999999999999999s" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  updateappinsttimeout=99999999999999999999s
      Error: parsing arg "deleteappinsttimeout=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc       deleteappinsttimeout=1x
      Error: parsing arg "deleteappinsttimeout=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc             deleteappinsttimeout=1
      Delete App Inst Timeout must be greater than 0                                                       deleteappinsttimeout=0s
      Error: parsing arg "deleteappinsttimeout=99999999999999999999s" failed: unable to parse "99999999999999999999s" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  deleteappinsttimeout=99999999999999999999s


      Error: parsing arg "createclusterinsttimeout=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc        createclusterinsttimeout=1x
      Error: parsing arg "createclusterinsttimeout=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc             createclusterinsttimeout=1
      Create Cluster Inst Timeout must be greater than 0                                                       createclusterinsttimeout=0s
      Error: parsing arg "createclusterinsttimeout=99999999999999999999s" failed: unable to parse "99999999999999999999s" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  createclusterinsttimeout=99999999999999999999s
      Error: parsing arg "updateclusterinsttimeout=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc        updateclusterinsttimeout=1x
      Error: parsing arg "updateclusterinsttimeout=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc             updateclusterinsttimeout=1
      Update Cluster Inst Timeout must be greater than 0                                                       updateclusterinsttimeout=0s
      Error: parsing arg "updateclusterinsttimeout=99999999999999999999s" failed: unable to parse "99999999999999999999s" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  updateclusterinsttimeout=99999999999999999999s
      Error: parsing arg "deleteclusterinsttimeout=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc        deleteclusterinsttimeout=1x
      Error: parsing arg "deleteclusterinsttimeout=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc             deleteclusterinsttimeout=1
      Delete Cluster Inst Timeout must be greater than 0                                                       deleteclusterinsttimeout=0s
      Error: parsing arg "deleteclusterinsttimeout=99999999999999999999s" failed: unable to parse "99999999999999999999s" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  deleteclusterinsttimeout=99999999999999999999s

      Flavor must preexist  masternodeflavor=xx

#      Load Balancer Max Port Range must be greater than 0  loadbalancermaxportrange=0
#      Unable to parse "loadbalancermaxportrange" value "x" as int: invalid syntax  loadbalancermaxportrange=x
#      Load Balancer Max Port Range must be greater than 0  loadbalancermaxportrange=-1
#      Load Balancer Max Port Range must be less than 65536  loadbalancermaxportrange=70000
#      Unable to parse "loadbalancermaxportrange" value "99999999999999999" as int: value out of range  loadbalancermaxportrange=99999999999999999

      Max Tracked Dme Clients must be greater than 0  maxtrackeddmeclients=0
      Max Tracked Dme Clients must be greater than 0  maxtrackeddmeclients=-1
      Error: parsing arg "maxtrackeddmeclients=x" failed: unable to parse "x" as int: invalid syntax  maxtrackeddmeclients=x

      Error: parsing arg "chefclientinterval=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  chefclientinterval=1
      Error: parsing arg "chefclientinterval=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  chefclientinterval=1x
      Error: parsing arg "chefclientinterval=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  chefclientinterval=x
      Chef Client Interval must be greater than 0  chefclientinterval=-1s

      Error: parsing arg "influxdbmetricsretention=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  influxdbmetricsretention=1
      Error: parsing arg "influxdbmetricsretention=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  influxdbmetricsretention=1x
      Error: parsing arg "influxdbmetricsretention=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  influxdbmetricsretention=x
      #Influx Db Metrics Retention must be greater than 0  influxdbmetricsretention=0s  supported
      Error parsing query: found -, expected duration at line 1, char 65  influxdbmetricsretention=-1s
      Retention policy duration must be at least 1h0m0s  influxdbmetricsretention=1s

      Error: parsing arg "cloudletmaintenancetimeout=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc       cloudletmaintenancetimeout=1
      Error: parsing arg "cloudletmaintenancetimeout=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  cloudletmaintenancetimeout=1x
      Error: parsing arg "cloudletmaintenancetimeout=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc               cloudletmaintenancetimeout=x
      Cloudlet Maintenance Timeout must be greater than 0                                                  cloudletmaintenancetimeout=0s

      Error: parsing arg "updatevmpooltimeout=1" failed: unable to parse "1" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc       updatevmpooltimeout=1
      Error: parsing arg "updatevmpooltimeout=1x" failed: unable to parse "1x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  updatevmpooltimeout=1x
      Error: parsing arg "updatevmpooltimeout=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc               updatevmpooltimeout=x
      Update Vm Pool Timeout must be greater than 0                                                 updatevmpooltimeout=0s

# ECQ-2987
Settings - mcctl shall be able to reset the settings
   [Documentation]
   ...  - send ResetSettings via mcctl
   ...  - verify settings are reset

   # EDGECLOUD-4156 	ResetSettings removes the influxdbmetricsretention setting  - closed

   ${settings}=  Run mcctl  settings show region=${region}
   Remove from Dictionary  ${settings}  edge_events_metrics_continuous_queries_collection_intervals
   [Teardown]  Cleanup Settings  ${settings}

   Run mcctl  settings reset region=${region}

   ${settings_post}=  Run mcctl  settings show region=${region}

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

#   Should Be Equal As Numbers  ${settings_post['load_balancer_max_port_range']}  50 
   Should Be Equal As Numbers  ${settings_post['max_tracked_dme_clients']}       100
   Should Be Equal             ${settings_post['chef_client_interval']}          10m0s
   Should Be Equal             ${settings_post['cloudlet_maintenance_timeout']}  5m0s 
   Should Be Equal             ${settings_post['update_vm_pool_timeout']}        20m0s 
   Should Be Equal             ${settings_post['influx_db_metrics_retention']}   672h0m0s

*** Keywords ***
Fail UpdateSettings Via mcctl
   [Arguments]  ${error_msg}  ${parms}

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  settings update region=${region} ${parms}
   Should Contain  ${std_create}  ${error_msg}

Cleanup Settings
   [Arguments]  ${settings}

   ${settings_pre}=  Run mcctl  settings show region=${region}

   ${parms_all}=  Set Variable  ${Empty}
   FOR  ${key}  IN  @{settings.keys()}
      ${parm}=  Replace String  ${key}  _  ${Empty}
      ${parms_all}=  Catenate  SEPARATOR=${SPACE}  ${parms_all}  ${parm}=${settings['${key}']} 
   END

   Run mcctl  settings update region=${region} ${parms_all}

   ${settings_post}=  Run mcctl  settings show region=${region}

