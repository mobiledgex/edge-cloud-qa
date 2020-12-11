*** Settings ***
Documentation   showDeviceReport - request shall return device for non-platos app

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${platos_app_name}  xxxxEnablingLayer
${developer_name}  MobiledgeX 
${platos_s20_type}=  platos:SM-G988U:platosEnablingLayer
${platos_s6_type}=  platos:SAMSUNG-SM-G920A:HASHED_ID
${platos_s6_id}=  01dddc962bbf0ddedcd32c70caf39b50dfb045ace735bafde9c6fb1540ebe61b76f659250bd81fc441abaafd0f7371d7897410077038a29a14151c0b836176aa

${region}  US

*** Test Cases ***
#ECQ-2299
showDeviceReport - request for non-platos app with uuidtype=platos shall return device information
    [Documentation]
    ...  registerClient with non-platos app with unique_id and type=platos
    ...  verify showDeviceReport returns all information supported
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=platos

      ${device}=  Show Device Report  region=${region}  unique_id=${timestamp}   unique_id_type=platos  

      Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  platos
      Should Be Equal As Numbers  ${device[0]['data']['key']['unique_id']}  ${timestamp}
      Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
      Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

#ECQ-2300
showDeviceReport - request for non-platos app with uuidtype=xxxSamSungxxx shall return device information
    [Documentation]
    ...  registerClient with non-platos app with unique_id and type=xxxSamSungxxx
    ...  verify showDeviceReport returns all information supported
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      ${epoch}=  Get Time  epoch

      Register Client  developer_org_name=${developer_name}  app_name=${platos_app_name}  unique_id=${epoch}  unique_id_type=xxxSamSungxxx

      ${device}=  Show Device Report  region=${region}  unique_id=${epoch}  unique_id_type=xxxSamSungxxx

      Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  xxxSamSungxxx
      Should Be Equal As Numbers  ${device[0]['data']['key']['unique_id']}  ${epoch}
      Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
      Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

#ECQ-2301
showDeviceReport - request for non-platos app with S20 shall return device information
    [Documentation]
    ...  registerClient with non-platos app with S20 unique_id and type
    ...  verify showDeviceReport returns all information supported
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      ${epoch}=  Get Time  epoch

      Register Client  developer_org_name=${developer_name}  app_name=${platos_app_name}  unique_id=${epoch}  unique_id_type=${platos_s20_type}

      ${device}=  Show Device Report  region=${region}  unique_id=${epoch}  unique_id_type=${platos_s20_type}

      Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  ${platos_s20_type}
      Should Be Equal As Numbers  ${device[0]['data']['key']['unique_id']}  ${epoch}
      Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
      Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

#ECQ-2302
showDeviceReport - request for non-platos app with S6 shall return device information
    [Documentation]
    ...  registerClient with non-platos app with S6 unique_id and type
    ...  verify showDeviceReport returns all information supported
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      Register Client  developer_org_name=${developer_name}  app_name=${platos_app_name}  unique_id=${platos_s6_id}  unique_id_type=${platos_s6_type}

      ${device}=  Show Device Report  region=${region}  unique_id=${platos_s6_id}  unique_id_type=${platos_s6_type}

      Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  ${platos_s6_type}
      Should Be Equal  ${device[0]['data']['key']['unique_id']}  ${platos_s6_id}
      Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
      Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

# ECQ-2952
showDeviceReport - request for non-platos app with non-platos unique_id_type should not return device information
    [Documentation]
    ...  - registerClient with non-platos app with non-platos unique_id and type
    ...  - verify showDeviceReport does not returns any information

    Register Client  developer_org_name=${developer_name}  app_name=${platos_app_name}  unique_id=${platos_s6_id}  unique_id_type=abcd

    ${device}=  Show Device Report  region=${region}  unique_id=${platos_s6_id}  unique_id_type=abcd

    Length Should Be   ${device}  0

# ECQ-2953
showDeviceReport - request for appname=nonplatos and orgname=platos and unique_id_type=platos should return device information
    [Documentation]
    ...  - registerClient with non-platos app with platos unique_id_type
    ...  - verify showDeviceReport returns all information supported
    ...  - key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

    ${epoch}=  Get Time  epoch

    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=platos  app_name=${platos_app_name}  access_ports=tcp:1  image_path=${docker_image}

    Register Client  developer_org_name=platos  app_name=${platos_app_name}  unique_id=${epoch}  unique_id_type=platos

    ${device}=  Show Device Report  region=${region}  unique_id=${epoch}  unique_id_type=platos

    Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  platos
    Should Be Equal As Numbers  ${device[0]['data']['key']['unique_id']}  ${epoch}
    Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
    Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0

    Length Should Be   ${device}  1

# ECQ-2954
showDeviceReport - request for appname=nonplatos and orgname=platos and unique_id_type contains platos should return device information
    [Documentation]
    ...  - registerClient with appname=nonplatos and orgname=platos and unique_id_type contains platos
    ...  - verify showDeviceReport returns all information supported
    ...  - key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

    ${epoch}=  Get Time  epoch

    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=platos  app_name=${platos_app_name}  access_ports=tcp:1  image_path=${docker_image}

    Register Client  developer_org_name=platos  app_name=${platos_app_name}  unique_id=${epoch}  unique_id_type=xplatosx

    ${device}=  Show Device Report  region=${region}  unique_id=${epoch}  unique_id_type=xplatosx

    Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  xplatosx
    Should Be Equal As Numbers  ${device[0]['data']['key']['unique_id']}  ${epoch}
    Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
    Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0

    Length Should Be   ${device}  1

# ECQ-2955
showDeviceReport - request for appname=nonplatos and orgname=platos and unique_id_type contains lowercase platos should return device information
    [Documentation]
    ...  - registerClient with appname=nonplatos and orgname=platos and unique_id_type contains lowercase platos
    ...  - verify showDeviceReport returns all information supported
    ...  - key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

    ${epoch}=  Get Time  epoch

    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=platos  app_name=${platos_app_name}  access_ports=tcp:1  image_path=${docker_image}

    Register Client  developer_org_name=platos  app_name=${platos_app_name}  unique_id=${epoch}  unique_id_type=platosx

    ${device}=  Show Device Report  region=${region}  unique_id=${epoch}  unique_id_type=platosx

    Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  platosx
    Should Be Equal As Numbers  ${device[0]['data']['key']['unique_id']}  ${epoch}
    Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
    Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0

    Length Should Be   ${device}  1

# ECQ-2956
showDeviceReport - request for appname=platosEnablingLayer and orgname=MobiledgeX and unique_id_type contains platos should return device information
    [Documentation]
    ...  - registerClient with appname=platosEnablingLayer and orgname=MobiledgeX and unique_id_type contains platos
    ...  - verify showDeviceReport returns all information supported
    ...  - key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

    ${epoch}=  Get Time  epoch

    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=MobiledgeX  app_name=platosEnablingLayer  access_ports=tcp:1  image_path=${docker_image}

    Register Client  developer_org_name=MobiledgeX  app_name=platosEnablingLayer  unique_id=${epoch}  unique_id_type=xplatosx

    ${device}=  Show Device Report  region=${region}  unique_id=${epoch}  unique_id_type=xplatosx

    Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  xplatosx
    Should Be Equal As Numbers  ${device[0]['data']['key']['unique_id']}  ${epoch}
    Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
    Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0

    Length Should Be   ${device}  1

*** Keywords ***
Setup
    Create Flavor  region=${region} 
    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=${developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  image_path=${docker_image}
