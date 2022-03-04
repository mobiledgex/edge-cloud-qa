*** Settings ***
Documentation   MasterController Org Update
	
Library		MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
	
*** Test Cases ***
# ECQ-4404
MC - Shall be able to update an operator org 
    [Documentation]
    ...  - update an operator org for various args
    ...  - verify org is updated

    [Setup]  Create Operator Org
    [Template]  Update Organization

    address=123 main st
    phone=112233
    address=12399 main st  phone=11223399       
    delete_in_progress=${True}
    delete_in_progress=${False}
    edgebox_only=${True}
    edgebox_only=${False}

# ECQ-4406
MC - Shall be able to update an developer org
    [Documentation]
    ...  - update a developer org for various args
    ...  - verify org is updated

    [Setup]  Create Developer Org
    [Template]  Update Organization

    address=123 main st
    phone=112233
    address=12399 main st  phone=11223399
    public_images=${True}
    public_images=${False}
    delete_in_progress=${True}
    delete_in_progress=${False}
    edgebox_only=${True}
    edgebox_only=${False}

# ECQ-4405
MC - Shall not be able to update restricted parms or bad values in an operator org
    [Documentation]
    ...  - update an operator org for various unsupported args and bad values
    ...  - verify error is returned

    [Setup]  Create Operator Org
    [Template]  Update Organization Fail

    Cannot update created at  created_at=2006-01-02T15:04:05Z
    Cannot update parent  parent=x
    Cannot update edgeboxonly field for Organization  edgebox_only=${True}

    Gitlab project ${org_name} not found  public_images=${True}

    Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"DeleteInProgress\\\\"  delete_in_progress=x
    Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\"  created_at=x
    Invalid JSON data: Unmarshal time \\\\"updated_at=x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\"  updated_at=x
    Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"PublicImages\\\\"   public_images=x
    Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"EdgeboxOnly\\\\"  edgebox_only=x

# ECQ-4407
MC - Shall not be able to update restricted parms or bad values in a developer org
    [Documentation]
    ...  - update a developer org for various unsupported args and bad values
    ...  - verify error is returned

    [Setup]  Create Developer Org
    [Template]  Update Organization Fail

    Cannot update created at  created_at=2006-01-02T15:04:05Z
    Cannot update parent  parent=x
    Cannot update edgeboxonly field for Organization  edgebox_only=${True}

    Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"DeleteInProgress\\\\"  delete_in_progress=x
    Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\"  created_at=x
    Invalid JSON data: Unmarshal time \\\\"updated_at=x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z\\\\", or \\\\"2006-01-02T15:04:05+07:00\\\\"  updated_at=x
    Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"PublicImages\\\\"   public_images=x
    Invalid JSON data: Unmarshal error: expected bool, but got string for field \\\\"EdgeboxOnly\\\\"  edgebox_only=x

*** Keywords ***
Setup

Create Operator Org
    Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
    ${org_name}=  Create Org    orgtype=operator    address=222 somewhere dr    phone=111-222-3333
 
    Set Suite Variable  ${org_name}
Create Developer Org
    Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
    Create Org    orgtype=developer    address=222 somewhere dr    phone=111-222-3333

Update Organization
    [Arguments]   ${address}=${None}  ${phone}=${None}  ${public_images}=${None}  ${delete_in_progress}=${None}  ${edgebox_only}=${None}

    ${org}=  Update Org   address=${address}  phone=${phone}  public_images=${public_images}  delete_in_progress=${delete_in_progress}  edgebox_only=${edgebox_only}

    ${phone}=  Run Keyword If  '${phone}' == '${None}'  Set Variable  ${org['Phone']}  ELSE  Set Variable  ${phone}
    ${address}=  Run Keyword If  '${address}' == '${None}'  Set Variable  ${org['Address']}  ELSE  Set Variable  ${address}

    Should Be Equal  ${org['Address']}  ${address}
    Should Be Equal  ${org['Phone']}    ${phone}

    IF  ${public_images} == ${True} or (${public_images} == ${None} and 'PublicImages' in ${org})
        Should Be True  ${org['PublicImages']}
    ELSE
        Should Not Contain  ${org}  PublicImages
    END

    IF  ${delete_in_progress} == ${True} or (${delete_in_progress} == ${None} and 'DeleteInProgress' in ${org})
        Should Be True  ${org['DeleteInProgress']}
    ELSE
        Should Not Contain  ${org}  DeleteInProgress
    END

    IF  ${edgebox_only} == ${True} or (${edgebox_only} == ${None} and 'EdgeboxOnly' in ${org})
        Should Be True  ${org['EdgeboxOnly']}
    ELSE
        Should Not Contain  ${org}  EdgeboxOnly
    END

Update Organization Fail
   [Arguments]  ${error_msg}  ${created_at}=${None}  ${delete_in_progress}=${None}  ${parent}=${None}  ${edgebox_only}=${None}  ${public_images}=${None}

   ${error}=  Run Keyword and Expect Error  *  Update Org  created_at=${created_at}  delete_in_progress=${delete_in_progress}  parent=${parent}  edgebox_only=${edgebox_only}  public_images=${public_images}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  ${error_msg}
   #Should Be Equal  ${error}  ('code=400', 'error={"message":"${error_msg}"}') 

