*** Settings ***
Documentation   Flavor with GPU

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 

Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-1898
Flavor - shall be able to create flavor with gpu resources
    [Documentation]
    ...  create a flavor with gpu resource 
    ...  verify create is successful

    ${flavor}=  Create Flavor  region=${region}  optional_resources=gpu=gpu:1
    Should Be Equal  ${flavor['data']['opt_res_map']['gpu']}  gpu:1

    ${flavor_name}=  Get Default Flavor Name
    ${flavor}=  Create Flavor  region=${region}  flavor_name=${flavor_name}xx  optional_resources=gpu=gpu:4
    Should Be Equal  ${flavor['data']['opt_res_map']['gpu']}  gpu:4

    ${flavor}=  Create Flavor  region=${region}  flavor_name=${flavor_name}2  optional_resources=gpu=VGPU:4
    Should Be Equal  ${flavor['data']['opt_res_map']['gpu']}  VGPU:4

    ${flavor}=  Create Flavor  region=${region}  flavor_name=${flavor_name}3  optional_resources=gpu=x:4
    Should Be Equal  ${flavor['data']['opt_res_map']['gpu']}  x:4

    ${flavor}=  Create Flavor  region=${region}  flavor_name=${flavor_name}4  optional_resources=gpu=x:y:4
    Should Be Equal  ${flavor['data']['opt_res_map']['gpu']}  x:y:4

# ECQ-1899
Flavor - create shall fail with invalid gpu resources
    [Documentation]
    ...  create a flavor with invalid gpu resources
    ...  verify proper error is returned 

    #EDGECLOUD-1743 - CreateFlavor with invalid gpu value should return an error

    ${error}=  Run Keyword and Expect Error  *  Create Flavor  region=${region}  optional_resources=gpu=gpu:xx
    Should Contain  ${error}  ('code=400', 'error={"message":"Non-numeric resource count encountered, found xx"}')

    ${error}=  Run Keyword and Expect Error  *  Create Flavor  region=${region}  optional_resources=gpu=gpu:
    Should Contain  ${error}  ('code=400', 'error={"message":"Non-numeric resource count encountered, found "}')

# ECQ-1900
Flavor - create shall fail with invalid gpu resource type
    [Documentation]
    ...  create a flavor with invalid gpu resource type 
    ...  verify proper error is returned

# now supported
#    ${error}=  Run Keyword and Expect Error  *  Create Flavor  region=${region}  optional_resources=gpu=pu:1
#    Should Contain  ${error}  ('code=400', 'error={"message":"GPU resource type selector must be one of [gpu, pci, vgpu] found pu"}') 

    ${error}=  Run Keyword and Expect Error  *  Create Flavor  region=${region}  optional_resources=gpu=1
    Should Contain  ${error}  ('code=400', 'error={"message":"Missing manditory resource count, ex: optresmap=gpu=gpu:1"}') 

    ${error}=  Run Keyword and Expect Error  *  Create Flavor  region=${region}  optional_resources=gpu=
    Should Contain  ${error}  ('code=400', 'error={"message":"Missing manditory resource count, ex: optresmap=gpu=gpu:1"}')

# ECQ-1901
Flavor - create shall fail with invalid resource
    [Documentation]
    ...  create a flavor with invalid resource
    ...  verify proper error is returned

    ${error}=  Run Keyword and Expect Error  *  Create Flavor  region=${region}  optional_resources=pu=pu:1
    Should Contain  ${error}  ('code=400', 'error={"message":"Only GPU resources currently supported, use optresmap=gpu=$resource:[$specifier:]$count found pu"}')
