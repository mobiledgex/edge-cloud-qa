*** Settings ***
Documentation   clientcloudletusage Metrics Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudletStage
${operator}=                       TDG
	
*** Test Cases ***
# ECQ-3433
ClientCloudletUsageMetrics - get with no cloudlet org shall return error
   [Documentation]
   ...  - get clientappusage metrics with no cloudlet org
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=deviceinfo  limit=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=x  limit=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

# ECQ-3434
ClientCloudletUsageMetrics - Developer shall not be able to get metrics
   [Documentation]
   ...  - get clientcloudletusage metrics as DeveloperViewer/DeveloperContributor/DeveloperManager
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${dev_manager_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${dev_contributor_token}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}
   ${dev_viewer_token}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Client Cloudlet Usage Metrics  region=US  selector=latency  operator_org_name=${operator}  limit=1  token=${dev_manager_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Client Cloudlet Usage Metrics  region=US  selector=latency  operator_org_name=${operator}  limit=1  token=${dev_contributor_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Client Cloudlet Usage Metrics  region=US  selector=latency  operator_org_name=${operator}  limit=1  token=${dev_viewer_token}  use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Client Cloudlet Usage Metrics  region=US  selector=deviceinfo  operator_org_name=${operator}  limit=1  token=${dev_manager_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Client Cloudlet Usage Metrics  region=US  selector=deviceinfo  operator_org_name=${operator}  limit=1  token=${dev_contributor_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Client Cloudlet Usage Metrics  region=US  selector=deviceinfo  operator_org_name=${operator}  limit=1  token=${dev_viewer_token}  use_defaults=${False}

# ECQ-3435
ClientCloudletUsageMetrics - operator get with no cloudlet org shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with no cloudlet org as operator
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${op_manager_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  cloudlet_name=tmocloud-1  limit=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=deviceinfo  cloudlet_name=tmocloud-1  limit=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=x  cloudlet_name=tmocloud-1  limit=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

# ECQ-3436
ClientCloudletUsageMetrics - get with selector=custom shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with selector=custom
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=custom  operator_org_name=${operator}  limit=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid clientcloudletusage selector: custom"}

# ECQ-3437
ClientCloudletUsageMetrics - get with no token name shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with no token
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  operator_org_name=developer  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No bearer token found"}

# ECQ-3438
ClientCloudletUsageMetrics - get with no selector name shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with no selector
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid clientcloudletusage selector: "} 

# ECQ-3439
ClientCloudletUsageMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid selector
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=xx  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}

   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid clientcloudletusage selector: xx"}

# ECQ-3440
ClientCloudletUsageMetrics - get with invalid start time shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid start time
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-3441
ClientCloudletUsageMetrics - get with invalid end time shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid end time
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-3442
ClientCloudletUsageMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid start/end time
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-3576
ClientCloudletUsageMetrics - get with invalid start age shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid start age
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  start_age=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"2019-09-26T04:01:01\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-3577
ClientCloudletUsageMetrics - get with invalid end age shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid end age
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  end_age=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"2019-09-26T04:01:01\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-3578
ClientCloudletUsageMetrics - get with invalid start/end age shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid start/end age
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  start_age=x  end_age=2019-09  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-3600
ClientCloudletUsageMetrics - get with start age newer than end age shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with start age newer than /end age
   ...  - verify error

   #  EDGECLOUD-5269 - metrics request with startage lower than endage gives incorrect error 

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  start_age=2m  end_age=3m  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Start age must be before (older than) end age"}')

# ECQ-3443
ClientCloudletUsageMetrics - get with invalid limit shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid limit
   ...  - verify error

   [Tags]  DMEPersistentConnection

   # EDGECLOUD-5254 dme metrics with negative limit/numsamples needs better error handling
   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=x  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Limit\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=-1  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"xxxxInvalid data: json: cannot unmarshal string into Go struct field RegionClientCloudletUsageMetrics.Limit of type int"}')

# ECQ-3579
ClientCloudletUsageMetrics - get with invalid numsamples shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with invalid numsamples
   ...  - verify error

   # EDGECLOUD-5254 dme metrics with negative limit/numsamples needs better error handling

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  number_samples=x  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"NumSamples\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  number_samples=-1  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"xxxxxxxxInvalid data: json: cannot unmarshal string into Go struct field RegionClientCloudletUsageMetrics.Limit of type int"}')

# ECQ-3444
ClientCloudletUsageMetrics - get with operator not found shall return an empty list
   [Documentation]
   ...  - get clientcloudletusage metrics with operator not found
   ...  - verify empty list is returned

   [Tags]  DMEPersistentConnection

   ${metrics}=  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

# ECQ-3445
ClientCloudletUsageMetrics - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  - get clientcloudletusage metrics with cloudlet not found
   ...  - verify empty list is returned

   [Tags]  DMEPersistentConnection

   ${metrics}=  Get Client Cloudlet Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet_name_openstack_metrics  operator_org_name=TDG  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

# ECQ-3446
ClientCloudletUsageMetrics - get without region shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics without region 
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  selector=latency  limit=1  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

# rawdata no longer supported
# ECQ-3447
#ClientCloudletUsageMetrics - get with invalid rawdata shall return error
#   [Documentation]
#   ...  - get clientcloudletusage metrics with invalid rawdata
#   ...  - verify error
#
#   [Tags]  DMEPersistentConnection
#
#   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  raw_data=x  selector=latency  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  {"message":"Invalid data: Unmarshal type error: expected=bool, got=string, field=RawData, offset=

# ECQ-3448
ClientCloudletUsageMetrics - get with latency and deviceos shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with latency and deviceos
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  device_os=x   selector=latency  limit=1  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}   token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"DeviceOS not allowed for cloudlet latency metric"}

# ECQ-3449
ClientCloudletUsageMetrics - get with latency and devicemodel shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with latency and devicemodel
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  device_model=x   selector=latency  limit=1  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"DeviceModel not allowed for cloudlet latency metric"}

# ECQ-3450
ClientCloudletUsageMetrics - get with deviceinfo and data_network_type shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with deviceinfo and data_network_type
   ...  - verify error

   [Tags]  DMEPersistentConnection

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  data_network_type=x   selector=deviceinfo  limit=1  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"DataNetworkType not allowed for cloudlet deviceinfo metric"}

# ECQ-3607
ClientCloudletUsageMetrics - get with numsamples and limit shall return error
   [Documentation]
   ...  - get clientcloudletusage metrics with numsamples and limit
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=latency  number_samples=1  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Only one of Limit or NumSamples can be specified"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client Cloudlet Usage Metrics  region=US  selector=deviceinfo  number_samples=1  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Only one of Limit or NumSamples can be specified"}')

*** Keywords ***
Setup
    ${token}=  Get Super Token

    Set Suite Variable  ${token}
