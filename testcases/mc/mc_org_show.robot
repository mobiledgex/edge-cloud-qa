*** Settings ***
Documentation   MasterController org 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
Library         Collections

Test Setup     Setup
Test Teardown   Cleanup Provisioning

*** Variables ***
${username}          mextester99
${password}          ${mextester06_gmail_password}
${email}             mextester99@gmail.com
${dev_address}=  222 dev dr
${dev_phone}=    111-222-3333
${op_address}=  222 op dr
${op_phone}=    222-222-3333

*** Test Cases ***
# ECQ-3481
MC - shall be able to show org by name/address/phone
    [Documentation]
    ...  - create 2 orgs
    ...  - send user show with name/address/phone
    ...  - verify returned info is correct

   [Template]  Show Org with filter

   orgname_to_check=${orgname1}  orgname=${orgname1}  
   orgname_to_check=${orgname1}  address=${dev_address} 
   orgname_to_check=${orgname1}  phone=${dev_phone}
   orgname_to_check=${orgname1}  orgname=${orgname1}  address=${dev_address}
   orgname_to_check=${orgname1}  orgname=${orgname1}  phone=${dev_phone}
   orgname_to_check=${orgname1}  address=${dev_address}  phone=${dev_phone}
   orgname_to_check=${orgname1}  orgname=${orgname1}  address=${dev_address}  phone=${dev_phone}

# ECQ-3482
MC - shall be able to show org by type 
    [Documentation]
    ...  - send org show with all types
    ...  - verify returned info is correct

   @{info_dev}=  Show Organizations  org_type=developer   token=${super_token}  use_defaults=${False}
   @{info_op}=   Show Organizations  org_type=operator   token=${super_token}  use_defaults=${False}
   @{info_all}=  Show Organizations  token=${super_token}  use_defaults=${False}

   FOR  ${org}  IN  @{info_dev}
      Should Be Equal  ${org['Type']}  developer
   END

   FOR  ${org}  IN  @{info_op}
      Should Be Equal  ${org['Type']}  operator
   END

   ${num_dev}=  Get Length  ${info_dev}
   ${num_op}=  Get Length  ${info_op}
   ${num_all}  Get Length  ${info_all}

   Should Be True  ${num_dev} + ${num_op} == ${num_all}

# ECQ-3483
MC - shall be able to show org by edgeboxonly
    [Documentation]
    ...  - send org show with edgeboxonly
    ...  - verify returned info is correct

   @{info_true}=  Show Organizations  edgebox_only=${True}   token=${super_token}  use_defaults=${False}
   @{info_false}=   Show Organizations  edgebox_only=${False}   token=${super_token}  use_defaults=${False}
   @{info_all}=  Show Organizations  token=${super_token}  use_defaults=${False}

   FOR  ${org}  IN  @{info_true}
      Should Be True  ${org['EdgeboxOnly']}
   END

   FOR  ${org}  IN  @{info_false}
      Should Be True  'EdgeboxOnly' not in ${org}
   END

   ${num_true}=  Get Length  ${info_true}
   ${num_false}=  Get Length  ${info_false}
   ${num_all}  Get Length  ${info_all}

   Should Be True  ${num_true} + ${num_false} == ${num_all}

# ECQ-3484
MC - shall be able to show org by publicimages
    [Documentation]
    ...  - send org show with publicimages
    ...  - verify returned info is correct

   @{info_true}=  Show Organizations  public_images=${True}   token=${super_token}  use_defaults=${False}
   @{info_false}=   Show Organizations  public_images=${False}   token=${super_token}  use_defaults=${False}
   @{info_all}=  Show Organizations  token=${super_token}  use_defaults=${False}

   FOR  ${org}  IN  @{info_true}
      Should Be True  ${org['PublicImages']}
   END

   FOR  ${org}  IN  @{info_false}
      Should Be True  'PublicImages' not in ${org}
   END

   ${num_true}=  Get Length  ${info_true}
   ${num_false}=  Get Length  ${info_false}
   ${num_all}  Get Length  ${info_all}

   Should Be True  ${num_true} + ${num_false} == ${num_all}

# ECQ-3485
MC - shall be able to show org by deleteinprogress
    [Documentation]
    ...  - send org show with deleteinprogress
    ...  - verify returned info is correct

   @{info_true}=  Show Organizations  delete_in_progress=${True}   token=${super_token}  use_defaults=${False}
   @{info_false}=   Show Organizations  delete_in_progress=${False}   token=${super_token}  use_defaults=${False}
   @{info_all}=  Show Organizations  token=${super_token}  use_defaults=${False}

   FOR  ${org}  IN  @{info_true}
      Should Be True  ${org['DeleteInProgress']}
   END

   FOR  ${org}  IN  @{info_false}
      Should Be True  'DeleteInProgress' not in ${org}
   END

   ${num_true}=  Get Length  ${info_true}
   ${num_false}=  Get Length  ${info_false}
   ${num_all}  Get Length  ${info_all}

   Should Be True  ${num_true} + ${num_false} == ${num_all}

*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   ${time}=  Get Time  epoch
   
   ${orgname1}=  Set Variable  org1_${time}
   ${orgname2}=  Set Variable  org2_${time}

   Create Org    orgname=${orgname1}  orgtype=developer  address=${dev_address}  phone=${dev_phone}  token=${super_token}  use_defaults=${False}
   Create Org    orgname=${orgname2}  orgtype=operator   address=${op_address}   phone=${op_phone}   token=${super_token}  use_defaults=${False}

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${orgname1}
   Set Suite Variable  ${orgname2}

Show Org with filter
   [Arguments]  ${orgname_to_check}  ${orgname}=${None}  ${orgtype}=${None}  ${address}=${None}  ${phone}=${None}  ${public_images}=${None}  ${delete_in_progress}=${None}  ${edgebox_only}=${None}

   ${info}=  Show Organizations  org_name=${orgname}  org_type=${orgtype}  address=${address}  phone=${phone}  public_images=${public_images}  delete_in_progress=${delete_in_progress}  edgebox_only=${edgebox_only}  token=${super_token}  use_defaults=${False}

   Convert Date  ${info[0]['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Convert Date  ${info[0]['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   Should Be Equal  ${info[0]['Type']}     developer
   Should Be Equal  ${info[0]['Phone']}    ${dev_phone} 
   Should Be Equal  ${info[0]['Address']}  ${dev_address}
   Should Be Equal  ${info[0]['Name']}     ${orgname_to_check}
