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

	Run Keyword And Expect Error  ('code=400', 'error={"message":"Org mcixx not found"}')  Create Cloudlet	cloudlet_name=${cldlet}  region=${region}   token=${token}    operator_org_name=mcixx     number_dynamic_ips=2      latitude=35.0     longitude=-96.0    use_defaults=False

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

   [Tags]  TrustPolicy

    ${epoch}=  Get Time  epoch
    ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}

    Run Keyword And Expect Error  ('code=200', 'error={"result":{"message":"TrustPolicy x for organization ${oper} not found","code":400}}')  Create Cloudlet  region=${region}  operator_org_name=${oper}  cloudlet_name=${cldlet}  number_dynamic_ips=5  latitude=35  longitude=-96  trust_policy=x

# ECQ-3031
CreateCloudlet - create with trust policy on non-openstack shall return error
   [Documentation]
   ...  - send CreateCloudlet with trust policy  with non-openstack platforms
   ...  - verify error is returned

   [Tags]  TrustPolicy

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  operator_org_name=${oper}  rule_list=${rulelist}
   Create Flavor  region=US

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_AZURE"}')    Create Cloudlet  region=US  platform_type=PlatformTypeAzure  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_GCP"}')      Create Cloudlet  region=US  platform_type=PlatformTypeGCP  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_EDGEBOX"}')  Create Cloudlet  region=US  platform_type=PlatformTypeEdgebox  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_VSPHERE"}')  Create Cloudlet  region=US  platform_type=PlatformTypeVsphere  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_AWS_EKS"}')  Create Cloudlet  region=US  platform_type=PlatformTypeAwsEks  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_AWS_EC2"}')  Create Cloudlet  region=US  platform_type=PlatformTypeAwsEc2  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}

   Create VM Pool  region=${region}  vm_pool_name=${policy_return['data']['key']['name']}_pool  org_name=${oper}  #use_defaults=False
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_VM_POOL"}')  Create Cloudlet  region=US  platform_type=PlatformTypeVmPool  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}  vm_pool=${policy_return['data']['key']['name']}_pool

# ECQ-3358
CreateCloudlet - create with developer org shall return error
   [Documentation]
   ...  - create developer org
   ...  - send CreateCloudlet with developer org
   ...  - verify error is returned

   ${org}=  Create Org  orgtype=developer

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Operation only allowed for organizations of type operator"}')    Create Cloudlet  region=US  operator_org_name=${org}  latitude=1  longitude=1  number_dynamic_ips=1 

# ECQ-3503
CreateCloudlet - create with kafka user/password but no cluster shall return error
   [Documentation]
   ...  - send CreateCloudlet with kafka user/password but no cluster
   ...  - verify error is returned

   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Must specify a kafka cluster endpoint in addition to kafka credentials","code":400}}')  Create Cloudlet  region=US  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  kafka_user=x  kafka_password=x

# ECQ-3567
CreateCloudlet - create without both kafka user and password shall return error
   [Documentation]
   ...  - send CreateCloudlet without both kafka both user and password
   ...  - verify error is returned

   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Must specify both kafka username and password, or neither","code":400}}')  Create Cloudlet  region=US  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  kafka_password=x
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Must specify both kafka username and password, or neither","code":400}}')  Create Cloudlet  region=US  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  kafka_user=x
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Must specify both kafka username and password, or neither","code":400}}')  Create Cloudlet  region=US  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  kafka_user=x  kafka_cluster=x
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Must specify both kafka username and password, or neither","code":400}}')  Create Cloudlet  region=US  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  kafka_password=x  kafka_cluster=x

# ECQ-3971
CreateCloudlet - create with developer alliance org shall return error
   [Documentation]
   ...  - send CreateCloudlet with alliance developer org
   ...  - verify error is returned

   [Tags]  AllianceOrg

   @{alliance_list}=  Create List  automation_dev_org
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Operation only allowed for organizations of type operator"}')    Create Cloudlet  region=US  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  alliance_org_list=${alliance_list}  token=${token}

   @{alliance_list}=  Create List  dmuus  automation_dev_org
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Operation only allowed for organizations of type operator"}')    Create Cloudlet  region=US  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  alliance_org_list=${alliance_list}  token=${token}

# ECQ-3972
CreateCloudlet - create with unknown alliance org shall return error
   [Documentation]
   ...  - send CreateCloudlet with alliance org of org that doesnt exist
   ...  - verify error is returned

   [Tags]  AllianceOrg

   @{alliance_list}=  Create List  notknown
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Org notknown not found"}')    Create Cloudlet  region=US  operator_org_name=${oper}  latitude=1  longitude=1  number_dynamic_ips=1  alliance_org_list=${alliance_list}  token=${token}

** Keywords **
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

