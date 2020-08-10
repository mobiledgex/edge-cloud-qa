*** Settings ***
Documentation  VMPool CreateAppInst failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${operator_name_vmpool}=  TDG
${vmpool_server_name}=  vmpoolvm
${physical_name}=  berlin

${cloudlet_name_vmpool}=  cloudlet1595967146-891194

${region}=  EU 

*** Test Cases ***
# ECQ-2368
AppInst shall fail with VMPool and VM deployment 
   [Documentation]
   ...  - send CreateAppInst for vm deployment on vmpool cloudlet
   ...  - verify proper error is received

    Create App  region=${region}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015
    ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=dummycluster

   Should Contain  ${error}  {"result":{"message":"Encountered failures: Create App Inst failed: VM based applications are not support by PlatformTypeVmPool","code":400}}

*** Keywords ***
Setup
   Create Flavor  region=${region} 
