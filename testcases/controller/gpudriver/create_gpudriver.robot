*** Settings ***
Documentation   Create/Update/Delete GPUDriver tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  5m

*** Variables ***
${driverpath}  https://artifactory.mobiledgex.net/artifactory/packages/pool/nvidia-450_450.119.03-4.15.0-143-generic-1_amd64.deb
${vgpudriverpath}               https://artifactory.mobiledgex.net/artifactory/qa-regression/nvidia-440_440.87-4.15.0-143-generic-1_amd64.deb
${md5sum}  4acc71e8d54bfa92d7f12debf7e0a3a9
${vgpumd5sum}   fea4a92f82a566c35d7b8d2f57b35ba1
${driverpath1}  https://artifactory.mobiledgex.net:443/artifactory/packages/pool/nvidia-450_450.102.04.1-4.15.0-135-generic-1_amd64.deb
${kernelversion1}  4.15.0-135-generic
${md5sum1}  aa89cc385928a781d77472b88a54d9d4

${region}=  EU

*** Test Cases ***
# ECQ-3641
MexAdmin shall be able to create/update/delete a gpudriver
    [Documentation]
    ...  Create a gpudriver as mexadmin
    ...  Verify output of gpudriver show
    ...  Update the properties of gpudriver

    &{properties}=  Create Dictionary  FPS=10

    ${gpudriver}=  Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}  properties=${properties} 
    Should Contain  ${gpudriver['data']['builds'][0]['driver_path']}  storage.cloud.google.com
    Should Be Equal  ${gpudriver['data']['builds'][0]['kernel_version']}  4.15.0-143-generic
    Should Be Equal  ${gpudriver['data']['builds'][0]['md5sum']}   ${md5sum}
    Dictionary Should Contain Key  ${gpudriver['data']}  properties   

    &{properties}=  Create Dictionary  FPS=20
    ${gpudriver}=  Update Gpudriver  region=${region}  gpudriver_org=GDDT  properties=${properties}
    Should Be Equal  ${gpudriver['data']['properties']['FPS']}  20

# ECQ-3642
MexAdmin shall be able to create a gpudriver without org
    [Documentation]
    ...  Create a gpudriver without org as mexadmin
    ...  Verify output of gpudriver show

    &{properties}=  Create Dictionary  FPS=10

    ${gpudriver}=  Create Gpudriver  region=${region}  gpudriver_org=${Empty}  builds_dict=${driver_details}  properties=${properties}
    Dictionary Should Not Contain Key  ${gpudriver['data']['key']}  organization

# ECQ-3643
MexAdmin shall to able to add/view licenconfig to a gpudriver
    [Documentation]
    ...  Create a gpudriver as mexadmin and add licenseconfig during driver creation
    ...  Create a gpudriver and add licenseconfig during driver updation
    ...  Verify output of gpudriver show for both cases

    &{properties}=  Create Dictionary  FPS=10
    Set To Dictionary  ${driver_details}  driver_path=${vgpudriverpath}
    Set To Dictionary  ${driver_details}  md5sum=${vgpumd5sum}
    Set To Dictionary  ${driver_details}  driver_path_creds=qa-regression:L2ihKxGzo3

    ${gpudriver}=  Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}  properties=${properties}  license_config=`cat ~/Downloads/gridd.conf`  auto_delete=False
    Should Contain  ${gpudriver['data']['license_config']}  storage.cloud.google.com
    Dictionary Should Contain Key  ${gpudriver['data']}  license_config_md5sum
    Should Be Equal  ${gpudriver['data']['builds'][0]['md5sum']}   ${vgpumd5sum}
    Dictionary Should Contain Key  ${gpudriver['data']}  properties

    Delete Gpudriver  region=${region}  gpudriver_org=GDDT

    Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}  properties=${properties}  auto_delete=False
    ${gpudriver}=  Update Gpudriver  region=${region}  gpudriver_org=GDDT  license_config=`cat ~/Downloads/gridd.conf`  properties=${properties}
    Should Contain  ${gpudriver['data']['license_config']}  storage.cloud.google.com
    Dictionary Should Contain Key  ${gpudriver['data']}  license_config_md5sum

    Delete Gpudriver  region=${region}  gpudriver_org=GDDT

    Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}  
    ${gpudriver}=  Update Gpudriver  region=${region}  gpudriver_org=GDDT  license_config=`cat ~/Downloads/gridd.conf`
    Should Contain  ${gpudriver['data']['license_config']}  storage.cloud.google.com
    Dictionary Should Contain Key  ${gpudriver['data']}  license_config_md5sum

# ECQ-3644
MexAdmin shall be able to add/remove build to a gpudriver
    [Documentation]
    ...  Create a gpudriver as mexadmin
    ...  Addbuilds to the driver
    ...  Verify output of gpudriver show

    &{properties}=  Create Dictionary  FPS=10
    Create Gpudriver  region=${region}  gpudriver_org=GDDT  properties=${properties}  auto_delete=False
    ${gpudriver}=  Addbuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic

    Should Contain  ${gpudriver['data']['builds'][0]['driver_path']}  storage.cloud.google.com
    Should Be Equal  ${gpudriver['data']['builds'][0]['kernel_version']}  4.15.0-143-generic
    Should Be Equal  ${gpudriver['data']['builds'][0]['md5sum']}   ${md5sum}
    Dictionary Should Contain Key  ${gpudriver['data']}  properties

    Delete Gpudriver  region=${region}  gpudriver_org=GDDT

    Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}  properties=${properties}
    ${gpudriver}=  Addbuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}1  build_driverpath=${driverpath1}  build_os=Linux  build_md5sum=${md5sum1}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-135-generic
 
    Length Should Be   ${gpudriver['data']['builds']}  2

    ${gpudriver}=  Removebuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}1
    
    Length Should Be   ${gpudriver['data']['builds']}  1

# ECQ-3645
OperatorManager shall be able to create/update/delete a gpudriver
    [Documentation]
    ...  Create a gpudriver as OperatorManager
    ...  Update the properties of gpudriver
    ...  Verify output of gpudriver show

    ${tokenop}=  Login  username=op_manager_automation  password=${op_manager_password_automation}

    &{properties}=  Create Dictionary  FPS=10
    ${gpudriver}=  Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}  properties=${properties}  token=${tokenop}
    Dictionary Should Not Contain Key  ${gpudriver['data']['builds'][0]}  driver_path
    Should Be Equal  ${gpudriver['data']['builds'][0]['kernel_version']}  4.15.0-143-generic
    Should Be Equal  ${gpudriver['data']['builds'][0]['md5sum']}   ${md5sum}
    Dictionary Should Contain Key  ${gpudriver['data']}  properties

    &{properties}=  Create Dictionary  FPS=20
    ${gpudriver}=  Update Gpudriver  region=US  gpudriver_org=dmuus  properties=${properties}  token=${tokenop}
    Should Be Equal  ${gpudriver['data']['properties']['FPS']}  20

# ECQ-3646
OperatorManager shall be able to add licenconfig to a gpudriver
    [Documentation]
    ...  Create a gpudriver as OperatorManager and add licenseconfig during driver creation
    ...  Create a gpudriver and add licenseconfig during driver updation
    ...  Verify output of gpudriver show for both cases , license_config and license_config_md5sum are not visible

    ${tokenop}=  Login  username=op_manager_automation  password=${op_manager_password_automation}

    &{driver_details}=  Create Dictionary  driver_path=${vgpudriverpath}  name=${gpudriver_build}  driver_path_creds=qa-regression:L2ihKxGzo3  kernel_version=4.15.0-143-generic  md5sum=${vgpumd5sum}  operating_system=Linux
    &{properties}=  Create Dictionary  FPS=10
    ${gpudriver}=  Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}  properties=${properties}  license_config=`cat ~/Downloads/gridd.conf`  auto_delete=False  token=${tokenop}
    Dictionary Should Contain Key  ${gpudriver['data']}  license_config
    Should Not Contain  ${gpudriver['data']['license_config']}  storage.cloud.google.com
    Dictionary Should Not Contain Key  ${gpudriver['data']}  license_config_md5sum
    Should Be Equal  ${gpudriver['data']['builds'][0]['md5sum']}   ${vgpumd5sum}
    Dictionary Should Contain Key  ${gpudriver['data']}  properties

    Delete Gpudriver  region=US  gpudriver_org=dmuus  token=${tokenop}

    Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}  properties=${properties}  auto_delete=False  token=${tokenop}
    ${gpudriver}=  Update Gpudriver  region=US  gpudriver_org=dmuus  license_config=`cat ~/Downloads/gridd.conf`  properties=${properties}  token=${tokenop}
    Dictionary Should Contain Key  ${gpudriver['data']}  license_config
    Dictionary Should Not Contain Key  ${gpudriver['data']}  license_config_md5sum
    Should Not Contain  ${gpudriver['data']['license_config']}  storage.cloud.google.com

    Delete Gpudriver  region=US  gpudriver_org=dmuus  token=${tokenop}

    Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}  token=${tokenop}
    ${gpudriver}=  Update Gpudriver  region=US  gpudriver_org=dmuus  license_config=`cat ~/Downloads/gridd.conf`  token=${tokenop}
    Dictionary Should Contain Key  ${gpudriver['data']}  license_config
    Dictionary Should Not Contain Key  ${gpudriver['data']}  license_config_md5sum
    Should Not Contain  ${gpudriver['data']['license_config']}  storage.cloud.google.com

# ECQ-3647
OperatorManager shall be able to add/remove build to a gpudriver
    [Documentation]
    ...  Create a gpudriver as OperatorManager
    ...  Addbuilds to the driver
    ...  Verify output of gpudriver show

    &{properties}=  Create Dictionary  FPS=10

    ${tokenop}=  Login  username=op_manager_automation  password=${op_manager_password_automation}
    Create Gpudriver  region=US  gpudriver_org=dmuus  properties=${properties}  auto_delete=False  token=${tokenop}
    ${gpudriver}=  Addbuild Gpudriver  region=US  gpudriver_org=dmuus  build_name=${gpudriver_build}  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic  token=${tokenop}

    Dictionary Should Not Contain Key  ${gpudriver['data']['builds'][0]}  driver_path
    Should Be Equal  ${gpudriver['data']['builds'][0]['kernel_version']}  4.15.0-143-generic
    Should Be Equal  ${gpudriver['data']['builds'][0]['md5sum']}   ${md5sum}
    Dictionary Should Contain Key  ${gpudriver['data']}  properties

    Delete Gpudriver  region=US  gpudriver_org=dmuus  token=${tokenop}

    Create Gpudriver  region=US  gpudriver_org=dmuus  builds_dict=${driver_details}  properties=${properties}  token=${tokenop}
    ${gpudriver}=  Addbuild Gpudriver  region=US  gpudriver_org=dmuus  build_name=${gpudriver_build}1  build_driverpath=${driverpath1}  build_os=Linux  build_md5sum=${md5sum1}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-135-generic  token=${tokenop}

    Length Should Be   ${gpudriver['data']['builds']}  2

    ${gpudriver}=  Removebuild Gpudriver  region=US  gpudriver_org=dmuus  build_name=${gpudriver_build}1  token=${tokenop}

    Length Should Be   ${gpudriver['data']['builds']}  1

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
