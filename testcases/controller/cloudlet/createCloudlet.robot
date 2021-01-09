*** Settings ***
#Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         String

Test Setup      Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}  CreateTest
${region}  US

${operator_name_fake}=  tmus

*** Test Cases ***
# ECQ-904
CreateCloudlet with all parameters
	[Documentation]   CreateCloudlet - Creates a cloudlet with all of the parameters
	...  The test case creates a cloudlet with all valid parameters
	...  Expect the cloudlet to be created sucessfully

        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch} 
		
	#Create Cloudlet	 operator_name=${oper}   cloudlet_name=${cldlet}   number_of_dynamic_ips=default     latitude=35     longitude=-96     accesscredentials=https://support.sup.com/supersupport   ipsupport=IpSupportDynamic    staticips=30.30.30.1   
        ${cloudlet}=  Create Cloudlet  region=${region}       operator_org_name=${oper}   cloudlet_name=${cldlet}   number_dynamic_ips=256     latitude=35     longitude=-96  ip_support=IpSupportDynamic    static_ips=30.30.30.1

	#Cloudlet Should Exist   
 
        Should Be True  ${cloudlet['data']['created_at']['seconds']} > 0
        Should Be True  ${cloudlet['data']['created_at']['nanos']} > 0
        Should Be True  'updated_at' in ${cloudlet['data']} and 'seconds' not in ${cloudlet['data']['updated_at']} and 'nanos' not in ${cloudlet['data']['updated_at']}

# ECQ-905
CreateCloudlet without the optional parameters
	[Documentation]   CreateCloudlet - Creates a cloudlet without the optional parameters
	...  The test case creates a cloudlet without accessuri, ipsupport, and staticips.
	...  Expect the cloudlet to be created sucessfully. Ipsupport will be set to IpSupportDynamic by default

        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum} 

	${cloudlet}=  Create Cloudlet  region=${region}  token=${token}  operator_org_name=${oper}   cloudlet_name=${cldlet}    number_dynamic_ips=256    latitude=35     longitude=-96  notify_server_address=${port}   use_defaults=False
	#Cloudlet Should Exist   

        Should Be True  ${cloudlet['data']['created_at']['seconds']} > 0
        Should Be True  ${cloudlet['data']['created_at']['nanos']} > 0
        Should Be True  'updated_at' in ${cloudlet['data']} and 'seconds' not in ${cloudlet['data']['updated_at']} and 'nanos' not in ${cloudlet['data']['updated_at']}

# no longer support accessurl
# ECQ-906
#CreateCloudlet with required parameters and accessuri
#	[Documentation]   CreateCloudlet - Creates a cloudlet with required parameters and the optional accessuri parameter
#	...  The test case creates a cloudlet with required parameters and the optional accessuri parameter
#	...  Expect the cloudlet to be created sucessfully. Ipsupport will be set to IpSupportDynamic by default
#
#        ${epoch}=  Get Time  epoch
#        ${epochstring}=  Convert To String  ${epoch}
#
#        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
##
#        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
#        #${portnum}=  Get Substring  ${epochstring}  -5
#        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}
#
#	${cloudlet}=  Create Cloudlet  region=${region}  token=${token}   operator_org_name=${oper}   cloudlet_name=${cldlet}   number_dynamic_ips=default     latitude=35     longitude=-96     access_credentials=https://support.sup.com/supersupport  notify_server_address=${port}  use_defaults=False
#	#Cloudlet Should Exist   
#
#        Should Be True  ${cloudlet['data']['created_at']['seconds']} > 0
#        Should Be True  ${cloudlet['data']['created_at']['nanos']} > 0
#        Should Be True  'updated_at' in ${cloudlet['data']} and 'seconds' not in ${cloudlet['data']['updated_at']} and 'nanos' not in ${cloudlet['data']['updated_at']}

# ECQ-907
CreateCloudlet with required parameters and ipsupport
	[Documentation]   CreateCloudlet - Creates a cloudlet with required parameters and the ipsupport parameter
	...  The test case creates a cloudlet with required parameters and the ipsupport parameter
	...  Expect the cloudlet to be created sucessfully

        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	${cloudlet}=  Create Cloudlet  region=${region}  token=${token}   operator_org_name=${oper}   cloudlet_name=${cldlet}   number_dynamic_ips=256     latitude=35     longitude=-96       ip_support=IpSupportDynamic  notify_server_address=${port}  use_defaults=False
	#Cloudlet Should Exist   

        Should Be True  ${cloudlet['data']['created_at']['seconds']} > 0
        Should Be True  ${cloudlet['data']['created_at']['nanos']} > 0
        Should Be True  'updated_at' in ${cloudlet['data']} and 'seconds' not in ${cloudlet['data']['updated_at']} and 'nanos' not in ${cloudlet['data']['updated_at']}

# ECQ-908
CreateCloudlet with required parameters and staticips
		[Documentation]   CreateCloudlet - Creates a cloudlet with required parameters and the optional staticips parameter
	...  The test case creates a cloudlet with required parameters and the optional staticips parameter
	...  Expect the cloudlet to be created sucessfully. Ipsupport will be set to IpSupportDynamic by default

        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	${cloudlet}=  Create Cloudlet  region=${region}  token=${token}   operator_org_name=${oper}   cloudlet_name=${cldlet}   number_dynamic_ips=256     latitude=35     longitude=-96      static_ips=30.30.30.1  notify_server_address=${port}   use_defaults=False
	#Cloudlet Should Exist   

        Should Be True  ${cloudlet['data']['created_at']['seconds']} > 0
        Should Be True  ${cloudlet['data']['created_at']['nanos']} > 0
        Should Be True  'updated_at' in ${cloudlet['data']} and 'seconds' not in ${cloudlet['data']['updated_at']} and 'nanos' not in ${cloudlet['data']['updated_at']}

CreateCloudlet without physicalname 
        [Documentation]   
        ...  send CreateCloudlet without physical name 
        ...  verify physical name is set to cloudlet name 

        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}

        ${resp}=  Run Keyword and Expect Error  *  Create Cloudlet  region=${region}  token=${token}  operator_org_name=${oper}   cloudlet_name=${cldlet}   number_dynamic_ips=256     latitude=35     longitude=-96      static_ips=30.30.30.1  notify_server_address=5000  platform_type=PlatformTypeOpenstack  use_defaults=False

        #Should Contain  ${resp}  failed to get values for /secret/data/cloudlet/openstack/${cldlet}/openrc.json from Vault
        #Should Contain  ${resp}  Failed to source platform variables as physicalname '${cldlet}' is invalid
        #Should Contain  ${resp}   Failed to source access variables as '${oper}/${cldlet}' does not exist in secure secrets storage (Vault)"
        Should Contain  ${resp}   Failed to source access variables from \\'/secret/data/${region}/cloudlet/openstack/${oper}/${cldlet}/openrc.json\\', does not exist in secure secrets storage (Vault)"

# ECQ-3064
CreateCloudlet - shall be able to create cloudlet with trust policy
   [Documentation]
   ...  - send CreateTrustPolicy
   ...  - send CreateCloudlet witht the policy
   ...  - verify the cloudlet is assinged the policy

   Create Flavor  region=${region}

   ${policy_name}=  Get Default Trust Policy Name

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${operator_name_fake}

   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${policy_return['data']['key']['name']}
   Should Be Equal             ${cloudlet['data']['trust_policy']}  ${policy_return['data']['key']['name']}
   Should Be Equal As Numbers  ${cloudlet['data']['trust_policy_state']}  5

# ECQ-3091
CreateCloudlet - shall be able to create cloudlet with empty trust policy
   [Documentation]
   ...  - send CreateCloudlet with empty trust policy
   ...  - verify the cloudlet is not assinged a policy

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${Empty}
   Should Not Contain  ${cloudlet['data']}  trust_policy
   Should Be Equal As Numbers  ${cloudlet['data']['trust_policy_state']}  1

** Keywords **
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

