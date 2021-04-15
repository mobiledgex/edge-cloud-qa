*** Settings ***
Documentation   CreateAppInst port range fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
AppInst - create with udp port range on k8s shared shall return error
   [Documentation]
   ...  create an app with upd port range
   ...  create app inst 
   ...  verify proper error is returned

   Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessShared  deployment=kubernetes
  
   Create App  region=US  access_ports=udp:1-10
 
   ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"Shared IP access with port range not allowed"}

AppInst - create with tcp port range on k8s shared shall return error
   [Documentation]
   ...  create an app with tcp port range
   ...  create app inst 
   ...  verify proper error is returned

   Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessShared  deployment=kubernetes

   Create App  region=US  access_ports=tcp:1-10

   ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"Shared IP access with port range not allowed"}

# no longer supported with http
#AppInst - create with http port range on k8s shared shall return error
#   [Documentation]
#   ...  create an app with http port range
#   ...  create app inst
#   ...  verify proper error is returned
#
#   Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessShared  deployment=kubernetes
#
#   ${error}=  Run Keyword and Expect Error  *  Create App  region=US  access_ports=http:1-10
#
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  error={"message":"Invalid deployment manifest, Port range not allowed for HTTP"}
#
##   ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
##   Should Contain  ${error}  code=400
##   Should Contain  ${error}  error={"message":"Shared IP access with port range not allowed"}

AppInst - create with tcp/udp single port and port range on k8s shared shall return error
   [Documentation]
   ...  create an app with tcp port range
   ...  create app inst
   ...  verify proper error is returned

   Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessShared  deployment=kubernetes

   Create App  region=US  access_ports=tcp:1,udp:1,tcp:1-10,udp:20-30

   ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"Shared IP access with port range not allowed"}

*** Keywords ***
Setup
    Create Flavor  region=US

