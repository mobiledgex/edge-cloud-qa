*** Settings ***
Documentation   RegisterClient with tags

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}

*** Variables ***

*** Test Cases ***
# ECQ-3162
RegisterClient - shall be able to send request with tags
   [Documentation]
   ...  - send registerClient with same tags as the mobile does
   ...  - send findCloudlet and verify it is found

   ${tags}=  Create Dictionary  Build.VERSION.SDK_INT  29   
   ...                          DataNetworkType        NETWORK_TYPE_IWLAN  
   ...                          DeviceSoftwareVersion  23  
   ...                          ManufacturerCode       35184511    
   ...                          NetworkCountryIso      us  
   ...                          NetworkOperatorName    xmobx  
   ...                          PhoneType              1  
   ...                          SimCountryCodeIso      de 
   ...                          SimOperatorName        telecom.de

   ${regresp}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  unique_id=myid  unique_id_type=mytype  tags=${tags}

   ${cloudlet}=  Find Cloudlet       carrier_name=dmuus  latitude=34  longitude=-96
   Should Be Equal  ${cloudlet['status']}  FindFound
   Should Be Equal  ${cloudlet['fqdn']}    shared.tmocloud-1.dmuus.mobiledgex.net
   Should Be True   len('${cloudlet['edge_events_cookie']}') > 100

   ${decoded_cookie}=  decoded session cookie
   ${token_server}=    token server uri
   Should Be Equal  ${token_server}  ${token_server_url}

   ${uuid_length}=  Get Length  ${decoded_cookie['key']['uniqueid']}

   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs

   Should Match Regexp         ${decoded_cookie['key']['peerip']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
   Should Be Equal             ${decoded_cookie['key']['orgname']}  ${developer_org_name_automation}
   Should Be Equal             ${decoded_cookie['key']['appname']}  ${app_name_automation}
   Should Be Equal             ${decoded_cookie['key']['appvers']}  1.0
   Should Be Equal             ${decoded_cookie['key']['uniqueid']}  myid
   Should Be Equal             ${decoded_cookie['key']['uniqueidtype']}  mytype
