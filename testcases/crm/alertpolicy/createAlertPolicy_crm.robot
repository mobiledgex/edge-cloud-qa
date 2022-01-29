#-*- coding: robot -*-

*** Settings ***
Documentation  CreateAlertPolicy on CRM

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}    #auto_login=${False}
Library  MexApp
Library  String
Library  DateTime

Suite Setup     Setup
Suite Teardown  Cleanup Provisioning
Test Timeout  30m

*** Variables ***
${nogo}=  ${True}
#${cloudlet_name_crm}  automationDallasCloudlet
#${cloudlet_name_crm}  qa-anthos
#${cloudlet_name_crm}  dfw-vsphere
#${cloudlet_name_crm}  DFWVMW2
${cloudlet_name_crm}  automationBuckhornCloudlet
#${operator_name_crm}  packet
${operator_name_crm}  GDDT
${developer_org_name}  automation_dev_org
#${developer_org_name}  MobiledgeX
${developer_org_name_automation}=  ${developer_org_name}
${alert_org}=  ${developer_org_name_automation}           
${app_org}=    ${developer_org_name_automation}
${app_name}              alertapp101
${cluster_name}          alertcluster101
${mobiledgex_domain}     mobiledgex.net
${docker_image_alerts}   docker-qa.mobiledgex.net/automation_dev_org/images/jmeterplus8086:13.8.6
${docker_image_edgex}    docker-qa.mobiledgex.net/mobiledgex/images/jmeterplus8086:13.8.6
${docker_image}=  ${docker_image_alerts}
${access_tcp_port}       tcp:8086
${ip_access_type}        IpAccessShared
#${ip_access_type}   IpAccessDedicated
${ip_access}             ${ip_access_type}
${num_master}       1
${num_nodes}        0
#default alert_policy_min_trigger_time
${tt_3s}=             3s
${tt_s}=             30s
${tt_30s}=           30s
${tt_32s}=           32s
${tt_15s}=           15s
${test_timeout_crm}  15 min
#ALERT POLICY RECEIVER INFO
${CPU_policy}   CPUpolicyErr
${MEM_policy}   MEMpolicyErr
${DSK_policy}   DSKpolicyErr
${ACX_policy}   ACXpolicyErr
${RCV_policy}   RCVemailRxErr
${RCV_policy_cloudlet}  RCVemailRxErr
${RCV_policy_cluster}   RCVemailRxInfo
${RCV_policy_appinst}   RCVemailRxWarn
${username}=              qaadmin
${password}=              zudfgojfrdhqntzm
${mexadmin_password}=     mexadminfastedgecloudinfra
${email}=                 mxdmnqa@gmail.com
${err}=     error
${wrn}=     warning
${inf}=     info
${user_username}=  mextester06
${user_password}=  mextester06123mobiledgexisbadass
${user_email}=     mexadmin@mobiledgex.net
${slack_channel}=  qa-alertreceiver
${slack_api_url}=  https://hooks.slack.com/services/***REMOVED***  
${region}=  US
${jmp8086_ver}=  13.8.6
${app_version}=  ${jmp8086_ver}
${util_val}=  1
${tt_policy}      ${tt_30s}
${tt_policy2}     ${tt_32s} 
${cpu_util_val}=  7
${mem_util_val}=  1
${dsk_util_val}=  1
${acx_util_val}=  5
${cpu_trig_val}=  15s
${mem_trig_val}=  12s
${dsk_trig_val}=  3s
${acx_trig_val}=  14s
${script_runtime}=   125
${script2_runtime}=  125
${influx_wait_seconds}=  30seconds
${influx2_wait_seconds}=  30seconds
${script_primer}=    60
${script_stress}=  stresscombobash.sh
${command_script_delay}=  20
${public_tcp_port}=  8086
${public_check}=  
${timeout}=  120
${loop_c}=  20
${loop_5}=  5
${loop_10}=  10
${loop_15}=  15
${loop_20}=  20
#delay to wait to make sure measurement script has stopped.
${alert_clear_delay}=  60seconds
#poll time to wait during loop to check firing
${poll_time}=   6seconds
${alertname_totals}=  0
${firing_totals}=     0

*** Test Cases ***


Create Custom Alert Receiver Selector Testall
   [Documentation]
   ...  - Create new alert policies

   Log To Console  ${\n} Create Policies
   Run Keyword  Create Custom Alert Receiver Selector Testall

#AlertPolicy - Create alert policies for k8s app utilization triggering all supported alert types
#ECQ-4276
Create alert receivers by selector type cloudlet,cluster,appinst so alerts can be seen
   [Documentation]
   ...  - Create an alert receiver for each selector type so alerts can be seen
   ...  - Use selector type cloudlet to create an slert receiver
   ...  - Use selector type cluster create an slert receiver
   ...  - Use selector type Appinst to create an slert receiver

   Log To Console  ${\n}Create alert receivers based on selector of cloudlet,cluster and appinst
   Run Keyword  Create Custom Alert Receiver Selector All

Create new alert policies for cpu mem disk and active-connections
   [Documentation]
   ...  - Create new alert policies 

   Log To Console  ${\n} Create Policies
   Run Keyword  Create Policies

Update mc settings alertpolicymintriggertime to 3s
   [Documentation]
   ...  - Set alertpolicymintriggertime to 3s

   Log To Console  ${\n}Set Trigger Time Policy 3s
   Run Keyword  Set Trigger Time Policy 3s

Update existing policies with new values
   [Documentation]
   ...  - Update alertpolicy values for trigger severity and utilization

   Log To Console  ${\n}Update Policies Severity Warning Trigger3s
   Run Keyword  Update Policies Severity Warning Trigger3s

Add alert policies to k8s app so appinst will trigger alerts
   [Documentation]
   ...  - Add cpu mem disk and active-connections policies to app

   Log To Console  ${\n}Add Policies To App
   Run Keyword  Add Policies To App

Show alert policies added to k8s app
   [Documentation]
   ...  - Show cpu mem disk and active-connections alert policies were added to app

   Log To Console  ${\n} Show Alert Policies From App
   Run Keyword  Show Alert Policies From App

Use runcommand on appinst to test script is creating utilization for alerts
   [Documentation]
   ...  - Create utilization to trigger k8s appinst alerts
   ...  - Use the appinst created and issue a Runcommand to start utilization script 

   Log To Console  ${\n}Setup Runcommand To Run Measurments
   Run Keyword  Setup Runcommand To Run Measurments

Check the metrics from the utilization script and check for alerts
   [Documentation]
   ...  - Test that the appinst utilization script and influxdb metrics are working

   Log To Console  ${\n}Get Metrics Primer
   Log To Console  Waiting ${script_primer} seconds for influxdb 
   Sleep  ${script_primer}
   Run Keyword  Get Metrics Primer
   Log To Console  Testing metrics and script to generate utilization
   Log To Console  Show Alerts Firing Primer
   Run Keyword  Show Alerts Firing Primer

Verify all alerts are cleared for mem disk cpu and active-connections
   [Documentation]
   ...  - Test that any alerts have cleared after the utilization script stops

   Log To Console  ${\n}Verify no alerts are triggering from utilization primer
   Log To Console  Show Alerts Cleared
   Run Keyword  Show Alerts Cleared
   Log To Console  Getting trigger values and metrics values

Run utilization script and verify all alert types are firing for k8s appinst
   [Documentation]
   ...  - Run appinst script to generate utilization for triggering alerts
   ...  - Poll for alerts firing and verify all clear after trigger duration is no longer met

   Log To Console  ${\n}Setup Runcommand To Run Measurments
   Run Keyword  Setup Runcommand To Run Measurments
   Log To Console  Show Alerts Firing
   Run Keyword  Show Alerts Firing
   Log To Console  Show Alerts Cleared
   Run Keyword  Show Alerts Cleared

Set mc settings alertpolicymintriggertime back to 30s
   [Documentation]
   ...  - Set the mc alertpolicytrigger to 30s
   ...  - Verify that the value is set back for 30s US and EU

   Log To Console  ${\n}Reset Trigger Time Policy 30s
   Run Keyword  Reset Trigger Time Policy 30s

*** Keywords ***
Setup
    ${super_token}  Get Super Token
    Set Suite Variable  ${super_token}
    Set Suite Variable  ${firing_cpu}   0
    Set Suite Variable  ${firing_acx}   0
    Set Suite Variable  ${firing_mem}   0
    Set Suite Variable  ${firing_dsk}   0
    Set Suite Variable  ${firing_pass}  0
    Set Suite Variable  ${developer_org_name}  ${developer_org_name}
    Set Suite Variable  ${docker_image}     ${docker_image_alerts}
    Set Suite Variable  ${alertname_totals}   0
    Set Suite Variable  ${firing_totals}      0 
    Set Suite Variable  ${cpu_firing_total}   0
    Set Suite Variable  ${mem_firing_total}   0
    Set Suite Variable  ${dsk_firing_total}   0
    Set Suite Variable  ${acx_firing_total}   0
    Set Suite Variable  ${cpu_firing_cnt}     0
    Set Suite Variable  ${mem_firing_cnt}     0
    Set Suite Variable  ${dsk_firing_cnt}     0
    Set Suite Variable  ${acx_firing_cnt}     0
    Set Suite Variable  ${cpu_firing_val}     0
    Set Suite Variable  ${mem_firing_val}     0
    Set Suite Variable  ${dsk_firing_val}     0
    Set Suite Variable  ${acx_firing_val}     0
    Set Suite Variable  ${cpu_alertname_total}   0
    Set Suite Variable  ${mem_alertname_total}   0
    Set Suite Variable  ${dsk_alertname_total}   0
    Set Suite Variable  ${acx_alertname_total}   0
    Set Suite Variable  ${cpu_alertname_cnt}     0
    Set Suite Variable  ${mem_alertname_cnt}     0
    Set Suite Variable  ${dsk_alertname_cnt}     0
    Set Suite Variable  ${acx_alertname_cnt}     0
    Set Suite Variable  ${cpu_alertname_val}     0
    Set Suite Variable  ${mem_alertname_val}     0
    Set Suite Variable  ${dsk_alertname_val}     0
    Set Suite Variable  ${acx_alertname_val}     0
    Set Suite Variable  ${cpu_metric_val}        0
    Set Suite Variable  ${mem_metric_val}        0
    Set Suite Variable  ${dsk_metric_val}        0
    Set Suite Variable  ${acx_metric_val}        0
    ${date}=         Get Current Date  result_format=epoch  exclude_millis=no
    Set Suite Variable  ${date} 
    ${epoch}=        Convert Date    ${date}    epoch  exclude_millis=yes   
    ${epoch}=        Convert To String  ${epoch}
    ${epoch}=        Remove String   ${epoch}  .0   
    ${cluster_name}=  Catenate  ${cluster_name}-${epoch}
    ${app_name}=      Catenate  ${app_name}-${epoch}
    Set Suite Variable  ${cluster_name}
    Set Suite Variable  ${app_name}
    ${CPU_policy}=  Catenate  ${CPU_policy}-${epoch}
    ${MEM_policy}=  Catenate  ${MEM_policy}-${epoch}
    ${DSK_policy}=  Catenate  ${DSK_policy}-${epoch}
    ${ACX_policy}=  Catenate  ${ACX_policy}-${epoch}
    ${RCV_policy}=  Catenate  ${RCV_policy}-${epoch}
    ${RCV_policy_cloudlet}=   Catenate  ${RCV_policy_cloudlet}-${epoch}-selector-cloudlet
    ${RCV_policy_cluster}=    Catenate  ${RCV_policy_cluster}-${epoch}-selector-cluster
    ${RCV_policy_appinst}=    Catenate  ${RCV_policy_appinst}-${epoch}-selector-appinst
    Set Suite Variable  ${CPU_policy}
    Set Suite Variable  ${MEM_policy}
    Set Suite Variable  ${DSK_policy}
    Set Suite Variable  ${ACX_policy}
    Set Suite Variable  ${RCV_policy}
    Set Suite Variable  ${RCV_policy_cloudlet}
    Set Suite Variable  ${RCV_policy_cluster}
    Set Suite Variable  ${RCV_policy_appinst}
    Set Suite Variable  ${err}          error
    Set Suite Variable  ${wrn}          warning
    Set Suite Variable  ${inf}          info
    Set Suite Variable  ${loop_c}   20
    Set Suite Variable  ${loop_5}    5
    Set Suite Variable  ${loop_10}  10
    Set Suite Variable  ${loop_15}  15
    Set Suite Variable  ${loop_20}  20
    #Log naming to console checking webui manually durring testing
    Log To Console  ${\n}${CPU_policy}
    Log To Console  ${\n}${MEM_policy}
    Log To Console  ${\n}${DSK_policy}
    Log To Console  ${\n}${ACX_policy}
    Log To Console  ${\n}${RCV_policy}
    Log To Console  ${\n}${RCV_policy_cloudlet}
    Log To Console  ${\n}${RCV_policy_cluster}
    Log To Console  ${\n}${RCV_policy_appinst}
    Log To Console  ${\n}${app_name}
    Log To Console  ${\n}${cluster_name}

    Log To Console  ${\n}Creating Flavor
    Create Flavor  token=${super_token}  region=${region}

    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}

    IF  '${platform_type}' == 'K8SBareMetal'
      ${allow_serverless}=  Set Variable  ${True}
      Set Suite Variable  ${platform_type}
      Set Suite Variable  ${allow_serverless}
      Create App  token=${super_token}  region=${region}  image_path=${docker_image_edgex}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  developer_org_name=${developer_org_name}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=kubernetes  app_name=${app_name}  allow_serverless=${allow_serverless}  #default_flavor_name=${cluster_flavor_name}
      Log To Console  ${\n}Done Creating App
    ELSE
      ${allow_serverless}=  Set Variable  ${None}
      Set Suite Variable  ${allow_serverless}
      Log To Console  ${\n}Creating App
      Create App  token=${super_token}  region=${region}  image_path=${docker_image}  app_version=${app_version}  developer_org_name=${developer_org_name}  access_ports=${access_tcp_port}  developer_org_name=${developer_org_name}  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=kubernetes  app_name=${app_name}  allow_serverless=${allow_serverless}  #default_flavor_name=${cluster_flavor_name}
      Log To Console  ${\n}Done Creating App
      Log To Console  ${\n}Creating Cluster Instance
      Create Cluster Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=${ip_access_type}  number_masters=${num_master}  number_nodes=${num_nodes}  deployment=kubernetes  developer_org_name=${developer_org_name}  cluster_name=${cluster_name}  #flavor_name=${cluster_flavor_name}
      Log To Console  ${\n}Done Creating Cluster Instance
    END

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    Log To Console  ${\n}Initial catenation ${rootlb}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    Log To Console  ${\n}Conversion to lowercase ${rootlb}
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
    Set Suite Variable  ${rootlb}
    Log To Console  ${\n}rootlb catenation ${rootlb}

    Log To Console  ${\n}Creating App Instance

    Create App Instance  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  app_version=${app_version}  developer_org_name=${developer_org_name}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
    Log To Console  ${\n}Done Creating Appinst
    ${public_check}=  Show App Instances  token=${super_token}  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name}  app_version=${app_version}  developer_org_name=${developer_org_name}

    ${internal_port_val}=  Set Variable  ${public_check[0]['data']['mapped_ports'][0]['internal_port']}
    ${public_port_val}=  Set Variable  ${public_check[0]['data']['mapped_ports'][0]['public_port']}
    #Log ports to console when checking webui manually while test is running
    Log To Console  ${\n}
    Log To Console  Internal port=${internal_port_val}
    Log To Console  Public port..=${public_port_val}
    #Values are used in appinst script for jmeter to create active connections
    Set Suite Variable  ${internal_port_val}
    Set Suite Variable  ${public_port_val}

Create Custom Alert Receiver Cloudlet Err
    # Only a generic type email is needed to setup alert manager to trigger k8s alert policy. Creating each type with alert policy is covered in mcctl robot tests
    ${RCV_policy1}=  Run Keyword  Create Alert Receiver  token=${super_token}  region=${region}  receiver_name=${RCV_policy}-${cloudlet_name_crm}  type=email  email_address=${user_email}  severity=${err}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    Set Suite Variable  ${RCV_policy1}
    Log To Console  ${\n}Done Creating Alert Receiver name=${RCV_policy1}

Create Custom Alert Receiver Selector All
    # Createing Alert Receiver by selector types
    #Selector Cloudlet
    ${RCV_policy_cld}=  Run Keyword  Create Alert Receiver  token=${super_token}  region=${region}  receiver_name=${RCV_policy_cloudlet}  type=email  email_address=${user_email}  severity=${err}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    Set Suite Variable  ${RCV_policy_cld}
    Log To Console  ${\n}Done Creating Alert Receiver name=${RCV_policy_cld}
    Run Keyword  Should Be Equal  ${RCV_policy_cld['Name']}  ${RCV_policy_cloudlet}
    #Selector Cluster
    ${RCV_policy_clust}=  Run Keyword  Create Alert Receiver  token=${super_token}  region=${region}  receiver_name=${RCV_policy_cluster}  type=email  email_address=${user_email}  severity=${inf}  cluster_instance_name=${cluster_name}  app_cloudlet_name=${cloudlet_name_crm}  app_cloudlet_org=${operator_name_crm}
    Set Suite Variable  ${RCV_policy_clust}
    Log To Console  ${\n}Done Creating Alert Receiver by clusterinst selector  name=${RCV_policy_clust}
    Run Keyword  Should Be Equal  ${RCV_policy_clust['Name']}  ${RCV_policy_cluster}
    #Selector Appinst
    ${RCV_policy_app}=  Run Keyword  Create Alert Receiver  token=${super_token}  region=${region}  receiver_name=${RCV_policy_appinst}  type=email  email_address=${user_email}  severity=${wrn}  cluster_instance_name=${cluster_name}  app_name=${app_name}  app_version=${app_version}  app_cloudlet_name=${cloudlet_name_crm}  app_cloudlet_org=${operator_name_crm}
    Set Suite Variable  ${RCV_policy_app}
    Log To Console  ${\n}Done Creating Alert Receiver by appinst selector  name=${RCV_policy_app}
    Run Keyword  Should Be Equal  ${RCV_policy_app['Name']}  ${RCV_policy_appinst}

Create Custom Alert Receiver Selector Testall
    # manual testing for just alert receivers when no cluster instance or appinstance is created - for error testing
    ${super_token}  Get Super Token
    Set Suite Variable  ${super_token}
    ${date}=         Get Current Date  result_format=epoch  exclude_millis=no
    Set Suite Variable  ${date}
    ${epoch}=        Convert Date    ${date}    epoch  exclude_millis=yes
    ${epoch}=        Convert To String  ${epoch}
    ${epoch}=        Remove String   ${epoch}  .0
    ${RCV_policy_cloudlet}=        Catenate  ${RCV_policy_cloudlet}-${epoch}-selector-cloudlet-deleteme
    ${RCV_policy_cluster}=  Catenate  ${RCV_policy_cluster}-${epoch}-selector-cluster-deleteme
    ${RCV_policy_appinst}=    Catenate  ${RCV_policy_appinst}-${epoch}-selector-appinst-deleteme

    ${RCV_policy_cld}=  Run Keyword  Create Alert Receiver  token=${super_token}  region=${region}  receiver_name=${RCV_policy_cloudlet}  type=email  email_address=${user_email}  severity=${err}  cloudlet_name=automationDallasCloudlet  operator_org_name=packet
    Set Suite Variable  ${RCV_policy_cld}
    Log To Console  ${\n}Done Creating Alert Receiver name=${RCV_policy_cld}
    Run Keyword  Should Be Equal  ${RCV_policy_cld['Name']}  ${RCV_policy_cloudlet}

    ${RCV_policy_clust}=  Run Keyword  Create Alert Receiver  token=${super_token}  region=US  receiver_name=${RCV_policy_cluster}  type=email  email_address=${user_email}  severity=${inf}  cluster_instance_name=porttestcluster  app_cloudlet_name=automationDallasCloudlet  app_cloudlet_org=packet
    Set Suite Variable  ${RCV_policy_clust}
    Log To Console  ${\n}Done Creating Alert Receiver by clusterinst selector  name=${RCV_policy_clust}
    Run Keyword  Should Be Equal  ${RCV_policy_clust['Name']}  ${RCV_policy_cluster}

    ${RCV_policy_app}=  Run Keyword  Create Alert Receiver  token=${super_token}  region=US  receiver_name=${RCV_policy_appinst}  type=email  email_address=${user_email}  severity=${wrn}  cluster_instance_name=porttestcluster  app_name=automation-sdk-porttest  app_version=1.0  app_cloudlet_name=automationDallasCloudlet  app_cloudlet_org=packet
    Set Suite Variable  ${RCV_policy_app}
    Log To Console  ${\n}Done Creating Alert Receiver by appinst selector  name=${RCV_policy_app}
    Run Keyword  Should Be Equal  ${RCV_policy_app['Name']}  ${RCV_policy_appinst}

Reset Trigger Time Policy 30s
   # Show current settings for trriger time and set back to 30s which is the default when test is complete
   # Run mcctl  settings update alertpolicymintriggertime=30s region=EU
   # Run mcctl  settings update alertpolicymintriggertime=30s region=US
   ${set_tt_us}=  Run Keyword  Update Settings  token=${super_token}  region=US  alert_policy_min_trigger_time=${tt_30s}
   ${set_tt_eu}=  Run Keyword  Update Settings  token=${super_token}  region=EU  alert_policy_min_trigger_time=${tt_30s}
   ${show_us}=  Run Keyword  Show Settings  token=${super_token}  region=US
   ${show_eu}=  Run Keyword  Show Settings  token=${super_token}  region=EU
   ${tt_us}=  Set Variable  ${show_us['alert_policy_min_trigger_time']}
   ${tt_eu}=  Set Variable  ${show_eu['alert_policy_min_trigger_time']}
   Run Keywords    Should Be Equal As Strings  ${tt_us}  ${tt_30s}  AND  Log To Console  ${\n}alert_policy_min_trigger_time US= ${tt_us}
   Run Keywords    Should Be Equal As Strings  ${tt_eu}  ${tt_30s}  AND  Log To Console  ${\n}alert_policy_min_trigger_time EU= ${tt_eu}

Set Trigger Time Policy 3s
   # In order to update alert policy trigger less than 30s this setting must be changed to 3s
   ${set_tt_us}=  Run Keyword  Update Settings  token=${super_token}  region=US  alert_policy_min_trigger_time=${tt_3s}
   ${set_tt_eu}=  Run Keyword  Update Settings  token=${super_token}  region=EU  alert_policy_min_trigger_time=${tt_3s}
   ${show_us}=  Run Keyword  Show Settings  token=${super_token}  region=US
   ${show_eu}=  Run Keyword  Show Settings  token=${super_token}  region=EU
   ${tt_us}=  Set Variable  ${show_us['alert_policy_min_trigger_time']}
   ${tt_eu}=  Set Variable  ${show_eu['alert_policy_min_trigger_time']}
   Run Keywords    Should Be Equal As Strings  ${tt_us}  ${tt_3s}  AND  Log To Console  ${\n}alert_policy_min_trigger_time US= ${tt_us}
   Run Keywords    Should Be Equal As Strings  ${tt_eu}  ${tt_3s}  AND  Log To Console  ${\n}alert_policy_min_trigger_time EU= ${tt_eu}

Create Policies
   #Creating Alert Policies if exists already test will not error and status of exists or created will be displayed
   ${cpu_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${CPUpolicy}\\\\\\\\"} already exists"}\\\')\')
   ${mem_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${MEMpolicy}\\\\\\\\"} already exists"}\\\')\')
   ${dsk_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${DSKpolicy}\\\\\\\\"} already exists"}\\\')\')
   ${acx_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${ACXpolicy}\\\\\\\\"} already exists"}\\\')\')
#CPU AlertPolicy
   ${cpu_policy_name}=  Run Keyword And Ignore Error  Create Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}  severity=${err}  trigger_time=${tt_s}  alert_org=${alert_org}     cpu_utilization=${util_val}  labels_vars=Error=CPU  annotations_vars=description=[CPU] Error on 8086 critical consumption app needs 1.21 gigawatts of CPU power  description=description-cpu
   ${nogo}=  Run Keyword If  ${cpu_err}==${cpu_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${CPU_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${cpu_err}!=${cpu_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${CPU_policy} was created
   ${cpu_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}
   ${cpu_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['severity']}
   ${cpu_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_sev}   ${err}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_trig}  ${tt_policy}
#MEM AlertPolicy
   ${mem_policy_name}=  Run Keyword And Ignore Error    Create Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}  severity=${err}  trigger_time=${tt_s}  alert_org=${alert_org}     mem_utilization=${util_val}  labels_vars=Error=MEM  annotations_vars=description=[MEM] Error on 8086 critical consumption app needs 1.21 gigawatts of MEM power  description=description-mem
   ${nogo}=  Run Keyword If  ${mem_err}==${mem_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${MEM_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${mem_err}!=${mem_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${MEM_policy} was created
   ${mem_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}
   ${mem_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['severity']}
   ${mem_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_sev}   ${err}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_trig}  ${tt_policy}
#DSK AlertPolicy
   ${dsk_policy_name}=  Run Keyword And Ignore Error    Create Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}  severity=${err}  trigger_time=${tt_s}  alert_org=${alert_org}    disk_utilization=${util_val}  labels_vars=Error=DSK  annotations_vars=description=[DSK] Error on 8086 critical consumption app needs 1.21 gigawatts of DSK power  description=description-dsk
   ${nogo}=  Run Keyword If  ${dsk_err}==${dsk_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${DSK_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${dsk_err}!=${dsk_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${DSK_policy} was created
   ${dsk_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}
   ${dsk_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['severity']}
   ${dsk_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_sev}   ${err}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_trig}  ${tt_policy}
#ACX AlertPolicy
   ${acx_policy_name}=  Run Keyword And Ignore Error    Create Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}  severity=${err}  trigger_time=${tt_s}  alert_org=${alert_org}  active_connections=${util_val}  labels_vars=Error=ACX  annotations_vars=description=[ACX] Error on 8086 critical consumption app needs 1.21 gigawatts of ACX power  description=description-acx
   ${nogo}=  Run Keyword If  ${acx_err}==${acx_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${ACX_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${acx_err}!=${acx_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${ACX_policy} was created
   ${acx_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}
   ${acx_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['severity']}
   ${acx_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_sev}   ${err}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_trig}  ${tt_policy}

Delete Policies
#Deleting alert policies if exists - not used in suite testing as teardown will remove policies leaving this keyword for not suite tests
   ${cpu_err}      Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${CPU_policy}\\\\\\\\"} not found"}\\\')\') 
   ${mem_err}      Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${MEM_policy}\\\\\\\\"} not found"}\\\')\') 
   ${dsk_err}      Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${DSK_policy}\\\\\\\\"} not found"}\\\')\')
   ${acx_err}      Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${ACX_policy}\\\\\\\\"} not found"}\\\')\')
   ${cpu_err2}     Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert is in use by App"}\\\')\')
   ${mem_err2}     Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert is in use by App"}\\\')\')
   ${dsk_err2}     Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert is in use by App"}\\\')\')
   ${acx_err2}     Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert is in use by App"}\\\')\')
   ${cpu_deleted}  Set Variable  (added to app)
#CPU AlertPolicy
   ${cpu_policy_name}=  Run Keyword And Ignore Error  Delete Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}  alert_org=${alert_org}
   Run Keyword If     ${cpu_err}==${cpu_policy_name}     Log To Console  ${\n}${CPU_policy} does not exist not deleted
   Run Keyword If     ${cpu_err2}==${cpu_policy_name}    Log To Console  ${\n}${CPU_policy} is in use by App not deleted
   Run Keyword If     ${cpu_err}!=${cpu_policy_name}     Log To Console  ${\n}${CPU_policy} was deleted
#MEM AlertPolicy
   ${mem_policy_name}=  Run Keyword And Ignore Error  Delete Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}  alert_org=${alert_org}
   Run Keyword If     ${mem_err}==${mem_policy_name}     Log To Console  ${\n}${MEM_policy} does not exist not deleted
   Run Keyword If     ${mem_err2}==${mem_policy_name}    Log To Console  ${\n}${MEM_policy} is in use by App not deleted
   Run Keyword If     ${mem_err}!=${mem_policy_name}     Log To Console  ${\n}${MEM_policy} was deleted
#DSK AlertPolicy  
   ${dsk_policy_name}=  Run Keyword And Ignore Error  Delete Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}  alert_org=${alert_org}
   Run Keyword If     ${dsk_err}==${dsk_policy_name}     Log To Console  ${\n}${DSK_policy} does not exist not deleted
   Run Keyword If     ${dsk_err2}==${dsk_policy_name}    Log To Console  ${\n}${DSK_policy} is in use by App not deleted
   Run Keyword If     ${dsk_err}!=${dsk_policy_name}     Log To Console  ${\n}${DSK_policy} was deleted
#ACX AlertPolicy
   ${acx_policy_name}=  Run Keyword And Ignore Error  Delete Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}  alert_org=${alert_org}
   Run Keyword If     ${acx_err}==${acx_policy_name}     Log To Console  ${\n}${ACX_policy} does not exist not deleted
   Run Keyword If     ${acx_err2}==${acx_policy_name}    Log To Console  ${\n}${ACX_policy} is in use by App not deleted
   Run Keyword If     ${acx_err}!=${acx_policy_name}     Log To Console  ${\n}${ACX_policy} was deleted

Update Policies Severity Warning Trigger30
#Update Alert Policies intial trigger has to be updated with 30s until the mc settings is changed to 3s 
   ${nogo}          Set Variable  null
   ${wrn}           Set Variable  warning
   ${inf}           Set Variable  info
   ${err}           Set Variable  error
   ${tt_s}          Set Variable  ${tt_30s}
   ${tt_policy}     Set Variable  ${tt_30s}
   ${cpu_util_val}  Set Variable  ${cpu_util_val}
   ${mem_util_val}  Set Variable  ${mem_util_val}
   ${dsk_util_val}  Set Variable  ${dsk_util_val}
   ${acx_util_val}  Set Variable  ${acx_util_val}
#Updating alert policies if exists
   ${cpu_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${CPUpolicy}\\\\\\\\"} not found"}\\\')\')
   ${mem_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${MEMpolicy}\\\\\\\\"} not found"}\\\')\')
   ${dsk_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${DSKpolicy}\\\\\\\\"} not found"}\\\')\')
   ${acx_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${ACXpolicy}\\\\\\\\"} not found"}\\\')\')
#CPU AlertPolicy
   ${cpu_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}  severity=${wrn}  trigger_time=${tt_policy}  alert_org=${alert_org}     cpu_utilization=${cpu_util_val}  labels_vars=Error=CPU  annotations_vars=description=[CPU] Error on 8086 critical consumption app needs 1.21 gigawatts of CPU power  description=description-cpu
   ${nogo}=  Run Keyword If  ${cpu_err}==${cpu_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${CPU_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${cpu_err}!=${cpu_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${CPU_policy} was updated
   ${cpu_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}
   ${cpu_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['severity']}
   ${cpu_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_trig}  ${tt_policy}
#MEM AlertPolicy
   ${mem_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}  severity=${wrn}  trigger_time=${tt_policy}  alert_org=${alert_org}     mem_utilization=${mem_util_val}  labels_vars=Error=MEM  annotations_vars=description=[MEM] Error on 8086 critical consumption app needs 1.21 gigawatts of MEM power  description=description-mem
   ${nogo}=  Run Keyword If  ${mem_err}==${mem_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${MEM_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${mem_err}!=${mem_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${MEM_policy} was updated
   ${mem_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}
   ${mem_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['severity']}
   ${mem_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_trig}  ${tt_policy}
#DSK AlertPolicy
   ${dsk_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}  severity=${wrn}  trigger_time=${tt_policy}  alert_org=${alert_org}    disk_utilization=${dsk_util_val}  labels_vars=Error=DSK  annotations_vars=description=[DSK] Error on 8086 critical consumption app needs 1.21 gigawatts of DSK power  description=description-dsk
   ${nogo}=  Run Keyword If  ${dsk_err}==${dsk_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${DSK_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${dsk_err}!=${dsk_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${DSK_policy} was updated
   ${dsk_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}
   ${dsk_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['severity']}
   ${dsk_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_trig}  ${tt_policy}
#ACX AlertPolicy
   ${acx_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}  severity=${wrn}  trigger_time=${tt_policy}  alert_org=${alert_org}  active_connections=${acx_util_val}  labels_vars=Error=ACX  annotations_vars=description=[ACX] Error on 8086 critical consumption app needs 1.21 gigawatts of ACX power  description=description-acx
   ${nogo}=  Run Keyword If  ${acx_err}==${acx_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${ACX_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${acx_err}!=${acx_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${ACX_policy} was updated
   ${acx_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}
   ${acx_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['severity']}
   ${acx_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_trig}  ${tt_policy}
   Sleep  2seconds

Update Policies Severity Warning Trigger3s
#Update Alert Policies - After mc settings have been changed
   ${nogo}          Set Variable  null
   ${wrn}           Set Variable  warning
   ${inf}           Set Variable  info
   ${err}           Set Variable  error
   ${tt_s}          Set Variable  ${tt_3s}
   ${tt_policy}     Set Variable  ${tt_3s}
   ${cpu_util_val}  Set Variable  ${cpu_util_val}
   ${mem_util_val}  Set Variable  ${mem_util_val}
   ${dsk_util_val}  Set Variable  ${dsk_util_val}
   ${acx_util_val}  Set Variable  ${acx_util_val}
   ${cpu_trig_val}  Set Variable  ${cpu_trig_val}
   ${mem_trig_val}  Set Variable  ${mem_trig_val}
   ${dsk_trig_val}  Set Variable  ${dsk_trig_val}
   ${acx_trig_val}  Set Variable  ${acx_trig_val}
#Updating alert policies if exists
   ${cpu_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${CPUpolicy}\\\\\\\\"} not found"}\\\')\')
   ${mem_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${MEMpolicy}\\\\\\\\"} not found"}\\\')\')
   ${dsk_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${DSKpolicy}\\\\\\\\"} not found"}\\\')\')
   ${acx_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"AlertPolicy key {\\\\\\\\"organization\\\\\\\\":\\\\\\\\"automation_dev_org\\\\\\\\",\\\\\\\\"name\\\\\\\\":\\\\\\\\"${ACXpolicy}\\\\\\\\"} not found"}\\\')\')
#CPU AlertPolicy
   ${cpu_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}  severity=${wrn}  trigger_time=${cpu_trig_val}  alert_org=${alert_org}     cpu_utilization=${cpu_util_val}  labels_vars=Error=CPU  annotations_vars=description=[CPU] Error on 8086 critical consumption app needs 1.21 gigawatts of CPU power  description=description-cpu
   ${nogo}=  Run Keyword If  ${cpu_err}==${cpu_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${CPU_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${cpu_err}!=${cpu_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${CPU_policy} was updated
   ${cpu_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${CPU_policy}
   ${cpu_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['severity']}
   ${cpu_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${cpu_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${cpu_plcy_trig}  ${cpu_trig_val}
#MEM AlertPolicy
   ${mem_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}  severity=${wrn}  trigger_time=${mem_trig_val}  alert_org=${alert_org}     mem_utilization=${mem_util_val}  labels_vars=Error=MEM  annotations_vars=description=[MEM] Error on 8086 critical consumption app needs 1.21 gigawatts of MEM power  description=description-mem
   ${nogo}=  Run Keyword If  ${mem_err}==${mem_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${MEM_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${mem_err}!=${mem_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${MEM_policy} was updated
   ${mem_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${MEM_policy}
   ${mem_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['severity']}
   ${mem_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${mem_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${mem_plcy_trig}  ${mem_trig_val}
#DSK AlertPolicy
   ${dsk_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}  severity=${wrn}  trigger_time=${dsk_trig_val}  alert_org=${alert_org}    disk_utilization=${dsk_util_val}  labels_vars=Error=DSK  annotations_vars=description=[DSK] Error on 8086 critical consumption app needs 1.21 gigawatts of DSK power  description=description-dsk
   ${nogo}=  Run Keyword If  ${dsk_err}==${dsk_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${DSK_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${dsk_err}!=${dsk_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${DSK_policy} was updated
   ${dsk_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${DSK_policy}
   ${dsk_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['severity']}
   ${dsk_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${dsk_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${dsk_plcy_trig}  ${dsk_trig_val}
#ACX AlertPolicy
   ${acx_policy_name}=  Run Keyword And Ignore Error    Update Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}  severity=${wrn}  trigger_time=${acx_trig_val}  alert_org=${alert_org}  active_connections=${acx_util_val}  labels_vars=Error=ACX  annotations_vars=description=[ACX] Error on 8086 critical consumption app needs 1.21 gigawatts of ACX power  description=description-acx
   ${nogo}=  Run Keyword If  ${acx_err}==${acx_policy_name}  Set Variable  ${False}
   Run Keyword If  '${nogo}'=='${False}'  Log To Console  ${\n}${ACX_policy} does not exists not updated
   ${nogo}=  Run Keyword If  ${acx_err}!=${acx_policy_name}  Set Variable  ${True}
   Run Keyword If  '${nogo}'=='${True}'  Log To Console  ${\n}${ACX_policy} was updated
   ${acx_plcy_show}=  Run Keyword If  '${nogo}'=='${True}'  Show Alert Policy  token=${super_token}  region=${region}  alertpolicy_name=${ACX_policy}
   ${acx_plcy_sev}=   Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['severity']}
   ${acx_plcy_trig}=  Run Keyword If  '${nogo}'=='${True}'  Convert To String  ${acx_plcy_show[0]['data']['trigger_time']}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_sev}   ${wrn}
   Run Keyword If  '${nogo}'=='${True}'  Should Be Equal  ${acx_plcy_trig}  ${acx_trig_val}
   Sleep  2seconds

Add Policies To App
#Adding alert policies to app if does not  exist
   ${cpu_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert ${CPUpolicy} already monitored on App"}\\\')\') 
   ${mem_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert ${MEMpolicy} already monitored on App"}\\\')\')
   ${dsk_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert ${DSKpolicy} already monitored on App"}\\\')\')
   ${acx_err}  Set Variable  (\'FAIL\', \'(\\\'code=400\\\', \\\'error={"message":"Alert ${ACXpolicy} already monitored on App"}\\\')\') 
#CPU AlertPolicy
   ${cpu_policy_add}=  Run Keyword And Ignore Error    Add Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${CPU_policy}  app_org=${app_org}
   Run Keyword If      ${cpu_err}==${cpu_policy_add}    Log To Console  ${\n}${CPU_policy} already added not adding to app ${app_name}
   Run Keyword If      ${cpu_err}!=${cpu_policy_add}    Log To Console  ${\n}${CPU_policy} added to ${app_name}
   Sleep  2seconds
#MEM AlertPolicy
   ${mem_policy_add}=  Run Keyword And Ignore Error    Add Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${MEM_policy}  app_org=${app_org}
   Run Keyword If      ${mem_err}==${mem_policy_add}    Log To Console  ${\n}${MEM_policy} already added not adding to app ${app_name}
   Run Keyword If      ${mem_err}!=${mem_policy_add}    Log To Console  ${\n}${MEM_policy} added to ${app_name}
   Sleep  2seconds   
#DSK AlertPolicy
   ${dsk_policy_add}=  Run Keyword And Ignore Error    Add Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${DSK_policy}  app_org=${app_org}
   Run Keyword If      ${dsk_err}==${dsk_policy_add}    Log To Console  ${\n}${DSK_policy} already added not adding to app ${app_name}
   Run Keyword If      ${dsk_err}!=${dsk_policy_add}    Log To Console  ${\n}${DSK_policy} added to ${app_name}
   Sleep  2seconds
#ACX AlertPolicy
   ${acx_policy_add}=  Run Keyword And Ignore Error    Add Alert Policy App  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  alert_policy=${ACX_policy}  app_org=${app_org}
   Run Keyword If      ${acx_err}==${acx_policy_add}    Log To Console  ${\n}${ACX_policy} already added not adding to app ${app_name}
   Run Keyword If      ${acx_err}!=${acx_policy_add}    Log To Console  ${\n}${ACX_policy} added to ${app_name}
   Sleep  2seconds

Show Alert Policies From App
    ${super_token}  Get Super Token
    Set Suite Variable  ${super_token}
    ${policy_show_app}=  Run Keyword  Show Apps  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}
    ${app_alerts_added}  Convert To String  ${policy_show_app[0]['data']['alert_policies']}
    Set Variable  ${app_alerts_added}
    @{alert_list}  Create List  ${app_alerts_added}
    Run Keyword  Should Contain   @{alert_list}  ${CPU_policy}
    Run Keyword  Should Contain   @{alert_list}  ${MEM_policy}
    Run Keyword  Should Contain   @{alert_list}  ${DSK_policy}
    Run Keyword  Should Contain   @{alert_list}  ${ACX_policy}
    Log To Console  ${app_alerts_added}


Setup Runcommand To Run Measurments
   
   ${uri_check}=  Show App Instances  token=${super_token}  region=${region}  app_name=${app_name}  region=${region}  app_version=${app_version}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}

   ${uri_val}=  Set Variable  ${uri_check}[0][data][uri]
   ${uri_val}=  Convert To Lowercase  ${uri_val}

   Sleep  ${poll_time}
   ${script_runtime}        Set Variable   ${script2_runtime}
   ${script_primer}         Set Variable   ${script_primer}
   ${command_script_sh}     Set Variable   sh all_measurements.sh ${script_runtime}
   ${command_script_sh2}    Set Variable   sh all_measurements.sh ${script_primer}
   ${command_script_delay}  Set Variable   ${command_script_delay}
   ${public_tcp_port}       Set Variable   ${public_port_val}
   ${command_script}=            Catenate  SEPARATOR=   ${command_script_sh} ${EMPTY}${uri_val} ${EMPTY}${command_script_delay}
   ${command_script2}=           Catenate  SEPARATOR=   ${command_script_sh2} ${EMPTY}${uri_val} ${EMPTY}${command_script_delay}
   ${command_script_pubprime1}=  Catenate  SEPARATOR=   ${command_script_sh2} ${EMPTY}${uri_val} ${EMPTY}${public_tcp_port} ${EMPTY}${command_script_delay}
   ${command_script_pubmain1}=   Catenate  SEPARATOR=   ${command_script_sh} ${EMPTY}${uri_val} ${EMPTY}${public_tcp_port} ${EMPTY}${command_script_delay}
   ${command_script}=            Convert To Lowercase  ${command_script}
   ${command_script2}=           Convert To Lowercase  ${command_script2}
   ${command_script_pubprime1}=  Convert To Lowercase  ${command_script_pubprime1}
   ${command_script_pubmain1}=   Convert To Lowercase  ${command_script_pubmain1}
   #test url in case error will show in log
   ##using runcommand to do a ls on the appinst first in case pod is in a bad state. EC-5971 see notes on that
   ${url_error_test}=  Run Keyword And Ignore Error  Run Command  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name_automation}  cluster_instance_developer_org_name=${developer_org_name_automation}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  timeout=${timeout}  command=ls
   ${url_error_test}=  Convert To String  ${url_error_test}
   Log To Console  ${url_error_test}

   ${run_script_main}=  Run Command  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name_automation}  cluster_instance_developer_org_name=${developer_org_name_automation}  cluster_instance_name=${cluster_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  timeout=${timeout}  command=${command_script_pubmain1}
   Log To Console  Running script commands on appinst for measurements ${\n}${command_script_pubmain1}


Get Metrics Primer
   FOR  ${i}  IN RANGE  ${loop_5}
   Sleep  ${poll_time}
    ${cpu_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=cpu  last=1
    ${mem_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=mem  last=1
    ${dsk_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=disk  last=1
    ${acx_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=connections  last=1

   FOR  ${i}  IN RANGE  ${loop_10}
       IF  ${cpu_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${cpu_metric_name}=  Convert To String  ${cpu_metrics['data'][0]['Series'][0]['columns'][9]}
           ${cpu_metric_val}=  Convert To String  ${cpu_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${mem_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${mem_metric_name}=  Convert To String  ${mem_metrics['data'][0]['Series'][0]['columns'][9]}
           ${mem_metric_val}=  Convert To String  ${mem_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${dsk_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${dsk_metric_name}=  Convert To String  ${dsk_metrics['data'][0]['Series'][0]['columns'][9]}
           ${dsk_metric_val}=  Convert To String  ${dsk_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${acx_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${acx_metric_name}=  Convert To String  ${acx_metrics['data'][0]['Series'][0]['columns'][9]}
           ${acx_metric_val}=  Convert To String  ${acx_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
   Exit For Loop If  ${cpu_metrics} and ${mem_metrics} and ${dsk_metrics} and ${acx_metrics} != {'data': [{'Series': None, 'Messages': None}]}
   Sleep  ${poll_time}
   END
   END
   Log To Console  ${\n}There should be metrics if so then  runcommand and appinst are working if no metrics this test most likely will fail
   Log To Console  ${cpu_metric_name}=${cpu_metric_val} %
   Log To Console  ${mem_metric_name}=${mem_metric_val} Bytes
   Log To Console  ${dsk_metric_name}=${dsk_metric_val} Bytes
   Log To Console  ${acx_metric_val} active connections if 0 something went wrong
   Log To Console  ${\n}This was a primer check that influx has data before testing alert policy triggers


Show Alerts Firing
    Set Suite Variable  ${alertname_totals}   0
    Set Suite Variable  ${firing_totals}      0
    Set Suite Variable  ${cpu_firing_total}   0
    Set Suite Variable  ${mem_firing_total}   0
    Set Suite Variable  ${dsk_firing_total}   0
    Set Suite Variable  ${acx_firing_total}   0
    Set Suite Variable  ${cpu_firing_cnt}     0
    Set Suite Variable  ${mem_firing_cnt}     0
    Set Suite Variable  ${dsk_firing_cnt}     0
    Set Suite Variable  ${acx_firing_cnt}     0
    Set Suite Variable  ${cpu_firing_val}     0
    Set Suite Variable  ${mem_firing_val}     0
    Set Suite Variable  ${dsk_firing_val}     0
    Set Suite Variable  ${acx_firing_val}     0
    Set Suite Variable  ${cpu_alertname_total}   0
    Set Suite Variable  ${mem_alertname_total}   0
    Set Suite Variable  ${dsk_alertname_total}   0
    Set Suite Variable  ${acx_alertname_total}   0
    Set Suite Variable  ${cpu_alertname_cnt}     0
    Set Suite Variable  ${mem_alertname_cnt}     0
    Set Suite Variable  ${dsk_alertname_cnt}     0
    Set Suite Variable  ${acx_alertname_cnt}     0
    Set Suite Variable  ${cpu_alertname_val}     0
    Set Suite Variable  ${mem_alertname_val}     0
    Set Suite Variable  ${dsk_alertname_val}     0
    Set Suite Variable  ${acx_alertname_val}     0
    Set Suite Variable  ${loop_c}   20
    Set Suite Variable  ${loop_5}    5
    Set Suite Variable  ${loop_10}  10
    Set Suite Variable  ${loop_15}  15
    Set Suite Variable  ${loop_20}  20
    Set Suite Variable  ${poll_time}  5seconds

   FOR  ${i}  IN RANGE  ${loop_c}
   Log To Console  ${\n}Waiting for triggers >=1 ${CPU_policy}=${cpu_firing_total} ${MEM_policy}=${mem_firing_total} ${DSK_policy}=${dsk_firing_total} ${ACX_policy}=${acx_firing_total}

         ${cpu_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${CPU_policy}
         ${len_cpu}=  Get Length  ${cpu_firing}
         Sleep  1seconds
         IF  ${len_cpu} > 0
            ${cpu_firing_cnt}=     Get Count  ${cpu_firing}$[key][data][state]  firing
            ${cpu_alertname_cnt}=  Get Count  ${cpu_firing}$[key][data][labels][alertname]  ${CPU_policy}
            ${cpu_firing_val}=     Convert To String  ${cpu_firing}[0][data][value]
            ${cpu_alertname_val}=  Convert To String  ${cpu_firing}[0][data][labels][alertname]
            ${cpu_firing_total}=     Evaluate  ${cpu_firing_cnt} + ${cpu_firing_total} + 0
            ${cpu_alertname_total}=  Evaluate  ${cpu_alertname_cnt} + ${cpu_alertname_total} + 0
            Run Keywords   Should Contain  ${cpu_alertname_val}  ${CPU_policy}    AND  Log To Console  CPU alert name firing was ${cpu_alertname_val}
            Log To Console  CPU alert utilization value=${cpu_util_val}% firing value=${cpu_firing_val}%
            END
         ${mem_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${MEM_policy}
         ${len_mem}=  Get Length  ${mem_firing}
         Sleep  1seconds
         IF  ${len_mem} > 0
            ${mem_firing_cnt}=     Get Count  ${mem_firing}$[key][data][state]  firing
            ${mem_alertname_cnt}=  Get Count  ${mem_firing}$[key][data][labels][alertname]  ${MEM_policy}
            ${mem_firing_val}=     Convert To String  ${mem_firing}[0][data][value]
            ${mem_alertname_val}=  Convert To String  ${mem_firing}[0][data][labels][alertname]
            ${mem_firing_total}=     Evaluate  ${mem_firing_cnt} + ${mem_firing_total} + 0
            ${mem_alertname_total}=  Evaluate  ${mem_alertname_cnt} + ${mem_alertname_total} + 0
            Run Keywords   Should Contain  ${mem_alertname_val}  ${MEM_policy}    AND  Log To Console  MEM alert name firing was ${mem_alertname_val}
            Log To Console  MEM alert utilization value=${mem_util_val}% firing value=${mem_firing_val} GB
            END
         ${dsk_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${DSK_policy}
         ${len_dsk}=  Get Length  ${dsk_firing}
         Sleep  1seconds
         IF  ${len_dsk} > 0
            ${dsk_firing_cnt}=     Get Count  ${dsk_firing}$[key][data][state]  firing
            ${dsk_alertname_cnt}=  Get Count  ${dsk_firing}$[key][data][labels][alertname]  ${DSK_policy}
            ${dsk_firing_val}=     Convert To String  ${dsk_firing}[0][data][value]
            ${dsk_alertname_val}=  Convert To String  ${dsk_firing}[0][data][labels][alertname]
            ${dsk_firing_total}=     Evaluate  ${dsk_firing_cnt} + ${dsk_firing_total} + 0
            ${dsk_alertname_total}=  Evaluate  ${dsk_alertname_cnt} + ${dsk_alertname_total} + 0
            Run Keywords   Should Contain  ${dsk_alertname_val}  ${DSK_policy}    AND  Log To Console  DSK alert name firing was ${dsk_alertname_val}
            Log To Console  DSK alert utilization value=${dsk_util_val}% firing value=${dsk_firing_val} GB
            END
         ${acx_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${ACX_policy}
         ${len_acx}=  Get Length  ${acx_firing}
         Sleep  1seconds
         IF  ${len_acx} > 0
            ${acx_firing_cnt}=     Get Count  ${acx_firing}$[key][data][state]  firing
            ${acx_alertname_cnt}=  Get Count  ${acx_firing}$[key][data][labels][alertname]  ${ACX_policy}
            ${acx_firing_val}=     Convert To String  ${acx_firing}[0][data][value]
            ${acx_alertname_val}=  Convert To String  ${acx_firing}[0][data][labels][alertname]
            ${acx_firing_total}=     Evaluate  ${acx_firing_cnt} + ${acx_firing_total} + 0
            ${acx_alertname_total}=  Evaluate  ${acx_alertname_cnt} + ${acx_alertname_total} + 0
            Run Keywords   Should Contain  ${acx_alertname_val}  ${ACX_policy}    AND  Log To Console  ACX alert name firing was ${acx_alertname_val}
            Log To Console  ACX alert utilization value=${acx_util_val}% firing value=${acx_firing_val} connections
            END
   Sleep  ${poll_time} 
   ${alertname_totals}=     Evaluate  ${cpu_alertname_total} + ${mem_alertname_total} + ${dsk_alertname_total} + ${acx_alertname_total} + 0 
   ${firing_totals}=        Evaluate  ${cpu_firing_total} + ${mem_firing_total} + ${dsk_firing_total} + ${acx_firing_total} + 0
   Log To Console  ${\n}Waiting Fire>0 for ${CPU_policy}=${cpu_firing_total} ${MEM_policy}=${mem_firing_total} ${DSK_policy}=${dsk_firing_total} ${ACX_policy}=${acx_firing_total} BIGloop ${i}of${loop_c} FT-all=${firing_totals}
   Log To Console  ${\n}Waiting Name>0 for ${CPU_policy}=${cpu_alertname_total} ${MEM_policy}=${mem_alertname_total} ${DSK_policy}=${dsk_alertname_total} ${ACX_policy}=${acx_alertname_total} BIGloop ${i}of${loop_c} AN-all=${alertname_totals}
   Exit For Loop If  ${cpu_firing_total} and ${mem_firing_total} and ${dsk_firing_total} and ${acx_firing_total} > 0
   Exit For Loop If  ${cpu_alertname_total} and ${mem_alertname_total} and ${dsk_alertname_total} and ${acx_alertname_total} > 0
   END
    #Get influx metrics to compare to alerts trigger
    ${cpu_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=cpu  last=1
    Sleep  1seconds
    ${mem_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=mem  last=1
    Sleep  1seconds
    ${dsk_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=disk  last=1
    Sleep  1seconds
    ${acx_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=connections  last=1
    Log To Console  ${cpu_metrics}
       IF  ${cpu_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${cpu_metric_name}=  Convert To String  ${cpu_metrics['data'][0]['Series'][0]['columns'][9]}
           ${cpu_metric_val}=  Convert To String  ${cpu_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${mem_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${mem_metric_name}=  Convert To String  ${mem_metrics['data'][0]['Series'][0]['columns'][9]}
           ${mem_metric_val}=  Convert To String  ${mem_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${dsk_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${dsk_metric_name}=  Convert To String  ${dsk_metrics['data'][0]['Series'][0]['columns'][9]}
           ${dsk_metric_val}=  Convert To String  ${dsk_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${acx_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${acx_metric_name}=  Convert To String  ${acx_metrics['data'][0]['Series'][0]['columns'][9]}
           ${acx_metric_val}=  Convert To String  ${acx_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
         Log To Console  ${\n}There should be metrics 
         Log To Console  ${cpu_metric_name}=${cpu_metric_val} %
         Log To Console  ${mem_metric_name}=${mem_metric_val} Bytes
         Log To Console  ${dsk_metric_name}=${dsk_metric_val} Bytes
         Log To Console  ${acx_metric_val} active connections
         Log To Console  ${\n}These results should have triggered all 4 triggers in one test

   Run Keywords   Should Be True  ${cpu_firing_total} > 0   AND   Log To Console  ${\n}${CPU_policy} alert triggered CPU alert utilization value=${cpu_util_val}% firing value=${cpu_firing_val}%
   Run Keywords   Should Be True  ${mem_firing_total} > 0   AND   Log To Console  ${MEM_policy} alert triggered MEM alert utilization value=${mem_util_val}% firing value=${mem_firing_val} Bytes
   Run Keywords   Should Be True  ${dsk_firing_total} > 0   AND   Log To Console  ${DSK_policy} alert triggered DSK alert utilization value=${dsk_util_val}% firing value=${dsk_firing_val} Bytes
   Run Keywords   Should Be True  ${acx_firing_total} > 0   AND   Log To Console  ${ACX_policy} tirigger value active-connections=${acx_util_val} firing value=${acx_firing_val} active connections
#   Log To Console  ${\n}${CPU_policy} alert triggered CPU alert utilization value=${cpu_util_val}% firing value=${cpu_firing_val}%
#   Log To Console  ${MEM_policy} alert triggered MEM alert utilization value=${mem_util_val}% firing value=${mem_firing_val} Bytes
#   Log To Console  ${DSK_policy} alert triggered DSK alert utilization value=${dsk_util_val}% firing value=${dsk_firing_val} Bytes
#   Log To Console  ${ACX_policy} tirigger value active-connections=${acx_util_val} firing value=${acx_firing_val} active connections

Show Alerts Firing Primer
    Set Suite Variable  ${alertname_totals}   0
    Set Suite Variable  ${firing_totals}      0
    Set Suite Variable  ${cpu_firing_total}   0
    Set Suite Variable  ${mem_firing_total}   0
    Set Suite Variable  ${dsk_firing_total}   0
    Set Suite Variable  ${acx_firing_total}   0
    Set Suite Variable  ${cpu_firing_cnt}     0
    Set Suite Variable  ${mem_firing_cnt}     0
    Set Suite Variable  ${dsk_firing_cnt}     0
    Set Suite Variable  ${acx_firing_cnt}     0
    Set Suite Variable  ${cpu_firing_val}     0
    Set Suite Variable  ${mem_firing_val}     0
    Set Suite Variable  ${dsk_firing_val}     0
    Set Suite Variable  ${acx_firing_val}     0
    Set Suite Variable  ${cpu_alertname_total}   0
    Set Suite Variable  ${mem_alertname_total}   0
    Set Suite Variable  ${dsk_alertname_total}   0
    Set Suite Variable  ${acx_alertname_total}   0
    Set Suite Variable  ${cpu_alertname_cnt}     0
    Set Suite Variable  ${mem_alertname_cnt}     0
    Set Suite Variable  ${dsk_alertname_cnt}     0
    Set Suite Variable  ${acx_alertname_cnt}     0
    Set Suite Variable  ${cpu_alertname_val}     0
    Set Suite Variable  ${mem_alertname_val}     0
    Set Suite Variable  ${dsk_alertname_val}     0
    Set Suite Variable  ${acx_alertname_val}     0
    Set Suite Variable  ${loop_c}   5
    Set Suite Variable  ${loop_20}  20
    Set Suite Variable  ${primer_poll_time}  35seconds
   Log To Console  This is a primer to wait for stats in influxdb
   FOR  ${i}  IN RANGE  ${loop_c}
   Log To Console  ${\n}Monitoring triggers >=1 ${CPU_policy}=${cpu_firing_total} ${MEM_policy}=${mem_firing_total} ${DSK_policy}=${dsk_firing_total} ${ACX_policy}=${acx_firing_total}

         ${cpu_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${CPU_policy}
         ${len_cpu}=  Get Length  ${cpu_firing}
         Sleep  1seconds
         IF  ${len_cpu} > 0
            ${cpu_firing_cnt}=     Get Count  ${cpu_firing}$[key][data][state]  firing
            ${cpu_alertname_cnt}=  Get Count  ${cpu_firing}$[key][data][labels][alertname]  ${CPU_policy}
            ${cpu_firing_val}=     Convert To String  ${cpu_firing}[0][data][value]
            ${cpu_alertname_val}=  Convert To String  ${cpu_firing}[0][data][labels][alertname]
            ${cpu_firing_total}=     Evaluate  ${cpu_firing_cnt} + ${cpu_firing_total} + 0
            ${cpu_alertname_total}=  Evaluate  ${cpu_alertname_cnt} + ${cpu_alertname_total} + 0
            Run Keywords   Should Contain  ${cpu_alertname_val}  ${CPU_policy}    AND  Log To Console  CPU alert name firing was ${cpu_alertname_val}
            Log To Console  CPU alert utilization value=${cpu_util_val}% firing value=${cpu_firing_val}%
            END
         ${mem_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${MEM_policy}
         ${len_mem}=  Get Length  ${mem_firing}
         Sleep  1seconds
         IF  ${len_mem} > 0
            ${mem_firing_cnt}=     Get Count  ${mem_firing}$[key][data][state]  firing
            ${mem_alertname_cnt}=  Get Count  ${mem_firing}$[key][data][labels][alertname]  ${MEM_policy}
            ${mem_firing_val}=     Convert To String  ${mem_firing}[0][data][value]
            ${mem_alertname_val}=  Convert To String  ${mem_firing}[0][data][labels][alertname]
            ${mem_firing_total}=     Evaluate  ${mem_firing_cnt} + ${mem_firing_total} + 0
            ${mem_alertname_total}=  Evaluate  ${mem_alertname_cnt} + ${mem_alertname_total} + 0
            Run Keywords   Should Contain  ${mem_alertname_val}  ${MEM_policy}    AND  Log To Console  MEM alert name firing was ${mem_alertname_val}
            Log To Console  MEM alert utilization value=${mem_util_val}% firing value=${mem_firing_val} GB
            END
         ${dsk_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${DSK_policy}
         ${len_dsk}=  Get Length  ${dsk_firing}
         Sleep  1seconds
         IF  ${len_dsk} > 0
            ${dsk_firing_cnt}=     Get Count  ${dsk_firing}$[key][data][state]  firing
            ${dsk_alertname_cnt}=  Get Count  ${dsk_firing}$[key][data][labels][alertname]  ${DSK_policy}
            ${dsk_firing_val}=     Convert To String  ${dsk_firing}[0][data][value]
            ${dsk_alertname_val}=  Convert To String  ${dsk_firing}[0][data][labels][alertname]
            ${dsk_firing_total}=     Evaluate  ${dsk_firing_cnt} + ${dsk_firing_total} + 0
            ${dsk_alertname_total}=  Evaluate  ${dsk_alertname_cnt} + ${dsk_alertname_total} + 0
            Run Keywords   Should Contain  ${dsk_alertname_val}  ${DSK_policy}    AND  Log To Console  DSK alert name firing was ${dsk_alertname_val}
            Log To Console  DSK alert utilization value=${dsk_util_val}% firing value=${dsk_firing_val} GB
            END
         ${acx_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${ACX_policy}
         ${len_acx}=  Get Length  ${acx_firing}
         Sleep  1seconds
         IF  ${len_acx} > 0
            ${acx_firing_cnt}=     Get Count  ${acx_firing}$[key][data][state]  firing
            ${acx_alertname_cnt}=  Get Count  ${acx_firing}$[key][data][labels][alertname]  ${ACX_policy}
            ${acx_firing_val}=     Convert To String  ${acx_firing}[0][data][value]
            ${acx_alertname_val}=  Convert To String  ${acx_firing}[0][data][labels][alertname]
            ${acx_firing_total}=     Evaluate  ${acx_firing_cnt} + ${acx_firing_total} + 0
            ${acx_alertname_total}=  Evaluate  ${acx_alertname_cnt} + ${acx_alertname_total} + 0
            Run Keywords   Should Contain  ${acx_alertname_val}  ${ACX_policy}    AND  Log To Console  ACX alert name firing was ${acx_alertname_val}
            Log To Console  ACX alert utilization value=${acx_util_val}% firing value=${acx_firing_val} connections
            END
   Sleep  ${primer_poll_time}
   ${alertname_totals}=     Evaluate  ${cpu_alertname_total} + ${mem_alertname_total} + ${dsk_alertname_total} + ${acx_alertname_total} + 0
   ${firing_totals}=        Evaluate  ${cpu_firing_total} + ${mem_firing_total} + ${dsk_firing_total} + ${acx_firing_total} + 0
   Log To Console  ${\n}Waiting Fire>0 for ${CPU_policy}=${cpu_firing_total} ${MEM_policy}=${mem_firing_total} ${DSK_policy}=${dsk_firing_total} ${ACX_policy}=${acx_firing_total} BIGloop ${i}of${loop_c} FT-all=${firing_totals}
   Log To Console  ${\n}Monitoring Name>0 for ${CPU_policy}=${cpu_alertname_total} ${MEM_policy}=${mem_alertname_total} ${DSK_policy}=${dsk_alertname_total} ${ACX_policy}=${acx_alertname_total} BIGloop ${i}of${loop_c} AN-all=${alertname_totals}
   Exit For Loop If  ${cpu_firing_total} and ${mem_firing_total} and ${dsk_firing_total} and ${acx_firing_total} > 0
   Exit For Loop If  ${cpu_alertname_total} and ${mem_alertname_total} and ${dsk_alertname_total} and ${acx_alertname_total} > 0
   END
    #Get influx metrics to compare to alerts trigger
    ${cpu_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=cpu  last=1
    Sleep  1seconds
    ${mem_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=mem  last=1
    Sleep  1seconds
    ${dsk_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=disk  last=1
    Sleep  1seconds
    ${acx_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=connections  last=1
    Log To Console  ${cpu_metrics}
       IF  ${cpu_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${cpu_metric_name}=  Convert To String  ${cpu_metrics['data'][0]['Series'][0]['columns'][9]}
           ${cpu_metric_val}=  Convert To String  ${cpu_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${mem_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${mem_metric_name}=  Convert To String  ${mem_metrics['data'][0]['Series'][0]['columns'][9]}
           ${mem_metric_val}=  Convert To String  ${mem_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${dsk_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${dsk_metric_name}=  Convert To String  ${dsk_metrics['data'][0]['Series'][0]['columns'][9]}
           ${dsk_metric_val}=  Convert To String  ${dsk_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${acx_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${acx_metric_name}=  Convert To String  ${acx_metrics['data'][0]['Series'][0]['columns'][9]}
           ${acx_metric_val}=  Convert To String  ${acx_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
   Log To Console  ${\n}Metrics should be reporting before triggers can be tested
   Run Keyword If  ${cpu_metric_val} >= 0  Log To Console  ${cpu_metric_name}=${cpu_metric_val} %
   Run Keyword If  ${mem_metric_val} >= 0  Log To Console  ${mem_metric_name}=${mem_metric_val} Bytes
   Run Keyword If  ${dsk_metric_val} >= 0  Log To Console  ${dsk_metric_name}=${dsk_metric_val} Bytes
   Run Keyword If  ${acx_metric_val} >= 0  Log To Console  ${acx_metric_val} active connections
   Log To Console  ${\n}These results are a primer and should not show Message None error
   Log To Console  ${\n}Testing output format for trigger value and firing value
   Log To Console  ${\n}${CPU_policy} alert triggered CPU alert utilization value=${cpu_util_val}% firing value=${cpu_firing_val}%
   Log To Console  ${MEM_policy} alert triggered MEM alert utilization value=${mem_util_val}% firing value=${mem_firing_val} Bytes
   Log To Console  ${DSK_policy} alert triggered DSK alert utilization value=${dsk_util_val}% firing value=${dsk_firing_val} Bytes
   Log To Console  ${ACX_policy} tirigger value active-connections=${acx_util_val} firing value=${acx_firing_val} active connections

Show Alerts Cleared
    Set Suite Variable  ${firing_totals}      0
    Set Suite Variable  ${cpu_firing_total}   0
    Set Suite Variable  ${mem_firing_total}   0
    Set Suite Variable  ${dsk_firing_total}   0
    Set Suite Variable  ${acx_firing_total}   0
    Set Suite Variable  ${cpu_firing_cnt}     0
    Set Suite Variable  ${mem_firing_cnt}     0
    Set Suite Variable  ${dsk_firing_cnt}     0
    Set Suite Variable  ${acx_firing_cnt}     0
    Set Suite Variable  ${cpu_firing_val}     0
    Set Suite Variable  ${mem_firing_val}     0
    Set Suite Variable  ${dsk_firing_val}     0
    Set Suite Variable  ${acx_firing_val}     0
   Log To Console  Waiting ${alert_clear_delay} before polling
   Sleep  ${alert_clear_delay}
   FOR  ${i}  IN RANGE  ${loop_10}
         ${cpu_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${CPU_policy}
         ${len_cpu}=  Get Length  ${cpu_firing}
         ${mem_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${MEM_policy}
         ${len_mem}=  Get Length  ${mem_firing}
         ${dsk_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${DSK_policy}
         ${len_dsk}=  Get Length  ${dsk_firing}
         ${acx_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${ACX_policy}
         ${len_acx}=  Get Length  ${acx_firing}

         ${cpu_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${CPU_policy}
         ${len_cpu}=  Get Length  ${cpu_firing}         
         IF  ${len_cpu} <= 0
            ${cpu_firing_cnt}=     Get Count  ${cpu_firing}$[key][data][state]  firing
            ${cpu_firing_val}=     Convert To String  ${cpu_firing_cnt}
            ${cpu_firing_total}=   Evaluate  ${cpu_firing_val} + ${cpu_firing_total} + 0
            END
         ${mem_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${MEM_policy}
         ${len_mem}=  Get Length  ${mem_firing}
         IF  ${len_mem} <= 0
            ${mem_firing_cnt}=     Get Count  ${mem_firing}$[key][data][state]  firing
            ${mem_firing_val}=     Convert To String  ${mem_firing_cnt}
            ${mem_firing_total}=   Evaluate  ${mem_firing_val} + ${mem_firing_total} + 0
            END
         ${dsk_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${DSK_policy}
         ${len_dsk}=  Get Length  ${dsk_firing}
         IF  ${len_dsk} <= 0
            ${dsk_firing_cnt}=     Get Count  ${dsk_firing}$[key][data][state]  firing
            ${dsk_firing_val}=     Convert To String  ${dsk_firing_cnt}
            ${dsk_firing_total}=   Evaluate  ${dsk_firing_val} + ${dsk_firing_total} + 0
            END
         ${acx_firing}=  Run Keyword  Show Alerts  token=${super_token}  region=${region}  alert_name=${ACX_policy}
         ${len_acx}=  Get Length  ${acx_firing}
         IF  ${len_acx} <= 0
            ${acx_firing_cnt}=     Get Count  ${acx_firing}$[key][data][state]  firing
            ${acx_firing_val}=     Convert To String  ${acx_firing_cnt}
            ${acx_firing_total}=   Evaluate  ${acx_firing_val} + ${acx_firing_total} + 0
            END

   Log To Console  ${\n}Waiting for alerts to clear ${CPU_policy}=${len_cpu} ${MEM_policy}=${len_mem} ${DSK_policy}=${len_acx} ${ACX_policy}=${len_acx} loop ${i} of ${loop_10}
   ${firing_totals}=         Evaluate   ${cpu_firing_total} + ${mem_firing_total} + ${dsk_firing_total} + ${acx_firing_total} + 0
   Exit For Loop If  ${firing_totals} <= 0
   Sleep  ${poll_time}
   END
   #Check influx metrics values - note trigger time being over the value set is checked by polling this is just informational at this point
    ${cpu_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=cpu  last=1
    ${mem_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=mem  last=1
    ${dsk_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=disk  last=1
    ${acx_metrics}=  Run Keyword  Get App Metrics  token=${super_token}  region=${region}  app_name=${app_name}  app_version=${app_version}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}  selector=connections  last=1
   FOR  ${i}  IN RANGE  ${loop_10}
       IF  ${cpu_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${cpu_metric_name}=  Convert To String  ${cpu_metrics['data'][0]['Series'][0]['columns'][9]}
           ${cpu_metric_val}=  Convert To String  ${cpu_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${mem_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${mem_metric_name}=  Convert To String  ${mem_metrics['data'][0]['Series'][0]['columns'][9]}
           ${mem_metric_val}=  Convert To String  ${mem_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${dsk_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${dsk_metric_name}=  Convert To String  ${dsk_metrics['data'][0]['Series'][0]['columns'][9]}
           ${dsk_metric_val}=  Convert To String  ${dsk_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
       IF  ${acx_metrics} != {'data': [{'Series': None, 'Messages': None}]}
           ${acx_metric_name}=  Convert To String  ${acx_metrics['data'][0]['Series'][0]['columns'][9]}
           ${acx_metric_val}=  Convert To String  ${acx_metrics['data'][0]['Series'][0]['values'][0][9]}
           END
   Exit For Loop If  ${cpu_metrics} and ${mem_metrics} and ${dsk_metrics} and ${acx_metrics} != {'data': [{'Series': None, 'Messages': None}]}
   Sleep  ${poll_time}
   END
    Run Keywords   Should Be True  ${cpu_firing_total} <= 0   AND   Log To Console  ${\n}${cpu_metric_name}=${cpu_metric_val}
    Run Keywords   Should Be True  ${mem_firing_total} <= 0   AND   Log To Console  ${mem_metric_name}=${mem_metric_val}
    Run Keywords   Should Be True  ${dsk_firing_total} <= 0   AND   Log To Console  ${dsk_metric_name}=${dsk_metric_val}
    Run Keywords   Should Be True  ${acx_firing_total} <= 0   AND   Log To Console  ${acx_metric_name}=${acx_metric_val}

    Log To Console  ${\n}${CPU_policy} alert cleared CPU alert utilization value=${cpu_util_val}% cleared ${cpu_metric_name}=${cpu_metric_val} %
    Log To Console  ${MEM_policy} alert cleared MEM alert utilization value=${mem_util_val}% cleared ${mem_metric_name}=${mem_metric_val} Bytes
    Log To Console  ${DSK_policy} alert cleared DSK alert utilization value=${dsk_util_val}% cleared ${dsk_metric_name}=${dsk_metric_val} Bytes
    Log To Console  ${ACX_policy} alert cleared ACX alert active-connections=${acx_util_val} cleared ${acx_metric_name}=${acx_metric_val} active connections

Set Variable Pass
  Set Suite Variable  ${alert_pass}       1
Set Variable Noremove
  Set Suite Variable  ${alert_no_remove}  2
Set Variable Remove
  Set Suite Variable  ${alert_remove}     3
