*** Settings ***
Documentation   View organization details

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         String
	
Suite Setup      Setup
Suite Teardown   Teardown

Test Timeout    ${timeout}
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}     25 min

*** Test Cases ***
# ECQ-1552
WebUI - user shall be able view organization details
   [Documentation]
   ...  Show organizations
   ...  click an organization to view the details
   ...  Verify details are correct
   [Tags]  passing

   @{ws}=  Show Organizations  token=${token}

   Open Organizations

   #update for bug 1391

   FOR  ${row}  IN  @{ws}   
      ${ui_details}=  Open Organization Details  organization=${row['Name']}
      Log to Console  ${ui_details}
      ${org_lowercase}=  Convert to Lowercase  ${row['Name']}
    
      ${instructions}=  Catenate  SEPARATOR=  If your image is docker, please upload your image with your MobiledgeX Account Credentials to our docker registry using the following docker commands.\n
      ...  \n
      ...  $ docker login -u <username> docker.mobiledgex.net\n
      ...  $ docker tag <your application> docker.mobiledgex.net/  ${org_lowercase}  /images/<application name>:<version>\n
      ...  $ docker push docker.mobiledgex.net/  ${org_lowercase}  /images/<application name>:<version>\n
      ...  $ docker logout docker.mobiledgex.net\n
      ...  \n
      ...  If you image is VM, please upload your image with your MobiledgeX Account Credentials to our VM registry using the following curl command.\n\n
      ...  $ curl -u<username> -T <path_to_file> "https://artifactory.mobiledgex.net/artifactory/repo-  ${row['Name']}  /<target_file_path>" --progress-bar -o <upload status filename>\n
      log to console  -------------------
      log to console  ${instructions}
      log to console  ====================
      log to console  ${ui_details['instructions']}
      Should Be Equal             ${ui_details['Organization']}  ${row['Name']}
      Should Be Equal             ${ui_details['Type']}          ${row['Type']}
      Run Keyword If  'Phone' in ${ui_details}    Should Be Equal             ${ui_details['Phone']}         ${row['Phone']}
      Run Keyword If  'Address' in ${ui_details}  Should Be Equal             ${ui_details['Address']}       ${row['Address']}
      ${Value}=   Verify Instructions   orgtype=${row['Type']}  organization=${row['Name']}
      #Run Keyword If  '${row['Type']}' == 'developer'  Should Be Equal  ${details['instructions']}  ${instructions}  ELSE  Should Be Equal  ${details['instructions']}  ${EMPTY} 
      Run Keyword If  '${row['Type']}' == 'developer'          Should Be Equal  ${Value}  True  ELSE  Should Be Equal  ${Value}  EMPTY
      Run Keyword If  'EdgeboxOnly' in ${row}        Should Be Equal             ${ui_details['Edgebox Only']}       Yes
      Run Keyword If  'PublicImages' in ${row}       Should Be Equal             ${ui_details['Public Image']}       Yes
      Close Organization Details
   END


*** Keywords ***
	
Setup
    Open Browser	
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    ${token}=  Get Supertoken
    Set Suite Variable  ${token}

Teardown
    Close Browser