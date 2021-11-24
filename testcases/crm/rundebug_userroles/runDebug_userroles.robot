*** Settings ***

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
#Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  Process
Library  OperatingSystem


Test Setup      Setup
Test Teardown   CleanUp

*** Variables ***

${region}  EU
${username}=  mextester06
${password}=  ${mextester06_gmail_password}
#${password}=  mextester06123
${region}=  EU
${cloudlet_name_openstack_dedicated}  automationParadiseCloudlet
${ntype_shep}=  shepherd
${ntype_crm}=  crm
${triggered_refresh}=  triggered refresh

*** Test Cases ***


#ECQ-2215
RunDebug - developer viewer does not have permission to use command to return device information

    [Documentation]
    ...  RunDebug returns cmd=oscmd request for Admin only
    ...  verify RunDebug does not return device information for developer viewer

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperViewer  token=${user_token}

      ${error}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=refresh-internal-certs  node_type=shepherd 
      Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}')

      ${error2}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=oscmd  args=openstack flavor list  node_type=shepherd
      Should Contain  ${error2}  ('code=403', 'error={"message":"Forbidden"}')


#ECQ-2216
RunDebug - developer manager does not have permission to use command to return device information
    [Documentation]
    ...  RunDebug returns cmd=oscmd request for Admin only
    ...  verify RunDebug does not return device information for developer manager

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager  token=${user_token}

      ${error}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=refresh-internal-certs  node_type=shepherd
      Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}')

      ${error2}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=oscmd  args=openstack flavor list  node_type=shepherd
      Should Contain  ${error2}  ('code=403', 'error={"message":"Forbidden"}')


#ECQ-2217
RunDebug - developer contributor does not have permission to use command to return device information
    [Documentation]
    ...  RunDebug returns cmd=oscmd request for Admin only
    ...  verify RunDebug does not return device information for developer contributor

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperContributor  token=${user_token}

      ${error}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=refresh-internal-certs  node_type=shepherd
      Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}')

      ${error2}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=oscmd  args=openstack flavor list  node_type=shepherd
      Should Contain  ${error2}  ('code=403', 'error={"message":"Forbidden"}')


#ECQ-2218
RunDebug - mexadmin has permission to use command to return device information from orgtype developer
    [Documentation]
    ...  RunDebug returns cmd=oscmd request for Admin only
    ...  verify RunDebug returns cmd=oscmd information for mexadmin on a developer organization

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager  token=${supertoken}

      ${node}=  RunDebug  token=${supertoken}  cloudlet_name=${cloudlet_name_crm}  command=refresh-internal-certs  #node_type=shepherd

      ${type}=  Set Variable  ${node}[0][data][node][type]
      ${type2}=  Set Variable  ${node}[-1][data][node][type]
      ${refresh}=  Set Variable  ${node}[0][data][output]
      ${refresh2}=  Set Variable  ${node}[-1][data][output]

      Should Contain Any  ${type}  ${ntype_shep}  ${ntype_crm}
      Should Contain Any  ${type2}  ${ntype_shep}  ${ntype_crm}
      Should Contain  ${refresh}  ${triggered_refresh}
      Should Contain  ${refresh2}  ${triggered_refresh}

#ECQ-2219
RunDebug - operator viewer does not have permission to use command to return device information
    [Documentation]
    ...  RunDebug returns cmd=oscmd request for Admin only
    ...  verify RunDebug does not return device information for operator viewer

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorViewer  token=${user_token}

      ${error}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=refresh-internal-certs  node_type=shepherd
      Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}')

      ${error2}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=oscmd  args=openstack flavor list  node_type=shepherd
      Should Contain  ${error2}  ('code=403', 'error={"message":"Forbidden"}')


#ECQ-2220
RunDebug - operator manager does not have permission to use command to return device information
    [Documentation]
    ...  RunDebug returns cmd=oscmd request for Admin only
    ...  verify RunDebug does not return device information for operator manager

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${user_token}

      ${error}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=refresh-internal-certs  node_type=shepherd
      Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}')

      ${error2}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=oscmd  args=openstack flavor list  node_type=shepherd
      Should Contain  ${error2}  ('code=403', 'error={"message":"Forbidden"}')


#ECQ-2221
RunDebug - operator contributor does not have permission to use command to return device information
    [Documentation]
    ...  RunDebug returns cmd=oscmd request for Admin only
    ...  verify RunDebug does not return device information for operator contributor

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorContributor  token=${user_token}

      ${error}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=refresh-internal-certs  node_type=shepherd
      Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}')

      ${error2}=  Run Keyword And Expect Error  *  Run Debug  token=${user_token}  cloudlet_name=${cloudlet_name_crm}  command=oscmd  args=openstack flavor list  node_type=shepherd
      Should Contain  ${error2}  ('code=403', 'error={"message":"Forbidden"}')


#ECQ-2222
RunDebug - mexadmin has permission to use command to return device information from orgtype operator
    [Documentation]
    ...  RunDebug returns cmd=oscmd request for Admin only
    ...  verify RunDebug returns cmd=oscmd information for mexadmin on a operator organization

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${supertoken}

      ${node}=  RunDebug  token=${supertoken}  cloudlet_name=${cloudlet_name_crm}  command=refresh-internal-certs  #node_type=shepherd

      ${type}=  Set Variable  ${node}[0][data][node][type]
      ${type2}=  Set Variable  ${node}[-1][data][node][type]
      ${refresh}=  Set Variable  ${node}[0][data][output]
      ${refresh2}=  Set Variable  ${node}[-1][data][output]

      Should Contain Any  ${type}  ${ntype_shep}  ${ntype_crm}
      Should Contain Any  ${type2}  ${ntype_shep}  ${ntype_crm}
      Should Contain  ${refresh}  ${triggered_refresh}
      Should Contain  ${refresh2}  ${triggered_refresh}


*** Keywords ***

CleanUp

#   MexController.Cleanup Provisioning
   MexMasterController.Cleanup Provisioning

Setup

   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${supertoken}=  Get Super Token

#  No longer need to verify email to create user accounts EDC-2163 has been added using Skip Verify Config
   Skip Verify Email  token=${supertoken}
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
#   Verify Email  email_address=${emailepoch}
   Unlock User
   ${user_token}=  Login  username=${epochusername}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
#   Verify Email  email_address=${emailepoch2}
   Unlock User
   ${user_token2}=  Login  username=${epochusername2}  password=${password}


   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}

Find Device
   [Arguments]  ${device}  ${id}  ${type}

   ${fd}=  Set Variable  ${None}
   FOR  ${d}  IN  @{device}
   #   log to console  ${d['data']['key']['unique_id']} ${id}
      ${fd}=  Run Keyword If  '${d['data']['key']['unique_id']}' == '${id}' and '${d['data']['key']['unique_id_type']}' == '${type}'  Set Variable  ${d}
      ...  ELSE  Set Variable  ${fd}
   #   Run Keyword If  '${d['data']['key']['unique_id']}' == '${id}' and '${d['data']['key']['unique_id_type']}' == '${type}'    [Return]  ${d}
   #   log to console  ${fd}
   END

   [Return]  ${fd}


Should Be Larger Than
    [Arguments]    ${value_1}    ${value_2}
    Run Keyword If    ${value_1} <= ${value_2}
    ...    Fail    The value ${value_1} is not larger than ${value_2}
