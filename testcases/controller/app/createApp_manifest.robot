*** Settings ***
Documentation   Create App with manifest

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
CreateApp - error shall be received with ImageTypeQCOW and no manifest md5
    [Documentation]
    ...  create QCOW app with no md5 in manifest 
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath	

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "md5 checksum of image is required. Please append checksum to imagepath: "<url>#md5:checksum"

CreateApp - error shall be received wih ImageTypeQCOW and manifest md5 too short
    [Documentation]
    ...  create QCOW app with md5 in manifest is too short
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath#md5:checksum

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "md5 checksum must be at least 32 characters"

CreateApp - error shall be received wih ImageTypeQCOW and manifest md5 invalid 
    [Documentation]
    ...  create QCOW app with md5 in manifest is invalid
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=mypath#md5:12345678901234567890123456checksum

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   details = "invalid md5 checksum"

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor

