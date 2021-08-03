*** Settings ***
Documentation   Cloudlet Edge Event Metrics Tests

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
${cloudlet2_tile}=   -94.996407,34.991408_-95.005390,35.000452_1
${cloudlet12_tile}=  -94.987424,30.984896_-95.005390,31.002985_1

${dme_conn_lat}=  ${cloud1_lat}
${dme_conn_long}=  ${cloud1_long}

${edge_collection_timer}=  10

*** Test Cases ***
# ECQ-3476
DMEMetrics - Shall be able to get the last DME Client Cloudlet Latency metric
   [Documentation]
   ...  request latency clientappusage metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get the last client cloudlet usage metric  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  raw=${True}
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  raw=${True}

DMEMetrics - Shall be able to get the last DME Client Cloudlet DeviceInfo metric
   [Documentation]
   ...  request deviceinfo clientappusage metrics with last=1
   ...  verify info is correct

   ${metrics}=  Get the last client cloudlet usage metric  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   DeviceInfo Values Should Be Correct  ${metrics}   raw=${True}

DMEMetrics - Shall be able to get DME Client Cloudlet Latency metrics with cloudletorg only
   [Documentation]
   ...  request latency clientappusage metrics with apporg only
   ...  verify info is correct

   ${metrics}=  Get all client cloudlet usage metrics  operator_org_name=${operator_name_fake}  selector=latency

#   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6 
#   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  2

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  8  raw=${True}

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be True  '${m['tags']['cloudletorg']}' == '${operator_name_fake}'
   END

DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with cloudletorg only
   [Documentation]
   ...  request deviceinfo clientappusage metrics with apporg only
   ...  verify info is correct

   ${metrics}=  Get all client cloudlet usage metrics  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}  raw=${True}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}  raw=${True}

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be True  '${m['tags']['cloudletorg']}' == '${operator_name_fake}' 
   END

DMEMetrics - Shall be able to get all DME Client Cloudlet Latency metric
   [Documentation]
   ...  request all latency clientappusage metrics
   ...  verify info is correct

   ${metrics}=  Get all client cloudlet usage metrics  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}

   #Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6
   #Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  2

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  8  raw=${True}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  raw=${True}
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  raw=${True}

DMEMetrics - Shall be able to get all DME Client Cloudlet DeviceInfo metric
   [Documentation]
   ...  request all deviceinfo clientappusage metrics
   ...  verify info is correct

   ${metrics}=  Get all client cloudlet usage metrics  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}  raw=${True}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}  raw=${True}

   DeviceInfo Values Should Be Correct  ${metrics}  raw=${True}

DMEMetrics - Shall be able to get DME Client Cloudlet Latency metrics with starttime
   [Documentation]
   ...  request latency clientappusage metrics with starttime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with starttime   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

#   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6
#   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  2

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  8  raw=${False}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  time_diff=${time_diff}  raw=${False} 
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  time_diff=${time_diff}  raw=${False}

DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with starttime
   [Documentation]
   ...  request deviceinfo clientappusage metrics with starttime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with starttime   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${False}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  metrics=${metrics}  time_diff=${time_diff}  raw=${False}

DMEMetrics - Shall be able to get DME Client Cloudlet Latency metrics with endtime
   [Documentation]
   ...  request latency clientappusage metrics with endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with endtime   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${False}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  time_diff=${time_diff}  raw=${False}
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  time_diff=${time_diff}  raw=${False}



DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with endtime
   [Documentation]
   ...  request deviceinfo clientappusage metrics with endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with endtime   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${False}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}  time_diff=${time_diff}  raw=${False}

DMEMetrics - Shall be able to get DME Client Cloudlet Latency metrics with starttime and endtime
   [Documentation]
   ...  request latency clientappusage metrics with startime and endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with starttime and endtime   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${False}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  time_diff=${time_diff}  raw=${False}

   Latency Values Should Be Correct  ${metrics}  cloudlet=${cloudlet_name}  time_diff=${time_diff}  raw=${False}

DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with starttime and endtime
   [Documentation]
   ...  request deviceinfo clientappusage metrics with startime and endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with starttime and endtime   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${False}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}  time_diff=${time_diff}  raw=${False}

DMEMetrics - Shall be able to get DME Client Cloudlet Latency metrics with starttime and endtime and last
   [Documentation]
   ...  request latency clientappusage metrics with startime and endtime and last
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with starttime and endtime and last   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6  raw=${True}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  raw=${True}

   Latency Values Should Be Correct  ${metrics}  cloudlet=${cloudlet_name}  raw=${True}

DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with starttime and endtime and last
   [Documentation]
   ...  request deviceinfo clientappusage metrics with startime and endtime and last
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with starttime and endtime and last   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${True}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}  raw=${True}

DMEMetrics - Shall be able to get DME Client Cloudlet Latency metrics with locationtile
   [Documentation]
   ...  request latency clientappusage metrics with locationtile
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with locationtile   cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency  location_tile=${cloudlet1_tile}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   #Latency Values Should Be Correct  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  6
   Latency Values Should Be Correct  ${metrics}    raw=${True}

DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with deviceos
   [Documentation]
   ...  request deviceinfo clientappusage metrics with deviceos
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with deviceinfo   operator_org_name=${operator_name_fake}  selector=deviceinfo  device_os=${device_os}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be Equal  ${m['tags']['deviceos']}  ${device_os}
   END

DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with devicemodel
   [Documentation]
   ...  request deviceinfo clientappusage metrics with devicemodel
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with deviceinfo   operator_org_name=${operator_name_fake}  selector=deviceinfo  device_model=${device_model}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be Equal  ${m['tags']['devicemodel']}  ${device_model} 
   END

DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with devicecarrier
   [Documentation]
   ...  request deviceinfo clientappusage metrics with datanetworktype
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with deviceinfo   operator_org_name=${operator_name_fake}  selector=deviceinfo  device_carrier=${carrier_name}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}
 
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be Equal  ${m['tags']['devicecarrier']}  ${carrier_name}
   END


DMEMetrics - Shall be able to get DME Client Cloudlet DeviceInfo metrics with all deviceinfo
   [Documentation]
   ...  request deviceinfo clientappusage metrics with all deviceinfo
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with deviceinfo   operator_org_name=${operator_name_fake}  selector=deviceinfo  device_os=${device_os}  device_model=${device_model}  device_carrier=${carrier_name}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}

   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      Should Be Equal  ${m['tags']['devicecarrier']}  ${carrier_name}
   END

DMEMetrics - Shall be able to get the DME Client Cloudlet Latency metrics with startage
   [Documentation]
   ...  request all DME client cloudlet latency metrics with startage
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with startage  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  8  raw=${True}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  raw=${True}
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  raw=${True}

DMEMetrics - Shall be able to get the DME Client Cloudlet Latency metrics with endage
   [Documentation]
   ...  request all DME client cloudlet latency metrics with endage
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with endage  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  8  raw=${True}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  raw=${True}
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  raw=${True}

DMEMetrics - Shall be able to get the DME Client Cloudlet Latency metrics with startage and endage
   [Documentation]
   ...  request all DME client cloudlet latency metrics with startage and endage
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with startage and endage  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  8  raw=${True}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  raw=${True}
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  raw=${True}

DMEMetrics - Shall be able to get the DME Client Cloudlet Latency metrics with numsamples
   [Documentation]
   ...  request all DME client cloudlet latency metrics with numsamples
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with numsamples  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  8  raw=${False}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  raw=${False}
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  raw=${False}  numsamples=${10}

DMEMetrics - Shall be able to get the DME Client Cloudlet Latency metrics with numsamples and starttime/endtime
   [Documentation]
   ...  request all DME client cloudlet latency metrics with numsamples and startime/endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with numsamples and starttime/endtime  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=latency

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   Latency Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  ${latency11.statistics.max}  ${latency11.statistics.min}  ${latency11.statistics.avg}  ${latency11.statistics.std_dev}  ${latency11.statistics.variance}  ${num_samples1}  8  raw=${False}

   #Latency Values Should Be Correct  metrics=${metrics}  max=${latency11.statistics.max}  min=${latency11.statistics.min}  avg=${latency11.statistics.avg}  stddev=${latency11.statistics.std_dev}  variance=${latency11.statistics.variance}  numsamples=${num_samples1}  numrequests=6  cloudlet=${cloudlet_name}  raw=${False}
   Latency Values Should Be Correct  metrics=${metrics}  cloudlet=${cloudlet_name}  raw=${False}  numsamples=${5}

DMEMetrics - Shall be able to get the DME Client Cloudlet DeviceInfo metrics with startage
   [Documentation]
   ...  request all DME client cloudlet deviceinfo metrics with startage
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with startage  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  metrics=${metrics}  raw=${True}

DMEMetrics - Shall be able to get the DME Client Cloudlet DeviceInfo metrics with endage
   [Documentation]
   ...  request all DME client cloudlet deviceinfo metrics with endage
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with endage  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  metrics=${metrics}  raw=${True}

DMEMetrics - Shall be able to get the DME Client Cloudlet DeviceInfo metrics with startage and endage
   [Documentation]
   ...  request all DME client cloudlet deviceinfo metrics with startage and endage
   ...  verify info is correct

   ${metrics}=  Get client cloudlet usage metrics with startage and endage  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  metrics=${metrics}  raw=${True}

DMEMetrics - Shall be able to get the DME Client Cloudlet DeviceInfo metrics with numsamples
   [Documentation]
   ...  request all DME client cloudlet deviceinfo metrics with numsamples
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with numsamples  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  metrics=${metrics}  time_diff=${time_diff}  raw=${False}  numsamples=${10}

DMEMetrics - Shall be able to get the DME Client Cloudlet DeviceInfo metrics with numsamples and starttime/endtime
   [Documentation]
   ...  request all DME client cloudlet deviceinfo metrics with numsamples and startime/endtime
   ...  verify info is correct

   ${metrics}  ${time_diff}=  Get client cloudlet usage metrics with numsamples and starttime/endtime  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  selector=deviceinfo

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  metrics=${metrics}  time_diff=${time_diff}  raw=${False}  numsamples=${5}

DMEMetrics - DeveloperManager shall not be able to get DME Client Cloudlet Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as DeveloperManager
   ...  verify metrics are returned

   DeveloperManager shall not be able to get client cloudlet usage metrics  selector=latency  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet2_name}

DMEMetrics - DeveloperManager shall not be able to get DME Client Cloudlet DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as DeveloperManager
   ...  verify metrics are returned

   DeveloperManager shall not be able to get client cloudlet usage metrics  selector=deviceinfo  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet2_name}

DMEMetrics - DeveloperContributor shall not be able to get DME Client Cloudlet Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as DeveloperContributor
   ...  verify metrics are returned

   DeveloperContributor shall not be able to get client cloudlet usage metrics  selector=latency  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet2_name}

DMEMetrics - DeveloperContributor shall not be able to get DME Client Cloudlet DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as DeveloperContributor
   ...  verify metrics are returned

   DeveloperContributor shall not be able to get client cloudlet usage metrics  selector=deviceinfo  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet2_name}

DMEMetrics - DeveloperViewer shall not be able to get DME Client Cloudlet Latency metrics
   [Documentation]
   ...  request latency clientappusage metrics as DeveloperViewer
   ...  verify metrics are returned

   DeveloperViewer shall not be able to get client cloudlet usage metrics  selector=latency  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet2_name}

DMEMetrics - DeveloperViewer shall not be able to get DME Client Cloudlet DeviceInfo metrics
   [Documentation]
   ...  request deviceinfo clientappusage metrics as DeveloperViewer
   ...  verify metrics are returned

   DeveloperViewer shall not be able to get client cloudlet usage metrics  selector=deviceinfo  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet2_name} 

DMEMetrics - OperatorManager shall be able to get DME Client Cloudlet Latency metrics with raw data
   [Documentation]
   ...  request latency clientappusage metrics as OperatorManager
   ...  verify metrics are returned

   ${metrics}=  OperatorManager shall be able to get client cloudlet usage metrics  selector=latency  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   #Latency Values Should Be Correct  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet_name}
   Latency Values Should Be Correct  ${metrics}  raw=${True}  cloudlet=${cloudlet_name}

DMEMetrics - OperatorManager shall be able to get DME Client Cloudlet DeviceInfo metrics with raw data
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorManager
   ...  verify metrics are returned

   ${metrics}=  OperatorManager shall be able to get client cloudlet usage metrics  selector=deviceinfo  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - OperatorContributor shall be able to get DME Client Cloudlet Latency metrics with raw data
   [Documentation]
   ...  request latency clientappusage metrics as OperatorContributor
   ...  verify metrics are returned

   ${metrics}=  OperatorContributor shall be able to get client cloudlet usage metrics  selector=latency  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   #Latency Values Should Be Correct  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet_name}
   Latency Values Should Be Correct  ${metrics}  cloudlet=${cloudlet_name}

DMEMetrics - OperatorContributor shall be able to get DME Client Cloudlet DeviceInfo metrics with raw data
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorContributor
   ...  verify metrics are returned

   ${metrics}=  OperatorContributor shall be able to get client cloudlet usage metrics  selector=deviceinfo  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - OperatorViewer shall be able to get DME Client Cloudlet Latency metrics with raw data
   [Documentation]
   ...  request latency clientappusage metrics as OperatorViewer
   ...  verify metrics are returned

   ${metrics}=  OperatorViewer shall be able to get client cloudlet usage metrics  selector=latency  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${True}

   #Latency Values Should Be Correct  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet_name}
   Latency Values Should Be Correct  ${metrics}  cloudlet=${cloudlet_name}

DMEMetrics - OperatorViewer shall be able to get DME Client Cloudlet DeviceInfo metrics with raw data
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorViewer
   ...  verify metrics are returned

   ${metrics}=  OperatorViewer shall be able to get client cloudlet usage metrics  selector=deviceinfo  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}

DMEMetrics - OperatorManager shall be able to get DME Client Cloudlet Latency metrics with starttime and endtime
   [Documentation]
   ...  request latency clientappusage metrics as OperatorManager with starttime and endtime
   ...  verify metrics are returned

   ${metrics}  ${time_diff}=  OperatorManager shall be able to get client cloudlet usage metrics with starttime and endtime  selector=latency  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   #Latency Values Should Be Correct  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet_name}
   Latency Values Should Be Correct  ${metrics}  raw=${False}  cloudlet=${cloudlet_name}  time_diff=${time_diff}

DMEMetrics - OperatorManager shall be able to get DME Client Cloudlet DeviceInfo metrics with starttime and endtime
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorManager with starttime and endtime
   ...  verify metrics are returned

   ${metrics}  ${time_diff}=  OperatorManager shall be able to get client cloudlet usage metrics with starttime and endtime  selector=deviceinfo  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}  raw=${False}  time_diff=${time_diff}

DMEMetrics - OperatorContributor shall be able to get DME Client Cloudlet Latency metrics with starttime and endtime
   [Documentation]
   ...  request latency clientappusage metrics as OperatorContributor with starttime and endtime
   ...  verify metrics are returned

   ${metrics}  ${time_diff}=  OperatorContributor shall be able to get client cloudlet usage metrics with starttime and endtime  selector=latency  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   #Latency Values Should Be Correct  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet_name}
   Latency Values Should Be Correct  ${metrics}  cloudlet=${cloudlet_name}  raw=${False}  time_diff=${time_diff}

DMEMetrics - OperatorContributor shall be able to get DME Client Cloudlet DeviceInfo metrics with starttime and endtime
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorContributor with starttime and endtime
   ...  verify metrics are returned

   ${metrics}  ${time_diff}=  OperatorContributor shall be able to get client cloudlet usage metrics with starttime and endtime  selector=deviceinfo  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}  raw=${False}  time_diff=${time_diff}

DMEMetrics - OperatorViewer shall be able to get DME Client Cloudlet Latency metrics with starttime and endtime
   [Documentation]
   ...  request latency clientappusage metrics as OperatorViewer with starttime and endtime
   ...  verify metrics are returned

   ${metrics}  ${time_diff}=  OperatorViewer shall be able to get client cloudlet usage metrics with starttime and endtime  selector=latency  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   Latency Metrics Headings Should Be Correct  ${metrics}  raw=${False}

   #Latency Values Should Be Correct  ${metrics}  ${latency13.statistics.max}  ${latency13.statistics.min}  ${latency13.statistics.avg}  ${latency13.statistics.std_dev}  ${latency13.statistics.variance}  ${num_samples1}  2  cloudlet=${cloudlet_name}
   Latency Values Should Be Correct  ${metrics}  cloudlet=${cloudlet_name}  raw=${False}  time_diff=${time_diff}

DMEMetrics - OperatorViewer shall be able to get DME Client Cloudlet DeviceInfo metrics with starttime and endtime
   [Documentation]
   ...  request deviceinfo clientappusage metrics as OperatorViewer with starttime and endtime
   ...  verify metrics are returned

   ${metrics}  ${time_diff}=  OperatorViewer shall be able to get client cloudlet usage metrics with starttime and endtime  selector=deviceinfo  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}

   DeviceInfo Metrics Headings Should Be Correct  ${metrics}

#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=2  tile=${cloudlet1_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=1  tile=${cloudlet2_tile}
#   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=1  tile=${cloudlet1_tile}

   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${carrier_name}        numsessions=3  tile=${cloudlet1_tile}
   DeviceInfo Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  device_carrier=${operator_name_fake}  numsessions=2  tile=${cloudlet2_tile}

   DeviceInfo Values Should Be Correct  ${metrics}  raw=${False}  time_diff=${time_diff}

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

    @{collection_intervals}=  Create List  1m10s  2m10s  3m10s
    Update Settings  region=${region}  edge_events_metrics_collection_interval=${edge_collection_timer}s  edge_events_metrics_continuous_queries_collection_intervals=@{collection_intervals}  location_tile_side_length_km=1
    Sleep  15s

    ${r1}=  Register Client  app_name=${app_name}1  app_version=1.0  developer_org_name=${developer_org_name_automation}	
    ${cloudlet1}=  Find Cloudlet   carrier_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud1_long}
    #${cloudlet1}=  Find Cloudlet   carrier_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud2_long}
    Should Be Equal As Numbers  ${cloudlet1.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet1.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet1.fqdn}  shared.${cloudlet_name}.dmuus.mobiledgex.net

    ${r2}=  Register Client  app_name=${app_name}2  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet2}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=${cloud1_lat}  longitude=${cloud1_long}
    Should Be Equal As Numbers  ${cloudlet2.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet2.edge_events_cookie}') > 100
    Should Be Equal  ${cloudlet2.fqdn}  shared.${cloudlet_name}.dmuus.mobiledgex.net

    ${r3}=  Register Client  app_name=${app_name}3  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet3}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=${cloud2_lat}  longitude=${cloud2_long}
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
    Should Be Equal  ${lu.new_cloudlet.fqdn}  shared.tmocloud-2.dmuus.mobiledgex.net
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
    Should Be Equal  ${lu4.new_cloudlet.fqdn}  shared.tmocloud-2.dmuus.mobiledgex.net

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
    
    Sleep  2m 
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
   ${count}=  Set Variable  1
   #Run Keyword If   ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  latency-metric
   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  latency-metric

   FOR  ${i}  IN RANGE  0  ${count} 
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][0]}  time
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][1]}  0s
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][2]}  5ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][3]}  10ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][4]}  25ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][5]}  50ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][6]}  100ms
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][7]}  max
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][8]}  min
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][9]}  avg
      IF  ${raw}
          Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][10]}  variance
          Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][11]}  stddev
          Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][12]}  numsamples
      ELSE
          Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][10]}  numsamples
      END
   END

   FOR  ${i}  IN RANGE  0  ${count}
      Should Be True  'cloudlet' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'cloudletorg' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'datanetworktype' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'devicecarrier' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'locationtile' in ${metrics['data'][0]['Series'][${i}]['tags']}
   END

DeviceInfo Metrics Headings Should Be Correct
  [Arguments]  ${metrics}  ${raw}=${True}

   #Run Keyword If   not ${raw}  DeviceInfo Metrics Headings Should Contain Name  ${metrics}  device-metric-2m10s  #Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  device-metric-2m10s
   #Run Keyword If   not ${raw}  DeviceInfo Metrics Headings Should Contain Name  ${metrics}  device-metric-1m10s  #Should Be Equal  ${metrics['data'][0]['Series'][1]['name']}  device-metric-1m10s
   #Run Keyword If   not ${raw}  DeviceInfo Metrics Headings Should Contain Name  ${metrics}  device-metric-10s    #Should Be Equal  ${metrics['data'][0]['Series'][2]['name']}  device-metric-10s
   #${count}=  Run Keyword If   not ${raw}  Set Variable  3
   #...   ELSE  Set Variable  1
   ${count}=  Set Variable  1
   #Run Keyword If   ${raw}  Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  device-metric
   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  device-metric

   FOR  ${i}  IN RANGE  0  ${count}
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][0]}  time
      Should Be Equal  ${metrics['data'][0]['Series'][${i}]['columns'][1]}  numsessions
   END

   FOR  ${i}  IN RANGE  0  ${count}
      Should Be True  'cloudlet' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'cloudletorg' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'devicecarrier' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'devicemodel' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'deviceos' in ${metrics['data'][0]['Series'][${i}]['tags']}
      Should Be True  'locationtile' in ${metrics['data'][0]['Series'][${i}]['tags']}
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
   #[Arguments]  ${metrics}  ${max}  ${min}  ${avg}  ${variance}  ${stddev}  ${numsamples}  ${numrequests}  ${cloudlet}=${cloudlet_name}  ${raw}=${True}  ${time_diff}=${None}
   [Arguments]  ${metrics}  ${cloudlet}=${cloudlet_name}  ${raw}=${True}  ${time_diff}=${None}  ${numsamples}=${100}

   #${count}=  Run Keyword If   not ${raw}  Set Variable  3
   #...   ELSE  Set Variable  1

   FOR  ${i}  IN  @{metrics['data'][0]['Series']}
      Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet}
      Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_name_fake}
      Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['datanetworktype']}  ${data_network_type}
      Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['devicecarrier']}  ${carrier_name}
      Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['locationtile']}  ${cloudlet1_tile}

      IF  ${time_diff} != ${None}
         ${time_def}=  Evaluate  ${time_diff}/${numsamples}

         ${time_check}=  Set Variable  ${edge_collection_timer}
         IF  ${time_def} > ${edge_collection_timer}
            ${time_check}=  Set Variable  ${time_def}
         END

         ${datez}=  Get Substring  ${metrics['data'][0]['Series'][0]['values'][0][0]}  0  -1
         @{datesplit}=  Split String  ${datez}  .
         ${epochpre}=  Evaluate  calendar.timegm(time.strptime('${datesplit[0]}', '%Y-%m-%dT%H:%M:%S'))  modules=calendar
         ${start}=  Evaluate  ${epochpre} + ${time_check}
      END

   #FOR  ${i}  IN RANGE  0  ${count}
      FOR  ${v}  IN  @{i['values']}
         IF  ${v[1]} != None
            Should Be True  ${v[1]} >= 0
            Should Be True  ${v[2]} >= 0
            Should Be True  ${v[3]} >= 0
            Should Be True  ${v[4]} >= 0
            Should Be True  ${v[5]} >= 0
            Should Be True  ${v[6]} >= 0
            Should Be True  ${v[7]} > 0
            Should Be True  ${v[8]} > 0
            Should Be True  ${v[9]} > 0
            Should Be True  ${v[10]} > 0
            IF  ${raw}
               Should Be True  ${v[11]} > 0
               Should Be True  ${v[12]} > 0
            END
         END
         IF  ${time_diff} != ${None}
            ${datez}=  Get Substring  ${v[0]}  0  -1
            @{vdatesplit}=  Split String  ${datez}  .
            ${vepochpre}=  Evaluate  calendar.timegm(time.strptime('${vdatesplit[0]}', '%Y-%m-%dT%H:%M:%S'))  modules=calendar
            #${vepochpre}=  Convert Date  ${vdatesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
            ${epoch_diff}=  Evaluate  ${start}-${vepochpre}
            #Should Be True  ${epoch_diff} <= ${time_check}+1 and ${epoch_diff} >= ${time_check}-1
            Should Be True  ${time_check}-1 <= ${epoch_diff} <= ${time_check}+1
            ${start}=  Set Variable  ${vepochpre}
         END
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
   [Arguments]  ${metrics}  ${raw}=${True}  ${time_diff}=${None}  ${numsamples}=${100}  ${cloudlet}=${cloudlet_name}

   #${count}=  Run Keyword If   not ${raw}  Set Variable  3
   #...   ELSE  Set Variable  2

   #Length Should Be  ${metrics['data'][0]['Series']}  ${count}

   FOR  ${s}  IN  @{metrics['data'][0]['Series']}
      Should Be Equal  ${s['tags']['cloudlet']}  ${cloudlet}
      Should Be Equal  ${s['tags']['cloudletorg']}  ${operator_name_fake}
      Should Be True   '${s['tags']['devicecarrier']}' == '${carrier_name}' or '${metrics['data'][0]['Series'][0]['tags']['devicecarrier']}' == '${operator_name_fake}'
      Should Be Equal  ${s['tags']['devicemodel']}  ${device_model}
      Should Be Equal  ${s['tags']['deviceos']}  ${device_os}
      Should Be True  '${s['tags']['locationtile']}' == '${cloudlet1_tile}' or '${metrics['data'][0]['Series'][0]['tags']['locationtile']}' == '${cloudlet2_tile}'

      IF  ${time_diff} != ${None}
         ${time_def}=  Evaluate  ${time_diff}/${numsamples}

         ${time_check}=  Set Variable  ${edge_collection_timer}
         IF  ${time_def} > ${edge_collection_timer}
            ${time_check}=  Set Variable  ${time_def}
         END

         ${datez}=  Get Substring  ${s['values'][0][0]}  0  -1
         @{datesplit}=  Split String  ${datez}  .
         ${epochpre}=  Evaluate  calendar.timegm(time.strptime('${datesplit[0]}', '%Y-%m-%dT%H:%M:%S'))  modules=calendar
         ${start}=  Evaluate  ${epochpre} + ${time_check}
      END

      FOR  ${v}  IN  @{s['values']}
         IF  ${v[1]} != None
            Should Be True  ${v[1]} > 0
         END
         IF  ${time_diff} != ${None}
            ${datez}=  Get Substring  ${v[0]}  0  -1
            @{vdatesplit}=  Split String  ${datez}  .
            ${vepochpre}=  Evaluate  calendar.timegm(time.strptime('${vdatesplit[0]}', '%Y-%m-%dT%H:%M:%S'))  modules=calendar
            #${vepochpre}=  Convert Date  ${vdatesplit[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
            ${epoch_diff}=  Evaluate  ${start}-${vepochpre}
            #Should Be True  ${epoch_diff} <= ${time_check}+1 and ${epoch_diff} >= ${time_check}-1
            Should Be True  ${time_check}-1 <= ${epoch_diff} <= ${time_check}+1
            ${start}=  Set Variable  ${vepochpre}
         END
      END
   END

Cloudlet Should Be Found
   [Arguments]  ${cloudlet_name}  ${metrics}  ${numsamples}=${None}  ${numsessions}=${None}  ${data_network_type}=${None}  ${carrier}=${None}  ${tile}=${None}

   ${metric_found}=  Set Variable  ${None}
   FOR  ${m}  IN  @{metrics['data'][0]['Series']}
      IF  '${m['tags']['cloudlet']}' == '${cloudlet_name}'
          ${metric_found}=  Set Variable  ${m}

          IF  '${carrier}' != '${None}'
              log to console  ${m['tags']['cloudlet']} ${m['tags']['devicecarrier']} ${carrier}
              IF  '${m['tags']['devicecarrier']}' != '${carrier}'
                  ${metric_found}=  Set Variable  ${None}
              END
          END

          IF  '${data_network_type}' != '${None}'
              log to console  ${m['tags']['cloudlet']} ${m['tags']['datanetworktype']} ${datanetworktype}
              IF  '${m['tags']['datanetworktype']}' != '${data_network_type}'
                  ${metric_found}=  Set Variable  ${None}
              END
          END

          IF  '${tile}' != '${None}'
              log to console  ${m['tags']['cloudlet']} ${m['tags']['locationtile']} ${tile}
              IF  '${m['tags']['locationtile']}' != '${tile}'
                  ${metric_found}=  Set Variable  ${None}
              END
          END
      END

      IF  ${metric_found} != ${None}
          ${value_sum}=  Set Variable  ${0}
          FOR  ${v}  IN  @{m['values']}
              IF  ${v[1]} != ${None}    # dont check null readings which be removed later
                 ${value_sum}=  Evaluate  ${value_sum}+${v[-1]}
                 log to console  ${value_sum}
              END
          END

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

#          FOR  ${v}  IN  @{m['values']}
#              IF  '${numsamples}' != '${None}'
#                  IF  '${v[12]}' != '${numsamples}'
#                      ${metric_found}=  Set Variable  ${None}
#                  END
#              END
#              IF  '${numsessions}' != '${None}'
#                  IF  ${v[1]} != ${numsessions}
#                      ${metric_found}=  Set Variable  ${None}
#                  END
#              ELSE
#                  ${metric_found}=  Set Variable  ${m}
#              END
#              Exit For Loop If  ${metric_found} != ${None}
#          END
      END
      Exit For Loop If  ${metric_found} != ${None}
   END
#              IF  '${device_network_type}' != '${None}'
#                  IF  '${v[2]}' != '${device_network_type}'
#                      ${metric_found}=  Set Variable  ${None}
#                  END
#              END
#              IF  '${carrier}' != '${None}'
#                  IF  '${device_network_type}' != '${None}'
#                      IF  '${v[3]}' != '${carrier}'
#                          ${metric_found}=  Set Variable  ${None}
#                      END
#                  ELSE
#                      IF  '${v[3]}' != '${carrier}'
#                          ${metric_found}=  Set Variable  ${None}
#                      END
#                  END
#              END
#
#              IF  '${tile}' != '${None}'
#                  IF  '${device_network_type}' != '${None}'
#                      IF  '${v[4]}' != '${tile}'
#                          ${metric_found}=  Set Variable  ${None}
#                      END
#                  ELSE
#                      IF  '${v[4]}' != '${tile}'
#                          ${metric_found}=  Set Variable  ${None}
#                      END
#                  END
#              END

              #IF  '${numsessions}' != '${None}' and '${device_network_type}' != '${None}'
              #    IF  ${v[6]} != ${numsessions} or '${v[12]}' != '${device_network_type}'
              #        ${metric_found}=  Set Variable  ${None}
              #    END
              #END
#          END
#          Exit For Loop If  ${metric_found} != ${None}
#      END
#      Exit For Loop If  ${metric_found} != ${None}
#   END

   Should Be True  ${metric_found} != ${None}

   [Return]  ${metric_found}

Latency Cloudlet Should Be Found
   [Arguments]  ${cloudlet_name}  ${metrics}  ${max}  ${min}  ${avg}  ${variance}  ${stddev}  ${numsamples}  ${numrequests}  ${cloudlet}=${cloudlet2_name}  ${raw}=${False}

   ${numsamples_find}=  Evaluate  ${numsamples}*${numrequests}
#   ${numrequests_find}=  Evaluate  ${2}*${numrequests}
   ${metric_found}=  Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  numsamples=${numsamples_find}  #tottotalrequests=${numrequests_find}
   ${values_found}=  Set Variable  ${None}

#   FOR  ${v}  IN  @{metric_found['values']}
#       IF  ${v[12]} == ${numsamples_find}
#           ${values_found}=  Set Variable  ${v}
#           Exit For Loop
#       END
#   END

   Should Be Equal  ${metric_found['tags']['cloudlet']}  ${cloudlet_name}
   Should Be Equal  ${metric_found['tags']['cloudletorg']}  ${operator_name_fake}

   FOR  ${v}  IN  @{metric_found['values']}
      IF  ${v[1]} != ${None}    # dont check null readings which be removed later
         IF  ${raw}
            ${vrequests}=  Evaluate  int(${v[12]}/${numsamples})
         ELSE
            ${vrequests}=  Evaluate  int(${v[10]}/${numsamples})
         END
 
         ${r9}=   Evaluate  ${2}*${vrequests}
         ${r10}=  Evaluate  ${1}*${vrequests}
         ${r11}=  Evaluate  ${1}*${vrequests}
         ${r12}=  Evaluate  ${1}*${vrequests}
         ${r13}=  Evaluate  ${0}*${vrequests}
         ${r14}=  Evaluate  ${2}*${vrequests}
         ${r20}=  Evaluate  ${numsamples}*${vrequests}
 
         Should Be Equal As Numbers  ${v[1]}  ${r9}
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

#   ${r9}=  Evaluate  ${2}*${numrequests}
#   ${r10}=  Evaluate  ${1}*${numrequests}
#   ${r11}=  Evaluate  ${1}*${numrequests}
#   ${r12}=  Evaluate  ${1}*${numrequests}
#   ${r13}=  Evaluate  ${0}*${numrequests}
#   ${r14}=  Evaluate  ${2}*${numrequests}
#   ${r20}=  Evaluate  ${numsamples}*${numrequests}
#
#   Should Be Equal As Numbers  ${values_found[1]}   ${r9}
#   Should Be Equal As Numbers  ${values_found[2]}  ${r10}
#   Should Be Equal As Numbers  ${values_found[3]}  ${r11}
#   Should Be Equal As Numbers  ${values_found[4]}  ${r12}
#   Should Be Equal As Numbers  ${values_found[5]}  ${r13}
#   Should Be Equal As Numbers  ${values_found[6]}  ${r14}

#   ${latency_total_stdev}=     Evaluate  statistics.stdev(${numrequests}*@{samples1})     modules=statistics
#   ${latency_total_variance}=  Evaluate  statistics.variance(${numrequests}*@{samples1})  modules=statistics

#   ${latency_avg}=  Evaluate  round(${avg})
#   ${metrics_avg}=  Evaluate  round(${values_found[9]})
#   ${latency_var}=  Evaluate  round(${latency_total_variance})
#   ${metrics_var}=  Evaluate  round(${values_found[10]})
#   ${latency_std}=  Evaluate  round(${latency_total_stdev})
#   ${metrics_std}=  Evaluate  round(${values_found[11]})
#
#   Should Be Equal  ${values_found[7]}  ${max}
#   Should Be Equal  ${values_found[8]}  ${min}
#   Should Be Equal  ${metrics_avg}  ${latency_avg}
#   Should Be Equal  ${metrics_var}  ${latency_var}
#   Should Be Equal  ${metrics_std}  ${latency_std}
#   Should Be Equal  ${values_found[12]}  ${r20}

#   IF  '${cloudlet}' == '${cloudlet2}'
#      Should Be Equal  ${metric_found[21]}  ${cloudlet2_tile}
#   ELSE
#      Should Be Equal  ${metric_found[21]}  ${cloudlet1_tile}
#   END

DeviceInfo Cloudlet Should Be Found
   [Arguments]  ${cloudlet_name}  ${metrics}  ${numsessions}=1  ${raw}=${False}  ${device_carrier}=${operator_name_fake}  ${data_network_type}=${None}  ${tile}=${None}

   ${metric_found}=  Cloudlet Should Be Found  ${cloudlet_name}  ${metrics}  numsessions=${numsessions}  carrier=${device_carrier}  data_network_type=${data_network_type}  tile=${tile}

   ${vsum}=  Set Variable  ${0} 
   FOR  ${v}  IN  @{metric_found['values']}
      IF  ${v[1]} != ${None}
         ${vsum}=  Evaluate  ${vsum}+${v[1]}    # dont check null readings which be removed later
      END
   END

#   ${values_found}=  Set Variable  ${None}
#   FOR  ${v}  IN  @{metric_found['values']}
#       IF  ${v[12]} == ${numsamples_find}
#           ${values_found}=  Set Variable  ${v}
#           Exit For Loop
#       END
#   END

   Should Be Equal  ${metric_found['tags']['cloudlet']}  ${cloudlet_name}
   Should Be Equal  ${metric_found['tags']['cloudletorg']}  ${operator_name_fake}
   Should Be Equal  ${metric_found['tags']['devicecarrier']}  ${device_carrier}
   Should Be Equal  ${metric_found['tags']['devicemodel']}  ${device_model}
   Should Be Equal  ${metric_found['tags']['deviceos']}  ${device_os}
   Should Be Equal  ${metric_found['tags']['locationtile']}  ${tile}

#   Should Be Equal As Numbers  ${values_found[1]}   ${numsessions}
   Should Be Equal As Numbers  ${vsum}  ${numsessions}


