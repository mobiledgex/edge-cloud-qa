*** Settings ***
Documentation   clientappusage Metrics Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationSunnydaleCloudletStage
${operator}=                       GDDT
${region}=  US
	
*** Test Cases ***
# ECQ-3454
ClientAppUsageMetrics - get with no app org shall return error
   [Documentation]
   ...  - get clientappusage metrics with no app org
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either App organization or Cloudlet organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  limit=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either App organization or Cloudlet organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=x  limit=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either App organization or Cloudlet organization"}

# ECQ-3455
ClientAppUsageMetrics - developer get with no app org shall return error
   [Documentation]
   ...  - get clientappusage metrics with no app org as developer
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  operator_org_name=${operator}  limit=1  token=${dev_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Developers please specify the App Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  operator_org_name=${operator}  limit=1  token=${dev_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Developers please specify the App Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=x  operator_org_name=${operator}  limit=1  token=${dev_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Developers please specify the App Organization"}

# ECQ-3456
ClientAppUsageMetrics - operator get with no cloudlet org shall return error
   [Documentation]
   ...  - get clientappusage metrics with no cloudlet org as operator
   ...  - verify error

   @{cloudlet_list}=  Create List  ${cloudlet_name_fake}
   ${pool_return}=  Create Cloudlet Pool  region=${region}  token=${op_manager_token}  operator_org_name=${operator_name_fake}  cloudlet_list=${cloudlet_list}
   Create Cloudlet Pool Access Invitation  region=${region}  cloudlet_pool_name=${pool_return['data']['key']['name']}  cloudlet_pool_org_name=${operator_name_fake}  developer_org_name=${developer_org_name_automation}  token=${op_manager_token}
   Create Cloudlet Pool Access Response    region=${region}  cloudlet_pool_name=${pool_return['data']['key']['name']}  cloudlet_pool_org_name=${operator_name_fake}  developer_org_name=${developer_org_name_automation}  decision=accept  token=${dev_manager_token}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  token=${op_manager_token}  developer_org_name=${developer_org_name_automation}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  developer_org_name=${developer_org_name_automation}  limit=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=x  developer_org_name=${developer_org_name_automation}  limit=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

# ECQ-3457
ClientAppUsageMetrics - operator get with no cloudlet pools shall return error
   [Documentation]
   ...  - get clientappusage metrics with no cloudlet pools as operator
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  developer_org_name=${operator}  operator_org_name=dmuus  limit=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  developer_org_name=${operator}  operator_org_name=dmuus  limit=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=x  developer_org_name=${operator}  operator_org_name=dmuus  limit=1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

# ECQ-3458
ClientAppUsageMetrics - get with selector=custom shall return error
   [Documentation]
   ...  - get clientappusage metrics with selector=custom
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=custom  developer_org_name=${operator}  limit=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Provided selector \\\\"custom\\\\" is not valid, must provide only one of \\\\"latency\\\\", \\\\"deviceinfo\\\\""}

# ECQ-3459
ClientAppUsageMetrics - get with no token shall return error
   [Documentation]
   ...  - get clientappusage metrics with no token
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No bearer token found"}

# ECQ-3460
ClientAppUsageMetrics - get with no selector shall return error
   [Documentation]
   ...  - get clientappusage metrics with no selector
   ...  - verify error
   # EDGECLOUD-5255 invalid limit/numsamples/startage/endage for clientapiusage/clientappusage/clientcloudletusage needs better error handling
   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Provided selector \\\\"\\\\" is not valid, must provide only one of \\\\"latency\\\\", \\\\"deviceinfo\\\\""} 

# ECQ-3461
ClientAppUsageMetrics - get with invalid selector shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid selector
   ...  - verify error
   # EDGECLOUD-5255 invalid limit/numsamples/startage/endage for clientapiusage/clientappusage/clientcloudletusage needs better error handling

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=xx  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}

   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Provided selector \\\\"xx\\\\" is not valid, must provide only one of \\\\"latency\\\\", \\\\"deviceinfo\\\\""}

# ECQ-3462
ClientAppUsageMetrics - get with invalid start time shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid start time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-3463
ClientAppUsageMetrics - get with invalid end time shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid end time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-3464
ClientAppUsageMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid start/end time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-3572
ClientAppUsageMetrics - get with invalid start age shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid start age 
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_age=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"2019-09-26T04:01:01\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-3573
ClientAppUsageMetrics - get with invalid end age shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid end age
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  end_age=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"2019-09-26T04:01:01\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-3574
ClientAppUsageMetrics - get with invalid start/end age shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid start/end age
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_age=x  end_age=2019-09  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-3601
ClientAppUsageMetrics - get with start age newer than end age shall return error
   [Documentation]
   ...  - get clientappusage metrics with start age newer than /end age
   ...  - verify error

   #  EDGECLOUD-5269 - metrics request with startage lower than endage gives incorrect error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet  operator_org_name=operator  start_age=2m  end_age=3m  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Start age must be before (older than) end age"}')

# ECQ-3465
ClientAppUsageMetrics - get with invalid limit shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid limit
   ...  - verify error

   # EDGECLOUD-5254 dme metrics with negative limit/numsamples needs better error handling

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=x  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Limit\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  limit=-1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"xxxxxxxxInvalid data: json: cannot unmarshal string into Go struct field RegionClientAppUsageMetrics.Limit of type int"}')

# ECQ-3575
ClientAppUsageMetrics - get with invalid numsamples shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid numsamples
   ...  - verify error

   # EDGECLOUD-5254 dme metrics with negative limit/numsamples needs better error handling

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  number_samples=x  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid data: json: cannot unmarshal string into Go struct field RegionClientAppUsageMetrics.NumSamples of type int"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  number_samples=-1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"xxxxxxxxInvalid data: json: cannot unmarshal string into Go struct field RegionClientAppUsageMetrics.Limit of type int"}')

# ECQ-3466
ClientAppUsageMetrics - get with cluster not found shall return an empty list
   [Documentation]
   ...  - get clientappusage metrics with cluster not found
   ...  - verify empty list is returned

   ${metrics}=  Get Client App Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  operator_org_name=GDDT  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

# ECQ-3467
ClientAppUsageMetrics - get with operator not found shall return an empty list
   [Documentation]
   ...  - get clientappusage metrics with operator not found
   ...  - verify empty list is returned

   ${metrics}=  Get Client App Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=${cloudlet_name_openstack_metrics}  app_name=automation_api_app  app_version=1.0  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

# ECQ-3468
ClientAppUsageMetrics - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  - get clientappusage metrics with cloudlet not found
   ...  - verify empty list is returned

   ${metrics}=  Get Client App Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=automation_api_app  app_version=1.0  operator_org_name=GDDT  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

# ECQ-3469
ClientAppUsageMetrics - get with appname not found shall return an empty list
   [Documentation]
   ...  - get clientappusage metrics with cloudlet not found
   ...  - verify empty list is returned

   ${metrics}=  Get Client App Usage Metrics  region=US  selector=latency  limit=1  cloudlet_name=cloudlet_name_openstack_metrics  app_name=xx  app_version=1.0  operator_org_name=GDDT  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

# ECQ-3470
ClientAppUsageMetrics - get without region shall return error
   [Documentation]
   ...  - get clientappusage metrics without region 
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

# rawdata no longer supported
# ECQ-3471
#ClientAppUsageMetrics - get with invalid rawdata shall return error
#   [Documentation]
#   ...  - get clientappusage metrics with invalid rawdata
#   ...  - verify error
#
#   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  raw_data=x  selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  {"message":"Invalid data: Unmarshal type error: expected=bool, got=string, field=RawData, offset=253"}

# ECQ-3472
ClientAppUsageMetrics - get with latency and deviceos shall return error
   [Documentation]
   ...  - get clientappusage metrics with latency and deviceos
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  device_os=x   selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"DeviceOS not allowed for appinst latency metric"}

# ECQ-3473
ClientAppUsageMetrics - get with latency and devicemodel shall return error
   [Documentation]
   ...  - get clientappusage metrics with latency and devicemodel
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  device_model=x   selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"DeviceModel not allowed for appinst latency metric"}

# we now support this: EDGECLOUD-5213 Allow developers to see data network type for latency metrics
# ECQ-3474
#ClientAppUsageMetrics - get with latency and data_network_type shall return error
#   [Documentation]
#   ...  - get clientappusage metrics with latency and data_network_type
#   ...  - verify error
#
#   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  data_network_type=x   selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  {"message":"DataNetworkType not allowed for appinst latency metric"}

# ECQ-3475
ClientAppUsageMetrics - get with deviceinfo and locationtile shall return error
   [Documentation]
   ...  - get clientappusage metrics with deviceinfo and locationtile
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  data_network_type=x   selector=deviceinfo  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  location_tile=-90.998922,30.993940_-91.007905,31.002985_1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"LocationTile not allowed for appinst deviceinfo metric"}

# ECQ-3606
ClientAppUsageMetrics - get with numsamples and limit shall return error
   [Documentation]
   ...  - get clientappusage metrics with numsamples and limit
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=latency  number_samples=1  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Only one of Limit or NumSamples can be specified"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  selector=deviceinfo  number_samples=1  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Only one of Limit or NumSamples can be specified"}')

# ECQ-3632
ClientAppUsageMetrics - get with invalid locationtile shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid locationtile
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  data_network_type=x   selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  location_tile=x  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid format for the location tile."}') 

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  region=US  data_network_type=x   selector=latency  limit=1  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  location_tile=-90.998922,30.993940_-91.007905a  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid format for the location tile."}')

# ECQ-3637
ClientAppUsageMetrics - get with invalid app/cluster/cloudlet shall return error
   [Documentation]
   ...  - get clientappusage metrics with invalid app/cluster/cloudlet args
   ...  - verify error

   ${token}=  Get Token

   ${inject}=  Set Variable  \\'\\;drop measurment \"cloudlet-ipusage\"

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  app_name=${inject}  app_version=1.0  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid app"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  app_name=automation_api_app  app_version=${inject}  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid appver"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  app_name=automation_api_app  app_version=1.0  cluster_instance_name=${inject}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cluster"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  cloudlet_name=${inject}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudlet"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${inject}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudletorg"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=${inject}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid apporg"}')

   ${error}=  Run Keyword and Expect Error  *  Get Client App Usage Metrics  selector=latency  app_name=automation_api_app  app_version=1.0  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  cluster_instance_developer_org_name=${inject}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid clusterorg"}')

*** Keywords ***
Setup
    ${token}=  Get Super Token

    ${dev_manager_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
    ${op_manager_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${token}
    Set Suite Variable  ${dev_manager_token}
    Set Suite Variable  ${op_manager_token}

