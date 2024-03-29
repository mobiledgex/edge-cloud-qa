*** Settings ***
Documentation   Cloudlet Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationSunnydaleCloudletStage
${operator}=                       GDDT
	
*** Test Cases ***
# this works now
# ECQ-1554
#CloudletMetrics - get with no cloudlet name shall return error
#   [Documentation]
#   ...  get cloudlet metrics with no cloudlet name
#   ...  verify error
#
#   ${token}=  Get Token
#	
#   Run Keyword and Expect Error  *  Get Cloudlet Metrics  region=US  operator_name=${operator}  selector=utilization  last=1  token=${token}  use_defaults=${False}
#
#   ${status_code}=  Response Status Code
#   ${body} =        Response Body
#
#   Should Be Equal As Integers  ${status_code}  400
#   Should Be Equal              ${body}         {"message":"Cloudlet details must be present"}

# ECQ-1555
CloudletMetrics - get with no operator name shall return error
   [Documentation]
   ...  - get cloudlet metrics with no operator name
   ...  - verify error

   ${token}=  Get Token

   # utilization	
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=utilization  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   # ipusage
   ${error2}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=ipusage  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Cloudlet details must be present"}

# ECQ-1556
CloudletMetrics - get with no cloudlet/operator name shall return error
   [Documentation]
   ...  - get cloudlet metrics with no cloudlet/operator name
   ...  - verify error

   ${token}=  Get Token

   # utilization	
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  region=US  selector=utilization  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Cloudlet details must be present"}

   # ipusage
   ${error2}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  region=US  selector=ipusage  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Cloudlet details must be present"}

# ECQ-1557
CloudletMetrics - get with no token name shall return error
   [Documentation]
   ...  - get cloudlet metrics with no token
   ...  - verify error

   ${token}=  Get Token

   # utilization
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  region=US  selector=utilization  last=1  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No bearer token found"}

   # ipusage
   ${error2}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  region=US  selector=ipusage  last=1  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"No bearer token found"}

# ECQ-1558
CloudletMetrics - get with no selector name shall return error
   [Documentation]
   ...  - get cloudlet metrics with no selector
   ...  - verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  region=US  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid cloudlet selector: , must be one of \\\\"network\\\\", \\\\"utilization\\\\", \\\\"ipusage\\\\""} 

# ECQ-1559
CloudletMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  - get cloudlet metrics with invalid selector
   ...  - verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=xx  region=US  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid cloudlet selector: xx, must be one of \\\\"network\\\\", \\\\"utilization\\\\", \\\\"ipusage\\\\""}

# ECQ-1560
CloudletMetrics - get with invalid start time shall return error
   [Documentation]
   ...  - get cloudlet metrics with invalid start time
   ...  - verify error

   ${token}=  Get Token

   # utilization
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  region=US  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""} 
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}
   # EDGECLOUD-1332
   # EDGECLOUD-1569 metrics with invalid start/end time give strange date in error message

   # ipusage
   ${error2}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=ipusage  region=US  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   #Should Contain  ${error2}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}

# ECQ-1561
CloudletMetrics - get with invalid end time shall return error
   [Documentation]
   ...  - get cloudlet metrics with invalid end time
   ...  - verify error

   ${token}=  Get Token

   # utilization
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  region=US  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""} 
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}

   # EDGECLOUD-1332
   # EDGECLOUD-1569 metrics with invalid start/end time give strange date in error message

   # ipusage
   ${error2}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=ipusage  region=US  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   #Should Contain  ${error2}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}

# ECQ-1562
CloudletMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  - get cloudlet metrics with invalid start/end time
   ...  - verify error

   ${token}=  Get Token

   # utilization
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  region=US  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""} 
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}

   # EDGECLOUD-1332
   # EDGECLOUD-1569 metrics with invalid start/end time give strange date in error message

   # ipusage
   ${error2}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=ipusage  region=US  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   #Should Contain  ${error2}  {"message":"Invalid data: parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error2}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\""}

# ECQ-1563
CloudletMetrics - get with invalid last shall return error
   [Documentation]
   ...  - get cloudlet metrics with invalid last
   ...  - verify error

   ${token}=  Get Token

   # utilization
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  region=US  last=x  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Limit\\\\" at offset

   # EDGECLOUD-1332

   # ipusage
   ${error2}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=ipusage  region=US  last=x  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Limit\\\\" at offset

# ECQ-1564
CloudletMetrics - get with operator not found shall return an empty list
   [Documentation]
   ...  - get cloudlet metrics with operator not found
   ...  - verify empty list is returned

   ${token}=  Get Token

   # utilization
   ${metrics}=  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  selector=utilization  region=US  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   # ipusage
   ${metrics}=  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  selector=ipusage  region=US  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

# ECQ-1565
CloudletMetrics - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  - get cloudlet metrics with cloudlet not found
   ...  - verify empty list is returned

   ${token}=  Get Token

   # utilization
   ${metrics}=  Get Cloudlet Metrics  cloudlet_name=xx  operator_org_name=${operator}  selector=utilization  region=US  last=1  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   # ipusage
   ${metrics}=  Get Cloudlet Metrics  cloudlet_name=xx  operator_org_name=${operator}  selector=ipusage  region=US  last=1  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

# ECQ-1603
CloudletMetrics - get without region shall return error
   [Documentation]
   ...  - get cloudlet metrics without region 
   ...  - verify error

   ${token}=  Get Token

   # utilization
   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=utilization  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

   # ipusage
   ${error2}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  selector=ipusage  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"No region specified"}

# ECQ-3634
CloudletMetrics - get with invalid cloudlet shall return error
   [Documentation]
   ...  - get app metrics with invalid cloudlet args
   ...  - verify error

   ${token}=  Get Token

   ${inject}=  Set Variable  \\'\\;drop measurment \"cloudlet-ipusage\"

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  selector=utilization  last=1  cloudlet_name=${inject}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudlet"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cloudlet Metrics  selector=utilization  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${inject}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudletorg"}')

