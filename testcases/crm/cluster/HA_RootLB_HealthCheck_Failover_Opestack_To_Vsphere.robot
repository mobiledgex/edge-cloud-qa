### ECQ-2432 ###
*** Settings ***
Documentation   Create Dedicated Docker Reservable Cluster, Delete Cloudlet from policy and Verify HA works between Openstacl and Vsphere

#Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         MexApp
Library         Process
#Library         String
##Library         SSHLibrary.execute command
#Library         OperatingSystem
Test Timeout     20 minutes

Suite Setup     Setup
Suite Teardown  Cleanup

*** Variables ***
${cloudlet1}  packetcloudlet
${cloudlet2}  DFWVMW2
${operator_name_openstack}  packet
${mobiledgex_domain}  mobiledgex.net
${region}      US
${flavor}  automation_api_flavor
${default_flavor_name}   automation_api_flavor
${cluster_name}  dockerreservable
${docker_image}  docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1
${policy_name}  AutoProvPolicyTest
${app_name}  AutoProvAppDocker
${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
${username}=  mextester06
${password}=  mextester06123

*** Test Cases ***

Create docker based reservable cluster instnace
   [Documentation]
   ...  create a dedicated reservabe docker cluster instnace

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  reservable=${True}   cluster_name=${cluster_name}  cloudlet_name=${cloudlet1}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}  developer_org_name=MobiledgeX  token=${super_token}
   ${cluster_inst}=  Create Cluster Instance  region=${region}  reservable=${True}   cluster_name=${cluster_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}  developer_org_name=MobiledgeX  token=${super_token}

   Log to Console  DONE creating cluster instance

Create Auto Provisioning Policy

   Log to Console  Create Auto Provisioning Policy with 1 min active instances and add two cloudlet to the policy

   &{cloudlet1}=  create dictionary  name=packetcloudlet  organization=packet
   &{cloudlet2}=  create dictionary  name=DFWVMW2  organization=packet
   @{cloudletlist}=  create list  ${cloudlet1}  ${cloudlet2}

   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  min_active_instances=1  max_instances=2  developer_org_name=${orgname}  token=${user_token}  cloudlet_list=${cloudletlist}

   log to console   ${policy_return}

Create App, Add Autoprovisioning Policy and Deploy an App Instance

   log to console  Creating App and App Instance
   create app  region=${region}  app_name=${app_name}  deployment=docker  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policy=${policy_name}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet1}  operator_org_name=${operator_name_openstack}  token=${user_token}
##   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}  token=${user_token}


Shutdown Cluster VM/RLB and Trigger failover via HEALTH_CHECK_FAIL_ROOTLB_OFFLINE

#   ${stdout}=  run process  source /Users/ashutoshbhatt/Documents/OpenstackRC/admin-openrc-packet.sh  &&  openstack server stop ${rootlb}  shell=True
   ${stdout}=  run process  source ~/Documents/OpenstackRC/admin-openrc-packet.sh && openstack server stop ${rootlb}  shell=True
   log to console  ${stdout}
   sleep  1 minute
#   ${stdout}=  run process  openstack server start dockerreservable1599583043.packetcloudlet.packet.mobiledgex.net  shell=True
#   log to console  ${stdout}
#   run process  openstack server stop ${rootlb}
#   log to console  ${stdout} ${stderr}

#
#   Run openstack command and shuwdown rootlb vm
##
#   run debug  region=${region}  cloudlet_name=${cloudlet1}  command=oscmd  args=openstack server stop ${rootlb}  node_type=crm  token=${supertoken}
#   run debug  region=${region}  cloudlet_name=${cloudlet1}  command=oscmd  args=openstack server stop dockerreservable1599175092.packetcloudlet.packet.mobiledgex.net node_type=crm  token=${supertoken}


#   app instance should exist   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator_name_openstack}  token=${user_token}

Check health check OK for app instance after switch over to Vsphere Cloudlet
#   wait for app instance health check ok  region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator_name_openstack}  token=${user_token}
##Delete Cloudlet from Auto Provisioning Policy
##
##    ${remove_cloudlet}=  remove auto provisioning policy cloudlet  region=${region}  policy_name=${policy_name}  developer_org_name=${orgname}  cloudlet_name=${cloudlet1}  operator_org_name=${operator_name_openstack}  token=${user_token}
   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator_name_openstack}  token=${user_token}
##    sleep  3 minutes
##    app instance should not exist  app_name=${app_name}  region=${region}  app_version=v1  developer_org_name=${orgname}  cloudlet_name=${cloudlet1}

Turn-on Cluster VM/RLB via RunDebug

    run debug  region=${region}  cloudlet_name=${cloudlet1}  command=oscmd  args=openstack server start ${rootlb}  node_type=crm  token=${supertoken}

Remove auto provisioning policy from App
#    sleep  1 minute
    update app  region=${region}  app_name=${app_name}  developer_org_name=${orgname}  auto_prov_policy=${EMPTY}  app_version=v1  token=${user_token}

    sleep  2 minutes
#    app instance should not exist  app_name=${app_name}  region=${region}  app_version=v1  developer_org_name=${orgname}  cloudlet_name=${cloudlet1}
    app instance should not exist  app_name=${app_name}  region=${region}  app_version=v1  developer_org_name=${orgname}  cloudlet_name=${cloudlet2}
*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
    ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
    ${cluster_name}=  Catenate  SEPARATOR=  ${cluster_name}  ${epoch}
    ${policy_name}=  Catenate  SEPARATOR=  ${policy_name}  ${epoch}
    ${app_name}=  Catenate  SEPARATOR=  ${app_name}  ${epoch}
    ${super_token}=  Get Super Token

    Skip Verify Email  token=${super_token}
    Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
    #Verify Email  email_address=${emailepoch}
    Unlock User
    ${user_token}=  Login  username=${epochusername}  password=${password}

    ${orgname}=  Create Org  token=${user_token}  orgtype=developer
    Set Suite Variable  ${super_token}
    Set Suite Variable  ${user_token}
    Set Suite Variable  ${policy_name}
    Set Suite Variable  ${orgname}
    Set Suite Variable  ${cluster_name}
    Set Suite Variable  ${app_name}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${cloudlet1}  ${operator_name_openstack}  ${mobiledgex_domain}
    set suite variable  ${rootlb}

#source opnstack RC file and stop the RootLB Server
#   ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name_1}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
#   ${rootlb}=  Convert To Lowercase   ${rootlb}

Cleanup
#    delete app instance  region=${region}  app_name=${app_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    cleanup provisioning


