# -*- coding: robot -*-
*** Settings ***
Documentation  AccessCloudlet mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String


#Test Teardown  Cleanup Provisioning

Test Timeout  8m

*** Variables ***


${cloudlet_name_openstack}=  automationFrankfurtCloudlet
${cloudlet_name_openstack_shared}=  automationDusseldorfCloudlet
${cloudlet_name_openstack_dedicated}=  automationMunichCloudlet
#${cloudlet_name_openstack_dedicated}=  automationHamburgCloudlet
#${cloudlet_name_openstack_dedicated}=  automationDusseldorfCloudlet
${operator_name_openstack}=  TDG
${region}=  
${developer}=  MobiledgeX
${type_shep}=  shepherd
${type_crm}=  crm
${timeout}=  45s
${access_command2c}=  stty cols 210;docker logs --tail 100 crmserver >2&1 | grep
${node_name}=  automationDusseldorfCloudlet-TDG-pf
${mobiledgex_domain}=  mobiledgex.net
${platformvm}=
${sharedrootlb}=
${region_EU}=  EU
${region_US}=  US
${operator_org_name}=  packet
${cloudlet_name_vsphere}=  DFWVMW2
${cloudlet_name_vcd}=  automation-qa2-vcd-01
${operator_name_vsphere}=  packet
${operator_name_openstack}=  TDG
${operator_name_vcd}=  packet
${cloudlet_name}=  ${cloudlet_name_openstack_shared}
${operator_name}=  ${operator_name_openstack}
${cloudlet_platform_type}=  PlatformTypeOpenstack
#${cloudlet_platform_type}=  PlatformTypevSphere
#${cloudlet_platform_type}=  PlatformTypeVCD
${mobiledgex_domain}=  mobiledgex.net
${vs_nodename}=
${os_nodename}=
${vsphere_cluster_flavor_name}=  vsphere.m4.small
${cluster_flavor_name} =  vsphere.m4.small
${vs_clusterk8sconfigfile}=
${os_clusterk8sconfigfile}=
${nodenamevs} =
${nodenameos} =
${cluster_org}=  automation-dev-org
${tty_error4}=   ('runCommand failed with stderr:', Exception('Error: Cannot use tty, input is not a terminal\\nUsage: mcctl accesscloudlet [flags] [args]\\n\\nRequired Args:\\n  region        Region name\\n  cloudletorg   Organization of the cloudlet site\\n  cloudlet      Name of the cloudlet\\n\\nOptional Args:\\n  federatedorg  Federated operator organization who shared this cloudlet\\n  command       Command or Shell\\n  nodetype      Type of Cloudlet Mgmt Node\\n  nodename      Name of Cloudlet Mgmt Node\\n\\nFlags:\\n  -h, --help          help for accesscloudlet\\n  -i, --interactive   send stdin\\n  -t, --tty           treat stdin and stout as a tty\\n'))
${lb_dedicated}=  dedicatedrootlb


*** Test Cases ***

#ECQ-2965
AccessCloudlet - mcctl shall handle error messages
   [Documentation]
   ...  - send AccessCloudlet conditions for all error types
   ...  - verify expected error is returned 
   ...  - send AccessCloudlet missing required args
   ...  - verify expected error is returned

   [Template]  Fail AccessCloudlet Command Via mcctl

      Error: missing required args                                           region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}
      Error: parsing arg "notcloudletorg\=TDG" failed: invalid argument: key "notcloudletorg" not found   region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  notcloudletorg=${operator_name_openstack}   
      Error: missing required args: cloudlet                                 region=${region_US}  cloudletorg=${operator_name_openstack} nodetype=sharedrootlb  command=exit
      Error: missing required args: region                                                        cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack} nodetype=sharedrootlb  command=exit
      Error: Bad Request (400), No cloudlet mgmt node specified              region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  command=a
      Error: Bad Request (400), Unable to find specified cloudlet mgmt node  region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack} nodetype=sharedrootlb nodename=test  command=exit
      Error: Bad Request (400), Too many nodes matched                       region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack} nodetype=  command=exit
      Error: unable to fetch access URL                                      region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=  nodetype=sharedrootlb  command=exit
      Error: Bad Request (400), No run command specified                     region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}
      Error: Bad Request (400), Region "ZZ" not found                        region=ZZ            cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  command=exit
      Error: arg "Error:" not name=val format                                region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  command= exit


#ECQ-2966 
AccessCloudlet - mcctl shall pass cli commands to specified cloudlet and node
   [Documentation]
   ...  - send cli commands node type platformvm and sharedrootlb
   ...  - verify proper command is executed

#valid nodes: [{platformvm automationDusseldorfCloudlet-TDG-pf} {sharedrootlb automationdusseldorfcloudlet.tdg.mobiledgex.net} {dedicatedrootlb dockerdediated.automationdusseldorfcloudlet.tdg.mobiledgex.net}]

   [Template]  Check Response For CLI Sent

#platformvm
      crmserver  shepherd  cloudletPrometheus  region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  nodetype=platformvm  nodename=${platformvm}  command="docker ps;exit"
      command2c  shepherd  cloudletPrometheus  region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  nodetype=platformvm  nodename=${platformvm}  command="docker logs --tail 100 crmserver >2&1 | grep 140738018"
      empty      empty     shepherd            region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  nodetype=platformvm  nodename=${platformvm}  command="stty cols 210;docker logs --tail 12 shepherd"
      empty      empty     crmserver           region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  nodetype=platformvm  nodename=${platformvm}  command="stty cols 210;docker logs --tail 10 crmserver"
      logme      empty     empty               region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  nodetype=platformvm  nodename=${platformvm}  command="touch logme;ls -l"
      No such file or directory  empty  empty  region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  nodetype=platformvm  nodename=${platformvm}  command="rm logme;ls -l logme"
#sharedrootlb
      command2c  envoy     empty               region=${region_US}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudletorg=${operator_name_openstack}  nodetype=sharedrootlb  nodename=${sharedrootlb}  command="ls -lcth | grep nothing;exit"


#ECQ-2967
AccessCloudlet - mcctl shall pass cli commands to a dedicatedrootlb
   [Documentation]
    ...  create a dedicatedrootlb cluster inst and use accesscloudlet to login
    ...  verify mcctl accesscloudlet can login and issue commands to return docker and file information
    ...  verify the cluster k8s config file was created using cli ls command
    ...  verify error if input is not a terminal and -t for tty is used
   [Setup]  Setup
   [Template]  Check Dedicated Cluster For CLI Sent

#dedicatedrootlb vsphere - using to conservere resources
      CONTAINER  ID  envoy                            region=${region_US}  cloudlet=${cloudlet_name_vsphere}  cloudletorg=${operator_name_vsphere}  nodetype=dedicatedrootlb  nodename=${vs_nodename}  command="docker ps;exit"
      REPOSITORY  TAG  SIZE                           region=${region_US}  cloudlet=${cloudlet_name_vsphere}  cloudletorg=${operator_name_vsphere}  nodetype=dedicatedrootlb  nodename=${vs_nodename}  command="docker images;exit"
      ${vs_clusterk8sconfigfile}  kubeconfig  empty   region=${region_US}  cloudlet=${cloudlet_name_vsphere}  cloudletorg=${operator_name_vsphere}  nodetype=dedicatedrootlb  nodename=${vs_nodename}  command="ls -l;exit"


*** Keywords ***
Setup
   Create Flavor          ram=1024  vcpus=1  disk=1  region=US
   #Create Cluster #creating specific dedicatedrootlb on vsphere - using it to conservere resources for this mcctl test
   ${cluster_default}=  Get Default Cluster Name
   Set Suite Variable  ${cluster_default}
   ${flavor_name}=   Get Default Flavor Name
   ${region}=  Set Variable  US
   Log to Console  START creating cluster instance
   Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name_vsphere}  operator_org_name=${operator_name_vsphere}  cluster_name=${cluster_default}  number_nodes=0  number_masters=0  ip_access=Dedicated   #Shared   #ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance
   ${cluster_inst}=  Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_vsphere}  cluster_name=${cluster_default}  use_defaults=False
   ${cluster_inst_name}=  Set Variable  ${cluster_inst}[0][data][key][cluster_key][name]    
   Set Suite Variable  ${cluster_inst_name}
   ${cluster_cloudlet_name}=  Set Variable  ${cluster_inst}[0][data][key][cloudlet_key][name]
   Set Suite Variable  ${cluster_cloudlet_name}
   ${cluster_inst_org}=  Set Variable       ${cluster_inst}[0][data][key][organization]
   Set Suite Variable  ${cluster_inst_org}
   ${cluster_inst_lb}=  Set Variable  ${cluster_inst}[0][data][resources][vms][0][name]
   Set Suite Variable  ${cluster_inst_lb}
   ${vs_clusterk8sconfigfile}=  Catenate  SEPARATOR=.  ${cluster_default}  ${operator_name_vsphere}  kubeconfig   #cluster-16mcctlaccess.packet.kubeconfig
   Set Suite Variable  ${vs_clusterk8sconfigfile}

   Should Contain  ${cluster_inst}[0][data][key][cluster_key][name]   ${cluster_default} 
   Should Contain  ${cluster_inst}[0][data][key][cloudlet_key][name]  ${cloudlet_name_vsphere}

   #{dedicatedrootlb cluster1646365600-072066-automation-dev-org.dfwvmw2-packet.us.mobiledgex.net}
   ${vs_nodename}=  Catenate  SEPARATOR=.  ${cluster_inst_name}-${cluster_org}  ${cloudlet_name_vsphere}-${operator_name_vsphere}  ${region}  ${mobiledgex_domain}
   ${vs_nodename}=  Convert To Lowercase  ${vs_nodename}
   Set Suite Variable  ${vs_nodename}
   Should Contain  ${cluster_inst}[0][data][fqdn]  ${vs_nodename}

Check Dedicated Cluster For CLI Sent
   [Arguments]  ${output_msg}  ${output_msg2}  ${output_msg3}  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   # no flag
   ${std_output}=  Run mcctl  accesscloudlet ${parmss}
   Set Test Variable  ${std_output}
   Should Contain Any  ${std_output}  ${output_msg}  ${output_msg2}  ${output_msg3}

   # flag -t tty error
   ${command_parms}=  Set Variable  ${parms['command']}
   Set Variable  ${command_parms}
   ${flag_t_err}=  Run Keyword and Expect Error  *   Run mcctl  accesscloudlet region=${region_US} cloudlet=${cloudlet_name_vsphere} cloudletorg=${operator_name_vsphere} nodetype=dedicatedrootlb nodename=${vs_nodename} command=${command_parms} -t
   Convert To String  ${flag_t_err}
   Set Variable  ${flag_t_err}
   Should Be True   ${flag_t_err}  ${tty_error4}

   # flag -i interactive without error
   ${parmss3}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   ${flag_i}=  Run mcctl  accesscloudlet ${parmss3}-i
   Set Test Variable  ${flag_i}
   Should Contain Any  ${flag_i}  ${output_msg}  ${output_msg2}  ${output_msg3}   

Check Response For CLI Sent
   [Arguments]  ${output_msg}  ${output_msg2}  ${output_msg3}  &{parms}

   ${sharedrootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
   ${sharedrootlb}=  Convert To Lowercase  ${sharedrootlb}
   Set Test Variable  ${sharedrootlb}

   ${platformvm}=  Catenate  SEPARATOR=-  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  pf
   Set Test Variable  ${platformvm}

   #{platformvm automationHamburgCloudlet-TDG-pf} {sharedrootlb automationhamburgcloudlet.tdg.mobiledgex.net}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_output}=  Run mcctl  accesscloudlet ${parmss}
   Set Test Variable  ${std_output}   
   ${cnt}=  Get Line Count  ${std_output}
   Set Test Variable  ${cnt}
   Set Test Variable  ${output_msg}
   Set Test Variable  ${output_msg2}
   Set Test Variable  ${output_msg3}

   Run Keyword If  '${output_msg}' != 'command2c'     Should Contain Any  ${std_output}  ${output_msg}  ${output_msg2}  ${output_msg3}
   Run Keyword If  '${output_msg}' == 'command2c'     Should Be True  ${cnt} < 5
   Run Keyword If  '${output_msg3}' == 'crmserver'    Check CLI Check Length
   Run Keyword If  '${output_msg3}' == 'shepherd'     Check CLI Check Length


Check CLI Check Length
   Should Be True  ${cnt} >= 10

Check CLI Shepherd
   Should Be True  ${cnt} >= 10

Fail AccessCloudlet Command Via mcctl
   [Arguments]  ${error_msg}= "Error:" not name=val  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_output}=  Run Keyword and Expect Error  *  Run mcctl  accesscloudlet ${parmss}
   Should Contain Any  ${std_output}  ${error_msg}

AlreadySetup
   #keeping this section for easy trouble shooting existing clusters for manual testing
   ${tty_errors}  Set Variable
   Set Suite Variable  ${tty_errors}
   ${tty_err_st}  Set Variable
   Set Suite Variable  ${tty_err_st}
   ${region}  Set Variable  US
   Set Suite Variable  ${region}
   ${cluster_default}  Set Variable  cluster1646455152-164335
   Set Suite Variable   ${cluster_default}
   Log to Console  START creating cluster instance
   Log to Console  DONE creating cluster instance
   ${cluster_inst}=  Show Cluster Instances  region=${region}  cloudlet_name=${cloudlet_name_vsphere}  cluster_name=${cluster_default}  use_defaults=False
   ${cluster_inst_name}=  Set Variable  ${cluster_inst}[0][data][key][cluster_key][name]
   Set Suite Variable  ${cluster_inst_name}
   ${cluster_cloudlet_name}=  Set Variable  ${cluster_inst}[0][data][key][cloudlet_key][name]
   Set Suite Variable  ${cluster_cloudlet_name}
   ${cluster_inst_org}=  Set Variable       ${cluster_inst}[0][data][key][organization]
   Set Suite Variable  ${cluster_inst_org}
   ${cluster_inst_lb}=  Set Variable  ${cluster_inst}[0][data][resources][vms][0][name]
   Set Suite Variable  ${cluster_inst_lb}
   ${vs_clusterk8sconfigfile}=  Catenate  SEPARATOR=.  ${cluster_default}  ${operator_name_vsphere}  kubeconfig
   Set Suite Variable  ${vs_clusterk8sconfigfile}

   Should Contain  ${cluster_inst}[0][data][key][cluster_key][name]   ${cluster_default}
   Should Contain  ${cluster_inst}[0][data][key][cloudlet_key][name]  ${cloudlet_name_vsphere}
   #{dedicatedrootlb cluster1646365600-072066-automation-dev-org.dfwvmw2-packet.us.mobiledgex.net}
   ${vs_nodename}=  Catenate  SEPARATOR=.  ${cluster_inst_name}-${cluster_org}  ${cloudlet_name_vsphere}-${operator_name_vsphere}  ${region}  ${mobiledgex_domain}
   ${vs_nodename}=  Convert To Lowercase  ${vs_nodename}
   Set Suite Variable  ${vs_nodename}
   Should Contain  ${cluster_inst}[0][data][fqdn]  ${vs_nodename}
