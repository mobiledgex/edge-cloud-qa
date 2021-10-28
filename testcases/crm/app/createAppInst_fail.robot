*** Settings ***
Documentation   CreateAppInst 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String

Test Setup	Setup
Test Teardown   Cleanup Provisioning	

*** Variables ***
${operator_name_openstack}   GDDT 
${cloudlet_name_openstack_vm}  automationBuckhornCloudlet
${mobile_latitude}  1
${mobile_longitude}  1
${qcow_centos_image}  qcowimage

*** Test Cases ***
# ECQ-1634
AppInst - VM deployment with wrong md5 shall fail
    [Documentation]
    ...  - create a VM app instance with wrong md5 
    ...  - verify proper error is received 

    ${app_name_default}=  Get Default App Name

    ${qcow_new}=  Replace String Using Regexp  ${qcow_centos_image}  [1,2,3,4,6,,8,9]  2
    
    Create App   deployment=vm  image_type=ImageTypeQCOW  image_path=${qcow_new}
    ${error}=  Run Keyword and Expect Error  *  Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  use_defaults=${False}
    
    Should Contain  ${error}  details = "Encountered failures: Create App Inst failed: mismatch in md5sum 
    Should Contain  ${error}  status = StatusCode.UNKNOWN

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor
    
    ${app_version_default}=  Get Default App Version
    ${developer_name_default}=  Get Default Developer Name
    ${flavor_name_default}=  Get Default Flavor Name
  
    Set Suite Variable  ${app_version_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${flavor_name_default}

