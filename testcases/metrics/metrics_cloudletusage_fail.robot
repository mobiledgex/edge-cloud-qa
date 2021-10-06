*** Settings ***
Documentation   cloudletusage Metrics Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudletStage
${operator}=                       TDG
	
*** Test Cases ***
# ECQ-4024
CloudletUsageMetrics - get with no cloudlet org shall return error
   [Documentation]
   ...  - get cloudletusage metrics with no cloudlet org
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=flavorusage  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=x  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=x  cloudlet_name=tmocloud-1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

# ECQ-4025
CloudletUsageMetrics - Developer shall not be able to get metrics
   [Documentation]
   ...  - get cloudletusage metrics as DeveloperViewer/DeveloperContributor/DeveloperManager
   ...  - verify error

   ${dev_manager_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${dev_contributor_token}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}
   ${dev_viewer_token}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  operator_org_name=${operator}  token=${dev_manager_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  operator_org_name=${operator}  token=${dev_contributor_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  operator_org_name=${operator}  token=${dev_viewer_token}  use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Cloudlet Usage Metrics  region=US  selector=flavorusage  operator_org_name=${operator}  token=${dev_manager_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Cloudlet Usage Metrics  region=US  selector=flavorusage  operator_org_name=${operator}  token=${dev_contributor_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Get Cloudlet Usage Metrics  region=US  selector=flavorusage  operator_org_name=${operator}  token=${dev_viewer_token}  use_defaults=${False}

# ECQ-4026
CloudletUsageMetrics - operator get with no cloudlet org shall return error
   [Documentation]
   ...  - get cloudletusage metrics with no cloudlet org as operator
   ...  - verify error

   ${op_manager_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  cloudlet_name=tmocloud-1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=flavorusage  cloudlet_name=tmocloud-1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=x  cloudlet_name=tmocloud-1  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

# ECQ-4027
CloudletUsageMetrics - get with no token name shall return error
   [Documentation]
   ...  - get cloudletusage metrics with no token
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  operator_org_name=developer  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No bearer token found"}

# ECQ-4028
CloudletUsageMetrics - get with no selector name shall return error
   [Documentation]
   ...  - get cloudletusage metrics with no selector
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid cloudletusage selector: , must be one of \\\\"resourceusage\\\\", \\\\"flavorusage\\\\""} 

# ECQ-4029
CloudletUsageMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid selector
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=xx  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}

   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid cloudletusage selector: xx, must be one of \\\\"resourceusage\\\\", \\\\"flavorusage\\\\""}

# ECQ-4030
CloudletUsageMetrics - get with invalid start time shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid start time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  cloudlet_name=cloudlet  operator_org_name=operator  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-4031
CloudletUsageMetrics - get with invalid end time shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid end time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  cloudlet_name=cloudlet  operator_org_name=operator  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-4032
CloudletUsageMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid start/end time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  cloudlet_name=cloudlet  operator_org_name=operator  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-4033
CloudletUsageMetrics - get with invalid start age shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid start age
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  cloudlet_name=cloudlet  operator_org_name=operator  start_age=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"2019-09-26T04:01:01\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-4034
CloudletUsageMetrics - get with invalid end age shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid end age
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  cloudlet_name=cloudlet  operator_org_name=operator  end_age=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"2019-09-26T04:01:01\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-4035
CloudletUsageMetrics - get with invalid start/end age shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid start/end age
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  cloudlet_name=cloudlet  operator_org_name=operator  start_age=x  end_age=2019-09  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal duration \\\\"x\\\\" failed, valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

# ECQ-4036
CloudletUsageMetrics - get with start age newer than end age shall return error
   [Documentation]
   ...  - get cloudletusage metrics with start age newer than /end age
   ...  - verify error

   #  EDGECLOUD-5681 cloudletusage metrics with startage lower than endage should return error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  cloudlet_name=tmocloud-1  operator_org_name=tmus  start_age=2m  end_age=3m  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Start age must be before (older than) end age"}')

# ECQ-4037
CloudletUsageMetrics - get with invalid limit shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid limit
   ...  - verify error

   # EDGECLOUD-5680 cloudletusage metrics with negative limit/numsamples needs better error handling
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  limit=x  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Limit\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=flavorusage  limit=-1  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"xxxxInvalid data: json: cannot unmarshal string into Go struct field RegionClientCloudletUsageMetrics.Limit of type int"}')

# ECQ-4038
CloudletUsageMetrics - get with invalid numsamples shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid numsamples
   ...  - verify error

   # EDGECLOUD-5680 cloudletusage metrics with negative limit/numsamples needs better error handling

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  number_samples=x  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"NumSamples\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  number_samples=-1  cloudlet_name=cloudlet  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"xxxxxxxxInvalid data: json: cannot unmarshal string into Go struct field RegionClientCloudletUsageMetrics.Limit of type int"}')

# ECQ-4039
CloudletUsageMetrics - get with operator not found shall return error
   [Documentation]
   ...  - get cloudletusage metrics with operator not found
   ...  - verify error is returned

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  limit=1  cloudlet_name=tmocloud-1  operator_org_name=txmus  token=${token}  use_defaults=${False}
   Should Contain  ${error}  ('code=400', 'error={"message":"Cloudlet does not exist"}')

# ECQ-4040
CloudletUsageMetrics - get with cloudlet not found shall return error
   [Documentation]
   ...  - get cloudletusage metrics with cloudlet not found
   ...  - verify error is returned

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  limit=1  cloudlet_name=cloudlet_name_openstack_metrics  operator_org_name=TDG  token=${token}  use_defaults=${False}
   Should Contain  ${error}  ('code=400', 'error={"message":"Cloudlet does not exist"}')

# ECQ-4041
CloudletUsageMetrics - get without region shall return error
   [Documentation]
   ...  - get cloudletusage metrics without region 
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  selector=resourceusage  limit=1  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

# ECQ-4042
CloudletUsageMetrics - get with numsamples and limit shall return error
   [Documentation]
   ...  - get cloudletusage metrics with numsamples and limit
   ...  - verify error

   # EDGECLOUD-5682 cloudletusage with limit and numsamples should return error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=resourceusage  number_samples=1  limit=1  cloudlet_name=tmocloud-1  operator_org_name=tmus  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Only one of Limit or NumSamples can be specified"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  region=US  selector=flavorusage  number_samples=1  limit=1  cloudlet_name=tmocloud-1  operator_org_name=tmus  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Only one of Limit or NumSamples can be specified"}')

# ECQ-4043
CloudletUsageMetrics - get with invalid cloudlet shall return error
   [Documentation]
   ...  - get cloudletusage metrics with invalid cloudlet values
   ...  - verify error

   ${token}=  Get Token

   ${inject}=  Set Variable  \\'\\;drop measurment \"cloudlet-ipusage\"

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  selector=resourceusage  cloudlet_name=${inject}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudlet"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Usage Metrics  selector=resourceusage  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${inject}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudletorg"}')

*** Keywords ***
Setup
    ${token}=  Get Super Token

    Set Suite Variable  ${token}
