*** Settings ***
Documentation  RegisterClient

Library  MexDme  dme_address=${dme_api_address}

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0

*** Test Cases ***
RegisterClient - request shoudld return proper JWT
   Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
   ${decoded_cookie}=  decoded session cookie
   ${token_server}=    token server uri

   Should Be Equal  ${token_server}  http://127.0.0.1:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc

   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   Should Be Equal  ${decoded_cookie['key']['peerip']}  127.0.0.1	
   Should Be Equal  ${decoded_cookie['key']['devname']}  ${developer_name}	
   Should Be Equal  ${decoded_cookie['key']['appname']}  ${app_name}	
   Should Be Equal  ${decoded_cookie['key']['appvers']}  ${app_version}	
