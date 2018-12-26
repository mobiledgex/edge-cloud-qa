*** Settings ***
Library		MexController  controller_address=${controller_api_address}
Library         Collections	

Test Setup      Setup
Test Teardown	Cleanup provisioning


*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}  CreateTest
	
*** Test Cases ***
ShowCloudlets all
	[Documentation]   ShowCloudlets - Shows all cloudlets
	...  The test case shows a list of cloudlets 
	...  Expect the show cloudlets to be sucessfully
		
	${list}=  Show Cloudlets
	${length}=  Get Length  ${list}
	Cloudlet Should Exist   operator_name=${oper}   cloudlet_name=${cldlet}  

ShowCloudlets selected
	[Documentation]   ShowCloudlets - Shows a selected cloudlet
	...  The test case shows a selected cloudlet.
	...  Expect the show cloudlet to be successfull


	${list}=  Show Cloudlets	  operator_name=${oper}   cloudlet_name=${cldlet}      
	Cloudlet Should Exist   operator_name=${oper}   cloudlet_name=${cldlet}  

ShowCloudlets invalid
	[Documentation]   ShowCloudlets - Tries to show an invalid cloudlet
	...  The test case tries to show an invalid cloudlet 
	...  Expect the test to fail .. no cloudlet found 

	${list}=  Show Cloudlets	  operator_name=${oper}    cloudlet_name=ShowMe  
	Should Be Empty   ${list}

*** Keywords ***
Setup
	${dips}    Convert To Integer     254
	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     number_of_dynamic_ips=${dips}    latitude=35     longitude=-96  
	Cloudlet Should Exist
