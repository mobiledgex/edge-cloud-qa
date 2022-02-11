*** Settings ***
Documentation   cloudletpoolsage Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudletStage
${operator}=                       TDG
${region}=  US
	
*** Test Cases ***
# ECQ-4330
CloudletPoolUsage - get with no cloudletpool shall return error
   [Documentation]
   ...  - get cloudletpoolusage with no cloudletpool
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  cloudlet_pool_name=x  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  operator_org_name=tmus  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')


# ECQ-4331
CloudletPoolUsage - developer get with no cloudletpool shall return error
   [Documentation]
   ...  - get cloudletpoolusage with no cloudletpool as developer
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${dev_manager_token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  cloudlet_pool_name=x  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${dev_manager_token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  operator_org_name=tmus  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${dev_manager_token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')

# ECQ-4332
CloudletPoolUsage - operator get with no cloudletpool shall return error
   [Documentation]
   ...  - get cloudletpoolusage with no cloudletpool as operator
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${op_manager_token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  operator_org_name=tmus  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${op_manager_token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  cloudlet_pool_name=tmus  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${op_manager_token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"CloudletPool details must be present"}')

# ECQ-4333
CloudletPoolUsage - get with no token shall return error
   [Documentation]
   ...  - get cloudletpoolsage with no token
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No bearer token found"}

# ECQ-4334
CloudletPoolUsage - get with invalid start time shall return error
   [Documentation]
   ...  - get appusage with invalid start time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  cloudlet_pool_name=cloudlet  operator_org_name=operator  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}

# ECQ-4335
CloudletPoolUsage - get with invalid end time shall return error
   [Documentation]
   ...  - get cloudletpoolusage with invalid end time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  cloudlet_pool_name=cloudlet  operator_org_name=operator  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}

# ECQ-4336
CloudletPoolUsage - get with invalid start/end time shall return error
   [Documentation]
   ...  - get cloudletpoolusage with invalid start/end time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  cloudlet_pool_name=cloudlet  operator_org_name=operator  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}

# ECQ-4337
CloudletPoolUsage - get with cloudlet pool not found shall return an empty list
   [Documentation]
   ...  - get cloudletpool usage with pool not found
   ...  - verify empty list is returned

   ${metrics}=  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_pool_name=${cloudlet_name_openstack_metrics}  operator_org_name=operator  token=${token}  use_defaults=${False}
   Should Be Empty  ${metrics['data']}

# ECQ-4338
CloudletPoolUsage - get without region shall return error
   [Documentation]
   ...  - get cloudletpoolusage without region 
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_pool_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

# ECQ-4339
CloudletPoolUsage - get with invalid cloudlet pool shall return error
   [Documentation]
   ...  - get cloudletpoolusage with invalid cloudlet pool args
   ...  - verify error

   #${token}=  Get Token

   ${inject}=  Set Variable  \\'\\;drop measurment \"cloudlet-ipusage\"

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_pool_name=${inject}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudlet"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_pool_name=${cloudlet_name_openstack_metrics}  operator_org_name=${inject}   token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudletorg"}')

# ECQ-4340
CloudletPoolUsage - get with invalid showvmappsonly shall return error
   [Documentation]
   ...  - get cloudletpoolusage with invalid showvmappsonly args
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_pool_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}   show_vm_apps_only=x  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"ShowVmAppsOnly\\\\" at offset 169, valid values are true, false"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_pool_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  show_vm_apps_only=1  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"ShowVmAppsOnly\\\\" at offset 169, valid values are true, false"}')

   ${inject}=  Set Variable  \\'\\;drop measurment \"cloudlet-ipusage\"
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Pool Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_pool_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  show_vm_apps_only=${inject}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"ShowVmAppsOnly\\\\" at offset 210, valid values are true, false"}')

*** Keywords ***
Setup
    ${token}=  Get Super Token

    ${dev_manager_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
    ${op_manager_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${token}
    Set Suite Variable  ${dev_manager_token}
    Set Suite Variable  ${op_manager_token}

