*** Settings ***
#Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections

Test Teardown	Cleanup provisioning	

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}   azure
${cldlet}   TestUpdate
${region}=  US
${operator_name_fake}=  dmuus

*** Test Cases ***
# no longer supported
# ECQ-927
#UpdateCloudlet accessuri
#	[Documentation]   UpdateCloudlet -  Updates the existing accessuri to a different value.
#	...  The test case updates the default accessuri to a different value
#	...  Expect the test case to pass - accessuri should be updated.
#
#        Sleep  1s
#        ${epoch}=  Get Time  epoch
#        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
#        #${epochstring}=  Convert To String  ${epoch}
#        #${portnum}=  Get Substring  ${epochstring}  -5
#        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
#        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}
#
#	Create Cloudlet  region=${region}   operator_org_name=${oper}   cloudlet_name=${cldlet}  notify_server_address=${port}   
#	Cloudlet Should Exist
#	Update Cloudlet	 region=${region}  operator_org_name=${oper}    cloudlet_name=${cldlet}      accesscredentials=https://support.net/supportme
#	Cloudlet Should Exist  

# ECQ-928
UpdateCloudlet staticips
	[Documentation]   UpdateCloudlet -  Updates the existing staticips to a different value. 
	...  The test case updates the default staticuri to a different value.
	...  Expect the test case to pass - staticuri should be updated.

        Sleep  1s
        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        #${epochstring}=  Convert To String  ${epoch}
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet  region=${region}   operator_org_name=${oper}   cloudlet_name=${cldlet}    #notify_server_address=${port} 
	#Cloudlet Should Exist
	${cloudlet}=  Update Cloudlet  region=${region}  operator_org_name=${oper}    cloudlet_name=${cldlet}      static_ips=50.50.50.50
	#Cloudlet Should Exist       
        Should Be Equal  ${cloudlet['data']['key']['name']}  ${cldlet}
        Should Be Equal  ${cloudlet['data']['static_ips']}  50.50.50.50

# ECQ-929
UpdateCloudlet number_of_dynamic_ips
	[Documentation]   UpdateCloudlet -  Updates the numdynamicips to a different value.
	...  The test case updates the default numdynamicips to a different value.
	...  Expect the test case to pass - numdynamicips should be updated.

	${dips}     Convert To Integer 	  60

        Sleep  1s
        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        #${epochstring}=  Convert To String  ${epoch}
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet  region=${region}   operator_org_name=${oper}   cloudlet_name=${cldlet}    #notify_server_address=${port} 
	#Cloudlet Should Exist
	${cloudlet}=  Update Cloudlet	 region=${region}   operator_org_name=${oper}    cloudlet_name=${cldlet}      number_dynamic_ips=${dips}  
	#Cloudlet Should Exist        
        Should Be Equal  ${cloudlet['data']['key']['name']}  ${cldlet}
        Should Be Equal  ${cloudlet['data']['num_dynamic_ips']}  ${dips}

# ECQ-930
UpdateCloudlet location 
	[Documentation]   UpdateCloudlet -  Updates the location lat and long at the same time
	...  The test case updates both of the location lat and long at the same time
	...  Expect the test case to pass - both fields should be updated.

	${loc}     Convert To Integer 	  40

        Sleep  1s
        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        #${epochstring}=  Convert To String  ${epoch}
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet  region=${region}   operator_org_name=${oper}   cloudlet_name=${cldlet}    #notify_server_address=${port} 
	#Cloudlet Should Exist
	${cloudlet}=  Update Cloudlet	 region=${region}  operator_org_name=${oper}    cloudlet_name=${cldlet}          latitude=${loc}       longitude=${loc} 
	#Cloudlet Should Exist       
        Should Be Equal  ${cloudlet['data']['key']['name']}  ${cldlet}
        Should Be Equal  ${cloudlet['data']['location']['latitude']}  ${loc}
        Should Be Equal  ${cloudlet['data']['location']['longitude']}  ${loc}

# ECQ-931
UpdateCloudlet location lat
	[Documentation]   UpdateCloudlet -  Updates the location lat only
	...  The test case updates only the location lat 
	...  Expect the test case to pass - only the location lat field should be updated.

	${loc}     Convert To Integer 	  60

        Sleep  1s
        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        #${epochstring}=  Convert To String  ${epoch}
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet  region=${region}   operator_org_name=${oper}   cloudlet_name=${cldlet}    #notify_server_address=${port} 
	#Cloudlet Should Exist
	${cloudlet}=  Update Cloudlet  region=${region}   operator_org_name=${oper}    cloudlet_name=${cldlet}      latitude=${loc}
	#Cloudlet Should Exist           
        Should Be Equal  ${cloudlet['data']['key']['name']}  ${cldlet}
        Should Be Equal  ${cloudlet['data']['location']['latitude']}  ${loc}

# ECQ-932	
UpdateCloudlet location long
	[Documentation]   UpdateCloudlet -  Updates the location long only
	...  The test case updates only the location long 
	...  Expect the test case to pass - only the location long field should be updated.

	${loc}     Convert To Integer 	  90

        Sleep  1s
        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        #${epochstring}=  Convert To String  ${epoch}
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet    region=${region}   operator_org_name=${oper}   cloudlet_name=${cldlet}    #notify_server_address=${port} 
	#Cloudlet Should Exist
	${cloudlet}=  Update Cloudlet	 region=${region}   operator_org_name=${oper}    cloudlet_name=${cldlet}      longitude=${loc}
	#Cloudlet Should Exist       
        Should Be Equal  ${cloudlet['data']['key']['name']}  ${cldlet}
        Should Be Equal  ${cloudlet['data']['location']['longitude']}  ${loc}

# no longer supported
# ECQ-933
#UpdateCloudlet optional accessuri
#	[Documentation]   UpdateCloudlet -  Updates and adds the accessuri to the cloudlet
#	...  The test case updates and adds the opional field accessuri to the clouldlet.
#	...  Expect the test case to pass - the accessuri field should be updated and addedd to the cloudlet.
#
#	${dips}   Convert To Integer    254
#	${lat}    Convert To Integer    35
#	${long}   Convert To Integer    -96
#
#        Sleep  1s
#        ${epoch}=  Get Time  epoch
#        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
#        #${epochstring}=  Convert To String  ${epoch}
#        #${portnum}=  Get Substring  ${epochstring}  -5
#        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
#        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}
#
#	Create Cloudlet     operator_org_name=${oper}   cloudlet_name=${cldlet}     number_of_dynamic_ips=${dips}      latitude=${lat}     longitude=${long}   notify_server_address=${port}  use_defaults=False
#	Cloudlet Should Exist	   
#	Update Cloudlet	   operator_org_name=${oper}    cloudlet_name=${cldlet}     accesscredentials=https://support.net/supportme     use_defaults=False
#	Cloudlet Should Exist      

# ECQ-934
UpdateCloudlet optional staticips	
	[Documentation]   UpdateCloudlet -  Updates and adds the staticips to the cloudlet
	...  The test case updates and adds the opional field staticips to the clouldlet.
	...  Expect the test case to pass - the staticips field should be updated and addedd to the cloudlet.

	${dips}   Convert To Integer    254
	${lat}    Convert To Integer    35
	${long}   Convert To Integer    -96

        Sleep  1s
        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        #${epochstring}=  Convert To String  ${epoch}
        #${portnum}=  Get Substring  ${epochstring}  -5
        ${portnum}=    Evaluate    random.randint(49152, 65500)   random
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet  region=${region}   operator_org_name=${oper}   cloudlet_name=${cldlet}     number_dynamic_ips=${dips}      latitude=${lat}     longitude=${long}    #use_defaults=False  #notify_server_address=${port}  use_defaults=False
	#Cloudlet Should Exist	  
	${cloudlet}=  Update Cloudlet	 region=${region}  operator_org_name=${oper}    cloudlet_name=${cldlet}     static_ips=50.50.50.50    use_defaults=False
	#Cloudlet Should Exist      
        Should Be Equal  ${cloudlet['data']['key']['name']}  ${cldlet}
        Should Be Equal  ${cloudlet['data']['static_ips']}  50.50.50.50

# ECQ-3065
UpdateCloudlet - shall be able to update cloudlet with trust policy
   [Documentation]
   ...  - create 2 trust policies
   ...  - send CreateCloudlet with policy1
   ...  - verify the cloudlet is assinged the policy
   ...  - send UpdateCloudlet with policy2
   ...  - verify cloudlet has policy2

   Create Flavor  region=${region}

   ${policy_name}=  Get Default Trust Policy Name

   # create 1st trust policy
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

   # create 2nd trust policy
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist2}=  Create List  ${rule2}
   ${policy_return2}=  Create Trust Policy  region=${region}  policy_name=${policy_name}_2  rule_list=${rulelist2}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${policy_return2['data']['key']['name']}          ${policy_name}_2
   Should Be Equal  ${policy_return2['data']['key']['organization']}  ${operator_name_fake}

   # create cloudlet trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${policy_return['data']['key']['name']}
   Should Be Equal             ${cloudlet['data']['trust_policy']}  ${policy_return['data']['key']['name']}
   Should Be Equal As Numbers  ${cloudlet['data']['trust_policy_state']}  5

   # update cloudlet with new trust policy
   ${cloudlet_update}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${policy_name}_2
   Should Be Equal             ${cloudlet_update['data']['trust_policy']}  ${policy_name}_2
   Should Be Equal As Numbers  ${cloudlet_update['data']['trust_policy_state']}  5	

# ECQ-3066
UpdateCloudlet - shall be able to add trust policy to cloudlet
   [Documentation]
   ...  - create a trust policy
   ...  - send CreateCloudlet without policy
   ...  - send UpdateCloudlet with the policy
   ...  - verify cloudlet has policy

   Create Flavor  region=${region}

   ${policy_name}=  Get Default Trust Policy Name

   # create a trust policy
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

   # create cloudlet without trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  
   Should Not Contain             ${cloudlet['data']}  trust_policy

   # update cloudlet with new trust policy
   ${cloudlet_update}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${policy_name}
   Should Be Equal             ${cloudlet_update['data']['trust_policy']}  ${policy_name}
   Should Be Equal As Numbers  ${cloudlet_update['data']['trust_policy_state']}  5

