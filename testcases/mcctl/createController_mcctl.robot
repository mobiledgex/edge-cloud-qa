*** Settings ***
Documentation  CreateController mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

#Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  2m

*** Variables ***
${region}=  UK
${address}=   mexplat-qa-uk.ctrl.mobiledgex.net:55001
${influxdb}=    https://uk-qa.influxdb.mobiledgex.net:8086	

*** Test Cases ***
# ECQ-2854
CreateController - mcctl shall be able to create/show/delete controllers
	[Documentation]
	...  - send CreateController/ShowController/DeleteController via mcctl with various parms
	...  - verify contoller is created/shown/deleted
	
	[Template]  Success Create/Show/Delete Controller Via mcctl
	# no influxdb
	address=${address}
	
	# all
	address=${address}  influxdb=${influxdb}


# ECQ-2855
CreateController - mcctl shall handle create failures
	[Documentation]
	...  - send CreateContoller via mcctl with various error cases
	...  - verify proper error is received

	[Template]  Fail Create Controller Via mcctl
	# missing values
	Error: missing required args: region address  Error: missing required args: address region     #not sending any args with mcctl  
	Bad Request (400), Controller Address not specified  region=${region}  address=  	
	Bad Request (400), Controller Address not specified  region=${region}  address=""  	

*** Keywords ***
Success Create/Show/Delete Controller Via mcctl
	[Arguments]  &{parms}

	${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
	
	Run mcctl   controller create region=${region} ${parmss} 
	${show}=  Run mcctl  controller show
	Run mcctl  controller delete region=${region} ${parmss}

	Should Be True   "${show[0]['Address']}"=="${parms['address']}" or "${show[1]['Address']}"=="${parms['address']}" or "${show[2]['Address']}"=="${parms['address']}"

	Run Keyword If  'influxdb' in ${parms}  Should Be True  "${show[0]['InfluxDB']}"=="${parms['influxdb']}" or "${show[0]['InfluxDB']}"=="${parms['influxdb']}" or "${show[2]['InfluxDB']}"=="${parms['influxdb']}"


Update Setup
	Run mcctl  controller create region=${region} adderess=${address}

Update Teardown
	Run mcctl  controller delete region=${region} adderess=${address}


Fail Create Controller Via mcctl
	[Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

	${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

	${std_create}=  Run Keyword and Expect Error  *  Run mcctl  controller create ${parmss}
	Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
