*** Settings ***
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}    DeleteTest

*** Test Cases ***
DeleteCloudlet without an operator
	[Documentation]   DeleteCloudlet -  Trys to delete a cloudlet without an operator
	...  This test case trys to delete a cloudlet without giving an operator name
	...  Expect to fail witn invalid operator name
	
	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	cloudlet_name=${cldlet}     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid operator name"

DeleteCloudlet with an invalid operator
	[Documentation]   DeleteCloudlet -  Trys to delete a cloudlet with an invalid operator
	...  This test case will try and delete a cloudlet with an invalid operator name 
	...  Expect this test case to fail with an invalid Key (Needs a valid operator and a valid cloudlet name)
	 
	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	operator_name=mci      cloudlet_name=${cldlet}      use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Key not found"

DeleteCloudlet without a cloudlet name
	[Documentation]   DeleteCloudlet -  Trys to delete a cloudlet without a cloudlet name
	...  This test case trys to delete a cloudlet without giving a cloudlet name
	...  Expect to fail witn invalid cloudlet name
	
	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	operator_name=${oper}       use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid cloudlet name"

DeleteCloudlet with an invalid cloudlet name
	[Documentation]   DeleteCloudlet -  Trys to delete a cloudlet with an invalid cloudlet name
	...  This test case will try and delete a cloudlet with an invalid cloudlet name 
	...  Expect this test case to fail with an invalid Key (Needs a valid operator and a valid cloudlet name)

	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	operator_name=${oper}   cloudlet_name=Test     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Key not found"

DeleteCloudlet with a valid operator and cloudlet name
	[Documentation]   DeleteCloudlet -  Successfully deletes a cloudlet
	...  This test case will create a cloudlet and then delete the cloudlet
	...  Expect to pass. The cloudlet will successfully be created and then deleted'
	
	Create Cloudlet     operator_name=${oper}       cloudlet_name=${cldlet}      number_of_dynamic_ips=default    latitude=35.0     longitude=-96.0
	Delete Cloudlet     operator_name=${oper}       cloudlet_name=${cldlet}
	Cloudlet Should Not Exist

