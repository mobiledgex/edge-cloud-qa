*** Settings ***
#Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         String

Test Teardown  Cleanup Provisioning

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}   dmuus
${cldlet}   tmocloud-1 
${dips}    254
${region}=  US

*** Test Cases ***
# ECQ-935
UpdateCloudlet without an operator
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet without an operator name
	...  The test case will try and update a Cloudlet with only the cloudlet name.
	...  An Invalid opereator name error is expected

#        [Setup]  Setup

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  cloudlet_name=${cldlet}    use_defaults=False

        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid organization name"}')
	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Key not found"
        #Should Contain  ${error_msg}   details = "Invalid organization name"

        [Teardown]  Cleanup provisioning

# ECQ-936
UpdateCloudlet with an invalid operator
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid operator name
	...  The test case will try and update a Cloudlet with a valid cloudlet name and in invalid operator name.
	...  A Key not found error is expected

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=mci      cloudlet_name=${cldlet}    use_defaults=False

        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"mci\\\\",\\\\"name\\\\":\\\\"${cldlet}\\\\"} not found"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Cloudlet key {"organization":"mci","name":"${cldlet}"} not found" 

# ECQ-937
UpdateCloudlet without a cloudlet name
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet without a cloudlet name
	...  The test case will try and update a Cloudlet with only the operator name.
	...  An Invalid cloudlet name error is expected

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}   operator_org_name=${oper}     use_defaults=False

        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid cloudlet name"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Key not found"
        #Should Contain  ${error_msg}   details = "Invalid cloudlet name"

# ECQ-938
UpdateCloudlet with an invalid cloudlet name
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet name
	...  The test case will try and update a Cloudlet with an invalid cloudlet name.
	...  A Key not found error is expected

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}   cloudlet_name=TestMe    use_defaults=False

        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"${oper}\\\\",\\\\"name\\\\":\\\\"TestMe\\\\"} not found"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Cloudlet key {"organization":"${oper}","name":"TestMe"} not found" 

# ECQ-939
UpdateCloudlet with a numdynamicips 0
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet number of dynamic ips value
	...  The test case will try and update a Cloudlet with an invalid number of dynamic ips (0).
	...  A 'Cannot specify less than one dynamic IP unless Ip Support Static is specified' error is expected

	${dips}  Convert To Integer 	0

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    number_dynamic_ips=${dips}    use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot specify less than one dynamic IP unless Ip Support Static is specified"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Cannot specify less than one dynamic IP unless Ip Support Static is specified"
	
# ECQ-940	
UpdateCloudlet with a numdynamicips -1
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet number of dynamic ips value
	...  The test case will try and update a Cloudlet with an invalid number of dynamic ips (-1).
	...  A 'Cannot specify less than one dynamic IP unless Ip Support Static is specified' error is expected

	${dips}    Convert To Integer 	-1

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    number_dynamic_ips=${dips}      use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cannot specify less than one dynamic IP unless Ip Support Static is specified"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Cannot specify less than one dynamic IP unless Ip Support Static is specified"

# ECQ-941
UpdateCloudlet with a numdynamicips A
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet number of dynamic ips value
	...  The test case will try and update a Cloudlet with an invalid number of dynamic ips (A).
	...  TypeError: 'A' has type str, but expected one of: int, long   error is expected


	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    number_dynamic_ips=A        use_defaults=False

	Should Contain Any  ${error_msg}   ValueError: invalid literal for int() with base 10: 'A'  TypeError: 'A' has type str, but expected one of: int, long    TypeError: 'A' has type <class 'str'>, but expected one of: (<class 'int'>,) for field Cloudlet.num_dynamic_ips
        #Should Contain  ${error_msg}   TypeError: 'A' has type <class 'str'>, but expected one of: (<class 'int'>,) for field Cloudlet.num_dynamic_ips

# ECQ-942
UpdateCloudlet with a numdynamicips 2323232232323
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet number of dynamic ips value
	...  The test case will try and update a Cloudlet with an invalid number of dynamic ips (2323232232323).
	...  ValueError: Value out of range: 2323232232323  error is expected

	#${dips}    Convert To Integer 	2323232232323

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    number_dynamic_ips=2323232232323        use_defaults=False

	Should Contain  ${error_msg}   Invalid data: code=400, message=Unmarshal type error: expected=int32, got=number 2323232232323, field=Cloudlet.num_dynamic_ips, offset=101

# ECQ-943
UpdateCloudlet with a ipsupport of -1
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet ipsupport value
	...  The test case will try and update a Cloudlet with an invalid ipsupport (-1).
	...  An 'invalid IpSupport' error is expected

        #[Setup]   Setup

	${ipsup}    Convert To Integer 	-1

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    ip_support=${ipsup}      use_defaults=False             
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid IpSupport"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid IpSupport"
       
        #[Teardown]  Cleanup provisioning

# ECQ-944 
UpdateCloudlet with a ipsupport of -8
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet ipsupport value
	...  The test case will try and update a Cloudlet with an invalid ipsupport (-8).
	...  An 'invalid IpSupport' error is expected

	${ipsup}    Convert To Integer 	-8

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    ip_support=${ipsup}        use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid IpSupport"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid IpSupport"

# ECQ-945
UpdateCloudlet with a location of 0 0 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of 0 0.
	...  A 'location is missing; 0,0 is not a valid location' error is expected

	#[Setup]  Setup

	${locat}    Convert To Integer 	0

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}      cloudlet_name=${cldlet}      latitude=${locat}      longitude=${locat}       use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid latitude value"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid latitude value"

	#[Teardown]  Cleanup provisioning

# ECQ-946
UpdateCloudlet with a location of 100 200 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of 100 200.
	...  A 'Invalid latitude value' error is expected

        #[Setup]  Setup

	${lat}    Convert To Integer 	100
	${long}    Convert To Integer 	200

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}      cloudlet_name=${cldlet}      latitude=${lat}      longitude=${long}       use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid latitude value"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid latitude value"

        #[Teardown]  Cleanup provisioning

# ECQ-1009
UpdateCloudlet with a location of 90 200 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of 90 200.
	...  A 'Invalid longitude value' error is expected

        #[Setup]  Setup
        #[Teardown]  Cleanup provisioning

	${lat}    Convert To Integer 	90
	${long}    Convert To Integer 	200

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}      cloudlet_name=${cldlet}      latitude=${lat}      longitude=${long}       use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid longitude value"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid longitude value"

# ECQ-947
UpdateCloudlet with a location of -100 -200 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of -100 -200.
	...  A 'Invalid latitude value' error is expected

        #[Setup]  Setup
        #[Teardown]  Cleanup provisioning

	${lat}    Convert To Integer 	-100
	${long}    Convert To Integer 	-200

	${error_msg}=  Run Keyword And Expect Error  *   Update Cloudlet  region=${region}  operator_org_name=${oper}      cloudlet_name=${cldlet}      latitude=${lat}      longitude=${long}       use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid latitude value"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid latitude value"

# ECQ-1010
UpdateCloudlet with a location of -90 -200 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of -90 -200.
	...  A 'Invalid longitude value' error is expected

        #[Setup]  Setup
        #[Teardown]  Cleanup provisioning

	${lat}    Convert To Integer 	-90
	${long}    Convert To Integer 	-200

	${error_msg}=  Run Keyword And Expect Error  *   Update Cloudlet  region=${region}   operator_org_name=${oper}      cloudlet_name=${cldlet}      latitude=${lat}      longitude=${long}       use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid longitude value"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid longitude value"

# ECQ-948
UpdateCloudlet with a location of A A 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
	...  The test case will try and update a Cloudlet with an invalid location lat and long of A A.
	...  A 'location is missing; 0,0 is not a valid location' error is expected

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	  region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    latitude=A    longitude=A         use_defaults=False
	Should Contain  ${error_msg}   ValueError: could not convert string to float: 'A'

# no longer supported
# ECQ-949
#UpdateCloudlet with accessuri of 6 
#	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet accessuri value
#	...  The test case will try and update a Cloudlet with an invalid accessuri of 6.
#	...  A 'TypeError: 6 has type int, but expected one of: bytes, unicode' error is expected
#  
#        #[Setup]  Setup
#        #[Teardown]  Cleanup provisioning
#
#	${accessuri}    Convert To Integer 	6
#
#	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	  region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    access_uri=${accessuri}       use_defaults=False
#	Should Contain Any  ${error_msg}   TypeError: 6 has type int, but expected one of: bytes, unicode    TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.access_credentials
#        #Should Contain  ${error_msg}  TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.access_uri

# ECQ-950
UpdateCloudlet with staticips of 6 
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet staticips value
	...  The test case will try and update a Cloudlet with an invalid staticips of 6.
	...  A 'TypeError: 6 has type int, but expected one of: bytes, unicode' error is expected

	${staticips}    Convert To Integer 	6

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	  region=${region}  operator_org_name=${oper}     cloudlet_name=${cldlet}     static_ips=${staticips}       use_defaults=False
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid data: code=400, message=Unmarshal type error: expected=string, got=number, field=Cloudlet.static_ips, offset=84"}')
	#Should Contain Any  ${error_msg}   TypeError: 6 has type int, but expected one of: bytes, unicode    TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.static_ips 
        #Should Contain  ${error_msg}  TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.static_ips

# ECQ-3068
UpdateCloudlet with invalid maintenance mode 
        [Documentation]
        ...  - send UpdateCloudlet with invalid maintenance mode 
        ...  - verify correct error is received 

        ${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet  region=${region}  operator_org_name=${oper}     cloudlet_name=${cldlet}     maintenance_state=999      use_defaults=False
        Should Be Equal  ${error_msg}   ('code=400', 'error={"message":"Invalid maintenance state, only normal operation and maintenance start states are allowed"}')

# ECQ-3069
UpdateCloudlet with unknown trust policy
   [Documentation]
   ...  - send UpdateCloudlet with trust policy
   ...  - verify correct error is received

   [Tags]  TrustPolicy

   ${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet  region=${region}  operator_org_name=${oper}     cloudlet_name=${cldlet}     trust_policy=999      use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"TrustPolicy 999 for organization ${oper} not found"}') 

# ECQ-3095
UpdateCloudlet - error shall be received for update to trusted with nontrusted app
   [Documentation]
   ...  - create a trust policy
   ...  - send CreateCloudlet without policy
   ...  - create a non-trusted app/appinst on the cloudlet
   ...  - send UpdateCloudlet with trust policy
   ...  - verify error is received

   [Tags]  TrustPolicy

   Create Flavor  region=${region}

   ${policy_name}=  Get Default Trust Policy Name
   ${app_name}=  Get Default App Name

   # create a trust policy
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}
   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${oper}
   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${oper}
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   # create cloudlet without trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${oper}
   Should Not Contain  ${cloudlet['data']}  trust_policy
   Should Be Equal As Numbers  ${cloudlet['data']['trust_policy_state']}  1

   # create a trusted app/appinst on the cloudlet
   ${app}=  Create App  region=${region}  trusted=${True}
   ${appinst}=  Create App Instance  region=${region}  operator_org_name=${oper}  cluster_instance_name=autocluster${policy_name}

   # update cloudlet with trust policy and remove the policy
   Update Cloudlet  region=${region}  operator_org_name=${oper}  trust_policy=${policy_name}
   Update Cloudlet  region=${region}  operator_org_name=${oper}  trust_policy=${Empty}

   # create a nontrusted app/appinst on the cloudlet
   ${app}=  Create App  region=${region}  app_name=${app_name}_untrusted
   ${appinst}=  Create App Instance  region=${region}  operator_org_name=${oper}  cluster_instance_name=autocluster${policy_name}

   # update cloudlet with trust policy
   ${error}=  Run Keyword and Expect Error  *  Update Cloudlet  region=${region}  operator_org_name=${oper}  trust_policy=${policy_name}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Non trusted app: organization:\\\\"MobiledgeX\\\\" name:\\\\"${app['data']['key']['name']}\\\\" version:\\\\"1.0\\\\" not compatible with trust policy: organization:\\\\"${oper}\\\\" name:\\\\"${policy_name}\\\\" "}')

# ECQ-3098
UpdateCloudlet - update with trust policy on non-openstack shall return error
   [Documentation]
   ...  - send UpdateCloudlet with trust policy with non-openstack platforms
   ...  - verify error is returned

   [Tags]  TrustPolicy

   # fixed EDGECLOUD-4220 - able to do UpdateCloudlet with trustpolicy on azure/gcp cloudlet 

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  operator_org_name=azure  rule_list=${rulelist}
   Create Flavor  region=US

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_AZURE"}')   Update Cloudlet  region=US  cloudlet_name=automationAzureCentralCloudlet  operator_org_name=azure  trust_policy=${policy_return['data']['key']['name']}  use_defaults=${False}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_GCP"}')     Update Cloudlet  region=US  cloudlet_name=automationGcpCentralCloudlet  operator_org_name=gcp  trust_policy=${policy_return['data']['key']['name']}  use_defaults=${False}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_VM_POOL"}')     Update Cloudlet  region=EU  cloudlet_name=automationVMPoolCloudlet  operator_org_name=GDDT  trust_policy=${policy_return['data']['key']['name']}  use_defaults=${False}

*** Keywords ***
Setup
	${dips}    Convert To Integer     254

        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

        Sleep  1s

	Create Cloudlet     operator_org_name=${oper}   cloudlet_name=${cldlet}     number_dynamic_ips=${dips}    latitude=35     longitude=-96  notify_server_address=${port}  use_defaults=False 
	Cloudlet Should Exist

        Set Suite Variable  ${cldlet}
