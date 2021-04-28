*** Settings ***
Documentation   MasterController Org Delete

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   H31m8@W8maSfg
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw

*** Test Cases ***
# ECQ-2781
MC - Delete an org without an org name	
	[Documentation]
	...  delete an org without an org name
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Delete Org   token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Organization name not specified"}


# ECQ-2782
MC - Delete an org that doesn't exist with admin token	
	[Documentation]
	...  delete an org that doesn't exist with the admin token
	...  verify the correct error message is returned

	Run Keyword and Expect Error  *    Delete Org     orgname=madeuporgnname    token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	
	Should Be Equal              ${body}         {"message":"org madeuporgnname not found"}


# ECQ-2783
MC - Delete an org that doesn't exist with org manager token	
	[Documentation]
	...  delete an org that doesn't exist with the org manager token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Delete Org     orgname=madeuporgnname    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  403	
	Should Be Equal              ${body}         {"message":"Forbidden"}


# ECQ-2784
MC - Delete an org without a token	
	[Documentation]
	...  delete an org without a token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *    Delete Org     orgname=myOrg      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"no bearer token found"}


# ECQ-2785
MC - Delete an org with an empty token	
	[Documentation]
	...  delete an org with an empty token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *    Delete Org     orgname=myOrg     token=${EMPTY}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"no bearer token found"}


# ECQ-2786
MC - Delete an org with a bad token	
	[Documentation]
	...  delete an org with a bad token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *    Delete Org    orgname=myOrg    token=thisisabadtoken      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}


# ECQ-2787
MC - Delete an org with an expired token	
	[Documentation]
	...  delete an org with an expired token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Delete Org    orgname=myOrg    token=${expToken}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}


# ECQ-2788
MC - Delete an org with another user assigned to the org with the admin token	
	[Documentation]
	...  delete an org with a user assigned with the admin token
	...  verify the correct error message is returned

        ${user_role}=  Get Roletype
	${epoch}=  Get Time  epoch
        ${email2}=  Catenate  SEPARATOR=  user  +  ${epoch}  @gmail.com
	${username2}=  Catenate  SEPARATOR=  user  ${epoch}
	${orgname}=   Catenate  SEPARATOR=   org   ${epoch}
	Create Org    orgname=${orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}    use_defaults=${False}   auto_delete=${False}
	Create User      username=${username2}     password=${password}     email_address=${email2}
        Adduser Role     orgname=${orgname}      username=${username2}     role=${user_role}      token=${userToken}      use_defaults=${False}
	Delete Org    orgname=${orgname}    token=${adminToken}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal              ${body}         {"message":"Organization deleted"}


# ECQ-2789
MC - Delete an org with another user assigned to the org with the org manager token	
	[Documentation]
	...  delete an org with a user assigned with the user token
	...  verify the correct error message is returned

        ${user_role}=  Get Roletype
	${epoch}=  Get Time  epoch
        ${email2}=  Catenate  SEPARATOR=  user  +  ${epoch}  @gmail.com
	${username2}=  Catenate  SEPARATOR=  user  ${epoch}
	${orgname}=   Catenate  SEPARATOR=   org   ${epoch}
	Create Org    orgname=${orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}    use_defaults=${False}   auto_delete=${False}
	Create User      username=${username2}     password=${password}     email_address=${email2}
        Adduser Role     orgname=${orgname}       username=${username2}     role=${user_role}      token=${userToken}      use_defaults=${False}
	Delete Org    orgname=${orgname}    token=${userToken}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal              ${body}         {"message":"Organization deleted"}


# ECQ-2790
MC - Delete an org created by user1 using user2 token
	[Documentation]
	...  delete an org created by another user
	...  verify the correct error message is returned

	${epoch}=  Get Time  epoch
        ${email2}=  Catenate  SEPARATOR=  user  +  ${epoch}  @gmail.com
	${username2}=  Catenate  SEPARATOR=  user  ${epoch}
	Create User       username=${username2}     password=${password}     email_address=${email2}
	Unlock User
	${user2Token}=    Login            username=${username2}     password=${password} 
	${org}=   Run Keyword and Expect Error  *   Delete Org        orgname=myOrg    token=${user2Token}      use_defaults=${False}
	${status_code}=   Response Status Code
	${body}=          Response Body
	
	Should Be Equal As Numbers   ${status_code}  403	
	Should Be Equal              ${body}         {"message":"Forbidden"}


# ECQ-2791
MC - Verify the last remaining Manager account of an org can not be deleted
	[Documentation]
	...  create a user and create an org with that user 
	...  delete the user without deleting the org first
	...  verify the correct error message is returned
	...  delete the org then the user 

	${epoch}=  Get Time  epoch
        ${email2}=  Catenate  SEPARATOR=  myuser  +  ${epoch}  @gmail.com
	${username2}=  Catenate  SEPARATOR=  user  ${epoch}
	${orgname}=   Catenate  SEPARATOR=   org   ${epoch}
	${message}=   Catenate  SEPARATOR=   {"message":"Error: Cannot delete the last remaining manager for the org   ${SPACE}   ${orgname}   "}
	Create User       username=${username2}     password=${password}     email_address=${email2}   auto_delete=${False} 
	Unlock User
	${user2Token}=   Login    username=${username2}    password=${password}
	Create Org    orgname=${orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${user2Token}    use_defaults=${False}   auto_delete=${False}

	${error}=  Run Keyword and Expect Error  *   Delete User   username=${username2}   token=${adminToken}
        Should Contain  ${error}  ${message}
	#${status_code}=   Response Status Code
	#${body}=          Response Body	
	#Should Be Equal As Numbers   ${status_code}  400	
	#Should Be Equal              ${body}         ${message}

        Delete Org   orgname=${orgname}   token=${adminToken}      use_defaults=${False}
	${body}=          Response Body
	Should Be Equal              ${body}         {"message":"Organization deleted"}

	Delete User   username=${username2}   token=${adminToken}
	#${body}=          Response Body
	#Should Be Equal              ${body}         {"message":"user deleted"}



# ECQ-2792
MC - Verify an org can not be deleted while an associated cluster inst exists
	[Documentation]
	...  create a user then create an org 
	...  create a cluster with the org
	...  delete the org without deleting the cluster
	...  verify the correct error message is returned
	...  delete cluster 
	...  delete the org

	${epoch}=  Get Time  epoch
        ${email2}=  Catenate  SEPARATOR=  user  +  ${epoch}  @gmail.com
	${username2}=  Catenate  SEPARATOR=  user  ${epoch}
	${orgname}=   Catenate  SEPARATOR=   org   ${epoch}
	${cluster_name}=  Catenate  SEPARATOR=   cluster   ${epoch}
	${message}=  Catenate  SEPARATOR=   {"message":"Organization  ${SPACE}  ${orgname}  ${SPACE}  in use or check failed: region US: in use by some ClusterInst"}
	${message2}=  Catenate  SEPARATOR=   {"message":"Organization  ${SPACE}  ${orgname}  ${SPACE}  in use or check failed: region US: in use by some AppInst, ClusterInst"}
	${message3}=  Catenate  SEPARATOR=   {"message":"Organization  ${SPACE}  ${orgname}  ${SPACE}  in use or check failed: region US: in use by some App, AppInst, ClusterInst"}
	Create User       username=${username2}     password=${password}     email_address=${email2}   auto_delete=${False} 
	Unlock User
	${user2Token}=   Login    username=${username2}    password=${password}
	Create Org    orgname=${orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${user2Token}    use_defaults=${False}   auto_delete=${False}
	Create Cluster Instance  region=US  cluster_name=${cluster_name}  cloudlet_name=tmocloud-1  operator_org_name=tmus  developer_org_name=${orgname}  flavor_name=automation_api_flavor  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  auto_delete=${False}
	Run Keyword and Expect Error  *  Delete Org   orgname=${orgname}   token=${adminToken}      use_defaults=${False}
	${body}=          Response Body
	Should Contain Any              ${body}         ${message}  ${message2}  ${message3}

	${rsp}=  Delete Cluster Instance  region=US  cluster_name=${cluster_name}   cloudlet_name=tmocloud-1   operator_org_name=tmus   developer_org_name=${orgname}

	Delete Org   orgname=${orgname}   token=${adminToken}      use_defaults=${False}
	${body}=          Response Body
	Should Be Equal              ${body}         {"message":"Organization deleted"}

	Delete User   username=${username2}   token=${adminToken}
	#${body}=          Response Body
	#Should Be Equal              ${body}         {"message":"user deleted"}



# ECQ-2793
MC - Verify an org can not be deleted while an associated app exists
	[Documentation]
	...  create a user then create an org 
	...  create a app with the org
	...  delete the org without deleting the app
	...  verify the correct error message is returned
	...  delete app and cluster 
	...  delete the org

	${epoch}=  Get Time  epoch
        ${email2}=  Catenate  SEPARATOR=  user  +  ${epoch}  @gmail.com
	${username2}=  Catenate  SEPARATOR=  user  ${epoch}
	${orgname}=   Catenate  SEPARATOR=   org   ${epoch}
	${cluster_name}=  Catenate  SEPARATOR=   cluster   ${epoch}
	${appname}=  Catenate  SEPARATOR=   app   ${epoch}
	${message}=  Catenate  SEPARATOR=   {"message":"Organization  ${SPACE}  ${orgname}  ${SPACE}  in use or check failed: region US: in use by some ClusterInst"}
	${message2}=  Catenate  SEPARATOR=   {"message":"Organization  ${SPACE}  ${orgname}  ${SPACE}  in use or check failed: region US: in use by some AppInst, ClusterInst"}
	${message3}=  Catenate  SEPARATOR=   {"message":"Organization  ${SPACE}  ${orgname}  ${SPACE}  in use or check failed: region US: in use by some App, AppInst, ClusterInst"}
	Create User       username=${username2}     password=${password}     email_address=${email2}   auto_delete=${False} 
	Unlock User
	${user2Token}=   Login    username=${username2}    password=${password}
	Create Org    orgname=${orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${user2Token}    use_defaults=${False}   auto_delete=${False}
	Create Cluster Instance  region=US  cluster_name=${cluster_name}  cloudlet_name=tmocloud-1  operator_org_name=tmus  developer_org_name=${orgname}  flavor_name=automation_api_flavor  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  auto_delete=${False}
	Create App  region=US  app_name=${appname}  app_version=1.0  developer_org_name=${orgname}  image_type=ImageTypeDocker  cluster_name=${cluster_name}  default_flavor_name=automation_api_flavor  auto_delete=${False}

	Run Keyword and Expect Error  *  Delete Org   orgname=${orgname}   token=${adminToken}      use_defaults=${False}
	${body}=          Response Body
	Should Contain Any              ${body}         ${message}  ${message2}  ${message3}

	${rsp}=  Delete Cluster Instance  region=US  cluster_name=${cluster_name}   cloudlet_name=tmocloud-1   operator_org_name=tmus   developer_org_name=${orgname}

        ${rsp}=  Delete App  region=US  app_name=${appname}  app_version=1.0  developer_org_name=${orgname}

	Delete Org   orgname=${orgname}   token=${adminToken}      use_defaults=${False}
	${body}=          Response Body
	Should Be Equal              ${body}         {"message":"Organization deleted"}

	Delete User   username=${username2}   token=${adminToken}
	#${body}=          Response Body
	#Should Be Equal              ${body}         {"message":"user deleted"}


# ECQ-2794
MC - Verify an org can not be deleted while an associated app instance exists
	[Documentation]
	...  create a user then create an org 
	...  create a app with the org
	...  delete the org without deleting the app instance
	...  verify the correct error message is returned
	...  delete app instance, app, and cluster 
	...  delete the org

	${epoch}=  Get Time  epoch
        ${email2}=  Catenate  SEPARATOR=  user  +  ${epoch}  @gmail.com
	${username2}=  Catenate  SEPARATOR=  user  ${epoch}
	${orgname}=   Catenate  SEPARATOR=   org   ${epoch}
	${cluster_name}=  Catenate  SEPARATOR=   cluster   ${epoch}
	${appname}=  Catenate  SEPARATOR=   app   ${epoch}
	${message}=  Catenate  SEPARATOR=   {"message":"Organization  ${SPACE}  ${orgname}  ${SPACE}  in use or check failed: region US: in use by some App, AppInst, ClusterInst"}
	Create User       username=${username2}     password=${password}     email_address=${email2}   auto_delete=${False} 
	Unlock User
	${user2Token}=   Login    username=${username2}    password=${password}
	Create Org    orgname=${orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${user2Token}    use_defaults=${False}   auto_delete=${False}
	Create Cluster Instance  region=US  cluster_name=${cluster_name}  cloudlet_name=tmocloud-1  operator_org_name=tmus  developer_org_name=${orgname}  flavor_name=automation_api_flavor  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  auto_delete=${False}
	Create App  region=US  app_name=${appname}  app_version=1.0  developer_org_name=${orgname}  image_type=ImageTypeDocker  cluster_name=${cluster_name}  default_flavor_name=automation_api_flavor  auto_delete=${False}

	Create App Instance  token=${user2Token}  region=US  app_name=${appname}  app_version=1.0  developer_org_name=${orgname}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}  cloudlet_name=tmocloud-1  operator_org_name=tmus  auto_delete=${False}  use_defaults=${False}

	Run Keyword and Expect Error  *  Delete Org   orgname=${orgname}   token=${adminToken}      use_defaults=${False}
	${body}=          Response Body
	Should Be Equal              ${body}         ${message}

        ${rsp}=  Delete App Instance  token=${user2Token}  region=US  app_name=${appname}  app_version=1.0  developer_org_name=${orgname}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${orgname}  cloudlet_name=tmocloud-1  operator_org_name=tmus  use_defaults=${False}
        ${rsp}=  Delete App  region=US  app_name=${appname}  app_version=1.0  developer_org_name=${orgname}
	${rsp}=  Delete Cluster Instance  region=US  cluster_name=${cluster_name}   cloudlet_name=tmocloud-1   operator_org_name=tmus   developer_org_name=${orgname}
	Delete Org   orgname=${orgname}   token=${adminToken}      use_defaults=${False}
	${body}=          Response Body
	Should Be Equal              ${body}         {"message":"Organization deleted"}

	Delete User   username=${username2}   token=${adminToken}
	#${body}=          Response Body
	#Should Be Equal              ${body}         {"message":"user deleted"}


*** Keywords ***
Setup
	${adminToken}=   Login    username=qaadmin    password=mexadminfastedgecloudinfra
	${epoch}=  Get Time  epoch
        ${email}=  Catenate  SEPARATOR=   user  +  ${epoch}  @gmail.com
	${username}=  Catenate  SEPARATOR=   user   ${epoch}
	${orgname}=   Catenate  SEPARATOR=   org   ${epoch} 
#        Skip Verify Email
#	Create User  username=${username}   password=${password}   email_address=${email}
#	Unlock User
#	${userToken}=  Login  username=${username}  password=${password}
        ${userToken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
	Create Org    orgname=${orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}    use_defaults=${False}
	Set Suite Variable  ${adminToken}
	Set Suite Variable  ${userToken}
	
