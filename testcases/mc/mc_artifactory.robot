*** Settings ***
Documentation   MasterController Artifactory

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
	
#Suite Setup	 Setup
Test Teardown    Cleanup provisioning

*** Variables ***
	
*** Test Cases ***
# ECQ-4412
MC - Admin shall be able to see artifactory summary info
    [Documentation]
    ...  - do artifactory summary as admin 
    ...  - verify it returns all info

    Login  username=${admin_manager_username}  password=${admin_manager_password}
    
    ${info}=  Show Artifactory Summary

    Should Contain  ${info}  Groups
    Should Contain  ${info}  Users
    Should Contain  ${info}  GroupMembers

# ECQ-4413
MC - Non-admin shall not be able to see artifactory summary info
    [Documentation]
    ...  - do artifactory summary as all non-admin types of operator and developer
    ...  - verify it returns forbidden

    [Template]  Non-admin shall not be able to see artifactory summary

    ${op_manager_user_automation}      ${op_manager_password_automation}
    ${op_contributor_user_automation}  ${op_contributor_password_automation}
    ${op_viewer_user_automation}       ${op_viewer_password_automation}

    ${dev_manager_user_automation}      ${dev_manager_password_automation}
    ${dev_contributor_user_automation}  ${dev_contributor_password_automation}
    ${dev_viewer_user_automation}       ${dev_viewer_password_automation}

*** Keywords ***
Non-admin shall not be able to see artifactory summary
    [Arguments]  ${username}  ${password}

    Login  username=${username}  password=${password}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Artifactory Summary
