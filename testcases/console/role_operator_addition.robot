*** Settings ***
Documentation   Add users to Operator roles as OperatorManager
Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup     Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

${username}          mextester03
${password}          thequickbrownfoxjumpedoverthelazydog9$
${email}             mextester03@gmail.com

${org_name}          AnOperOrg
${timeout}           10 min

*** Test Cases ***
WebUI - OperatorManager shall be able to add a OperatorManager role to a user
    [Documentation]
    ...  Select an org and add the user with the OperatorManager role
    ...  Verify correct feedback
    ...  User should be assigned to the org with the correct role

    Open Browser
    Login to Mex Console  browser=${browser}  username=${username1_epoch}  password=${password}
    Open Compute  role=Operator
    Open Organizations  contains_organizations=${False}

    Add New Organization  organization_name=${org_name}  organization_type=Operator

    #Open Organizations
    Add New Organization User  username=${username2_epoch}  organization=${org_name}  role=Manager  flag=during_org_create

    Open Users
    #Filter Users  choice=Username
    Search Users  username=${username2_epoch}

    @{userws2}=  Get Table Data
    # If the label in front of each role type changes then the variable has to too
    #${role}=      Set Variable   MOperatorManager
    #${counter}=   Set Variable   ${0}

    #:FOR    ${row}    IN     @{userws2}
    #\  Exit For Loop If  '${row[2]}'=='${role}'
    #\  ${counter}=  Evaluate  ${counter} + 1

    Should Be Equal  ${userws2}[0][1]  ${username1_epoch}
    Should Be Equal  ${userws2}[0][2]  ${org_name}
    Should Be Equal  ${userws2}[0][3]  MOperatorManager 

    Should Be Equal  ${userws2}[1][1]  ${username2_epoch}
    Should Be Equal  ${userws2}[1][2]  ${org_name}
    Should Be Equal  ${userws2}[1][3]  MOperatorManager

    ${num_users}=  Get Length  ${userws2}
    Should Be Equal As Integers  ${num_users}  2

WebUI - OperatorManager shall be able to add a OperatorContributor role to a user
    [Documentation]
    ...  Select an org and add the user with the OperatorContributor role
    ...  Verify correct feedback
    ...  User should be assigned to the org with the correct role

    Open Browser
    Login to Mex Console  browser=${browser}  username=${username1_epoch}  password=${password}
    Open Compute  role=Operator
    Open Organizations  contains_organizations=${False}

    Add New Organization  organization_name=${org_name}  organization_type=Operator

    #Open Organizations
    Add New Organization User  username=${username2_epoch}  organization=${org_name}  role=Contributor  flag=during_org_create

    Open Users
    #Filter Users  choice=Username
    Search Users  username=${username2_epoch}

    @{userws2}=  Get Table Data
    # If the label in front of each role type changes then the variable has to too
    #${role}=      Set Variable   COperatorContributor
    #${counter}=   Set Variable   ${0}

    #:FOR    ${row}    IN     @{userws2}
    #\  Exit For Loop If  '${row[2]}'=='${role}'
    #\  ${counter}=  Evaluate  ${counter} + 1

    Should Be Equal  ${userws2}[0][1]  ${username1_epoch}
    Should Be Equal  ${userws2}[0][2]  ${org_name}
    Should Be Equal  ${userws2}[0][3]  MOperatorManager

    Should Be Equal  ${userws2}[1][1]  ${username2_epoch}
    Should Be Equal  ${userws2}[1][2]  ${org_name}
    Should Be Equal  ${userws2}[1][3]  COperatorContributor

    ${num_users}=  Get Length  ${userws2}
    Should Be Equal As Integers  ${num_users}  2

WebUI - OperatorManager shall be able to add a OperatorViewer role to a user
    [Documentation]
    ...  Select an org and add the user with the OperatorViewer role
    ...  Verify correct feedback
    ...  User should be assigned to the org with the correct role

    Open Browser
    Login to Mex Console  browser=${browser}  username=${username1_epoch}  password=${password}
    Open Compute  role=Operator
    Open Organizations  contains_organizations=${False}

    Add New Organization  organization_name=${org_name}  organization_type=Operator

    #Open Organizations
    Add New Organization User  username=${username2_epoch}  organization=${org_name}  role=Viewer  flag=during_org_create

    Open Users
    #Filter Users  choice=Username
    Search Users  username=${username2_epoch}

    @{userws2}=  Get Table Data
    # If the label in front of each role type changes then the variable has to too
    #${role}=      Set Variable   VOperatorViewer
    #${counter}=   Set Variable   ${0}

    #:FOR    ${row}    IN     @{userws2}
    #\  Exit For Loop If  '${row[2]}'=='${role}'
    #\  ${counter}=  Evaluate  ${counter} + 1

    Should Be Equal  ${userws2}[0][1]  ${username1_epoch}
    Should Be Equal  ${userws2}[0][2]  ${org_name}
    Should Be Equal  ${userws2}[0][3]  MOperatorManager

    Should Be Equal  ${userws2}[1][1]  ${username2_epoch}
    Should Be Equal  ${userws2}[1][2]  ${org_name}
    Should Be Equal  ${userws2}[1][3]  VOperatorViewer

    ${num_users}=  Get Length  ${userws2}
    Should Be Equal As Integers  ${num_users}  2

*** Keywords ***
Setup
    ${epoch_time}=   Get Time  epoch
    ${username1_epoch}=  Catenate  SEPARATOR=  ${username}  ${epoch_time}
    ${email1_epoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch_time}  @gmail.com
    ${username2_epoch}=  Catenate  SEPARATOR=  ${username}  ${epoch_time}  2
    ${email2_epoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch_time}  2  @gmail.com

    ${org_name}=  Catenate  SEPARATOR=  ${orgname}  ${epoch_time}

    Skip Verify Email
    Create User  username=${username1_epoch}  password=${password}  email_address=${email1_epoch} 
    Unlock User
    #Verify Email

    Create User  username=${username2_epoch}  password=${password}  email_address=${email2_epoch}
    Unlock User
    #Verify Email

    Set Suite Variable  ${username1_epoch}
    Set Suite Variable  ${username2_epoch}
    Set Suite Variable  ${org_name}

#    Open Browser
#    Open Signup
#    Run Keyword and Ignore Error  Signup New User  username=${username}  password=${password}  email_address=${email}
#    # need to sign in the gmail for this
#    Run Keyword and Ignore Error  Verification Email Should Be Received
#    sleep  2s
#    Run Keyword and Ignore Error  Verify New User
#    Run Keyword and Ignore Error  Unlock User     username=${username}
#    Close Browser

#    Open Browser
#    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
#    Open Compute
#    Open Organizations
#    # Cant delete the org since we aint ADMIN
#    Run Keyword and Ignore Error  Add New Organization  organization_name=${org_name}  organization_type=Operator
#    Open Organizations
#    Sort Organization Name  1
#    Add New Organization User  username=${console_username}  organization=${org_name}  role=Manager
#    Close Browser

Teardown
    Delete Org   orgname=${org_name}
    Cleanup Provisioning
    Close Browser
