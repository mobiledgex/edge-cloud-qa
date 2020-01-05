*** Settings ***
Documentation   Flavor with GPU

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 

Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
Flavor - shall be able to create flavor with 1 gpu resource 
    [Documentation]
    ...  create a flavor with gpu resource 
    ...  verify create is successful

    ${flavor}=  Create Flavor  region=${region}  optional_resources=gpu=1

    Should Be Equal  ${flavor['data']['opt_res_map']['gpu']}  1

Flavor - shall be able to create flavor with 4 gpu resources
    [Documentation]
    ...  create a flavor with gpu resources
    ...  verify create is successful

    ${flavor}=  Create Flavor  region=${region}  optional_resources=gpu=4

    Should Be Equal  ${flavor['data']['opt_res_map']['gpu']}  4

Flavor - create shall faile with invalid gpu resources
    [Documentation]
    ...  create a flavor with gpu resources = xx
    ...  verify proper error is returned 

    EDGECLOUD-1743 - CreateFlavor with invalid gpu value should return an error

    ${flavor}=  Create Flavor  region=${region}  optional_resources=gpu=xx

    Should Be Equal  ${flavor['data']['opt_res_map']['gpu']}  4

