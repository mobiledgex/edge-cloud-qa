*** Settings ***
Documentation  CreateCloudlet mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${region}=  US
${operator}=  dmuus

${version}=  latest

*** Test Cases ***
# ECQ-3085
CreateCloudlet - mcctl shall be able to create/show/delete cloudlet
   [Documentation]
   ...  - send CreateCloudlet/ShowCloudlet/DeleteCloudlet via mcctl with various parms
   ...  - verify app is created/shown/deleted

   [Tags]  AllianceOrg

   [Template]  Success Create/Show/Delete Cloudlet Via mcctl
      # trusted
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  trustpolicy=${trustpolicy_name} 
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  trustpolicy=

      # kafka
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  kafkacluster=x
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  kafkacluster=cluster  kafkauser=user  kafkapassword=password

      # alliance orgs
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  allianceorgs=dmuus 
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  allianceorgs=dmuus allianceorgs=GDDT
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  allianceorgs:empty=true

# ECQ-3086
CreateCloudlet - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateCloudlet via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  AllianceOrg

   [Template]  Fail Create Cloudlet Via mcctl
      # missing values
      #Error: Bad Request (400), Unknown image type IMAGE_TYPE_UNKNOWN  appname=${app_name}  app-org=${developer}  appvers=1.0

      # trusted
      Error: OK (200), TrustPolicy x for organization dmuus not found  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  trustpolicy=x

      # kafka
      Error: OK (200), Must specify both kafka username and password, or neither  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  kafkacluster=cluster  kafkauser=user
      Error: OK (200), Must specify both kafka username and password, or neither  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  kafkacluster=cluster  kafkapassword=password
      Error: OK (200), Must specify a kafka cluster endpoint in addition to kafka credentials  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  kafkauser=user  kafkapassword=password
      Error: OK (200), Must specify a kafka cluster endpoint in addition to kafka credentials  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  kafkacluster=${Empty}  kafkauser=user  kafkapassword=password
      Error: OK (200), Must specify both kafka username and password, or neither  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  kafkauser=user 
      Error: OK (200), Must specify both kafka username and password, or neither  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  kafkapassword=password

      # alliance orgs
      Error: Bad Request (400), Org notfound not found  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  allianceorgs=notfound

# ECQ-3087
UpdateCloudlet - mcctl shall handle update cloudlet 
   [Documentation]
   ...  - send UpdateCloudlet via mcctl with various args
   ...  - verify proper is updated

   [Tags]  AllianceOrg

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success Update/Show Cloudlet Via mcctl
      # trusted
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  trustpolicy=${trustpolicy_name} 
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  trustpolicy=

      # kafka
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  kafkacluster=x
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  kafkacluster=cluster  kafkauser=user  kafkapassword=password

      # alliance orgs
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  allianceorgs=dmuus
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  allianceorgs=dmuus allianceorgs=GDDT

# ECQ-3609
FindFlavorMatch - mcctl shall handle findflavormatch
   [Documentation]
   ...  - send FindFlavorMatch via mcctl with various args
   ...  - verify flavor is returned or error is received

   [Setup]

   ${show}=  Run mcctl  cloudlet findflavormatch region=${region} cloudlet=tmocloud-1 cloudlet-org=dmuus flavor=automation_api_flavor  version=${version}
   Should Be Equal  ${show['key']['name']}  tmocloud-1
   Should Be Equal  ${show['key']['organization']}  dmuus
   Should Be Equal  ${show['flavor_name']}  x1.small

   ${error1}=  Run Keyword And Expect Error  *  Run mcctl  cloudlet findflavormatch region=${region} cloudlet-org=dmuus  version=${version}
   Should Contain  ${error1}  missing required args

   ${error2}=  Run Keyword And Expect Error  *  Run mcctl  cloudlet findflavormatch region=${region} cloudlet=tmocloud-1  version=${version}
   Should Contain  ${error2}  missing required args

   ${error3}=  Run Keyword And Expect Error  *  Run mcctl  cloudlet findflavormatch region=${region} cloudlet=tmocloud-1 cloudlet-org=dmuus  version=${version}
   Should Contain  ${error3}  missing required args

# ECQ-3610
ShowFlavorsFor - mcctl shall handle showflavorsfor
   [Documentation]
   ...  - send ShowFlavorsFor via mcctl with various args
   ...  - verify flavor is returned or error is received

   [Setup]

   ${show}=  Run mcctl  cloudlet showflavorsfor region=${region} cloudlet=tmocloud-1 cloudlet-org=dmuus  version=${version}
   Should Contain  ${show}  automation_api_flavor

   ${error1}=  Run Keyword And Expect Error  *  Run mcctl  cloudlet showflavorsfor region=${region}  version=${version}
   Should Contain  ${error1}  missing required args

   ${error2}=  Run Keyword And Expect Error  *  Run mcctl  cloudlet showflavorsfor region=${region} cloudlet=tmocloud-1   version=${version}
   Should Contain  ${error2}  missing required args

   ${error3}=  Run Keyword And Expect Error  *  Run mcctl  cloudlet showflavorsfor region=${region} cloudlet-org=dmuus   version=${version}
   Should Contain  ${error3}  missing required args

# ECQ-3957
AddAllianceOrg - mcctl shall handle cloudlet addallianceorg
   [Documentation]
   ...  - send AddAllianceOrg/RemoveAllianceOrg via mcctl with various args
   ...  - verify alliance org is updated

   [Tags]  AllianceOrg

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   Run mcctl  cloudlet addallianceorg region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} organization=packet   version=${version}
   ${show}=  Run mcctl  cloudlet show region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator}  version=${version}

   Run mcctl  cloudlet addallianceorg region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} organization=GDDT   version=${version}
   ${show1}=  Run mcctl  cloudlet show region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator}  version=${version}

   Run mcctl  cloudlet removeallianceorg region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} organization=packet   version=${version}
   ${show2}=  Run mcctl  cloudlet show region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator}  version=${version}

   Run mcctl  cloudlet removeallianceorg region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} organization=GDDT   version=${version}
   ${show3}=  Run mcctl  cloudlet show region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator}  version=${version}

   @{alliancelist}=  Create List  packet 
   Should Be Equal  ${show[0]['alliance_orgs']}  ${alliancelist}

   @{alliancelist}=  Create List  packet  GDDT
   Should Be Equal  ${show1[0]['alliance_orgs']}  ${alliancelist}

   @{alliancelist}=  Create List  GDDT
   Should Be Equal  ${show2[0]['alliance_orgs']}  ${alliancelist}

   Should Be True  'alliance_orgs' not in ${show3[0]}

# ECQ-3958
AddAllianceOrg - mcctl shall handle cloudlet addallianceorg failures
   [Documentation]
   ...  - send AddAllianceOrg via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  AllianceOrg

   [Template]  Fail Add Alliance Org Via mcctl
      # missing values
      Error: missing required args  cloudlet=${cloudlet_name}
      Error: missing required args  cloudlet-org=${cloudlet_name}
      Error: missing required args  organization=${cloudlet_name}
      Error: missing required args  cloudlet=${cloudlet_name} cloudlet-org=${cloudlet_name}
      Error: missing required args  cloudlet=${cloudlet_name} organization=${cloudlet_name}
      Error: missing required args  cloudlet-org=${cloudlet_name} organization=${cloudlet_name}

      Error: Bad Request (400), Org notfound not found  cloudlet=tmocloud-2 cloudlet-org=dmuus organization=notfound

      Error: Bad Request (400), Cloudlet key {"organization":"yyyy","name":"xxxx"} not found  cloudlet=xxxx cloudlet-org=yyyy organization=dmuus

# ECQ-3989
AddAllianceOrg - mcctl shall handle cloudlet removeallianceorg failures
   [Documentation]
   ...  - send RemoveAllianceOrg via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  AllianceOrg

   [Template]  Fail Remove Alliance Org Via mcctl
      # missing values
      Error: missing required args  cloudlet=${cloudlet_name}
      Error: missing required args  cloudlet-org=${cloudlet_name}
      Error: missing required args  organization=${cloudlet_name}
      Error: missing required args  cloudlet=${cloudlet_name} cloudlet-org=${cloudlet_name}
      Error: missing required args  cloudlet=${cloudlet_name} organization=${cloudlet_name}
      Error: missing required args  cloudlet-org=${cloudlet_name} organization=${cloudlet_name}

      Error: Bad Request (400), Cloudlet key {"organization":"yyyy","name":"xxxx"} not found  cloudlet=xxxx cloudlet-org=yyyy organization=dmuus

# ECQ-3959
UpdateCloudlet - mcctl shall handle allianceorg clear
   [Documentation]
   ...  - send UpdateCloudlet with allianceorgs=empty:true via mcctl
   ...  - verify alliance org is cleared

   [Tags]  AllianceOrg

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   Run mcctl  cloudlet update region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} allianceorgs=dmuus allianceorgs=GDDT  version=${version}
   ${show}=  Run mcctl  cloudlet show region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator}  version=${version}

   Run mcctl  cloudlet update region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} allianceorgs:empty=true  version=${version}
   ${show2}=  Run mcctl  cloudlet show region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator}  version=${version}

   Should Not Contain  ${show2[0]}  alliance_orgs

*** Keywords ***
Setup
   ${cloudlet_name}=  Get Default Cloudlet Name

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}
   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator}
   ${trustpolicy_name}=  Set Variable  ${policy_return['data']['key']['name']}
   
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${trustpolicy_name}
 
Success Create/Show/Delete Cloudlet Via mcctl
   [Arguments]  &{parms}
   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   Remove From Dictionary  ${parms_copy}  kafkapassword
   Remove From Dictionary  ${parms_copy}  kafkauser
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
 
   Run mcctl  cloudlet create region=${region} ${parmss} --debug  version=${version}
   ${show}=  Run mcctl  cloudlet show region=${region} ${parmss_modify}  version=${version}
   Run mcctl  cloudlet delete region=${region} ${parmss_modify}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['cloudlet']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['cloudlet-org']}
   Should Be Equal As Numbers  ${show[0]['location']['latitude']}   ${parms['location.latitude']}
   Should Be Equal As Numbers  ${show[0]['location']['longitude']}  ${parms['location.longitude']}
   Should Be Equal As Numbers  ${show[0]['num_dynamic_ips']}        ${parms['numdynamicips']}
   Should Be Equal As Numbers  ${show[0]['state']}                  5

   IF  'trustpolicy' in ${parms}
      IF  '${parms['trustpolicy']}' != '${Empty}'
         Should Be Equal  ${show[0]['trust_policy']}  ${parms['trustpolicy']}
         Should Be Equal As Numbers  ${show[0]['trust_policy_state']}  5
      END
   ELSE
      Should Not Contain  ${show[0]}  trust_policy
      Should Be Equal As Numbers  ${show[0]['trust_policy_state']}  1
   END

   IF  'kafkacluster' in ${parms}
      Should Be Equal  ${show[0]['kafka_cluster']}  ${parms['kafkacluster']}
   END

   IF  'allianceorgs' in ${parms}
      @{alliancelist}=  Split String  ${parms['allianceorgs']}  ${SPACE}allianceorgs=
      Should Be Equal  ${show[0]['alliance_orgs']}  ${alliancelist}
   END
   IF  'allianceorgs:empty' in ${parms}
      Should Not Contain  ${show[0]}  alliance_orgs
   END

Update Setup
   #${cloudlet_name}=  Get Default Cloudlet Name

   #Set Suite Variable  ${cloudlet_name}

   Setup 

   Run mcctl  cloudlet create region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} location.latitude=1 location.longitude=1 numdynamicips=1 platformtype=PlatformTypeFake 

Update Teardown
   Run mcctl  cloudlet delete region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} location.latitude=1 location.longitude=1 numdynamicips=1

   Cleanup Provisioning

Success Update/Show Cloudlet Via mcctl
   [Arguments]  &{parms}
   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   Remove From Dictionary  ${parms_copy}  kafkapassword
   Remove From Dictionary  ${parms_copy}  kafkauser
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   Run mcctl  cloudlet update region=${region} ${parmss}  version=${version}
   ${show}=  Run mcctl  cloudlet show region=${region} ${parmss_modify}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['cloudlet']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['cloudlet-org']}
   Should Be Equal As Numbers  ${show[0]['state']}     5

   IF  'trustpolicy' in ${parms}
      IF  '${parms['trustpolicy']}' != '${Empty}'
         Should Be Equal  ${show[0]['trust_policy']}  ${parms['trustpolicy']}
         Should Be Equal As Numbers  ${show[0]['trust_policy_state']}  5
      END
   ELSE
      Should Not Contain  ${show[0]}  trust_policy
      Should Be Equal As Numbers  ${show[0]['trust_policy_state']}  1
   END

   IF  'kafkacluster' in ${parms}
      Should Be Equal  ${show[0]['kafka_cluster']}  ${parms['kafkacluster']}
   END

   IF  'allianceorgs' in ${parms}
      @{alliancelist}=  Split String  ${parms['allianceorgs']}  ${SPACE}allianceorgs=
      Should Be Equal  ${show[0]['alliance_orgs']}  ${alliancelist}
   END

Fail Create Cloudlet Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudlet create region=${region} ${parmss}  version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Add Alliance Org Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudlet addallianceorg region=${region} ${parmss}  version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Remove Alliance Org Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudlet removeallianceorg region=${region} ${parmss}  version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
