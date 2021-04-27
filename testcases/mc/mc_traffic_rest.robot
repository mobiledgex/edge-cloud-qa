*** Settings ***
Documentation  User Login multiple times

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime
	
Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${password}=   ${mextester06_gmail_password}
${number_batches}   10
${number_requests}  100
${autoLogin}	    1
${name}             None
${type}             None
${address}          None
${phone}            None

	
*** Test Cases ***
MC - Login mc requests admin user Traffic 
	[Documentation]
	...  Send simultaneous Login request messages to the MC
	...  Verify all are successful

        [Tags]  Traffic

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send Login
	
	${total}=    Number of Login Requests
	${success}=  Number of Successful Login Requests
	${fail}=     Number of Failed Login Requests

	${total_total}=    Evaluate  ${number_requests}*${number_batches}+${autoLogin}+1
	
	Should Be Equal As Numbers  ${total}  ${total_total}
	Should Be Equal As Numbers  ${success}  ${total_total}
	Should Be Equal As Numbers  ${fail}  0

MC - Create User requests create different users Traffic 
	[Documentation]
	...  Send simultaneous Create Users request messages to the MC
	...  Verify all are successful

        [Tags]  Traffic
	
	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send Createuser

	${total}=     Number of Createuser Requests
	${success}=   Number of Successful Createuser Requests
	${fail}=      Number of Failed Createuser Requests

	${total_total}=    Evaluate  ${number_requests}*${number_batches}
	
	Should Be Equal As Numbers  ${total}  ${total_total}
	Should Be Equal As Numbers  ${success}  ${total_total}
	Should Be Equal As Numbers  ${fail}  0

MC - Login mc requests different users Traffic 
	[Documentation]
	...  Send simultaneous Login request messages for different users to the MC
	...  Verify all are successful

        [Tags]  Traffic

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateuserSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send LoginUsers

 	${usertotal}=     Number of Createuser Requests
	${usersuccess}=   Number of Successful Createuser Requests
	${userfail}=      Number of Failed Createuser Requests
	${usertotal_total}=    Evaluate  ${number_requests}*${number_batches}

	${logintotal}=    Number of Login Requests
	${loginsuccess}=  Number of Successful Login Requests
	${loginfail}=     Number of Failed Login Requests
	${logintotal_total}=    Evaluate  ${number_requests}*${number_batches}+${autoLogin}

	Should Be Equal As Numbers  ${usertotal}  ${usertotal_total}
	Should Be Equal As Numbers  ${usersuccess}  ${usertotal_total}
	Should Be Equal As Numbers  ${userfail}  0
	Should Be Equal As Numbers  ${logintotal}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginsuccess}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginfail}  0

MC - Current users mc requests different users Traffic 
	[Documentation]
	...  Send simultaneous Current Users request messages for different users to the MC
	...  Verify all are successful

        [Tags]  Traffic

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateuserSeq

	@{token_list}=   Create List

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send UserLoginSeq

	Set Suite Variable    @{token_list}
	

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CurrentUser
	
	${usertotal}=     Number of Createuser Requests
	${usersuccess}=   Number of Successful Createuser Requests
	${userfail}=      Number of Failed Createuser Requests
	${usertotal_total}=    Evaluate  ${number_requests}*${number_batches}

	${logintotal}=    Number of Login Requests
	${loginsuccess}=  Number of Successful Login Requests
	${loginfail}=     Number of Failed Login Requests
	${logintotal_total}=    Evaluate  ${number_requests}*${number_batches}+${autoLogin}

	${currenttotal}=     Number of Currentuser Requests
	${currentsuccess}=   Number of Successful Currentuser Requests
	${currentfail}=      Number of Failed Currentuser Requests
	${currenttotal_total}=    Evaluate  ${number_requests}*${number_batches}

	Should Be Equal As Numbers  ${usertotal}  ${usertotal_total}
	Should Be Equal As Numbers  ${usersuccess}  ${usertotal_total}
	Should Be Equal As Numbers  ${userfail}  0
	Should Be Equal As Numbers  ${logintotal}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginsuccess}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginfail}  0
	Should Be Equal As Numbers  ${currenttotal}  ${currenttotal_total}
	Should Be Equal As Numbers  ${currentsuccess}  ${currenttotal_total}
	Should Be Equal As Numbers  ${currentfail}  0

MC - Show Role mc requests admin user Traffic 
	[Documentation]
	...  Send simultaneous Show Role request messages to the MC
	...  Verify all are successful

        [Tags]  Traffic

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send ShowRole
		
	${total}=    Number of Showrole Requests
	${success}=  Number of Successful Showrole Requests
	${fail}=     Number of Failed Showrole Requests

	${total_total}=    Evaluate  ${number_requests}*${number_batches}
	
	Should Be Equal As Numbers  ${total}  ${total_total}
	Should Be Equal As Numbers  ${success}  ${total_total}
	Should Be Equal As Numbers  ${fail}  0

MC - Show Role mc requests different users Traffic 
	[Documentation]
	...  Send simultaneous Show Role request messages to the MC
	...  Verify all are successful

        [Tags]  Traffic

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateuserSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send UserLoginSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send ShowRoleUsers
	
	${usertotal}=     Number of Createuser Requests
	${usersuccess}=   Number of Successful Createuser Requests
	${userfail}=      Number of Failed Createuser Requests
	${usertotal_total}=    Evaluate  ${number_requests}*${number_batches}

	${logintotal}=    Number of Login Requests
	${loginsuccess}=  Number of Successful Login Requests
	${loginfail}=     Number of Failed Login Requests
	${logintotal_total}=    Evaluate  ${number_requests}*${number_batches}+${autoLogin}

	${roletotal}=    Number of Showrole Requests
	${rolesuccess}=  Number of Successful Showrole Requests
	${rolefail}=     Number of Failed Showrole Requests
	${roletotal_total}=    Evaluate  ${number_requests}*${number_batches}
	
	Should Be Equal As Numbers  ${usertotal}  ${usertotal_total}
	Should Be Equal As Numbers  ${usersuccess}  ${usertotal_total}
	Should Be Equal As Numbers  ${userfail}  0
	Should Be Equal As Numbers  ${logintotal}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginsuccess}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginfail}  0
	Should Be Equal As Numbers  ${roletotal}  ${roletotal_total}
	Should Be Equal As Numbers  ${rolesuccess}  ${roletotal_total}
	Should Be Equal As Numbers  ${rolefail}  0

MC - Create Org mc requests different users Traffic 
	[Documentation]
	...  Send simultaneous Create Org request messages to the MC
	...  Verify all are successful

        [Tags]  Traffic

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateuserSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send UserLoginSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateOrg
	
	${usertotal}=     Number of Createuser Requests
	${usersuccess}=   Number of Successful Createuser Requests
	${userfail}=      Number of Failed Createuser Requests
	${usertotal_total}=    Evaluate  ${number_requests}*${number_batches}

	${logintotal}=    Number of Login Requests
	${loginsuccess}=  Number of Successful Login Requests
	${loginfail}=     Number of Failed Login Requests
	${logintotal_total}=    Evaluate  ${number_requests}*${number_batches}+${autoLogin}

	${orgtotal}=    Number of Createorg Requests
	${orgsuccess}=  Number of Successful Createorg Requests
	${orgfail}=     Number of Failed Createorg Requests
	${orgtotal_total}=    Evaluate  ${number_requests}*${number_batches}
	
	Should Be Equal As Numbers  ${usertotal}  ${usertotal_total}
	Should Be Equal As Numbers  ${usersuccess}  ${usertotal_total}
	Should Be Equal As Numbers  ${userfail}  0
	Should Be Equal As Numbers  ${logintotal}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginsuccess}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginfail}  0
	Should Be Equal As Numbers  ${orgtotal}  ${orgtotal_total}
	Should Be Equal As Numbers  ${orgsuccess}  ${orgtotal_total}
	Should Be Equal As Numbers  ${orgfail}  0

MC - Show Org mc requests different users Traffic 
	[Documentation]
	...  Send simultaneous Create Org request messages to the MC
	...  Verify all are successful

        [Tags]  Traffic

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateuserSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send UserLoginSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateOrgSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send ShowOrg

	${usertotal}=     Number of Createuser Requests
	${usersuccess}=   Number of Successful Createuser Requests
	${userfail}=      Number of Failed Createuser Requests
	${usertotal_total}=    Evaluate  ${number_requests}*${number_batches}

	${logintotal}=    Number of Login Requests
	${loginsuccess}=  Number of Successful Login Requests
	${loginfail}=     Number of Failed Login Requests
	${logintotal_total}=    Evaluate  ${number_requests}*${number_batches}+${autoLogin}

	${orgtotal}=    Number of Createorg Requests
	${orgsuccess}=  Number of Successful Createorg Requests
	${orgfail}=     Number of Failed Createorg Requests
	${orgtotal_total}=    Evaluate  ${number_requests}*${number_batches}
	
	${showorgtotal}=    Number of Showorg Requests
	${showorgsuccess}=  Number of Successful Showorg Requests
	${showorgfail}=     Number of Failed Showorg Requests
	${showorgtotal_total}=    Evaluate  ${number_requests}*${number_batches}

	Should Be Equal As Numbers  ${usertotal}  ${usertotal_total}
	Should Be Equal As Numbers  ${usersuccess}  ${usertotal_total}
	Should Be Equal As Numbers  ${userfail}  0
	Should Be Equal As Numbers  ${logintotal}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginsuccess}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginfail}  0
	Should Be Equal As Numbers  ${orgtotal}  ${orgtotal_total}
	Should Be Equal As Numbers  ${orgsuccess}  ${orgtotal_total}
	Should Be Equal As Numbers  ${orgfail}  0
	Should Be Equal As Numbers  ${showorgtotal}  ${showorgtotal_total}
	Should Be Equal As Numbers  ${showorgsuccess}  ${showorgtotal_total}
	Should Be Equal As Numbers  ${showorgfail}  0

MC - Adduser Role mc requests different users Traffic 
	[Documentation]
	...  Send simultaneous Role Adduser request messages to the MC
	...  Verify all are successful

        [Tags]  Traffic

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateuserSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send UserLoginSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateOrgSeq

	Reset User Count

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CreateRoleuserSeq

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send AdduserRole

	${logintotal}=    Number of Login Requests
	${loginsuccess}=  Number of Successful Login Requests
	${loginfail}=     Number of Failed Login Requests
	${logintotal_total}=    Evaluate  ${number_requests}*${number_batches}+${autoLogin}

	${orgtotal}=    Number of Createorg Requests
	${orgsuccess}=  Number of Successful Createorg Requests
	${orgfail}=     Number of Failed Createorg Requests
	${orgtotal_total}=    Evaluate  ${number_requests}*${number_batches}
	
	${usertotal}=     Number of Createuser Requests
	${usersuccess}=   Number of Successful Createuser Requests
	${userfail}=      Number of Failed Createuser Requests
	${usertotal_total}=    Evaluate  ${number_requests}*${number_batches}

	${addusertotal}=    Number of Adduserrole Requests
	${addusersuccess}=  Number of Successful Adduserrole Requests
	${adduserfail}=     Number of Failed Adduserrole Requests
	${addusertotal_total}=    Evaluate  ${number_requests}*${number_batches}

	Should Be Equal As Numbers  ${logintotal}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginsuccess}  ${logintotal_total}
	Should Be Equal As Numbers  ${loginfail}  0
	Should Be Equal As Numbers  ${orgtotal}  ${orgtotal_total}
	Should Be Equal As Numbers  ${orgsuccess}  ${orgtotal_total}
	Should Be Equal As Numbers  ${orgfail}  0
	Should Be Equal As Numbers  ${usertotal}  ${usertotal_total}
	Should Be Equal As Numbers  ${usersuccess}  ${usertotal_total}
	Should Be Equal As Numbers  ${userfail}  0
	Should Be Equal As Numbers  ${addusertotal}  ${addusertotal_total}
	Should Be Equal As Numbers  ${addusersuccess}  ${addusertotal_total}
	Should Be Equal As Numbers  ${adduserfail}  0

*** Keywords ***
Setup
   Login Mexadmin

Send Login
	@{handle_list}=  Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}=  Login     use_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	
	MexMasterController.Wait For Replies    @{handle_list}

Send LoginUsers
	@{handle_list}=  Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}=  Login      username=@{user_list}[${INDEX}]     password=@{pass_list}[${INDEX}]    use_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	
	MexMasterController.Wait For Replies    @{handle_list}

Send Createuser
	@{handle_list}=   Create List
        ${epoch}=  Get Current Date  result_format=epoch
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}=    Create User  username=user${epoch}${INDEX}  password=${password}   use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}

	MexMasterController.Wait For Replies  @{handle_list}

Send CreateuserSeq
	@{user_list}=     Create List
	@{pass_list}=     Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${user}    ${pass}   ${email}=    Create User     
	\  Append To List  ${user_list}    ${user}
	\  Append To List  ${pass_list}    ${pass}

	Set Suite Variable    @{user_list}
	Set Suite Variable    @{pass_list}


Send UserLoginSeq
	@{token_list}=   Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${token}=   Login     username=@{user_list}[${INDEX}]    password=@{pass_list}[${INDEX}]   
	\  Append To List  ${token_list}   ${token}

	Set Suite Variable    @{token_list}
	

Send CurrentUser
	@{handle_list}=  Create List

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}    Get Current User     token=@{token_list}[${INDEX}]     use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}

Send ShowRole
	@{handle_list}=  Create List
	${adminToken}=    Login

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}    Show Role      token=${adminToken}      use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}
	
Send ShowRoleUsers
	@{handle_list}=  Create List

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}    Show Role      token=@{token_list}[${INDEX}]      use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}
	
Send CreateOrg
	@{handle_list}=   Create List

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}=   Create Org    token=@{token_list}[${INDEX}]      use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}

Send CreateOrgSeq
	@{orgname_list}=   Create List

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${orgname}=    Create Org    token=@{token_list}[${INDEX}]      
	\  Append To List  ${orgname_list}  ${orgname}
	
	Set Suite Variable     @{orgname_list}

Send CreateRoleuserSeq
	@{roleuser_list}=     Create List
	@{rolepass_list}=     Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${user}    ${pass}   ${email}=     Create User    
	\  Append To List  ${roleuser_list}    ${user}
	\  Append To List  ${rolepass_list}    ${pass}

	Set Suite Variable    @{roleuser_list}
	Set Suite Variable    @{rolepass_list}

Send ShowOrg
	@{handle_list}=   Create List

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}=   Show Org    token=@{token_list}[${INDEX}]      use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}

Send AdduserRole
	@{handle_list}=   Create List

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}=    Adduser Role     orgname=@{orgname_list}[${INDEX}]     username=@{roleuser_list}[${INDEX}]    token=@{token_list}[${INDEX}]      use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}     #to run sequentially comment this line and use_threads=${True} above
