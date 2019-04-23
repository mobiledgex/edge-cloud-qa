*** Settings ***
Documentation  User Login multiple times

Library		MexMasterController  root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
	
#Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${password}=   mex1234567
${number_batches}   10
${number_requests}  100
${autoLogin}	    1

	
*** Test Cases ***
MC - Login mc requests admin user Traffic 
	[Documentation]
	...  Send simultaneous Login request messages to the MC
	...  Verify all are successful

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send Login

	Sleep   10s    Wait for replies 
	
	${total}=    Number of Login Requests
	${success}=  Number of Successful Login Requests
	${fail}=     Number of Failed Login Requests

	${total_total}=    Evaluate  ${number_requests}*${number_batches}+${autoLogin}
	
	Should Be Equal As Numbers  ${total}  ${total_total}
	Should Be Equal As Numbers  ${success}  ${total_total}
	Should Be Equal As Numbers  ${fail}  0

MC - Create User requests create different users Traffic 
	[Documentation]
	...  Send simultaneous Create Users request messages to the MC
	...  Verify all are successful
	
	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send Createuser

	Sleep   10s    Wait for replies 

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

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send Createuser

        Sleep    10s    Wait for replies
	
	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send LoginUsers

        Sleep    10s    Wait for replies

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

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send Createuser

	Sleep    10s    Wait for replies

	@{token_list}=   Create List

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send UserLogin

	Set Suite Variable    @{token_list}
	

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send CurrentUser

	Sleep    10s    Wait for replies
	
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

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send ShowRole
	
	Sleep   10s    Wait for replies
	
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

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send Createuser

	Sleep   10s    Wait for replies

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send UserLogin

	Sleep   10s    Wait for replies

	: FOR  ${x}  IN RANGE  0  ${number_batches}
	\  Send ShowRoleUsers

	Sleep   10s    Wait for replies
	
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


*** Keywords ***
Send Login
	@{handle_list}=  Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}=  Login     use_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	
	MexMasterController.Wait For Replies    @{handle_list}

Send LoginUsers
	@{handle_list}=  Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}=  Login      @{user_list}[${INDEX}]     @{pass_list}[${INDEX}]    use_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	
	MexMasterController.Wait For Replies    @{handle_list}

Send Createuser
	@{handle_list}=   Create List
	@{user_list}=     Create List
	@{pass_list}=     Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}   ${user}    ${pass}=    Create User     use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	\  Append To List  ${user_list}    ${user}
	\  Append To List  ${pass_list}    ${pass}

	Set Suite Variable    @{user_list}
	Set Suite Variable    @{pass_list}

	MexMasterController.Wait For Replies  @{handle_list}

Send UserLogin
	@{token_list}=   Create List
	
	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${token}=   Login     @{user_list}[${INDEX}]     @{pass_list}[${INDEX}]   
	\  Append To List  ${token_list}   ${token}

	Set Suite Variable    @{token_list}
	

Send CurrentUser
	@{handle_list}=  Create List

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}    Get Current User     @{token_list}[${INDEX}]     use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}

Send ShowRole
	@{handle_list}=  Create List
	${adminToken}=    Login

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}    Show Role      ${adminToken}      use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}
	
Send ShowRoleUsers
	@{handle_list}=  Create List

	: FOR  ${INDEX}  IN RANGE  0  ${number_requests}
	\  ${handle}    Show Role      @{token_list}[${INDEX}]      use_thread=${True}
	\  Append To List  ${handle_list}  ${handle}
	
	MexMasterController.Wait For Replies  @{handle_list}
	

