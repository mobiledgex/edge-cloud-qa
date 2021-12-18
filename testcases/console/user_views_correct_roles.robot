*** Settings ***
Documentation   Users organizations check should work
Library         MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

#Test Setup      Setup
Test Teardown   Teardown
Test Timeout    ${timeout}


*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min
${tester_account_username}  mextester99
${tester_account_password}  mextester99123
${OPorgname}  oporgtester01
${DEVorgname}  devorgtester1
${roleOV}  OperatorViewer
${roleOC}  OperatorContributor
${roleOM}  OperatorManager
${roleDV}  DeveloperViewer
${roleDC}  DeveloperContributor
${roleDM}  DeveloperManager

*** Test Cases ***
Web UI - User shall be able to view the correct Operator Viewer Roles
    [Documentation]
    ...  Change user role to OPERATOR VIEWER through MexMaster
    ...  Log into user account
    ...  Select Organization
    ...  Confirm User views the correct OPERATOR VIEWER permissions
    ...  Delete User role
    [Tags]  passing

    Create Org    orgname=${OPorgname}  orgtype=operator
    Adduser Role  orgname=${OPorgname}  username=${tester_account_username}  role=${roleOV}  

    Open Browser
    Login to Mex Console  browser=${browser}  username=${tester_account_username}  password=${tester_account_password}
    #Login to user account
    Open Compute

    Open Organizations
    Select Organization  organization=${OPorgname}
    
    Organizations Menu Should Exist
    Users Menu Should Exist
    Cloudlet Menu Should Exist
    Flavor Menu Should Not Exist
    Cluster Instances Menu Should Not Exist
    Apps Menu Should Not Exist
    App Instances Menu Should Not Exist

    Organization New Button Should Be Enabled
    Organization Manage Button Should Be Enabled
    Organization Add User Button Should Be Disabled
    Organization Trash Icon Should Be Disabled
    
    Open Users
    Users Trash Icon Should Be Disabled
    
    Open Cloudlets Page
    Cloudlet New Button Should Be Disabled
    Cloudlet Trash Icon Should Be Disabled

    
Web UI - User shall be able to view the correct Operator Contributor Roles
    [Documentation]
    ...  Change user role to OPERATOR CONTRIBUTOR through MexMaster
    ...  Log into user account
    ...  Select Organization
    ...  Confirm User views the correct OPERATOR CONTRIBUTOR permissions
    ...  Delete User role
    [Tags]  passing

    Adduser Role  orgname=${OPorgname}  username=${tester_account_username}  role=${roleOC}

    Open Browser
    Login to Mex Console  browser=${browser}  username=${tester_account_username}  password=${tester_account_password}
    #Login to user account
    Open Compute

    Open Organizations
    Select Organization  organization=${OPorgname}
    
    Organizations Menu Should Exist
    Users Menu Should Exist
    Cloudlet Menu Should Exist
    Flavor Menu Should Not Exist
    Cluster Instances Menu Should Not Exist
    Apps Menu Should Not Exist
    App Instances Menu Should Not Exist

    Organization New Button Should Be Enabled
    Organization Add User Button Should Be Disabled
    Organization Trash Icon Should Be Disabled
    
    Open Users
    Users Trash Icon Should Be Disabled
    
    Open Cloudlets
    Cloudlet New Button Should Be Enabled
    Cloudlet Trash Icon Should Be Enabled

    

Web UI - User shall be able to view the correct Operator Manager Roles
    [Documentation]
    ...  Change user role to OPERATOR MANAGER through MexMaster
    ...  Log into user account
    ...  Select Organization
    ...  Confirm User views the correct OPERATOR MANAGER permissions
    ...  Delete User role
    [Tags]  passing

    Adduser Role  orgname=${OPorgname}  username=${tester_account_username}  role=${roleOM}

    Open Browser
    Login to Mex Console  browser=${browser}  username=${tester_account_username}  password=${tester_account_password}
    #Login to user account
    Open Compute

    Open Organizations
    Select Organization  organization=${OPorgname}
    
    Organizations Menu Should Exist
    Users Menu Should Exist
    Cloudlet Menu Should Exist
    Flavor Menu Should Not Exist
    Cluster Instances Menu Should Not Exist
    Apps Menu Should Not Exist
    App Instances Menu Should Not Exist

    Organization New Button Should Be Enabled
    Organization Add User Button Should Be Enabled
    Organization Trash Icon Should Be Enabled
    
    Open Users
    Users Trash Icon Should Be Enabled
    
    Open Cloudlets
    Cloudlet New Button Should Be Enabled
    Cloudlet Trash Icon Should Be Enabled

    
Web UI - User shall be able to view the correct Developer Viewer Roles
    [Documentation]
    ...  Change user role to DEVELOPER VIEWER through MexMaster
    ...  Log into user account
    ...  Select Organization
    ...  Confirm User views the correct DEVELOPER VIEWER permissions
    ...  Delete User role
    [Tags]  passing

    Adduser Role  orgname=${DEVorgname}  username=${tester_account_username}  role=${roleDV}

    Open Browser
    Login to Mex Console  browser=${browser}  username=${tester_account_username}  password=${tester_account_password}
    #Login to user account
    Open Compute

    Open Organizations
    Select Organization  organization=${DEVorgname}
    
    Organizations Menu Should Exist
    Users Menu Should Exist
    Cloudlet Menu Should Exist
    Flavor Menu Should Exist
    Cluster Instances Menu Should Exist
    Apps Menu Should Exist
    App Instances Menu Should Exist

    Organization New Button Should Be Enabled
    Organization Add User Button Should Be Disabled
    Organization Trash Icon Should Be Disabled
    
    Open Users
    Users Trash Icon Should Be Disabled
    
    Open Cloudlets Page
    Cloudlet New Button Should Be Disabled
    Cloudlet Trash Icon Should Be Disabled
    
    Open Flavors Page
    Flavor New Button Should Be Disabled
    Flavor Trash Icon Should Be Disabled
    
    Open Cluster Instances Page
    Cluster Instances New Button Should Be Disabled
    Cluster Instances Trash Icon Should Be Disabled
    
    Open Apps Page
    Apps New Button Should Be Disabled
    Apps Trash Icon Should Be Disabled
   
    Open App Instances Page
    App Instances New Button Should Be Disabled
    App Instances Trash Icon Should Be Disabled
    
Web UI - User shall be able to view the correct Developer Contributor Roles
    [Documentation]
    ...  Change user role to DEVELOPER CONTRIBUTOR through MexMaster
    ...  Log into user account
    ...  Select Organization
    ...  Confirm User views the correct DEVELOPER CONTRIBUTOR permissions
    ...  Delete User role
    [Tags]  passing

    Adduser Role  orgname=${DEVorgname}  username=${tester_account_username}  role=${roleDC}

    Open Browser
    Login to Mex Console  browser=${browser}  username=${tester_account_username}  password=${tester_account_password}
    #Login to user account
    Open Compute

    Open Organizations
    Select Organization  organization=${DEVorgname}
    
    Organizations Menu Should Exist
    Users Menu Should Exist
    Cloudlet Menu Should Exist
    Flavor Menu Should Exist
    Cluster Instances Menu Should Exist
    Apps Menu Should Exist
    App Instances Menu Should Exist

    Organization New Button Should Be Enabled
    Organization Add User Button Should Be Disabled
    Organization Trash Icon Should Be Disabled
    
    Open Users
    Users Trash Icon Should Be Disabled
    
    Open Cloudlets Page
    Cloudlet New Button Should Be Disabled
    Cloudlet Trash Icon Should Be Disabled
    
    Open Flavors Page
    Flavor New Button Should Be Disabled
    Flavor Trash Icon Should Be Disabled
    
    Open Cluster Instances Page
    Cluster Instances New Button Should Be Enabled
    Cluster Instances Trash Icon Should Be Enabled
    
    Open Apps Page
    Apps New Button Should Be Enabled
    Apps Trash Icon Should Be Enabled
    
    Open App Instances Page
    App Instances New Button Should Be Enabled
    App Instances Trash Icon Should Be Enabled


Web UI - User shall be able to view the correct Developer Manager Roles
    [Documentation]
    ...  Change user role to DEVELOPER MANAGER through MexMaster
    ...  Log into user account
    ...  Select Organization
    ...  Confirm User views the correct DEVELOPER MANAGER permissions
    ...  Delete User role
    [Tags]  passing

    Adduser Role  orgname=${DEVorgname}  username=${tester_account_username}  role=${roleDM}
    Open Browser
    Login to Mex Console  browser=${browser}  username=${tester_account_username}  password=${tester_account_password}
    #Login to user account
    Open Compute

    Open Organizations
    Select Organization  organization=${DEVorgname}
    
    Organizations Menu Should Exist  
    Users Menu Should Exist
    Cloudlet Menu Should Exist
    Flavor Menu Should Exist
    Cluster Instances Menu Should Exist
    Apps Menu Should Exist
    App Instances Menu Should Exist

    Organization New Button Should Be Enabled
    Organization Add User Button Should Be Enabled
    Organization Trash Icon Should Be Enabled
    
    Open Users
    Users Trash Icon Should Be Enabled
    
    Open Cloudlets Page
    Cloudlet New Button Should Be Disabled
    Cloudlet Trash Icon Should Be Disabled
    
    Open Flavors Page
    Flavor New Button Should Be Disabled
    Flavor Trash Icon Should Be Disabled
    
    Open Cluster Instances Page
    Cluster Instances New Button Should Be Enabled
    Cluster Instances Trash Icon Should Be Enabled
    
    Open Apps Page
    Apps New Button Should Be Enabled
    Apps Trash Icon Should Be Enabled
    
    Open App Instances Page
    App Instances New Button Should Be Enabled
    App Instances Trash Icon Should Be Enabled

    
*** Keywords ***

Teardown
    Cleanup Provisioning
    Close Browser
