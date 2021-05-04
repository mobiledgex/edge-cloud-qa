*** Settings ***
Documentation   clientappusage Metrics Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudletStage
${operator}=                       TDG
	
*** Test Cases ***
ClientAppUsageMetrics - get with no app org shall return error
   [Documentation]
   ...  get clientappusage metrics with no app org
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either App organization or Cloudlet organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either App organization or Cloudlet organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=x  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either App organization or Cloudlet organization"}

ClientAppUsageMetrics - developer get with no app org shall return error
   [Documentation]
   ...  get clientappusage metrics with no app org as developer
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  operator_org_name=${operator}  last=1  token=${dev_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Developers please specify the App Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  operator_org_name=${operator}  last=1  token=${dev_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Developers please specify the App Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=x  operator_org_name=${operator}  last=1  token=${dev_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Developers please specify the App Organization"}

ClientAppUsageMetrics - operator get with no cloudlet org shall return error
   [Documentation]
   ...  get clientappusage metrics with no cloudlet org as operator
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  developer_org_name=${operator}  last=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  developer_org_name=${operator}  last=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=x  developer_org_name=${operator}  last=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

ClientAppUsageMetrics - operator get with no cloudlet pools shall return error
   [Documentation]
   ...  get clientappusage metrics with no cloudlet pools as operator
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  developer_org_name=${operator}  operator_org_name=tmus  last=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  developer_org_name=${operator}  operator_org_name=tmus  last=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=x  developer_org_name=${operator}  operator_org_name=tmus  last=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

ClientAppUsageMetrics - get with selector=custom shall return error
   [Documentation]
   ...  get clientappusage metrics with selector=custom
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=custom  developer_org_name=${operator}  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Custom stat not implemented yet"}

ClientAppUsageMetrics - get with no token name shall return error
   [Documentation]
   ...  get clientappusage metrics with no token
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  last=1  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"no bearer token found"}

ClientAppUsageMetrics - get with no selector name shall return error
   [Documentation]
   ...  get clientappusage metrics with no selector
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Provided selector \\\\"\\\\" is not valid. Must provide only one of \\\\"latency\\\\", \\\\"deviceinfo\\\\", \\\\"custom\\\\""} 

ClientAppUsageMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  get clientappusage metrics with invalid selector
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=xx  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}

   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Provided selector \\\\"xx\\\\" is not valid. Must provide only one of \\\\"latency\\\\", \\\\"deviceinfo\\\\", \\\\"custom\\\\""}

ClientAppUsageMetrics - get with invalid start time shall return error
   [Documentation]
   ...  get clientappusage metrics with invalid start time
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""} 

ClientAppUsageMetrics - get with invalid end time shall return error
   [Documentation]
   ...  get clientappusage metrics with invalid end time
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

ClientAppUsageMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  get clientappusage metrics with invalid start/end time
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

ClientAppUsageMetrics - get with invalid last shall return error
   [Documentation]
   ...  get clientappusage metrics with invalid last
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  last=x  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

ClientAppUsageMetrics - get with cluster not found shall return an empty list
   [Documentation]
   ...  get clientappusage metrics with cluster not found
   ...  verify empty list is returned

   ${metrics}=  Get Client App Usage Metrics  region=US  selector=latency  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClientAppUsageMetrics - get with operator not found shall return an empty list
   [Documentation]
   ...  get clientappusage metrics with operator not found
   ...  verify empty list is returned

   ${metrics}=  Get Client App Usage Metrics  region=US  selector=latency  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClientAppUsageMetrics - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  get clientappusage metrics with cloudlet not found
   ...  verify empty list is returned

   ${metrics}=  Get Client App Usage Metrics  region=US  selector=latency  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=automation_api_app  app_version=1.0  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClientAppUsageMetrics - get with appname not found shall return an empty list
   [Documentation]
   ...  get clientappusage metrics with cloudlet not found
   ...  verify empty list is returned

   ${metrics}=  Get Client App Usage Metrics  region=US  selector=latency  last=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=xx  app_version=1.0  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClientAppUsageMetrics - get without region shall return error
   [Documentation]
   ...  get clientappusage metrics without region 
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"no region specified"}

ClientAppUsageMetrics - get with invalid rawdata shall return error
   [Documentation]
   ...  get clientappusage metrics without region
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  raw_data=x  selector=latency  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=bool, got=string, field=RawData, offset=253"}

ClientAppUsageMetrics - get with latency and deviceos shall return error
   [Documentation]
   ...  get clientappusage metrics without region
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  device_os=x   selector=latency  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"DeviceOS not allowed for appinst latency metric"}

ClientAppUsageMetrics - get with latency and devicetype shall return error
   [Documentation]
   ...  get clientappusage metrics without region
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  device_type=x   selector=latency  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"DeviceType not allowed for appinst latency metric"}

ClientAppUsageMetrics - get with latency and data_network_type shall return error
   [Documentation]
   ...  get clientappusage metrics without region
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  data_network_type=x   selector=latency  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"DataNetworkType not allowed for appinst latency metric"}

ClientAppUsageMetrics - get with deviceinfo and locationtile shall return error
   [Documentation]
   ...  get clientappusage metrics with deviceinfo and locationtile
   ...  verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  data_network_type=x   selector=deviceinfo  last=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  location_tile=x  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"LocationTile not allowed for appinst deviceinfo metric"}

*** Keywords ***
Setup
    ${token}=  Get Super Token

    ${dev_manager_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
    ${op_manager_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${token}
    Set Suite Variable  ${dev_manager_token}
    Set Suite Variable  ${op_manager_token}

