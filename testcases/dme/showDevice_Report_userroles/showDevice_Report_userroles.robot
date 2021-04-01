*** Settings ***

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
#Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  DateTime

Test Setup      Setup
Test Teardown   CleanUp

*** Variables ***
${platos_app_name}  platosEnablingLayer
${platos_developer_name}  platos
${platos_cloudlet_name}  default
${platos_operator_name}  developer
${platos_uri}  automation.platos.com
${platos_unique_id}  12345
${platos_unique_id_type}  abcde
${platos_begin_seconds}  124
${platos_end_seconds}  1234
${platos_begin_nanos}  1234
${platos_end_nanos}  1234
${platos_notify_id}  1234
${region}  US
${username}=  mextester06


*** Test Cases ***

#ECQ-2141
showDevice - developer viewer does not have permission to use command to return device information

    [Documentation]
    ...  showDevice returns uuid for Admin only
    ...  verify showDevice does not return uuid device information for developer viewer


      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer
      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperViewer  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}
      #${pool_return}=        Show Device  region=US  token=${user_token2}


      #${devicelength}=  Get length  ${pool_return}
      #Should Be Equal As Integers  ${devicelength}  0

#ECQ-2142
showDeviceReport - developer viewer does not have permission to use command to return device information

    [Documentation]
    ...  showDeviceReport returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for developer viewer

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer
      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperViewer  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device Report  region=US  token=${user_token2}
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2143
showDevice - developer manager does not have permission to use command to return device information
    [Documentation]
    ...  showDevice returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for developer manager

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer
      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2144
showDeviceReport - developer manager does not have permission to use command to return device information
    [Documentation]
    ...  showDeviceReport returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for developer manager

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer
      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device Report  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2145
showDevice - developer contributor does not have permission to use command to return device information
    [Documentation]
    ...  showDevice returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for developer contributor

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer
      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}   region=${region}  token=${supertoken}


      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperContributor  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2146
showDeviceReport - developer contributor does not have permission to use command to return device information
    [Documentation]
    ...  showDeviceReport returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for developer contributor

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer
      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperContributor  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device Report  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2147
showDevice - mexadmin has permission to use command to return device information from orgtype developer
    [Documentation]
    ...  showDevice returns uuid information for mexadmin user
    ...  verify showDevice returns uuid device information for mexadmin on a developer organization

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer
      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager  token=${supertoken}

      ${pool_return}=        Show Device  region=US  token=${supertoken}

      ${value_1}=  Get length  ${pool_return}
      ${value_2}=  Set Variable  1

      Should Be Larger Than  ${value_1}  ${value_2}

#ECQ-2148
showDeviceReport - mexadmin has permission to use command to return device information from orgtype developer
    [Documentation]
    ...  showDeviceReport returns uuid information for mexadmin user
    ...  verify showDeviceReport returns uuid device information for mexadmin on a developer organization

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=developer
      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager  token=${supertoken}

      ${pool_return}=        Show Device Report  region=US  token=${supertoken}

      ${value_1}=  Get length  ${pool_return}
      ${value_2}=  Set Variable  1

      Should Be Larger Than  ${value_1}  ${value_2}

#ECQ-2149
showDevice - operator viewer does not have permission to use command to return device information

    [Documentation]
    ...  showDevice returns uuid for Admin only
    ...  verify showDevice does not return uuid device information for operator viewer


      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator
      #MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      #MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      #Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorViewer  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2150
showDeviceReport - operator viewer does not have permission to use command to return device information

    [Documentation]
    ...  showDeviceReport returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for operator viewer

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator
      #MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      #MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      #Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorViewer  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device Report  region=US  token=${user_token2}
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2151
showDevice - operator manager does not have permission to use command to return device information
    [Documentation]
    ...  showDevice returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for operator manager

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator
      #MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      #MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      #Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2152
showDeviceReport - operator manager does not have permission to use command to return device information
    [Documentation]
    ...  showDeviceReport returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for operator manager

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator
      #MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      #MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      #Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device Report  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0


#ECQ-2153
showDevice - operator contributor does not have permission to use command to return device information
    [Documentation]
    ...  showDevice returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for operator contributor

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator
      #MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      #MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      #Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorContributor  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

#ECQ-2154
showDeviceReport - operator contributor does not have permission to use command to return device information
    [Documentation]
    ...  showDeviceReport returns uuid for Admin only
    ...  verify showDeviceReport does not return uuid device information for operator contributor

      ${supertoken}=  Get Super Token
      ${timestamp}=  Get Time  epoch

      ${orgname}=  Create Org  token=${user_token}  orgtype=operator
      #MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
      #MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}


      #Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd

      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorContributor  token=${user_token}

      Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Device  region=US  token=${user_token2}

#      ${pool_return}=        Show Device Report  region=US  token=${user_token2}
#
#
#      ${devicelength}=  Get length  ${pool_return}
#      Should Be Equal As Integers  ${devicelength}  0

# no longer support CreateApp with operator org
#ECQ-2155
#showDevice - mexadmin has permission to use command to return device information from orgtype operator
#    [Documentation]
#    ...  showDevice returns uuid information
#    ...  verify showDeviceReport returns uuid device information for mexadmin on a operator organization
#
#      ${supertoken}=  Get Super Token
#      ${timestamp}=  Get Time  epoch
#
#      ${orgname}=  Create Org  token=${user_token}  orgtype=operator
#      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
#      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}
#
#
#      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd
#
#      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${supertoken}
#
#      ${pool_return}=        Show Device  region=US  token=${supertoken}
#
#      ${value_1}=  Get length  ${pool_return}
#      ${value_2}=  Set Variable  1
#
#      Should Be Larger Than  ${value_1}  ${value_2}
#
##ECQ-2156
#showDeviceReport - mexadmin has permission to use command to return device information from orgtype operator
#    [Documentation]
#    ...  showDeviceReport returns uuid information
#    ...  verify showDeviceReport returns uuid device information for mexadmin on a operator organization
#
#      ${supertoken}=  Get Super Token
#      ${timestamp}=  Get Time  epoch
#
#      ${orgname}=  Create Org  token=${user_token}  orgtype=operator
#      MexMasterController.Create Flavor  flavor_name=flavor${timestamp}  region=${region}  token=${supertoken}
#      MexMasterController.Create App  default_flavor_name=flavor${timestamp}  developer_org_name=${orgname}  region=${region}  token=${supertoken}
#
#
#      Register Client  developer_org_name=${orgname}  #app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=abcd
#
#      Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${supertoken}
#      ${pool_return}=        Show Device Report  region=US  token=${supertoken}
#
#      ${value_1}=  Get length  ${pool_return}
#      ${value_2}=  Set Variable  1
#
#      Should Be Larger Than  ${value_1}  ${value_2}

*** Keywords ***

CleanUp

#   MexController.Cleanup Provisioning
   MexMasterController.Cleanup Provisioning

Setup
   ${epoch}=  Get Current Date  result_format=epoch
   #${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2
   ${epochpassword}=  Catenate  SEPARATOR=  ${username}  ${epoch} 
   ${supertoken}=  Get Super Token

   Skip Verify Email  token=${supertoken}
   Create User  username=${epochusername}   password=${epochpassword}   email_address=${emailepoch}
#   Verify Email  email_address=${emailepoch}
   Unlock User
   ${user_token}=  Login  username=${epochusername}  password=${epochpassword}

   Create User  username=${epochusername2}   password=${epochpassword}   email_address=${emailepoch2}
#   Verify Email  email_address=${emailepoch2}
   Unlock User
   ${user_token2}=  Login  username=${epochusername2}  password=${epochpassword}

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
