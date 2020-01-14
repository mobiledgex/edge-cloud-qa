*** Settings ***
Documentation  ShowOrgCloudlet for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator}=  tmus
${operator0}=  att
&{cloudlet0}=  cloudlet=attcloud-1  operator=att
&{cloudlet1}=  cloudlet=tmocloud-1  operator=tmus
&{cloudlet2}=  cloudlet=tmocloud-2  operator=tmus
@{cloudlets}=  &{cloudlet0}  &{cloudlet1}  &{cloudlet2}

${username}=  mextester06
${password}=  mextester06123

*** Test Cases ***
ShowOrgCloudlet - org shall be assigned to 1 cloudlet 
   [Documentation]
   ...  assign 1 cloudlet to the pool for org1 
   ...  send ShowOrgCloudlet for org1 and verify it returns the 1 cloudlet
   ...  send ShowOrgCloudlet for org2 and verify it returns the other cloudlets 

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   Should Be Equal  ${show_return[0]['key']['name']}  ${cloudlet1['cloudlet']} 
   Should Be Equal  ${show_return[0]['key']['operator_key']['name']}  ${cloudlet1['operator']}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlet0}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

ShowOrgCloudlet - org shall be assigned to 2 cloudlets
   [Documentation]
   ...  assign 2 cloudlet to the pool for org1
   ...  send ShowOrgCloudlet for org1 and verify it returns the 2 cloudlets
   ...  send ShowOrgCloudlet for org2 and verify it returns the other cloudlets

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  2

   @{cloudlets2}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  1

ShowOrgCloudlet - org shall be assigned to all cloudlets
   [Documentation]
   ...  assign all cloudlet to the pool for org1
   ...  send ShowOrgCloudlet for org1 and verify it returns all the cloudlets
   ...  send ShowOrgCloudlet for org2 and verify it returns no cloudlets

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   Cloudlets Should Be In List  ${cloudlets}  ${show_return}
   Length Should Be   ${show_return}  3

   Length Should Be   ${show_return2}  0

ShowOrgCloudlet - orgs shall be assigned to different cloudlets
   [Documentation]
   ...  assign different cloudlets to 2 different orgs 
   ...  send ShowOrgCloudlet for each org and verify the cloudlets 

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

ShowOrgCloudlet - orgs shall be assigned the same cloudlet
   [Documentation]
   ...  assign same cloudlet to 2 different orgs
   ...  send ShowOrgCloudlet for each org and verify the cloudlets

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlet0}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

ShowOrgCloudlet - orgs shall be assigned the same pool 
   [Documentation]
   ...  assign 2 orgs to same orgcloudletpool
   ...  send ShowOrgCloudlet for each org and verify the cloudlets

   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Create Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlet0} 
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
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

   # change the pool
   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname2}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudletsnew1}=  Create List  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudletsnew1}  ${show_return_new}
   Length Should Be   ${show_return_new}  2

   @{cloudletsnew2}=  Create List  ${cloudlet0}
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
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

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
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}  auto_delete=${False}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}  auto_delete=${False}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

   # delete the pool members 
   Delete Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Delete Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   # no cloudlets are returned since the pool is now empty
   Length Should Be   ${show_return_new}  0

   # 1 cloudlet should be returned
   @{cloudlets_new2}=  Create List  ${cloudlet1}
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
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}  auto_delete=${False}  auto_delete=${False}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}  auto_delete=${False}  auto_delete=${False}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}  auto_delete=${False}  auto_delete=${False}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}  auto_delete=${False}
   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}  auto_delete=${False}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets1}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets1}  ${show_return}
   Length Should Be   ${show_return}  1

   @{cloudlets2}=  Create List  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets2}  ${show_return2}
   Length Should Be   ${show_return2}  2

   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}
   Delete Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  org_name=${orgname2}

   # delete the pool members
   Delete Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname1}
   Delete Cloudlet Pool         region=US  token=${super_token}  cloudlet_pool_name=${poolname2}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   # no cloudlets are returned since they are still in the pools even though org is removed from pool
   @{cloudlets_new1}=  Create List  ${cloudlet0}  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets_new1}  ${show_return_new}
   Length Should Be   ${show_return_new}  3

   @{cloudlets_new2}=  Create List  ${cloudlet0}  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets_new2}  ${show_return_new2}
   Length Should Be   ${show_return_new2}  3

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
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet0['operator']}  cloudlet_name=${cloudlet0['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']} 
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname2}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   ${show_return_new}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}
   ${show_return_new2}=  Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname2}

   @{cloudlets_new1}=  Create List  ${cloudlet0}
   Cloudlets Should Be In List  ${cloudlets_new1}  ${show_return_new}
   Length Should Be   ${show_return_new}  1

   @{cloudlets_new2}=  Create List  ${cloudlet1}  ${cloudlet2}
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

   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet1['operator']}  cloudlet_name=${cloudlet1['cloudlet']}
   Create Cloudlet Pool Member  region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  operator_name=${cloudlet2['operator']}  cloudlet_name=${cloudlet2['cloudlet']}

   Create Org Cloudlet Pool     region=US  token=${super_token}  cloudlet_pool_name=${poolname1}  org_name=${orgname}

   ${show_return}=   Show Org Cloudlet  region=US  token=${user_token}  org_name=${orgname}

   # create new user
   ${user_new}=  Catenate  SEPARATOR=  ${epochusername}  new
   ${email_new}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   Create User  username=${user_new}   password=${password}   email_address=${email_new}
   Verify Email  email_address=${email_new}
   Unlock User
   ${user_token_new}=  Login  username=${user_new}  password=${password}

   # add new user to org
   Adduser Role  token=${user_token}  orgname=${orgname}  username=${user_new}  role=OperatorViewer

   # show org cloudlet for new user
   ${show_return_new}=  Show Org Cloudlet  region=US  token=${user_token_new}  org_name=${orgname}

   @{cloudlets_new1}=  Create List  ${cloudlet1}  ${cloudlet2} 
   Cloudlets Should Be In List  ${cloudlets_new1}  ${show_return}
   Length Should Be   ${show_return}  2

   @{cloudlets_new2}=  Create List  ${cloudlet1}  ${cloudlet2}
   Cloudlets Should Be In List  ${cloudlets_new2}  ${show_return_new}
   Length Should Be   ${show_return_new}  2

*** Keywords ***
Cloudlets Should Be In List
   [Arguments]  ${cloudlet_list}  ${show_list}
   FOR  ${pool_cloudlet}  IN  @{show_list}
      &{cloudlet_key}=  Create Dictionary  cloudlet=${pool_cloudlet['key']['name']}  operator=${pool_cloudlet['key']['operator_key']['name']}
      List Should Contain Value   ${cloudlet_list}  ${cloudlet_key}
   END

Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token

   ${poolname1}=  Get Default Cloudlet Pool Name
   ${poolname2}=  Catenate  SEPARATOR=  ${poolname1}  2

   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Verify Email  email_address=${emailepoch}
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
