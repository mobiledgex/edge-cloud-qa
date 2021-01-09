*** Settings ***
Documentation   Create App with imagepath org verification

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Cleanup Provisioning

*** Variables ***
${region}=  US 

*** Test Cases ***

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=docker and org does not match
    [Documentation]
    ...  create app wih image_type=ImageTypeDocke deployment=docker and image_path has org mismatch with developer
    ...  verify error is received

    ${orgname}=  Get Default Organization Name

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  region=${region}  developer_org_name=xx  image_type=ImageTypeDocker  deployment=docker  image_path=docker-qa.mobiledgex.net/${orgname}/images/server_ping_threaded:5.0

    Should Contain  ${error_msg}  code=400 
    Should Contain  ${error_msg}  error={"message":"ImagePath for .mobiledgex.net registry using organization \\'${orgname}\\' does not match App developer name \\'xx\\', must match"} 

CreateApp - error shall be received wih image_type=ImageTypeDocker deployment=kubernetes and org does not match
    [Documentation]
    ...  create app wih image_type=ImageTypeDocker deployment=kubernetes and image_path has org mismatch with developer
    ...  verify error is received

    ${orgname}=  Get Default Organization Name

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  region=${region}  developer_org_name=xx  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker-qa.mobiledgex.net/${orgname}/images/server_ping_threaded:5.0

    Should Contain  ${error_msg}  code=400
    Should Contain  ${error_msg}  error={"message":"ImagePath for .mobiledgex.net registry using organization \\'${orgname}\\' does not match App developer name \\'xx\\', must match"}

CreateApp - error shall be received wih image_type=ImageTypeQcow deployment=vm and org does not match
    [Documentation]
    ...  create app wih image_type=ImageTypeQCOW deployment=vm and org does not match with developer
    ...  verify error is received

    ${orgname}=  Get Default Organization Name

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  region=${region}  developer_org_name=xx  image_type=ImageTypeQcow  deployment=vm  image_path=https://artifactory-qa.mobiledgex.net/artifactory/repo-${orgname}/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d

    Should Contain  ${error_msg}  code=400
    Should Contain  ${error_msg}  error={"message":"ImagePath for .mobiledgex.net registry using organization \\'${orgname}\\' does not match App developer name \\'xx\\', must match"}

CreateApp - shall be to create with image_type=ImageTypeDocker deployment=docker and org does match
    [Documentation]
    ...  create app wih image_type=ImageTypeDocke deployment=docker and image_path has org match with developer
    ...  verify it passes the org check and gets image not found error 

    ${orgname}=  Get Default Organization Name

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  region=${region}  developer_org_name=${orgname}  image_type=ImageTypeDocker  deployment=docker  image_path=docker-qa.mobiledgex.net/${orgname}/images/server_ping_threaded:5.0

    Should Contain  ${error_msg}  code=400
    Should Contain  ${error_msg}  error={"message":"Failed to validate docker registry image, path docker-qa.mobiledgex.net/${orgname}/images/server_ping_threaded:5.0, Image at https://docker-qa.mobiledgex.net/v2/${orgname}/images/server_ping_threaded/tags/list not found, please confirm it has been uploaded to the registry"}

CreateApp - shall be to create with image_type=ImageTypeDocker deployment=kubernetes and org does match
    [Documentation]
    ...  create app wih image_type=ImageTypeDocke deployment=kubernetes and image_path has org match with developer
    ...  verify it passes the org check and gets image not found error

    ${orgname}=  Get Default Organization Name

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  region=${region}  developer_org_name=${orgname}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=docker-qa.mobiledgex.net/${orgname}/images/server_ping_threaded:5.0

    Should Contain  ${error_msg}  code=400
    Should Contain  ${error_msg}  error={"message":"Failed to validate docker registry image, path docker-qa.mobiledgex.net/${orgname}/images/server_ping_threaded:5.0, Image at https://docker-qa.mobiledgex.net/v2/${orgname}/images/server_ping_threaded/tags/list not found, please confirm it has been uploaded to the registry"}

CreateApp - shall be to create with image_type=ImageTypeQcow deployment=vm and org does match
    [Documentation]
    ...  create app wih image_type=ImageTypeQcow deployment=vm and image_path has org match with developer
    ...  verify it passes the org check and gets image not found error

    ${orgname}=  Get Default Organization Name

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  region=${region}  developer_org_name=${orgname}  image_type=ImageTypeQcow  deployment=vm  image_path=https://artifactory-qa.mobiledgex.net/artifactory/repo-${orgname}/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d

    Should Contain  ${error_msg}  code=400
    Should Contain  ${error_msg}  error={"message":"Failed to validate VM registry image, path https://artifactory-qa.mobiledgex.net/artifactory/repo-${orgname}/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d, Invalid URL: https://artifactory-qa.mobiledgex.net/artifactory/repo-${orgname}/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d, Not Found"}

*** Keywords ***
Setup
    Create Flavor  region=${region}
    Create Org 
