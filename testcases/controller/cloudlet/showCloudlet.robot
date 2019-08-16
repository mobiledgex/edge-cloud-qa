*** Settings ***
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         Collections	
Library         String

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
	Cloudlet Should Exist   operator_name=${oper}   cloudlet_name=${cldlet}   latitude=35     longitude=-96  notify_server_address=${port}

ShowCloudlets selected
	[Documentation]   ShowCloudlets - Shows a selected cloudlet
	...  The test case shows a selected cloudlet.
	...  Expect the show cloudlet to be successfull


	${list}=  Show Cloudlets	  operator_name=${oper}   cloudlet_name=${cldlet}      
	Cloudlet Should Exist   operator_name=${oper}   cloudlet_name=${cldlet}  latitude=35     longitude=-96   notify_server_address=${port}

ShowCloudlets invalid
	[Documentation]   ShowCloudlets - Tries to show an invalid cloudlet
	...  The test case tries to show an invalid cloudlet 
	...  Expect the test to fail .. no cloudlet found 

	${list}=  Show Cloudlets	  operator_name=${oper}    cloudlet_name=ShowMe  latitude=35     longitude=-96 
	Should Be Empty   ${list}

*** Keywords ***
Setup
        Sleep  1s
	${dips}    Convert To Integer     254
        ${epoch}=  Get Time  epoch

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${epochstring}=  Convert To String  ${epoch}

        ${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet     operator_name=${oper}   cloudlet_name=${cldlet}     number_of_dynamic_ips=${dips}    latitude=35     longitude=-96  notify_server_address=${port}
	Cloudlet Should Exist

        Set Suite Variable  ${cldlet}
        Set Suite Variable  ${port}

