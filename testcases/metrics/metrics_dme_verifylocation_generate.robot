*** Settings ***
Documentation  DME metrics for VerifyLocation 

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
# ECQ-4095
DMEMetrics - VerifyLocation shall generate metrics
   [Documentation]
   ...  - Send multiple VerifyLocation messages
   ...  - Verify all are collected 

   Register Client  app_name=${app}

   MexDmeRest.Get Token

   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-94
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Verify Location API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}  

   ${count}=  Set Variable  ${0}
   FOR  ${s}  IN  @{metrics['data'][0]['Series']}
      ${count}=  Evaluate  ${count}+${s['values'][0][1]}  # reqs field
   END

   Should Be Equal As Numbers  ${count}  10

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}  ${app}  ${dmuus_cloudlet_name}  ${dmuus_operator_name}

# ECQ-4096
DMEMetrics - VerifyLocation with error shall generate metrics
   [Documentation]
   ...  - Send multiple VerifyLocation messages with errors 
   ...  - Verify all are collected

   Register Client  app_name=${app}

   Run Keyword and Expect Error  *  Verify Location  carrier_name=${dmuus_operator_name}  latitude=5  longitude=-5  token=${Empty}

   MexDmeRest.Get Token

   Run Keyword and Expect Error  *  Verify Location  carrier_name=${dmuus_operator_name}  latitude=135  longitude=-94 
   Run Keyword and Expect Error  *  Verify Location  carrier_name=${dmuus_operator_name}  latitude=35  longitude=-194
   Run Keyword and Expect Error  *  Verify Location  carrier_name=${dmuus_operator_name}  latitude=135  longitude=-194
   Run Keyword and Expect Error  *  Verify Location  carrier_name=${dmuus_operator_name} 

   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Verify Location API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}
   ${req_count}=  Set Variable  ${0}
   ${error_count}=  Set Variable  ${0}
   FOR  ${s}  IN  @{metrics['data'][0]['Series']}
      ${req_count}=  Evaluate  ${req_count}+${s['values'][0][1]}
      ${error_count}=  Evaluate  ${error_count}+${s['values'][0][2]}
   END

   Should Be Equal As Numbers  ${req_count}  5  
   Should Be Equal As Numbers  ${error_count}  5 

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
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  reqs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  errs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cellID
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  foundCloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  foundOperator

   Should Be True  'apporg' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'app' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'ver' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cloudletorg' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cloudlet' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'dmeId' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'method' in ${metrics['data'][0]['Series'][0]['tags']}

Values Should Be In Range
  [Arguments]  ${metrics}  ${app}  ${cloudlet}  ${operator} 

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${developer}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${app}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${appvers}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  VerifyLocation

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} > 0
      Should Be True   ${reading[2]} == 0
      Should Be Equal  ${reading[3]}  0
      Should Be Empty  ${reading[4]} 
      Should Be Empty  ${reading[5]}
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
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  VerifyLocation

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} > 0
      Should Be True   ${reading[2]} >= 0
      Should Be Equal  ${reading[3]}  0
      Should Be Empty  ${reading[4]}
      Should Be Empty  ${reading[5]}
   END

