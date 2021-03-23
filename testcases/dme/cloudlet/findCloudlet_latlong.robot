*** Settings ***
Documentation   FindCloudlet with lat/long

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}

*** Variables ***
${latitude}=  31
${longitude}=  -91

*** Test Cases ***
# ECQ-3295
FindCloudlet - request with 0 lat/long shall return cloudlet
   [Documentation]
   ...  - send findCloudlet with various 0 values for lat/long
   ...  - verify it is successful
      
   [Template]  Register And Find Cloudlet

   lat=31       long=${None}
   lat=${None}  long=91
   lat=0        long=91
   lat=31       long=0
   lat=0        long=0

*** Keywords ***
Register And Find Cloudlet
   [Arguments]  ${lat}=0  ${long}=0

   Register Client  app_name=${app_name_automation}
   ${cloudlet}=  Find Cloudlet  carrier_name=tmus  latitude=${lat}  longitude=${long}

   Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

   Should Be Equal             ${cloudlet.fqdn}  tmocloud-1.tmus.mobiledgex.net
   Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${latitude}
   Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${longitude}

   Should Be True  len('${cloudlet.edge_events_cookie}') > 100

