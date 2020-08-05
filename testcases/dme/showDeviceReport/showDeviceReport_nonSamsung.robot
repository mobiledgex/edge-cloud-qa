*** Settings ***
Documentation   showDeviceReport - request shall return device for non-samsung app

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${samsung_app_name}  xxxxEnablingLayer
${developer_name}  MobiledgeX 
${samsung_s20_type}=  Samsung:SM-G988U:SamsungEnablingLayer
${samsung_s6_type}=  samsung:SAMSUNG-SM-G920A:HASHED_ID
${samsung_s6_id}=  01dddc962bbf0ddedcd32c70caf39b50dfb045ace735bafde9c6fb1540ebe61b76f659250bd81fc441abaafd0f7371d7897410077038a29a14151c0b836176aa

${region}  US

*** Test Cases ***
#ECQ-2299
showDeviceReport - request for non-samsung app with uuidtype=samsung shall return device information
    [Documentation]
    ...  registerClient with non-samsung app with unique_id and type=samsung
    ...  verify showDeviceReport returns all information supported
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=samsung

      ${device}=  Show Device Report  region=${region}  unique_id=${timestamp}   unique_id_type=samsung  

      Should Be Equal  ${device['data']['key']['unique_id_type']}  samsung
      Should Be Equal As Numbers  ${device['data']['key']['unique_id']}  ${timestamp}
      Should Be True   ${device['data']['first_seen']['seconds']} > 0
      Should Be True   ${device['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

#ECQ-2300
showDeviceReport - request for non-samsung app with uuidtype=xxxSamSungxxx shall return device information
    [Documentation]
    ...  registerClient with non-samsung app with unique_id and type=xxxSamSungxxx
    ...  verify showDeviceReport returns all information supported
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      ${epoch}=  Get Time  epoch

      Register Client  developer_org_name=${developer_name}  app_name=${samsung_app_name}  unique_id=${epoch}  unique_id_type=xxxSamSungxxx

      ${device}=  Show Device Report  region=${region}  unique_id=${epoch}  unique_id_type=xxxSamSungxxx

      Should Be Equal  ${device['data']['key']['unique_id_type']}  xxxSamSungxxx
      Should Be Equal As Numbers  ${device['data']['key']['unique_id']}  ${epoch}
      Should Be True   ${device['data']['first_seen']['seconds']} > 0
      Should Be True   ${device['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

#ECQ-2301
showDeviceReport - request for non-samsung app with S20 shall return device information
    [Documentation]
    ...  registerClient with non-samsung app with S20 unique_id and type
    ...  verify showDeviceReport returns all information supported
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      ${epoch}=  Get Time  epoch

      Register Client  developer_org_name=${developer_name}  app_name=${samsung_app_name}  unique_id=${epoch}  unique_id_type=${samsung_s20_type}

      ${device}=  Show Device Report  region=${region}  unique_id=${epoch}  unique_id_type=${samsung_s20_type}

      Should Be Equal  ${device['data']['key']['unique_id_type']}  ${samsung_s20_type}
      Should Be Equal As Numbers  ${device['data']['key']['unique_id']}  ${epoch}
      Should Be True   ${device['data']['first_seen']['seconds']} > 0
      Should Be True   ${device['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

#ECQ-2302
showDeviceReport - request for non-samsung app with S6 shall return device information
    [Documentation]
    ...  registerClient with non-samsung app with S6 unique_id and type
    ...  verify showDeviceReport returns all information supported
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      Register Client  developer_org_name=${developer_name}  app_name=${samsung_app_name}  unique_id=${samsung_s6_id}  unique_id_type=${samsung_s6_type}

      ${device}=  Show Device Report  region=${region}  unique_id=${samsung_s6_id}  unique_id_type=${samsung_s6_type}

      Should Be Equal  ${device['data']['key']['unique_id_type']}  ${samsung_s6_type}
      Should Be Equal As Numbers  ${device['data']['key']['unique_id']}  ${samsung_s6_id}
      Should Be True   ${device['data']['first_seen']['seconds']} > 0
      Should Be True   ${device['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

*** Keywords ***
Setup
    Create Flavor  region=${region} 
    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=${developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  image_path=${docker_image}
