*** Settings ***
Documentation   Cloudlet Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${cloudlet_name_openstack_shared}=   automationBonnCloudlet
${operator}=                       TDG
	
*** Test Cases ***
CloudletMetrics - get with no cloudlet name shall return error
   [Documentation]
   ...  get cloudlet metrics with no cloudlet name
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  region=US  operator_name=${operator}  selector=utilization  last=1  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Cloudlet details must be present"}

CloudletMetrics - get with no operator name shall return error
   [Documentation]
   ...  get cloudlet metrics with no operator name
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_shared}  selector=utilization  last=1  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Cloudlet details must be present"}

CloudletMetrics - get with no cloudlet/operator name shall return error
   [Documentation]
   ...  get cloudlet metrics with no cloudlet/operator name
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  region=US  selector=utilization  last=1  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Cloudlet details must be present"}

CloudletMetrics - get with no token name shall return error
   [Documentation]
   ...  get cloudlet metrics with no token
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator}  region=US  selector=utilization  last=1  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"no bearer token found"}

CloudletMetrics - get with no selector name shall return error
   [Documentation]
   ...  get cloudlet metrics with no selector
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator}  region=US  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Invalid selector in a request"}

CloudletMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  get cloudlet metrics with invalid selector
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator}  selector=xx  region=US  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Invalid selector in a request"}

CloudletMetrics - get with invalid start time shall return error
   [Documentation]
   ...  get cloudlet metrics with invalid start time
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator}  selector=utilization  region=US  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   # EDGECLOUD-1332

   Should Be Equal As Integers  ${status_code}  400
   Should Contain               ${body}         {"message":"Invalid XXX data: code=400, message=parsing time 

CloudletMetrics - get with invalid end time shall return error
   [Documentation]
   ...  get cloudlet metrics with invalid end time
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator}  selector=utilization  region=US  end_time=2019-09  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   # EDGECLOUD-1332

   Should Be Equal As Integers  ${status_code}  400
   Should Contain               ${body}         {"message":"Invalid XXX data: code=400, message=parsing time

CloudletMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  get cloudlet metrics with invalid start/end time
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator}  selector=utilization  region=US  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   # EDGECLOUD-1332

   Should Be Equal As Integers  ${status_code}  400
   Should Contain               ${body}         {"message":"Invalid XXX data: code=400, message=parsing time

CloudletMetrics - get with invalid last shall return error
   [Documentation]
   ...  get cloudlet metrics with invalid last
   ...  verify error

   ${token}=  Get Token
	
   Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator}  selector=utilization  region=US  last=x  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   # EDGECLOUD-1332

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Invalid xxxx data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=136"} 

CloudletMetrics - get with operator not found shall return an empty list
   [Documentation]
   ...  get cloudlet metrics with operator not found
   ...  verify empty list is returned

   ${token}=  Get Token
	
   ${metrics}=  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=xx  selector=utilization  region=US  token=${token}  use_defaults=${False}
	
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

CloudletMetrics - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  get cloudlet metrics with cloudlet not found
   ...  verify empty list is returned

   ${token}=  Get Token
	
   ${metrics}=  Get Cloudlet Metrics  cloudlet_name=xx  operator_name=${operator}  selector=utilization  region=US  last=1  token=${token}  use_defaults=${False}

   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}


CloudletMetrics - get without region shall return error
   [Documentation]
   ...  get cloudlet metrics without region 
   ...  verify error

   ${token}=  Get Token

   Run Keyword and Expect Error  *  Get Cloudlet Metrics  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator}  selector=utilization  token=${token}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"no region specified"}

