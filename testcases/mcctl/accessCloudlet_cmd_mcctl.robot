*** Settings ***
Documentation  AccessCloudlet mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String


Test Teardown  Cleanup Provisioning

Test Timeout  8m

*** Variables ***


${cloudlet_name_openstack}=  automationFairviewCloudlet
${cloudlet_name_openstack_shared}=  automationParadiseCloudlet
${cloudlet_name_openstack_dedicated}=  automationSunnydaleCloudlet
#${cloudlet_name_openstack_dedicated}=  automationHawkinsCloudlet
#${cloudlet_name_openstack_dedicated}=  automationParadiseCloudlet
${operator_name_openstack}=  GDDT
${region}=  
${developer}=  MobiledgeX
${type_shep}=  shepherd
${type_crm}=  crm
${timeout}=  45s
${access_command2c}=  stty cols 210;docker logs --tail 100 crmserver >2&1 | grep
${node_name}=  automationParadiseCloudlet-GDDT-pf
${mobiledgex_domain}=  mobiledgex.net
${platformvm}=
${sharedrootlb}=
${cluster_name_mcctl_access}=  cluster-16mcctlaccess  #want to be specific yet still be able for the cleanup to delete if teardown fails
${region_EU}=  EU
${region_US}=  US
${operator_org_name}=  packet
${cloudlet_name_vsphere}=  DFWVMW2
${cloudlet_name_vcd}=  automation-qa2-vcd-01
${operator_name_vsphere}=  packet
${operator_name_openstack}=  GDDT
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
${cluster_org} =

# mcctl --addr https://console-qa.mobiledgex.net:443 --skipverify region AccessCloudlet region=EU cloudlet=automationParadiseCloudlet cloudlet-org=GDDT node-type=sharedrootlb command=ls;exit


*** Test Cases ***

#ECQ-2965
AccessCloudlet - mcctl shall handle error messages
   [Documentation]
   ...  - send AccessCloudlet conditions for all error types
   ...  - verify expected error is returned 
   ...  - send AccessCloudlet missing required args
   ...  - verify expected error is returned

   [Template]  Fail AccessCloudlet Command Via mcctl

      Error: missing required args                                           region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}
      Error: parsing arg "notcloudlet-org\=GDDT" failed: invalid argument: key "notcloudlet-org" not found   region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  notcloudlet-org=${operator_name_openstack}   
      Error: missing required args: cloudlet                                 region=${region_EU}  cloudlet-org=${operator_name_openstack} node-type=sharedrootlb  command=exit
      Error: missing required args: region                                                        cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack} node-type=sharedrootlb  command=exit
      Error: Bad Request (400), No cloudlet mgmt node specified              region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  command=a
      Error: Bad Request (400), Unable to find specified cloudlet mgmt node  region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack} node-type=sharedrootlb node-name=test  command=exit
      Error: Bad Request (400), Too many nodes matched                       region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack} node-type=  command=exit
      Error: unable to fetch access URL                                      region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=  node-type=sharedrootlb  command=exit
      Error: Bad Request (400), No run command specified                     region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}
      Error: Bad Request (400), Region "ZZ" not found                        region=ZZ            cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  command=exit
      Error: arg "Error:" not name=val format                                region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  command= exit


#ECQ-2966 
AccessCloudlet - mcctl shall pass cli commands to specified cloudlet and node
   [Documentation]
   ...  - send cli commands node type platformvm and sharedrootlb
   ...  - verify proper command is executed

#valid nodes: [{platformvm automationParadiseCloudlet-GDDT-pf} {sharedrootlb automationparadisecloudlet.gddt.mobiledgex.net} {dedicatedrootlb dockerdediated.automationparadisecloudlet.gddt.mobiledgex.net}]

   [Template]  Check Response For CLI Sent

#platformvm
      crmserver  shepherd  cloudletPrometheus  region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  node-type=platformvm  node-name=${platformvm}  command="docker ps;exit"
      command2c  shepherd  cloudletPrometheus  region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  node-type=platformvm  node-name=${platformvm}  command="docker logs --tail 100 crmserver >2&1 | grep 140738018"
      empty      empty     shepherd            region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  node-type=platformvm  node-name=${platformvm}  command="stty cols 210;docker logs --tail 12 shepherd"
      empty      empty     crmserver           region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  node-type=platformvm  node-name=${platformvm}  command="stty cols 210;docker logs --tail 10 crmserver"
      logme      empty     empty               region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  node-type=platformvm  node-name=${platformvm}  command="touch logme;ls -l"
      No such file or directory  empty  empty  region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  node-type=platformvm  node-name=${platformvm}  command="rm logme;ls -l logme"
#sharedrootlb
      command2c  envoy     empty               region=${region_EU}  cloudlet=${cloudlet_name_openstack_dedicated}  cloudlet-org=${operator_name_openstack}  node-type=sharedrootlb  node-name=${sharedrootlb}  command="ls -lcth | grep nothing;exit"


#ECQ-2967
AccessCloudlet - mcctl shall pass cli commands to a dedicatedrootlb
   [Documentation]
    ...  create a dedicatedrootlb cluster inst and use accesscloudlet to login
    ...  verify mcctl accesscloudlet can login and issue commands to return docker and file information
    ...  verify the cluster k8s config file was created using cli ls command

   [Template]  Check Dedicated Cluster For CLI Sent

#dedicatedrootlb vsphere - using to conservere resources
      CONTAINER  ID  envoy                            region=${region_US}  cloudlet=${cloudlet_name_vsphere}  cloudlet-org=${operator_name_vsphere}  node-type=dedicatedrootlb  node-name=${vs_nodename}  command="docker ps;exit"
      REPOSITORY  TAG  SIZE                           region=${region_US}  cloudlet=${cloudlet_name_vsphere}  cloudlet-org=${operator_name_vsphere}  node-type=dedicatedrootlb  node-name=${vs_nodename}  command="docker images;exit"
      ${vs_clusterk8sconfigfile}  kubeconfig  empty   region=${region_US}  cloudlet=${cloudlet_name_vsphere}  cloudlet-org=${operator_name_vsphere}  node-type=dedicatedrootlb  node-name=${vs_nodename}  command="ls -l;exit"



*** Keywords ***
Setup
    ${vs_clusterk8sconfigfile}=  Catenate  SEPARATOR=.  ${cluster_name_mcctl_access}  operator_org_name=${operator_name_vsphere}  kubeconfig   #cluster-16mcctlaccess.packet.kubeconfig
    Set Suite Variable  ${vs_clusterk8sconfigfile}

    ${cloudnodesvs}=  Show Cloudlet Info  region=${region_US}  cloudlet_name=${cloudlet_name_vsphere}
    ${vs_nodename}=  Catenate  SEPARATOR=.  ${cluster_name_mcctl_access}  ${cloudlet_name_vsphere}  ${operator_name_vsphere}  ${mobiledgex_domain}
    ${vs_nodename}=  Convert To Lowercase  ${nodenamevs}

    Set Suite Variable  ${vs_nodename}


Check Dedicated Cluster For CLI Sent
   [Arguments]  ${output_msg}  ${output_msg2}  ${output_msg3}  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_output}=  Run mcctl  accesscloudlet ${parmss}
   Set Test Variable  ${std_output}
   Should Contain Any  ${std_output}  ${output_msg}  ${output_msg2}  ${output_msg3}


Check Response For CLI Sent
   [Arguments]  ${output_msg}  ${output_msg2}  ${output_msg3}  &{parms}

   ${sharedrootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
   ${sharedrootlb}=  Convert To Lowercase  ${sharedrootlb}
   Set Test Variable  ${sharedrootlb}

   ${platformvm}=  Catenate  SEPARATOR=-  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  pf
   Set Test Variable  ${platformvm}

#{platformvm automationHawkinsCloudlet-GDDT-pf} {sharedrootlb automationhawkinscloudlet.gddt.mobiledgex.net}

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


