*** Settings ***
Documentation   CreateAppInst with developer mismatch

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Teardown   Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

# not supported anymore. we can now create it without a developer

*** Test Cases ***
AppInst - User shall not be able to create an AppInst with a developer mismatch with ClusterInst Developer
    [Documentation]
    ...  create an app instance with developer mismatch with cluster instance developer 
    ...  verify error is received
    
    Create Flavor
    Create App  developer_org_name=${developer_org_name_automation}
    Create Cluster Instance  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  developer_org_name=MobiledgeX
    
    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}   cluster_instance_developer_org_name=MobiledgeX 

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "Developer name mismatch between App: ${developer_org_name_automation} and ClusterInst: MobiledgeX"

