*** Settings ***
Documentation  Create DME QOS session 

Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  String

Test Setup	Setup
#Test Teardown	Cleanup provisioning

*** Variables ***

*** Test Cases ***
# ECQ-4440
CreateQosPrioritySession - create with invalid parms shall return error
    [Documentation]
    ...  - create a qos priority session with various invalid data
    ...  - verify error is returned

    [Template]  Create Qos Session Should Fail With Invalid Args

    Invalid Address for IpUserEquipment: 1.x.1.1   profile=QOS_LOW_LATENCY  ip_user_equipment=1.x.1.1  ip_application_server=2.2.2.2  port_application_server=99
    Invalid Address for IpUserEquipment: 1         profile=QOS_LOW_LATENCY  ip_user_equipment=1        ip_application_server=2.2.2.2  port_application_server=99
    Invalid Address for IpUserEquipment: x         profile=QOS_LOW_LATENCY  ip_user_equipment=x        ip_application_server=2.2.2.2  port_application_server=99

    Invalid Address for IpApplicationServer: 2.x.2.2   profile=QOS_LOW_LATENCY  ip_user_equipment=1.1.1.1  ip_application_server=2.x.2.2  port_application_server=99
    Invalid Address for IpApplicationServer: 2         profile=QOS_LOW_LATENCY  ip_user_equipment=1.1.1.1  ip_application_server=2        port_application_server=99
    Invalid Address for IpApplicationServer: x         profile=QOS_LOW_LATENCY  ip_user_equipment=1.1.1.1  ip_application_server=x        port_application_server=99

    unknown value "OS_LOW_LATENCY" for enum distributed_match_engine.QosSessionProfile   profile=OS_LOW_LATENCY  ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=99
    unknown value "9" for enum distributed_match_engine.QosSessionProfile                profile=9               ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=99

    Invalid Address for IpApplicationServer: 2.x.2.2   profile=QOS_LOW_LATENCY  ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=x
    
    with no port
CreateQosPrioritySession - shall be able to create/delete a qos session
    [Documentation]
    ...  - create a qos priority session with various invalid data
    ...  - verify error is returned
     
    [Template]  Create/Delete Qos Session 

    profile=QOS_LOW_LATENCY        ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  

#    profile=QOS_LOW_LATENCY        ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2   port_application_server=${portnum}
#    profile=QOS_THROUGHPUT_DOWN_S  ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=${portnum}
#    profile=QOS_THROUGHPUT_DOWN_M  ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=${portnum}
#    profile=QOS_THROUGHPUT_DOWN_L  ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=${portnum}
#
#    profile=QOS_LOW_LATENCY        ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=${portnum}  session_duration=10
#    profile=QOS_THROUGHPUT_DOWN_S  ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=${portnum}  session_duration=1
#    profile=QOS_THROUGHPUT_DOWN_M  ip_user_equipment=1.1.1.1  ip_application_server=2.2.2.2  port_application_server=${portnum}  session_duration=100
#    profile=QOS_THROUGHPUT_DOWN_L  ip_user_equipment=1.1.1.4  ip_application_server=2.2.2.2  port_application_server=${portnum}   session_duration=1009

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}

    ${portnum}=    Evaluate    str(random.randint(1, 65535))   random
    Set Suite Variable  ${portnum}

Create Qos Session Should Fail With Invalid Args
    [Arguments]  ${error}  &{args}

    ${ret}=  Run Keyword and Expect Error  *  Create Qos Priority Session  &{args}

    ${body}=   Response Body
    ${body}=  Replace String  ${body}  \\"  \\\\"
    ${body_json}=  Evaluate  json.loads('''${body}''')    json

    ${code}=  Response Status Code

    Should Be Equal As Numbers  ${code}  400

    Should Be Equal As Numbers  ${body_json['code']}   3 
    Should Be Equal  ${body_json['message']}  ${error}
    Length Should Be  ${body_json['details']}  0

Create/Delete Qos Session
    [Arguments]  &{args}

    ${profile}=  Set Variable  ${args['profile']}

    ${ret}=  Create Qos Priority Session  &{args}
#    ${ret2}=  Delete Qos Priority Session  session_id=${ret['session_id']}

    IF  '${profile}' == 'QOS_LOW_LATENCY'
        Should Be Equal  ${ret['profile']}  LowLatency
    ELSE IF  '${profile}' == 'QOS_THROUGHPUT_DOWN_S'
        Should Be Equal  ${ret['profile']}  ThroughputDownS
    ELSE IF  '${profile}' == 'QOS_THROUGHPUT_DOWN_M'
        Should Be Equal  ${ret['profile']}  ThroughputDownM
    ELSE IF  '${profile}' == 'QOS_THROUGHPUT_DOWN_L'
        Should Be Equal  ${ret['profile']}  ThroughputDownL
    ELSE
        Fail  Unknown profile of ${profile}
    END

    IF  'session_duration' in ${args}
        Should Be Equal As Numbers  ${ret['session_duration']}  ${args['session_duration']}
    ELSE
        Should Be Equal As Numbers  ${ret['session_duration']}  86400
    END
    Should Be True  len('${ret['started_at']}') > 0
    Should Be True  len('${ret['expires_at']}') > 0
    Should Be Equal As Numbers  ${ret['http_status']}  201
    Should Be True  len('${ret['session_id']}') > 0
