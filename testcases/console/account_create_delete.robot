*** Settings ***
Documentation   Create and delete an account

Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
#Library         Collections
#Library         String

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min

${username}          mextester06
${account_password}          Thequickbrownfoxjumpedoverthelazydog9$
${email_password}    thequickbrownfoxjumpedoverthelazydog9$
#${email}             mextester03@gmail.com

*** Test Cases ***
WebUI - Account creation should be possible
    [Documentation]
    ...  Sign up new user
    ...  Load Accounts page
    ...  Delete created user and confirm successfully updated
    #[Tags]  passing

    Open Signup
    Skip Verify Email   skip_verify_email=False
    Signup New User  username=${username_epoch}  account_password=${account_password}  email_password=${email_password}  email_address=${email}
    # need to sign in the gmail for that
    #sleep  5s
    #Verification Email Should Be Received
    #Verify New User

    #Unlock User     username=${username_epoch}

    #Close Browser
    #Open Browser
    #Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}

    #Open Compute
    #Open Accounts
    #sleep  5s

    #@{ws_acc}=  Get Table Data
    #${ws_pre}=  Get Length  ${ws_acc}

    # Until new button is... dealt with
    #${stringTEMP}=  Catenate  SEPARATOR=  New\n  ${username_epoch}
    #Log To Console  ${stringTEMP}
    #@{testList}=  Create List  ${stringTEMP}
    #Log To Console  \n${testList[0]}
    #Account Should Exist  account_name=${testList[0]}
    #Delete Account  account_name=${testList[0]}

    # HAVE TO USE EMAIL BC THIS NEW BUTTON HAS A \n NEW LINE CHAR
    #Account Should Exist  account_name=${username_epoch}  email=${email}  email_verified=${True}  locked=${False}  rowsize=Set
    #Delete Account  email=${email}  account_name=${username_epoch}  #tempName=${username}

    #@{ws_acc2}=  Get Table Data
    #${ws_post}=  Get Length  ${ws_acc2}
    #Should Not Be Equal  ${ws_pre}  ${ws_post}

*** Keywords ***
Setup
    Open Browser
    
    ${epoch_time}=  Get Time  epoch

    ${email}=     Catenate  SEPARATOR=  ${username}  +  ${epoch_time}  @gmail.com
    ${username_epoch}=  Catenate  SEPARATOR=  ${username}  ${epoch_time}

    Run Keyword and Ignore Error  Delete Account  email=${email}  tempName=${username_epoch}

    Set Suite Variable  ${email}
    Set Suite Variable  ${username_epoch}
 
Teardown
    Skip Verify Email 
    Run Keyword and Ignore Error  Delete User  username=${username_epoch}
    Cleanup Provisioning
    Close Browser
