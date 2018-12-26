*** Settings ***
Library		MexController  controller_address=${controller_api_address}

Test Teardown	Cleanup provisioning	

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}   tmus
${cldlet}   TestUpdate

*** Test Cases ***
UpdateCloudlet accessuri
	[Documentation]   UpdateCloudlet -  Updates the existing accessuri to a different value.
	...  The test case updates the default accessuri to a different value
	...  Expect the test case to pass - accessuri should be updated.

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     
	Cloudlet Should Exist
	Update Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}      accessuri=https://support.net/supportme
	Cloudlet Should Exist  

UpdateCloudlet staticips
	[Documentation]   UpdateCloudlet -  Updates the existing staticips to a different value. 
	...  The test case updates the default staticuri to a different value.
	...  Expect the test case to pass - staticuri should be updated.

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     
	Cloudlet Should Exist
	Update Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}      staticips=50.50.50.50
	Cloudlet Should Exist       


UpdateCloudlet number_of_dynamic_ips
	[Documentation]   UpdateCloudlet -  Updates the numdynamicips to a different value.
	...  The test case updates the default numdynamicips to a different value.
	...  Expect the test case to pass - numdynamicips should be updated.

	${dips}     Convert To Integer 	  60

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     
	Cloudlet Should Exist
	Update Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}      number_of_dynamic_ips=${dips}  
	Cloudlet Should Exist        


UpdateCloudlet location 
	[Documentation]   UpdateCloudlet -  Updates the location lat and long at the same time
	...  The test case updates both of the location lat and long at the same time
	...  Expect the test case to pass - both fields should be updated.

	${loc}     Convert To Integer 	  40

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     
	Cloudlet Should Exist
	Update Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}          latitude=${loc}       longitude=${loc} 
	Cloudlet Should Exist       

UpdateCloudlet location lat
	[Documentation]   UpdateCloudlet -  Updates the location lat only
	...  The test case updates only the location lat 
	...  Expect the test case to pass - only the location lat field should be updated.

	${loc}     Convert To Integer 	  60

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     
	Cloudlet Should Exist
	Update Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}      latitude=${loc}
	Cloudlet Should Exist           
	
UpdateCloudlet location long
	[Documentation]   UpdateCloudlet -  Updates the location long only
	...  The test case updates only the location long 
	...  Expect the test case to pass - only the location long field should be updated.

	${loc}     Convert To Integer 	  90

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     
	Cloudlet Should Exist
	Update Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}      longitude=${loc}
	Cloudlet Should Exist       

UpdateCloudlet optional accessuri
	[Documentation]   UpdateCloudlet -  Updates and adds the accessuri to the cloudlet
	...  The test case updates and adds the opional field accessuri to the clouldlet.
	...  Expect the test case to pass - the accessuri field should be updated and addedd to the cloudlet.

	${dips}   Convert To Integer    254
	${lat}    Convert To Integer    35
	${long}   Convert To Integer    -96

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     number_of_dynamic_ips=${dips}      latitude=${lat}     longitude=${long}    use_defaults=False
	Cloudlet Should Exist	   
	Update Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}     accessuri=https://support.net/supportme     use_defaults=False
	Cloudlet Should Exist      

UpdateCloudlet optional staticips	
	[Documentation]   UpdateCloudlet -  Updates and adds the staticips to the cloudlet
	...  The test case updates and adds the opional field staticips to the clouldlet.
	...  Expect the test case to pass - the staticips field should be updated and addedd to the cloudlet.

	${dips}   Convert To Integer    254
	${lat}    Convert To Integer    35
	${long}   Convert To Integer    -96

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     number_of_dynamic_ips=${dips}      latitude=${lat}     longitude=${long}    use_defaults=False
	Cloudlet Should Exist	  
	Update Cloudlet	   operator_name=${oper}    cloudlet_name=${cldlet}     staticips=50.50.50.50    use_defaults=False
	Cloudlet Should Exist      

	
