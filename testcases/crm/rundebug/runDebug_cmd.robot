*** Settings ***
Documentation  runDebug

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library  Process
Library  OperatingSystem

#Test Setup      Setup
Test Teardown   Cleanup provisioning


*** Variables ***
${app_name}  andy
${developer_name}  MobiledgeX
${operator_name_openstack}  GDDT
${no_cpu_inprog}=  no cpu profiling in progress
${ntype_shep}=  shepherd
${ntype_crm}=  crm
${stop-cpu-profile}=  stop-cpu-profile
${region}=  EU
${cloudlet_name_openstack_dedicated}  automationParadiseCloudlet
${unknown_cmd}=  Unknown cmd
${unknown_cmd_oscmd}=  Unknown cmd oscmd
${unknown_cmd_crmcmd}=  Unknown cmd crmcmd
${not_supported}=  not supported
${invalid_txt}=  adjsx
${timeout_request}=  request timed out
${bin}=  bin  
${yaml}=  yaml
${go_top_kb}=  kB
${go_top_flat}=  flat%
${go_top_cum}=  cum%
${go_top_sum}=  sum%
${go_top_regexp}=  go 
${go_top_nodes}=  nodes
${go_top_k8s}=  k8s
${go_top_google}=  google
${go_top_build}=  Build
${go_top_type}=  Type
${go_top_time}=  Time
${go_top_showing}=  Showing
${go_top_100}=  100%
${go_top_total}=  total
${mem_prof_64base}=  H4sIAAAAAAAE
${started_base64}=  started. output will be base64 encoded go tool pprof file contents
${in_progress_base64}=  cpu profiling already in progress
${not_progress_base64}=  no cpu profiling in progress
${server_id}=  ID
${server_name}=  Name
${server_ram}=  RAM
${server_disk}=  Disk
${server_vcpus}=  VCPUs
${server_ispublic}=  Is Public
${server_status}=  Status
${server_networks}=  Networks
${server_image}=  Image
${server_flavor}=  Flavor
${server_mobiledgex}=  mobiledgex
${mcctlcmd}=  mcctl  --addr https://console-qa.mobiledgex.net:443  --skipverify region  RunDebug region\=EU type\=crm cloudlet\=automationParadiseCloudlet cmd\=oscmd args\="openstack flavor list" shell=yes


*** Test Cases ***
#ECQ-2187
RunDebug - cmd node_type set to shepherd and cmd stop-cpu-profile timeout 5s
    [Documentation]
    ...  send runDebug specifying node_type shepherd
    ...  verify stop-cpu-profile on shepherd node_type


      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=${stop-cpu-profile}  node_type=${ntype_shep}  timeout=5s

      ${type}=  Set Variable  ${node}[data][node][type]
      ${output}=  Set Variable  ${node}[data][output]
      
      Should Be Equal  ${type}  ${ntype_shep}
      Should Contain  ${output}  ${no_cpu_inprog}

      ${cmd_blank}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=  node_type=
      ${check_blank}=  Set Variable  ${cmd_blank}[0][data][output]

      Should Contain  ${check_blank}  ${unknown_cmd}

      ${cmd_invalid}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=${invalid_txt}  node_type=
      ${check_invalid}=  Set Variable  ${cmd_invalid}[0][data][output]

      Should Contain  ${check_invalid}  ${unknown_cmd}

#ECQ-2188      
RunDebug - cmd stop-cpu-profile without specifying node_type timeout 8s
    [Documentation]
    ...  send runDebug without specifying node_type
    ...  verify return information shows node_type crm and shepherd for automationParadiseCloudlet
    ...  verify stop-cpu-profile applied to both node types


      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=${stop-cpu-profile}  timeout=8s

      ${type}=  Set Variable  ${node}[0][data][node][type]
      ${type2}=  Set Variable  ${node}[-1][data][node][type]
      ${type3}=  Set Variable  ${node}[0][data][output]
      ${type4}=  Set Variable  ${node}[-1][data][output]

      Should Contain Any  ${type}  ${ntype_shep}  ${ntype_crm}
      Should Contain Any  ${type2}  ${ntype_shep}  ${ntype_crm}
      Should Be Equal  ${type3}  ${no_cpu_inprog}
      Should Be Equal  ${type4}  ${no_cpu_inprog}

      ${cmd_blank}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=
      ${check_blank}=  Set Variable  ${cmd_blank}[0][data][output]

      Should Contain  ${check_blank}  ${unknown_cmd}

      ${cmd_invalid}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=${invalid_txt}
      ${check_invalid}=  Set Variable  ${cmd_invalid}[0][data][output]

      Should Contain  ${check_invalid}  ${unknown_cmd}

#ECQ-2189
RunDebug - cmd disable-debug-levels request should return information
    [Documentation]
    ...  send runDebug cmd disable-debug-levels
    ...  verify type output disable-debug-levels is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=disable-debug-levels  node_type=shepherd

      ${type}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  disabled debug levels 

#ECQ-2190
RunDebug - cmd disable-debug-levels second request should return information
    [Documentation]
    ...  send runDebug cmd disable-debug-levels
    ...  verify output disable-debug-levels is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=disable-debug-levels  node_type=shepherd

      ${type}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  disabled debug levels
#ECQ-2191
RunDebug - cmd enable-debug-levels request should return information
    [Documentation]
    ...  send runDebug cmd enable-debug-levels
    ...  verify output enable-debug-levels is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=enable-debug-levels  node_type=shepherd

      ${type}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  enabled debug levels
#ECQ-2192
RunDebug - cmd enable-debug-levels a second time should return information
    [Documentation]
    ...  send runDebug cmd enable-debug-levels a second time
    ...  verify output enable-debug-levels is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=enable-debug-levels  node_type=shepherd

      ${type}=  Set Variable  ${node}[data][output]}

      Should Contain  ${type}  enabled debug levels

#ECQ-2193
RunDebug - cmd get-mem-profile request should return information
    [Documentation]
    ...  send runDebug cmd get-mem-profile
    ...  verify cmd get-mem-profile returns a valid mem profile requested
    ...  verify decoded output with go returns valid mem top table
          
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=get-mem-profile  node_type=shepherd

      ${memtype}=  Set Variable  ${node}[data][output]
       
      Create File  /tmp/output.base64  ${memtype} 
      Run Process  cat /tmp/output.base64 | base64 --decode  stdout=/tmp/mem.pprof  shell=yes 
      ${results}=  Run Process  go  tool  pprof  --top  /tmp/mem.pprof 

      Should Contain  ${memtype}  ${mem_prof_64base}
      Should Contain  ${results.stdout}  ${go_top_kb}
      Should Contain  ${results.stdout}  ${go_top_flat}
      Should Contain  ${results.stdout}  ${go_top_cum}
      Should Contain  ${results.stdout}  ${go_top_sum}
      Should Contain  ${results.stdout}  ${go_top_nodes}

#ECQ-2194
RunDebug - cmd get-mem-profile request twice in a row should return information
    [Documentation]
    ...  send runDebug cmd get-mem-profile twice in a row
    ...  verify cmd get-mem-profile returns a valid mem profile requested
    ...  verify decoded output with go returns valid mem top table

      RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=get-mem-profile  node_type=shepherd
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=get-mem-profile  node_type=shepherd

      ${memtype}=  Set Variable  ${node}[data][output]

      Create File  /tmp/output.base64  ${memtype}
      Run Process  cat /tmp/output.base64 | base64 --decode  stdout=/tmp/mem.pprof  shell=yes
      ${results}=  Run Process  go  tool  pprof  --top  /tmp/mem.pprof

      Should Contain  ${memtype}  ${mem_prof_64base}
      Should Contain  ${results.stdout}  ${go_top_build}
      Should Contain  ${results.stdout}  ${go_top_type}
      Should Contain  ${results.stdout}  ${go_top_time}
      Should Contain  ${results.stdout}  ${go_top_showing}
      Should Contain  ${results.stdout}  ${go_top_100}
      Should Contain  ${results.stdout}  ${go_top_total}
#ECQ-2195
RunDebug - cmd refresh-internal-certs request should return information
    [Documentation]
    ...  send runDebug cmd refresh-internal-certs
    ...  verify refresh-internal-certs returns triggered refresh for both node types
    ...  verify type crm and shepherd return triggered refresh

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=refresh-internal-certs  #node_type=shepherd

      ${type}=  Set Variable  ${node}[0][data][node][type]
      ${type2}=  Set Variable  ${node}[-1][data][node][type]
      ${refresh}=  Set Variable  ${node}[0][data][output]
      ${refresh2}=  Set Variable  ${node}[-1][data][output]

      Should Contain Any  ${type}  ${ntype_shep}  ${ntype_crm}
      Should Contain Any  ${type2}  ${ntype_shep}  ${ntype_crm}
      Should Contain  ${refresh}  triggered refresh
      Should Contain  ${refresh2}  triggered refresh

#ECQ-2196
RunDebug - cmd refresh-internal-certs for node type shepherd
    [Documentation]
    ...  send runDebug cmd refresh-internal-certs for node tyep shepherd
    ...  verify cmd refresh-internal-certs triggers refresh for node type shepherd

      #RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=refresh-internal-certs  node_type=${ntype_shep}
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=refresh-internal-certs  node_type=${ntype_shep}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${refresh}=  Set Variable  ${node}[data][output]

      Should Contain  ${refresh}  triggered refresh
      Should Contain  ${type}  ${ntype_shep}
#ECQ-2197
RunDebug - cmd refresh-internal-certs for node type crm
    [Documentation]
    ...  send runDebug cmd refresh-internal-certs on node tyep crm
    ...  verify cmd refresh-internal-certs triggers refresh for node type crm

      #RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=refresh-internal-certs  node_type=${ntype_crm}
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=refresh-internal-certs  node_type=${ntype_crm}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${refresh}=  Set Variable  ${node}[data][output]

      Should Contain  ${refresh}  triggered refresh
      Should Contain  ${type}  ${ntype_crm}

#ECQ-2198
RunDebug - cmd show-debug-levels for node type shepherd should return information
    [Documentation]
    ...  send runDebug cmd show-debug-levels for node type shepherd
    ...  verify show-debug-levels returns information requested for node type shepherd

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=show-debug-levels  node_type=${ntype_shep}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${levels}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  ${ntype_shep}
      Should Contain Any  ${levels}  api  notify  infra  metric  mongoose
#ECQ-2199
RunDebug - cmd show-debug-levels for node type crm should return information
    [Documentation]
    ...  send runDebug cmd show-debug-levels for node type crm
    ...  verify show-debug-levels returns information requested for node type crm

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=show-debug-levels  node_type=${ntype_crm}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${levels}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  ${ntype_crm}
      Should Contain Any  ${levels}  api  notify  infra  metric  other

#ECQ-2200
RunDebug - cmd start-cpu-profile for node type shepherd from already started state
    [Documentation]
    ...  send runDebug cmd start-cpu-profile when profile is already started for node type shepherd
    ...  verify show-start-cpu-profile returns cpu profiling already in progress for node type shepherd

      RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=start-cpu-profile  node_type=${ntype_shep}
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=start-cpu-profile  node_type=${ntype_shep}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${pprof}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  ${ntype_shep}
      Should Contain  ${pprof}  ${in_progress_base64}

#ECQ-2201
RunDebug - cmd start-cpu-profile for node type shepherd from stop state
    [Documentation]
    ...  send runDebug cmd stop-cpu-profile for node type shepherd to setup test
    ...  send runDebug cmd start-cpu-profile when profile is already stopped for node type shepherd
    ...  verify show-start-cpu-profile returns cpu profiling in progress for node type shepherd

      RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=stop-cpu-profile  node_type=${ntype_shep}
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=start-cpu-profile  node_type=${ntype_shep}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${pprof}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  ${ntype_shep}
      Should Contain  ${pprof}  ${started_base64}

#ECQ-2202
RunDebug - cmd show-stop-cpu-profile that is already in progress for node type shepherd
    [Documentation]
    ...  send runDebug cmd start-cpu-profil for node type shepherd to setup test
    ...  send runDebug cmd stop-cpu-profile that is already in progress for node type shepherd
    ...  verify stop-cpu-profile for node type shepherd returns base64 mem output

      RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=start-cpu-profile  node_type=${ntype_shep}
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=stop-cpu-profile  node_type=${ntype_shep}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${pprof}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  ${ntype_shep}
      Should Contain  ${pprof}  ${mem_prof_64base}

#ECQ-2204
RunDebug - cmd show-stop-cpu-profile for already stopped cpu profile for node type shepherd
    [Documentation]
    ...  send runDebug cmd stop-cpu-profile for node type shepherd
    ...  verify stop-cpu-profile for node type shepherd returns no cpu profile in progress 

      RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=stop-cpu-profile  node_type=${ntype_shep}
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=stop-cpu-profile  node_type=${ntype_shep}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${pprof}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  ${ntype_shep}
      Should Contain  ${pprof}  ${not_progress_base64}

#ECQ-2203
RunDebug - cmd show-stop-cpu-profile not already in progress for node type crm
    [Documentation]
    ...  send runDebug cmd stop-cpu-profile
    ...  verify stop-cpu-profile for node type crm returns no cpu profile in progress

      RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=stop-cpu-profile  node_type=${ntype_crm}
      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=stop-cpu-profile  node_type=${ntype_crm}

      ${type}=  Set Variable  ${node}[data][node][type]
      ${pprof}=  Set Variable  ${node}[data][output]

      Should Contain  ${type}  ${ntype_crm}
      Should Contain  ${pprof}  ${not_progress_base64}

#  output: |
#    +--------------------------------------+---------------+-------+------+-----------+-------+-----------+
#    | ID                                   | Name          |   RAM | Disk | Ephemeral | VCPUs | Is Public |
#    +--------------------------------------+---------------+-------+------+-----------+-------+-----------+
#    | 0bb494c8-adf0-47a7-a408-8b666311bfb2 | m4.xxlarge16  | 65536 |  120 |         0 |    16 | True
#ECQ-2205
RunDebug - cmd=oscmd args openstack flavor list node type crm on targeted crm should return information
    [Documentation]
    ...  send runDebug cmd=oscmd  args openstack flavor list node type crm cloudlet automationParadiseCloudlet
    ...  verify args openstack flavor list output is returned


      ${stack}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=oscmd  args=openstack flavor list  node_type=${ntype_crm}

      ${output}=  Set Variable  ${stack}[data][output]

      Should Contain  ${output}  ${server_id}
      Should Contain  ${output}  ${server_name}
      Should Contain  ${output}  ${server_ram}
      Should Contain  ${output}  ${server_disk}
      Should Contain  ${output}  ${server_vcpus}
      Should Contain  ${output}  ${server_ispublic}


#  output: |
#    +--------------------------------------+---------------+-------+------+-----------+-------+-----------+
#    | ID                                   | Name          |   RAM | Disk | Ephemeral | VCPUs | Is Public |
#    +--------------------------------------+---------------+-------+------+-----------+-------+-----------+
#    | 0bb494c8-adf0-47a7-a408-8b666311bfb2 | m4.xxlarge16  | 65536 |  120 |         0 |    16 | True
#ECQ-2206
RunDebug - blanket cmd=oscmd args openstack flavor list EU only node type crm cloudlets should return information timeout 9s
    [Documentation]
    ...  send runDebug cmd args openstack flavor list query to all EU crm cloudlets
    ...  verify args openstack flavor list output is returned for openstack crm type only

      ${stack}=  RunDebug  region=EU  command=oscmd  args=openstack flavor list  node_type=${ntype_crm}  timeout=9s

      ${cnt}=  Get Length  ${stack}

      FOR  ${key}  IN RANGE  ${cnt}
         Should Contain  ${stack}[${key}][data][output]  ${server_id}
         Should Contain  ${stack}[${key}][data][output]  ${server_name}
         Should Contain  ${stack}[${key}][data][output]  ${server_ram}
         Should Contain  ${stack}[${key}][data][output]  ${server_disk}
         Should Contain  ${stack}[${key}][data][output]  ${server_vcpus}
         Should Contain  ${stack}[${key}][data][output]  ${server_ispublic}
         Should Contain  ${stack}[${key}][data][node][type]  ${ntype_crm} 
      END


#  output: |
#    +--------------------------------------+---------------------------------------------------------------------------------------------+--------+-----------------------------------------------------------------------------------------+------------------------------------+---------------+
#    | ID                                   | Name                                                                                        | Status | Networks                                                                                | Image                              | Flavor        |
#    +--------------------------------------+---------------------------------------------------------------------------------------------+--------+-----------------------------------------------------------------------------------------+------------------------------------+---------------+
#    | 7bf4d000-b9db-4abd-b7e7-c3f8f177d096 | mex-k8s-master-mw-k8s-cld60-mw-k8-cluster-mobiledgex                                        | ACTIVE | mex-k8s-net-1=10.101.6.10                                                               | mobiledgex-4.0-beta2               | m4.medium     |
#    | b3b9217d-c9b0-4f40-8a5e-46143dbafcc5 | mex-k8s-node-1-mw-k8s-cld60-mw-k8-cluster-mobiledgex                                        | ACTIVE | mex-k8s-net-1=10.101.6.101                                                              | mobiledgex-4.0-beta2
#ECQ-2207
RunDebug - targeted cmd=oscmd args openstack server list on dedicated cloudlet node type crm should return information
    [Documentation]
    ...  send runDebug cmd args openstack server list on automationParadiseCloudlet 
    ...  verify args openstack flavor list output is returned for targeted cloudlet node type crm

      ${stack}=  RunDebug  region=EU  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=oscmd  args=openstack server list  node_type=${ntype_crm}

      Should Contain  ${stack}[data][output]  ${server_id}
      Should Contain  ${stack}[data][output]  ${server_name}
      Should Contain  ${stack}[data][output]  ${server_status}
      Should Contain  ${stack}[data][output]  ${server_networks}
      Should Contain  ${stack}[data][output]  ${server_image}
      Should Contain  ${stack}[data][output]  ${server_flavor}
      Should Contain  ${stack}[data][output]  ${server_mobiledgex}
      Should Contain  ${stack}[data][node][type]  ${ntype_crm}


#  output: |
#    +--------------------------------------+---------------------------------------------------------------------------------------------+--------+-----------------------------------------------------------------------------------------+------------------------------------+---------------+
#    | ID                                   | Name                                                                                        | Status | Networks                                                                                | Image                              | Flavor        |
#    +--------------------------------------+---------------------------------------------------------------------------------------------+--------+-----------------------------------------------------------------------------------------+------------------------------------+---------------+
#    | 7bf4d000-b9db-4abd-b7e7-c3f8f177d096 | mex-k8s-master-mw-k8s-cld60-mw-k8-cluster-mobiledgex                                        | ACTIVE | mex-k8s-net-1=10.101.6.10                                                               | mobiledgex-4.0-beta2               | m4.medium     |
#    | b3b9217d-c9b0-4f40-8a5e-46143dbafcc5 | mex-k8s-node-1-mw-k8s-cld60-mw-k8-cluster-mobiledgex                                        | ACTIVE | mex-k8s-net-1=10.101.6.101                                                              | mobiledgex-4.0-beta2
#ECQ-2208
RunDebug - cmd=oscmd args openstack server list on all cloudlets node type crm should return information
    [Documentation]
    ...  send runDebug cmd args openstack server list on all cloudlets
    ...  verify args openstack server list output is returned for all crm node type only

      ${stack}=  RunDebug  region=EU  command=oscmd  args=openstack server list  node_type=${ntype_crm}

      ${cnt}=  Get Length  ${stack}

      FOR  ${key}  IN RANGE  ${cnt}
         Should Contain  ${stack}[${key}][data][output]  ${server_id}
         Should Contain  ${stack}[${key}][data][output]  ${server_name}
         Should Contain  ${stack}[${key}][data][output]  ${server_status}
         Should Contain  ${stack}[${key}][data][output]  ${server_networks}
         Should Contain  ${stack}[${key}][data][output]  ${server_image}
         Should Contain  ${stack}[${key}][data][output]  ${server_flavor}
         Should Contain  ${stack}[${key}][data][output]  ${server_mobiledgex}
         Should Contain  ${stack}[${key}][data][node][type]  ${ntype_crm}
      END


#ECQ-2209
RunDebug - cmd=oscmd args openstack flavor list on all cloudlets node type shepherd is invalid
    [Documentation]
    ...  send runDebug cmd args openstack flavor list on all cloudlets
    ...  verify args openstack flavor list output returns not valid command for all shepherd node type

      ${stack}=  RunDebug  region=EU  command=oscmd  args=openstack flavor list  node_type=${ntype_shep}


      Request Should Be Invalid  ${stack}


#ECQ-2210
RunDebug - cmd=oscmd args openstack server list on targeted cloudlet node type shepherd is invalid
    [Documentation]
    ...  send runDebug cmd args openstack server list on all cloudlets
    ...  verify args openstack server list output returns not valid command for node type shepherd 

       ${stack}=  RunDebug  region=EU  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=oscmd  args=openstack server list  node_type=${ntype_shep}

      ${type}=  Set Variable  ${stack}[data][node][type]
      ${output}=  Set Variable  ${stack}[data][output]

      Should Contain  ${type}  ${ntype_shep}
      Should Contain  ${output}  ${unknown_cmd_oscmd}


#ECQ-2211
RunDebug - cmd=crmcmd args ls on targeted cloudlet node type crm is valid
    [Documentation]
    ...  send runDebug cmd=crmcmd ls on targeted cloudlet
    ...  verify args ls output returns valid data for node type crm

       ${stack}=  RunDebug  region=EU  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=crmcmd  args=ls  node_type=${ntype_crm}

      ${type}=  Set Variable  ${stack}[data][node][type]
      ${output}=  Set Variable  ${stack}[data][output]

      Should Contain  ${type}  ${ntype_crm}
      Should Contain  ${output}  ${yaml}
      Should Contain  ${output}  ${bin}

#ECQ-2212
RunDebug - cmd=crmcmd args ls on targeted cloudlet node type shepherd is invalid
    [Documentation]
    ...  send runDebug cmd=crmcmd ls on targeted node tyep shepherd cloudlet
    ...  verify cmd=crmcmd args ls output is not valid for node type shepherd

       ${stack}=  RunDebug  region=EU  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=crmcmd  args=ls  node_type=${ntype_shep}

      ${type}=  Set Variable  ${stack}[data][node][type]
      ${output}=  Set Variable  ${stack}[data][output]

      Should Contain  ${type}  ${ntype_shep}
      Should Contain  ${output}  ${unknown_cmd_crmcmd}

#ECQ-2213
RunDebug - timeout option test for request times out on blanket request oscmd server list
    [Documentation]
    ...  send runDebug cmd args openstack server list on all cloudlets timeout=5ms
    ...  verify args openstack server list output returns request timed out for all cloudlets
    ...  verify RunDebug returns list of cloudlets queried despite timeout

      ${stack}=  RunDebug  region=EU  command=oscmd  args=openstack server list  node_type=${ntype_crm}  timeout=5ms

      ${cnt}=  Get Length  ${stack}
      Should Be True   ${cnt} > 0
      
      Request Should Be Timedout  ${stack}

#ECQ-2214
RunDebug - timeout option test for request times out on target cloudlet request oscmd server list
    [Documentation]
    ...  send runDebug cmd args openstack server list on targeted cloudlet timeout=5ms
    ...  verify args openstack server list output returns request timed out for all cloudlets
    ...  verify RunDebug returns cloudlet quiried despite timeout

      ${stack}=  RunDebug  region=EU  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=oscmd  args=openstack server list  node_type=${ntype_crm}  timeout=5ms

      ${cnt}=  Get Length  ${stack}
      Should Be True  ${cnt} > 0
      Should Be Equal  ${stack}[data][output]  ${timeout_request}
      Should Be True   ${cnt} > 0

#Adding 9 new test cases to cover cmd enable or disable sample logging added June 6th 2020
#mcctl --addr https://console-qa.mobiledgex.net:443 --skipverify region  RunDebug region=EU cloudlet=automationParadiseCloudlet cmd=disable-sample-logging
#ECQ-
RunDebug - cmd disable-sample-logging node_type shepherd request should return information
    [Documentation]
    ...  send runDebug cmd disable-sample-logs for node type shepherd
    ...  verify output disabled log sampling for node type shepherd is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=disable-sample-logging  node_type=shepherd

      ${type}=  Set Variable  ${node}[data][output]
      ${type2}=  Set Variable  ${node}[data][node][type]

      Should Contain  ${type}  disabled log sampling
      Should Contain  ${type2}  shepherd 

#ECQ-
RunDebug - cmd disable-sample-logging node_type shepherd second request should return information
    [Documentation]
    ...  send runDebug cmd disable-sample-logging more than once for node type shepherd
    ...  verify output sends disabled log sampling for each request for node type shepherd

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=disable-sample-logging  node_type=shepherd

      ${type}=  Set Variable  ${node}[data][output]
      ${type2}=  Set Variable  ${node}[data][node][type]

      Should Contain  ${type}  disabled log sampling
      Should Contain  ${type2}  shepherd

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=disable-sample-logging  node_type=shepherd


      ${type}=  Set Variable  ${node}[data][output]
      ${type2}=  Set Variable  ${node}[data][node][type]

      Should Contain  ${type}  disabled log sampling
      Should Contain  ${type2}  shepherd

#ECQ-
RunDebug - cmd enable-sample-logging request node_type shepherd should return information
    [Documentation]
    ...  send runDebug cmd enable-sample-logging for node type shepherd
    ...  verify output enabled log sampling for node type shepherd is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=enable-sample-logging  node_type=shepherd

      ${type}=  Set Variable  ${node}[data][output]
      ${type2}=  Set Variable  ${node}[data][node][type]

      Should Contain  ${type}  enabled log sampling
      Should Contain  ${type2}  shepherd
#ECQ-
RunDebug - cmd enable-sample-logging node_type shepherd second request should return information
    [Documentation]
    ...  send runDebug cmd enable-sample-logging more than once for node tyep shepherd
    ...  verify output sends enabled log sampling for each request for node type shepherd

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=enable-sample-logging  node_type=shepherd

      ${type}=  Set Variable  ${node}[data][output]
      ${type2}=  Set Variable  ${node}[data][node][type]

      Should Contain  ${type}  enabled log sampling
      Should Contain  ${type2}  shepherd

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=enable-sample-logging  node_type=shepherd


      ${type}=  Set Variable  ${node}[data][output]
      ${type2}=  Set Variable  ${node}[data][node][type]

      Should Contain  ${type}  enabled log sampling
      Should Contain  ${type2}  shepherd

#ECQ-
RunDebug - cmd enable-sample-logging node_type not specified will set crm and shepherd
    [Documentation]
    ...  send runDebug cmd enable-sample-logging a second time
    ...  verify output enabled log sampling for both node types is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=enable-sample-logging

      ${type}=  Set Variable  ${node}[0][data][output]
      ${type2}=  Set Variable  ${node}[0][data][node][type]

      ${type3}=  Set Variable  ${node}[-1][data][output]}
      ${type4}=  Set Variable  ${node}[-1][data][node][type]

      Should Contain  ${type}  enabled log sampling
      Should Contain Any  ${type2}  crm  shepherd 
      Should Contain  ${type3}  enabled log sampling
      Should Contain Any  ${type4}  crm  shepherd

#ECQ-
RunDebug - cmd enable-sample-logging request node_type crm should return information
    [Documentation]
    ...  send runDebug cmd enable-sample-logging
    ...  verify output log sampling enabled for node type crm is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=enable-sample-logging  node_type=crm

      ${type}=  Set Variable  ${node}[data][output]
      ${type2}=  Set Variable  ${node}[data][node][type]

      Should Contain  ${type}  enabled log sampling
      Should Contain  ${type2}  crm

#ECQ-
RunDebug - cmd disable-sample-logging request node_type crm should return information
    [Documentation]
    ...  send runDebug cmd disable-sample-logging
    ...  verify output log sampling disabled for node type crm is returned

      ${node}=  RunDebug  cloudlet_name=${cloudlet_name_openstack_dedicated}  command=disable-sample-logging  node_type=crm

      ${type}=  Set Variable  ${node}[data][output]
      ${type2}=  Set Variable  ${node}[data][node][type]

      Should Contain  ${type}  disabled log sampling
      Should Contain  ${type2}  crm

#ECQ-
RunDebug - blanket request to enable-sample-logging will set all cloudlet node type shepherd
    [Documentation]
    ...  send runDebug enable-sample-logging node type shepherd on all cloudlets
    ...  verify  output is returned for all crm node type shepherd and unknown cmd for non os crm

      ${sample}=  RunDebug  region=EU  command=enable-sample-logging  node_type=${ntype_shep}

      ${cnt}=  Get Length  ${sample}

      FOR  ${key}  IN RANGE  ${cnt}
         Should Contain Any  ${sample}[${key}][data][output]  enabled log sampling  Unknown cmd enable-sample-logging
         Should Contain Any  ${sample}[${key}][data][node][type]  ${ntype_shep}
      END

#ECQ-
RunDebug - blanket request to enable-sample-logging will set all cloudlet node type crm
    [Documentation]
    ...  send runDebug enable-sample-logging node type shepherd on all cloudlets
    ...  verify  output is returned for all crm node type shepherd and unknown cmd for non os crm

      ${sample}=  RunDebug  region=EU  command=enable-sample-logging  node_type=${ntype_crm}

      ${cnt}=  Get Length  ${sample}

      FOR  ${key}  IN RANGE  ${cnt}
         Should Contain Any  ${sample}[${key}][data][output]  enabled log sampling  Unknown cmd enable-sample-logging
         Should Contain Any  ${sample}[${key}][data][node][type]  ${ntype_crm}
      END

*** Keywords ***

Setup
    Create Flavor  region=${region}
    Create App  region=${region}  developer_org_name=${developer_name}  app_name=${app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/platos/images/server_ping_threaded:6.0
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=autocluster

Request Should Be Timedout
   [Arguments]  ${newstack}

   FOR  ${key}  IN   @{newstack} 
      Should Be Equal  ${key}[data][output]  ${timeout_request}
   END
 
Request Should Be Invalid
   [Arguments]  ${newstack}

   FOR  ${key}  IN   @{newstack}
      Should Contain  ${key}[data][output]  ${unknown_cmd_oscmd}
   END


Find Node
   [Arguments]  ${node}  ${type}  ${name}

   ${fd}=  Set Variable  ${None}
   FOR  ${d}  IN  @{node}
   log to console  ${d['data']['key']['node']} ${type}
      ${fd}=  Run Keyword If  '${d['data']['key']['node']}' == '${type}' and '${d['data']['key']['name']}' == '${name}'  Set Variable  ${d}
      ...  ELSE  Set Variable  ${fd}
   Run Keyword If  '${d['data']['key']['node']}' == '${type}' and '${d['data']['key']['node']}' == '${name}'    [Return]  ${d}
   log to console  ${fd}
   END

   Return]  ${fd}

