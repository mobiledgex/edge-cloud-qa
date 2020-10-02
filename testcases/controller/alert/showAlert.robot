*** Settings ***
Documentation  ShowAlert

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  EU

*** Test Cases ***
ShowAlert - shall be able to show alerts
   [Documentation]
   ...  - send ShowAlert
   ...  - verify all alert fields are given

   ${alerts}=  Show Alerts  region=EU 

   ${len}=  Get Length  ${alerts}

   # only verify alerts if there are any
   Run Keyword If  ${len} > 0  Verify Alerts  ${alerts}

*** Keywords ***
Verify Alerts
   [Arguments]  ${alerts}
   
   FOR  ${a}  IN  @{alerts}
      log to console  XXXX 
      Should Be True  ${a['data']['active_at']['nanos']} > 0
      Should Be True  ${a['data']['active_at']['seconds']} > 0
      Should Contain  ${a['data']['controller']}  controller
      Should Be Equal  ${a['data']['labels']['alertname']}  AppInstDown
      Should Be True  len('${a['data']['labels']['app']}') > 0 
      Should Be True  len('${a['data']['labels']['apporg']}') > 0
      Should Be True  len('${a['data']['labels']['appver']}') > 0
      Should Be True  len('${a['data']['labels']['cloudlet']}') > 0
      Should Be True  len('${a['data']['labels']['cloudletorg']}') > 0
      Should Be True  len('${a['data']['labels']['cluster']}') > 0
      Should Be True  len('${a['data']['labels']['clusterorg']}') > 0
      Should Be True  len('${a['data']['labels']['envoy_cluster_name']}') > 0
      Should Be True  len('${a['data']['labels']['instance']}') > 0
      Should Be True  len('${a['data']['labels']['job']}') > 0
      Should Be Equal  ${a['data']['labels']['region']}  ${region}
      Should Be Equal  ${a['data']['labels']['status']}  2 
      Should Be True  ${a['data']['notify_id']} > 0 
      Should Be Equal  ${a['data']['state']}  firing

   END
