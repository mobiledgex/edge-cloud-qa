*** Settings ***
Documentation  DME metrics for FindCloudlet 

Library         MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms

${cloudlet_name_dme}=  mexplat-qa-cloudlet
${operator_org_name_dme}=  GDDT

${region}=  US

${metrics_wait_time}=  45 s

*** Test Cases ***
# ECQ-2047
DMEMetrics - FindCloudlet shall generate metrics
   [Documentation]
   ...  Send multiple FindCloudlet messages
   ...  Verify all are collected 

   Register Client  app_name=${app}

   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Find Cloudlet API Metrics  region=${region}  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}  
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][11]}

   Should Be Equal As Numbers  ${last_count}  10  # should be 10 register client requests

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}  ${app}  ${dmuus_cloudlet_name}  ${dmuus_operator_name}

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
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][11]}

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
   ${req_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][11]}
   ${error_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][12]}
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

   Create App Instance  region=${region}  cloudlet_name=${dmuus_cloudlet_name}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster

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
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  ver
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  dmeId
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  cellID
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  method
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  foundCloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  foundOperator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][11]}  reqs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][12]}  errs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][13]}  0s
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][14]}  5ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][15]}  10ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][16]}  25ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][17]}  50ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][18]}  100ms

Values Should Be In Range
  [Arguments]  ${metrics}  ${app}  ${cloudlet}  ${operator}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal  ${reading[1]}  ${developer}
      Should Be Equal  ${reading[2]}  ${app}
      Should Be Equal  ${reading[3]}  ${appvers}
      Should Be Equal  ${reading[4]}  ${operator_org_name_dme}
      Should Be Equal  ${reading[5]}  ${cloudlet_name_dme}
      Should Be True   '${reading[6]}'.startswith('dme-')
      Should Be True   ${reading[7]} == 0
      Should Be Equal  ${reading[8]}  FindCloudlet
      Should Be Equal  ${reading[9]}  ${cloudlet} 
      Should Be Equal  ${reading[10]}  ${operator} 
      Should Be True   ${reading[11]} > 0
      Should Be True   ${reading[12]} >= 0
      Should Be True   ${reading[13]} >= 0
      Should Be True   ${reading[14]} >= 0
      Should Be True   ${reading[15]} >= 0
      Should Be True   ${reading[16]} >= 0
      Should Be True   ${reading[17]} >= 0
      Should Be True   ${reading[18]} >= 0
      ${sum}=  Evaluate  ${reading[13]} + ${reading[14]} + ${reading[15]} + ${reading[16]} + ${reading[17]} + ${reading[18]}
      Should Be Equal As Numbers  ${sum}  ${reading[11]}  # sum of ms fields
   END

Values With Error Should Be In Range
  [Arguments]  ${metrics}  ${app_arg}  ${dev_arg}  ${ver_arg}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be Equal  ${reading[1]}  ${dev_arg}
      Should Be Equal  ${reading[2]}  ${app_arg}
      Should Be Equal  ${reading[3]}  ${ver_arg}
      Should Be Equal  ${reading[4]}  ${operator_org_name_dme}
      Should Be Equal  ${reading[5]}  ${cloudlet_name_dme}
      Should Be True   '${reading[6]}'.startswith('dme-')
      Should Be True   ${reading[7]} == 0
      Should Be Equal  ${reading[8]}  FindCloudlet
      Should Be True   len('${reading[9]}') == 0 
      Should Be True   len('${reading[10]}') == 0
      Should Be True   ${reading[11]} > 0
      Should Be True   ${reading[12]} >= 0
      Should Be True   ${reading[13]} >= 0
      Should Be True   ${reading[14]} >= 0
      Should Be True   ${reading[15]} >= 0
      Should Be True   ${reading[16]} >= 0
      Should Be True   ${reading[17]} >= 0
      Should Be True   ${reading[18]} >= 0
      ${sum}=  Evaluate  ${reading[13]} + ${reading[14]} + ${reading[15]} + ${reading[16]} + ${reading[17]} + ${reading[18]}
      Should Be Equal As Numbers  ${sum}  ${reading[11]}  # sum of ms fields
   END

