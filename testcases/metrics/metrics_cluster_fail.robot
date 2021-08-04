*** Settings ***
Documentation   Cluster Metrics Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudletStage
${operator}=                       TDG
	
*** Test Cases ***
# ECQ-1936
ClusterMetrics - get with no operator name shall return error
   [Documentation]
   ...  get cluster metrics with no operator name
   ...  verify error

   ${token}=  Get Token

   # cpu	
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=cpu  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # mem
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=mem  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # network 
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=network  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # tcp 
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=tcp  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # udp
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=udp  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # disk 
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  selector=disk  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

# ECQ-1937
ClusterMetrics - get with no cloudlet/operator name shall return error
   [Documentation]
   ...  get cluster metrics with no cloudlet/operator name
   ...  verify error

   ${token}=  Get Token

   # cpu
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # mem
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # network
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # tcp
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # udp
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

   # disk
   ${error2}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  token=${token}  use_defaults=${False}
   Should Contain  ${error2}  code=400
   Should Contain  ${error2}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

# ECQ-1938
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

# ECQ-1939
ClusterMetrics - get with no selector name shall return error
   [Documentation]
   ...  get cluster metrics with no selector
   ...  verify error

   ${token}=  Get Token
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid cluster selector: "} 

# ECQ-1940
ClusterMetrics - get with invalid selector name shall return error
   [Documentation]
   ...  get cluster metrics with invalid selector
   ...  verify error

   ${token}=  Get Token
   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=xx  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}

   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid cluster selector: xx"}

# ECQ-1941
ClusterMetrics - get with invalid start time shall return error
   [Documentation]
   ...  get cluster metrics with invalid start time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""} 
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-1942
ClusterMetrics - get with invalid end time shall return error
   [Documentation]
   ...  get cluster metrics with invalid end time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"2019-09-26T04:01:01\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-1943
ClusterMetrics - get with invalid start/end time shall return error
   [Documentation]
   ...  get cluster metrics with invalid start/end time
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=1  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: parsing time \\\\"\\\\"x\\\\"\\\\" into RFC3339 format failed. Example: \\\\"2006-01-02T15:04:05Z07:00\\\\""}
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-1944
ClusterMetrics - get with invalid last shall return error
   [Documentation]
   ...  get cluster metrics with invalid last
   ...  verify error

   ${token}=  Get Token

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=cpu  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: Unmarshal type error: expected=int, got=string, field=Last, offset=
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Last\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=disk  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: Unmarshal type error: expected=int, got=string, field=Last, offset=
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Last\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=mem  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: Unmarshal type error: expected=int, got=string, field=Last, offset=
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Last\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=tcp  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: Unmarshal type error: expected=int, got=string, field=Last, offset=
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Last\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=udp  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: Unmarshal type error: expected=int, got=string, field=Last, offset=
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Last\\\\" at offset

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  selector=network  last=x  cluster_name=cluster  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   #Should Contain  ${error}  {"message":"Invalid data: Unmarshal type error: expected=int, got=string, field=Last, offset=
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal error: expected int, but got string for field \\\\"Last\\\\" at offset

# ECQ-1945
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

# ECQ-1946
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

# ECQ-1947
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

# ECQ-1948
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

# ECQ-3635
ClusterMetrics - get with invalid cluster/cloudlet shall return error
   [Documentation]
   ...  - get app metrics with invalid cluster/cloudlet args
   ...  - verify error

   ${token}=  Get Token

   ${inject}=  Set Variable  \\'\\;drop measurment \"cloudlet-ipusage\"

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=cpu  last=1  cluster_name=${inject}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cluster"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=cpu  last=1  cluster_name=autoclusterautomation  cloudlet_name=${inject}  operator_org_name=${operator}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudlet"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=cpu  last=1  cluster_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${inject}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudletorg"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Metrics  selector=cpu  last=1  cluster_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=${inject}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid clusterorg"}')

