*** Settings ***
Documentation   Latency Edge Event Metrics Tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections

Resource  metrics_dme_library.robot

Suite Setup	Setup
Suite Teardown	Teardown Settings  ${settings_pre}

Test Timeout    240s

*** Variables ***
${region}=  US
${device_os}=  Android
${device_model}=  platos S20
${data_network_type}=  5G
${signal_strength}=  5
${signal_strength_2}=  2
${carrier_name}=  mycarrier

${cloudlet1}=  ${cloudlet_name_fake}
${cloudlet2_name}=  tmocloud-2

${cloud1_lat}=  31
${cloud1_long}=  -91
${cloud2_lat}=  35
${cloud2_long}=  -95
${cloudlet1_tile}=  -90.998922,30.993940_-91.007905,31.002985_1
${cloudlet2_tile}=  2-1990,5343-2

${dme_conn_lat}=  ${cloud1_lat}
${dme_conn_long}=  ${cloud1_long}

*** Test Cases ***
# ECQ-3426
DMEMetrics - Shall be able to get the last DME Client App Latency metric
   [Documentation]
   ...  request latency clientappusage metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get the last client app usage metric  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

DMEMetrics - Shall be able to get the last DME Client App DeviceInfo metric
   [Documentation]
   ...  request deviceinfo clientappusage metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get the last client app usage metric  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo Values Should Be Correct  ${metrics} 

DMEMetrics - Shall be able to get DME Client App Latency metrics with apporg only
   [Documentation]
   ...  request latency clientappusage metrics with apporg only
   ...  verify info is correct

   ${metrics}=  Get all client app usage metrics  app_name=${None}  app_version=${None}  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency App Should Be Found  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${True}
   Latency App Should Be Found  ${app_name}2  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${True}
   Latency App Should Be Found  ${app_name}3  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  raw=${True}


   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be True  '${m['tags']['apporg']}' == '${developer_org_name_automation}'
   END

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with apporg only
   [Documentation]
   ...  request deviceinfo clientappusage metrics with apporg only
   ...  verify info is correct

   ${metrics}=  Get all client app usage metrics  app_name=${None}  app_version=${None}  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo App Should Be Found  ${app_name}2  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be True  '${m['tags']['apporg']}' == '${developer_org_name_automation}'
   END

DMEMetrics - Shall be able to get all DME Client App Latency metric
   [Documentation]
   ...  request all latency clientappusage metrics
   ...  verify info is correct

   ${metrics}=  Get all client app usage metrics  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

DMEMetrics - Shall be able to get all DME Client App DeviceInfo metric
   [Documentation]
   ...  request all deviceinfo clientappusage metrics
   ...  verify info is correct

   ${metrics}=  Get all client app usage metrics  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - Shall be able to get DME Client App Latency metrics with starttime
   [Documentation]
   ...  request latency clientappusage metrics with starttime
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${False}

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with starttime
   [Documentation]
   ...  request deviceinfo clientappusage metrics with starttime
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - Shall be able to get DME Client App Latency metrics with endtime
   [Documentation]
   ...  request latency clientappusage metrics with endtime
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with endtime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${False}

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with endtime
   [Documentation]
   ...  request deviceinfo clientappusage metrics with endtime
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with endtime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - Shall be able to get DME Client App Latency metrics with starttime and endtime
   [Documentation]
   ...  request latency clientappusage metrics with startime and endtime
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime and endtime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${False}

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with starttime and endtime
   [Documentation]
   ...  request deviceinfo clientappusage metrics with startime and endtime
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime and endtime   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - Shall be able to get DME Client App Latency metrics with starttime and endtime and last
   [Documentation]
   ...  request latency clientappusage metrics with startime and endtime and last
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime and endtime and last   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with starttime and endtime and last
   [Documentation]
   ...  request deviceinfo clientappusage metrics with startime and endtime and last
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with starttime and endtime and last   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - Shall be able to get DME Client App Latency metrics with locationtile
   [Documentation]
   ...  request latency clientappusage metrics with locationtile
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with locationtile   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=latency  location_tile=${cloudlet1_tile}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with deviceos
   [Documentation]
   ...  request deviceinfo clientappusage metrics with deviceos
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with deviceinfo   developer_org_name=${developer_org_name_automation}  selector=deviceinfo  device_os=${device_os}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo App Should Be Found  ${app_name}2  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
       Should Be True  '${m['tags']['deviceos']}' == '${device_os}'
   END

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with devicemodel
   [Documentation]
   ...  request deviceinfo clientappusage metrics with devicemodel
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with deviceinfo   developer_org_name=${developer_org_name_automation}  selector=deviceinfo  device_model=${device_model}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo App Should Be Found  ${app_name}2  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
       Should Be True  '${m['tags']['devicemodel']}' == '${device_model}'
   END

DMEMetrics - Shall be able to get DME Client App Latency metrics with datanetworktype
   [Documentation]
   ...  request latency clientappusage metrics with datanetworktype
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with deviceinfo   developer_org_name=${developer_org_name_automation}  selector=latency  data_network_type=${data_network_type}

   Latency Metrics Headings Should Be Correct  ${metrics}

   Latency App Should Be Found  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${True}
   Latency App Should Be Found  ${app_name}2  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${True}
   Latency App Should Be Found  ${app_name}3  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  raw=${True}

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
       Should Be True  '${m['tags']['datanetworktype']}' == '${data_network_type}'
   END

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with datanetworktype
   [Documentation]
   ...  request deviceinfo clientappusage metrics with datanetworktype
   ...  verify info is correct

   #${metrics}=  Get client app usage metrics with deviceinfo   app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}  selector=deviceinfo  data_network_type=${data_network_type}
   ${metrics}=  Get client app usage metrics with deviceinfo   developer_org_name=${developer_org_name_automation}  selector=deviceinfo  data_network_type=${data_network_type}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}2  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
       Should Be True  '${m['tags']['datanetworktype']}' == '${data_network_type}'
   END

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with all deviceinfo
   [Documentation]
   ...  request deviceinfo clientappusage metrics with all deviceinfo
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with deviceinfo   developer_org_name=${developer_org_name_automation}  selector=deviceinfo  device_os=${device_os}  device_model=${device_model}  data_network_type=${data_network_type}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}2  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
       Should Be True  '${m['tags']['datanetworktype']}' == '${data_network_type}'
   END

DMEMetrics - Shall be able to get the DME Client App Latency metrics with startage
   [Documentation]
   ...  request all DME client app latency metrics with startage
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with startage  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency App Should Be Found  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${True}

DMEMetrics - Shall be able to get the DME Client App Latency metrics with endage
   [Documentation]
   ...  request all DME client app latency metrics with endage
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with endage  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency App Should Be Found  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${True}

DMEMetrics - Shall be able to get the DME Client App Latency metrics with startage and endage
   [Documentation]
   ...  request all DME client app latency metrics with startage and endage
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with startage and endage  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency App Should Be Found  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${True}

DMEMetrics - Shall be able to get the DME Client App Latency metrics with numsamples
   [Documentation]
   ...  request all DME client app latency metrics with numsamples
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client app usage metrics with numsamples  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency App Should Be Found  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${False}

DMEMetrics - Shall be able to get the DME Client App Latency metrics with numsamples and starttime/endtime
   [Documentation]
   ...  request all DME client app latency metrics with numsamples and startime/endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client app usage metrics with numsamples and starttime/endtime  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency App Should Be Found  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}  raw=${False}

DMEMetrics - Shall be able to get the DME Client App DeviceInfo metrics with startage
   [Documentation]
   ...  request all DME client app latency metrics with startage
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with startage  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

DMEMetrics - Shall be able to get the DME Client App DeviceInfo metrics with endage
   [Documentation]
   ...  request all DME client app latency metrics with endage
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with endage  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

DMEMetrics - Shall be able to get the DME Client App DeviceInfo metrics with startage and endage
   [Documentation]
   ...  request all DME client app latency metrics with startage and endage
   ...  verify info is correct

   ${metrics}=  Get client app usage metrics with startage and endage  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

DMEMetrics - Shall be able to get the DME Client App DeviceInfo metrics with numsamples
   [Documentation]
   ...  request all DME client app latency metrics with numsamples
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client app usage metrics with numsamples  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

DMEMetrics - Shall be able to get the DME Client App DeviceInfo metrics with numsamples and starttime/endtime
   [Documentation]
   ...  request all DME client app latency metrics with numsamples and startime/endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client app usage metrics with numsamples and starttime/endtime  app_name=${app_name}1  developer_org_name=${developer_org_name_automation}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

DMEMetrics - DeveloperManager shall be able to get DME Client App Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}=  DeveloperManager shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

DMEMetrics - DeveloperManager shall be able to get DME Client App DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as DeveloperManager
   ...  verify metrics are returned

   ${metrics}=  DeveloperManager shall be able to get client app usage metrics  selector=deviceinfo  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - DeveloperContributor shall be able to get DME Client App Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as DeveloperContributor
   ...  verify metrics are returned

   ${metrics}=  DeveloperContributor shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

DMEMetrics - DeveloperContributor shall be able to get DME Client App DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as DeveloperContributor
   ...  verify metrics are returned

   ${metrics}=  DeveloperContributor shall be able to get client app usage metrics  selector=deviceinfo  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - DeveloperViewer shall be able to get DME Client App Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as DeveloperViewer
   ...  verify metrics are returned

   ${metrics}=  DeveloperViewer shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}1  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

DMEMetrics - DeveloperViewer shall be able to get DME Client App DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as DeveloperViewer
   ...  verify metrics are returned

   ${metrics}=  DeveloperViewer shall be able to get client app usage metrics  selector=deviceinfo  developer_org_name=${developer_org_name_automation}  app_name=${app_name}1  app_version=1.0

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet_name}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - OperatorManager shall be able to get DME Client App Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as OperatorManager
   ...  verify metrics are returned

   ${metrics}=  OperatorManager shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}3  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=tmocloud-2  raw=${True}

DMEMetrics - OperatorManager shall be able to get DME Client App DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorManager
   ...  verify metrics are returned

   ${metrics}=  OperatorManager shall be able to get client app usage metrics  selector=deviceinfo  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - OperatorContributor shall be able to get DME Client App Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as OperatorContributor
   ...  verify metrics are returned

   ${metrics}=  OperatorContributor shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}3  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=tmocloud-2  raw=${True}

DMEMetrics - OperatorContributor shall be able to get DME Client App DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorContributor
   ...  verify metrics are returned

   ${metrics}=  OperatorContributor shall be able to get client app usage metrics  selector=deviceinfo  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - OperatorViewer shall be able to get DME Client App Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as OperatorViewer
   ...  verify metrics are returned

   ${metrics}=  OperatorViewer shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Values Should Be Correct  ${app_name}3  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=tmocloud-2  raw=${True}

DMEMetrics - OperatorViewer shall be able to get DME Client App DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorViewer
   ...  verify metrics are returned

   ${metrics}=  OperatorViewer shall be able to get client app usage metrics  selector=deviceinfo  developer_org_name=${developer_org_name_automation}  app_name=${app_name}3  app_version=1.0  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - Shall be able to get DME Client App Latency metrics with apporg only
   [Documentation]
   ...  request latency clientappusage metrics with apporg only
   ...  verify info is correct

   ${metrics}=  DeveloperManager shall be able to get client app usage metrics  selector=latency  developer_org_name=${developer_org_name_automation}  app_name=${None}  app_version=${None} 

   Latency App Should Be Found  ${app_name}3  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=tmocloud-2  device_network_type=${data_network_type}  raw=${True}

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be True  '${m['tags']['apporg']}' == '${developer_org_name_automation}'
   END

DMEMetrics - Shall be able to get DME Client App DeviceInfo metrics with apporg only
   [Documentation]
   ...  request deviceinfo clientappusage metrics with apporg only
   ...  verify info is correct

   ${metrics}=  DeveloperManager shall be able to get client app usage metrics  selector=deviceinfo  developer_org_name=${developer_org_name_automation}  app_name=${None}  app_version=${None}

#   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet1}  device_network_type=${data_network_type}c1  device_carrier=${carrier_name}  numsessions=2
#   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet1}  device_network_type=${data_network_type}l1  device_carrier=${operator_name_fake}  numsessions=1
#   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet1}  device_network_type=${data_network_type}l3  device_carrier=${operator_name_fake}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}c2  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}1  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}l2  device_carrier=${operator_name_fake}  numsessions=1

#   DeviceInfo App Should Be Found  ${app_name}2  ${metrics}  cloudlet=${cloudlet1}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1
   DeviceInfo App Should Be Found  ${app_name}3  ${metrics}  cloudlet=${cloudlet2_name}  device_network_type=${data_network_type}  device_carrier=${carrier_name}  numsessions=1

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${app_name}=  Get Default App Name

    Create Flavor  region=${region}

    ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud1_long}
    ${cloudlet_name}=  Set Variable  ${cloudlet['data']['key']['name']}
    Set Suite Variable  ${cloudlet_name}

    @{cloudlet_list}=  Create List  tmocloud-2
    ${pool_return}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  cloudlet_list=${cloudlet_list}
    Create Cloudlet Pool Access Invitation  region=${region}  cloudlet_pool_name=${pool_return['data']['key']['name']}  cloudlet_pool_org_name=${operator_name_fake}  developer_org_name=${developer_org_name_automation}
    Create Cloudlet Pool Access Response    region=${region}  cloudlet_pool_name=${pool_return['data']['key']['name']}  cloudlet_pool_org_name=${operator_name_fake}  developer_org_name=${developer_org_name_automation}  decision=accept

    Create App  region=${region}  app_name=${app_name}1  access_ports=tcp:1
    Create App Instance  region=${region}  app_name=${app_name}1  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster
    Create App Instance  region=${region}  app_name=${app_name}1  cloudlet_name=tmocloud-2  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster

    Create App  region=${region}  app_name=${app_name}2  access_ports=tcp:1
    Create App Instance  region=${region}  app_name=${app_name}2  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster

    Create App  region=${region}  app_name=${app_name}3  access_ports=tcp:1
    Create App Instance  region=${region}  app_name=${app_name}3  cloudlet_name=tmocloud-2  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster

    Set Suite Variable  ${app_name}

    ${settings_pre}=   Show Settings  region=${region}
    Set Suite Variable  ${settings_pre}

    @{collection_intervals}=  Create List  10s  2m10s  3m10s
    Update Settings  region=${region}  edge_events_metrics_collection_interval=10s  edge_events_metrics_continuous_queries_collection_intervals=@{collection_intervals}
    Sleep  15s

    ${r1}=  Register Client  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}	
    ${cloudlet1}=  Find Cloudlet   carrier_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud1_long}
    #${cloudlet1}=  Find Cloudlet   carrier_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud2_long}
    Should Be Equal As Numbers  ${cloudlet1.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet1.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet1.fqdn}  shared.${cloudlet_name}.dmuus.mobiledgex.net

    ${r2}=  Register Client  app_name=${app_name}2  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet2}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud2_long}
    Should Be Equal As Numbers  ${cloudlet2.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet2.fqdn}  shared.${cloudlet_name}.dmuus.mobiledgex.net

    ${r3}=  Register Client  app_name=${app_name}3  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet3}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud2_long}
    Should Be Equal As Numbers  ${cloudlet3.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet3.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet3.fqdn}  shared.${cloudlet2_name}.dmuus.mobiledgex.net

    @{samples1}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${170.45}
    ${num_samples1}=  Get Length  ${samples1}

    # connect to cloud1
    Create DME Persistent Connection  carrier_name=${carrier_name}  session_cookie=${r1.session_cookie}  edge_events_cookie=${cloudlet1.edge_events_cookie}  device_os=${device_os}  device_model=${device_model}  signal_strength=${signal_strength}  data_network_type=${data_network_type}c1
    ${latency11}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency21}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency31}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency41}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency51}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency61}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    #Sleep  3s
    # this should return cloud2 
    ${lu}=  Send Location Update Edge Event  carrier_name=${operator_name_fake}  latitude=${cloud2_lat}  longitude=${cloud2_long}  signal_strength=${signal_strength}  data_network_type=${data_network_type}l1
    Should Be Equal As Numbers  ${lu.new_cloudlet.status}  1  #FIND_FOUND
    Should Be Equal  ${lu.new_cloudlet.fqdn}  shared.${cloudlet2_name}.dmuus.mobiledgex.net
    # connection to cloud2
    Create DME Persistent Connection  carrier_name=${carrier_name}  session_cookie=${r1.session_cookie}  edge_events_cookie=${lu.new_cloudlet.edge_events_cookie}  device_os=${device_os}  device_model=${device_model}  signal_strength=${signal_strength}  data_network_type=${data_network_type}c2
    # this should return cloud1
    ${lu3}=  Send Location Update Edge Event  carrier_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud1_long}  signal_strength=${signal_strength}  data_network_type=${data_network_type}l2
    Should Be Equal As Numbers  ${lu3.new_cloudlet.status}  1  #FIND_FOUND
    Should Be Equal  ${lu3.new_cloudlet.fqdn}  shared.${cloudlet_name}.dmuus.mobiledgex.net
    # connect back to cloud1 with same deviceinfo
    Create DME Persistent Connection  carrier_name=${carrier_name}  session_cookie=${r1.session_cookie}  edge_events_cookie=${lu3.new_cloudlet.edge_events_cookie}  device_os=${device_os}  device_model=${device_model}  signal_strength=${signal_strength}  data_network_type=${data_network_type}c1
    # this should return cloud2
    ${lu4}=  Send Location Update Edge Event  carrier_name=${operator_name_fake}  latitude=${cloud2_lat}  longitude=${cloud2_long}  signal_strength=${signal_strength_2}  data_network_type=${data_network_type}l3
    Should Be Equal As Numbers  ${lu4.new_cloudlet.status}  1  #FIND_FOUND
    Should Be Equal  ${lu4.new_cloudlet.fqdn}  shared.${cloudlet2_name}.dmuus.mobiledgex.net

#    Terminate DME Persistent Connection

    Create DME Persistent Connection  carrier_name=${carrier_name}  session_cookie=${r2.session_cookie}  edge_events_cookie=${cloudlet2.edge_events_cookie}  device_os=${device_os}  device_model=${device_model}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency12}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency22}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
#    Terminate DME Persistent Connection
#
    Create DME Persistent Connection  carrier_name=${carrier_name}  session_cookie=${r3.session_cookie}  edge_events_cookie=${cloudlet3.edge_events_cookie}  device_os=${device_os}  device_model=${device_model}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency13}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  device_os=${device_os}  device_model=${device_model}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    ${latency23}=  Send Latency Edge Event  carrier_name=${carrier_name}  latitude=${dme_conn_lat}  longitude=${dme_conn_long}  samples=${samples1}  device_os=${device_os}  device_model=${device_model}  signal_strength=${signal_strength}  data_network_type=${data_network_type}
    #Terminate DME Persistent Connection

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
    Set Suite Variable  @{samples1}


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

Latency Metrics Headings Should Be Correct
  [Arguments]  ${metrics}  ${raw}=${True}

   #Run Keyword If   not ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  latency-metric-2m10s
   #Run Keyword If   not ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][1]['name']}  latency-metric-1m10s
   #Run Keyword If   not ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][2]['name']}  latency-metric-10s
   #${count}=  Run Keyword If   not ${raw}  Set Variable  3
   #...   ELSE  Set Variable  1

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  latency-metric

   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  0s
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  5ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  10ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  25ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  50ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  100ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  max
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  min
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  avg
   IF  ${raw}
       Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  variance
       Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][11]}  stddev
       Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][12]}  numsamples
   ELSE
       Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  numsamples
   END

   FOR  ${i}  IN  @{metrics['data'][0]['Series']}
      Should Be True  'apporg' in ${i['tags']}
      Should Be True  'app' in ${i['tags']}
      Should Be True  'ver' in ${i['tags']}
      Should Be True  'cloudletorg' in ${i['tags']}
      Should Be True  'cloudlet' in ${i['tags']}
      Should Be True  'datanetworktype' in ${i['tags']}
      Should Be True  'locationtile' in ${i['tags']}
      Should Be True  'clusterorg' in ${i['tags']}
      Should Be True  'cluster' in ${i['tags']}
   END

DeviceInfo Metrics Headings Should Be Correct
  [Arguments]  ${metrics}  ${raw}=${False}

   #${count}=  Run Keyword If   not ${raw}  Set Variable  3
   #...   ELSE  Set Variable  1

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  device-metric

   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  numsessions

   FOR  ${i}  IN  @{metrics['data'][0]['Series']}
      Should Be True  'apporg' in ${i['tags']}
      Should Be True  'app' in ${i['tags']}
      Should Be True  'ver' in ${i['tags']}
      Should Be True  'cloudletorg' in ${i['tags']}
      Should Be True  'cloudlet' in ${i['tags']}
      Should Be True  'datanetworktype' in ${i['tags']}
      Should Be True  'clusterorg' in ${i['tags']}
      Should Be True  'cluster' in ${i['tags']}
      Should Be True  'devicecarrier' in ${i['tags']}
      Should Be True  'devicemodel' in ${i['tags']}
      Should Be True  'deviceos' in ${i['tags']}
   END

DeviceInfo Metrics Headings Should Contain Name
   [Arguments]  ${metrics}  ${name}

   ${found}=  Set Variable  ${False}
   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
       IF  "${m['name']}" == "${name}"
           ${found}=  Set Variable  ${True}
           Exit For Loop
       END
   END

   Should Be True  ${found}

Latency Values Should Be Correct
   [Arguments]  ${app_name}  ${metrics}  ${max}  ${min}  ${avg}  ${variance}  ${stddev}  ${numsamples}  ${numrequests}  ${cloudlet}=${cloudlet_name}  ${raw}=${True}

   FOR  ${i}  IN  @{metrics['data'][0]['Series']}
      Should Be Equal  ${i['tags']['app']}  ${app_name}
      Should Be Equal  ${i['tags']['apporg']}  ${developer_org_name_automation}
      Should Be Equal  ${i['tags']['ver']}  1.0
      Should Be Equal  ${i['tags']['cluster']}  autocluster
      Should Be Equal  ${i['tags']['clusterorg']}  MobiledgeX
      Should Be Equal  ${i['tags']['cloudlet']}  ${cloudlet}
      Should Be Equal  ${i['tags']['cloudletorg']}  ${operator_name_fake}
      Should Be Equal  ${i['tags']['datanetworktype']}  ${data_network_type}
      Should Be Equal  ${i['tags']['locationtile']}  ${cloudlet1_tile}

      FOR  ${v}  IN  @{i['values']}
         IF  ${v[1]} != None
            Should Be True  ${v[1]} >= 0
         END
    #     ${r9}=  Evaluate  ${2}*${numrequests}
    #     ${r10}=  Evaluate  ${1}*${numrequests}
    #     ${r11}=  Evaluate  ${1}*${numrequests}
    #     ${r12}=  Evaluate  ${1}*${numrequests}
    #     ${r13}=  Evaluate  ${0}*${numrequests}
    #     ${r14}=  Evaluate  ${2}*${numrequests}
    #     ${r20}=  Evaluate  ${numsamples}*${numrequests}
#
#         Should Be Equal As Numbers  ${v[1]}   ${r9}
#         Should Be Equal As Numbers  ${v[2]}  ${r10}
#         Should Be Equal As Numbers  ${v[3]}  ${r11}
#         Should Be Equal As Numbers  ${v[4]}  ${r12}
#         Should Be Equal As Numbers  ${v[5]}  ${r13}
#         Should Be Equal As Numbers  ${v[6]}  ${r14}
#
#         ${latency_avg}=  Evaluate  round(${avg})
#         ${metrics_avg}=  Evaluate  round(${v[9]})
#
#         Should Be Equal  ${v[7]}  ${max}
#         Should Be Equal  ${v[8]}  ${min}
#         Should Be Equal  ${metrics_avg}  ${latency_avg} 
#         Should Be Equal  ${v[10]}  ${variance}
#         Should Be Equal  ${v[11]}  ${stddev}
#         Should Be Equal  ${v[12]}  ${r20}
#         #Should Be Equal  ${v[12]}  ${numsamples}
     END
   END

#DeviceInfo Values Should Be Correct
#   [Arguments]  ${app_name}  ${metrics}  ${cloudlet}=${cloudlet2}  ${raw}=${False}
#
#   ${count}=  Run Keyword If   not ${raw}  Set Variable  3
#   ...   ELSE  Set Variable  1
#
#   FOR  ${i}  IN RANGE  0  ${count}
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][1]}  ${app_name}
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][2]}  ${developer_org_name_automation}
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][3]}  1.0
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][4]}  autocluster
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][5]}  MobiledgeX
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][6]}  ${cloudlet}
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][7]}  ${operator_name_fake}
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][8]}  ${device_os}
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][9]}  ${device_model}
#      Should Be Equal As Integers  ${metrics['data'][0]['Series'][${i}]['values'][0][10]}  1
#      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['values'][0][11]}  ${data_network_type}
#   END

DeviceInfo Values Should Be Correct
   [Arguments]  ${metrics}  ${raw}=${True}  ${cloudlet}=${cloudlet_name}

   FOR  ${s}  IN  @{metrics['data'][0]['Series']}
      Should Be True  '${s['tags']['cloudlet']}' == '${cloudlet}' or '${s['tags']['cloudlet']}' == '${cloudlet2_name}'
      Should Be Equal  ${s['tags']['cloudletorg']}  ${operator_name_fake}
      Should Be True   '${s['tags']['devicecarrier']}' == '${carrier_name}' or '${s['tags']['devicecarrier']}' == '${operator_name_fake}'
      Should Be Equal  ${s['tags']['devicemodel']}  ${device_model}
      Should Be Equal  ${s['tags']['deviceos']}  ${device_os}
      Should Contain   ${s['tags']['app']}  ${app_name}
      Should Be Equal  ${s['tags']['apporg']}  automation_dev_org
      Should Be Equal  ${s['tags']['cluster']}  autocluster
      Should Be Equal  ${s['tags']['clusterorg']}  MobiledgeX
   END

   FOR  ${v}  IN  @{metrics['data'][0]['Series'][0]['values']}
      IF  ${v[1]} != None
         Should Be True  ${v[1]} > 0
      END
   END

App Should Be Found
   [Arguments]  ${app_name}  ${cloudlet_name}  ${metrics}  ${numsamples}=${None}  ${numsessions}=${None}  ${device_network_type}=${None}

   ${metric_found}=  Set Variable  ${None}
   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      IF  '${m['tags']['app']}' == '${app_name}' and '${m['tags']['cloudlet']}' == '${cloudlet_name}' and '${m['tags']['datanetworktype']}' == '${device_network_type}'
          ${metric_found}=  Set Variable  ${m}
      END
      log to console  found1 ${metric_found}
      IF  ${metric_found} != ${None}
          ${value_sum}=  Set Variable  ${0}
          FOR  ${v}  IN  @{m['values']}
              IF  ${v[1]} != ${None}    # dont check null readings which be removed later
                 ${value_sum}=  Evaluate  ${value_sum}+${v[-1]}
                 log to console  ${value_sum}
              END
          END
          log to console  value_sum ${value_sum}
          IF  '${numsamples}' != '${None}'
              IF  '${value_sum}' != '${numsamples}'
                  ${metric_found}=  Set Variable  ${None}
              END
          ELSE
              ${metric_found}=  Set Variable  ${m}
          END
          IF  '${numsessions}' != '${None}'
              IF  ${value_sum} != ${numsessions}
                  ${metric_found}=  Set Variable  ${None}
              END
          ELSE
              ${metric_found}=  Set Variable  ${m}
          END
      END
      Exit For Loop If  ${metric_found} != ${None}
   END

   Should Be True  ${metric_found} != ${None}

   [Return]  ${metric_found}

Latency App Should Be Found
   [Arguments]  ${app_name}  ${metrics}  ${max}  ${min}  ${avg}  ${variance}  ${stddev}  ${numsamples}  ${numrequests}  ${cloudlet}=${cloudlet2}  ${raw}=${False}  ${device_network_type}=${None}

   ${metric_found}=  App Should Be Found  ${app_name}  ${cloudlet}  ${metrics}  device_network_type=${device_network_type}

   Should Be Equal  ${metric_found['tags']['app']}  ${app_name}
   Should Be Equal  ${metric_found['tags']['apporg']}  ${developer_org_name_automation}
   Should Be Equal  ${metric_found['tags']['ver']}  1.0
   Should Be Equal  ${metric_found['tags']['cluster']}  autocluster
   Should Be Equal  ${metric_found['tags']['clusterorg']}  MobiledgeX
   Should Be Equal  ${metric_found['tags']['cloudlet']}  ${cloudlet}
   Should Be Equal  ${metric_found['tags']['cloudletorg']}  ${operator_name_fake}
   Should Be Equal  ${metric_found['tags']['datanetworktype']}  ${device_network_type}
   Should Be Equal  ${metric_found['tags']['locationtile']}  ${cloudlet1_tile}

   FOR  ${v}  IN  @{metric_found['values']}
      IF  ${v[1]} != ${None}    # dont check null readings which be removed later
         IF  ${raw}
            ${vrequests}=  Evaluate  int(${v[12]}/${numsamples})
         ELSE
            ${vrequests}=  Evaluate  int(${v[10]}/${numsamples})
         END

         ${r9}=  Evaluate  ${2}*${vrequests}
         ${r10}=  Evaluate  ${1}*${vrequests}
         ${r11}=  Evaluate  ${1}*${vrequests}
         ${r12}=  Evaluate  ${1}*${vrequests}
         ${r13}=  Evaluate  ${0}*${vrequests}
         ${r14}=  Evaluate  ${2}*${vrequests}
         ${r20}=  Evaluate  ${numsamples}*${vrequests}

         Should Be Equal As Numbers  ${v[1]}   ${r9}
         Should Be Equal As Numbers  ${v[2]}  ${r10}
         Should Be Equal As Numbers  ${v[3]}  ${r11}
         Should Be Equal As Numbers  ${v[4]}  ${r12}
         Should Be Equal As Numbers  ${v[5]}  ${r13}
         Should Be Equal As Numbers  ${v[6]}  ${r14}

         ${latency_avg}=  Evaluate  round(${avg})
         ${metrics_avg}=  Evaluate  round(${v[9]})

         Should Be Equal  ${v[7]}  ${max}
         Should Be Equal  ${v[8]}  ${min}
         Should Be Equal  ${metrics_avg}  ${latency_avg}

         IF  ${raw}
            ${latency_total_stdev}=     Evaluate  statistics.stdev(${vrequests}*@{samples1})     modules=statistics
            ${latency_total_variance}=  Evaluate  statistics.variance(${vrequests}*@{samples1})  modules=statistics
            ${latency_var}=  Evaluate  round(${latency_total_variance})
            ${metrics_var}=  Evaluate  round(${v[10]})
            ${latency_std}=  Evaluate  round(${latency_total_stdev})
            ${metrics_std}=  Evaluate  round(${v[11]})

            Should Be Equal  ${metrics_var}  ${latency_var}
            Should Be Equal  ${metrics_std}  ${latency_std}
            Should Be Equal  ${v[12]}  ${r20}
         END
      END
   END

DeviceInfo App Should Be Found
   [Arguments]  ${app_name}  ${metrics}  ${cloudlet}  ${device_network_type}  ${numsessions}=1  ${raw}=${False}  ${device_carrier}=${operator_name_fake}

   ${metric_found}=  App Should Be Found  ${app_name}  ${cloudlet}  ${metrics}  ${numsessions}  device_network_type=${device_network_type}

   ${vsum}=  Set Variable  ${0}
   FOR  ${v}  IN  @{metric_found['values']}
      IF  ${v[1]} != ${None}
         ${vsum}=  Evaluate  ${vsum}+${v[1]}    # dont check null readings which be removed later
      END
   END

   Should Be Equal  ${metric_found['tags']['app']}  ${app_name}
   Should Be Equal  ${metric_found['tags']['apporg']}  ${developer_org_name_automation}
   Should Be Equal  ${metric_found['tags']['ver']}  1.0
   Should Be Equal  ${metric_found['tags']['cluster']}  autocluster
   Should Be Equal  ${metric_found['tags']['clusterorg']}  MobiledgeX
   Should Be Equal  ${metric_found['tags']['cloudlet']}  ${cloudlet}
   Should Be Equal  ${metric_found['tags']['cloudletorg']}  ${operator_name_fake}
   Should Be Equal  ${metric_found['tags']['datanetworktype']}  ${device_network_type}
#   Should Be Equal  ${metric_found['tags']['locationtile']}  ${cloudlet1_tile}

   Should Be Equal As Numbers  ${vsum}  ${numsessions}

