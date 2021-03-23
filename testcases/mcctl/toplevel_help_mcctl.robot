*** Settings ***
Documentation  mcctl help

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${version}=  latest

*** Test Cases ***
# ECQ-3293
mcctl shall show toplevel help
   [Documentation]
   ...  - send mcctl without parms and with help arg
   ...  - verify help is shown

   ${show}=  Run mcctl  parms=${Empty}  version=${version}  output_format=${None}
   Should Contain  ${show}  User and Organization Commands\n  login                     Login using account credentials
   Should Contain  ${show}  Operator Commands\n  cloudlet                  Manage Cloudlets
   Should Contain  ${show}  Developer Commands\n  cloudletshow              View cloudlets
   Should Not Contain  ${show}  Admin-Only Commands  # this wont show when using docker since it need the .mcctl_admin file
   Should Contain  ${show}  Logs and Metrics Commands\n  metrics                   View metrics
   Should Contain  ${show}  Other Commands\n  version                   Version of mcctl cli utility

   ${show2}=  Run mcctl  parms=-h  version=${version}  output_format=${None}
   Should Contain  ${show2}  User and Organization Commands\n  login                     Login using account credentials
   Should Contain  ${show2}  Operator Commands\n  cloudlet                  Manage Cloudlets
   Should Contain  ${show2}  Developer Commands\n  cloudletshow              View cloudlets
   Should Not Contain  ${show2}  Admin-Only Commands  # this wont show when using docker since it need the .mcctl_admin file
   Should Contain  ${show2}  Logs and Metrics Commands\n  metrics                   View metrics
   Should Contain  ${show2}  Other Commands\n  version                   Version of mcctl cli utility

   ${show3}=  Run mcctl  parms=--help  version=${version}  output_format=${None}
   Should Contain  ${show3}  User and Organization Commands\n  login                     Login using account credentials
   Should Contain  ${show3}  Operator Commands\n  cloudlet                  Manage Cloudlets
   Should Contain  ${show3}  Developer Commands\n  cloudletshow              View cloudlets
   Should Not Contain  ${show3}  Admin-Only Commands  # this wont show when using docker since it need the .mcctl_admin file
   Should Contain  ${show3}  Logs and Metrics Commands\n  metrics                   View metrics
   Should Contain  ${show3}  Other Commands\n  version                   Version of mcctl cli utility

*** Keywords ***
Setup
   ${recv_name}=  Get Default Autoscale Policy Name
   Set Suite Variable  ${recv_name}

