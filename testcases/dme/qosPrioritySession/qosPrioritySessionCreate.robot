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
      
*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}

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
