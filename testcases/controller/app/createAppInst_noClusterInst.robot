*** Settings ***
Documentation   CreateAppInst without cluster instance

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
AppInst - User shall not be able to create an AppInst without a ClusterInst
    [Documentation]
    ...  create an app instance with no cluster name 
    ...  verify "Cloudlet operator_key:<>  not ready, state is CloudletStateNotPresent" is received
    #...  verify "No cluster name specified. Create one first or use "autocluster" as the name to automatically create a ClusterInst" is received 

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_name_default}  use_defaults=${False}   #cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  use_defaults=${False}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Invalid organization name"
    #Should Contain  ${error_msg}   details = "Cloudlet operator_key:<>  not ready, state is CloudletStateNotPresent"
    #Should Contain  ${error_msg}   details = "Invalid cluster name"
    #details = "No cluster name specified. Create one first or use "autocluster" as the name to automatically create a ClusterInst"

AppInst - User shall not be able to create an AppInst with a ClusterInst that doesnt exist
    [Documentation]
    ...  create an app instance with a cluster that doesnt exist
    ...  verify "Specified ClusterInst not found" is received

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_name_default}  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  use_defaults=${False} use_defaults=${False}   #cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  use_defaults=${False}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Specified ClusterInst not found"

AppInst - User shall not be able to create an app instance without cluster developer and no matching cluster instance
    [Documentation]
    ...  create a clusterinstance
    ...  create an app instance with matching cluster name and no cluster developer
    ...  verify "Specified ClusterInst not found" is received 

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  cluster  ${epoch_time}
    ${developer_name}=  Catenate  SEPARATOR=-  ${developer_name_default}  2 

    Create Cluster Instance  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_name} 

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  app_name=${app_name_default}  app_version=${app_version_default}  developer_org_name=${developer_name_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name}  use_defaults=${False}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Specified ClusterInst not found"


*** Keywords ***
Setup
    #Create Developer
    Create Flavor
    Create App                  access_ports=tcp:1

    ${app_name_default}=  Get Default App Name
    ${app_version_default}=  Get Default App Version
    ${developer_name_default}=  Get Default Developer Name
    ${flavor_name_default}=  Get Default Flavor Name

    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${app_version_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${flavor_name_default}

