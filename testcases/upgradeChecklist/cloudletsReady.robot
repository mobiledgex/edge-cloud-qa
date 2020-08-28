*** Settings ***
Documentation  Check Cloudlets in Ready state 

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         MexOpenstack
Library         String 

#Test Setup	Setup
#Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   mex1234567
${orgname}=    TheAdminOrg
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw

@{cloudlets}=  automationBuckhornCloudlet  automationSunnydaleCloudlet  gcpcloud-11574672319
&{openstack_envs}=  automationBuckhornCloudlet=/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_buckhorn.mex

${num_cores_needed}=  50 
${num_ips_needed}=    50

*** Test Cases ***
All Cloudlets should be Ready
	[Documentation]
	...  admin user can show role assignments with no assignments
	...  verify the roles returned

   @{cloudletinfo}=  Show Cloudlet Info  region=US

   #&{cloudlet_dict}=  Create Dictionary 

   Log To Console  Checking @{cloudlets}

   :FOR  ${cloudlet}  IN  @{cloudletinfo}
   \  Run Keyword If  '${cloudlet['data']['key']['name']}' in @{cloudlets} and ${cloudlet['data']['state']} != 2   Fail  ${cloudlet['data']['key']['name']} is state=${cloudlet['data']['state']} expected state=2

   #log to console  ${cloudlet_dict}

   
All Cloudlets should have enough resources
   [Documentation]
   ...  admin user can show role assignments with no assignments
   ...  verify the roles returned

   # check for cores
   :FOR  ${cloudlet}  IN  @{openstack_envs.keys()}
   \  ${limits}=  Get limits  env_file=${openstack_envs['${cloudlet}']}
   \  Should Be True  ${limits['maxTotalCores']} - ${limits['totalCoresUsed']} >= ${num_cores_needed}  ${cloudlet} does not have enough cores. used=${limits['totalCoresUsed']} out of ${limits['maxTotalCores']}

   # check for IPs
   :FOR  ${cloudlet}  IN  @{openstack_envs.keys()}
   \  ${subnet}=  Get Subnet Details  external-subnet  env_file=${openstack_envs['${cloudlet}']}
   \  @{iprange}=  Split String  ${subnet['allocation_pools']}  separator=-
   \  ${maxips}=  Evaluate  int(ipaddress.IPv4Address('${iprange[1]}')) - int(ipaddress.IPv4Address('${iprange[0]}')) + 1  modules=ipaddress
   \
   \  ${networkcount}=  Get Server IP Count  ${cloudlet} 
   \  Log To Console  ${cloudlet} has used ${networkcount} IPs out of ${maxips}
   \  Should Be True  ${maxips} - ${networkcount} >= ${num_ips_needed}  ${cloudlet} does not have enough IPs. used=${networkcount} out of ${maxips}

*** Keywords ***
Get Server IP Count
   [Arguments]  ${cloudlet}

   @{servers}=  Get Server List  env_file=${openstack_envs['${cloudlet}']}
   ${networkcount}=  Set Variable  0
   :FOR  ${server}  IN  @{servers}
   \     ${contains}=  Evaluate  'external-network-shared' in '${server['Networks']}'
   #\     log to console  ${contains}
   \     ${networkcount}=  Run Keyword If  ${contains} == ${True}  Evaluate  ${networkcount} + 1  ELSE  Set Variable  ${networkcount}

   [return]  ${networkcount}
