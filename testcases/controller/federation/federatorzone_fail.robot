*** Settings ***
Documentation    Federatorzone create failure tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${selfoperator}  TDG
${region}  EU
${selfcountrycode}  DE

*** Test Cases ***
# ECQ-4208
Federatorzone create - Controller shall throw error with invalid cloudlet
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federatorzone with invalid cloudlet name
    ...  Controller throws error

    @{cloudlets}=  Create List  XX

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Cloudlet \\\\\"XX\\\\\" doesn\\'t exist"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${super_token}
 
# ECQ-4209
Federatorzone create - Controller shall throw error with invalid operatorid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federatorzone with invalid operatorid
    ...  Controller throws error


    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Org XX not found"}')  Create FederatorZone  operatorid=XX  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${super_token}

# ECQ-4210
Federatorzone create - Controller shall throw error with invalid countrycode
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federatorzone with invalid countrycode
    ...  Controller throws error

    # EDGECLOUD-5979
    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid country code \\\\\"XX\\\\\". It must be a valid ISO 3166-1 Alpha-2 code for the country"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=XX  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${super_token}

# ECQ-4211
Federatorzone create - Controller shall throw error with invalid geolocation
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federatorzone with invalid geolocation
    ...  Controller throws error

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid geo location \\\\\"50\\\\\". Valid format: \\\\u003cLatInDecimal,LongInDecimal\\\\u003e"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${super_token}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid longitude \\\\\"\\\\\", must be a valid decimal number"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${super_token}

# ECQ-4212
Federatorzone create - Controller shall throw error with invalid region
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federatorzone with invalid region
    ...  Controller throws error

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Region \\\\\"XX\\\\\" not found"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=XX  zoneid=${federator_zone}  use_defaults=${False}  token=${super_token}

# ECQ-4213
Federatorzone create - Controller shall throw error with invalid zoneid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federatorzone with invalid zoneid
    ...  Controller throws error

    ${zoneid1}=  Generate Random String  7  [LETTERS][NUMBERS]
    ${zoneid2}=  Generate Random String  33  [LETTERS][NUMBERS]

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    # zoneid lesser than 7 characters
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid zone ID \\\\\"${zoneid1}\\\\\", valid length is 8 to 32 characters"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${zoneid1}  use_defaults=${False}  token=${super_token}

    # zoneid greater than 32 characters
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid zone ID \\\\\"${zoneid2}\\\\\", valid length is 8 to 32 characters"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${zoneid2}  use_defaults=${False}  token=${super_token}

    # zoneid starting with -
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid zone ID \\\\\"-${zoneid1}\\\\\", can only contain alphanumeric, -, _ characters"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=-${zoneid1}  use_defaults=${False}  token=${super_token}

    # zoneid starting with _
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid zone ID \\\\\"_${zoneid1}\\\\\", can only contain alphanumeric, -, _ characters"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=_${zoneid1}  use_defaults=${False}  token=${super_token}

    # zoneid ending with -
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid zone ID \\\\\"${zoneid1}-\\\\\", can only contain alphanumeric, -, _ characters"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${zoneid1}-  use_defaults=${False}  token=${super_token}

    # zoneid ending with _
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid zone ID \\\\\"${zoneid1}_\\\\\", can only contain alphanumeric, -, _ characters"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${zoneid1}_  use_defaults=${False}  token=${super_token}

    # zoneid containing @
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid zone ID \\\\\"xyz@${zoneid1}\\\\\", can only contain alphanumeric, -, _ characters"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=xyz@${zoneid1}  use_defaults=${False}  token=${super_token}

# ECQ-4214
Federatorzone create - Controller shall throw error while creating two zones with same zoneid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create two federatorzones with same zoneid
    ...  Controller throws error

    ${zoneid1}=  Generate Random String  8  [LETTERS][NUMBERS]

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${zoneid1}  use_defaults=${False}  token=${super_token}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Zone \\\\\"${zoneid1}\\\\\" already exists"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${zoneid1}  use_defaults=${False}  token=${super_token}

# ECQ-4215
Federatorzone share - Controller shall throw error with invalid federation name
    [Documentation]
    ...  Login as MexAdmin
    ...  Share federatorzone by providing invalid federation name
    ...  Controller throws error

    ${federation_name}=  Get Default Federation Name
    ${zoneid1}=  Generate Random String  8  [LETTERS][NUMBERS]

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${zoneid1}  use_defaults=${False}  token=${super_token}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Federation with name \\\\\"${federation_name}\\\\\" does not exist for self operator ID \\\\\"${selfoperator}\\\\\""}')  Share FederatorZone  zoneid=${zoneid1}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${super_token}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${federator_zone}=  Get Default Federator Zone
    ${cloudlet_name}=  Get Default Cloudlet Name

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${federator_zone}
    Set Suite Variable  ${cloudlet_name}
