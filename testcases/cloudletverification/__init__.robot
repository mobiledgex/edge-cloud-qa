*** Settings ***
Documentation  Cloudlet Verification 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  auto_login=${False}
#Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}  auto_login=${False}

Suite Setup     Setup
Suite Teardown  Teardown

Test Timeout    ${test_timeout}

*** Variables ***
${test_timeout}=  32mins
${region}=  EU

${run_test_teardown}=  ${True}

*** Keywords ***
Setup
#   Create Org  orgname=${operator_name}  orgtype=operator  address="123 main street"  phone=123-456-7890
#   ${flavor_default}=  Get Default Flavor Name

   Run Keyword If  ${create_flavors}  Create Flavors

Teardown
   Log To Console  Cleaning Up Tests

   Run Keyword If  ${run_test_teardown}  Cleanup Provisioning
   ...  ELSE  Log to Console  Teardown is disabled. Not cleaning up tests

Create Flavors
   Log To Console  Creating Flavors

   Login  username=${username_mexadmin}  password=${password_mexadmin}

   Create Flavor  region=${region}  flavor_name=${flavor_name_small}  ram=1024  vcpus=1  disk=20           #Docker/K8s Flavor
   Create Flavor  region=${region}  flavor_name=${flavor_name_medium}  ram=4096  vcpus=2  disk=20          #Docker/K8s Flavor
   Create Flavor  region=${region}  flavor_name=${flavor_name_large}  ram=8192  vcpus=4  disk=20           #Docker/K8s Flavor
   Create Flavor  region=${region}  flavor_name=${flavor_name_vm}  disk=80                                 #VM flavor
   Create Flavor  region=${region}  flavor_name=${flavor_name_gpu}  disk=80  optional_resources=gpu=gpu:1  #GPU flavor

