*** Settings ***
#Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         String
Library  DateTime

Test Teardown  Cleanup Provisioning

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}   tmus
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

	#Should Contain  ${error_msg}   Invalid data: Unmarshal type error: expected=int32, got=number 2323232232323, field=Cloudlet.num_dynamic_ips, offset=101
        Should Contain  ${error_msg}  Invalid JSON data: Unmarshal error: expected int32, but got number 2323232232323 for field \\\\"Cloudlet.num_dynamic_ips\\\\" at offset 101

# ECQ-943
UpdateCloudlet with a ipsupport of -1
	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet ipsupport value
	...  The test case will try and update a Cloudlet with an invalid ipsupport (-1).
	...  An 'invalid IpSupport' error is expected

        #[Setup]   Setup

	${ipsup}    Convert To Integer 	-1

	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}   cloudlet_name=${cldlet}    ip_support=${ipsup}      use_defaults=False             
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected IpSupport, but got value -1 for field \\\\"Cloudlet.ip_support\\\\", valid values are one of Unknown, Static, Dynamic, or 0, 1, 2"}')

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
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected IpSupport, but got value -8 for field \\\\"Cloudlet.ip_support\\\\", valid values are one of Unknown, Static, Dynamic, or 0, 1, 2"}')

	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Invalid IpSupport"

# we now support 0,0
# ECQ-945
#UpdateCloudlet with a location of 0 0 
#	[Documentation]   UpdateCloudlet -  Trys to update a cloudlet with an invalid cloudlet location value
#	...  The test case will try and update a Cloudlet with an invalid location lat and long of 0 0.
#	...  A 'location is missing; 0,0 is not a valid location' error is expected
#
#	#[Setup]  Setup
#
#	${locat}    Convert To Integer 	0
#
#	${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet	 region=${region}  operator_org_name=${oper}      cloudlet_name=${cldlet}      latitude=${locat}      longitude=${locat}       use_defaults=False
#        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid latitude value"}')
#
#	#Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
#	#Should Contain  ${error_msg}   details = "Invalid latitude value"
#
#	#[Teardown]  Cleanup provisioning

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
        Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected string, but got number for field \\\\"Cloudlet.static_ips\\\\" at offset 84"}')
        #Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=string, got=number, field=Cloudlet.static_ips, offset=84"}')
	#Should Contain Any  ${error_msg}   TypeError: 6 has type int, but expected one of: bytes, unicode    TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.static_ips 
        #Should Contain  ${error_msg}  TypeError: 6 has type <class 'int'>, but expected one of: (<class 'bytes'>, <class 'str'>) for field Cloudlet.static_ips

# ECQ-3068
UpdateCloudlet with invalid maintenance mode 
        [Documentation]
        ...  - send UpdateCloudlet with invalid maintenance mode 
        ...  - verify correct error is received 

        ${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet  region=${region}  operator_org_name=${oper}     cloudlet_name=${cldlet}     maintenance_state=999      use_defaults=False
        Should Be Equal  ${error_msg}   ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected MaintenanceState, but got value 999 for field \\\\"Cloudlet.maintenance_state\\\\", valid values are one of NormalOperation, MaintenanceStart, FailoverRequested, FailoverDone, FailoverError, MaintenanceStartNoFailover, CrmRequested, CrmUnderMaintenance, CrmError, NormalOperationInit, UnderMaintenance, or 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 31"}')

# ECQ-3069
UpdateCloudlet with unknown trust policy
   [Documentation]
   ...  - send UpdateCloudlet with trust policy
   ...  - verify correct error is received

   [Tags]  TrustPolicy

   ${error_msg}=  Run Keyword And Expect Error  *  Update Cloudlet  region=${region}  operator_org_name=${oper}     cloudlet_name=${cldlet}     trust_policy=999      use_defaults=False
   #Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"TrustPolicy 999 for organization ${oper} not found"}') 
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"${oper}\\\\",\\\\"name\\\\":\\\\"999\\\\"} not found"}')

# ECQ-3095
UpdateCloudlet - error shall be received for update to trusted with nontrusted app
   [Documentation]
   ...  - create a trust policy
   ...  - send CreateCloudlet without policy
   ...  - create a non-trusted app/appinst on the cloudlet
   ...  - send UpdateCloudlet with trust policy
   ...  - verify error is received

   [Tags]  TrustPolicy

   ${epoch}=  Get Current Date  result_format=epoch
   ${cloudlet_name}=  Set Variable  cloudlet${epoch}

   Create Flavor  region=${region}

   ${policy_name}=  Get Default Trust Policy Name
   ${app_name}=  Get Default App Name

   # create a trust policy
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}
   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${oper}
   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${oper}
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        UDP
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   # create cloudlet without trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${oper}
   Should Not Contain  ${cloudlet['data']}  trust_policy
   Should Be Equal     ${cloudlet['data']['trust_policy_state']}  NotPresent

   # create a trusted app/appinst on the cloudlet
   ${app}=  Create App  region=${region}  trusted=${True}
   ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${oper}  cluster_instance_name=autocluster${policy_name}

   # update cloudlet with trust policy and remove the policy
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${oper}  trust_policy=${policy_name}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${oper}  trust_policy=${Empty}

   # create a nontrusted app/appinst on the cloudlet
   ${app}=  Create App  region=${region}  app_name=${app_name}_untrusted
   ${appinst}=  Create App Instance  region=${region}  operator_org_name=${oper}  cluster_instance_name=autocluster${policy_name}

   # update cloudlet with trust policy
   ${error}=  Run Keyword and Expect Error  *  Update Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${oper}  trust_policy=${policy_name}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Non trusted app: organization:\\\\"automation_dev_org\\\\" name:\\\\"${app['data']['key']['name']}\\\\" version:\\\\"1.0\\\\" not compatible with trust policy: organization:\\\\"${oper}\\\\" name:\\\\"${policy_name}\\\\" "}')

# ECQ-3393
UpdateCloudlet - error shall be received for update to trusted with trusted app and mismatched policy
   [Documentation]
   ...  - create a trust policy
   ...  - send CreateCloudlet without policy
   ...  - create a trusted app/appinst on the cloudlet
   ...  - send UpdateCloudlet with trust policy that doesnt match the app required connections
   ...  - verify error is received

   [Tags]  TrustPolicy

   ${epoch}=  Get Current Date  result_format=epoch
   ${cloudlet_name}=  Set Variable  cloudlet${epoch}

   Create Flavor  region=${region}

   ${policy_name}=  Get Default Trust Policy Name
   ${app_name}=  Get Default App Name

   # create a trust policy
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}
   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${oper}
   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${oper}
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        UDP
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   # create cloudlet without trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${oper}
   Should Not Contain  ${cloudlet['data']}  trust_policy
   Should Be Equal     ${cloudlet['data']['trust_policy_state']}  NotPresent

   # create a trusted app/appinst on the cloudlet
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1000  port_range_maximum=1000  remote_cidr=3.1.1.1/1
   @{tcp1_rulelist}=  Create List  ${rule1}
   ${app}=  Create App  region=${region}
   ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${oper}  cluster_instance_name=autocluster${policy_name}
   ${appt}=  Update App  region=${region}  trusted=${True}  required_outbound_connections_list=${tcp1_rulelist}

   # update cloudlet with trust policy
   ${error}=  Run Keyword and Expect Error  *  Update Cloudlet  cloudlet_name=${cloudlet['data']['key']['name']}  region=${region}  operator_org_name=${oper}  trust_policy=${policy_name}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"No outbound rule in policy or exception to match required connection UDP:3.1.1.1/1:1000-1000 for App {\\\\"organization\\\\":\\\\"automation_dev_org\\\\",\\\\"name\\\\":\\\\"${app['data']['key']['name']}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"}"}')

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

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Trust Policy not supported on PLATFORM_TYPE_VM_POOL"}')     Update Cloudlet  region=US  cloudlet_name=automationVMPoolCloudlet  operator_org_name=TDG  trust_policy=${policy_return['data']['key']['name']}  use_defaults=${False}

# ECQ-3480
UpdateCloudlet - update to maintenance mode when already in maintenance mode shall return error
   [Documentation]
   ...  - put cloudlet in maintenance mode
   ...  - send UpdateCloudlet with MaintenanceStart and MaintenanceStartNoFailover
   ...  - verify error is returned

   Create Org  orgtype=operator
   RestrictedOrg Update
   ${cloudlet}=  Create Cloudlet  region=${region}

   Sleep  1s

   ${ret}=  Update Cloudlet  region=${region}  operator_org_name=${cloudlet['data']['key']['organization']}  cloudlet_name=${cloudlet['data']['key']['name']}  maintenance_state=MaintenanceStart  use_defaults=False

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cloudlet must be in NormalOperation before starting maintenance"}')  Update Cloudlet  region=${region}  operator_org_name=${cloudlet['data']['key']['organization']}  cloudlet_name=${cloudlet['data']['key']['name']}  maintenance_state=MaintenanceStart  use_defaults=False

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cloudlet must be in NormalOperation before starting maintenance"}')  Update Cloudlet  region=${region}  operator_org_name=${cloudlet['data']['key']['organization']}  cloudlet_name=${cloudlet['data']['key']['name']}  maintenance_state=MaintenanceStartNoFailover  use_defaults=False

# ECQ-3973
UpdateCloudlet - update with developer alliance org shall return error
   [Documentation]
   ...  - send CreateCloudlet
   ...  - send UpdateCloudlet with alliance developer org
   ...  - verify error is returned

   [Tags]  AllianceOrg

   [Teardown]  Cleanup provisioning

   Create Org  orgtype=operator
   RestrictedOrg Update
   ${cloudlet}=  Create Cloudlet  region=${region}

   @{alliance_list}=  Create List  automation_dev_org
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Operation only allowed for organizations of type operator"}')    Update Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}   alliance_org_list=${alliance_list}

   @{alliance_list}=  Create List  tmus  automation_dev_org
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Operation only allowed for organizations of type operator"}')    Update Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}   alliance_org_list=${alliance_list}

# ECQ-3974
UpdateCloudlet - update with unknown alliance org shall return error
   [Documentation]
   ...  - send CreateCloudlet
   ...  - send UpdateCloudlet with alliance org that doenst exist
   ...  - verify error is returned

   [Tags]  AllianceOrg

   [Teardown]  Cleanup provisioning

   Create Org  orgtype=operator
   RestrictedOrg Update
   ${cloudlet}=  Create Cloudlet  region=${region}

   @{alliance_list}=  Create List  notknown
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Org notknown not found"}')    Update Cloudlet  region=US  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}    alliance_org_list=${alliance_list}

# ECQ-4007
UpdateCloudlet - update with duplicate alliance org shall return error
   [Documentation]
   ...  - send CreateCloudlet
   ...  - send UpdateCloudlet with same alliance org twice
   ...  - verify error is returned

   [Tags]  AllianceOrg

   [Teardown]  Cleanup provisioning

   Create Org  orgtype=operator
   RestrictedOrg Update
   ${cloudlet}=  Create Cloudlet  region=${region}

   @{alliance_list}=  Create List  packet  packet
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Duplicate alliance org \\\\"packet\\\\" specified"}')    Update Cloudlet  region=US  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}    alliance_org_list=${alliance_list}

# ECQ-4011
UpdateCloudlet - update with same alliance org as own org shall return error
   [Documentation]
   ...  - send CreateCloudlet
   ...  - send UpdateCloudlet with same alliance org as its own operator org
   ...  - verify error is returned

   [Tags]  AllianceOrg

   [Teardown]  Cleanup provisioning

   Create Org  orgtype=operator
   RestrictedOrg Update
   ${cloudlet}=  Create Cloudlet  region=${region}

   @{alliance_list}=  Create List  ${cloudlet['data']['key']['organization']}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cannot add cloudlet\\'s own org \\\\"${cloudlet['data']['key']['organization']}\\\\" as alliance org"}')    Update Cloudlet  region=US  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${cloudlet['data']['key']['organization']}    alliance_org_list=${alliance_list}

*** Keywords ***
Setup
	${dips}    Convert To Integer     254

        ${epoch}=  Get Current Date  result_format=epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

        Sleep  1s

	Create Cloudlet     operator_org_name=${oper}   cloudlet_name=${cldlet}     number_dynamic_ips=${dips}    latitude=35     longitude=-96  notify_server_address=${port}  use_defaults=False 
	Cloudlet Should Exist

        Set Suite Variable  ${cldlet}
