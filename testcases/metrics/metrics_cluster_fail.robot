*** Settings ***
Documentation   Cluster Metrics Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudletStage
${operator}=                       TDG
	
*** Test Cases ***
ClusterMetrics - get with no operator name shall return error
   [Documentation]
   ...  get cluster metrics with no operator name
   ...  verify error

   ${token}=  Get Token

   # cpu	
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=cpu  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either App organization or Cloudlet organization"}

   # mem
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=mem  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

   # network 
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=network  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

   # tcp 
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=tcp  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

   # udp
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=udp  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

   # disk 
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=disk  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

ClusterMetrics - get with no cloudlet/operator name shall return error
   [Documentation]
   ...  get cluster metrics with no cloudlet/operator name
   ...  verify error

   ${token}=  Get Token

   # cpu
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either App organization or Cloudlet organization"}

   # mem
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

   # network
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

   # tcp
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

   # udp
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

   # disk
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either App organization or Cloudlet organization"}

ClusterMetrics - get with no token name shall return error
   [Documentation]
   ...  get cluster metrics with no token
   ...  verify error

   ${token}=  Get Token

   # cpu
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No bearer token found"}

   # mem
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"No bearer token found"}

   # network
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  last=1  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"No bearer token found"}

   # tcp
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  last=1  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"No bearer token found"}

   # udp
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"No bearer token found"}

   # disk
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"No bearer token found"}

ClusterMetrics - get with no selector name shall return error
   [Documentation]
   ...  get cluster metrics with no selector
   ...  verify error

   ${token}=  Get Token
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid cluster selector: "} 

ClusterMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  get cluster metrics with invalid selector
   ...  verify error

   ${token}=  Get Token
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=xx  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}

   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid cluster selector: xx"}

ClusterMetrics - get with invalid start time shall return error
   [Documentation]
   ...  get cluster metrics with invalid start time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""} 

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

ClusterMetrics - get with invalid end time shall return error
   [Documentation]
   ...  get cluster metrics with invalid end time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

ClusterMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  get cluster metrics with invalid start/end time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}

ClusterMetrics - get with invalid last shall return error
   [Documentation]
   ...  get cluster metrics with invalid last
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid data: code=400, message=Unmarshal type error: expected=int, got=string, field=Last, offset=

ClusterMetrics - get with cluster not found shall return an empty list
   [Documentation]
   ...  get cluster metrics with cluster not found
   ...  verify empty list is returned

   ${token}=  Get Token

   #${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster}  cloudlet_name=${cloudlet}  operator_name=${operator}  developer_name=${developer}  selector=${selector}  last=1

   ${metrics}=  Get Cluster Metrics  region=US  selector=cpu  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=disk  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=tcp  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=udp  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=network  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=mem  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=xx  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClusterMetrics - get with operator not found shall return an empty list
   [Documentation]
   ...  get cluster metrics with operator not found
   ...  verify empty list is returned

   ${token}=  Get Token

   #${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster}  cloudlet_name=${cloudlet}  operator_name=${operator}  developer_name=${developer}  selector=${selector}  last=1

   ${metrics}=  Get Cluster Metrics  region=US  selector=cpu  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=disk  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=tcp  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=udp  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=network  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=mem  last=1  cloudlet_name=${cloudlet_name_openstack_metrics}  cluster_name=autoclusterautomation  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClusterMetrics - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  get cloudlet metrics with cloudlet not found
   ...  verify empty list is returned

   ${token}=  Get Token

   #${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster}  cloudlet_name=${cloudlet}  operator_name=${operator}  developer_name=${developer}  selector=${selector}  last=1

   ${metrics}=  Get Cluster Metrics  region=US  selector=cpu  last=1  cloudlet_name=cloudlet_name_openstack_metrics  cluster_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=disk  last=1  cloudlet_name=cloudlet_name_openstack_metrics  cluster_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=mem  last=1  cloudlet_name=cloudlet_name_openstack_metrics  cluster_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=tcp  last=1  cloudlet_name=cloudlet_name_openstack_metrics  cluster_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=udp  last=1  cloudlet_name=cloudlet_name_openstack_metrics  cluster_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

   ${metrics}=  Get Cluster Metrics  region=US  selector=network  last=1  cloudlet_name=cloudlet_name_openstack_metrics  cluster_name=autoclusterautomation  operator_org_name=TDG  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${metrics['data'][0]['Series']}        ${None}
   Should Be Equal  ${metrics['data'][0]['Messages']}      ${None}

ClusterMetrics - get without region shall return error
   [Documentation]
   ...  get cluster metrics without region 
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=cpu  last=1  cluster_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=disk  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=mem  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=tcp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=udp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=network  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}
