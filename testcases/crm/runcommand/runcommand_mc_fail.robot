*** Settings ***
Documentation  use FQDN to access app on openstack

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
#Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
#Library  MexApp
#Library  String

#Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${test_timeout_crm}  15 min

${username}=   mextester06
${password}=   mextester06123
#${email}=      mextester06@gmail.com

${developer}=  automation_dev_org

${qcow_centos_image}=  https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d
	
*** Test Cases ***
# ECQ-1478
RunCommand - shall return error with appname not found
    [Documentation]
    ...  execute Run Command with app name not found 
    ...  verify error is received

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_ap  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"automation_dev_org\\\\",\\\\"name\\\\":\\\\"automation_api_ap\\\\",\\\\"version\\\\":\\\\"1.0\\\\"} not found"}')

# ECQ-1479
RunCommand - shall return error with app version not found
    [Documentation]
    ...  execute Run Command with app version not found
    ...  verify error is received

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.1  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"automation_dev_org\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.1\\\\"} not found"}')

# ECQ-1480
RunCommand - shall return error with developer not found
    [Documentation]
    ...  execute Run Command with app developer not found
    ...  verify error is received

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=automation_ap  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"automation_ap\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"} not found"}')

# ECQ-1481
RunCommand - shall return error with cluster not found
    [Documentation]
    ...  execute Run Command with cluster not found
    ...  verify error is received

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluste  operator_org_name=dmuus  cloudlet_name=tmocloud-1  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autocluste\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"dmuus\\\\",\\\\"name\\\\":\\\\"tmocloud-1\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}')

# ECQ-1482
RunCommand - shall return error with operator not found
    [Documentation]
    ...  execute Run Command with operator not found
    ...  verify error is received

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=tmu  cloudlet_name=tmocloud-1  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autocluster\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"tmu\\\\",\\\\"name\\\\":\\\\"tmocloud-1\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}') 

# ECQ-1483
RunCommand - shall return error with cloudlet not found
    [Documentation]
    ...  execute Run Command with cloudlet not found
    ...  verify error is received

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autocluster\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"dmuus\\\\",\\\\"name\\\\":\\\\"tmocloud-\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}') 

# ECQ-1484
RunCommand - shall return error with bad token 
    [Documentation]
    ...  execute Run Command with token=xx
    ...  verify error is received

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  token=xx  command=ls

    Should Contain  ${error}  ('code=401', 'error={"message":"invalid or expired jwt"}')

# ECQ-1485
RunCommand - shall return error without token
    [Documentation]
    ...  execute Run Command with no token 
    ...  verify error is received


    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  command=ls  use_defaults=${False}

    Should Contain  ${error}  ('code=400', 'error={"message":"no bearer token found"}')

# ECQ-2063
RunCommand - shall return error without run command 
    [Documentation]
    ...  execute Run Command with no command 
    ...  verify error is received

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  operator_org_name=dmuus  cloudlet_name=tmocloud-1  

    Should Contain  ${error}  ('code=400', 'error={"message":"No run command specified"}')

# ECQ-2065
RunCommand - shall return error for VM app 
    [Documentation]
    ...  execute Run Command for VM app 
    ...  verify error is received

    Create Flavor  region=US
    Create App  region=US  image_path=${qcow_centos_image}  access_ports=tcp:2015  deployment=vm  image_type=ImageTypeQCOW  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    Create App Instance  region=US  operator_org_name=dmuus  cloudlet_name=tmocloud-1  #app_name=${app_name_default}  developer_org_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  use_defaults=${False}

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  command=ls  operator_org_name=dmuus  cloudlet_name=tmocloud-1  #app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  command=ls  use_defaults=${False}

    Should Contain  ${error}  ('code=400', 'error={"message":"RunCommand not available for VM deployments, use RunConsole instead"}')

