*** Settings ***
Documentation   CreateAppInst with accesstype failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-2

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

${region}=  US

*** Test Cases ***
Update - User shall not be able to UpdateApp to include skip_hc_port when app inst is running
    [Documentation]
    ...  create a docker based app instance
    ...  verify that UpdateApp to include skip_hc_port fails 

    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name_default}

    ${error_msg}=  Run Keyword And Expect Error  *  Update App  region=${region}  skip_hc_ports=tcp:2016  

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Field cannot be modified when AppInsts exist"}')

*** Keywords ***
Setup
    Create Flavor     region=${region}
    ${cluster_name_default}=  Get Default Cluster Name
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared
    Log To Console  Done Creating Cluster Instance
    Set Suite Variable  ${cluster_name_default}
  

