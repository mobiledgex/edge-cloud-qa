*** Settings ***
Documentation    GPUDriver userrole tests

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
${driverpath1}  https://artifactory.mobiledgex.net:443/artifactory/packages/pool/nvidia-450_450.102.04.1-4.15.0-135-generic-1_amd64.deb
${kernelversion1}  4.15.0-135-generic
${md5sum1}  aa89cc385928a781d77472b88a54d9d4

${region}=  EU
${cloudlet_name}  automationParadiseCloudlet
${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3649
Operator shall be able to UpdateCloudlet using a gpudriver with no org
    [Documentation]
    ...  Create a gpudriver with no org as mexadmin
    ...  Create a user with role OperatorContributor and login
    ...  Verify that gpudriver is visible
    ...  UpdateCloudlet to map the gpudriver to the cloudlet

    ${epoch}=  Get Time  epoch
    ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
    ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com

    Skip Verify Email
    Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
    Unlock User

    Adduser Role  username=${usernameop_epoch}  orgname=GDDT  role=OperatorContributor
    ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}

    &{properties}=  Create Dictionary  FPS=10
    ${gpudriver}=  Create Gpudriver  region=${region}  gpudriver_org=${Empty}  builds_dict=${driver_details}  properties=${properties}  token=${super_token}

    ${gpudriver}=  Show Gpudriver  region=${region}  gpudriver_org=${Empty}  token=${tokenop}
    Should Be Equal  ${gpudriver[0]['data']['key']['name']}  ${gpudriver_name}

    ${gpudriver}=  Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  gpudriver_name=${gpudriver_name}  gpudriver_org=${Empty}
    Should Be Equal  ${gpudriver['data']['gpu_config']['driver']['name']}  ${gpudriver_name}
    ${gpudriver}=  Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  gpudriver_name=${Empty}

# ECQ-3650
OperatorManager of Org A shall not be able to UpdateCloudlet using gpudriver of Org B
    [Documentation]
    ...  Create a gpudriver as OperatorManager of Org A
    ...  Login as OperatorManager of Org B
    ...  UpdateCloudlet to map the gpudriver of Org A to the cloudlet of Org B
    ...  Controller throws error

    ${epoch}=  Get Time  epoch
    ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
    ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com

    Skip Verify Email
    Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
    Unlock User

    Adduser Role  username=${usernameop_epoch}  orgname=packet  role=OperatorManager
    ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}
    ${tokenop1}=  Login  username=op_manager_automation  password=${op_manager_password_automation}

    &{properties}=  Create Dictionary  FPS=10
    ${gpudriver}=  Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}  properties=${properties}  token=${tokenop1}

    ${error_msg}=  Run Keyword and Expect Error  *  Update Cloudlet  region=US  operator_org_name=packet  cloudlet_name=packet-qaregression  gpudriver_name=${gpudriver_name}  gpudriver_org=dmuus  token=${tokenop}
    Should Contain  ${error_msg}  'code=400', 'error={"message":"Can only use packet or \\\'\\\' org gpu drivers"}'

# ECQ-3651	
Operator shall not be able to create/update/delete/addbuild/removebuild a gpudriver with no org
    [Documentation]
    ...  Controller throws 403 Forbidden when OperatorManager tries to create a gpudriver with no org
    ...  Create a gpudriver with no org as mexadmin
    ...  Controller throws 403 Forbidden when OperatorManager tries to update/delete/addbuild/removebuild to this gpudriver

    &{properties}=  Create Dictionary  FPS=10
    ${tokenop}=  Login  username=op_manager_automation  password=${op_manager_password_automation}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Gpudriver  region=US  gpudriver_org=${Empty}  builds_dict=${driver_details} 

    ${gpudriver}=  Create Gpudriver  region=US  gpudriver_org=${Empty}  builds_dict=${driver_details}  token=${super_token}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Gpudriver  region=US  gpudriver_org=${Empty}  properties=${properties}  token=${tokenop}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Gpudriver  region=US  gpudriver_org=${Empty}  token=${tokenop}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Addbuild Gpudriver  region=US  gpudriver_org=${Empty}  build_name=${gpudriver_build}1  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic   token=${tokenop}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Removebuild Gpudriver  region=US  gpudriver_org=${Empty}  build_name=${gpudriver_build}  token=${tokenop}

# ECQ-3652
OperatorContributor shall be able to create/update/delete/addbuild/removebuild to a gpudriver
    [Documentation]
    ...  Login as user with role OperatorContributor
    ...  OperatorContributor is able to create/update/delete/addbuild/removebuild to a gpudriver

    ${tokenop}=  Login  username=op_contributor_automation  password=${op_contributor_password_automation}

    &{properties}=  Create Dictionary  FPS=10
    ${gpudriver}=  Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}  properties=${properties}  token=${tokenop}
    Dictionary Should Not Contain Key  ${gpudriver['data']['builds'][0]}  driver_path
    Should Be Equal  ${gpudriver['data']['builds'][0]['kernel_version']}  4.15.0-143-generic
    Should Be Equal  ${gpudriver['data']['builds'][0]['md5sum']}   ${md5sum}
    Dictionary Should Contain Key  ${gpudriver['data']}  properties

    &{properties}=  Create Dictionary  FPS=20
    ${gpudriver}=  Update Gpudriver  region=US  gpudriver_org=dmuus  properties=${properties}  token=${tokenop}
    Should Be Equal  ${gpudriver['data']['properties']['FPS']}  20

    ${gpudriver}=  Addbuild Gpudriver  region=US  gpudriver_org=dmuus  build_name=${gpudriver_build}1  build_driverpath=${driverpath1}  build_os=Linux  build_md5sum=${md5sum1}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=${kernelversion1}  token=${tokenop}

    Length Should Be   ${gpudriver['data']['builds']}  2

    ${gpudriver}=  Removebuild Gpudriver  region=US  gpudriver_org=dmuus  build_name=${gpudriver_build}1  token=${tokenop}

    Length Should Be   ${gpudriver['data']['builds']}  1

# ECQ-3653
OperatorViewer shall not be able to create/update/delete/addbuild/removebuild to a gpudriver
    [Documentation]
    ...  Login as user with role OperatorViewer
    ...  Controller throws 403 forbidden when OperatorViewer tries to create/update/delete/addbuild/removebuild to a gpudriver

    &{properties}=  Create Dictionary  FPS=10
    ${tokenopv}=  Login  username=op_viewer_automation  password=${op_viewer_password_automation}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}

    ${tokenopm}=  Login  username=op_manager_automation  password=${op_manager_password_automation}
    Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}  token=${tokenopm}
    ${gpudriver}=   Show Gpudriver  region=US  gpudriver_org=dmuus  token=${tokenopv}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Gpudriver  region=US  gpudriver_org=dmuus  properties=${properties}  token=${tokenopv}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Gpudriver  region=US  gpudriver_org=dmuus  token=${tokenopv}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Addbuild Gpudriver  region=US  gpudriver_org=dmuus  build_name=${gpudriver_build}1  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic  token=${tokenopv}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Removebuild Gpudriver  region=US  gpudriver_org=dmuus  build_name=${gpudriver_build}  token=${tokenopv}

# ECQ-3654
DeveloperContributor shall not be able to create/update/delete/addbuild/removebuild a gpudriver
    [Documentation]
    ...  Login as user with role DeveloperContributor
    ...  Controller throws 403 forbidden when DeveloperContributor tries to create/update/delete/addbuild/removebuild to a gpudriver

    &{properties}=  Create Dictionary  FPS=10
    ${tokendev}=  Login  username=dev_contributor_automation  password=${dev_contributor_password_automation}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}

    Create Gpudriver  region=US  gpudriver_org=${Empty}  builds_dict=${driver_details}  token=${super_token}
    ${gpudriver}=   Show Gpudriver  region=US  gpudriver_org=${Empty}  token=${tokendev}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Gpudriver  region=US  gpudriver_org=${Empty}  properties=${properties}  token=${tokendev}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Gpudriver  region=US  gpudriver_org=${Empty}  token=${tokendev}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Addbuild Gpudriver  region=US  gpudriver_org=${Empty}  build_name=${gpudriver_build}1  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic  token=${tokendev}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Removebuild Gpudriver  region=US  gpudriver_org=${Empty}  build_name=${gpudriver_build}  token=${tokendev}

# ECQ-3655
DeveloperViewer shall not be able to create/update/delete/addbuild/removebuild a gpudriver
    [Documentation]
    ...  Login as user with role DeveloperViewer
    ...  Controller throws 403 forbidden when DeveloperViewer tries to create/update/delete/addbuild/removebuild to a gpudriver

    &{properties}=  Create Dictionary  FPS=10
    ${tokendev}=  Login  username=dev_viewer_automation  password=${dev_viewer_password_automation}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}

    Create Gpudriver  region=US  gpudriver_org=${Empty}  builds_dict=${driver_details}  token=${super_token}
    ${gpudriver}=   Show Gpudriver  region=US  gpudriver_org=${Empty}  token=${tokendev}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Gpudriver  region=US  gpudriver_org=${Empty}  properties=${properties}  token=${tokendev}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Gpudriver  region=US  gpudriver_org=${Empty}  token=${tokendev}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Addbuild Gpudriver  region=US  gpudriver_org=${Empty}  build_name=${gpudriver_build}1  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic  token=${tokendev}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Removebuild Gpudriver  region=US  gpudriver_org=${Empty}  build_name=${gpudriver_build}  token=${tokendev}

# ECQ-3656
Developer shall be able to download a gpudriver with no org
    [Documentation]
    ...  Create a gpudriver with no org as mexadmin
    ...  Login as user with role DeveloperViewer
    ...  DeveloperViewer is able to view and getbuildurl of the gpudriver

    &{properties}=  Create Dictionary  FPS=10
    ${gpudriver}=  Create Gpudriver  region=US  gpudriver_org=${Empty}  builds_dict=${driver_details}  properties=${properties}

    ${tokendev}=  Login  username=dev_viewer_automation  password=${dev_viewer_password_automation}
    ${gpudriver}=  Show Gpudriver  region=US  gpudriver_org=${Empty}  token=${tokendev}
    Should Be Equal  ${gpudriver[0]['data']['key']['name']}  ${gpudriver_name}

    ${buildurl}=  GetBuildUrl Gpudriver  region=US  gpudriver_org=${Empty}  build_name=${gpudriver_build}  token=${tokendev}
    Should Contain  ${buildurl['build_url_path']}  storage.googleapis.com
    Should Be Equal  ${buildurl['validity']}  20m0s

# ECQ-3657
GpuDriver with no org shall be visible to all developers/operators
    [Documentation]
    ...  Create a gpudriver with no org as mexadmin
    ...  Login as OperatorManager and verify that gpudriver is visible
    ...  Login as DeveloperManager and verify that gpudriver is visible

    &{properties}=  Create Dictionary  FPS=10
    ${gpudriver}=  Create Gpudriver  region=US  gpudriver_org=${Empty}  builds_dict=${driver_details}  properties=${properties}

    ${tokenop}=  Login  username=op_manager_automation  password=${op_manager_password_automation}
    ${gpudriver}=  Show Gpudriver  region=US  gpudriver_org=${Empty}  token=${tokenop}
    Should Be Equal  ${gpudriver[0]['data']['key']['name']}  ${gpudriver_name}

    ${tokendev}=  Login  username=dev_manager_automation  password=${dev_manager_password_automation}
    ${gpudriver}=  Show Gpudriver  region=US  gpudriver_org=${Empty}  token=${tokendev}
    Should Be Equal  ${gpudriver[0]['data']['key']['name']}  ${gpudriver_name}

# ECQ-3658
OperatorManager of Org A cannot create/update/delete gpudriver of Operator Org B
    [Documentation]
    ...  Login as OperatorManager of Org A
    ...  Controller throws error while creating/updating/deleting gpudriver of Org B

    &{properties}=  Create Dictionary  FPS=10
    Create Gpudriver  region=${region}  gpudriver_org=GDDT2

    ${tokenop}=  Login  username=op_manager_automation  password=${op_manager_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Gpudriver  region=${region}  gpudriver_org=GDDT2  token=${tokenop}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Gpudriver  region=${region}  gpudriver_org=GDDT2  properties=${properties}  token=${tokenop}
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Gpudriver  region=${region}  gpudriver_org=GDDT2  gpudriver_name=${gpudriver_name}1  token=${tokenop}

# ECQ-3659
Developer can view/download gpudriver mapped to public cloudlet
    [Documentation]
    ...  Create a gpudriver for Org A and map it to a public cloudlet
    ...  Login as Developer and verify output of gpudriver show
    ...  Gpudriver is visible to developer and getbuildurl works fine

    &{properties}=  Create Dictionary  FPS=10
    ${gpudriver}=  Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}  properties=${properties}

    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  gpudriver_name=${gpudriver_name}  gpudriver_org=GDDT
    ${tokendev}=  Login  username=dev_contributor_automation  password=${dev_contributor_password_automation}

    ${gpudriver}=  Show Gpudriver  region=${region}  gpudriver_org=GDDT  token=${tokendev}
    Length Should Be   ${gpudriver[0]['data']['builds']}  1
    Should Be Equal  ${gpudriver[0]['data']['properties']['FPS']}  10

    ${buildurl}=  GetBuildUrl Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}  token=${tokendev}
    Should Contain  ${buildurl['build_url_path']}  storage.googleapis.com
    Should Be Equal  ${buildurl['validity']}  20m0s

    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  gpudriver_name=${Empty}  token=${super_token}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${gpudriver_name}=  Get Default Gpudriver Name
    ${gpudriver_build}=  Get Default Gpudriver Build Name
    &{driver_details}=  Create Dictionary  driver_path=${driverpath}  name=${gpudriver_build}  driver_path_creds=apt:mobiledgex  kernel_version=4.15.0-143-generic  md5sum=${md5sum}  operating_system=Linux
   
    Set Suite Variable  ${super_token}
    Set Suite Variable  ${gpudriver_name}
    Set Suite Variable  ${gpudriver_build}
    Set Suite Variable  ${driver_details}
