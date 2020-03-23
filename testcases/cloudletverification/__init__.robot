*** Settings ***
Documentation  Cloudlet Verification 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup     Setup
#Suite Teardown  Teardown

Test Timeout    ${test_timeout}

*** Variables ***
${test_timeout}=  32mins
${region}=  EU

*** Keywords ***
Setup
#   Create Org  orgname=${operator_name_openstack}  orgtype=operator  address="123 main street"  phone=123-456-7890
   Create Flavor  region=${region}  ram=1024  vcpus=1  disk=20    #Docker/K8s Flavor

#   ${flavor_default}=  Get Default Flavor Name
   
#   Create Flavor  region=${region}  flavor_name=${flavor_default}vm  disk=80  #VM flavor

Teardown
   Log To Console  Cleaning Up Tests

   Cleanup Provisioning

