*** Settings ***
Documentation  CreateTrustPolicyException mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Teardown

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${operator}=   packet
${version}=  latest
${appvers}=  1.0

*** Test Cases ***
# ECQ-4110
CreateTrustPolicyException - mcctl shall be able to create/show/delete policy exception
   [Documentation]
   ...  - send CreateTrustPolicyException/ShowTrustPolicyException/DeleteTrustPolicyException via mcctl with various parms
   ...  - verify policy is created/shown/deleted

   [Tags]  TrustPolicyException

   [Template]  Success Create/Show/Delete Trust Policy Via mcctl
      # no protocol - no longer supported 
      #name=${recv_name}

      # icmp
      name=${recv_name}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=ICMP  outboundsecurityrules:0.remotecidr=1.1.1.1/1

      # tcp
      name=${recv_name}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=tcp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=tcp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=TCP  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=tCp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=tcP  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      # udp
      name=${recv_name}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=udp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=UDP  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=uDp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udP  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      # icmp/tcp/udp
      name=${recv_name}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:1.protocol=tcp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=ICMP  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:1.protocol=TCP  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=UDP  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

# ECQ-4111
CreateTrustPolicyException - mcctl shall handle create exception failures
   [Documentation]
   ...  - send CreateTrustPolicyException via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  TrustPolicyException

   [Template]  Fail Create Trust Policy Via mcctl
      # missing values
      Error: missing required args:   #not sending any args with mcctl  

      Error: missing required args:  apporg=${operator}  outboundsecurityrules:0.protocol=icmp
      Error: missing required args:  appname=x  apporg=${operator}  outboundsecurityrules:0.protocol=icmp
      Error: missing required args:  appname=x  appvers=x  apporg=${operator}  outboundsecurityrules:0.protocol=icmp
      Error: missing required args:       appname=x  appvers=x  apporg=${operator}  cloudletpoolorg=${operator}  outboundsecurityrules:0.protocol=icmp
      Error: missing required args: name  appname=x  appvers=x  apporg=${operator}  cloudletpoolname=y  cloudletpoolorg=${operator}  outboundsecurityrules:0.protocol=icmp
      Error: Bad Request (400), Port range must be empty for ICMP  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1

      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp
      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:1.portrangemin=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1
      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemax=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2

      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp
      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:1.portrangemin=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1
      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemax=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2

      # invalid values
      Error: Bad Request (400), Invalid CIDR address: 1.11.1/1  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.11.1/1

      Error: parsing arg "outboundsecurityrules:0.portrangemin\=x" failed: unable to parse "x" as uint  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=x  outboundsecurityrules:0.portrangemax=2
      Error: parsing arg "outboundsecurityrules:0.portrangemax\=x" failed: unable to parse "x" as uint  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=x
      Error: Bad Request (400), Invalid min port: 999999  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=999999  outboundsecurityrules:0.portrangemax=1
      Error: Bad Request (400), Invalid max port: 99999  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=99999
      Bad Request (400), Invalid CIDR address: 1.1.1.1  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1
      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.remotecidr=1.11.1/1

      Error: parsing arg "outboundsecurityrules:0.portrangemin\=x" failed: unable to parse "x" as uint  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=x  outboundsecurityrules:0.portrangemax=2
      Error: parsing arg "outboundsecurityrules:0.portrangemax\=x" failed: unable to parse "x" as uint  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=x
      Error: Bad Request (400), Invalid min port: 999999  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=999999  outboundsecurityrules:0.portrangemax=1
      Error: Bad Request (400), Invalid max port: 99999  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=99999
      Bad Request (400), Invalid CIDR address: 1.1.1.1  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1
      Bad Request (400), Invalid min port: 0  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.remotecidr=1.11.1/1

      Bad Request (400), Protocol must be one of: (TCP,UDP,ICMP)  name=${recv_name}  appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  outboundsecurityrules:0.protocol=x  outboundsecurityrules:0.remotecidr=1.11.1/1

# ECQ-4112
UpdateTrustPolicyException - mcctl shall handle update exception
   [Documentation]
   ...  - send UpdateTrustPolicyException via mcctl with various args
   ...  - verify policy is updated

   [Tags]  TrustPolicyException

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success Update/Show Trust Policy Via mcctl
      name=${recv_name}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=tcp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=tcp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      # udp
      name=${recv_name}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=udp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      # icmp/tcp/udp
      name=${recv_name}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:1.protocol=tcp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      name=${recv_name}  state=Active             outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  state=Rejected

# ECQ-4271
CreatePolicyException - mcctl help shall show
   [Documentation]
   ...  - send TrustPolicyException via mcctl with help for each command
   ...  - verify help is returned

   [Tags]  TrustPolicyException

   [Template]  Show Help
   ${Empty}
   create
   update
   delete
   show

*** Keywords ***
Setup
   ${recv_name}=  Get Default Trust Policy Name
   Set Suite Variable  ${recv_name}

   ${pool_name}=  Get Default Cloudlet Pool Name
   Set Suite Variable  ${pool_name}

   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   Run mcctl  cloudletpool create region=${region} org=${operator_name_fake} name=${pool_name}  version=${version}  token=${token}
  
Teardown
   Run mcctl  cloudletpool delete region=${region} org=${operator_name_fake} name=${pool_name}  version=${version}  token=${token}
 
Success Create/Show/Delete Trust Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  trustpolicyexception create region=${region} ${parmss} appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  version=${version}
   ${show}=  Run mcctl  trustpolicyexception show region=${region} ${parmss}  version=${version}
   Run mcctl  trustpolicyexception delete region=${region} ${parmss} appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']} 
   Should Be Equal  ${show[0]['key']['cloudlet_pool_key']['organization']}  ${operator_name_fake}
   Should Be Equal  ${show[0]['key']['cloudlet_pool_key']['name']}  ${pool_name}
   Should Be Equal  ${show[0]['key']['app_key']['organization']}  ${developer_org_name_automation}
   Should Be Equal  ${show[0]['key']['app_key']['name']}  ${app_name_automation_trusted}
   Should Be Equal  ${show[0]['key']['app_key']['version']}  ${appvers}

   Should Be Equal  ${show[0]['state']}  ApprovalRequested

   IF  'outboundsecurityrules:0.protocol' in ${parms}
      ${protocol_upper0}=  Convert To Uppercase  ${parms['outboundsecurityrules:0.protocol']}
      Should Be Equal  ${show[0]['outbound_security_rules'][0]['protocol']}  ${protocol_upper0}
      Should Be Equal  ${show[0]['outbound_security_rules'][0]['remote_cidr']}  ${parms['outboundsecurityrules:0.remotecidr']}
      Run Keyword If  'outboundsecurityrules:0.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_min']}  ${parms['outboundsecurityrules:0.portrangemin']}
      Run Keyword If  'outboundsecurityrules:0.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_max']}  ${parms['outboundsecurityrules:0.portrangemax']}
   END
   #Run Keyword If  'outboundsecurityrules:0.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][0]['remote_cidr']}  ${parms['outboundsecurityrules:0.remotecidr']}
   #Run Keyword If  'outboundsecurityrules:0.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_min']}  ${parms['outboundsecurityrules:0.portrangemin']}
   #Run Keyword If  'outboundsecurityrules:0.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_max']}  ${parms['outboundsecurityrules:0.portrangemax']}

   IF  'outboundsecurityrules:1.protocol' in ${parms}
      ${protocol_upper1}=  Convert To Uppercase  ${parms['outboundsecurityrules:1.protocol']}
      Should Be Equal  ${show[0]['outbound_security_rules'][1]['protocol']}  ${protocol_upper1}
      Should Be Equal  ${show[0]['outbound_security_rules'][1]['remote_cidr']}  ${parms['outboundsecurityrules:1.remotecidr']}
      Run Keyword If  'outboundsecurityrules:1.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_min']}  ${parms['outboundsecurityrules:1.portrangemin']}
      Run Keyword If  'outboundsecurityrules:1.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_max']}  ${parms['outboundsecurityrules:1.portrangemax']}
   END
   #Run Keyword If  'outboundsecurityrules:1.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][1]['protocol']}  ${protocol_upper1}
   #Run Keyword If  'outboundsecurityrules:1.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][1]['remote_cidr']}  ${parms['outboundsecurityrules:1.remotecidr']}
   #Run Keyword If  'outboundsecurityrules:1.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_min']}  ${parms['outboundsecurityrules:1.portrangemin']}
   #Run Keyword If  'outboundsecurityrules:1.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_max']}  ${parms['outboundsecurityrules:1.portrangemax']}

   IF  'outboundsecurityrules:2.protocol' in ${parms}
      ${protocol_upper2}=  Convert To Uppercase  ${parms['outboundsecurityrules:2.protocol']}
      Should Be Equal  ${show[0]['outbound_security_rules'][2]['protocol']}  ${protocol_upper2}
      Should Be Equal  ${show[0]['outbound_security_rules'][2]['remote_cidr']}  ${parms['outboundsecurityrules:2.remotecidr']}
      Run Keyword If  'outboundsecurityrules:2.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_min']}  ${parms['outboundsecurityrules:2.portrangemin']}
      Run Keyword If  'outboundsecurityrules:2.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_max']}  ${parms['outboundsecurityrules:2.portrangemax']}
   END

Update Setup
   Setup
   Run mcctl  trustpolicyexception create region=${region} name=${recv_name} appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake} outboundsecurityrules:0.protocol=tcp outboundsecurityrules:0.portrangemin=1 outboundsecurityrules:0.remotecidr=1.1.1.1/1  version=${version}

Update Teardown
   Run mcctl  trustpolicyexception delete region=${region} name=${recv_name} appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}   version=${version}
   Teardown

Success Update/Show Trust Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  trustpolicyexception update region=${region} ${parmss} appname=${app_name_automation_trusted} appvers=${appvers} apporg=${developer_org_name_automation} cloudletpoolname=${pool_name} cloudletpoolorg=${operator_name_fake}   version=${version}
   ${show}=  Run mcctl  trustpolicyexception show region=${region} ${parmss}    version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal  ${show[0]['key']['cloudlet_pool_key']['organization']}  ${operator_name_fake}
   Should Be Equal  ${show[0]['key']['cloudlet_pool_key']['name']}  ${pool_name}
   Should Be Equal  ${show[0]['key']['app_key']['organization']}  ${developer_org_name_automation}
   Should Be Equal  ${show[0]['key']['app_key']['name']}  ${app_name_automation_trusted}
   Should Be Equal  ${show[0]['key']['app_key']['version']}  ${appvers}

   IF  'state' in ${parms}
      Should Be Equal  ${show[0]['state']}  ${parms['state']}
   ELSE
      Should Be Equal  ${show[0]['state']}  ApprovalRequested
   END

   IF  'outboundsecurityrules:empty' in ${parms}
       Should Be Equal  ${show[0]['outbound_security_rules']}  ${None}
   ELSE
      IF  'outboundsecurityrules:0.protocol' in ${parms}
         ${protocol_upper0}=  Convert To Uppercase  ${parms['outboundsecurityrules:0.protocol']}
         Should Be Equal  ${show[0]['outbound_security_rules'][0]['protocol']}  ${protocol_upper0}
         Should Be Equal  ${show[0]['outbound_security_rules'][0]['remote_cidr']}  ${parms['outboundsecurityrules:0.remotecidr']}
         Run Keyword If  'outboundsecurityrules:0.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_min']}  ${parms['outboundsecurityrules:0.portrangemin']}
         Run Keyword If  'outboundsecurityrules:0.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_max']}  ${parms['outboundsecurityrules:0.portrangemax']}
      END

      IF  'outboundsecurityrules:1.protocol' in ${parms}
         ${protocol_upper1}=  Convert To Uppercase  ${parms['outboundsecurityrules:1.protocol']}
         Should Be Equal  ${show[0]['outbound_security_rules'][1]['protocol']}  ${protocol_upper1}
         Should Be Equal  ${show[0]['outbound_security_rules'][1]['remote_cidr']}  ${parms['outboundsecurityrules:1.remotecidr']}
         Run Keyword If  'outboundsecurityrules:1.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_min']}  ${parms['outboundsecurityrules:1.portrangemin']}
         Run Keyword If  'outboundsecurityrules:1.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_max']}  ${parms['outboundsecurityrules:1.portrangemax']}
      END

      IF  'outboundsecurityrules:2.protocol' in ${parms}
         ${protocol_upper2}=  Convert To Uppercase  ${parms['outboundsecurityrules:2.protocol']}
         Should Be Equal  ${show[0]['outbound_security_rules'][2]['protocol']}  ${protocol_upper2}
         Should Be Equal  ${show[0]['outbound_security_rules'][2]['remote_cidr']}  ${parms['outboundsecurityrules:2.remotecidr']}
         Run Keyword If  'outboundsecurityrules:2.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_min']}  ${parms['outboundsecurityrules:2.portrangemin']}
         Run Keyword If  'outboundsecurityrules:2.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_max']}  ${parms['outboundsecurityrules:2.portrangemax']}
      END

#      Run Keyword If  'outboundsecurityrules:0.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][0]['protocol']}  ${parms['outboundsecurityrules:0.protocol']}
#      Run Keyword If  'outboundsecurityrules:0.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][0]['remote_cidr']}  ${parms['outboundsecurityrules:0.remotecidr']}
#      Run Keyword If  'outboundsecurityrules:0.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_min']}  ${parms['outboundsecurityrules:0.portrangemin']}
#      Run Keyword If  'outboundsecurityrules:0.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_max']}  ${parms['outboundsecurityrules:0.portrangemax']}
#
#      Run Keyword If  'outboundsecurityrules:1.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][1]['protocol']}  ${parms['outboundsecurityrules:1.protocol']}
#      Run Keyword If  'outboundsecurityrules:1.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][1]['remote_cidr']}  ${parms['outboundsecurityrules:1.remotecidr']}
#      Run Keyword If  'outboundsecurityrules:1.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_min']}  ${parms['outboundsecurityrules:1.portrangemin']}
#      Run Keyword If  'outboundsecurityrules:1.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_max']}  ${parms['outboundsecurityrules:1.portrangemax']}
#
#      Run Keyword If  'outboundsecurityrules:2.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][2]['protocol']}  ${parms['outboundsecurityrules:2.protocol']}
#      Run Keyword If  'outboundsecurityrules:2.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][2]['remote_cidr']}  ${parms['outboundsecurityrules:2.remotecidr']}
#      Run Keyword If  'outboundsecurityrules:2.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_min']}  ${parms['outboundsecurityrules:2.portrangemin']}
#      Run Keyword If  'outboundsecurityrules:2.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_max']}  ${parms['outboundsecurityrules:2.portrangemax']}
   END

Fail Create Trust Policy Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  trustpolicyexception create region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Show Help
   [Arguments]  ${parms}

   ${error}=  Run Keyword and Expect Error  *  Run mcctl  trustpolicyexception ${parms} -h  version=${version}

   ${cmd}=  Run Keyword If  '${parms}' == '${Empty}'  Set Variable  ${Empty}  ELSE  Set Variable  ${parms}
   Should Contain  ${error}  Usage: mcctl trustpolicyexception ${cmd}
