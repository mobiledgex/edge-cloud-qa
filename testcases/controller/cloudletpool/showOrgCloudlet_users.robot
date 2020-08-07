*** Settings ***
Documentation  ShowOrgCloudlet for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator}=  dmuus
${operator0}=  att
#&{cloudlet0}=  cloudlet=attcloud-1  operator=att
#&{cloudlet1}=  cloudlet=tmocloud-1  operator=dmuus
#&{cloudlet2}=  cloudlet=tmocloud-2  operator=dmuus
#&{cloudlet3}=  cloudlet=automationGcpCentralCloudlet  operator=gcp
#&{cloudlet4}=  cloudlet=automationAzureCentralCloudlet  operator=azure

#@{cloudlets}=  &{cloudlet0}  &{cloudlet1}  &{cloudlet2}  &{cloudlet3}  &{cloudlet4}

${username}=  mextester06
${password}=  mextester06123

*** Test Cases ***
ShowOrgCloudlet - org shall be assigned to 1 cloudlet 
   [Documentation]
   ...  assign 1 cloudlet to the pool for org1 
   ...  send ShowOrgCloudlet for org1 and verify it returns the 1 cloudlet
   ...  send ShowOrgCloudlet for org2 and verify it returns the other cloudlets 

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}   #operator_org_name=${operator}
   Add Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  cloudlet_pool_org_name=${cloudlets[1]['operator']}  org_name=${orgname}     #cloudlet_pool_org_name=${operator}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

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

ShowOrgCloudlet - org shall be assigned to 2 cloudlets
   [Documentation]
   ...  assign 2 cloudlet to the pool for org1
   ...  send ShowOrgCloudlet for org1 and verify it returns the 2 cloudlets
   ...  send ShowOrgCloudlet for org2 and verify it returns the other cloudlets

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   #${cloudlet_copy}=  Copy List  ${cloudlets}  deepcopy=${True}
   @{cloudlets1}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  2

   Remove Values from List  ${cloudlets}  ${cloudlets[1]}  ${cloudlets[2]}
   ${len}=  Get Length  ${cloudlets}
   #@{cloudlets2}=  Create List  ${cloudlet0}  ${cloudlet3}  ${cloudlet4}
   Cloudlets Should Be In List  ${cloudlets}  ${show_return2}
   Length Should Be   ${show_return2}  ${len}  

ShowOrgCloudlet - org shall be assigned to all cloudlets
   [Documentation]
   ...  assign all cloudlet to the pool for org1
   ...  send ShowOrgCloudlet for org1 and verify it returns all the cloudlets
   ...  send ShowOrgCloudlet for org2 and verify it returns no cloudlets

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}

   FOR  ${cloudlet}  IN  @{cloudlets}
      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet['operator']}  cloudlet_name=${cloudlet['cloudlet']}
   END

   #Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   #Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
   #Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}
   #Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet3['operator']}  cloudlet_name=${cloudlet3['cloudlet']}
   #Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet4['operator']}  cloudlet_name=${cloudlet4['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   ${len_cloudlets}=  Get Length  ${cloudlets}

   Cloudlets Should Be In List  ${cloudlets}  ${show_return}
   Length Should Be   ${show_return}  ${len_cloudlets}

   Length Should Be   ${show_return2}  0

ShowOrgCloudlet - orgs shall be assigned to different cloudlets
   [Documentation]
   ...  assign different cloudlets to 2 different orgs 
   ...  send ShowOrgCloudlet for each org and verify the cloudlets 

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlets[0]}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

ShowOrgCloudlet - orgs shall be assigned the same cloudlet
   [Documentation]
   ...  assign same cloudlet to 2 different orgs
   ...  send ShowOrgCloudlet for each org and verify the cloudlets

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlets[0]}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlets[0]}  ${cloudlets[2]}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

ShowOrgCloudlet - orgs shall be assigned the same pool 
   [Documentation]
   ...  assign 2 orgs to same orgcloudletpool
   ...  send ShowOrgCloudlet for each org and verify the cloudlets

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}

   #Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}

   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlets[0]}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlets[0]} 
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  1

ShowOrgCloudlet - orgs shall be changed to different pools
   [Documentation]
   ...  assign 2 orgs to 2 different orgcloudletpools 
   ...  send ShowOrgCloudlet for each org and verify the cloudlets
   ...  send orgcloudletpool delete and re-create by swithing the orgs
   ...  send ShowOrgCloudlet for each org and verify the cloudlets have switched orgs

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlets[0]}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

   # change the pool
   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname2}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudletsnew1}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
   Cloudlets Should Be In List  ${cloudletsnew1}  ${show_return_new}
   Length Should Be   ${show_return_new}  2

   @{cloudletsnew2}=  Create List  ${cloudlets[0]}
   Cloudlets Should Be In List  ${cloudletsnew2}  ${show_return_new2}
   Length Should Be   ${show_return_new2}  1

ShowOrgCloudlet - orgs shall be removed from all org pools
   [Documentation]
   ...  create 2 pools and assign all cloudlets to the pools 
   ...  send orgcloudletpool create for 2 orgs
   ...  send ShowOrgCloudlet for each org and verify the cloudlets
   ...  delete the orgcloudletpools
   ...  send ShowOrgCloudlet for each org
   ...  verify empty list are returned for each org since all the cloudlets are still in a pool

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}

   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}

#      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
#      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}
#      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet3['operator']}  cloudlet_name=${cloudlet3['cloudlet']}
#      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet4['operator']}  cloudlet_name=${cloudlet4['cloudlet']}

   ${len}=  Get Length  ${cloudlets}
   FOR  ${cloud}  IN RANGE  1  ${len} 
      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[${cloud}]['operator']}  cloudlet_name=${cloudlets[${cloud}]['cloudlet']}
   END

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   ${cloudlets1}=  Remove from List  ${cloudlets}  0
   @{cloudlets1}=  Create List  ${cloudlets1}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   #@{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
   Cloudlets Should Be In List  ${cloudlets}  ${show_return2}
   ${len_cloudlets}=  Get Length  ${cloudlets}
   Length Should Be   ${show_return2}  ${len_cloudlets} 

   # delete all the org pools
   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   # no cloudlets are returned since they are still in the pools even though org is removed from pool
   Length Should Be   ${show_return_new}  0
   Length Should Be   ${show_return_new2}  0

ShowOrgCloudlet - members shall be removed from cloudlet pools
   [Documentation]
   ...  create 2 pools and assign all cloudlets to the pools
   ...  send orgcloudletpool create for 2 orgs
   ...  send ShowOrgCloudlet for each org and verify the cloudlets
   ...  delete some of the members
   ...  send ShowOrgCloudlet for each org
   ...  verify proper cloudlets are returned

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}  auto_delete=${False}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}  auto_delete=${False}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlets[0]}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

   # delete the pool members 
   Delete Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
   Delete Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   # no cloudlets are returned since the pool is now empty
   Length Should Be   ${show_return_new}  0

   # 1 cloudlet should be returned
   @{cloudlets_new2}=  Create List  ${cloudlets[1]}
   Cloudlets Should Be In List  ${cloudlets_new2}  ${show_return_new2}
   Length Should Be   ${show_return_new2}  1

ShowOrgCloudlet - shall be to show after deleting all pools
   [Documentation]
   ...  create 2 pools and assign all cloudlets to the pools
   ...  send orgcloudletpool create for 2 orgs
   ...  send ShowOrgCloudlet for each org and verify the cloudlets
   ...  delete orgs and pools 
   ...  send ShowOrgCloudlet for each org
   ...  verify proper cloudlets are returned

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  auto_delete=${False}  auto_delete=${False}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  auto_delete=${False}  auto_delete=${False}

   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}  auto_delete=${False}

   ${len}=  Get Length  ${cloudlets}
   FOR  ${cloud}  IN RANGE  1  ${len}
      Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[${cloud}]['operator']}  cloudlet_name=${cloudlets[${cloud}]['cloudlet']}  auto_delete=${False}
   END

#   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}  auto_delete=${False}  auto_delete=${False}
#   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}  auto_delete=${False}  auto_delete=${False}
#   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}  auto_delete=${False}  auto_delete=${False}
#   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet3['operator']}  cloudlet_name=${cloudlet3['cloudlet']}  auto_delete=${False}  auto_delete=${False}
#   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlet4['operator']}  cloudlet_name=${cloudlet4['cloudlet']}  auto_delete=${False}  auto_delete=${False}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}  auto_delete=${False}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}  auto_delete=${False}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   log to console  COPY1 ${cloudlets} 
   ${cloudlets_copy}=  Copy List  ${cloudlets}  deepcopy=True
   ${cloudlets1}=  Remove from List  ${cloudlets_copy}  0
   log to console  COPY2 ${cloudlets} 
   @{cloudlets1}=  Create List  ${cloudlets1}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   #@{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
   Cloudlets Should Be In List  ${cloudlets_copy}  ${show_return2}
   ${len_copy}=  Get Length  ${cloudlets_copy}
   Length Should Be   ${show_return2}  ${len_copy}

   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   # delete the pool members
   Delete Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Delete Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   # no cloudlets are returned since they are still in the pools even though org is removed from pool
   #@{cloudlets_new1}=  Create List  ${cloudlet0}  ${cloudlet1}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
   Cloudlets Should Be In List  ${cloudlets}  ${show_return_new}
   Length Should Be   ${show_return_new}  ${len}

   #@{cloudlets_new2}=  Create List  ${cloudlet0}  ${cloudlet1}  ${cloudlet2}  ${cloudlet3}  ${cloudlet4}
   Cloudlets Should Be In List  ${cloudlets}  ${show_return_new2}
   Length Should Be   ${show_return_new2}  ${len}

ShowOrgCloudlet - shall be to add members after orgpoolcreate
   [Documentation]
   ...  create 2 pools with no members
   ...  send orgcloudletpool create for 2 orgs
   ...  send ShowOrgCloudlet for each org and verify list is empty
   ...  add members
   ...  send ShowOrgCloudlet for each org
   ...  verify proper cloudlets are returned

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  #auto_delete=${False} 
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  #auto_delete=${False}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   # list is empty since both orgs are added to a pool without members
   Length Should Be   ${show_return}  0
   Length Should Be   ${show_return2}  0

   # add members
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[0]['operator']}  cloudlet_name=${cloudlets[0]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']} 
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets_new1}=  Create List  ${cloudlets[0]}
   Cloudlets Should Be In List  ${cloudlets_new1}  ${show_return_new}
   Length Should Be   ${show_return_new}  1

   @{cloudlets_new2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
   Cloudlets Should Be In List  ${cloudlets_new2}  ${show_return_new2}
   Length Should Be   ${show_return_new2}  2

ShowOrgCloudlet - shall be to add user to existing orgpool 
   [Documentation]
   ...  create pools with members
   ...  send orgcloudletpool create
   ...  create new user and assign to org 
   ...  send ShowOrgCloudlet for each user 
   ...  verify proper cloudlets are returned

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  #auto_delete=${False}

   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[1]['operator']}  cloudlet_name=${cloudlets[1]['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_org_name=${cloudlets[2]['operator']}  cloudlet_name=${cloudlets[2]['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}

   # create new user
   ${user_new}=  Catenate  SEPARATOR=  ${epochusername}  new
   ${email_new}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com

   Skip Verify Email
   Create User  username=${user_new}   password=${password}   email_address=${email_new}
   #Verify Email  email_address=${email_new}
   Unlock User
   ${user_token_new}=  Login  username=${user_new}  password=${password}

   # add new user to org
   Adduser Role  token=${user_token}  orgname=${orgname}  username=${user_new}  role=OperatorViewer

   # show org cloudlet for new user
   ${show_return_new}=  Show Org Cloudlet  region=US  token=${user_token_new}  org_name=${orgname}

   @{cloudlets_new1}=  Create List  ${cloudlets[1]}  ${cloudlets[2]} 
   Cloudlets Should Be In List  ${cloudlets_new1}  ${show_return}
   Length Should Be   ${show_return}  2

   @{cloudlets_new2}=  Create List  ${cloudlets[1]}  ${cloudlets[2]}
   Cloudlets Should Be In List  ${cloudlets_new2}  ${show_return_new}
   Length Should Be   ${show_return_new}  2

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
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token

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
   
   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   #Verify Email  email_address=${emailepoch}
   Unlock User 
   ${user_token}=  Login  username=${epochusername}  password=${password}

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator
   ${orgname2}=  Catenate  SEPARATOR=  ${orgname}  2
   Create Org  token=${user_token}  orgname=${orgname2}  orgtype=operator

   Set Suite Variable  ${epoch}
   Set Suite Variable  ${user_token}
   Set Suite Variable  ${emailepoch}
   Set Suite Variable  ${epochusername}
   Set Suite Variable  ${super_token}
   Set Suite Variable  ${orgname}
   Set Suite Variable  ${orgname2}
   Set Suite Variable  ${poolname1}
   Set Suite Variable  ${poolname2}
   Set Suite Variable  ${cloudlets}
   Set Suite Variable  ${public_cloudlets}
   Set Suite Variable  ${num_public_cloudlets}
   Set Suite Variable  ${public_cloudlet_list}
