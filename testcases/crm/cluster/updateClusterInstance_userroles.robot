*** Settings ***
Documentation  UpdateClusterInst with different userroles  

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_fake}  tmocloud-1
${operator_name_fake}  dmuus

${developer_org_name}=  MobiledgeX

${mobiledgex_domain}  mobiledgex.net

${region}=  US

${test_timeout_crm}  15 min

${username}          mextester06
${password}          ${mextester06_gmail_password}


*** Test Cases ***
User shall be able to Update Cluster Instance as Developer Manager
    [Documentation]
    ...  Developer Manager can update cluster instance 

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=developer
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60  developer_org_name=${orgname}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname} 
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}
    Log To Console  Done Updating Cluster Instance


User shall be able to Update Cluster Instance as Developer Contributor
    [Documentation]
    ...  Developer Contributor can update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=developer
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperContributor

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60  developer_org_name=${orgname}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Log To Console  Updating Cluster Instance
    Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}
    Log To Console  Done Updating Cluster Instance


User shall not be able to Update Cluster Instance as Developer Viewer
    [Documentation]
    ...  Developer Viewer cannot update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=developer
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperViewer

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60  developer_org_name=${orgname}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    ${user_token}=  Login  username=${username1}  password=${password}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')   Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${user_token}


User shall not be able to Update Cluster Instance as Operator Manager
    [Documentation]
    ...  Operator Manager cannot update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=operator
    Adduser Role  orgname=${orgname}  username=${username1}  role=OperatorManager

    ${org_name_dev}=  Set Variable  ${orgname}_dev
    Create Org  orgname=${org_name_dev}  orgtype=developer
    Adduser Role  orgname=${org_name_dev}  username=${username2}  role=DeveloperManager

    ${operator_token}=  Login  username=${username1}  password=${password}
    ${developer_token}=  Login  username=${username2}  password=${password}
    
    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60  developer_org_name=${org_name_dev}  

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${org_name_dev}
    Log To Console  Done Creating Cluster Instance

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')   Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  autoscale_policy_name=${policy_name_default}  developer_org_name=${org_name_dev}  token=${operator_token}


User shall not be able to Update Cluster Instance as Operator Viewer
    [Documentation]
    ...  Operator Viewer cannot update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=operator
    Adduser Role  orgname=${orgname}  username=${username1}  role=OperatorViewer

    ${org_name_dev}=  Set Variable  ${orgname}_dev
    Create Org  orgname=${org_name_dev}  orgtype=developer
    Adduser Role  orgname=${org_name_dev}  username=${username2}  role=DeveloperManager

    ${operator_token}=  Login  username=${username1}  password=${password}
    ${developer_token}=  Login  username=${username2}  password=${password}

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60  developer_org_name=${org_name_dev}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${org_name_dev}
    Log To Console  Done Creating Cluster Instance

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')   Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${operator_token}


User shall not be able to Update Cluster Instance as Operator Contributor
    [Documentation]
    ...  Operator Contributor cannot update cluster instance

    ${cluster_name_default}=  Get Default Cluster Name
    ${policy_name_default}=  Get Default Autoscale Policy Name

    Create Org  orgname=${orgname}  orgtype=operator
    Adduser Role  orgname=${orgname}  username=${username1}  role=OperatorContributor

    ${org_name_dev}=  Set Variable  ${orgname}_dev
    Create Org  orgname=${org_name_dev}  orgtype=developer
    Adduser Role  orgname=${org_name_dev}  username=${username2}  role=DeveloperManager

    ${operator_token}=  Login  username=${username1}  password=${password}
    ${developer_token}=  Login  username=${username2}  password=${password}

    Create Autoscale Policy  region=${region}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=70  scale_down_cpu_threshold=50  trigger_time=60  developer_org_name=${org_name_dev}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  ip_access=IpAccessShared   deployment=kubernetes  number_nodes=1  developer_org_name=${org_name_dev}
    Log To Console  Done Creating Cluster Instance

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')   Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  autoscale_policy_name=${policy_name_default}  developer_org_name=${orgname}  token=${operator_token}


*** Keywords ***
Setup
    ${i}=  Get Time  epoch
    ${orgname}=  Catenate  SEPARATOR=  org  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
    ${email2}=  Catenate  SEPARATOR=  ${username}1  +  ${i}  @gmail.com
    ${username2}=  Catenate  SEPARATOR=  ${username}  1  ${i}

    Create Flavor  region=${region}

    Skip Verify Email
    Create user  username=${username1}  password=${password}  email_address=${email1}  
    Unlock User  username=${username1}

    Skip Verify Email
    Create user  username=${username2}  password=${password}  email_address=${email2}
    Unlock User  username=${username2}

    Set Suite Variable  ${orgname}
    Set Suite Variable  ${username1}
    Set Suite Variable  ${username2}


