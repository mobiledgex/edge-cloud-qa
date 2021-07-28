*** Settings ***
Documentation  DME metrics for RegisterClient 

Library         MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${cloudlet_name_dme}=  mexplat-qa-cloudlet
${operator_org_name_dme}=  TDG

${region}=  US

${app_key}      -----BEGIN PUBLIC KEY-----${\n}MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij${\n}TkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0${\n}VU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC${\n}GJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS${\n}z3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m${\n}QnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C${\n}/QIDAQAB${\n}-----END PUBLIC KEY-----

${metrics_wait_time}=  45 s

${api_collection_timer}=  30

*** Test Cases ***
# ECQ-2050
DMEMetrics - RegisterClient shall generate metrics
   [Documentation]
   ...  Send multiple RegisterClient messages
   ...  Verify all are collected 

   Register Client  app_name=${app} 
   Register Client  app_name=${app}
   Sleep  30 seconds
   Register Client  app_name=${app}
   Register Client  app_name=${app}
   Register Client  app_name=${app}
   Register Client  app_name=${app}
   Register Client  app_name=${app}
   Register Client  app_name=${app}
   Register Client  app_name=${app}
   Register Client  app_name=${app}
   Sleep  ${metrics_wait_time}
   ${metrics}=  Get Register Client API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}  
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][1]}  # reqs field
 
   Should Be Equal As Numbers  ${last_count}  10  # should be 10 register client requests

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

# ECQ-2051
DMEMetrics - RegisterClient with cellid shall generate metrics
   [Documentation]
   ...  Send multiple RegisterClient messages with cellid
   ...  Verify all are collected

   # EDGECLOUD-5247 clientapiusage does not report the cellID value

   Register Client  app_name=${app}  cell_id=123
   Register Client  app_name=${app}  cell_id=123
   Sleep  30 seconds
   Register Client  app_name=${app}  cell_id=123
   Register Client  app_name=${app}  cell_id=123
   Register Client  app_name=${app}  cell_id=123
   Register Client  app_name=${app}  cell_id=123
   Register Client  app_name=${app}  cell_id=123
   Register Client  app_name=${app}  cell_id=123
   Register Client  app_name=${app}  cell_id=123
   Register Client  app_name=${app}  cell_id=123
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Register Client API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][1]}

   Should Be Equal As Numbers  ${last_count}  10  # should be 10 register client requests

   Metrics Headings Should Be Correct  ${metrics}

   Values With Cellid Should Be In Range  ${metrics}

# ECQ-2052
DMEMetrics - RegisterClient with auth shall generate metrics
   [Documentation]
   ...  Send multiple RegisterClient messages auth
   ...  Verify all are collected

   ${token}=  Generate Auth Token  app_name=${appauth}  app_version=${appvers}  developer_name=${developer}

   Register Client  app_name=${appauth}  auth_token=${token}
   Register Client  app_name=${appauth}  auth_token=${token}
   Sleep  30 seconds
   Register Client  app_name=${appauth}  auth_token=${token}
   Register Client  app_name=${appauth}  auth_token=${token}
   Register Client  app_name=${appauth}  auth_token=${token}
   Register Client  app_name=${appauth}  auth_token=${token}
   Register Client  app_name=${appauth}  auth_token=${token}
   Register Client  app_name=${appauth}  auth_token=${token}
   Register Client  app_name=${appauth}  auth_token=${token}
   Register Client  app_name=${appauth}  auth_token=${token}
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Register Client API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${appauth}  app_version=${appvers}
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][1]}

   Should Be Equal As Numbers  ${last_count}  10  # should be 10 register client requests

   Metrics Headings Should Be Correct  ${metrics}

   Values With Auth Should Be In Range  ${metrics}

# ECQ-2053
DMEMetrics - RegisterClient with error shall generate metrics
   [Documentation]
   ...  Send multiple RegisterClient messages with errors 
   ...  Verify all are collected

   Run Keyword and Expect Error  *  Register Client  app_name=${appauth}  auth_token=123
   Run Keyword and Expect Error  *  Register Client  app_name=${appauth}
   Run Keyword and Expect Error  *  Register Client  app_name=${app}  app_version=2.0
   Run Keyword and Expect Error  *  Register Client  app_name=${app}  developer_org_name=2.0
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   # get appauth metrics
   ${metrics}=  Get Register Client API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${appauth}  app_version=${appvers}
   ${req_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][1]}
   ${error_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][2]}
   Should Be Equal As Numbers  ${req_count}  2  # should be 2 register client requests
   Should Be Equal As Numbers  ${error_count}  2  # should be 2 register client requests
   Metrics Headings Should Be Correct  ${metrics}
   Values With Error Should Be In Range  ${metrics}  ${appauth}  ${developer}  ${appvers}

   # get app ver=2.0 metrics
   ${metrics2}=  Get Register Client API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${app}  app_version=2.0
   ${req_count2}=  Set Variable  ${metrics2['data'][0]['Series'][0]['values'][0][1]}
   ${error_count2}=  Set Variable  ${metrics2['data'][0]['Series'][0]['values'][0][2]}
   Should Be Equal As Numbers  ${req_count2}  1  # should be 2 register client requests
   Should Be Equal As Numbers  ${error_count2}  1  # should be 2 register client requests
   Metrics Headings Should Be Correct  ${metrics2}
   Values With Error Should Be In Range  ${metrics2}  ${app}  ${developer}  2.0

   # get app dev=2.0 metrics
   ${metrics3}=  Get Register Client API Metrics  region=${region}  selector=api  developer_org_name=2.0  app_name=${app}
   ${req_count3}=  Set Variable  ${metrics3['data'][0]['Series'][0]['values'][0][1]}
   ${error_count3}=  Set Variable  ${metrics3['data'][0]['Series'][0]['values'][0][2]}
   Should Be Equal As Numbers  ${req_count3}  1  # should be 2 register client requests
   Should Be Equal As Numbers  ${error_count3}  1  # should be 2 register client requests
   Metrics Headings Should Be Correct  ${metrics3}
   Values With Error Should Be In Range  ${metrics3}  ${app}  2.0  1.0 

*** Keywords ***
Setup
   Update Settings  region=${region}  dme_api_metrics_collection_interval=${api_collection_timer}s

   Create Flavor  region=${region}

   ${app}=        Get Default App Name
   ${appauth}=  Catenate  SEPARATOR=  ${app}  auth

   Create App     region=${region}  app_name=${app}
   Create App     region=${region}  app_name=${appauth}  auth_public_key=${app_key}

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
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${developer}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${app}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${appvers}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['cellID']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundCloudlet']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundOperator']}') == 0
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  RegisterClient

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

      Should Be True  (${reading[3]} + ${reading[4]} + ${reading[5]} + ${reading[6]} + ${reading[7]} + ${reading[8]}) == ${reading[1]}
   END

Values With Cellid Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${developer}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${app}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${appvers}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cellID']}'  123
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundCloudlet']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundOperator']}') == 0
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  RegisterClient

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

      Should Be True  (${reading[3]} + ${reading[4]} + ${reading[5]} + ${reading[6]} + ${reading[7]} + ${reading[8]}) == ${reading[1]}
   END

Values With Auth Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${developer}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${appauth}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${appvers}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['cellID']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundCloudlet']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundOperator']}') == 0
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  RegisterClient

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

      Should Be True  (${reading[3]} + ${reading[4]} + ${reading[5]} + ${reading[6]} + ${reading[7]} + ${reading[8]}) == ${reading[1]}
   END

Values With Error Should Be In Range
  [Arguments]  ${metrics}  ${app_arg}  ${dev_arg}  ${ver_arg}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${dev_arg}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${ver_arg}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['cellID']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundCloudlet']}') == 0
   Should Be True   len('${metrics['data'][0]['Series'][0]['tags']['foundOperator']}') == 0
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  RegisterClient

   # verify values
   FOR  ${reading}  IN  @{values}
      #Should Be Equal  ${reading[1]}  ${dev_arg}
      #Should Be Equal  ${reading[2]}  ${app_arg}
      #Should Be Equal  ${reading[3]}  ${ver_arg}
      #Should Be Equal  ${reading[4]}  ${operator_org_name_dme}
      #Should Be Equal  ${reading[5]}  ${cloudlet_name_dme}
      #Should Be True   '${reading[6]}'.startswith('dme-')
      #Should Be True   ${reading[7]} == 0
      #Should Be Equal  ${reading[8]}  RegisterClient
      #Should Be True   len('${reading[9]}') == 0
      #Should Be True   len('${reading[10]}') == 0
      Should Be True   ${reading[1]} > 0
      Should Be True   ${reading[2]} >= 0
      Should Be True   ${reading[3]} >= 0
      Should Be True   ${reading[4]} >= 0
      Should Be True   ${reading[5]} >= 0
      Should Be True   ${reading[6]} >= 0
      Should Be True   ${reading[7]} >= 0
      Should Be True   ${reading[8]} >= 0

      Should Be True  (${reading[3]} + ${reading[4]} + ${reading[5]} + ${reading[6]} + ${reading[7]} + ${reading[8]}) == ${reading[1]}
   END

