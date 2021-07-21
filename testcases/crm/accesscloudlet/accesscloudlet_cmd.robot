*** Settings ***
Documentation  accessCloudlet

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
# Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
#Library  MexApp
#Library  Process
#Library  OperatingSystem
#Library  Collections
Library  String

Test Teardown   Cleanup provisioning


*** Variables ***
${cluster_name_access_cloudlet}=  cluster-16accesscloudlet   #want to be specific yet still be able for the cleanup to delete if teardown fails
${developer_name}=  MobiledgeX
${server_mobiledgex}=  mobiledgex
${count_flavor_list}=  | ID | Name | RAM | Disk | Ephemeral | VCPUs | Is Public |
${count_server_list}=  | ID | Name | Status | Networks | Image | Flavor |
${command4_return4}=  CONTAINER ID 
${command5_return5}=  REPOSITORY
${sharedrootlb}=  sharedrootlb
${platformvm}=  platformvm
${invalid}=  typonodetype
${touchfiletest}=  "touch file test.txt"
${lsfiletest}=  "ls -l test.txt"
${access_command}=  stty cols 210;echo;top -n 2;echo;echo;docker ps
${access_command2}=  stty cols 210;docker logs --tail 10 crmserver
${access_command2b}=  stty cols 210;docker logs --tail 10 shepherd
${access_command2c}=  stty cols 210;docker logs --tail 100 crmserver 2>&1 | grep 
${access_command3}=  touch logme;ls -l
${access_command3a}=  rm logme;ls -l
${access_command4}=  stty cols 210;docker ps;ls -l;whoami;exit
${access_command5}=  stty cols 200;docker ps;ls -l;whoami;docker images;docker version;exit
${access_command6}=  stty cols 200;ls -l;exit
${access_command_exit2}=  stty cols 200;ls -l;exit
${access_command_exit0}=  exit
${notabashcommand+}=  notabashcommand+
${region}=  US
${region_EU}=  EU
${region_US}=  US
${operator_org_name}=  packet
${cloudlet_name_vsphere}=  DFWVMW2
${cloudlet_name_vcd}=  qacloud
${cloudlet_name_openstack}=  automationFairviewCloudlet
${cloudlet_name_openstack_shared}=  automationHawkinsCloudlet
${cloudlet_name_openstack_dedicated}=  automationHawkinsCloudlet
${operator_name_vsphere}=  packet
${operator_name_openstack}=  GDDT
${operator_name_vcd}=  packet
${cloudlet_name}=  ${cloudlet_name_openstack_shared}
${operator_name}=  ${operator_name_openstack}
${cloudlet_platform_type}=  PlatformTypeOpenstack 
#${cloudlet_platform_type}=  PlatformTypevSphere
#${cloudlet_platform_type}=  PlatformTypeVCD
${mobiledgex_domain}=  mobiledgex.net


#mcctl and  reference inforamtion
# valid nodes: [{platformvm DFWVMW-packet-pf} {sharedrootlb dfwvmw.packet.mobiledgex.net} {dedicatedrootlb autoclusterapache2web8066v1.dfwvmw.packet.mobiledgex.net} {dedicatedrootlb autoclusterdunkleweb.dfwvmw.packet.mobiledgex.net}
# valid nodes: [{platformvm automationFairviewCloudlet-GDDT-pf} {sharedrootlb automationfairviewcloudlet.gddt.mobiledgex.net} {dedicatedrootlb cluster1603893239-0834615.automationfairviewcloudlet.gddt.mobiledgex.net}]
# ('code=400', 'error={"message":"Unable to find specified cloudlet mgmt node, list of valid nodes: [{platformvm DFWVMW2-packet-pf} {sharedrootlb dfwvmw2.packet.mobiledgex.net}]"}')
# ${stout_docker_ps}=  Access Cloudlet  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=whoami
# Error: Bad Request (400), Too many nodes matched, please specify type and name from:
# Error: Bad Request (400), Unable to find specified cloudlet mgmt node, list of valid nodes:
# Below is a method to search one platform type else default to the second known , I updated the test cases to handle as many types as needed, this is reference
#      ${region}=    Set Variable If    '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'
#    ...    ${region_EU}    ${region_US}
#
#      ${operator_name}=    Set Variable If    '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'
#    ...    ${operator_name_openstack}    ${operator_name_vsphere}
#
#      ${cloudlet_name}=    Set Variable If    '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'
#    ...     ${cloudlet_name_openstack_shared}    ${cloudlet_name_vsphere}




*** Test Cases ***
#ECQ-2812
AccessCloudlet - Check for error 400 too many nodes matched when node-type is blank
    [Documentation]
    ...  send accessCloudlet specifying no node_type
    ...  verify platformvm is not accessible
    ...  verify too many nodes matched error 400 with description is returned

         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}


      ${error}=  Run Keyword And Expect Error  *  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command}  node_type= 
      Should Contain  ${error}  ('code=400', 'error={"message":"Too many nodes matched, please specify type and name from:
      Log to Console  \n\n${error}

#ECQ-2813
AccessCloudlet - Check for error 400 too many nodes matched when node-type and node-name is blank
    [Documentation]
    ...  send accessCloudlet specifying no node_type and node_name
    ...  verify platformvm is not accessible
    ...  verify too many nodes matched error 400 with description is returned


         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}
 
         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}


      ${error}=  Run Keyword And Expect Error  *  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command}  node_type=  node_name=
      Should Contain  ${error}  ('code=400', 'error={"message":"Too many nodes matched, please specify type and name from:
      Log to Console  \n\n${error}


#ECQ-2814
AccessCloudlet - Check for error 400 too many nodes matched when node-name is blank
    [Documentation]
    ...  send accessCloudlet specifying no node_type
    ...  verify platformvm is not accessible
    ...  verify too many nodes matched error 400 with description is returned

         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}


      ${error}=  Run Keyword And Expect Error  *  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command}  node_name=
      Should Contain  ${error}  ('code=400', 'error={"message":"Too many nodes matched, please specify type and name from:
      Log to Console  \n\n${error}

#ECQ-2815
AccessCloudlet - Access cloudlet platform type specific check for error 400 when node type is invalid
    [Documentation]
    ...  send accessCloudlet specifying node_type invalid
    ...  verify platformvm is not accessible
    ...  verify unable to find specified cloudlet mgmt node error 400 with description is returned

         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      ${error}=  Run Keyword And Expect Error  *  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  command=${access_command}  node_type=${invalid}  region=${region}
      Should Contain  ${error}  ('code=400', 'error={"message":"Unable to find specified cloudlet mgmt node, list of valid nodes:
      Log to Console  \n\n${error}

#ECQ-2816
AccessCloudlet - Access cloudlet check for error if region is not specified
    [Documentation]
    ...  send accessCloudlet specifying node_type typonodetype
    ...  verify platformvm is not accessible
    ...  verify no region specified error 400 with description is returned

         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

#('code=400', 'error={"message":"no region specified"}')

      ${error}=  Run Keyword And Expect Error  *  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=  command=${access_command}  node_type=${platformvm} node_name=
      Should Contain  ${error}  ('code=400', 'error={"message":"No region specified"}') 
      Log to Console  \n\n${error}


#ECQ-2817
AccessCloudlet - Access cloudlet check for error if bash commnad is not found
    [Documentation]
    ...  send accessCloudlet specifying unknown bash command
    ...  verify platformvm is accessible
    ...  verify bash command is not found to execute and connection closed

#Return: 'bash: =: command not found\r\n


         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      ${nobash}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${notabashcommand+}   node_type=${platformvm}  node_name=
      Should Contain  ${nobash}   command not found
      Log to Console  \n\n:${nobash}

#ECQ-2818   
AccessCloudlet - Access cloudlet by node_type platformvm and send command docker ps
    [Documentation]
    ...  send accessCloudlet by node_type platformvm and send docker ps
    ...  verify return information shows container info for crmserver  shepherd  cloudletPrometheus

         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      ${prompt}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command}  node_type=${platformvm}  node_name=
      Should Contain Any  ${prompt}  crmserver  shepherd  cloudletPrometheus
      Log to Console  \n\n${prompt}

#ECQ-2819
AccessCloudlet - Access cloudlet by node_type platformvm and send command docker logs search crmserver     
    [Documentation]
    ...  send accessCloudlet command to search crmserver logs on platformvm
    ...  verify platformvm is accessible
    ...  verify commnad docker logs on crmserver returns log info
    ...  verify commnad docker logs on crmserver using grep with 2>&1 works properly 

#${access_command2}=  stty cols 210;docker logs --tail 10 crmserver
#${access_command2c}=  stty cols 210;docker logs --tail 100 crmserver >2&1 | grep ${testtime} 

         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

       ${prompt2}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command2}  node_type=${platformvm}  node_name=
       Should Contain Any  ${prompt2}  INFO
       Log to Console  \n\n${prompt2}

       ${testtime}=   Get Time  epoch
       ${testtime}=   Convert To String    ${testtime}
       ${prompt2c}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command2c} ${testtime}  node_type=${platformvm}  node_name=
       ${cnt}=  Get Line Count  ${prompt2c}
       Should Be True  ${cnt} < 5       #search is 100 lines so grep for epoch time is searching for nothing which will yeild 3 lines and should return less than 5 lines out of 100 
       Log to Console  \n\n${prompt2c}
       Log to Console  \n\n${prompt2c}

#ECQ-2820
AccessCloudlet - Access cloudlet by node_type platformvm and send command docker logs search shepherd
    [Documentation]
    ...  send accessCloudlet command to search shepherd logs on platformvm
    ...  verify platformvm is accessible
    ...  verify commnad docker logs on shepherd returns log info

#${access_command2b}=  stty cols 210;docker logs --tail 10 shepherd


         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

       ${prompt2}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command2b}  node_type=${platformvm}  node_name=
       Should Contain Any  ${prompt2}  INFO
       Log to Console  \n\n${prompt2}

#ECQ-2821
AccessCloudlet - Access cloudlet by node_type platformvm and send command to create and delete a file
    [Documentation]
    ...  send accessCloudlet node_type platformvm and create a file
    ...  verify command created a file on platformvm
    ...  send accessCloudlet node_type platformvm and delete a file
    ...  verify command deleted the file on platformvm

#${access_command3}=  touch logme;ls -l
#${access_command3a}= rm logme;ls -l


         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      ${prompt3}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command3}  node_type=${platformvm}  node_name=
      Should Contain Any  ${prompt3}  logme
      Log to Console  \n\n${prompt3}

      ${prompt3a}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command3a}  node_type=${platformvm}  node_name=
      Should Not Contain Any  ${prompt3a}  logme
      Log to Console  \n\n${prompt3a}

#ECQ-2822
AccessCloudlet - accessCloudlet with node type platformvm and verify command exit will return user from cli
   [Documentation]
    ...  Use automation cloudlet node type platformvm
    ...  Verify accesscloudlet can access the platformvm and exit
    ...  Verify exit is performed and user is returned from platformvm


         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      ${prompt_exit}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command_exit0}  node_type=${platformvm}  node_name=
      ${cnt}=  Get Length  ${prompt_exit}
      Should Be True  ${cnt} <= 0 
      Log to Console  \n\n${prompt_exit}

#ECQ-2823
AccessCloudlet - accessCloudlet with node type platformvm issue a ls command with exit to verify return from cli
   [Documentation]
    ...  Use automation cloudlet node type  platformvm
    ...  Verify accesscloudlet can access the platformvm and issue a ls command with exit
    ...  Verify ls -l and exit are performed and user is returned from platformvm


         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      ${prompt_exit2}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command_exit2}  node_type=${platformvm}  node_name=
      ${cnt}=  Get Length  ${prompt_exit2}
      Should Be True  ${cnt} >= 0
      Log to Console  \n\n${prompt_exit2}

#ECQ-2824
AccessCloudlet - Access node type sharedrootlb and verify command exit will return user from cli
   [Documentation]
    ...  Use automation cloudlet node type sharedrootlb
    ...  Verify accesscloudlet can access the sharedrootlb and exit
    ...  Verify exit is performed and user is returned from sharedrootlb

         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      ${prompt_exit}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command_exit0}  node_type=${sharedrootlb}  node_name=
      ${cnt}=  Get Length  ${prompt_exit}
      Should Be True  ${cnt} <= 0
      Log to Console  \n\n${prompt_exit}

#ECQ-2825
AccessCloudlet - Access node type sharedrootlb issue a ls command with exit to verify return from cli
   [Documentation]
    ...  Use automation cloudlet node type  sharedrootlb
    ...  Verify accesscloudlet can access the sharedrootlb and issue a command with exit
    ...  Verify ls -l and exit are performed and user is returned from sharedrootlb


         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      ${prompt_exit2}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command_exit2}  node_type=${sharedrootlb}  node_name=
      ${cnt}=  Get Length  ${prompt_exit2}
      Should Be True  ${cnt} >= 0
      Log to Console  \n\n${prompt_exit2}

#ECQ-2826
AccessCloudlet - Create and access a dedicatedrootlb cluster using command args to list docker and file info
   [Documentation]
    ...  create a dedicatedrootlb cluster inst and use accesscloudlet to login
    ...  verify accesscloudlet can login and issue commnads to return docker and file information
    ...  verify arguments stty cols 200;docker ps;ls -l;whoami;docker images;docker version;exit execute
    ...  verify the cluster k8s config file was created using accesscloudlet ls command

         ${region}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'    ${region_EU}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'      ${region_US}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'          ${region_US}

         ${operator_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${operator_name_openstack}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${operator_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${operator_name_vcd}

         ${cloudlet_name}=    Set Variable If
    ...  '${cloudlet_platform_type}' == 'PlatformTypeOpenstack'     ${cloudlet_name_openstack_shared}
    ...  '${cloudlet_platform_type}' == 'PlatformTypevSphere'       ${cloudlet_name_vsphere}
    ...  '${cloudlet_platform_type}' == 'PlatformTypeVCD'           ${cloudlet_name_vcd}

      Create Flavor  region=${region}
      Log To Console  Creating Cluster Instance
      Create Cluster Instance  cluster_name=${cluster_name_access_cloudlet}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=1  region=${region}  #flavor_name=${cluster_flavor_name}
      Log To Console  Done Creating Cluster Instance

      ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name}  ${operator_name}  ${mobiledgex_domain}
      ${rootlb}=  Convert To Lowercase  ${rootlb}

      ${clusterk8sconfigfile}=  Catenate  SEPARATOR=.  ${cluster_name_access_cloudlet}  ${operator_name}  kubeconfig   #cluster-16accesscloudlet.GDDT.kubeconfig


      ${cloudnodes}=  Show Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name}
      Log To Console  \n${cloudnodes}     #need this info to see the return of the node types and names and verify what was seen prior to run
      
      ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name_access_cloudlet}  ${cloudlet_name}  ${operator_name}  ${mobiledgex_domain}
      ${rootlb}=  Convert To Lowercase  ${rootlb}

#${access_command4}=  stty cols 210;docker ps;ls -l;whoami;exit
#${access_command5}=  stty cols 200;docker ps;ls -l;whoami;docker images;docker version;exit
#${access_command6}=  stty cols 200;ls -l;exit
#${command4_return4}=  CONTAINER ID
#${command5_return5}=  REPOSITORY

      ${prompt4}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command4}  node_name=${rootlb}
      Should Contain Any  ${prompt4}  ${command4_return4}
      Log to Console  \n\n${prompt4}

      ${prompt5}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command5}  node_name=${rootlb}
      Should Contain Any  ${prompt5}  ${command5_return5}
      Log to Console  \n\n${prompt5}

      ${prompt6}=  Access Cloudlet  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  region=${region}  command=${access_command6}  node_name=${rootlb}
      Should Contain Any  ${prompt6}  ${clusterk8sconfigfile}
      Log to Console  \n\n${prompt6}


*** Keywords ***
