*** Settings ***
Documentation   Cluster Metrics Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBuckhornCloudlet
${operator}=                       GDDT

${cluster_name}=   andycluster
${developer_name}=  automation_api
	
*** Test Cases ***
ClusterMetrics - get with no cluster info shall return error
   [Documentation]
   ...  get cloudlet metrics with no cluster info
   ...  verify error

   ${token}=  Get Token

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1
	
   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Cluster details must be present"}

ClusterMetrics - get with no developer name shall return error
   [Documentation]
   ...  get cluster metrics with no developer name
   ...  verify error

   ${token}=  Get Token

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=cpu  last=1

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Cluster details must be present"}

ClusterMetrics - get with no token name shall return error
   [Documentation]
   ...  get cluster metrics with no token
   ...  verify error

   ${token}=  Get Token

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  selector=cpu  last=1  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"no bearer token found"}

ClusterMetrics - get with no selector name shall return error
   [Documentation]
   ...  get cluster metrics with no selector
   ...  verify error

   ${token}=  Get Token

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  last=1

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Invalid cluster selector: "}

ClusterMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  get cluster metrics with invalid selector
   ...  verify error

   ${token}=  Get Token

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  selector=xx  last=1

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"Invalid cluster selector: xx"}

ClusterMetrics - get with invalid start time shall return error
   [Documentation]
   ...  get cluster metrics with invalid start time
   ...  verify error

   #${token}=  Get Token

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  selector=cpu  start_time=2019-09-26T04:01:01  last=1

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   # EDGECLOUD-1332
   # EDGECLOUD-1569 metrics with invalid start/end time give strange date in error message

   Should Be Equal As Integers  ${status_code}  400
   Should Contain               ${body}         {"message":"Invalid POST data: code=400, message=parsing time \\"\\"2019-09-26T04:01:01\\"\\" into RFC3339 format failed. Example: \\"2006-01-02T15:04:05Z07:00\\""} 

ClusterMetrics - get with invalid end time shall return error
   [Documentation]
   ...  get cluster metrics with invalid end time
   ...  verify error

   #${token}=  Get Token

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  selector=cpu  end_time=2019-09  last=1
	
   ${status_code}=  Response Status Code
   ${body} =        Response Body

   # EDGECLOUD-1332
   # EDGECLOUD-1569 metrics with invalid start/end time give strange date in error message

   Should Be Equal As Integers  ${status_code}  400
   Should Contain               ${body}         {"message":"Invalid POST data: code=400, message=parsing time \\"\\"2019-09\\"\\" into RFC3339 format failed. Example: \\"2006-01-02T15:04:05Z07:00\\""} 

ClusterMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  get cluster metrics with invalid start/end time
   ...  verify error


   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  selector=cpu  start_time=x  end_time=2019-09  last=1

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   # EDGECLOUD-1569 metrics with invalid start/end time give strange date in error message

   Should Be Equal As Integers  ${status_code}  400
   Should Contain               ${body}         {"message":"Invalid POST data: code=400, message=parsing time \\"\\"x\\"\\" into RFC3339 format failed. Example: \\"2006-01-02T15:04:05Z07:00\\""}

ClusterMetrics - get with invalid last shall return error
   [Documentation]
   ...  get cluster metrics with invalid last
   ...  verify error

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  selector=cpu  last=x
	
   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Contain              ${body}         {"message":"Invalid POST data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset= 

ClusterMetrics - get with operator not found shall return an empty list
   [Documentation]
   ...  get cluster metrics with operator not found
   ...  verify empty list is returned

   ${metrics}=  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=operator  developer_name=${developer_name}  selector=cpu  last=1
	
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClusterMetrics - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  get cluster metrics with cloudlet not found
   ...  verify empty list is returned

   ${metrics}=  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=cloudlet_name_openstack_metrics  operator_name=${operator}  developer_name=${developer_name}  selector=cpu  last=1

   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClusterMetrics - get with cluster not found shall return an empty list
   [Documentation]
   ...  get cluster metrics with cluster not found
   ...  verify empty list is returned

   ${metrics}=  Get Cluster Metrics  region=US  cluster_instance_name=cluster_name  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  selector=cpu  last=1

   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClusterMetrics - get with developer not found shall return an empty list
   [Documentation]
   ...  get cluster metrics with developer not found
   ...  verify empty list is returned

   ${metrics}=  Get Cluster Metrics  region=US  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=eveloper_name  selector=cpu  last=1

   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClusterMetrics - get without region shall return error
   [Documentation]
   ...  get cluster metrics without region 
   ...  verify error

   Run Keyword and Expect Error  *  Get Cluster Metrics  cluster_instance_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=${developer_name}  selector=cpu  last=1

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  400
   Should Be Equal              ${body}         {"message":"no region specified"}

