*** Settings ***
Documentation   CreateAppInst without cluster instance

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
AppInst - User shall not be able to create an AppInst without a ClusterInst
    [Documentation]
    ...  create an app instance with no cluster name 
    ...  verify "No cluster name specified. Create one first or use "autocluster" as the name to automatically create a ClusterInst" is received 

    ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "No cluster name specified. Create one first or use "autocluster" as the name to automatically create a ClusterInst"

