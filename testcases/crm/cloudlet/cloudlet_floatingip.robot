*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout   35 min 

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${cloudlet_name_openstack_fip}  automationFIPCloudlet
${operator_name_openstack_fip}  GDDT
${physical_name_openstack_fip}  fairview

${region}=  EU

${test_timeout_crm}  60 min

${router_name}=  automationFIPRouter

${max_value}=  5

*** Test Cases ***
# ECQ-4356
CreateCloudlet - User shall be able to create a cloudlet with floating IP
   [Documentation]
   ...  - do CreateCloudlet with Floatin Ip configured
   ...  - create a dedicated k8s and docker cluster and vm
   ...  - create vm 
   ...  - verify all are created successfully
   ...  - verify FloatinIps is correct in CloudletInfo
   ...  - verify ResourceUsage metrics is correct

   #  mcctl --addr https://console-qa.mobiledgex.net:443 --skipverify region CreateCloudlet region=EU cloudlet=automationFipCloudlet cloudlet-org=GDDT location.latitude=1 location.longitude=1 numdynamicips=254 platformtype=PlatformTypeOpenstack physicalname=fairview envvar=MEX_EXT_NETWORK=automationFIPNetwork envvar=MEX_NETWORK_SCHEME=cidr=172.168.X.0/24,floatingipnet=automationFIPNetwork,floatingipsubnet=automationFIPSubnet,floatingipextnet=external-network-shared
   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_fip}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_fip}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=MEX_EXT_NETWORK=automationFIPNetwork,MEX_NETWORK_SCHEME=cidr=172.168.X.0/24,floatingipnet=automationFIPNetwork,floatingipsubnet=automationFIPSubnet,floatingipextnet=external-network-shared  auto_delete=${False}
   Set Suite Variable  ${cloudlet}
#   FloatingIps Should Match  cloudlet=${cloudlet}  max_value=${max_value}  used_value=2

   ${t1}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_openstack_fip}  deployment=kubernetes  ip_access=IpAccessDedicated  number_nodes=1  flavor_name=${flavor_name}  use_thread=${True}
#   FloatingIps Should Match  cloudlet=${cloudlet}  max_value=${max_value}  used_value=3

   ${t2}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name}2  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_openstack_fip}  deployment=docker  ip_access=IpAccessDedicated   flavor_name=${flavor_name}  use_thread=${True}
#   FloatingIps Should Match  cloudlet=${cloudlet}  max_value=${max_value}  used_value=4

   ${t3}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_openstack_fip}   flavor_name=${flavor_name}vm  use_thread=${True}

   Wait For Replies  ${t1}  ${t2}  ${t3}

   # floatingipused:5   cloudlet=2 + clusters=2 + appinst=1
   FloatingIps Should Match  cloudlet=${cloudlet}  max_value=${max_value}  used_value=5

   Resource Usage Metrics Should Be Correct

*** Keywords ***
Setup
   Update Settings  region=${region}  resource_snapshot_thread_interval=1m

   ${flavor_name}=  Get Default Flavor Name
   Set Suite Variable  ${flavor_name}

   Create Flavor  region=${region}
   Create Flavor  region=${region}  flavor_name=${flavor_name}vm  disk=80
   Create App  region=${region}  image_path=${qcow_centos_image}  access_ports=tcp:2015  image_type=ImageTypeQcow  access_type=loadbalancer  deployment=vm

   ${cluster_name}=  Get Default Cluster Name
   Set Suite Variable  ${cluster_name}

Teardown
   Cleanup Provisioning
   FloatingIps Should Match  cloudlet=${cloudlet}  max_value=6  used_value=2

   Delete Cloudlet  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_openstack_fip}
 
Find Floatingips
   [Arguments]  ${info}

   ${found}=  Set Variable  ${None}
   FOR  ${i}  IN  @{info}
      IF  '${i['name']}' == 'Floating IPs'
          ${found}=  Set Variable  ${i}
      END
      Exit For Loop If  ${found} != ${None}
   END

   Run Keyword If  ${found} == ${None}  Fail  Floatin IPs not found

   [Return]  ${found}

FloatingIps Should Match
   [Arguments]  ${cloudlet}  ${max_value}  ${used_value}

   ${found}=  Set Variable  ${False}
   FOR   ${n}  IN RANGE  0  10
      ${cloudlet_info}=  Show Cloudlet Info  region=${region}  cloudlet_name=${cloudlet['data']['key']['name']}
      ${floatingips}=  Find Floatingips  ${cloudlet_info[0]['data']['resources_snapshot']['info']}

      IF  ${floatingips['infra_max_value']} == ${max_value} and ${floatingips['value']} == ${used_value}
         ${found}=  Set Variable  ${True}
         Exit For Loop
      ELSE
         Sleep  10s
      END
   END

   Run Keyword If  ${found} == ${False}  Fail  Floatin IPs dont match max=${max_value} used=${used_value}

Resource Usage Metrics Should Be Correct
   ${metrics}=  Get Cloudlet Usage Metrics  region=${region}  selector=resourceusage  cloudlet_name=${cloudlet['data']['key']['name']}  operator_org_name=${operator_name_openstack_fip}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  externalIpsUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  floatingIpsUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  gpusUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  instancesUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  ramUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  vcpusUsed

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}  openstack-resource-usage

   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][4][1]}  ${cloudlet['data']['key']['name']}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['values'][4][2]}  ${operator_name_openstack_fip}


