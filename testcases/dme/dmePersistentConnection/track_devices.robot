*** Settings ***
Documentation   Tracked Devices Tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
#Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  Collections
Library  String

#Test Setup	Setup
Test Teardown	Teardown

Test Timeout    600s

*** Variables ***
${region}=  US

${num_registers}=  100
${app_name}=  andyhealth

#${lat}=  54.0313728
#${long}=  13.5978605
${lat}=  52
${long}=  13

*** Test Cases ***
DMEPersistentConnection - create tracked devices
    [Documentation]
    ...  - make DME persistent connection
    ...  - send multiple Register/FindClodlets
    ...  - verify Track Devices map has all the devices

    [Tags]  DMEPersistentConnection

    FOR  ${r}  IN RANGE  0  ${num_registers}
       ${posneg}=  Generate Random String  1  01
       ${id}=  Generate Random String    9    0123456789
       ${latdec}=  Generate Random String    7    123456789
       ${longdec}=  Generate Random String    7    123456789
       IF  ${posneg} == 0
          ${latuse}=  Evaluate  int(${lat}) + (int(${latdec})/10000000)
          ${longuse}=  Evaluate  int(${long}) + (int(${longdec})/10000000)
       ELSE
          ${latuse}=  Evaluate  int(${lat}) - (int(${latdec})/10000000)
          ${longuse}=  Evaluate  int(${long}) - (int(${longdec})/10000000)
       END
       log to console  unique id ${id} ${latuse} ${longuse}
       ${r}=  Register Client  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cell_id=123456  unique_id=${id}  unique_id_type=andytype
       ${cloudlet}=  Find Cloudlet         carrier_name=TDG  latitude=${latuse}  longitude=${longuse}
    END

DMEPersistentConnection - create tracked devices with latency
    [Documentation]
    ...  - make DME persistent connection
    ...  - send multiple Register/FindClodlets/Latency
    ...  - verify Latency map has all the devices

    [Tags]  DMEPersistentConnection

    FOR  ${r}  IN RANGE  0  ${num_registers}
       ${posneg}=  Generate Random String  1  01
       ${id}=  Generate Random String    9    0123456789
       ${latdec}=  Generate Random String    7    123456789
       ${longdec}=  Generate Random String    7    123456789
       IF  ${posneg} == 0
          ${latuse}=  Evaluate  int(${lat}) + (int(${latdec})/10000000)
          ${longuse}=  Evaluate  int(${long}) + (int(${longdec})/10000000)
       ELSE
          ${latuse}=  Evaluate  int(${lat}) - (int(${latdec})/10000000)
          ${longuse}=  Evaluate  int(${long}) - (int(${longdec})/10000000)
       END
       log to console  unique id ${id} ${latuse} ${longuse}
       ${r}=  Register Client  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}  unique_id=${id}  unique_id_type=andytype
       ${cloudlet}=  Find Cloudlet         carrier_name=TDG  latitude=${latuse}  longitude=${longuse}

       @{samples}=    Evaluate    random.sample(range(1, 110), 3)    random

       Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=${latuse}  longitude=${longuse}  carrier_name=tmus 

       ${latency}=  Send Latency Edge Event  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=${latuse}  longitude=${longuse}  samples=${samples}  carrier_name=tmus  data_network_type=5G  device_os=Android  device_model=Google Pixel  signal_strength=75

       Terminate DME Persistent Connection
   END
*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${app_name}=  Get Default App Name

    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    Create Flavor  region=${region}
#    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    #Create Cluster		
    Create App  region=${region}  developer_org_name=andydevorg  access_ports=tcp:1
    ${tmus_appinst}=  Create App Instance  region=${region}  cluster_instance_developer_org_name=MobiledgeX  cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster
#    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

   
    Set Suite Variable  ${tmus_appinst} 
    Set Suite Variable  ${app_name}

Teardown
   Terminate DME Persistent Connection
   Cleanup Provisioning
