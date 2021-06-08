*** Settings ***
Documentation  org mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${version}=  latest

*** Test Cases ***
# ECQ-3432
ShowOrg - mcctl shall be able to show orgs
   [Documentation]
   ...  - send org show via mcctl with various parms
   ...  - verify success

   [Template]  Success ShowOrg Via mcctl
       name_to_check=GDDT                 num_results=-1
       name_to_check=GDDT                 num_results=1   name=GDDT

       name_to_check=dmuus                num_results=-1  type=operator
       name_to_check=automation_dev_org  num_results=-1  type=developer
       name_to_check=${None}             num_results=0   type=x

       name_to_check=automation_dev_org  num_results=1   phone=1112223333
       name_to_check=${None}             num_results=0   phone=x

       name_to_check=automation_dev_org  num_results=1   address="1 automation blvd"
       name_to_check=${None}             num_results=0   address="no address"

       name_to_check=${None}             num_results=-1  publicimages=true 
       name_to_check=GDDT                 num_results=-1  publicimages=false

       name_to_check=${None}             num_results=0   deleteinprogress=true
       name_to_check=GDDT                 num_results=-1  deleteinprogress=false

       name_to_check=${None}             num_results=-1  edgeboxonly=true
       name_to_check=GDDT                 num_results=-1  edgeboxonly=false

*** Keywords ***
Success ShowOrg Via mcctl
   [Arguments]  &{parms}

   ${name_to_check}=  Set Variable  ${parms['name_to_check']}
   ${num_results}=  Set Variable  ${parms['num_results']}

   Remove From Dictionary  ${parms}  name_to_check  # dont send this as an arg
   Remove From Dictionary  ${parms}  num_results  # dont send this as an arg
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   @{result}=  Run mcctl  org show ${parmss_modify}  version=${version}

   ${found}=  Set Variable  ${False}
   IF  '${name_to_check}' != '${None}'
      FOR  ${key}  IN  @{result}
         IF  '${name_to_check}' != '${None}' and '${key['Name']}' == '${name_to_check}'
             ${found}=  Set Variable  ${True}
             Exit For Loop
         END
      END
   ELSE
      ${found}=  Set Variable  ${True}
   END
   Should Be True  ${found}

   FOR  ${key}  IN  @{result}
      Should Be True  'Name' in ${key}
      Should Be True  'Type' in ${key}
   
      IF  'type' in ${parms}
         Should Be Equal  ${key['Type']}  ${parms['type']}
      END
      IF  'phone' in ${parms}
         Should Be Equal  ${key['Phone']}  ${parms['phone']}
      END
      IF  'publicimages' in ${parms}
         IF  '${parms['publicimages']}' == 'true'
            Should Be True  ${key['PublicImages']}
         ELSE
            Should Be True  'PublicImages' not in ${key}
         END
      END
      IF  'deleteinprogress' in ${parms}
         IF  '${parms['deleteinprogress']}' == 'true'
            Should Be True  ${key['DeleteInProgress']}
         ELSE
            Should Be True  'DeleteInProgress' not in ${key}
         END
      END
      IF  'edgeboxonly' in ${parms}
         IF  '${parms['edgeboxonly']}' == 'true'
            Should Be True  ${key['EdgeboxOnly']}
         ELSE
            Should Be True  'EdgeboxOnly' not in ${key}
         END
      END


   END

   IF  ${num_results} >= 0
      Length Should Be  ${result}  ${num_results}
   END

