*** Settings ***
Documentation    Federator create/update/delete/generateselfapikey failure tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${operator}  TDG
${region}  EU
${countrycode}  DE
${mcc}  49
${mnc1}  101

*** Test Cases ***
# ECQ-4187
Federator create - Controller shall throw error with invalid region
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator with invalid region
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Region \\\\\"XX\\\\\" not found"}')  Create Federator  region=XX  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc} 

# ECQ-4188
Federator create - Controller shall throw error with invalid operatorid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator with invalid operatorid
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Org XX not found"}')  Create Federator  region=${region}  operatorid=XX  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  

# ECQ-4189
Federator create - Controller shall throw error with developer org as operatorid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator with developer org as operatorid
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Operation only allowed for organizations of type operator"}')  Create Federator  region=${region}  operatorid=${developer_org_name_automation}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  

# ECQ-4190
Federator create - Controller shall throw error with invalid countrycode
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator with invalid countrycode
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid country code \\\\\"XX\\\\\". It must be a valid ISO 3166-1 Alpha-2 code for the country"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=XX  mcc=${mcc}  mnc=${mnc}  

# ECQ-4191
Federator create - Controller shall throw error with invalid federationid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator with invalid federationid
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]
    ${federationid1}=  Generate Random String  7  [LETTERS][NUMBERS]
    ${federationid2}=  Generate Random String  129  [LETTERS][NUMBERS]

    # federationid contains @
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid federation ID \\\\\"${federationid}@\\\\\", can only contain alphanumeric, -, _ characters"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}@  

    # federationid starting with -
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid federation ID \\\\\"-${federationid}\\\\\", can only contain alphanumeric, -, _ characters"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=-${federationid}  

    # federationid starting with _
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid federation ID \\\\\"_${federationid}\\\\\", can only contain alphanumeric, -, _ characters"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=_${federationid}  

    # federationid ending with -
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid federation ID \\\\\"${federationid}-\\\\\", can only contain alphanumeric, -, _ characters"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}-  

    # federationid ending with _
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid federation ID \\\\\"${federationid}_\\\\\", can only contain alphanumeric, -, _ characters"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}_  

    # federationid shorter than 8 characters
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid federation ID \\\\\"${federationid1}\\\\\", valid length is 8 to 128 characters"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid1}  
 
    # federationid longer than 128 characters
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid federation ID \\\\\"${federationid2}\\\\\", valid length is 8 to 128 characters"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid2}  

# ECQ-4192
Federator create - Controller shall throw while creating two federators with same federationid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create two federators with same federationid
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]

    Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"${federationid}\\\\\" already exists"}')  Create Federator  region=${region}  operatorid=packet  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  

# ECQ-4193
Federator update - Controller shall throw error with mismatched operatorid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator
    ...  Update the federator with correct federationid but incorrect operatorid
    ...  Controller throws error
  
    @{mnc}=  Create List  ${mnc1}

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  
    ${federationid}=  Set Variable  ${federator['federationid']}
    ${apikey}=  Set Variable  ${federator['apikey']}

    Append to List  ${mnc}  102

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"${federationid}\\\\\" does not exist for operator \\\\\"packet\\\\\""}')  Update Federator  operatorid=packet  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  

    Delete Federator  operatorid=${operator}  federationid=${federationid}

# ECQ-4194
Federator update - Controller shall throw error with invalid federationid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator
    ...  Update the federator with invalid federationid
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  
    ${federationid}=  Set Variable  ${federator['federationid']}
    ${apikey}=  Set Variable  ${federator['apikey']}

    Append to List  ${mnc}  102

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"XX\\\\\" does not exist for operator \\\\\"${operator}\\\\\""}')  Update Federator  operatorid=${operator}  mcc=${mcc}  mnc=${mnc}  federationid=XX  

    Delete Federator  operatorid=${operator}  federationid=${federationid}

# ECQ-4195
Federator delete - Controller shall throw error with mismatched operatorid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator
    ...  Delete the federator with correct federationid but incorrect operatorid
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  
    ${federationid}=  Set Variable  ${federator['federationid']}
    ${apikey}=  Set Variable  ${federator['apikey']}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"${federationid}\\\\\" does not exist for operator \\\\\"packet\\\\\""}')  Delete Federator  operatorid=packet  federationid=${federationid}

    Delete Federator  operatorid=${operator}  federationid=${federationid}

# ECQ-4196
Federator delete - Controller shall throw error with invalid federationid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator
    ...  Delete the federator with invalid federationid
    ...  Controller throws error

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"XX\\\\\" does not exist for operator \\\\\"${operator}\\\\\""}')  Delete Federator  operatorid=${operator}  federationid=XX

# ECQ-4197
Federator generateselfapikey - Controller shall throw error with mismatched operatorid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator
    ...  Generateselfapikey with correct federationid but incorrect operatorid
    ...  Controller throws error

    @{mnc}=  Create List  ${mnc1}

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  
    ${federationid}=  Set Variable  ${federator['federationid']}
    ${apikey}=  Set Variable  ${federator['apikey']}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"${federationid}\\\\\" does not exist for operator \\\\\"packet\\\\\""}')  GenerateSelfApiKey Federator  operatorid=packet  federationid=${federationid}

    Delete Federator  operatorid=${operator}  federationid=${federationid}

# ECQ-4198
Federator generateselfapikey - Controller shall throw error with invalid federationid
     [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator
    ...  Generateselfapikey with invalid federationid
    ...  Controller throws error

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"XX\\\\\" does not exist for operator \\\\\"${operator}\\\\\""}')  GenerateSelfApiKey Federator  operatorid=${operator}  federationid=XX

# ECQ-4242
Org delete - Controller shall throw error while deleting an operator org with a federator
     [Documentation]
    ...  Login as MexAdmin
    ...  Create an Operator org
    ...  Create a federator 
    ...  Controller throws error while deleting the operator org

    # EDGECLOUD-6010
    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]

    ${orgname}=  Create Org  token=${super_token}  orgtype=operator
    Create Federator  region=${region}  operatorid=${orgname}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Organization is in use by federator"}')  Delete Org

*** Keywords ***
Setup
    ${super_token}=  Get Super Token

    Set Suite Variable  ${super_token}

