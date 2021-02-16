*** Settings ***
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Variables  shared_variables.py

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}   dmuus
${cldlet}    tmocloud-4

*** Test Cases ***
DeleteCloudlet without an operator
	[Documentation]   DeleteCloudlet -  Tries to delete a cloudlet without an operator
	...  This test case trys to delete a cloudlet without giving an operator name
	...  Expect to fail witn invalid operator name
	
	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	cloudlet_name=${cldlet}     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Cloudlet key {"name":"tmocloud-4"} not found" 

DeleteCloudlet with an invalid operator
	[Documentation]   DeleteCloudlet -  Tries to delete a cloudlet with an invalid operator
	...  This test case will try and delete a cloudlet with an invalid operator name 
	...  Expect this test case to fail with an invalid Key (Needs a valid operator and a valid cloudlet name)
	 
	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	operator_org_name=mci      cloudlet_name=${cldlet}      use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Cloudlet key {"organization":"mci","name":"tmocloud-4"} not found" 

DeleteCloudlet without a cloudlet name
	[Documentation]   DeleteCloudlet -  Tries to delete a cloudlet without a cloudlet name
	...  This test case trys to delete a cloudlet without giving a cloudlet name
	...  Expect to fail witn invalid cloudlet name
	
	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	operator_org_name=${oper}       use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Cloudlet key {"organization":"dmuus"} not found" 

DeleteCloudlet with an invalid cloudlet name
	[Documentation]   DeleteCloudlet -  Tries to delete a cloudlet with an invalid cloudlet name
	...  This test case will try and delete a cloudlet with an invalid cloudlet name 
	...  Expect this test case to fail with an invalid Key (Needs a valid operator and a valid cloudlet name)

	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	operator_org_name=${oper}   cloudlet_name=Test     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Cloudlet key {"organization":"dmuus","name":"Test"} not found"

DeleteCloudlet with a static app assigned
	[Documentation]   DeleteCloudlet -  Tries to delete a cloudlet with a static appinst assigned
	...  This test case will try and delete a cloudlet with a static appinst assigned to it
	...  Expect this test case to fail with a Cloudlet in use by static Application Instance error

	[Setup]  Setup
	Create App                  
	Create App Instance  cluster_instance_name=autocluster         
	
	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	   operator_org_name=${oper}   cloudlet_name=${cldlet}     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	#Should Contain  ${error_msg}   details = "Cloudlet in use by static AppInst"
        Should Contain  ${error_msg}   details = "Cloudlet in use by ClusterInst name reservable0, reserved by Organization MobiledgeX"

	[Teardown]  Cleanup Provisioning

DeleteCloudlet with a static cluster instance assigned
	[Documentation]   DeleteCloudlet -  Tries to delete a cloudlet with a static cluster instance assigned
	...  This test case will try and delete a cloudlet with a static cluster instance assigned to it
	...  Expect this test case to fail with a Cloudlet in use by static Cluster Instance error

	[Setup]  Setup
	Create Cluster Instance	

	${error_msg}=  Run Keyword And Expect Error  *  Delete Cloudlet	   operator_org_name=${oper}   cloudlet_name=${cldlet}     use_defaults=False
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Cloudlet in use by static ClusterInst"

	[Teardown]  Cleanup Provisioning

DeleteCloudlet with a valid operator and cloudlet name
	[Documentation]   DeleteCloudlet -  Successfully deletes a cloudlet
	...  This test case will create a cloudlet and then delete the cloudlet
	...  Expect to pass. The cloudlet will successfully be created and then deleted'
	
	Create Cloudlet     operator_org_name=${oper}       cloudlet_name=${cldlet}      number_of_dynamic_ips=default    latitude=35.0     longitude=-96.0
	Delete Cloudlet     operator_org_name=${oper}       cloudlet_name=${cldlet}
	Cloudlet Should Not Exist

*** Keywords ***
Setup
	#Create Developer            
	Create Flavor
	Create Cloudlet		operator_org_name=${oper}       cloudlet_name=${cldlet}  
	#Create Cluster

