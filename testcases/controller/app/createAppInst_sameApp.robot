*** Settings ***
Documentation   CreateAppInst with same app

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

${region}=  US

*** Test Cases ***
# ECQ-3138
CreateAppInst - error shall be received when creating 2 appinst with same app with version=1.0 and version=10
    [Documentation]
    ...  - create an 2 apps with same name but  with version=1.0 and version=10
    ...  - create an app instance with version=1.0
    ...  - create an app instance with version=10
    ...  - verify error is received

    ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}

    Create App Instance  region=${region}  app_version=1.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}
    ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=10  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}

    Should Contain  ${error}  ('code=400', 'error={"message":"Cannot deploy AppInst due to DNS name collision with existing instance app_key:\\\\u003corganization:\\\\"automation_dev_org\\\\" name:\\\\"${app_name_default}\\\\" version:\\\\"1.0\\\\" \\\\u003e cluster_inst_key:\\\\u003ccluster_key:\\\\u003cname:\\\\"${cluster_name}\\\\" \\\\u003e cloudlet_key:\\\\u003corganization:\\\\"${operator_name}\\\\" name:\\\\"${cloudlet_name}\\\\" \\\\u003e organization:\\\\"MobiledgeX\\\\" \\\\u003e  - app-key:\\\\u003corganization:\\\\"automation_dev_org\\\\"name:\\\\"${app_name_default}\\\\"version:\\\\"10\\\\"\\\\u003ecluster-inst-key:\\\\u003ccluster-key:\\\\u003cname:\\\\"${cluster_name}\\\\"\\\\u003ecloudlet-key:\\\\u003corganization:\\\\"${operator_name}\\\\"name:\\\\"${cloudlet_name}\\\\"\\\\u003eorganization:\\\\"mobiledgex\\\\"\\\\u003e"}')

*** Keywords ***
Setup
    Create Flavor  region=${region}
    Create App  region=${region}  app_version=1.0  access_ports=tcp:1
    Create App  region=${region}  app_version=10  access_ports=tcp:1

    ${epoch_time}=  Get Time  epoch

    ${app_name_default}=  Get Default App Name
    ${app_version_default}=  Get Default App Version
    ${developer_name_default}=  Get Default Developer Name
    ${flavor_name_default}=  Get Default Flavor Name
  
    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${app_version_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${flavor_name_default}
    Set Suite Variable  ${epoch_time}

Teardown
    Cleanup provisioning
