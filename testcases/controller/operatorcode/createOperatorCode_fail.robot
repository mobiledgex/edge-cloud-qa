*** Settings ***
Documentation   CreateOperatorCode with possible error scenarios

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Variables      shared_variables.py

Suite Teardown  Cleanup Provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication   #has to match crm process startup parms
${region}  US
${code}  2561
${developer_name}  AcmeApp
${app_version}  1.0
${access_ports}    tcp:80,http:443,udp:10002
${operator_name}   tmus
${cloudlet_name1}  tmocloud-1
${cloudlet_lat1}   31
${cloudlet_long1}  -91
${cloudlet_name2}  tmocloud-2
${cloudlet_lat2}   35
${cloudlet_long2}  -95


*** Test Cases ***
CreateOperatorCode - create without region shall return error
   [Documentation]
   ...  send CreateOperatorCode without region
   ...  verify proper error is received

    ${error}=  Run Keyword And Expect Error  *    Create Operator Code  operator_name=${operator_name}  code=${code}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"no region specified"}

CreateOperatorCode - create without code shall return error
   [Documentation]
   ...  send CreateOperatorCode with region only
   ...  verify proper error is received

    ${error}=  Run Keyword And Expect Error  *    Create Operator Code  operator_name=${operator_name}  region=${region}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No code specified"}

CreateOperatorCode - create without operatorname
   [Documentation]
   ...  send CreateOperatorCode without operatorname
   ...  verify proper error is received

    ${error}=  Run Keyword And Expect Error  *   Create Operator Code  code=${code}  region=${region}  use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No operator name specified"}

CreateOperatorCode - create without operatorname and code
   [Documentation]
   ...  send CreateOperatorCode withour Code and Operator Name
   ...  verify proper error is received

   # start with a dash
   ${error}=  Run Keyword and Expect Error  *  Create Operator Code  region=${region}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No code specified"}


CreateCloudletPool - create with same name shall return error
   [Documentation]
   ...  send CreateOperatorName twice for same name
   ...  verify proper error is received

   Create Operator Code  region=${region}  code=${code}  operator_name=${operator_name}

   ${error}=  Run Keyword And Expect Error  *     Create Operator Code  region=${region}  code=${code}  operator_name=${operator_name}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"key ${code} already exists"}

