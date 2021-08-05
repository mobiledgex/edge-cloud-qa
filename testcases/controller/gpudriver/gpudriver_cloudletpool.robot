*** Settings ***
Documentation    GPUDriver CloudletPool test

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${driverpath}  https://artifactory.mobiledgex.net/artifactory/packages/pool/nvidia-450_450.119.03-4.15.0-143-generic-1_amd64.deb
${vgpudriverpath}               https://artifactory.mobiledgex.net/artifactory/qa-regression/nvidia-440_440.87-4.15.0-143-generic-1_amd64.deb
${md5sum}  4acc71e8d54bfa92d7f12debf7e0a3a9
${vgpumd5sum}   fea4a92f82a566c35d7b8d2f57b35ba1
${driverpath1}  https://artifactory.mobiledgex.net:443/artifactory/packages/pool/nvidia-450_450.102.04.1-4.15.0-135-generic-1_amd64.deb
${kernelversion1}  4.15.0-135-generic
${md5sum1}  aa89cc385928a781d77472b88a54d9d4

${cloudlet_name}  automationDusseldorfCloudlet
${region}=  EU

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3648
DeveloperOrg part of cloudletpool can only access gpudrivers mapped to private cloudlets belonging to the same cloudletpool
    [Documentation]
    ...  Create 2 cloudletpools for 2 operator orgs and add cloudlets to them
    ...  Add developer orgs to both cloudletpools
    ...  Create GPUDriver as Operator Manager for both operator orgs
    ...  Update Cloudlet to map the gpudriver to the cloudlets
    ...  Developer can only view gpudriver mapped to cloudlet belonging to the same cloudletpool

   Create Cloudlet Pool  region=${region}  token=${super_token}  cloudlet_pool_name=${pool1}  operator_org_name=TDG
   Add Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${pool1}  operator_org_name=TDG  cloudlet_name=automationDusseldorfCloudlet

   Create Cloudlet Pool  region=${region}  token=${super_token}  cloudlet_pool_name=${pool2}  operator_org_name=reportorg1
   Add Cloudlet Pool Member  region=${region}  token=${super_token}  cloudlet_pool_name=${pool2}  operator_org_name=reportorg1  cloudlet_name=testreportgpu

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op1_token}  cloudlet_pool_name=${pool1}  cloudlet_pool_org_name=TDG  developer_org_name=${org_name1}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${tokendev1}  cloudlet_pool_name=${pool1}  cloudlet_pool_org_name=TDG  developer_org_name=${org_name1}  decision=accept  use_defaults=False

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op2_token}  cloudlet_pool_name=${pool2}  cloudlet_pool_org_name=reportorg1  developer_org_name=${org_name2}  use_defaults=False
   Create Cloudlet Pool Access Response  region=${region}  token=${tokendev2}  cloudlet_pool_name=${pool2}  cloudlet_pool_org_name=reportorg1  developer_org_name=${org_name2}  decision=accept  use_defaults=False

   Create Gpudriver  region=${region}  gpudriver_org=TDG  builds_dict=${driver_details}  token=${op1_token}
   Create Gpudriver  region=${region}  gpudriver_org=reportorg1  builds_dict=${driver_details}  token=${op2_token}

   ${gpudriver1}=  Show Gpudriver  region=${region}  gpudriver_org=TDG  token=${tokendev1}
   ${gpudriver2}=  Show Gpudriver  region=${region}  gpudriver_org=reportorg1  token=${tokendev2}

   Should Be Empty  ${gpudriver1}
   Should Be Empty  ${gpudriver2}

   Update Cloudlet  region=${region}  operator_org_name=TDG  cloudlet_name=automationDusseldorfCloudlet  gpudriver_name=${gpudriver_name}  gpudriver_org=TDG  token=${op1_token}
   Update Cloudlet  region=${region}  operator_org_name=reportorg1  cloudlet_name=testreportgpu  gpudriver_name=${gpudriver_name}  gpudriver_org=reportorg1  token=${op2_token}

   ${gpudriver1}=  Show Gpudriver  region=${region}  gpudriver_org=TDG  token=${tokendev1}
   ${gpudriver2}=  Show Gpudriver  region=${region}  gpudriver_org=reportorg1  token=${tokendev2}

   Length Should Be   ${gpudriver1}  1
   Length Should Be   ${gpudriver2}  1

   ${gpudriver1}=  Show Gpudriver  region=${region}  gpudriver_org=reportorg1  token=${tokendev1}
   ${gpudriver2}=  Show Gpudriver  region=${region}  gpudriver_org=TDG  token=${tokendev2}

   Should Be Empty  ${gpudriver1}
   Should Be Empty  ${gpudriver2}

   Update Cloudlet  region=${region}  operator_org_name=TDG  cloudlet_name=automationDusseldorfCloudlet  gpudriver_name=${Empty}  token=${op1_token}
   Update Cloudlet  region=${region}  operator_org_name=reportorg1  cloudlet_name=testreportgpu  gpudriver_name=${Empty}  token=${op2_token}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${gpudriver_name}=  Get Default Gpudriver Name
    ${gpudriver_build}=  Get Default Gpudriver Build Name
    ${pool1}=  Get Default Cloudlet Pool Name
    ${pool2}=  Set Variable  ${pool1}1
    ${org_name1}=  Get Default Organization Name
    ${org_name2}=  Set Variable  ${org_name1}1
    &{driver_details}=  Create Dictionary  driver_path=${driverpath}  name=${gpudriver_build}  driver_path_creds=apt:mobiledgex  kernel_version=4.15.0-143-generic  md5sum=${md5sum}  operating_system=Linux
  
    Create Org  orgname=${org_name1}  orgtype=developer
    Create Billing Org  billing_org_name=${org_name1}  token=${super_token}

    Create Org  orgname=${org_name2}  orgtype=developer
    Create Billing Org  billing_org_name=${org_name2}  token=${super_token}

    ${epoch}=  Get Time  epoch
    ${usernamedev1_epoch}=  Catenate  SEPARATOR=  ${username}  dev1  ${epoch}
    ${emaildev1}=  Catenate  SEPARATOR=  ${username}  dev1  +  ${epoch}  @gmail.com
 
    ${usernamedev2_epoch}=  Catenate  SEPARATOR=  ${username}  dev2  ${epoch}
    ${emaildev2}=  Catenate  SEPARATOR=  ${username}  dev2  +  ${epoch}  @gmail.com

    Skip Verify Email
    Create User  username=${usernamedev1_epoch}  password=${password}  email_address=${emaildev1}
    Unlock User

    Create User  username=${usernamedev2_epoch}  password=${password}  email_address=${emaildev2}
    Unlock User

    Adduser Role  username=${usernamedev1_epoch}  orgname=${org_name1}  role=DeveloperManager
    ${tokendev1}=  Login  username=${usernamedev1_epoch}  password=${password}
 
    Adduser Role  username=${usernamedev2_epoch}  orgname=${org_name2}  role=DeveloperManager  token=${super_token}
    ${tokendev2}=  Login  username=${usernamedev2_epoch}  password=${password}

    Adduser Role  username=${op_manager_user_automation}  orgname=TDG  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
    ${op2_token}=  Login  username=testop1  password=c1C-[L3-g_AV[

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${gpudriver_name}
    Set Suite Variable  ${gpudriver_build}
    Set Suite Variable  ${driver_details}
    Set Suite Variable  ${tokendev1}
    Set Suite Variable  ${tokendev2}
    Set Suite Variable  ${op1_token}
    Set Suite Variable  ${op2_token}
    Set Suite Variable  ${epoch}
    Set Suite Variable  ${pool1}
    Set Suite Variable  ${pool2}
    Set Suite Variable  ${org_name1}
    Set Suite Variable  ${org_name2}
