*** Settings ***
Documentation  showlogs failures 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

#Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${test_timeout_crm}  15 min

${username}=   mextester06
${password}=   mextester06123
#${email}=      mextester06@gmail.com

#${developer}=  MobiledgeX
${developer}=  ${developer_org_name_automation}

${cloudlet_name_openstack_vm}  automationBonnCloudlet
${operator_name_openstack}  TDG
${developer_artifactory}  MobiledgeX

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
	
*** Test Cases ***
# ECQ-1878
ShowLogs - shall return error with appname not found
    [Documentation]
    ...  execute Show Logs with app name not found 
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_ap  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_ap\\\\",\\\\"version\\\\":\\\\"1.0\\\\"} not found"}')

# ECQ-1879
ShowLogs - shall return error with app version not found
    [Documentation]
    ...  execute Show Logs with app version not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.1  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.1\\\\"} not found"}')

# ECQ-1880
ShowLogs - shall return error with developer not found
    [Documentation]
    ...  execute Show Logs with app developer not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=automation_ap  cluster_instance_name=autoclusterautomation  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"automation_ap\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"} not found"}')

    #Should Contain  ${error}  Error: Forbidden, code=403, message=Forbidden

# ECQ-1881
ShowLogs - shall return error with cluster not found
    [Documentation]
    ...  execute Show Logs with cluster not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluste  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autocluste\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"tmus\\\\",\\\\"name\\\\":\\\\"tmocloud-1\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}') 

# ECQ-1882
ShowLogs - shall return error with operator not found
    [Documentation]
    ...  execute Show Logs with operator not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  operator_org_name=tmu  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autoclusterautomation\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"tmu\\\\",\\\\"name\\\\":\\\\"tmocloud-1\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}') 

# ECQ-1883
ShowLogs - shall return error with cloudlet not found
    [Documentation]
    ...  execute Show Logs with cloudlet not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  operator_org_name=tmus  cloudlet_name=tmocloud-  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autoclusterautomation\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"tmus\\\\",\\\\"name\\\\":\\\\"tmocloud-\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}') 

# ECQ-1884
ShowLogs - shall return error with bad token 
    [Documentation]
    ...  execute Show Logs with token=xx
    ...  verify error is received

    #${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=xx  
    log to console  ${error}

    Should Contain  ${error}  ('code=401', 'error={"message":"invalid or expired jwt"}')

# ECQ-1885
ShowLogs - shall return error without token
    [Documentation]
    ...  execute Show Logs with no token 
    ...  verify error is received

    #${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  operator_org_name=tmus  cloudlet_name=tmocloud-1    use_defaults=${False}
    log to console  ${error}

    Should Contain  ${error}  ('code=400', 'error={"message":"no bearer token found"}') 

# ECQ-1886
ShowLogs - shall return error without invalid parms 
    [Documentation]
    ...  execute Show Logs with no token
    ...  verify error is received

#    EDGECLOUD-2081 - ShowLogs should give better error handling for invalid tail/timestamps/follow

    ${error1}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  cluster_instance_developer_org_name=MobiledgeX  operator_org_name=tmus  cloudlet_name=tmocloud-1   since=x

    ${error2}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  cluster_instance_developer_org_name=MobiledgeX  operator_org_name=tmus  cloudlet_name=tmocloud-1   tail=x

    ${error3}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  cluster_instance_developer_org_name=MobiledgeX  operator_org_name=tmus  cloudlet_name=tmocloud-1   time_stamps=x

    ${error4}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  cluster_instance_developer_org_name=MobiledgeX  operator_org_name=tmus  cloudlet_name=tmocloud-1   follow=x

    ${error5}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  cluster_instance_developer_org_name=MobiledgeX  operator_org_name=tmus  cloudlet_name=tmocloud-1   tail=999999999999999

    Should Be Equal  ${error1}  ('code=400', 'error={"message":"Unable to parse Since field as duration or RFC3339 formatted time"}') 
    Should Contain  ${error2}  ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=string, field=ExecRequest.log.tail, offset=
    Should Contain  ${error3}  ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=bool, got=string, field=ExecRequest.log.timestamps, offset= 
    Should Contain  ${error4}  ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=bool, got=string, field=ExecRequest.log.follow, offset= 
    Should Contain  ${error5}  ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=int32, got=number 999999999999999, field=ExecRequest.log.tail, offset 

# ECQ-1896
ShowLogs - shall return error for VM apps
    [Documentation]
    ...  execute Show Logs for VM 
    ...  verify error is received

#    EDGECLOUD-2556 - ShowLogs for VM should show error consistent with RunCommand

    Create Flavor  region=US

    Create App  region=US  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  developer_org_name=${developer_artifactory} 
    ${app_inst}=  Create App Instance  region=US  cloudlet_name=tmocloud-1  operator_org_name=tmus  developer_org_name=${developer_artifactory}  cluster_instance_developer_org_name=${developer_artifactory}

    ${error1}=  Run Keyword And Expect Error  *  Show Logs  region=US  cloudlet_name=tmocloud-1  operator_org_name=tmus  developer_org_name=${developer_artifactory}

    Should Contain  ${error1}  ('code=400', 'error={"message":"ShowLogs not available for vm deployments"}')
