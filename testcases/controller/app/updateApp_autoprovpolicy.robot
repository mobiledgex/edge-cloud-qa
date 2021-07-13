*** Settings ***
Documentation   UpdateApp autoprov policy

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${access_ports_tcp}  tcp:2011

${region}=  US
	
*** Test Cases ***
# ECQ-3603
UpdateApp - user shall be able to add/remove an autoprov policy
    [Documentation]
    ...  - create an app with no autoprov policy
    ...  - update the app changing policy
    ...  - verify policy is updated
    ...  - update the app changing policy again
    ...  - verify policy is updated
    ...  - update the app removing policy
    ...  - verify policy is removed
    ...  - update the app adding a policy
    ...  - verify policy is added

    &{cloudlet1}=  Create Dictionary  name=${cloudlet_name1}  organization=${operator_name_fake}
    @{cloudlets}=  Create List  ${cloudlet1} 
    ${policy1}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  developer_org_name=${developer_org_name_automation}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudlets}
    @{policy_list1}=  Create List  ${policy1['data']['key']['name']}
    ${policy2}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}2  developer_org_name=${developer_org_name_automation}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudlets}
    @{policy_list2}=  Create List  ${policy2['data']['key']['name']}
	
    ${app1}=  Create App  region=${region}  access_ports=${access_ports_tcp}  
    Should Be True  'auto_prov_policies' not in ${app1['data']}

    ${app2}=  Update App  region=${region}  auto_prov_policies=@{policy_list1}
    Should Be Equal     ${app2['data']['auto_prov_policies']}  ${policy_list1}

    ${app3}=  Update App  region=${region}  auto_prov_policies=@{policy_list2}
    Should Be Equal     ${app3['data']['auto_prov_policies']}  ${policy_list2}

    @{empty_list}=  Create List
    ${app4}=  Update App  region=${region}  auto_prov_policies=@{empty_list}
    Should Be True  'auto_prov_policies' not in ${app4['data']}

    ${app5}=  Update App  region=${region}  auto_prov_policies=@{policy_list1}
    Should Be Equal     ${app5['data']['auto_prov_policies']}  ${policy_list1}

# ECQ-3604
UpdateApp - user shall be able to update/remove an autoprov policy 
    [Documentation]
    ...  - create an app with an autoprov policy
    ...  - update the app changing policy
    ...  - verify policy is updated
    ...  - update the app removing policy
    ...  - verify policy is removed
    ...  - update the app adding a policy
    ...  - verify policy is added

    &{cloudlet1}=  Create Dictionary  name=${cloudlet_name1}  organization=${operator_name_fake}
    @{cloudlets}=  Create List  ${cloudlet1}
    ${policy1}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  developer_org_name=${developer_org_name_automation}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudlets}
    @{policy_list1}=  Create List  ${policy1['data']['key']['name']}
    ${policy2}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}2  developer_org_name=${developer_org_name_automation}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudlets}
    @{policy_list2}=  Create List  ${policy2['data']['key']['name']}

    ${app1}=  Create App  region=${region}  access_ports=${access_ports_tcp}  auto_prov_policies=@{policy_list1}
    Should Be Equal     ${app1['data']['auto_prov_policies']}  ${policy_list1}

    ${app3}=  Update App  region=${region}  auto_prov_policies=@{policy_list2}
    Should Be Equal     ${app3['data']['auto_prov_policies']}  ${policy_list2}

    @{empty_list}=  Create List
    ${app4}=  Update App  region=${region}  auto_prov_policies=@{empty_list}
    Should Be True  'auto_prov_policies' not in ${app4['data']}

    ${app5}=  Update App  region=${region}  auto_prov_policies=@{policy_list1}
    Should Be Equal     ${app5['data']['auto_prov_policies']}  ${policy_list1}

*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${cloudlet_name}=  Get Default Cloudlet Name
    ${cloudlet_name1}=  Catenate  SEPARATOR=  ${cloudlet_name}  1
    ${cluster_name}=  Get Default Cluster Name
    ${cluster1}=  Catenate  SEPARATOR=  ${cluster_name}  1

    ${policy_name}=  Get Default Auto Provisioning Policy Name

    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name_fake}
    Create Cluster Instance  region=${region}  cluster_name=${cluster1}  reservable=${True}   cloudlet_name=${cloudlet_name1}  operator_org_name=${operator_name_fake}  developer_org_name=MobiledgeX  ip_access=IpAccessShared  deployment=kubernetes

    Set Suite Variable  ${cloudlet_name1}
    Set Suite Variable  ${policy_name}
