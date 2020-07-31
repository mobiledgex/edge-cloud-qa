*** Settings ***
Documentation  UpdateClusterInst with different userroles  

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationBonnCloudlet
${operator_name_openstack}  TDG

${developer_org_name}=  MobiledgeX

${mobiledgex_domain}  mobiledgex.net

${region}=  EU

${test_timeout_crm}  15 min

${username}          mextester06
${password}          mextester06123


*** Test Cases ***
User shall be able to Update Cluster Instance as Developer Manager
    [Documentation]
    ...  Developer Manager can update cluster instance 

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=developer
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname} 
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}
    Log To Console  Done Updating Cluster Instance


User shall be able to Update Cluster Instance as Developer Contributor
    [Documentation]
    ...  Developer Contributor can update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=developer
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperContributor

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}
    Log To Console  Done Updating Cluster Instance


User shall not be able to Update Cluster Instance as Developer Viewer
    [Documentation]
    ...  Developer Viewer cannot update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=developer

    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperViewer

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')   Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}


User shall not be able to Update Cluster Instance as Operator Manager
    [Documentation]
    ...  Operator Manager cannot update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=operator
    Adduser Role  orgname=${orgname}  username=${username1}  role=OperatorManager

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')   Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}


User shall not be able to Update Cluster Instance as Operator Viewer
    [Documentation]
    ...  Operator Viewer cannot update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=operator
    Adduser Role  orgname=${orgname}  username=${username1}  role=OperatorViewer

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')   Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}


User shall not be able to Update Cluster Instance as Operator Contributor
    [Documentation]
    ...  Operator Contributor cannot update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=operator
    Adduser Role  orgname=${orgname}  username=${username1}  role=OperatorContributor

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')   Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}


*** Keywords ***
Setup
    ${i}=  Get Time  epoch
    ${orgname}=  Catenate  SEPARATOR=  org  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Create Flavor  region=${region}

    Skip Verify Email
    Create user  username=${username1}  password=${password}  email_address=${email1}  
    Unlock User  username=${username1}

    Set Suite Variable  ${orgname}
    Set Suite Variable  ${username1}


