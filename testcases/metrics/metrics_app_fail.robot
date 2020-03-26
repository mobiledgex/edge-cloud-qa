*** Settings ***
Documentation   App Metrics Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudletStage
${operator}=                       TDG
	
*** Test Cases ***
AppMetrics - get with no app shall return error
   [Documentation]
   ...  get app metrics with no app info
   ...  verify error

   ${token}=  Get Token

   # cpu	
   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=cpu  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"App details must be present"}

   # mem
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=mem  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"App details must be present"}

   # network 
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=network  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"App details must be present"}

   # connections 
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=connections  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"App details must be present"}

   # disk 
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=disk  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"App details must be present"}

AppMetrics - get with no cloudlet/operator name shall return error
   [Documentation]
   ...  get app metrics with no cloudlet/operator name
   ...  verify error

   ${token}=  Get Token

   # cpu
   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  selector=cpu  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"App details must be present"}

   # mem
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  selector=mem  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"App details must be present"}

   # network
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  selector=network  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"App details must be present"}

   # connections 
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  selector=connections  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"App details must be present"}

   # disk
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  cluster_instance_name=autoclusterautomation  selector=disk  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"App details must be present"}

AppMetrics - get with no token name shall return error
   [Documentation]
   ...  get app metrics with no token
   ...  verify error

   ${token}=  Get Token

   # cpu
   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=cpu  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"no bearer token found"}

   # mem
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=mem  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"no bearer token found"}

   # network
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=network  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  last=1  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"no bearer token found"}

   #connections 
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=connections  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  last=1  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"no bearer token found"}

   # disk
   ${error2}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=disk  app_name=automation_api_app  app_version=1.0  last=1  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"no bearer token found"}

AppMetrics - get with no selector name shall return error
   [Documentation]
   ...  get app metrics with no selector
   ...  verify error

   ${token}=  Get Token
   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid appinst selector: "} 

AppMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  get app metrics with invalid selector
   ...  verify error

   ${token}=  Get Token
   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=xx  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}

   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid appinst selector: xx"}

AppMetrics - get with invalid start time shall return error
   [Documentation]
   ...  get app metrics with invalid start time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=cpu  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""} 

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=disk  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=mem  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=tcp  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=udp  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=network  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

AppMetrics - get with invalid end time shall return error
   [Documentation]
   ...  get app metrics with invalid end time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=cpu  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=disk  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=mem  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=tcp  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=udp  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=network  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

AppMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  get app metrics with invalid start/end time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=cpu  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=disk  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=mem  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=tcp  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=udp  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=network  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

AppMetrics - get with invalid last shall return error
   [Documentation]
   ...  get app metrics with invalid last
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=cpu  last=x  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=disk  last=x  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=mem  last=x  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=tcp  last=x  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=udp  last=x  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  region=US  selector=network  last=x  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

AppMetrics - get with cluster not found shall return an empty list
   [Documentation]
   ...  get app metrics with cluster not found
   ...  verify empty list is returned

   ${token}=  Get Token

   #${metrics}=         Get App Metrics  region=${region}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_name=${operator}  developer_name=${developer}  selector=${selector}  last=1

   ${metrics}=  Get App Metrics  region=US  selector=cpu  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  cluster_instance_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=disk  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  cluster_instance_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=mem  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  cluster_instance_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=connections  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_instance_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=network  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_instance_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

AppMetrics - get with operator not found shall return an empty list
   [Documentation]
   ...  get app metrics with operator not found
   ...  verify empty list is returned

   ${token}=  Get Token

   #${metrics}=         Get App Metrics  region=${region}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_name=${operator}  developer_name=${developer}  selector=${selector}  last=1

   ${metrics}=  Get App Metrics  region=US  selector=cpu  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=disk  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=connections  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=network  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=mem  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

AppMetrics - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  get app metrics with cloudlet not found
   ...  verify empty list is returned

   ${token}=  Get Token

   #${metrics}=         Get App Metrics  region=${region}  cluster_instance_name=${cluster}  cloudlet_name=${cloudlet}  operator_name=${operator}  developer_name=${developer}  selector=${selector}  last=1

   ${metrics}=  Get App Metrics  region=US  selector=cpu  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=disk  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=mem  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=connections  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=network  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

AppMetrics - get with appname not found shall return an empty list
   [Documentation]
   ...  get app metrics with cloudlet not found
   ...  verify empty list is returned

   ${token}=  Get Token

   ${metrics}=  Get App Metrics  region=US  selector=cpu  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=xx  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=disk  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=xx  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=mem  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=xx  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=connections  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=xx  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get App Metrics  region=US  selector=network  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=xx  app_version=1.0  cluster_instance_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

AppMetrics - get without region shall return error
   [Documentation]
   ...  get app metrics without region 
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  selector=cpu  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"no region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  selector=disk  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"no region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  selector=mem  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"no region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  selector=connections  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"no region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get App Metrics  selector=network  last=1  app_name=automation_api_app  app_version=1.0  cluster_instance_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"no region specified"}
