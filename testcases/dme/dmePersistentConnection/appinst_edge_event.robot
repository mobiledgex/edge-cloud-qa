*** Settings ***
Documentation   DME persistent connection with new appinst

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}

Suite Setup    Setup Suite
Test Setup     Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${cloudlet2}=  tmocloud-2
${cloudlet2_lat}=  35.0
${cloudlet2_long}=  -95.0
${operator}=  dmuus
${region}=  US

*** Test Cases ***
# ECQ-3837
DmePersistentConnection - create of new closer appinst shall return new cloudlet
   [Documentation]
   ...  - create 1 appinst
   ...  - create a dme persistent connection
   ...  - create a 2nd appinst closer to the user
   ...  - verify cloudlet update event is received with new cloudlet

   [Tags]  DMEPersistentConnection

   ${r}=  Register Client  
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=35  longitude=-95
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}

   Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet2}  operator_org_name=dmuus  cluster_instance_name=autoclusteraa2

   Sleep  1s

   ${cloud1}=  Receive Cloudlet Update Event
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud1.new_cloudlet.edge_events_cookie}') > 100
   Should Match Regexp  ${cloud1.new_cloudlet.fqdn}  reservable[0-9].${cloudlet2}.dmuus.mobiledgex.net 
   Should Be Equal  ${cloud1.new_cloudlet.ports}  ${fcloudlet.ports}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.latitude}  ${cloudlet2_lat}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.longitude}  ${cloudlet2_long}

# ECQ-3838
DmePersistentConnection - create of new farther appinst shall not return new cloudlet
   [Documentation]
   ...  - create 1 appinst
   ...  - create a dme persistent connection
   ...  - create a 2nd appinst farther from the user
   ...  - verify cloudlet update event is not received with new cloudlet

   [Tags]  DMEPersistentConnection

   ${r}=  Register Client
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=10  longitude=10
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}

   Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet2}  operator_org_name=dmuus  cluster_instance_name=autoclusteraa2

   Sleep  1s

   ${error}=  Run Keyword and Expect Error  *  Receive Cloudlet Update Event

   Should Contain  ${error}  no edge event received

# ECQ-3839
DmePersistentConnection - autoprov of new closer appinst shall return new cloudlet
   [Documentation]
   ...  - create 1 appinst
   ...  - create a dme persistent connection
   ...  - update app to add autprov policy and thus spin up new appinst closer
   ...  - verify cloudlet update event is received with new cloudlet

   [Tags]  DMEPersistentConnection

   [Teardown]  Autoprov Teardown

   &{cloudlet1}=  create dictionary  name=tmocloud-2  organization=dmuus
   @{cloudletlist}=  create list  ${cloudlet1}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  min_active_instances=1  max_instances=2  developer_org_name=${developer_org_name_automation}  cloudlet_list=${cloudletlist}
   @{policy_list}=  Create List  ${policy_return['data']['key']['name']}

   ${r}=  Register Client
   ${fcloudlet}=  Find Cloudlet  carrier_name=${operator}  latitude=35  longitude=-95
   Should Be Equal As Numbers  ${fcloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${fcloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  edge_events_cookie=${fcloudlet.edge_events_cookie}

   ${cluster}=  Create Cluster Instance  region=${region}  reservable=${True}  cloudlet_name=${cloudlet2}  operator_org_name=dmuus  ip_access=IpAccessDedicated  deployment=docker  developer_org_name=MobiledgeX

   Update App  region=${region}  app_name=${appname}  auto_prov_policies=@{policy_list}
   Wait For App Instance To Be Ready   region=${region}   app_name=${app_name}  cloudlet_name=${cloudlet2}

   Sleep  1s

   ${cloud1}=  Receive Cloudlet Update Event
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloud1.new_cloudlet.edge_events_cookie}') > 100
   Should Be Equal  ${cloud1.new_cloudlet.fqdn}  ${cluster['data']['key']['cluster_key']['name']}.${cloudlet2}.dmuus.mobiledgex.net
   Should Be Equal  ${cloud1.new_cloudlet.ports}  ${fcloudlet.ports}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.latitude}  ${cloudlet2_lat}
   Should Be Equal As Numbers  ${cloud1.new_cloudlet.cloudlet_location.longitude}  ${cloudlet2_long}

*** Keywords ***
Setup Suite
   ${cloudlet}=  Get Default Cloudlet Name
   Set Suite Variable  ${cloudlet}

Setup
   Create Flavor  region=${region}

   Create Org  orgtype=operator
   RestrictedOrg Update

   ${c}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=dmuus

   Create App  region=${region}  access_ports=tcp:1  developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}
   ${dmuus_appinst}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}   cloudlet_name=${c['data']['key']['name']}  operator_org_name=${c['data']['key']['organization']}  cluster_instance_name=autoclusteraa

   ${appname}=  Get Default App Name
   ${operator}=  Get Default Organization Name
   ${operator}=  Set Variable  dmuus
   Set Suite Variable  ${operator}
   Set Suite Variable  ${appname}

Autoprov Teardown
   @{policy_list}=  Create List
   Update App  region=${region}  app_name=${appname}  auto_prov_policies=@{policy_list}
   Wait For App Instance To Be Deleted  region=${region}  app_name=${app_name}  cloudlet_name=${cloudlet2}

   Cleanup Provisioning
