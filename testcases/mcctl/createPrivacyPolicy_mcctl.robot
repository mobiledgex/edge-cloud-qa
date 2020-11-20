*** Settings ***
Documentation  CreatePrivacyPolicy mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  2m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

*** Test Cases ***
# ECQ-2827
CreatePrivacyPolicy - mcctl shall be able to create/show/delete policy
   [Documentation]
   ...  - send CreatePrivacyPolicy/ShowPrivacyPolicy/DeletePrivacyPolicy via mcctl with various parms
   ...  - verify policy is created/shown/deleted

   [Template]  Success Create/Show/Delete Privacy Policy Via mcctl
      # no protocol 
      name=${recv_name}  cluster-org=${developer}

      # icmp
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.1.1.1/1

      # tcp
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=tcp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=tcp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      # udp
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=udp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      # icmp/tcp/udp
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:1.protocol=tcp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

# ECQ-2828
CreatePrivacyPolicy - mcctl shall handle create failures
   [Documentation]
   ...  - send CreatePrivacyPolicy via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Privacy Policy Via mcctl
      # missing values
      Error: missing required args: cluster-org name  Error: missing required args: name cluster-org  #not sending any args with mcctl  

      Error: missing required args: name  cluster-org=${developer}  outboundsecurityrules:0.protocol=icmp
      Error: missing required args: cluster-org  name=${recv_name}  outboundsecurityrules:0.protocol=icmp
      Error: missing required args: cluster-org name  Error: missing required args: name cluster-org  outboundsecurityrules:0.protocol=icmp
      Error: Bad Request (400), Port range must be empty for icmp  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1

      Error: missing required args: name  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp
      Error: missing required args: cluster-org  name=${recv_name}  outboundsecurityrules:0.protocol=tcp
      Error: missing required args: cluster-org name  Error: missing required args: name cluster-org  outboundsecurityrules:0.protocol=tcp
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:1.portrangemin=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemax=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2

      Error: missing required args: name  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp
      Error: missing required args: cluster-org  name=${recv_name}  outboundsecurityrules:0.protocol=udp
      Error: missing required args: cluster-org name  Error: missing required args: name cluster-org  outboundsecurityrules:0.protocol=udp
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:1.portrangemin=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemax=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=1
      Bad Request (400), Invalid CIDR address:      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2

      # invalid values
      Error: Bad Request (400), Invalid CIDR address: 1.11.1/1  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.11.1/1

      Unable to parse "outboundsecurityrules[0].portrangemin" value "x" as uint  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=x  outboundsecurityrules:0.portrangemax=2
      Unable to parse "outboundsecurityrules[0].portrangemax" value "x" as uint  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=x
      Error: Bad Request (400), Invalid min port range: 999999  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=999999  outboundsecurityrules:0.portrangemax=1
      Error: Bad Request (400), Invalid max port range: 99999  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=99999
      Bad Request (400), Invalid CIDR address: 1.1.1.1  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.remotecidr=1.11.1/1

      Unable to parse "outboundsecurityrules[0].portrangemin" value "x" as uint  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=x  outboundsecurityrules:0.portrangemax=2
      Unable to parse "outboundsecurityrules[0].portrangemax" value "x" as uint  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=x
      Error: Bad Request (400), Invalid min port range: 999999  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=999999  outboundsecurityrules:0.portrangemax=1
      Error: Bad Request (400), Invalid max port range: 99999  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=99999
      Bad Request (400), Invalid CIDR address: 1.1.1.1  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1
      Bad Request (400), Invalid min port range: 0  name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.remotecidr=1.11.1/1

# ECQ-2829
UpdatePrivacyPolicy - mcctl shall handle update policy
   [Documentation]
   ...  - send UpdatePrivacyPolicy via mcctl with various args
   ...  - verify proper is updated

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success Update/Show Privacy Policy Via mcctl
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=tcp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=tcp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=tcp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      # udp
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:0.portrangemax=2  outboundsecurityrules:0.remotecidr=1.1.1.1/1
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=udp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:0.portrangemin=1  outboundsecurityrules:1.protocol=udp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

      # icmp/tcp/udp
      name=${recv_name}  cluster-org=${developer}  outboundsecurityrules:0.protocol=icmp  outboundsecurityrules:0.remotecidr=1.1.1.1/1  outboundsecurityrules:1.protocol=tcp  outboundsecurityrules:1.portrangemin=1  outboundsecurityrules:1.remotecidr=1.1.1.1/1  outboundsecurityrules:2.protocol=udp  outboundsecurityrules:2.portrangemin=1  outboundsecurityrules:2.portrangemax=2  outboundsecurityrules:2.remotecidr=1.1.1.1/1

*** Keywords ***
Setup
   ${recv_name}=  Get Default Privacy Policy Name
   Set Suite Variable  ${recv_name}

Success Create/Show/Delete Privacy Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  region CreatePrivacyPolicy region=${region} ${parmss} 
   ${show}=  Run mcctl  region ShowPrivacyPolicy region=${region} ${parmss}
   Run mcctl  region DeletePrivacyPolicy region=${region} ${parmss}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']} 
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['cluster-org']}

   Run Keyword If  'outboundsecurityrules:0.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][0]['protocol']}  ${parms['outboundsecurityrules:0.protocol']}
   Run Keyword If  'outboundsecurityrules:0.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][0]['remote_cidr']}  ${parms['outboundsecurityrules:0.remotecidr']}
   Run Keyword If  'outboundsecurityrules:0.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_min']}  ${parms['outboundsecurityrules:0.portrangemin']}
   Run Keyword If  'outboundsecurityrules:0.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_max']}  ${parms['outboundsecurityrules:0.portrangemax']}

   Run Keyword If  'outboundsecurityrules:1.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][1]['protocol']}  ${parms['outboundsecurityrules:1.protocol']}
   Run Keyword If  'outboundsecurityrules:1.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][1]['remote_cidr']}  ${parms['outboundsecurityrules:1.remotecidr']}
   Run Keyword If  'outboundsecurityrules:1.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_min']}  ${parms['outboundsecurityrules:1.portrangemin']}
   Run Keyword If  'outboundsecurityrules:1.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_max']}  ${parms['outboundsecurityrules:1.portrangemax']}

   Run Keyword If  'outboundsecurityrules:2.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][2]['protocol']}  ${parms['outboundsecurityrules:2.protocol']}
   Run Keyword If  'outboundsecurityrules:2.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][2]['remote_cidr']}  ${parms['outboundsecurityrules:2.remotecidr']}
   Run Keyword If  'outboundsecurityrules:2.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_min']}  ${parms['outboundsecurityrules:2.portrangemin']}
   Run Keyword If  'outboundsecurityrules:2.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_max']}  ${parms['outboundsecurityrules:2.portrangemax']}

Update Setup
   Run mcctl  region CreatePrivacyPolicy region=${region} name=${recv_name} cluster-org=${developer}

Update Teardown
   Run mcctl  region DeletePrivacyPolicy region=${region} name=${recv_name} cluster-org=${developer}

Success Update/Show Privacy Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  region UpdatePrivacyPolicy region=${region} ${parmss}
   ${show}=  Run mcctl  region ShowPrivacyPolicy region=${region} ${parmss}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['cluster-org']}

   Run Keyword If  'outboundsecurityrules:0.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][0]['protocol']}  ${parms['outboundsecurityrules:0.protocol']}
   Run Keyword If  'outboundsecurityrules:0.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][0]['remote_cidr']}  ${parms['outboundsecurityrules:0.remotecidr']}
   Run Keyword If  'outboundsecurityrules:0.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_min']}  ${parms['outboundsecurityrules:0.portrangemin']}
   Run Keyword If  'outboundsecurityrules:0.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][0]['port_range_max']}  ${parms['outboundsecurityrules:0.portrangemax']}

   Run Keyword If  'outboundsecurityrules:1.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][1]['protocol']}  ${parms['outboundsecurityrules:1.protocol']}
   Run Keyword If  'outboundsecurityrules:1.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][1]['remote_cidr']}  ${parms['outboundsecurityrules:1.remotecidr']}
   Run Keyword If  'outboundsecurityrules:1.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_min']}  ${parms['outboundsecurityrules:1.portrangemin']}
   Run Keyword If  'outboundsecurityrules:1.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][1]['port_range_max']}  ${parms['outboundsecurityrules:1.portrangemax']}

   Run Keyword If  'outboundsecurityrules:2.protocol' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][2]['protocol']}  ${parms['outboundsecurityrules:2.protocol']}
   Run Keyword If  'outboundsecurityrules:2.remotecidr' in ${parms}  Should Be Equal  ${show[0]['outbound_security_rules'][2]['remote_cidr']}  ${parms['outboundsecurityrules:2.remotecidr']}
   Run Keyword If  'outboundsecurityrules:2.portrangemin' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_min']}  ${parms['outboundsecurityrules:2.portrangemin']}
   Run Keyword If  'outboundsecurityrules:2.portrangemax' in ${parms}  Should Be Equal As Integers  ${show[0]['outbound_security_rules'][2]['port_range_max']}  ${parms['outboundsecurityrules:2.portrangemax']}

Fail Create Privacy Policy Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  region CreatePrivacyPolicy region=${region} ${parmss}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
