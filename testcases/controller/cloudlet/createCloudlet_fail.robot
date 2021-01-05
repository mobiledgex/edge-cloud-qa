*** Settings ***
#Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Cleanup provisioning

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}  CreatTest
${region}=  US

*** Test Cases ***
# ECQ-909
CreateCloudlet without an operator
	[Documentation]   CreateCloudlet - Tries to create a cloudlet without an operator
	...  Trys to create a cloudlet without an operator
	...  Expect the create to fail with the operator not found error

	Run Keyword And Expect Error  ('code=200', 'error={"result":{"message":"Invalid organization name","code":400}}')   Create Cloudlet  region=${region}   token=${token}  cloudlet_name=${cldlet}     number_dynamic_ips=2      latitude=35.0     longitude=-96.0    use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid organization name"

# ECQ-910	
CreateCloudlet with an invalid operator
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with an invalid operator
	...  Trys to create a cloudlet with an invalid operator
	...  Expect the create to fail with the operator not found drror

        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Run Keyword And Expect Error  ('code=400', 'error={"message":"org mcixx not found"}')  Create Cloudlet	cloudlet_name=${cldlet}  region=${region}   token=${token}    operator_org_name=mcixx     number_dynamic_ips=2      latitude=35.0     longitude=-96.0    use_defaults=False

	#[Teardown]	Cleanup provisioning

# ECQ-911	
CreateCloudlet without a name
	[Documentation]   CreateCloudlet - Tries to create a cloudlet without a cloudlet name
	...  Trys to create a cloudlet without a cloudlet name
	...  Expect the create to fail with the invalid name error

	Run Keyword And Expect Error  ('code=200', 'error={"result":{"message":"Invalid cloudlet name","code":400}}')   Create Cloudlet  region=${region}   token=${token}  operator_org_name=${oper}      number_dynamic_ips=2      latitude=35.0     longitude=-96.0     use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid cloudlet name"

# ECQ-1065	
CreateCloudlet without a location
	[Documentation]   CreateCloudlet - Tries to create a cloudlet without a location 
	...  This tests case will not set the location for the cloudlet and should be rejected.
	...  Expect the test case to fail with loacation can not be 0 0 error
	
	Run Keyword And Expect Error  ('code=400', 'error={"message":"Location is missing; 0,0 is not a valid location"}')  Create Cloudlet	 region=${region}  token=${token}     operator_org_name=${oper}      cloudlet_name=${cldlet}     number_dynamic_ips=2     use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Location is missing; 0,0 is not a valid location"

# ECQ-912
CreateCloudlet with a location of 0 0
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of 0 0
	...  This tests case will set the location to 0 0 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with loacation can not be 0 0 error
	
	Run Keyword And Expect Error  ('code=400', 'error={"message":"Location is missing; 0,0 is not a valid location"}')  Create Cloudlet	 region=${region}  token=${token}     operator_org_name=${oper}      cloudlet_name=${cldlet}     number_dynamic_ips=2     latitude=0      longitude=0    use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Location is missing; 0,0 is not a valid location"

# ECQ-913
CreateCloudlet with a location of 100 200
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of 100 200
	...  This tests case will set the location to 100 200 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with an Invalid latitude value error
	
	Run Keyword And Expect Error  ('code=200', 'error={"result":{"message":"Invalid latitude value","code":400}}')  Create Cloudlet	 region=${region}  token=${token}     operator_org_name=${oper}      cloudlet_name=${cldlet}     number_dynamic_ips=2     latitude=100      longitude=200    use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid latitude value"

# ECQ-1007
CreateCloudlet with a location of 90 200
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of 90 200
	...  This tests case will set the location to 90 200 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with an Invalid longitude value error
	
	Run Keyword And Expect Error  ('code=200', 'error={"result":{"message":"Invalid longitude value","code":400}}')  Create Cloudlet	 region=${region}  token=${token}     operator_org_name=${oper}      cloudlet_name=${cldlet}     number_dynamic_ips=2     latitude=90      longitude=200    use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid longitude value"

# ECQ-914
CreateCloudlet with a location of -100 -200
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of -100 -200
	...  This tests case will set the location to -100 -200 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with an Invalid latitude value error
	
	Run Keyword And Expect Error  ('code=200', 'error={"result":{"message":"Invalid latitude value","code":400}}')  Create Cloudlet	 region=${region}  token=${token}     operator_org_name=${oper}      cloudlet_name=${cldlet}     number_dynamic_ips=2     latitude=-100      longitude=-200    use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid latitude value"

# ECQ-1008
CreateCloudlet with a location of -90 -200
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with location of -90 -200
	...  This tests case will set the location to -90 -200 which is concedered to be default and should be rejected.
	...  Expect the test case to fail with an Invalid longitude value error
	
	Run Keyword And Expect Error  ('code=200', 'error={"result":{"message":"Invalid longitude value","code":400}}')  Create Cloudlet	 region=${region}  token=${token}     operator_org_name=${oper}      cloudlet_name=${cldlet}     number_dynamic_ips=2     latitude=90      longitude=200    use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid longitude value"

# ECQ-915
CreateCloudlet with numdynamic set to 0
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with numdynamicIPS of 0
	...  You must have at least 1 dynamic IPS, this test case will set the value to 0
	...  Expect the create to fail with  
	
	${dips}  Convert To Integer 	0
	
	Run Keyword And Expect Error   ('code=400', 'error={"message":"Must specify at least one dynamic public IP available"}')  Create Cloudlet  region=${region}  token=${token}   operator_org_name=${oper}    cloudlet_name=${cldlet}      number_dynamic_ips=${dips}     latitude=35.0     longitude=-96.0    use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Must specify at least one dynamic public IP available"

# ECQ-916
CreateCloudlet with an invalid ipsupport enumeration -1
    [Documentation]   CreateCloudlet - Tries to create a cloudlet with an invalid ipsupport enumeration -1
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...            Expect the test to fail as enumeration -1 is not used and will give an error.
	
	${supp}    Convert To Integer 	-1
	
	Run Keyword And Expect Error  ('code=400', 'error={"message":"Only dynamic IPs are supported currently"}')   Create Cloudlet	 region=${region}  token=${token}   operator_org_name=${oper}    cloudlet_name=${cldlet}     number_dynamic_ips=2    latitude=35     longitude=-96   ip_support=${supp}   use_defaults=False
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"

# ECQ-917
CreateCloudlet with an invalid ipsupport IPSupportStatic
    [Documentation]   CreateCloudlet - Tries to create a cloudlet with an invalid ipsupport IPSupportStatic
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...             IpSupportStatic (1) is not supported at this time and will give an error.
	
    Run Keyword And Expect Error  ('code=400', 'error={"message":"Only dynamic IPs are supported currently"}')  Create Cloudlet  region=${region}  token=${token}  operator_org_name=${oper}    cloudlet_name=${cldlet}      number_dynamic_ips=2    latitude=35     longitude=-96   ip_support=IpSupportStatic    use_defaults=False

   #Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   #Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"

# ECQ-918	
CreateCloudlet with an invalid ipsupport enumeration 3
	[Documentation]   CreateCloudlet - Tries to create a cloudlet with an invalid ipsupport enumeration 3 
	...             IPSupport enumerations are:
	...                 IpSupportUnknown = 0
	...                 IpSupportStatic = 1
	...                 IpSupportDynamic = 2
	...             Expect the test to fail as enumeration 3 is not used and will give an error.
	${supp}    Convert To Integer 	3
	Run Keyword And Expect Error  ('code=400', 'error={"message":"Only dynamic IPs are supported currently"}')  Create Cloudlet	 region=${region}  token=${token}  operator_org_name=${oper}    cloudlet_name=${cldlet}     number_dynamic_ips=2    latitude=35     longitude=-96   ip_support=${supp}     use_defaults=False

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Only dynamic IPs are supported currently"

# ECQ-3067
CreateCloudlet - cloudlet should fail with unknown trust policy
    [Documentation]
    ...  - send CreateCloudlet with unknown trust policy
    ...  - verify correct error is received

    ${epoch}=  Get Time  epoch
    ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}

    Run Keyword And Expect Error  ('code=200', 'error={"result":{"message":"TrustPolicy x for organization ${oper} not found","code":400}}')  Create Cloudlet  region=${region}  operator_org_name=${oper}  cloudlet_name=${cldlet}  number_dynamic_ips=5  latitude=35  longitude=-96  trust_policy=x

** Keywords **
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

