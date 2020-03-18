*** Settings ***
Documentation  use FQDN to access app on openstack

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
#Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
#Library  MexApp
#Library  String

#Test Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${test_timeout_crm}  15 min

${username}=   mextester06
${password}=   mextester06123
#${email}=      mextester06@gmail.com

${developer}=  mobiledgex
	
*** Test Cases ***
RunCommand - shall return error with appname not found
    [Documentation]
    ...  execute Run Command with app name not found 
    ...  verify error is received


    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_ap  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=${token}  command=ls
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_ap","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autocluster"},"cloudlet_key":{"organization":"tmus","name":"tmocloud-1"},"organization":"${developer}"}} not found 

RunCommand - shall return error with app version not found
    [Documentation]
    ...  execute Run Command with app version not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.1  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=${token}  command=ls
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.1"},"cluster_inst_key":{"cluster_key":{"name":"autocluster"},"cloudlet_key":{"organization":"tmus","name":"tmocloud-1"},"organization":"${developer}"}} not found 

RunCommand - shall return error with developer not found
    [Documentation]
    ...  execute Run Command with app developer not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=automation_ap  cluster_instance_name=autocluster  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=${token}  command=ls
    log to console  ${error}

    #Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"organization":"automation_ap","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autocluster"},"cloudlet_key":{"organization":"tmus","name":"tmocloud-1"},"organization":"automation_ap"}} not found 
    Should Contain  ${error}  Error: Forbidden, code=403, message=Forbidden

RunCommand - shall return error with cluster not found
    [Documentation]
    ...  execute Run Command with cluster not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluste  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=${token}  command=ls
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autocluste"},"cloudlet_key":{"organization":"tmus","name":"tmocloud-1"},"organization":"${developer}"}} not found 

RunCommand - shall return error with operator not found
    [Documentation]
    ...  execute Run Command with operator not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=tmu  cloudlet_name=tmocloud-1  token=${token}  command=ls
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autocluster"},"cloudlet_key":{"organization":"tmu","name":"tmocloud-1"},"organization":"${developer}"}} not found 

RunCommand - shall return error with cloudlet not found
    [Documentation]
    ...  execute Run Command with cloudlet not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=tmus  cloudlet_name=tmocloud-  token=${token}  command=ls
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autocluster"},"cloudlet_key":{"organization":"tmus","name":"tmocloud-"},"organization":"${developer}"}} not found 

RunCommand - shall return error with bad token 
    [Documentation]
    ...  execute Run Command with token=xx
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=tmus  cloudlet_name=tmocloud-1  token=xx  command=ls
    log to console  ${error}

    Should Contain  ${error}  Error: Unauthorized, invalid or expired jwt 

RunCommand - shall return error without token
    [Documentation]
    ...  execute Run Command with no token 
    ...  verify error is received


    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  app_name=automation_api_app  app_version=1.0  developer_org_name=${developer}  cluster_instance_name=autocluster  operator_org_name=tmus  cloudlet_name=tmocloud-1  command=ls  use_defaults=${False}
    log to console  ${error}

    Should Contain  ${error}  Error: Unauthorized, invalid or expired jwt

