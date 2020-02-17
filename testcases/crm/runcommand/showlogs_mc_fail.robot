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

${developer}=  mobiledgex

${cloudlet_name_openstack_vm}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${developer_artifactory}  mobiledgex

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
	
*** Test Cases ***
ShowLogs - shall return error with appname not found
    [Documentation]
    ...  execute Show Logs with app name not found 
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_ap  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"developer_key":{"name":"${developer}"},"name":"automation_api_ap","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"operator_key":{"name":"dmuus"},"name":"tmocloud-1"},"developer":"${developer}"}} not found 

ShowLogs - shall return error with app version not found
    [Documentation]
    ...  execute Show Logs with app version not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.1  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"developer_key":{"name":"${developer}"},"name":"automation_api_app","version":"1.1"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"operator_key":{"name":"dmuus"},"name":"tmocloud-1"},"developer":"${developer}"}} not found 

ShowLogs - shall return error with developer not found
    [Documentation]
    ...  execute Show Logs with app developer not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=automation_ap  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    #Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"developer_key":{"name":"automation_ap"},"name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"operator_key":{"name":"dmuus"},"name":"tmocloud-1"},"developer":"automation_ap"}} not found 
    Should Contain  ${error}  Error: Forbidden, code=403, message=Forbidden

ShowLogs - shall return error with cluster not found
    [Documentation]
    ...  execute Show Logs with cluster not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autocluste  operator_name=dmuus  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"developer_key":{"name":"${developer}"},"name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autocluste"},"cloudlet_key":{"operator_key":{"name":"dmuus"},"name":"tmocloud-1"},"developer":"${developer}"}} not found 

ShowLogs - shall return error with operator not found
    [Documentation]
    ...  execute Show Logs with operator not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=tmu  cloudlet_name=tmocloud-1  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"developer_key":{"name":"${developer}"},"name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"operator_key":{"name":"tmu"},"name":"tmocloud-1"},"developer":"${developer}"}} not found 

ShowLogs - shall return error with cloudlet not found
    [Documentation]
    ...  execute Show Logs with cloudlet not found
    ...  verify error is received

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-  token=${token}  
    log to console  ${error}

    Should Contain  ${error}  Error: Bad Request, AppInst key {"app_key":{"developer_key":{"name":"${developer}"},"name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"operator_key":{"name":"dmuus"},"name":"tmocloud-"},"developer":"${developer}"}} not found 

ShowLogs - shall return error with bad token 
    [Documentation]
    ...  execute Show Logs with token=xx
    ...  verify error is received

    #${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1  token=xx  
Show    log to console  ${error}

    Should Contain  ${error}  Error: Unauthorized, invalid or expired jwt 

ShowLogs - shall return error without token
    [Documentation]
    ...  execute Show Logs with no token 
    ...  verify error is received

    #${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1    use_defaults=${False}
    log to console  ${error}

    Should Contain  ${error}  Error: Unauthorized, invalid or expired jwt

ShowLogs - shall return error without invalid parms 
    [Documentation]
    ...  execute Show Logs with no token
    ...  verify error is received

    EDGECLOUD-2081 - ShowLogs should give better error handling for invalid tail/timestamps/follow

    ${error1}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1   since=x

    ${error2}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1   tail=x

    ${error3}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1   time_stamps=x

    ${error4}=  Run Keyword And Expect Error  *  Show Logs  region=US  app_name=automation_api_app  app_version=1.0  developer_name=${developer}  cluster_instance_name=autoclusterautomation  operator_name=dmuus  cloudlet_name=tmocloud-1   follow=x

    Should Contain  ${error1}  Error: Bad Request, Unable to parse Since field as duration or RFC3339 formatted time
    Should Contain  ${error2}  Error: Bad Request, Unable to parse Since field as duration or RFC3339 formatted time
    Should Contain  ${error3}  Error: Bad Request, Unable to parse Since field as duration or RFC3339 formatted time
    Should Contain  ${error4}  Error: Bad Request, Unable to parse Since field as duration or RFC3339 formatted time

ShowLogs - shall return error for VM apps
    [Documentation]
    ...  execute Show Logs for VM 
    ...  verify error is received

    Create Flavor  region=US

    Create App  region=US  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  developer_name=${developer_artifactory} 
    ${app_inst}=  Create App Instance  region=US  cloudlet_name=tmocloud-1  operator_name=dmuus  developer_name=${developer_artifactory}  cluster_instance_developer_name=${developer_artifactory}

    ${error1}=  Run Keyword And Expect Error  *  Show Logs  region=US  cloudlet_name=tmocloud-1  operator_name=dmuus 

    Should Contain  ${error1}  Error: Bad Request, Unsupported deployment type
