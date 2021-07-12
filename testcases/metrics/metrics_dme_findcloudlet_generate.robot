*** Settings ***
Documentation  DME metrics for FindCloudlet 

Library         MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms

${cloudlet_name_dme}=  mexplat-qa-cloudlet
${operator_org_name_dme}=  TDG

${region}=  US

${metrics_wait_time}=  45 s

*** Test Cases ***
# ECQ-2047
DMEMetrics - FindCloudlet shall generate metrics
   [Documentation]
   ...  Send multiple FindCloudlet messages
   ...  Verify all are collected 

   # EDGECLOUD-5247  clientapiusage does not report the cellID/foundCloudlet/foundOperator value 

   Register Client  app_name=${app}

   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Find Cloudlet API Metrics  region=${region}  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}  
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][1]}

   Should Be Equal As Numbers  ${last_count}  10  # should be 10 register client requests

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}  ${app}  ${tmus_cloudlet_name}  ${tmus_operator_name}

# ECQ-2048
DMEMetrics - FindCloudlet Not Found shall generate metrics
   [Documentation]
   ...  Send multiple FindCloudlet not found messages
   ...  Verify all are collected

   Register Client  app_name=${app}

   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=x  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=y  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=1  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=2  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=3  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=4  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=5  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=6  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=7  latitude=35  longitude=-94
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=8  latitude=35  longitude=-94
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Find Cloudlet API Metrics  region=${region}  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][1]}

   Should Be Equal As Numbers  ${last_count}  10  # should be 10 register client requests

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}  ${app}  ${Empty}  ${Empty}

# ECQ-2049
DMEMetrics - FindCloudlet with error shall generate metrics
   [Documentation]
   ...  Send multiple FindCloudlet messages with errors 
   ...  Verify all are collected

   Register Client  app_name=${app}

   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=xx  latitude=135  longitude=-94 
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=xx  latitude=35  longitude=-194
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=xx  latitude=135  longitude=-194
   Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=xx 
   #Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=xx  latitude=35 
   #Run Keyword and Expect Error  *  Find Cloudlet       carrier_name=xx  longitude=-194
   #Run Keyword And Expect Error  *  Find Cloudlet  session_cookie=default  latitude=35  use_defaults=${False}

   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Find Cloudlet API Metrics  region=${region}  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}
   ${req_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][1]}
   ${error_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][2]}
   Should Be Equal As Numbers  ${req_count}  4  
   Should Be Equal As Numbers  ${error_count}  4 
   Metrics Headings Should Be Correct  ${metrics}
   Values With Error Should Be In Range  ${metrics}  ${app}  ${developer}  ${appvers}

*** Keywords ***
Setup
   Create Flavor  region=${region}

   ${epochtime}=  Get Time  epoch
   ${app}=      Catenate  SEPARATOR=  app  ${epochtime}
   ${appauth}=  Catenate  SEPARATOR=  ${app}  auth

   Create App     region=${region}  app_name=${app}

   Create App Instance  region=${region}  cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster

   ${developer}=  Get Default Developer Name
   ${appvers}=    Get Default App Version

   Set Suite Variable  ${developer}
   Set Suite Variable  ${app}
   Set Suite Variable  ${appauth}
   Set Suite Variable  ${appvers}

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        dme-api
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  reqs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  errs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  0s
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  5ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  10ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  25ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  50ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  100ms

   Should Be True  'apporg' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'app' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'ver' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cloudletorg' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cloudlet' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'dmeId' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cellID' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'method' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'foundCloudlet' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'foundOperator' in ${metrics['data'][0]['Series'][0]['tags']}

Values Should Be In Range
  [Arguments]  ${metrics}  ${app}  ${cloudlet}  ${operator}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${developer}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${app}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${appvers}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['cellID']}') == 0
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['foundCloudlet']}  ${cloudlet}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['foundOperator']}  ${operator}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  FindCloudlet

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} > 0
      Should Be True   ${reading[2]} >= 0
      Should Be True   ${reading[3]} >= 0
      Should Be True   ${reading[4]} >= 0
      Should Be True   ${reading[5]} >= 0
      Should Be True   ${reading[6]} >= 0
      Should Be True   ${reading[7]} >= 0
      Should Be True   ${reading[8]} >= 0
      ${sum}=  Evaluate  ${reading[3]} + ${reading[4]} + ${reading[5]} + ${reading[6]} + ${reading[7]} + ${reading[8]}
      Should Be Equal As Numbers  ${sum}  ${reading[1]}  # sum of ms fields
   END

Values With Error Should Be In Range
  [Arguments]  ${metrics}  ${app_arg}  ${dev_arg}  ${ver_arg}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${dev_arg}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${app_arg}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${ver_arg}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['cellID']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundCloudlet']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundOperator']}') == 0
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  FindCloudlet

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} > 0
      Should Be True   ${reading[2]} >= 0
      Should Be True   ${reading[3]} >= 0
      Should Be True   ${reading[4]} >= 0
      Should Be True   ${reading[5]} >= 0
      Should Be True   ${reading[6]} >= 0
      Should Be True   ${reading[7]} >= 0
      Should Be True   ${reading[8]} >= 0
      ${sum}=  Evaluate  ${reading[3]} + ${reading[4]} + ${reading[5]} + ${reading[6]} + ${reading[7]} + ${reading[8]}
      Should Be Equal As Numbers  ${sum}  ${reading[1]}  # sum of ms fields
   END

