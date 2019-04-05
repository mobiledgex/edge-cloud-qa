*** Settings ***
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}


Test Teardown	Cleanup provisioning


*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}  CreateTest

*** Test Cases ***
CreateClusterFlavor without a key name
	[Documentation]   CreateClusterFlavor - Tries to create a Cluster Flavor without a key name
	...  The test case tries to create a cluster flavor with a missing key name
	...  Expect the create to fail

	${error_msg}=  Run Keyword And Expect Error  *  CreateClusterFlavor   node_flavor_name=x1.medium    master_flavor_name=x1.medium    use_defaults=${False}
	Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
	Should Contain  ${error_msg}   details = "Please specify a unique key"
