*** Settings ***
Documentation   Create and delete 50 accounts

Library		    MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

#Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min

${hackusername}      HackTeam
${hackpassword}      hackteam123
${hackemail}         hackteamtester    #@gmail.com
${username}          mextester99
${password}          mextester99123
${email}             mextester99@gmail.com
  

*** Test Cases ***
Web UI - Shall be able to create 50 new accounts
    [Documentation]
    ...  Sign up new user
    ...  Load Accounts page
    ...  Delete created user and confirm successfully updated
    ...  Create 50 accounts
    #[Tags]  passing

   :FOR    ${i}    IN RANGE    50
    \  ${username1}=  Catenate  SEPARATOR=  ${username}  +  ${i} 
    \  ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    \  ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
    \  ${htmlusername}=  Catenate  SEPARATOR=  ${username}  &#43;  ${i}  @gmail.com
    \  Open Signup
    \  Signup New User  username=${username1}  password=${password}  email_address=${email1}
     #need to sign in the gmail for that
    \  sleep  5s
        # sleeps added to wait for console to load

    \  Verification Email Should Be Received  email_address=${htmlusername}
    \  Verify New User
    \  Unlock User     username=${username1}
   
    \  Close Browser
    \  Open Browser

    \  Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    \  Open Compute
    \  sleep  3s
    \  Open Accounts
    \  sleep  4s

    # Until new button is... dealt with
    \  ${stringTEMP}=  Catenate  SEPARATOR=  New\n  ${username1}
    \  Log To Console  ${stringTEMP}

    # HAVE TO USE EMAIL BC THIS NEW BUTTON HAS A \n NEW LINE CHAR
    \  Account Should Exist  account_name=${stringTEMP}  #account_name=${stringTEMP}username1
    \  Logout of Account

    Close Browser
    Open Browser

    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Open Compute
    sleep  3s
    Open Accounts
    sleep  4s
    
    :FOR    ${i}    IN RANGE    50
    \  ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    \  ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
    \  ${stringTEMP}=  Catenate  SEPARATOR=  New\n  ${username1}
    \  Delete Account  email=${email1}  account_name=${username1}
    \  sleep  5s

Web UI - Shall be able to create 40 new accounts
    [Documentation]
    ...  Sign up new user
    ...  Load Accounts page
    ...  Create 50 accounts
    ...  Add users to 40 organizations
    #[Tags]  passing

   :FOR    ${i}    IN RANGE    40
    \  ${number}=  Evaluate  ${i}+24
    \  ${email1}=  Catenate  SEPARATOR=  ${hackemail}  +  ${number}  @gmail.com
    \  ${username1}=  Catenate  SEPARATOR=  ${hackusername}  ${number}
    \  ${htmlusername}=  Catenate  SEPARATOR=  ${hackemail}  &#43;  ${number}  @gmail.com
    \  Open Signup
    \  Signup New User  username=${username1}  password=${hackpassword}  email_address=${email1}
     #need to sign in the gmail for that
    \  sleep  5s
        # sleeps added to wait for console to load
    \  Verification Email Should Be Received  email_address=${htmlusername}
    \  Verify New User
    \  Unlock User     username=${username1}
   
    \  Close Browser
    \  Open Browser

    \  Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    \  Open Compute
    \  sleep  3s
    \  Open Accounts
    \  sleep  4s

    # Until new button is... dealt with
    \  ${stringTEMP}=  Catenate  SEPARATOR=  New\n  ${username1}
    \  Log To Console  ${stringTEMP}

    # HAVE TO USE EMAIL BC THIS NEW BUTTON HAS A \n NEW LINE CHAR
    \  Account Should Exist  account_name=${username1}  #account_name=${stringTEMP}username1
    
    \  Open Organizations
    \  ${organization}=  Catenate  SEPARATOR=  HackathonTeam-  ${number}
    \  Add New Organization User  username=${username1}  organization=${organization}  role=Contributor
    
    \  Open Users
    \  Search Users  username=${username1}
    
    \  Logout of Account

*** Keywords ***
Setup
    Open Browser

Teardown
    
    Cleanup Provisioning
    Close Browser
