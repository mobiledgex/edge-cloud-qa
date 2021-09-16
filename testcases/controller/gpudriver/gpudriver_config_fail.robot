*** Settings ***
Documentation   Failure scenarios with gpudriver creation

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

${cloudlet_name}  automationParadiseCloudlet
${gpu_cloudlet}   automationSunnydaleCloudlet
${region}=  EU

*** Test Cases ***
# ECQ-3660
Controller throws error if adding build for Linux OS without providing kernel version
    [Documentation]
    ...  Create a gpudriver for Linux OS without providing kernel version
    ...  Add build to a gpudriver for Linux OS without providing kernel version
    ...  Controller throws error in both cases

    &{properties}=  Create Dictionary  FPS=10
    Remove From Dictionary  ${driver_details}  kernel_version

    ${error_msg}=  Run Keyword and Expect Error  *  Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}  properties=${properties}
    Should Contain  ${error_msg}  Kernel version is required for Linux build

    Create Gpudriver  region=${region}  gpudriver_org=GDDT
    ${error_msg}=  Run Keyword and Expect Error  *  Addbuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex    
    Should Contain  ${error_msg}  Kernel version is required for Linux build

    ${gpudriver}=  Show Gpudriver  region=${region}  gpudriver_org=GDDT
    Should Be Equal  ${gpudriver[0]['data']['builds']}  ${None}

# ECQ-3661
Controller throws error if invalid md5 checksum is provided while adding build
    [Documentation]
    ...  Create a gpudriver with invalid md5 checksum
    ...  Add build to a gpudriver with invalid md5 checksum
    ...  Controller throws error in both cases

    Set To Dictionary  ${driver_details}  md5sum=${md5sum}1

    ${error_msg}=  Run Keyword and Expect Error  *  Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Invalid md5sum specified, expected md5sum 4acc71e8d54bfa92d7f12debf7e0a3a9","code":400}}'

    Create Gpudriver  region=${region}  gpudriver_org=GDDT
    ${error_msg}=  Run Keyword and Expect Error  *  Addbuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}1  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Invalid md5sum specified, expected md5sum 4acc71e8d54bfa92d7f12debf7e0a3a9","code":400}}'

    ${gpudriver}=  Show Gpudriver  region=${region}  gpudriver_org=GDDT
    Should Be Equal  ${gpudriver[0]['data']['builds']}  ${None}

# ECQ-3662
Controller throws error when driverpath contains package other than debian
    [Documentation]
    ...  Create a gpudriver with .run package
    ...  Add build to a gpudriver with .run package
    ...  Controller throws error in both cases

    ${package}=  Set Variable  https://download.nvidia.com/XFree86/Linux-x86_64/450.119.03/NVIDIA-Linux-x86_64-450.119.03.run
    ${md5sum}=  Set Variable  b2725b8c15a364582be90c5fa1d6690f
 
    Set To Dictionary  ${driver_details}  driver_path=${package}
    Set To Dictionary  ${driver_details}  md5sum=${md5sum}

    ${error_msg}=  Run Keyword and Expect Error  *  Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Only supported file extension for Linux GPU driver is \\'.deb\\', given .run","code":400}}'

    Create Gpudriver  region=${region}  gpudriver_org=GDDT
    ${error_msg}=  Run Keyword and Expect Error  *  Addbuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}  build_driverpath=${package}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Only supported file extension for Linux GPU driver is \\'.deb\\', given .run","code":400}}'

    ${gpudriver}=  Show Gpudriver  region=${region}  gpudriver_org=GDDT
    Should Be Equal  ${gpudriver[0]['data']['builds']}  ${None}

# ECQ-3663
Controller throws error while adding build if debian package was built for older kernel version
    [Documentation]
    ...  Create a gpudriver with debian package built for older kernel version
    ...  Add build to a gpudriver with a debian package which was built for older kernel version
    ...  Controller throws error in both cases

    ${driverpath}=  Set Variable  https://artifactory.mobiledgex.net/artifactory/qa-regression/nvidiavgpu-460_460-1_amd64.deb
    ${md5sum}=  Set Variable  6029525db539304f23ddcb9e5c97fe42

    Set To Dictionary  ${driver_details}  driver_path=${driverpath}
    Set To Dictionary  ${driver_details}  md5sum=${md5sum}
    Set To Dictionary  ${driver_details}  driver_path_creds=qa-regression:L2ihKxGzo3

    ${error_msg}=  Run Keyword and Expect Error  *  Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Driver package(\\\\"GDDT/${gpudriver_name}/${gpudriver_build}.deb\\\\") should have Linux Kernel dependency(\\\\"4.15.0-143-generic\\\\") specified as part of debian control file

    Create Gpudriver  region=${region}  gpudriver_org=GDDT
    ${error_msg}=  Run Keyword and Expect Error  *  Addbuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=qa-regression:L2ihKxGzo3  build_kernelversion=4.15.0-143-generic
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Driver package(\\\\"GDDT/${gpudriver_name}/${gpudriver_build}.deb\\\\") should have Linux Kernel dependency(\\\\"4.15.0-143-generic\\\\") specified as part of debian control file

    ${gpudriver}=  Show Gpudriver  region=${region}  gpudriver_org=GDDT
    Should Be Equal  ${gpudriver[0]['data']['builds']}  ${None}

# ECQ-3664
Controller throws error while adding build if invalid credentials are provided
    [Documentation]
    ...  Create a gpudriver with invalid driver path credentials
    ...  Add build to a gpudriver with invalid driver path credentials
    ...  Controller throws error in both cases

    ${driverpath}=  Set Variable  https://artifactory.mobiledgex.net/artifactory/qa-regression/nvidiavgpu-460_460-1_amd64.deb
    ${md5sum}=  Set Variable  6029525db539304f23ddcb9e5c97fe42

    Set To Dictionary  ${driver_details}  driver_path=${driverpath}
    Set To Dictionary  ${driver_details}  md5sum=${md5sum}

    ${error_msg}=  Run Keyword and Expect Error  *  Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Failed to download GPU driver build ${driverpath}, Invalid credentials to access URL: ${driverpath}","code":400}}

    Create Gpudriver  region=${region}  gpudriver_org=GDDT
    ${error_msg}=  Run Keyword and Expect Error  *  Addbuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}  build_driverpath=${driverpath}  build_os=Linux  build_md5sum=${md5sum}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-143-generic
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Failed to download GPU driver build ${driverpath}, Invalid credentials to access URL: ${driverpath}","code":400}}

    ${gpudriver}=  Show Gpudriver  region=${region}  gpudriver_org=GDDT
    Should Be Equal  ${gpudriver[0]['data']['builds']}  ${None}

# ECQ-3665
ClusterInst/AppInst creation of gpu flavor on a cloudlet not mapped to GPU driver fails
    [Documentation]
    ...  Create a clusterinst of gpu flavor
    ...  Create an appinst of gpu flavor on a reservable cluster
    ...  Controller throws error in both cases since cloudlet is not mapped to gpudriver

    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  gpudriver_name=${Empty}

    ${error_msg}=  Run Keyword and Expect Error  *   Create Cluster Instance  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=automation_gpu_flavor
    Should Contain  ${error_msg}  'code=400', 'error={"message":"No GPU driver associated with cloudlet {GDDT ${cloudlet_name}}"}

    Create App  region=${region}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015  default_flavor_name=automation_gpu_flavor
    ${error_msg}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  cluster_instance_name=autocluster1
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"No GPU driver associated with cloudlet {GDDT ${cloudlet_name}}","code":400}}'

# ECQ-3666
Deletion of GpuDriver is use by Cloudlet fails
    [Documentation]
    ...  Create a gpudriver
    ...  UpdateCloudlet to map the gpudriver with the cloudlet
    ...  Controller throws error while trying to delete the gpudriver

    Create Gpudriver  region=${region}  gpudriver_org=GDDT  builds_dict=${driver_details}
    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  gpudriver_name=${gpudriver_name}  gpudriver_org=GDDT

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Gpudriver  region=${region}  gpudriver_org=GDDT
    Should Contain  ${error_msg}  'code=400', 'error={"message":"GPU driver in use by Cloudlet(s): ${cloudlet_name}"}

    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${cloudlet_name}  gpudriver_name=${Empty} 

# ECQ-3667
ClusterInst create on cloudlet mapped to incompatible GPU driver fails
    [Documentation]
    ...  Create a gpudriver and addbuild a debian package built for older kernel version
    ...  UpdateCloudlet to map the gpudriver to the cloudlet
    ...  Controller throws error while creating clusterinst since the correct debian package cannot be found

    Create Gpudriver  region=${region}  gpudriver_org=GDDT
    Addbuild Gpudriver  region=${region}  gpudriver_org=GDDT  build_name=${gpudriver_build}  build_driverpath=${driverpath1}  build_os=Linux  build_md5sum=${md5sum1}  build_driverpathcreds=apt:mobiledgex  build_kernelversion=4.15.0-135-generic

    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${gpu_cloudlet}  gpudriver_name=${gpudriver_name}  gpudriver_org=GDDT
    ${error_msg}=  Run Keyword and Expect Error  *   Create Cluster Instance  region=${region}  operator_org_name=GDDT  cloudlet_name=${gpu_cloudlet}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=automation_gpu_flavor
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Encountered failures: Create failed: failed to install GPU drivers on cluster VM: Unable to find Linux GPU driver build for kernel version 4.15.0-154-generic

    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${gpu_cloudlet}  gpudriver_name=nvidia-450  gpudriver_org=GDDT

# ECQ-3668
ClusterInst creation of gpu flavor fails if gpudriver does not contain any build
    [Documentation]
    ...  Create a gpudriver , no build is added to the driver
    ...  UpdateCloudlet to map the gpudriver to the cloudlet
    ...  Controller throws error while creating clusterinst since no debian package is found

    Create Gpudriver  region=${region}  gpudriver_org=GDDT

    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${gpu_cloudlet}  gpudriver_name=${gpudriver_name}  gpudriver_org=GDDT
    ${error_msg}=  Run Keyword and Expect Error  *   Create Cluster Instance  region=${region}  operator_org_name=GDDT  cloudlet_name=${gpu_cloudlet}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=automation_gpu_flavor
    Should Contain  ${error_msg}  'code=200', 'error={"result":{"message":"Encountered failures: Create failed: failed to install GPU drivers on cluster VM: Unable to find Linux GPU driver build for kernel version 4.15.0-154-generic

    Update Cloudlet  region=${region}  operator_org_name=GDDT  cloudlet_name=${gpu_cloudlet}  gpudriver_name=nvidia-450  gpudriver_org=GDDT

# ECQ-3669
ClusterInst/AppInst creation fail if GPU type of cloudlet and cluster do not match
    [Documentation]
    ...  Create a gpudriver and map it to a cloudlet
    ...  Cloudlet supports GPU of type Passthrough because of Restag mapping
    ...  Create a clusterinst of flavor which has VGPU in optresmap
    ...  Controller throws error cloudlet GPU type of clusterinst and cloudlet do not match

    Create Gpudriver  region=${region}  gpudriver_org=reportorg1  builds_dict=${driver_details}
    Update Cloudlet  region=${region}  operator_org_name=reportorg1  cloudlet_name=testreportgpu  gpudriver_name=${gpudriver_name}  gpudriver_org=reportorg1

    ${error_msg}=  Run Keyword and Expect Error  *   Create Cluster Instance  region=${region}  developer_org_name=reportdevorg1  operator_org_name=reportorg1  cloudlet_name=testreportgpu  ip_access=IpAccessDedicated  deployment=docker  flavor_name=automation_vgpu_flavor
    Should Contain  ${error_msg}  'code=400', 'error={"message":"Invalid node flavor automation_vgpu_flavor, cloudlet \\\\"testreportgpu\\\\" doesn\\\'t support GPU resource \\\\"resources\\\\""}
 
    Update Cloudlet  region=${region}  operator_org_name=reportorg1  cloudlet_name=testreportgpu  gpudriver_name=${Empty}

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

