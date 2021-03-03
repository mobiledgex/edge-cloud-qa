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
   ${metrics}=  Get Register Client API Metrics  region=${region}  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}  
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][-2]}
 
   Should Be Equal As Numbers  ${last_count}  10  # should be 10 register client requests

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}

# ECQ-2051
DMEMetrics - RegisterClient with cellid shall generate metrics
   [Documentation]
   ...  Send multiple RegisterClient messages with cellid
   ...  Verify all are collected

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

   ${metrics}=  Get Register Client API Metrics  region=${region}  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][-2]}

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

   ${metrics}=  Get Register Client API Metrics  region=${region}  developer_org_name=${developer}  app_name=${appauth}  app_version=${appvers}
   ${last_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][-2]}

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
   ${metrics}=  Get Register Client API Metrics  region=${region}  developer_org_name=${developer}  app_name=${appauth}  app_version=${appvers}
   ${req_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][-2]}
   ${error_count}=  Set Variable  ${metrics['data'][0]['Series'][0]['values'][0][12]}
   Should Be Equal As Numbers  ${req_count}  2  # should be 2 register client requests
   Should Be Equal As Numbers  ${error_count}  2  # should be 2 register client requests
   Metrics Headings Should Be Correct  ${metrics}
   Values With Error Should Be In Range  ${metrics}  ${appauth}  ${developer}  ${appvers}

   # get app ver=2.0 metrics
   ${metrics2}=  Get Register Client API Metrics  region=${region}  developer_org_name=${developer}  app_name=${app}  app_version=2.0
   ${req_count2}=  Set Variable  ${metrics2['data'][0]['Series'][0]['values'][0][-2]}
   ${error_count2}=  Set Variable  ${metrics2['data'][0]['Series'][0]['values'][0][12]}
   Should Be Equal As Numbers  ${req_count2}  1  # should be 2 register client requests
   Should Be Equal As Numbers  ${error_count2}  1  # should be 2 register client requests
   Metrics Headings Should Be Correct  ${metrics2}
   Values With Error Should Be In Range  ${metrics2}  ${app}  ${developer}  2.0

   # get app dev=2.0 metrics
   ${metrics3}=  Get Register Client API Metrics  region=${region}  developer_org_name=2.0  app_name=${app}
   ${req_count3}=  Set Variable  ${metrics3['data'][0]['Series'][0]['values'][0][-2]}
   ${error_count3}=  Set Variable  ${metrics3['data'][0]['Series'][0]['values'][0][12]}
   Should Be Equal As Numbers  ${req_count3}  1  # should be 2 register client requests
   Should Be Equal As Numbers  ${error_count3}  1  # should be 2 register client requests
   Metrics Headings Should Be Correct  ${metrics3}
   Values With Error Should Be In Range  ${metrics3}  ${app}  2.0  ${appvers}

*** Keywords ***
Setup
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
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  0s
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  100ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  10ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  25ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  50ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  5ms
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  cellID
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][11]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][12]}  errs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][13]}  foundCloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][14]}  foundOperator
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][15]}  method
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][16]}  reqs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][17]}  ver



Values Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} >= 0
      Should Be True   ${reading[2]} >= 0
      Should Be True   ${reading[3]} >= 0
      Should Be True   ${reading[4]} >= 0
      Should Be True   ${reading[5]} >= 0 
      Should Be True   ${reading[6]} >= 0
      Should Be Equal  ${reading[7]}  ${app}
      Should Be Equal  ${reading[8]}  ${developer}
      Should Be True   ${reading[9]} == 0
      Should Be Equal  ${reading[10]}  ${cloudlet_name_dme}
      Should Be Equal  ${reading[11]}  ${operator_org_name_dme}
      Should Be True   ${reading[12]} == 0
      Should Be True   ${reading[13]} == ${None}
      Should Be True   ${reading[14]} == ${None}
      Should Be Equal  ${reading[15]}  RegisterClient
      Should Be True   ${reading[16]} > 0
      Should Be Equal  ${reading[17]}  ${appvers} 

      Should Be True  (${reading[1]} + ${reading[2]} + ${reading[3]} + ${reading[4]} + ${reading[5]}) == ${reading[16]}
   END

Values With Cellid Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} >= 0
      Should Be True   ${reading[2]} >= 0
      Should Be True   ${reading[3]} >= 0
      Should Be True   ${reading[4]} >= 0
      Should Be True   ${reading[5]} >= 0 
      Should Be True   ${reading[6]} >= 0
      Should Be Equal  ${reading[7]}  ${app}
      Should Be Equal  ${reading[8]}  ${developer}
      Should Be True   ${reading[9]} == 123 
      Should Be Equal  ${reading[10]}  ${cloudlet_name_dme}
      Should Be Equal  ${reading[11]}  ${operator_org_name_dme}
      Should Be True   ${reading[12]} == 0
      Should Be True   ${reading[13]} == ${None}
      Should Be True   ${reading[14]} == ${None}
      Should Be Equal  ${reading[15]}  RegisterClient
      Should Be True   ${reading[16]} > 0
      Should Be Equal  ${reading[17]}  ${appvers}

      Should Be True  (${reading[1]} + ${reading[2]} + ${reading[3]} + ${reading[4]} + ${reading[5]}) == ${reading[16]}
   END

Values With Auth Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} >= 0
      Should Be True   ${reading[2]} >= 0
      Should Be True   ${reading[3]} >= 0
      Should Be True   ${reading[4]} >= 0
      Should Be True   ${reading[5]} >= 0        #== ${reading[16]} 
      Should Be True   ${reading[6]} >= 0
      Should Be Equal  ${reading[7]}  ${appauth}
      Should Be Equal  ${reading[8]}  ${developer}
      Should Be True   ${reading[9]} == 0
      Should Be Equal  ${reading[10]}  ${cloudlet_name_dme}
      Should Be Equal  ${reading[11]}  ${operator_org_name_dme}
      Should Be True   ${reading[12]} == 0
      Should Be True   ${reading[13]} == ${None}
      Should Be True   ${reading[14]} == ${None}
      Should Be Equal  ${reading[15]}  RegisterClient
      Should Be True   ${reading[16]} > 0
      Should Be Equal  ${reading[17]}  ${appvers}

      Should Be True  (${reading[1]} + ${reading[2]} + ${reading[3]} + ${reading[4]} + ${reading[5]}) == ${reading[16]}
   END

Values With Error Should Be In Range
  [Arguments]  ${metrics}  ${app_arg}  ${dev_arg}  ${ver_arg}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} >= 0
      Should Be True   ${reading[2]} >= 0
      Should Be True   ${reading[3]} >= 0
      Should Be True   ${reading[4]} >= 0
      Should Be True   ${reading[5]} >= 0
      Should Be True   ${reading[6]} >= 0
      Should Be Equal  ${reading[7]}  ${app_arg}
      Should Be Equal  ${reading[8]}  ${dev_arg}
      Should Be True   ${reading[9]} == 0
      Should Be Equal  ${reading[10]}  ${cloudlet_name_dme}
      Should Be Equal  ${reading[11]}  ${operator_org_name_dme}
      Should Be True   ${reading[12]} == ${reading[16]}
      Should Be True   ${reading[13]} == ${None}
      Should Be True   ${reading[14]} == ${None}
      Should Be Equal  ${reading[15]}  RegisterClient
      Should Be True   ${reading[16]} > 0
      Should Be Equal  ${reading[17]}  ${ver_arg}

      Should Be True  (${reading[1]} + ${reading[2]} + ${reading[3]} + ${reading[4]} + ${reading[5]}) == ${reading[16]}
   END

