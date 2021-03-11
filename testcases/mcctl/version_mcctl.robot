*** Settings ***
Documentation  version mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Timeout  5m

*** Variables ***
${version}=  latest

*** Test Cases ***
# ECQ-3142
Version - mcctl shall be able to show the version
   [Documentation]
   ...  - send version via mcctl
   ...  - verify version returned

   ${version}=  Run mcctl  version  version=${version}

   ${version_info}=  Split To Lines  ${version}

   #Should Match Regexp  ${version_info[0]}  buildmaster: v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
   Should Match Regexp  ${version_info[0]}  buildmaster: v\\d{1,3}\\b

   Should Match Regexp  ${version_info[1]}  buildhead: v\\d{1,3}\\b
   Should Match Regexp  ${version_info[2]}  builddate: .+    

