*** Settings ***
Documentation   FindCloudlet with device info

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}

*** Variables ***
${latitude}=  31
${longitude}=  -91

*** Test Cases ***
# ECQ-3388
FindCloudlet - request with device info shall return cloudlet
   [Documentation]
   ...  - send findCloudlet with various device info values
   ...  - verify it is successful
      
   [Template]  Register And Find Cloudlet

   device_os=Android
   device_model=mymodel
   signal_strength=1
   data_network_type=x
   device_os=Android  device_model=mymodel  signal_strength=1  data_network_type=x
   device_os=x  device_model=m  signal_strength=100000  data_network_type=x
   device_os=iOS  device_model=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx  signal_strength=2  data_network_type=5G
   device_os=iOS  device_model=x x xxxxxxxxxxxxxxxxxxxxxxxxxxxx  signal_strength=5  data_network_type=LTE

*** Keywords ***
Register And Find Cloudlet
   [Arguments]  ${lat}=1  ${long}=1  ${device_os}=${None}  ${device_model}=${None}  ${signal_strength}=${None}  ${data_network_type}=${None}

   Register Client  app_name=${app_name_automation}
   ${cloudlet}=  Find Cloudlet  carrier_name=tmus  latitude=${lat}  longitude=${long}  device_os=${device_os}  device_model=${device_model}  signal_strength=${signal_strength}  data_network_type=${data_network_type}

   Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

   Should Be Equal             ${cloudlet.fqdn}  tmocloud-1.tmus.mobiledgex.net
   Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${latitude}
   Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${longitude}

   Should Be True  len('${cloudlet.edge_events_cookie}') > 100
