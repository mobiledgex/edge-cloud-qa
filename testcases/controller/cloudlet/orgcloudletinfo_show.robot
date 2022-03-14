*** Settings ***
Documentation   MasterController Artifactory

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
	
#Suite Setup	 Setup
Test Teardown    Cleanup provisioning

*** Variables ***
	
*** Test Cases ***
# ECQ-4421
MC - Admin shall be able to see orgcloudlet info
    [Documentation]
    ...  - do orgcloudletinfo show as admin 
    ...  - verify it returns all info

    Login  username=${admin_manager_username}  password=${admin_manager_password}
    
    ${info}=  Show Org Cloudlet Info  region=US  operator_org_name=TDG

    FOR  ${cloudlet}  IN  @{info}
        Should Contain  ${cloudlet}  state
        Should Contain  ${cloudlet}  key
        Should Contain  ${cloudlet}  resources_snapshot
    END

# ECQ-4422
MC - Operator shall not be able to see all orgcloudletinfo info
    [Documentation]
    ...  - do orgcloudletinfo show as operator
    ...  - verify it doesnt return sensitive info

    [Template]  Operator shall not be able to see all orgcloudletinfo data

    ${op_manager_user_automation}      ${op_manager_password_automation}
    ${op_contributor_user_automation}  ${op_contributor_password_automation}
    ${op_viewer_user_automation}       ${op_viewer_password_automation}

# ECQ-4423
MC - Developer shall not be able to see orgcloudletinfo info
    [Documentation]
    ...  - do orgcloudletinfo show as developer
    ...  - verify it fails

    [Template]  Developer shall not be able to see orgcloudletinfo data

    ${dev_manager_user_automation}      ${dev_manager_password_automation}
    ${dev_contributor_user_automation}  ${dev_contributor_password_automation}
    ${dev_viewer_user_automation}       ${dev_viewer_password_automation}

*** Keywords ***
Operator shall not be able to see all orgcloudletinfo data
    [Arguments]  ${username}  ${password}

    Login  username=${username}  password=${password}

    ${info}=  Show Org Cloudlet Info  region=US  operator_org_name=TDG

    FOR  ${cloudlet}  IN  @{info}
        Should Contain  ${cloudlet}  state
        Should Contain  ${cloudlet}  key
        Should Contain  ${cloudlet}  resources_snapshot

        Should Be Equal  ${cloudlet['resources_snapshot']['cluster_insts']}  ${None}
        Should Be Equal  ${cloudlet['resources_snapshot']['info']}           ${None}
        Should Be Equal  ${cloudlet['resources_snapshot']['k8s_app_insts']}  ${None}
        Should Be Equal  ${cloudlet['resources_snapshot']['platform_vms']}   ${None}
        Should Be Equal  ${cloudlet['resources_snapshot']['vm_app_insts']}   ${None}

    END

Developer shall not be able to see orgcloudletinfo data
    [Arguments]  ${username}  ${password}

    Login  username=${username}  password=${password}

    Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Org Cloudlet Info  region=US  operator_org_name=TDG

