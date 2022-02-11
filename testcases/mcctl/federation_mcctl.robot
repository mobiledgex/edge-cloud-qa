*** Settings ***
Documentation  Resource Management mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${operator}=  packet
${countrycode}  DE
${mcc}  49
${mnc}  101
${partneroperator}  TDG
${partnercountrycode}  SG
${federationaddr}   https://console-dev.mobiledgex.net:30001/
${version}=  latest

*** Test Cases ***
# ECQ-4228
Federator create - mcctl shall handle failures
   [Documentation]
   ...  - send federator create via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail FederatorCreate Via mcctl

      # missing arguments
      Error: missing required args: mnc  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}

      # invalid values
      Error: Bad Request (400), Org XX not found  operatorid=XX  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}
      Error: Bad Request (400), Operation only allowed for organizations of type operator  operatorid=${developer}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}
      Error: Bad Request (400), Invalid country code "XX". It must be a valid ISO 3166-1 Alpha-2 code for the country  operatorid=${operator}  countrycode=XX  mcc=${mcc}  mnc=${mnc}

# ECQ-4229
Federator create - mcctl shall be able to create/view/delete federator   
   [Documentation]
   ...  - send federator create with valid arguments
   ...  - verify federator is created

   [Template]  Success FederatorCreate Via mcctl

      # without providing federationid
      operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}      
 
      # with federationid 
      operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}

# ECQ-4230
Federator update - mcctl shall handle failures
   [Documentation]
   ...  - send federator update via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail FederatorUpdate Via mcctl

      # missing arguments
      Error: missing required args: federationid  operatorid=${operator}  mcc=102
     
      # invalid federationid 
      Error: Bad Request (400), Self federator with ID "${federationid}" does not exist for operator "${operator}"  operatorid=${operator}  federationid=${federationid}  mcc=102

# ECQ-4231
Federator update - mcctl shall be able to update federator
   [Documentation]
   ...  - send federator update via mcctl with updated values of mcc/mnc
   ...  - verify federator is updated

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success FederatorUpdate Via mcctl

      # update mcc and mnc of federator
      mcc=200  mnc=210
     
      # provide multiple values of mnc
      mcc=200  mnc=201 mnc=202  length=2

# ECQ-4232
Federation create - mcctl shall handle failures
    [Documentation]
   ...  - send federation create via mcctl with various error cases
   ...  - verify proper error is received

    [Template]  Fail FederationCreate Via mcctl

       # missing arguments
       Error: missing required args: apikey  selfoperatorid=${operator}  selffederationid=${federationid}  name=${federation_name}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partner_fed_id}  federationaddr=${federationaddr}

       # invalid values
       Error: Bad Request (400), Self federator with ID "${federationid}" does not exist for operator "${operator}"  selfoperatorid=${operator}  selffederationid=${federationid}  name=${federation_name}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partner_fed_id}  federationaddr=${federationaddr}  apikey=${partnerapikey}

       Error: Bad Request (400), Invalid federation name "_${federation_name}", valid format is ^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$  selfoperatorid=${operator}  selffederationid=${federationid}  name=_${federation_name}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partner_fed_id}  federationaddr=${federationaddr}  apikey=${partnerapikey}

       Error: Bad Request (400), Invalid federation name "-${federation_name}", valid format is ^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$  selfoperatorid=${operator}  selffederationid=${federationid}  name=-${federation_name}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partner_fed_id}  federationaddr=${federationaddr}  apikey=${partnerapikey}

       Error: Bad Request (400), Invalid federation name "@${federation_name}", valid format is ^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$  selfoperatorid=${operator}  selffederationid=${federationid}  name=@${federation_name}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partner_fed_id}  federationaddr=${federationaddr}  apikey=${partnerapikey}

       # currently fails
       Error: Bad Request (400), Invalid country code "XX". It must be a valid ISO 3166-1 Alpha-2 code for the country  selfoperatorid=${operator}  selffederationid=${federationid}  name=${federation_name}  operatorid=${partneroperator}  countrycode=XX  federationid=${partner_fed_id}  federationaddr=${federationaddr}  apikey=${partnerapikey}

# ECQ-4233
Federation create - mcctl shall be able to create/view/delete federation
    [Documentation] 
    ...  - send federation create/show/delete via mcctl 
    ...  - verify output of federation show

    [Template]  Success FederationCreate Via mcctl

       selfoperatorid=${operator}  selffederationid=${federationid}  name=${federation_name}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partner_fed_id}  federationaddr=${federationaddr}  apikey=${partnerapikey}

# ECQ-4234
Federatorzone create - mcctl shall handle failures
    [Documentation]
    ...  - send federatorzone create via mcctl with various error cases
    ...  - verify proper error is received

    [Template]  Fail FederatorZone Create Via mcctl

       # missing arguments
       Error: missing required args: region  zoneid=${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50,50 
       
       # invalid values
       Error: Bad Request (400), Cloudlet "${cloudlet_name}" doesn\\'t exist  zoneid=${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50,50  region=${region}  

       Invalid zone ID "_${zone}", can only contain alphanumeric, -, _ characters  zoneid=_${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50,50  region=${region}
      
       Invalid zone ID "-${zone}", can only contain alphanumeric, -, _ characters  zoneid=-${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50,50  region=${region}

       Invalid zone ID "@${zone}", can only contain alphanumeric, -, _ characters  zoneid=@${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50,50  region=${region}

       Error: Bad Request (400), Invalid geo location "50". Valid format: <LatInDecimal,LongInDecimal>  zoneid=${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50  region=${region}

       Error: Bad Request (400), Invalid longitude "", must be a valid decimal number  zoneid=${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50,  region=${region}

       Error: Bad Request (400), Region "XX" not found  zoneid=${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50,50  region=XX

# ECQ-4235
Federatorzone create - mcctl shall be able to create/view/delete federatorzones
    [Documentation]
    ...  - send federatorzone create/show/delete via mcctl
    ...  - verify output of federatorzone show

    [Template]  Success FederatorZone Create Via mcctl

        zoneid=${zone}  operatorid=${operator}  countrycode=${countrycode}  cloudlets=${cloudlet_name}  geolocation=50,50  region=${region}

*** Keywords ***
Setup
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]
   ${partner_fed_id}=  Generate Random String  8  [LETTERS][NUMBERS]
   ${federation_name}=  Get Default Federation Name
   ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]
   ${zone}=   Get Default Federator Zone

   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${federationid}   
   Set Suite Variable  ${partner_fed_id}
   Set Suite Variable  ${federation_name}
   Set Suite Variable  ${partnerapikey}
   Set Suite Variable  ${zone}

Fail FederatorCreate Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  federator create region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Success FederatorCreate Via mcctl
   [Arguments]   &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${create}=   Run mcctl  federator create region=${region} ${parmss}    version=${version}
   ${show}=  Run mcctl  federator show region=${region} federationid=${create['federationid']}  version=${version}
   Should Not Be Empty  ${show} 
   Run mcctl  federator delete operatorid=${operator} federationid=${create['federationid']}  version=${version} 

Fail FederatorUpdate Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  federator update region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Update Setup
   Run mcctl  federator create region=${region} operatorid=${operator} countrycode=${countrycode} mcc=${mcc} mnc=${mnc} federationid=${federationid}   version=${version}

Update Teardown
   Run mcctl  federator delete operatorid=${operator} federationid=${federationid}   version=${version}

Success FederatorUpdate Via mcctl
   [Arguments]   &{parms}

   &{new}=  Copy Dictionary  ${parms}
   Remove from Dictionary  ${parms}  length
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${create}=   Run mcctl  federator update operatorid=${operator} federationid=${federationid} ${parmss}    version=${version}
   ${show}=  Run mcctl  federator show region=${region} federationid=${federationid}  version=${version}
   Should Be Equal  ${show[0]['mcc']}  200
 
   IF  'length' in ${new}
       Length Should Be  ${show[0]['mnc']}  2
   ELSE
       Should Be Equal  ${show[0]['mnc'][0]}  210
   END

Fail FederationCreate Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  federation create ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Success FederationCreate Via mcctl
   [Arguments]   &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  federator create region=${region} operatorid=${operator} countrycode=${countrycode} mcc=${mcc} mnc=${mnc} federationid=${federationid}  version=${version}

   Run mcctl  federation create ${parmss}  version=${version}

   ${show}=  Run mcctl  federation show ${parmss}  version=${version}
   Should Not Be Empty  ${show}
  
   Run mcctl  federation delete selfoperatorid=${operator} name=${federation_name}  version=${version}

   Run mcctl  federator delete operatorid=${operator} federationid=${federationid}  version=${version}

Fail FederatorZone Create Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  federatorzone create ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Success FederatorZone Create Via mcctl
   [Arguments]   &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
  
   Run mcctl  cloudlet create region=${region} cloudlet=${cloudlet_name} cloudletorg=${operator} location.latitude=1 location.longitude=1 numdynamicips=1 platformtype=PlatformTypeFake

   Run mcctl  federatorzone create ${parmss}  version=${version}

   ${show}=  Run mcctl  federatorzone show ${parmss}  version=${version}
   Should Not Be Empty  ${show}

   Run mcctl  federatorzone delete zoneid=${zone} operatorid=${operator} countrycode=${countrycode}  version=${version}
   Run mcctl  cloudlet delete region=${region} cloudlet=${cloudlet_name} cloudletorg=${operator}  
