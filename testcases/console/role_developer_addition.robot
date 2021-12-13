*** Settings ***
Documentation   Add users to Developer roles as DeveloperManager
Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup     Setup
#Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

${username}          mextester03
${password}          thequickbrownfoxjumpedoverthelazydog9$
${email}             mextester03@gmail.com

${org_name}          ADevOrg
${timeout}           10 min

*** Test Cases ***
WebUI - DeveloperManager shall be able to add a DeveloperManager role to a user
    [Documentation]
    ...  Select an org and add the user with the DeveloperManager role
    ...  Verify correct feedback
    ...  User should be assigned to the org with the correct role

    Open Browser
    Login to Mex Console  browser=${browser}  username=${username1_epoch}  password=${password}
    Open Compute  role=Developer
    Open Organizations  contains_organizations=${False}

    Add New Organization  organization_name=${org_name}  organization_type=Developer

    #Open Organizations
    Add New Organization User  username=${username2_epoch}  organization=${org_name}  role=Manager  flag=during_org_create

    Open Users
    #Filter Users  choice=Username
    Search Users  username=${username2_epoch}

    @{userws2}=  Get Table Data
    # If the label in front of each role type changes then the variable has to too
    #${role}=      Set Variable   MDeveloperManager
    #${counter}=   Set Variable   ${0}

    #:FOR    ${row}    IN     @{userws2}
    #\  Exit For Loop If  '${row[2]}'=='${role} and '
    #\  ${counter}=  Evaluate  ${counter} + 1

    Should Be Equal  ${userws2}[0][1]  ${username1_epoch}
    Should Be Equal  ${userws2}[0][2]  ${org_name}
    Should Be Equal  ${userws2}[0][3]  MDeveloperManager 

    Should Be Equal  ${userws2}[1][1]  ${username2_epoch}
    Should Be Equal  ${userws2}[1][2]  ${org_name}
    Should Be Equal  ${userws2}[1][3]  MDeveloperManager

    ${num_users}=  Get Length  ${userws2}
    Should Be Equal As Integers  ${num_users}  2
 
WebUI - DeveloperManager shall be able to add a DeveloperContributor role to a user
    [Documentation]
    ...  Select an org and add the user with the DeveloperContributor role
    ...  Verify correct feedback
    ...  User should be assigned to the org with the correct role

    Open Browser
    Login to Mex Console  browser=${browser}  username=${username1_epoch}  password=${password}
    Open Compute  role=Developer
    Open Organizations  contains_organizations=${False}

    Add New Organization  organization_name=${org_name}  organization_type=Developer

    #Open Organizations
    Add New Organization User  username=${username2_epoch}  organization=${org_name}  role=Contributor  flag=during_org_create

    Open Users
    #Filter Users  choice=Username
    Search Users  username=${username2_epoch}

    @{userws2}=  Get Table Data
    # If the label in front of each role type changes then the variable has to too
    #${role}=      Set Variable   CDeveloperContributor
    #${counter}=   Set Variable   ${0}

    #:FOR    ${row}    IN     @{userws2}
    #\  Exit For Loop If  '${row[2]}'=='${role}'
    #\  ${counter}=  Evaluate  ${counter} + 1

    Should Be Equal  ${userws2}[0][1]  ${username1_epoch}
    Should Be Equal  ${userws2}[0][2]  ${org_name}
    Should Be Equal  ${userws2}[0][3]  MDeveloperManager

    Should Be Equal  ${userws2}[1][1]  ${username2_epoch}
    Should Be Equal  ${userws2}[1][2]  ${org_name}
    Should Be Equal  ${userws2}[1][3]  CDeveloperContributor

    ${num_users}=  Get Length  ${userws2}
    Should Be Equal As Integers  ${num_users}  2

WebUI - DeveloperManager shall be able to add a DeveloperViewer role to a user
    [Documentation]
    ...  Select an org and add the user with the DeveloperViewer role
    ...  Verify correct feedback
    ...  User should be assigned to the org with the correct role

    Open Browser
    Login to Mex Console  browser=${browser}  username=${username1_epoch}  password=${password}
    Open Compute  role=Developer
    Open Organizations  contains_organizations=${False}

    Add New Organization  organization_name=${org_name}  organization_type=Developer

    #Open Organizations
    Add New Organization User  username=${username2_epoch}  organization=${org_name}  role=Viewer  flag=during_org_create

    Open Users
    #Filter Users  choice=Username
    Search Users  username=${username2_epoch}

    @{userws2}=  Get Table Data
    # If the label in front of each role type changes then the variable has to too
    #${role}=      Set Variable   VDeveloperViewer
    #${counter}=   Set Variable   ${0}

    #:FOR    ${row}    IN     @{userws2}
    #\  Exit For Loop If  '${row[2]}'=='${role}'
    #\  ${counter}=  Evaluate  ${counter} + 1

    Should Be Equal  ${userws2}[0][1]  ${username1_epoch}
    Should Be Equal  ${userws2}[0][2]  ${org_name}
    Should Be Equal  ${userws2}[0][3]  MDeveloperManager

    Should Be Equal  ${userws2}[1][1]  ${username2_epoch}
    Should Be Equal  ${userws2}[1][2]  ${org_name}
    Should Be Equal  ${userws2}[1][3]  VDeveloperViewer

    ${num_users}=  Get Length  ${userws2}
    Should Be Equal As Integers  ${num_users}  2

*** Keywords ***
Setup
    #Open Browser
    #Open Signup

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

#    Signup New User  username=${username1_epoch}  password=${password}  email_address=${email1_epoch}
#    # need to sign in the gmail for this
#    sleep  2s
#    Verification Email Should Be Received
#    Verify New User
#    Unlock User     username=${username1_epoch}
#    Close Browser

#    Open Browser
#    Open Signup
#    Signup New User  username=${username2_epoch}  password=${password}  email_address=${email2_epoch}
#    # need to sign in the gmail for this
#    sleep  2s
#    Verification Email Should Be Received
#    Verify New User
#    Unlock User     username=${username2_epoch}
#    Close Browser

    #Open Browser
    #Login to Mex Console  browser=${browser}  username=${username1_epoch}  password=${password}
    #Open Compute
    #Open Organizations  contains_organizations=${False}
    #Add New Organization  organization_name=${org_name}  organization_type=Developer
    ##Open Organizations
    ##Sort Organization Name  1
    ##Add New Organization User  username=${username2_epoch}  organization=${org_name}  role=Manager
    #Close Browser

    Set Suite Variable  ${username1_epoch}
    Set Suite Variable  ${username2_epoch}
    Set Suite Variable  ${org_name}

Teardown
    Delete Org   orgname=${org_name}

    Cleanup Provisioning
   
    Close Browser
