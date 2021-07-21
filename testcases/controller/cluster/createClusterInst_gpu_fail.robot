*** Settings ***
Documentation   CreateClusterInst with GPU failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-2

${qcow_gpu_ubuntu16_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

${region}=  US

*** Test Cases ***
ClusterInst - User shall not be able to create a docker/shared ClusterInst with GPU flavor on cloudlet that doesnt support GPU
    [Documentation]
    ...  create a docker/shared cluster instance with gpu flavor but no gpu supported on cloudlet
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  
 
    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet ${cloudlet_name} doesn\\\'t support GPU"}')

ClusterInst - User shall not be able to create a docker/dedicated ClusterInst with GPU flavor on cloudlet that doesnt support GPU
    [Documentation]
    ...  create a docker/dedicated cluster instance with gpu flavor but no gpu supported on cloudlet
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet ${cloudlet_name} doesn\\\'t support GPU"}')

ClusterInst - User shall not be able to create a k8s/shared ClusterInst with GPU flavor on cloudlet that doesnt support GPU
    [Documentation]
    ...  create a k8s/shared cluster instance with gpu flavor but no gpu supported on cloudlet
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet ${cloudlet_name} doesn\\\'t support GPU"}')

ClusterInst - User shall not be able to create a k8s/dedicated ClusterInst with GPU flavor on cloudlet that doesnt support GPU
    [Documentation]
    ...  create a k8s/dedicated cluster instance with gpu flavor but no gpu supported on cloudlet
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated

    Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet ${cloudlet_name} doesn\\\'t support GPU"}')

*** Keywords ***
Setup
    Create Flavor  region=${region}  disk=80  optional_resources=gpu=gpu:1

    ${flavor_name_default}=  Get Default Flavor Name
    Set Suite Variable  ${flavor_name_default}

