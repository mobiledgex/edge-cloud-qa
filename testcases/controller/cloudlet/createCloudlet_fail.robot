*** Settings ***
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}





*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}  CreatTest


*** Test Cases ***
CreateCloudlet without an operator
	[Documentation]   CreateCloudlet - Tries to create a cloudlet without an operator
	...  Trys to create a cloudlet without an operator
	...  Expect the create to fail with the operator not found error

	${error_msg}=  Run Keyword And Expect Error  *   Create Cloudlet	   cloudlet_name=${cldlet}     number_of_dynamic_ips=default      latitude=35.0     longitude=-96.0    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid operator name"
	
CreateCloudlet with an invalid operator
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with an invalid operator
	...  Trys to create a cloudlet with an invalid operator
	...  Expect the create to fail with the operator not found drror

        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet	cloudlet_name=${cldlet}     operator_name=mci     number_of_dynamic_ips=default      latitude=35.0     longitude=-96.0    notify_server_address=${port}  use_defaults=False

	[Teardown]	Cleanup provisioning
	
CreateCloudlet without a name
	[Documentation]   CreateCloudlet - Tries to create a cloudlet without a cloudlet name
	...  Trys to create a cloudlet without a cloudlet name
	...  Expect the create to fail with the invalid name error

	${error_msg}=  Run Keyword And Expect Error  *   Create Cloudlet	operator_name=${oper}      number_of_dynamic_ips=default      latitude=35.0     longitude=-96.0     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid cloudlet name"
	
CreateCloudlet without a location
	[Documentation]   CreateCloudlet - Tries to create a cloudlet without a location 
	...  This tests case will not set the location for the cloudlet and should be rejected.
	...  Expect the test case to fail with loacation can not be 0 0 error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "location is missing; 0,0 is not a valid location"

CreateCloudlet with a location of 0 0
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of 0 0
	...  This tests case will set the location to 0 0 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with loacation can not be 0 0 error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     latitude=0      longitude=0    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "location is missing; 0,0 is not a valid location"

CreateCloudlet with a location of 100 200
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of 100 200
	...  This tests case will set the location to 100 200 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with an Invalid latitude value error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     latitude=100      longitude=200    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid latitude value"

CreateCloudlet with a location of 90 200
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of 90 200
	...  This tests case will set the location to 90 200 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with an Invalid longitude value error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     latitude=90      longitude=200    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid longitude value"

CreateCloudlet with a location of -100 -200
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of -100 -200
	...  This tests case will set the location to -100 -200 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with an Invalid latitude value error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     latitude=-100      longitude=-200    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid latitude value"

CreateCloudlet with a location of -90 -200
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of -90 -200
	...  This tests case will set the location to -90 -200 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with an Invalid longitude value error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     latitude=90      longitude=200    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid longitude value"

CreateCloudlet with numdynamic set to 0
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with numdynamicIPS of 0
	...  You must have at least 1 dynamic IPS, this test case will set the value to 0
	...  Expect the create to fail with  
	
	${dips}  Convert To Integer 	0
	
	${error_msg}=  Run Keyword And Expect Error  *   Create Cloudlet     operator_name=${oper}    cloudlet_name=${cldlet}      number_of_dynamic_ips=${dips}     latitude=35.0     longitude=-96.0    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Must specify at least one dynamic public IP available"

CreateCloudlet with an invalid ipsupport enumeration -1
    [Documentation]   CreateCloudlet - Tries to create a cloudlet with an invalid ipsupport enumeration -1
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...            Expect the test to fail as enumeration -1 is not used and will give an error.
	
	${supp}    Convert To Integer 	-1
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}     number_of_dynamic_ips=default    latitude=35     longitude=-96   ipsupport=${supp}   use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"

CreateCloudlet with an invalid ipsupport IPSupportStatic
    [Documentation]   CreateCloudlet - Tries to create a cloudlet with an invalid ipsupport IPSupportStatic
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...             IpSupportStatic (1) is not supported at this time and will give an error.
	
    ${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	operator_name=${oper}    cloudlet_name=${cldlet}      number_of_dynamic_ips=default    latitude=35     longitude=-96   ipsupport=IpSupportStatic    use_defaults=False

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"

	
CreateCloudlet with an invalid ipsupport enumeration 3
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with an invalid ipsupport enumeration 3 
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...             Expect the test to fail as enumeration 3 is not used and will give an error.
	${supp}    Convert To Integer 	3
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}     number_of_dynamic_ips=default    latitude=35     longitude=-96   ipsupport=${supp}     use_defaults=False

	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"

CreateCloudlet - cloudlet should fail if address already in use
    [Documentation]  
        ...            send CreateCloudlet with address that is already in use 
        ...            verify correct error is received 

    #Create Cloudlet  operator_name=${oper}   cloudlet_name=${cldlet}   number_of_dynamic_ips=default  latitude=35  longitude=-96  accesscredentials=https://support.sup.com/supersupport  ipsupport=IpSupportDynamic  staticips=30.30.30.1

    ${epoch}=  Get Time  epoch
    ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}

    ${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet  operator_name=${oper}  cloudlet_name=${cldlet}  number_of_dynamic_ips=5  latitude=35  longitude=-96  ipsupport=IpSupportDynamic  notify_server_address=127.0.0.1:37001

   Should Contain  ${error_msg}  Failure: ServerMgr listen failed {\\"err\\": \\"listen tcp 127.0.0.1:37001: bind: address already in use\\"} 

