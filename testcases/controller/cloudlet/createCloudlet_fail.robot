*** Settings ***
Library		MexController  controller_address=${controller_api_address}


Test Teardown	Cleanup provisioning


*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}  CreatTest


*** Test Cases ***
CreateCloudlet without an operator
	[Documentation]   CreateCloudlet - Trys to create a cloudlet without an operator
	...  Trys to create a cloudlet without an operator
	...  Expect the create to fail with the operator not found error

	${error_msg}=  Run Keyword And Expect Error  *   Create Cloudlet	   cloudlet_name=${cldlet}     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Specified cloudlet operator not found"
	
CreateCloudlet without an invalid operator
	[Documentation]   CreateCloudlet - Trys to create a cloudlet with an invalid operator
	...  Trys to create a cloudlet with an invalid operator
	...  Expect the create to fail with the operator not found drror

	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	cloudlet_name=${cldlet}     operator_name=mci     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Specified cloudlet operator not found"
	
CreateCloudlet without a name
	[Documentation]   CreateCloudlet - Trys to create a cloudlet without a cloudlet name
	...  Trys to create a cloudlet without a cloudlet name
	...  Expect the create to fail with the invalid name error

	${error_msg}=  Run Keyword And Expect Error  *   Create Cloudlet	operator_name=${oper}      number_of_dynamic_ips=default      latitude=35.0     longitude=-96.0     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Invalid cloudlet name"
	
CreateCloudlet with a location of 0 0
	[Documentation]   CreateCloudlet - Trys to create a cloudlet with location of 0 0
	...  This tests case will set the location to 0 0 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with loacation can not be 0 0 error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     latitude=0      longitude=0    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "location is missing; 0,0 is not a valid location"

CreateCloudlet with a location of 100 200
	[Documentation]   CreateCloudlet - Trys to create a cloudlet with location of 100 200
	...  This tests case will set the location to 0 0 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with loacation can not be 100 200 error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     latitude=100      longitude=200    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "location is missing; 0,0 is not a valid location"

CreateCloudlet with a location of -100 -200
	[Documentation]   CreateCloudlet - Trys to create a cloudlet with location of -100 -200
	...  This tests case will set the location to 0 0 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with loacation can not be -100 -200 error
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	      operator_name=${oper}      cloudlet_name=${cldlet}     number_of_dynamic_ips=default     latitude=-100      longitude=-200    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "location is missing; 0,0 is not a valid location"

CreateCloudlet with numdynamic set to 0
	[Documentation]   CreateCloudlet - Trys to create a cloudlet with numdynamicIPS of 0
	...  You must have at least 1 dynamic IPS, this test case will set the value to 0
	...  Expect the create to fail with  
	
	${dips}  Convert To Integer 	0
	
	${error_msg}=  Run Keyword And Expect Error  *   Create Cloudlet     operator_name=${oper}    cloudlet_name=${cldlet}      number_of_dynamic_ips=${dips}     latitude=35.0     longitude=-96.0    use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Must specify at least one dynamic public IP available"

CreateCloudlet with an invalid ipsupport enumeration -1
    [Documentation]   CreateCloudlet - Trys to create a cloudlet with an invalid ipsupport enumeration -1
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...            Expect the test to fail as enumeration -1 is not used and will give an error.
	
	${supp}    Convert To Integer 	1
	
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}     number_of_dynamic_ips=default    latitude=35     longitude=-96   ipsupport=${supp}   use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"

CreateCloudlet with an invalid ipsupport IPSupportStatic
    [Documentation]   CreateCloudlet - Trys to create a cloudlet with an invalid ipsupport IPSupportStatic
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...             IpSupportStatic (1) is not supported at this time and will give an error.
	
    ${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	operator_name=${oper}    cloudlet_name=${cldlet}      number_of_dynamic_ips=default    latitude=35     longitude=-96   ipsupport=IpSupportStatic    use_defaults=False

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"

	
CreateCloudlet with an invalid ipsupport enumeration 3
	[Documentation]   CreateCloudlet - Trys to create a cloudlet with an invalid ipsupport enumeration 3 
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...             Expect the test to fail as enumeration 3 is not used and will give an error.
	${supp}    Convert To Integer 	3
	${error_msg}=  Run Keyword And Expect Error  *  Create Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}     number_of_dynamic_ips=default    latitude=35     longitude=-96   ipsupport=${supp}     use_defaults=False

	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"