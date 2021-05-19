*** Settings ***
Documentation   DME Persistent Connection Failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections

#Test Setup	Setup
#Test Teardown	Teardown

Test Timeout    60s

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3252
DMEPersistentConnection - persistent connection without session cookie shall fail
  [Documentation]
   ...  - make DME persistent connection without session cookie
   ...  - verify error is received 

   [Tags]  DMEPersistentConnection

   ${reply}=  Run Keyword and Expect Error  *  Create DME Persistent Connection  session_cookie=${None}  edge_events_cookie=${expired_cookie}  latitude=36  longitude=-96  use_defaults=${False}

   Should Contain  ${reply}  status = StatusCode.UNAUTHENTICATED
   Should Contain  ${reply}  details = "VerifyCookie failed: missing cookie" 

# ECQ-3253
DMEPersistentConnection - persistent connection without edge cookie shall fail
  [Documentation]
   ...  - make DME persistent connection without edge cookie
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}

   ${reply}=  Run Keyword and Expect Error  *  Create DME Persistent Connection  session_cookie=${r.session_cookie}  edge_events_cookie=${None}  latitude=36  longitude=-96  use_defaults=${False}

   Should Contain  ${reply}  status = StatusCode.UNAUTHENTICATED
   Should Contain  ${reply}  details = "VerifyCookie failed: missing cookie"

# ECQ-3254
DMEPersistentConnection - persistent connection without edge or session cookie shall fail
  [Documentation]
   ...  - make DME persistent connection without edge or session cookie
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${reply}=  Run Keyword and Expect Error  *  Create DME Persistent Connection  session_cookie=${None}  edge_events_cookie=${None}  latitude=36  longitude=-96  use_defaults=${False}

   Should Contain  ${reply}  status = StatusCode.UNAUTHENTICATED
   Should Contain  ${reply}  details = "VerifyCookie failed: missing cookie"

# ECQ-3255
DMEPersistentConnection - persistent connection expired session cookie shall fail
  [Documentation]
   ...  - make DME persistent connection with expired session cookie
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${reply}=  Run Keyword and Expect Error  *  Create DME Persistent Connection  session_cookie=${expired_cookie}  edge_events_cookie=${expired_cookie}  latitude=36  longitude=-96  use_defaults=${False}

   Should Contain  ${reply}  status = StatusCode.UNAUTHENTICATED
   Should Contain  ${reply}  details = "token is expired

# ECQ-3256
DMEPersistentConnection - persistent connection with expired edge cookie shall fail
  [Documentation]
   ...  - make DME persistent connection with expired edge cookie
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}

   ${reply}=  Run Keyword and Expect Error  *  Create DME Persistent Connection  session_cookie=${r.session_cookie}  edge_events_cookie=${expired_cookie}  latitude=36  longitude=-96  use_defaults=${False}

   Should Contain  ${reply}  status = StatusCode.UNAUTHENTICATED
   Should Contain  ${reply}  details = "token is expired

# ECQ-3257
DMEPersistentConnection - persistent connection with edge cookie = session cookie shall fail
  [Documentation]
   ...  - make DME persistent connection with edge cookie = session cookie
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   # fixed EDGECLOUD-4542 able to create DME persistent connection with edge_event_cookie = session_cookie
   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}

   ${reply}=  Run Keyword and Expect Error  *  Create DME Persistent Connection  session_cookie=${r.session_cookie}  edge_events_cookie=${r.session_cookie}  latitude=36  longitude=-96  use_defaults=${False}

   Should Contain  ${reply}  status = StatusCode.UNAUTHENTICATED
   Should Contain  ${reply}  details = "No Key data in cookie"

# ECQ-3258
DMEPersistentConnection - persistent connection with bad session cookie shall fail
  [Documentation]
   ...  - make DME persistent connection with bad session cookie
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${reply}=  Run Keyword and Expect Error  *  Create DME Persistent Connection  session_cookie=x  edge_events_cookie=${expired_cookie}  latitude=36  longitude=-96  use_defaults=${False}

   Should Contain  ${reply}  status = StatusCode.UNAUTHENTICATED
   Should Contain  ${reply}  details = "token contains an invalid number of segments"

# ECQ-3259
DMEPersistentConnection - persistent connection with bad edge_events_cookie shall fail
  [Documentation]
   ...  - make DME persistent connection with bad edge cookie
   ...  - verify error is received

   [Tags]  DMEPersistentConnection

   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}

   ${reply}=  Run Keyword and Expect Error  *  Create DME Persistent Connection  session_cookie=${r.session_cookie}  edge_events_cookie=x  latitude=36  longitude=-96  use_defaults=${False}

   Should Contain  ${reply}  status = StatusCode.UNAUTHENTICATED
   Should Contain  ${reply}  details = "token contains an invalid number of segments"

# ECQ-3401
DMEPersistentConnection - persistent connection without GPS shall fail
  [Documentation]
   ...  - make DME persistent connection without GPS 
   ...  - verify error is received

   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
   ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

   ${error}=  Run Keyword And Expect Error  *  Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}

   Should Contain  ${error}  status = StatusCode.UNKNOWN
   Should Contain  ${error}  details = "A valid location is required in EVENT_INIT_CONNECTION - error is rpc error: code = InvalidArgument desc = Missing GpsLocation"

# ECQ-3404
DMEPersistentConnection - persistent connection with invalid GPS shall fail
  [Documentation]
   ...  - make DME persistent connection with invalid GPS
   ...  - verify error is received

   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
   ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

   ${error}=  Run Keyword And Expect Error  *  Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=91  longitude=-96
   Should Contain  ${error}  status = StatusCode.UNKNOWN
   Should Contain  ${error}  details = "A valid location is required in EVENT_INIT_CONNECTION - error is rpc error: code = InvalidArgument desc = Invalid GpsLocation"

   ${error2}=  Run Keyword And Expect Error  *  Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-960
   Should Contain  ${error2}  status = StatusCode.UNKNOWN
   Should Contain  ${error2}  details = "A valid location is required in EVENT_INIT_CONNECTION - error is rpc error: code = InvalidArgument desc = Invalid GpsLocation"

