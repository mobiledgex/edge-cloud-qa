*** Settings ***
Documentation  Run Console failure tests 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${test_timeout_crm}  15 min

${username}=   mextester06
${password}=   mextester06123
#${email}=      mextester06@gmail.com

${developer}=  automation_dev_org
	
*** Test Cases ***
# ECQ-2075
RunConsole - shall return error with appname not found
    [Documentation]
    ...  execute Run Console with app name not found 
    ...  verify error is received


    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_ap  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  token=${token}  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_ap\\\\",\\\\"version\\\\":\\\\"1.0\\\\"} not found"}')

# ECQ-2076
RunConsole - shall return error with app version not found
    [Documentation]
    ...  execute Run Console with app version not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_app  app_version=1.1  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  token=${token}  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.1\\\\"} not found"}')

# ECQ-2077
RunConsole - shall return error with developer not found
    [Documentation]
    ...  execute Run Console with app developer not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=automation_ap  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  token=${token}  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"App key {\\\\"organization\\\\":\\\\"automation_ap\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"} not found"}')
    #Should Contain  ${error}  Error: Forbidden, code=403, message=Forbidden

# ECQ-2078
RunConsole - shall return error with cluster not found
    [Documentation]
    ...  execute Run Console with cluster not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluste  operator_org_name=dmuus  cloudlet_name=tmocloud-1  token=${token}  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autocluste\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"dmuus\\\\",\\\\"name\\\\":\\\\"tmocloud-1\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}')

# ECQ-2079
RunConsole - shall return error with operator not found
    [Documentation]
    ...  execute Run Console with operator not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=tmu  cloudlet_name=tmocloud-1  token=${token}  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autocluster\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"tmu\\\\",\\\\"name\\\\":\\\\"tmocloud-1\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}') 

# ECQ-2080
RunConsole - shall return error with cloudlet not found
    [Documentation]
    ...  execute Run Console with cloudlet not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-  token=${token}  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"automation_api_app\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"autocluster\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"dmuus\\\\",\\\\"name\\\\":\\\\"tmocloud-\\\\"},\\\\"organization\\\\":\\\\"${developer}\\\\"}} not found"}') 

# ECQ-2081
RunConsole - shall return error with bad token 
    [Documentation]
    ...  execute Run Console with token=xx
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  token=xx  command=ls

    Should Contain  ${error}  ('code=401', 'error={"message":"invalid or expired jwt"}')

# ECQ-2082
RunConsole - shall return error without token
    [Documentation]
    ...  execute Run Console with no token 
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=dmuus  cloudlet_name=tmocloud-1  command=ls  use_defaults=${False}

    Should Contain  ${error}  ('code=400', 'error={"message":"no bearer token found"}')

# ECQ-2083
RunConsole - shall return error with non-vm app
    [Documentation]
    ...  execute Run Console for non-vm app 
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autoclusterautomation  operator_org_name=dmuus  cloudlet_name=tmocloud-1  cluster_instance_developer_org_name=MobiledgeX  token=${token}  command=ls

    Should Contain  ${error}  ('code=400', 'error={"message":"RunConsole only available for VM deployments, use RunCommand instead"}') 

