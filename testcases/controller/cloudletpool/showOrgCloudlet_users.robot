*** Settings ***
Documentation  ShowOrgCloudlet for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator}=  tmus
${operator0}=  att
#&{cloudlet0}=  cloudlet=attcloud-1  operator=att
#&{cloudlet1}=  cloudlet=tmocloud-1  operator=tmus
#&{cloudlet2}=  cloudlet=tmocloud-2  operator=tmus
#&{cloudlet3}=  cloudlet=automationGcpCentralCloudlet  operator=gcp
#&{cloudlet4}=  cloudlet=automationAzureCentralCloudlet  operator=azure

${region}=  US

#@{cloudlets}=  &{cloudlet0}  &{cloudlet1}  &{cloudlet2}  &{cloudlet3}  &{cloudlet4}

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-1708
ShowOrgCloudlet - org shall be assigned to 1 cloudlet 
   [Documentation]
   ...  - assign 1 cloudlet to the pool for org1 
   ...  - send ShowOrgCloudlet for org1 and verify it returns the 1 cloudlet
   ...  - send ShowOrgCloudlet for org2 and verify it returns the other cloudlets 

   [Tags]  CloudletPoolAccess

   @{cloudlet_list}  Create List  ${cloudlets[1]['cloudlet']}

   Run Keyword If  '${cloudlets[1]['operator']}' != 'tmus'  Adduser Role  token=${super_token}  orgname=${cloudlets[1]['operator']}  username=${op_manager_user_automation}  role=OperatorManager

   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}   #operator_org_name=${operator}
   Update Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_list=${cloudlet_list}
   #Add Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False
   
   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  org_name=${orgname}     #cloudlet_pool_org_name=${operator}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}  #org_name=${cloudlets[1]['operator']}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}  #org_name=${cloudlets[2]['operator']}

   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlets[1]['cloudlet']}  ${cloudlets[1]['operator']}
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${num_public_cloudlets}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${num_public_cloudlets}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${num_public_cloudlets}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${num_public_cloudlets}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${cloudlet_length1}
   Length Should Be   ${show_return2}  ${cloudlet_length2}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return}  ${cloudlets[1]['cloudlet']}  ${cloudlets[1]['operator']}   

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return2}  ${cloudlets[1]['cloudlet']}  ${cloudlets[1]['operator']}

   #Should Be Equal  ${show_return[0]['key']['name']}  ${cloudlets[1]['cloudlet']} 
   #Should Be Equal  ${show_return[0]['key']['organization']}  ${cloudlets[1]['operator']}

   #Cloudlets Should Be In List  ${public_cloudlet_list}  ${show_return}

   #Cloudlets Should Be In List  ${public_cloudlet_list}  ${show_return2}

   #${cloudlets2}=  Remove from List  ${cloudlets}  1
   #${len}=  Get Length  ${cloudlets}	
   ##@{cloudlets2}=  Create List  ${cloudlet0}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
   #Cloudlets Should Be In List  ${cloudlets}  ${show_return2}
   #Length Should Be   ${show_return2}  ${len}

# ECQ-1709
ShowOrgCloudlet - org shall be assigned to 2 cloudlets
   [Documentation]
   ...  - assign 2 cloudlet to the pool for org1
   ...  - send ShowOrgCloudlet for org1 and verify it returns the 2 cloudlets
   ...  - send ShowOrgCloudlet for org2 and verify it returns the other cloudlets

   [Tags]  CloudletPoolAccess

   #Adduser Role  token=${super_token}  orgname=tmus  username=${epochusernameop}  role=OperatorManager

   Create Cloudlet Pool      region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}  #cloudlet_name=tmocloud-1
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=tmocloud-2

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False

   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}

   ${org_cloudlets1}=  Set Variable  ${num_public_cloudlets}
   ${org_cloudlets2}=  Set Variable  ${num_public_cloudlets}

   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${org_cloudlets1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${org_cloudlets2}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${org_cloudlets2}  # pool cloudlet is already private

   ${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length2}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length2}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${cloudlet_length1}
   Length Should Be   ${show_return2}  ${cloudlet_length2}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return}  tmocloud-2  tmus

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return2}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return2}  tmocloud-2  tmus

# ECQ-1710
# removing since we can no longer add cloudletst that have apps/clusters
#ShowOrgCloudlet - org shall be assigned to all cloudlets
#   [Documentation]
#   ...  - assign all cloudlet to the pool for org1
#   ...  - send ShowOrgCloudlet for org1 and verify it returns all the cloudlets
#   ...  - send ShowOrgCloudlet for org2 and verify it returns no cloudlets
#
#   [Tags]  CloudletPoolAccess
#
#   # create a cloudlet pool for every org
#   &{org_dict}=  Create Dictionary
#   FOR  ${cloudlet}  IN  @{cloudlets}
#      Set To Dictionary  ${org_dict}  ${cloudlet['operator']}  found
#   END
#   FOR  ${c}  IN  @{org_dict.keys()}  
#      IF  '${c}' != 'tmus' 
#          Run Keyword and Ignore Error  Adduser Role  token=${super_token}  orgname=${c}  username=${op_manager_user_automation}  role=OperatorManager
#      END
#      #Run Keyword If  '${c}' != 'tmus'  Adduser Role  token=${super_token}  orgname=${c}  username=${op_manager_user_automation}  role=OperatorManager
#      Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${c}  operator_org_name=${c}
#      Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${c}     cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  use_defaults=False
#      Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False
#   END
#
#   # add members to the pool
#   FOR  ${cloudlet}  IN  @{cloudlets}
#      Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${cloudlet['operator']}  operator_org_name=${cloudlet['operator']}  cloudlet_name=${cloudlet['cloudlet']}
#   END
#
#   # add to org cloudlet pool
#   #FOR  ${c}  IN  @{org_dict.keys()}
#   #   Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  org_name=${orgname}
#   #END
#   
#   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
#   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}
#
#   ${len_cloudlets}=  Get Length  ${cloudlets}
#
#   Cloudlets Should Be In List  ${cloudlets}  ${show_return}
#   Length Should Be   ${show_return}  ${len_cloudlets}
#
#   Length Should Be   ${show_return2}  0

# ECQ-1711
ShowOrgCloudlet - orgs shall be assigned to different cloudlets
   [Documentation]
   ...  - assign different cloudlets to 2 different orgs 
   ...  - send ShowOrgCloudlet for each org and verify the cloudlets 

   [Tags]  CloudletPoolAccess

   Adduser Role  token=${super_token}  orgname=azure  username=${op_manager_user_automation}  role=OperatorManager
   #Adduser Role  token=${super_token}  orgname=tmus  username=${epochusernameop}  role=OperatorManager

   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure
   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure  cloudlet_name=automationAzureCentralCloudlet
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=tmocloud-2

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  decision=accept  use_defaults=False

   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  org_name=${orgname}
   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus   org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}

   ${org_cloudlets1}=  Set Variable  ${num_public_cloudlets}
   ${org_cloudlets2}=  Set Variable  ${num_public_cloudlets}

   ${inlist0}=  Is Cloudlet In List  ${public_cloudlet_list}  automationAzureCentralCloudlet  azure 
   ${cloudlet_length1}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist0}'=='${True}'   Evaluate  ${org_cloudlets2}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${org_cloudlets2}  # pool cloudlet is already private

   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   ${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${cloudlet_length1}
   Length Should Be   ${show_return2}  ${cloudlet_length2}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return}   automationAzureCentralCloudlet  azure 
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  tmocloud-2  tmus

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return2}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  tmocloud-2  tmus

# ECQ-1712
ShowOrgCloudlet - orgs shall be assigned the same cloudlet
   [Documentation]
   ...  - assign same cloudlet to 2 different orgs
   ...  - send ShowOrgCloudlet for each org and verify the cloudlets

   [Tags]  CloudletPoolAccess

   #Adduser Role  token=${super_token}  orgname=tmus  username=${epochusernameop}  role=OperatorManager

   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=tmus
   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=tmocloud-2

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  decision=accept  use_defaults=False

   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  org_name=${orgname}
   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}

   ${org_cloudlets1}=  Set Variable  ${num_public_cloudlets}
   ${org_cloudlets2}=  Set Variable  ${num_public_cloudlets}

   ${inlist0}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus 
   ${cloudlet_length1}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets2}  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${org_cloudlets2}  # pool cloudlet is already private

   ${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist2}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist2}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${cloudlet_length1}
   Length Should Be   ${show_return2}  ${cloudlet_length2}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return}   ${cloudlet_name1}  tmus 
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  tmocloud-2  tmus

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  tmocloud-2  tmus

# ECQ-1713
ShowOrgCloudlet - orgs shall be assigned the same pool 
   [Documentation]
   ...  - assign 2 orgs to same orgcloudletpool
   ...  - send ShowOrgCloudlet for each org and verify the cloudlets

   [Tags]  CloudletPoolAccess

   #Adduser Role  token=${super_token}  orgname=tmus  username=${epochusernameop}  role=OperatorManager

   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=tmus
   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus

   #Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}

   Add Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}
   Add Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}
   Add Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=tmocloud-2

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  decision=accept  use_defaults=False

   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  org_name=${orgname}
   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}

   ${org_cloudlets1}=  Set Variable  ${num_public_cloudlets}
   ${org_cloudlets2}=  Set Variable  ${num_public_cloudlets}

   ${inlist0}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus
   ${cloudlet_length1}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets2}  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  1+${org_cloudlets2}  # pool cloudlet is already private

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return}   ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  ${cloudlet_name1}  tmus

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  tmocloud-2  tmus
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  tmocloud-2  tmus

# ECQ-1714
ShowOrgCloudlet - orgs shall be changed to different pools
   [Documentation]
   ...  - assign 2 orgs to 2 different orgcloudletpools 
   ...  - send ShowOrgCloudlet for each org and verify the cloudlets
   ...  - send orgcloudletpool delete and re-create by swithing the orgs
   ...  - send ShowOrgCloudlet for each org and verify the cloudlets have switched orgs

   [Tags]  CloudletPoolAccess

   Adduser Role  token=${super_token}  orgname=azure  username=${op_manager_user_automation}  role=OperatorManager
   #Adduser Role  token=${super_token}  orgname=tmus  username=${op_manager_user_automation}  role=OperatorManager

   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure
   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure  cloudlet_name=automationAzureCentralCloudlet
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=tmocloud-2

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  auto_delete=False
   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  auto_delete=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False  auto_delete=${False}
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  decision=accept  use_defaults=False  auto_delete=${False}

   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  org_name=${orgname}
   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}

   ${org_cloudlets1}=  Set Variable  ${num_public_cloudlets}
   ${org_cloudlets2}=  Set Variable  ${num_public_cloudlets}

   ${inlist0}=  Is Cloudlet In List  ${public_cloudlet_list}  automationAzureCentralCloudlet  azure
   ${cloudlet_length1}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist0}'=='${True}'   Evaluate  ${org_cloudlets2}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${org_cloudlets2}  # pool cloudlet is already private

   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   ${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${cloudlet_length1}
   Length Should Be   ${show_return2}  ${cloudlet_length2}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  tmocloud-2  tmus

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return2}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  tmocloud-2  tmus

#   @{cloudlets1}=  Create List  ${cloudlets[0]}
#   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
#   Length Should Be   ${show_return}  1
#
#   @{cloudlets2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
#   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
#   Length Should Be   ${show_return2}  2

   # change the pool
   #Delete Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  org_name=${orgname}
   #Delete Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  org_name=${orgname2}
   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  org_name=${orgname2}
   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  org_name=${orgname}

   Delete Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  use_defaults=False
   Delete Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  use_defaults=False
   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev2}  use_defaults=False
   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev2}  decision=accept  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev2}

#   ${inlist0}=  Is Cloudlet In List  ${public_cloudlet_list}  automationAzureCentralCloudlet  azure
   ${cloudlet_length2}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist0}'=='${True}'   Evaluate  ${org_cloudlets1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${org_cloudlets1}  # pool cloudlet is already private

#   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length2}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length2}  # pool cloudlet is already private

#   ${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length1}=  Run Keyword If  '${inlist2}'=='${True}'   Set Variable  ${cloudlet_length1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist2}'=='${True}'   Evaluate  ${cloudlet_length2}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length2}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${cloudlet_length2}
   Length Should Be   ${show_return2}  ${cloudlet_length1}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return_new2}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return_new}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return_new}  tmocloud-2  tmus

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return_new}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return_new2}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return_new2}  tmocloud-2  tmus

   #@{cloudletsnew1}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
   #Cloudlets Should Be In List  ${cloudletsnew1}  ${show_return_new}
   #Length Should Be   ${show_return_new}  2
#
#   @{cloudletsnew2}=  Create List  ${cloudlets[0]}
#   Cloudlets Should Be In List  ${cloudletsnew2}  ${show_return_new2}
#   Length Should Be   ${show_return_new2}  1

# ECQ-1715
# removing since we can no longer add cloudletst that have apps/clusters
#ShowOrgCloudlet - orgs shall be removed from all org pools
#   [Documentation]
#   ...  - create 2 pools and assign all cloudlets to the pools 
#   ...  - send orgcloudletpool create for 2 orgs
#   ...  - send ShowOrgCloudlet for each org and verify the cloudlets
#   ...  - delete the orgcloudletpools
#   ...  - send ShowOrgCloudlet for each org
#   ...  - verify empty list are returned for each org since all the cloudlets are still in a pool
#
#   [Tags]  CloudletPoolAccess
#
#   # create a cloudlet pool for every org
#   &{org_dict}=  Create Dictionary
#   FOR  ${cloudlet}  IN  @{cloudlets}
#      Set To Dictionary  ${org_dict}  ${cloudlet['operator']}  found
#   END
#   FOR  ${c}  IN  @{org_dict.keys()}
#      Run Keyword If  '${c}' != 'tmus'  Adduser Role  token=${super_token}  orgname=${c}  username=${op_manager_user_automation}  role=OperatorManager
#      Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${c}  operator_org_name=${c}
#   END
#
#   # add members to the pool
#   FOR  ${cloudlet}  IN  @{cloudlets}
#      Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${cloudlet['operator']}  operator_org_name=${cloudlet['operator']}  cloudlet_name=${cloudlet['cloudlet']}
#   END
#
#   ${show_return}=   Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev}
#   Length Should Be  ${show_return}  0
#
#   # add to org cloudlet pool
#   FOR  ${c}  IN  @{org_dict.keys()}
#   #   Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  org_name=${orgname}
#      Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  use_defaults=False
#      Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  decision=accept  auto_delete=False
#   END
#
#   #Create Cloudlet Pool         region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}
#   #Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
#
#   #Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
#
##      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
##      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}
##      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet3['operator']}  cloudlet_name=${cloudlet3['cloudlet']}
##      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet4['operator']}  cloudlet_name=${cloudlet4['cloudlet']}
#
#   #${len}=  Get Length  ${cloudlets}
#   #FOR  ${cloud}  IN RANGE  1  ${len} 
#   #   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[${cloud}]['operator']}  cloudlet_name=${cloudlets[${cloud}]['cloudlet']}
#   #END
#
#   #Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
#   #Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}
#
#   ${show_return}=   Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev}
#   #${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}
#
#   ${len_cloudlets}=  Get Length  ${cloudlets}
#
#   Cloudlets Should Be In List  ${cloudlets}  ${show_return}
#   Length Should Be   ${show_return}  ${len_cloudlets}
#
#   #${cloudlets1}=  Remove from List  ${cloudlets}  0
#   #@{cloudlets1}=  Create List  ${cloudlets1}
#   #Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
#   #Length Should Be   ${show_return}  1
#
#   ##@{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
#   #Cloudlets Should Be In List  ${cloudlets}  ${show_return2}
#   #${len_cloudlets}=  Get Length  ${cloudlets}
#   #Length Should Be   ${show_return2}  ${len_cloudlets} 
#
#   # delete all the org pools
#   FOR  ${c}  IN  @{org_dict.keys()}
#      #Delete Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  org_name=${orgname}
#      Delete Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  use_defaults=False
#   END
#   #Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
#   #Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}
#
#   ${show_return_new}=   Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev}
#   #${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}
#
#   # no cloudlets are returned since they are still in the pools even though org is removed from pool
#   Length Should Be   ${show_return_new}  0
#   #Length Should Be   ${show_return_new2}  0

# ECQ-1716
ShowOrgCloudlet - members shall be removed from cloudlet pools
   [Documentation]
   ...  - create 2 pools and assign all cloudlets to the pools
   ...  - send orgcloudletpool create for 2 orgs
   ...  - send ShowOrgCloudlet for each org and verify the cloudlets
   ...  - delete some of the members
   ...  - send ShowOrgCloudlet for each org
   ...  - verify proper cloudlets are returned

   [Tags]  CloudletPoolAccess

   Adduser Role  token=${super_token}  orgname=azure  username=${op_manager_user_automation}  role=OperatorManager
   #Adduser Role  token=${super_token}  orgname=tmus  username=${epochusernameop}  role=OperatorManager

   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure
   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure  cloudlet_name=automationAzureCentralCloudlet  auto_delete=${False}
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}
   Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=tmocloud-2  auto_delete=${False}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False
   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  decision=accept  use_defaults=False

   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  org_name=${orgname}
   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}

   ${org_cloudlets1}=  Set Variable  ${num_public_cloudlets}
   ${org_cloudlets2}=  Set Variable  ${num_public_cloudlets}

   ${inlist0}=  Is Cloudlet In List  ${public_cloudlet_list}  automationAzureCentralCloudlet  azure
   ${cloudlet_length1}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist0}'=='${True}'   Evaluate  ${org_cloudlets2}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${org_cloudlets2}  # pool cloudlet is already private

   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   ${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${cloudlet_length1}
   Length Should Be   ${show_return2}  ${cloudlet_length2}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return2}  tmocloud-2  tmus

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return2}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  tmocloud-2  tmus

#   @{cloudlets1}=  Create List  ${cloudlets[0]}
#   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
#   Length Should Be   ${show_return}  1
#
#   @{cloudlets2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
#   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
#   Length Should Be   ${show_return2}  2

   # delete the pool members 
   Remove Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure  cloudlet_name=automationAzureCentralCloudlet
   Remove Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=tmocloud-2

   #${public_cloudlets2}=  Get Public Cloudlets

   ${show_return_new}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
   ${show_return_new2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}

   ${l1}=  Get Length  ${show_return_new}
   ${l2}=  Get Length  ${show_return_new2}

   # no cloudlets are returned since the pool is now empty
   #Length Should Be   ${show_return_new}  0
   #${inlist0}=  Is Cloudlet In List  ${public_cloudlet_list}  automationAzureCentralCloudlet  azure
   ${cloudlet_length1}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${cloudlet_length1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length1}-1  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist0}'=='${True}'   Evaluate  ${cloudlet_length2}+1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length2}  # pool cloudlet is already private

   #${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist2}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  ${cloudlet_length2}-1  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist2}'=='${True}'   Evaluate  ${cloudlet_length1}+1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   Should Be True   len(${show_return_new}) == ${cloudlet_length1}
   Should Be True   len(${show_return_new2}) == ${cloudlet_length2}

   #Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return_new2}  tmocloud-2  tmus 
  
#   # 1 cloudlet should be returned
#   @{cloudlets_new2}=  Create List  ${cloudlets[1]}
#   Cloudlets Should Be In List  ${cloudlets_new2}  ${show_return_new2}
#   Length Should Be   ${show_return_new2}  1

# ECQ-1717
# removing since we can no longer add cloudletst that have apps/clusters
#ShowOrgCloudlet - shall be to show after deleting all pools
#   [Documentation]
#   ...  - create 2 pools and assign all cloudlets to the pools
#   ...  - send orgcloudletpool create for 2 orgs
#   ...  - send ShowOrgCloudlet for each org and verify the cloudlets
#   ...  - delete orgs and pools 
#   ...  - send ShowOrgCloudlet for each org
#   ...  - verify proper cloudlets are returned
#
#   [Tags]  CloudletPoolAccess
#
#   # create a cloudlet pool for every org
#   &{org_dict}=  Create Dictionary
#   FOR  ${cloudlet}  IN  @{cloudlets}
#      Set To Dictionary  ${org_dict}  ${cloudlet['operator']}  found
#   END
#
#   [Teardown]  Cleanup Pools  ${org_dict}
#
#   FOR  ${c}  IN  @{org_dict.keys()}
#      Run Keyword If  '${c}' != 'tmus'  Adduser Role  token=${super_token}  orgname=${c}  username=${op_manager_user_automation}  role=OperatorManager
#      Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${c}  operator_org_name=${c}
#   END
#
#   # add members to the pool
#   FOR  ${cloudlet}  IN  @{cloudlets}
#      Add Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${cloudlet['operator']}  operator_org_name=${cloudlet['operator']}  cloudlet_name=${cloudlet['cloudlet']}  auto_delete=${False}
#   END
#
#   # add to org cloudlet pool
#   FOR  ${c}  IN  @{org_dict.keys()}
#      Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  auto_delete=False
#      Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  decision=accept  auto_delete=False
#      #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  org_name=${orgname}  auto_delete=${False}
#   END
#
##   Create Cloudlet Pool         region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  auto_delete=${False}  auto_delete=${False}
##   Create Cloudlet Pool         region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  auto_delete=${False}  auto_delete=${False}
##
##   Create Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}  auto_delete=${False}
##
##   ${len}=  Get Length  ${cloudlets}
##   FOR  ${cloud}  IN RANGE  1  ${len}
##      Create Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[${cloud}]['operator']}  cloudlet_name=${cloudlets[${cloud}]['cloudlet']}  auto_delete=${False}
##   END
#
##   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}  auto_delete=${False}  auto_delete=${False}
##   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}  auto_delete=${False}  auto_delete=${False}
##   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}  auto_delete=${False}  auto_delete=${False}
##   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet3['operator']}  cloudlet_name=${cloudlet3['cloudlet']}  auto_delete=${False}  auto_delete=${False}
##   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet4['operator']}  cloudlet_name=${cloudlet4['cloudlet']}  auto_delete=${False}  auto_delete=${False}
#
##   Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}  auto_delete=${False}
##   Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}  auto_delete=${False}
#
#   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
#   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}
#
#   ${len_cloudlets}=  Get Length  ${cloudlets}
#   Length Should Be   ${show_return}  ${len_cloudlets}
#   Length Should Be   ${show_return2}  0 
#
##   log to console  COPY1 ${cloudlets} 
##   ${cloudlets_copy}=  Copy List  ${cloudlets}  deepcopy=True
##   ${cloudlets1}=  Remove from List  ${cloudlets_copy}  0
##   log to console  COPY2 ${cloudlets} 
##   @{cloudlets1}=  Create List  ${cloudlets1}
##   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
##   Length Should Be   ${show_return}  1
##
##   #@{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
##   Cloudlets Should Be In List  ${cloudlets_copy}  ${show_return2}
##   ${len_copy}=  Get Length  ${cloudlets_copy}
##   Length Should Be   ${show_return2}  ${len_copy}
#
#   FOR  ${c}  IN  @{org_dict.keys()}
#      Delete Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  use_defaults=False
#      Delete Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev}  use_defaults=False
#      #Delete Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  org_name=${orgname} 
#   END
#   FOR  ${cloudlet}  IN  @{cloudlets}
#      Remove Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${cloudlet['operator']}  operator_org_name=${cloudlet['operator']}  cloudlet_name=${cloudlet['cloudlet']} 
#   END
#
##   Delete Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
##   Delete Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}
##
##   # delete the pool members
##   Delete Cloudlet Pool         region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}
##   Delete Cloudlet Pool         region=${region}  token=${super_token}  cloudlet_pool_name=${poolname2}
#
#   ${show_return_new}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}
#   ${show_return_new2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}
#
#   # no cloudlets are returned since they are still in the pools even though org is removed from pool
#   #@{cloudlets_new1}=  Create List  ${cloudlet0}  ${cloudlet1}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
#   Cloudlets Should Be In List  ${cloudlets}  ${show_return_new}
#   Length Should Be   ${show_return_new}  ${num_public_cloudlets}
#
#   #@{cloudlets_new2}=  Create List  ${cloudlet0}  ${cloudlet1}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
#   Cloudlets Should Be In List  ${cloudlets}  ${show_return_new2}
#   Length Should Be   ${show_return_new2}  ${num_public_cloudlets}

# ECQ-1718
ShowOrgCloudlet - shall be to add members after orgpoolcreate
   [Documentation]
   ...  - create 2 pools with no members
   ...  - send orgcloudletpool create for 2 orgs
   ...  - send ShowOrgCloudlet for each org and verify list is empty
   ...  - add members
   ...  - send ShowOrgCloudlet for each org
   ...  - verify proper cloudlets are returned

   [Tags]  CloudletPoolAccess

   Adduser Role  token=${super_token}  orgname=azure  username=${op_manager_user_automation}  role=OperatorManager
   #Adduser Role  token=${super_token}  orgname=tmus  username=${epochusernameop}  role=OperatorManager

   Create Cloudlet Pool         region=US  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure  #auto_delete=${False} 
   Create Cloudlet Pool         region=US  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  #auto_delete=${False}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False
   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev2}  decision=accept  use_defaults=False

   #Create Org Cloudlet Pool     region=US  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=azure  org_name=${orgname}
   #Create Org Cloudlet Pool     region=US  token=${op_token}  cloudlet_pool_name=${poolname2}  cloudlet_pool_org_name=tmus  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev2}

   # list is empty since both orgs are added to a pool without members
   Length Should Be   ${show_return}  ${num_public_cloudlets} 
   Length Should Be   ${show_return2}   ${num_public_cloudlets}

   # add members
   Add Cloudlet Pool Member  region=US  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=azure  cloudlet_name=automationAzureCentralCloudlet
   Add Cloudlet Pool Member  region=US  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=${cloudlet_name1}
   Add Cloudlet Pool Member  region=US  token=${op_token}  cloudlet_pool_name=${poolname2}  operator_org_name=tmus  cloudlet_name=tmocloud-2

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${dev_token}  org_name=${orgnamedev2}

   ${org_cloudlets1}=  Set Variable  ${num_public_cloudlets}
   ${org_cloudlets2}=  Set Variable  ${num_public_cloudlets}

   ${inlist0}=  Is Cloudlet In List  ${public_cloudlet_list}  automationAzureCentralCloudlet  azure
   ${cloudlet_length1}=  Run Keyword If  '${inlist0}'=='${True}'   Set Variable  ${org_cloudlets1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets1}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist0}'=='${True}'   Evaluate  ${org_cloudlets2}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${org_cloudlets2}  # pool cloudlet is already private

   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   ${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length2}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length2}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${cloudlet_length1}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${cloudlet_length1}  # pool cloudlet is already private

   Length Should Be   ${show_return_new}  ${cloudlet_length1}
   Length Should Be   ${show_return_new2}  ${cloudlet_length2}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return_new}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return_new2}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return_new2}  tmocloud-2  tmus

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return_new2}   automationAzureCentralCloudlet  azure
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return_new}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return_new}  tmocloud-2  tmus

#   @{cloudlets_new1}=  Create List  ${cloudlets[0]}
#   Cloudlets Should Be In List  ${cloudlets_new1}  ${show_return_new}
#   Length Should Be   ${show_return_new}  1
#
#   @{cloudlets_new2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
#   Cloudlets Should Be In List  ${cloudlets_new2}  ${show_return_new2}
#   Length Should Be   ${show_return_new2}  2

# ECQ-1719
ShowOrgCloudlet - shall be to add user to existing orgpool 
   [Documentation]
   ...  - create pools with members
   ...  - send orgcloudletpool create
   ...  - create new user and assign to org 
   ...  - send ShowOrgCloudlet for each user 
   ...  - verify proper cloudlets are returned

   [Tags]  CloudletPoolAccess

   #Adduser Role  token=${super_token}  orgname=tmus  username=${epochusernameop}  role=OperatorManager

   @{cloudlet_list}=  Create List  ${cloudlet_name1}  tmocloud-2
   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=tmus  cloudlet_list=${cloudlet_list}  #auto_delete=${False}

   #Create Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}
   #Create Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False

   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=tmus  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}

   # create new user
   ${user_new}=  Catenate  SEPARATOR=  ${epochusernamedev}  new
   ${email_new}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  3  @gmail.com

   Skip Verify Email
   Create User  username=${user_new}   password=${password}   email_address=${email_new}
   #Verify Email  email_address=${email_new}
   Unlock User
   ${user_token_new}=  Login  username=${user_new}  password=${password}

   # add new user to org
   Adduser Role  token=${dev_token}  orgname=${orgnamedev}  username=${user_new}  role=DeveloperViewer

   # show org cloudlet for new user
   ${show_return_new}=  Show Org Cloudlet  region=${region}  token=${user_token_new}  org_name=${orgnamedev}

   ${org_cloudlets1}=  Set Variable  ${num_public_cloudlets}

   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlet_name1}  tmus
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${org_cloudlets1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${org_cloudlets1}  # pool cloudlet is not already public so add it to the public list

   ${inlist2}=  Is Cloudlet In List  ${public_cloudlet_list}  tmocloud-2  tmus
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${cloudlet_length1}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${cloudlet_length1}  # pool cloudlet is not already public so add it to the public list

   Length Should Be   ${show_return_new}  ${cloudlet_length1}

   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return_new}  ${cloudlet_name1}  tmus
   Pool Cloudlet Should Be In Show Org Cloudlet  ${show_return_new}  tmocloud-2  tmus


#   @{cloudlets_new1}=  Create List  ${cloudlets[1]}  ${cloudlets[2]} 
#   Cloudlets Should Be In List  ${cloudlets_new1}  ${show_return}
#   Length Should Be   ${show_return}  2
#
#   @{cloudlets_new2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
#   Cloudlets Should Be In List  ${cloudlets_new2}  ${show_return_new}
#   Length Should Be   ${show_return_new}  2

# ECQ-3356
ShowOrgCloudlet - org shall not show if invite rejected
   [Documentation]
   ...  - reject invitation for the cloudlet for org1
   ...  - send ShowOrgCloudlet for org1 and verify it returns the other cloudlet
   ...  - send ShowOrgCloudlet for org2 and verify it returns the other cloudlets

   [Tags]  CloudletPoolAccess

   @{cloudlet_list}  Create List  ${cloudlets[1]['cloudlet']}

   Run Keyword If  '${cloudlets[1]['operator']}' != 'tmus'  Adduser Role  token=${super_token}  orgname=${cloudlets[1]['operator']}  username=${op_manager_user_automation}  role=OperatorManager

   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}   #operator_org_name=${operator}
   Update Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_list=${cloudlet_list}
   #Add Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  developer_org_name=${orgnamedev}  decision=reject  use_defaults=False

   #Create Org Cloudlet Pool     region=${region}  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  org_name=${orgname}     #cloudlet_pool_org_name=${operator}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}  #org_name=${cloudlets[1]['operator']}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}  #org_name=${cloudlets[2]['operator']}

   ${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlets[1]['cloudlet']}  ${cloudlets[1]['operator']}
   ${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${num_public_cloudlets}  # pool cloudlet is already public
   ...  ELSE  Evaluate  1+${num_public_cloudlets}  # pool cloudlet is not already public so add it to the public list
   ${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${num_public_cloudlets}-1  # pool cloudlet is already public so remove it from public list
   ...  ELSE  Set Variable  ${num_public_cloudlets}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${cloudlet_length1-1}
   Length Should Be   ${show_return2}  ${cloudlet_length2}

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return}  ${cloudlets[1]['cloudlet']}  ${cloudlets[1]['operator']}

   Pool Cloudlet Should Not Be In Show Org Cloudlet  ${show_return2}  ${cloudlets[1]['cloudlet']}  ${cloudlets[1]['operator']}

   #Should Be Equal  ${show_return[0]['key']['name']}  ${cloudlets[1]['cloudlet']}
   #Should Be Equal  ${show_return[0]['key']['organization']}  ${cloudlets[1]['operator']}

   #Cloudlets Should Be In List  ${public_cloudlet_list}  ${show_return}

   #Cloudlets Should Be In List  ${public_cloudlet_list}  ${show_return2}

   #${cloudlets2}=  Remove from List  ${cloudlets}  1
   #${len}=  Get Length  ${cloudlets}
   ##@{cloudlets2}=  Create List  ${cloudlet0}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
   #Cloudlets Should Be In List  ${cloudlets}  ${show_return2}
   #Length Should Be   ${show_return2}  ${len}

# ECQ-3357
ShowOrgCloudlet - org shall be assigned to an empty pool
   [Documentation]
   ...  - create an empty pool
   ...  - send ShowOrgCloudlet for org1 and verify it returns all public cloudlets
   ...  - send ShowOrgCloudlet for org2 and verify it returns all public cloudlets

   [Tags]  CloudletPoolAccess

   @{cloudlet_list}  Create List  ${cloudlets[1]['cloudlet']}

   Run Keyword If  '${cloudlets[1]['operator']}' != 'tmus'  Adduser Role  token=${super_token}  orgname=${cloudlets[1]['operator']}  username=${op_manager_user_automation}  role=OperatorManager

   Create Cloudlet Pool         region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}   #operator_org_name=${operator}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  developer_org_name=${orgnamedev}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  developer_org_name=${orgnamedev}  decision=accept  use_defaults=False

   ${show_return}=   Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev}  #org_name=${cloudlets[1]['operator']}
   ${show_return2}=  Show Org Cloudlet  region=${region}  token=${dev_token}  org_name=${orgnamedev2}  #org_name=${cloudlets[2]['operator']}

   #${inlist}=  Is Cloudlet In List  ${public_cloudlet_list}  ${cloudlets[1]['cloudlet']}  ${cloudlets[1]['operator']}
   #${cloudlet_length1}=  Run Keyword If  '${inlist}'=='${True}'   Set Variable  ${num_public_cloudlets}  # pool cloudlet is already public
   #...  ELSE  Evaluate  1+${num_public_cloudlets}  # pool cloudlet is not already public so add it to the public list
   #${cloudlet_length2}=  Run Keyword If  '${inlist}'=='${True}'   Evaluate  ${num_public_cloudlets}-1  # pool cloudlet is already public so remove it from public list
   #...  ELSE  Set Variable  ${num_public_cloudlets}  # pool cloudlet is already private

   Length Should Be   ${show_return}  ${num_public_cloudlets}
   Length Should Be   ${show_return2}  ${num_public_cloudlets}

*** Keywords ***
Pool Cloudlet Should Be In Show Org Cloudlet
   [Arguments]  ${show_list}  ${cloudlet}  ${org}

   ${inlist}=  Set Variable  ${False}
   FOR  ${pool_cloudlet}  IN  @{show_list}
      ${inlist}=  Run Keyword IF  '${pool_cloudlet['key']['name']}'=='${cloudlet}' and '${pool_cloudlet['key']['organization']}'=='${org}'  Set Variable  ${True}
      ...  ELSE  Set Variable  ${inlist}
   END

   Should Be True  ${inlist}==${True}

Pool Cloudlet Should Not Be In Show Org Cloudlet
   [Arguments]  ${show_list}  ${cloudlet}  ${org}

   Run Keyword and Expect Error  *  Pool Cloudlet Should Be In Show Org Cloudlet  ${show_list}  ${cloudlet}  ${org}

Cloudlets Should Be In List
   [Arguments]  ${cloudlet_list}  ${show_list}
   FOR  ${pool_cloudlet}  IN  @{show_list}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['organization']}
      List Should Contain Value   ${cloudlet_list}  ${cloudlet_key}
   END

Is Cloudlet in List
   [Arguments]  ${cloudlet_list}  ${cloudlet}  ${org}
   ${inlist}=  Set Variable  ${False}
   &{cloudlet_key}=  Create Dictionary  cloudlet=${cloudlet}  operator=${org}
   #${status}=  List Should Contain Value   ${cloudlet_list}  ${cloudlet_key}
   ${inlist}=  Run Keyword IF  ${cloudlet_key} in ${cloudlet_list}  Set Variable  ${True}
   [Return]  ${inlist}

Setup
   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusernameop}=  Catenate  SEPARATOR=  ${username}op  ${epoch}  op
   ${epochusernamedev}=  Catenate  SEPARATOR=  ${username}dev  ${epoch}  dev

   ${super_token}=  Get Super Token

   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=tmus  token=${super_token}
   ${cloudlet_name1}=  Set Variable  ${cloudlet1['data']['key']['name']}

   ${poolname1}=  Get Default Cloudlet Pool Name
   ${poolname2}=  Catenate  SEPARATOR=  ${poolname1}  2

   ${public_cloudlets}=  Get Public Cloudlets  region=US
   ${num_public_cloudlets}=  Get Length  ${public_cloudlets}

   @{public_cloudlet_list}=  Create List
   FOR  ${cloud}  IN  @{public_cloudlets}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${cloud['data']['key']['name']}  operator=${cloud['data']['key']['organization']}
      Append To List  ${public_cloudlet_list}  ${cloudlet_key}
   END
   
   @{cloudlets}=  Create List
   ${cloudlet_list}=  Show Cloudlets  region=US  token=${super_token}  use_defaults=${False}
   FOR  ${cloud}  IN  @{cloudlet_list}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${cloud['data']['key']['name']}  operator=${cloud['data']['key']['organization']}
      #Run Keyword If  '${cloud['data']['key']['organization']}' == '${operator}'  Append To List  ${cloudlets}  ${cloudlet_key}
      Append To List  ${cloudlets}  ${cloudlet_key}
   END
   
#   Skip Verify Email
#   Create User  username=${epochusernameop}   password=${op_manager_password_automation}   email_address=${emailepoch}
#   Unlock User
#   ${op_token}=  Login  username=${epochusernameop}   password=${op_manager_password_automation}
#
#   Create User  username=${epochusernamedev}   password=${dev_manager_password_automation}   email_address=${emailepoch2}
#   Unlock User
#   ${dev_token}=  Login  username=${epochusernamedev}   password=${dev_manager_password_automation}
#
#   Verify Email Via mc  token=${op_token}
#   Verify Email Via mc  token=${dev_token}

   ${op_token}=  Login  username=${op_manager_user_automation}   password=${op_manager_password_automation}
   ${dev_token}=  Login  username=${dev_manager_user_automation}   password=${dev_manager_password_automation}

#  dddddd
#   Create User  username=${epochusernameop}   password=${password}   email_address=${emailepoch}
#   #Verify Email  email_address=${emailepoch}
#   Unlock User 
#   Create User  username=${epochusernamedev}   password=${password}   email_address=${emailepoch2}
#   Unlock User

#   ${op_token}=   Login  username=${op_manager_user_automation}   password=${op_manager_password_automation}
#   ${dev_token}=  Login  username=${dev_manager_user_automation}   password=${dev_manager_password_automation}

   #${orgnameop}=  Create Org  token=${super_token}  orgtype=operator
   ${orgnamedev}=  Create Org  token=${dev_token}  orgtype=developer

   ${orgname2}=  Catenate  SEPARATOR=  ${orgnamedev}  2
   #Create Org  token=${user_token}  orgname=${orgname2}  orgtype=operator
   ${orgnamedev2}=  Create Org  token=${dev_token}  orgname=${orgname2}  orgtype=developer

#   Adduser Role  token=${super_token}  orgname=${cloudlets[1]['operator']}  username=${epochusernameop}  role=OperatorManager

   Set Suite Variable  ${epoch}
   Set Suite Variable  ${op_token}
   Set Suite Variable  ${dev_token}
   Set Suite Variable  ${emailepoch}
   Set Suite Variable  ${epochusernameop}
   Set Suite Variable  ${epochusernamedev}
   Set Suite Variable  ${super_token}
   Set Suite Variable  ${orgnamedev}
   Set Suite Variable  ${orgnamedev2}
   Set Suite Variable  ${poolname1}
   Set Suite Variable  ${poolname2}
   Set Suite Variable  ${cloudlets}
   Set Suite Variable  ${public_cloudlets}
   Set Suite Variable  ${num_public_cloudlets}
   Set Suite Variable  ${public_cloudlet_list}
   Set Suite Variable  ${cloudlet_name1}

Cleanup Pools
   [Arguments]  ${org_dict}

   FOR  ${cloudlet}  IN  @{cloudlets}
      Run Keyword and Ignore Error  Remove Cloudlet Pool Member  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${cloudlet['operator']}  operator_org_name=${cloudlet['operator']}  cloudlet_name=${cloudlet['cloudlet']} 
   END

   FOR  ${c}  IN  @{org_dict.keys()}
      Run Keyword and Ignore Error  Delete Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev} 
      Run Keyword and Ignore Error  Delete Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${poolname2}${c}  cloudlet_pool_org_name=${c}  developer_org_name=${orgnamedev} 
   END

   Cleanup Provisioning
