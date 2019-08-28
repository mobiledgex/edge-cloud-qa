*** Settings ***
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}   azure
${cldlet}    TestUpdate
${dips}    254

*** Test Cases ***
UpdateCloudlet without an operator
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet without an operator name
	...  The test case will try and update a Cloudlet with only the cloudlet name.
	...  An Invalid opereator name error is expected

        [Setup]  Setup

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   cloudlet_name=${cldlet}    use_defaults=False

	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Key not found"
        Should Contain  ${error_msg}   details = "Invalid operator name"

        [Teardown]  Cleanup provisioning

UpdateCloudlet with an invalid operator
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid operator name
	...  The test case will try and update a Cloudlet with a valid cloudlet name and in invalid operator name.
	...  A Key not found error is expected

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=mci      cloudlet_name=${cldlet}    use_defaults=False

	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Key not found"


UpdateCloudlet without a cloudlet name
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet without a cloudlet name
	...  The test case will try and update a Cloudlet with only the operator name.
	...  An Invalid cloudlet name error is expected

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	    operator_name=${oper}     use_defaults=False

	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Key not found"
        Should Contain  ${error_msg}   details = "Invalid cloudlet name"

UpdateCloudlet with an invalid cloudlet name
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet name
	...  The test case will try and update a Cloudlet with an invalid cloudlet name.
	...  A Key not found error is expected

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=TestMe    use_defaults=False

	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Key not found"


UpdateCloudlet with a numdynamicips 0
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet number of dynamic ips value
	...  The test case will try and update a Cloudlet with an invalid number of dynamic ips (0).
	...  A 'Cannot specify less than one dynamic IP unless Ip Support Static is specified' error is expected

	${dips}  Convert To Integer 	0

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=${cldlet}    number_of_dynamic_ips=${dips}    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Cannot specify less than one dynamic IP unless Ip Support Static is specified"
	
	
UpdateCloudlet with a numdynamicips -1
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet number of dynamic ips value
	...  The test case will try and update a Cloudlet with an invalid number of dynamic ips (-1).
	...  A 'Cannot specify less than one dynamic IP unless Ip Support Static is specified' error is expected

	${dips}    Convert To Integer 	-1

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=${cldlet}    number_of_dynamic_ips=${dips}      use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Cannot specify less than one dynamic IP unless Ip Support Static is specified"


UpdateCloudlet with a numdynamicips A
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet number of dynamic ips value
	...  The test case will try and update a Cloudlet with an invalid number of dynamic ips (A).
	...  TypeError: 'A' has type str, but expected one of: int, long   error is expected


	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=${cldlet}    number_of_dynamic_ips=A        use_defaults=False
	Should Contain Any  ${error_msg}   ValueError: invalid literal for int() with base 10: 'A'  TypeError: 'A' has type str, but expected one of: int, long    TypeError: 'A' has type <class 'str'>, but expected one of: (<class 'int'>,) for field Cloudlet.num_dynamic_ips
        #Should Contain  ${error_msg}   TypeError: 'A' has type <class 'str'>, but expected one of: (<class 'int'>,) for field Cloudlet.num_dynamic_ips


UpdateCloudlet with a numdynamicips 2323232232323
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet number of dynamic ips value
	...  The test case will try and update a Cloudlet with an invalid number of dynamic ips (2323232232323).
	...  ValueError: Value out of range: 2323232232323  error is expected

	${dips}    Convert To Integer 	2323232232323

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=${cldlet}    number_of_dynamic_ips=${dips}        use_defaults=False
	Should Contain  ${error_msg}   ValueError: Value out of range: 2323232232323

UpdateCloudlet with a ipsupport of -1
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet ipsupport value
	...  The test case will try and update a Cloudlet with an invalid ipsupport (-1).
	...  An 'invalid IpSupport' error is expected

        [Setup]   Setup

	${ipsup}    Convert To Integer 	-1

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=${cldlet}    ipsupport=${ipsup}      use_defaults=False             
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "invalid IpSupport"
       
        [Teardown]  Cleanup provisioning
 
UpdateCloudlet with a ipsupport of -8
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet ipsupport value
	...  The test case will try and update a Cloudlet with an invalid ipsupport (-8).
	...  An 'invalid IpSupport' error is expected

	${ipsup}    Convert To Integer 	-8

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=${cldlet}    ipsupport=${ipsup}        use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "invalid IpSupport"

UpdateCloudlet with a location of 0 0 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of 0 0.
	...  A 'location is missing; 0,0 is not a valid location' error is expected

	[Setup]  Setup

	${locat}    Convert To Integer 	0

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}      cloudlet_name=${cldlet}      latitude=${locat}      longitude=${locat}       use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid latitude value"

	[Teardown]  Cleanup provisioning

UpdateCloudlet with a location of 100 200 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of 100 200.
	...  A 'Invalid latitude value' error is expected

        [Setup]  Setup

	${lat}    Convert To Integer 	100
	${long}    Convert To Integer 	200

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}      cloudlet_name=${cldlet}      latitude=${lat}      longitude=${long}       use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid latitude value"

        [Teardown]  Cleanup provisioning

UpdateCloudlet with a location of 90 200 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of 90 200.
	...  A 'Invalid longitude value' error is expected

        [Setup]  Setup
        [Teardown]  Cleanup provisioning

	${lat}    Convert To Integer 	90
	${long}    Convert To Integer 	200

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}      cloudlet_name=${cldlet}      latitude=${lat}      longitude=${long}       use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid longitude value"

UpdateCloudlet with a location of -100 -200 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of -100 -200.
	...  A 'Invalid latitude value' error is expected

        [Setup]  Setup
        [Teardown]  Cleanup provisioning

	${lat}    Convert To Integer 	-100
	${long}    Convert To Integer 	-200

	${error_msg}=  Run Keyword And Expect Error  *   Update Cloudlet   operator_name=${oper}      cloudlet_name=${cldlet}      latitude=${lat}      longitude=${long}       use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid latitude value"

UpdateCloudlet with a location of -90 -200 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of -90 -200.
	...  A 'Invalid longitude value' error is expected

        [Setup]  Setup
        [Teardown]  Cleanup provisioning

	${lat}    Convert To Integer 	-90
	${long}    Convert To Integer 	-200

	${error_msg}=  Run Keyword And Expect Error  *   Update Cloudlet   operator_name=${oper}      cloudlet_name=${cldlet}      latitude=${lat}      longitude=${long}       use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid longitude value"

UpdateCloudlet with a location of A A 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of A A.
	...  A 'location is missing; 0,0 is not a valid location' error is expected

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=${cldlet}    latitude=A    longitude=A         use_defaults=False
	Should Contain  ${error_msg}   ValueError: could not convert string to float: 'A'

UpdateCloudlet with accessuri of 6 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet accessuri value
	...  The test case will try and update a Cloudlet with an invalid accessuri of 6.
	...  A 'TypeError: 6 has type int, but expected one of: bytes, unicode' error is expected

	${accessuri}    Convert To Integer 	6

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}   cloudlet_name=${cldlet}    accesscredentials=${accessuri}       use_defaults=False
	Should Contain Any  ${error_msg}   TypeError: 6 has type int, but expected one of: bytes, unicode    TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.access_credentials
        #Should Contain  ${error_msg}  TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.access_uri

UpdateCloudlet with staticips of 6 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet staticips value
	...  The test case will try and update a Cloudlet with an invalid staticips of 6.
	...  A 'TypeError: 6 has type int, but expected one of: bytes, unicode' error is expected

	${statips}    Convert To Integer 	6

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	   operator_name=${oper}     cloudlet_name=${cldlet}     staticips=${statips}       use_defaults=False
	Should Contain Any  ${error_msg}   TypeError: 6 has type int, but expected one of: bytes, unicode    TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.static_ips
        #Should Contain  ${error_msg}  TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.static_ips


*** Keywords ***
Setup
	${dips}    Convert To Integer     254

        Sleep  1s
        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}


	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     number_of_dynamic_ips=${dips}    latitude=35     longitude=-96  notify_server_address=${port}  use_defaults=False 
	Cloudlet Should Exist

        Set Suite Variable  ${cldlet}
