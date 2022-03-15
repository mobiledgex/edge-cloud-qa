*** Settings ***
Documentation  user api key create delete show mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  Collections
Library  String

Test Setup  Setup

Test Timeout  5m

*** Variables ***
${devorg}=        automation_dev_org
${devdescrip}=    dev_apikey
${oprorg}=        tmus
${oprdescrip}=    oper_apikey
${version}=       latest
	
*** Test Cases ***
# ECQ-4394
CreateApiKey - mcctl shall be able to create/show/delete dev manager apikeys
   [Documentation]
   ...  - send CreateApiKey/ShowApiKey/DeleteApiKey via mcctl with various dev manager parms
   ...  - verify the user ApiKey is created/shown/deleted

   [Template]  Success Create/Show/Delete User ApiKey Via mcctl
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users   token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=flavors  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=cloudlets  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=clusters  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusters  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=clusterinsts  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusterinsts  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=apps  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=apps  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=appinsts  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=appinsts  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=alert  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=alert  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=developerpolicy  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=developerpolicy  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=billing  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=billing  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=clusteranalytics  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusteranalytics  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=appanalytics  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=appanalytics  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  token=${devmgrtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=apps  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=apps  permissions:5.action=manage  permissions:5.resource=appinsts  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=apps  permissions:5.action=manage  permissions:5.resource=appinsts  permissions:6.action=manage  permissions:6.resource=alert  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=apps  permissions:5.action=manage  permissions:5.resource=appinsts  permissions:6.action=manage  permissions:6.resource=alert  permissions:7.action=manage  permissions:7.resource=developerpolicy  token=${devmgrtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=apps  permissions:5.action=manage  permissions:5.resource=appinsts  permissions:6.action=manage  permissions:6.resource=alert  permissions:7.action=manage  permissions:7.resource=developerpolicy  permissions:8.action=manage  permissions:8.resource=billing  token=${devmgrtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=apps  permissions:5.action=manage  permissions:5.resource=appinsts  permissions:6.action=manage  permissions:6.resource=alert  permissions:7.action=manage  permissions:7.resource=developerpolicy  permissions:8.action=manage  permissions:8.resource=billing  permissions:9.action=manage  permissions:9.resource=clusteranalytics   token=${devmgrtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=apps  permissions:5.action=manage  permissions:5.resource=appinsts  permissions:6.action=manage  permissions:6.resource=alert  permissions:7.action=manage  permissions:7.resource=developerpolicy  permissions:8.action=manage  permissions:8.resource=billing  permissions:9.action=manage  permissions:9.resource=clusteranalytics  permissions:10.action=manage  permissions:10.resource=appanalytics  token=${devmgrtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=apps  permissions:5.action=manage  permissions:5.resource=appinsts  permissions:6.action=manage  permissions:6.resource=alert  permissions:7.action=manage  permissions:7.resource=developerpolicy  permissions:8.action=manage  permissions:8.resource=billing  permissions:9.action=manage  permissions:9.resource=clusteranalytics  permissions:10.action=manage  permissions:10.resource=appanalytics  permissions:11.action=manage  permissions:11.resource=clusterinsts  token=${devmgrtoken}  

# ECQ-4395
CreateApiKey - mcctl shall be able to create/show/delete oper manager apikeys
   [Documentation]
   ...  - send CreateApiKey/ShowApiKey/DeleteApiKey via mcctl with various oper manager parms
   ...  - verify the user ApiKey is created/shown/deleted

   [Template]  Success Create/Show/Delete User ApiKey Via mcctl
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=users  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=cloudlets  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudlets  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=cloudletpools  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudletpools  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=alert  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=alert  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=restagtbl  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=restagtbl  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=cloudletanalytics  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudletanalytics  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  token=${oprmgrtoken}  
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  permissions:2.action=manage  permissions:2.resource=cloudletpools  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  permissions:2.action=manage  permissions:2.resource=cloudletpools  permissions:3.action=manage  permissions:3.resource=alert  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  permissions:2.action=manage  permissions:2.resource=cloudletpools  permissions:3.action=manage  permissions:3.resource=alert  permissions:4.action=manage  permissions:4.resource=restagtbl  token=${oprmgrtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  permissions:2.action=manage  permissions:2.resource=cloudletpools  permissions:3.action=manage  permissions:3.resource=alert  permissions:4.action=manage  permissions:4.resource=restagtbl  permissions:5.action=manage  permissions:5.resource=cloudletanalytics  token=${oprmgrtoken}

# ECQ-4396
CreateApiKey - mcctl shall be able to create/show/delete dev contributor apikeys
   [Documentation]
   ...  - send CreateApiKey/ShowApiKey/DeleteApiKey via mcctl with various dev contributor parms
   ...  - verify the user ApiKey is created/shown/deleted

   [Template]  Success Create/Show/Delete User ApiKey Via mcctl
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=flavors  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=cloudlets  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=clusters  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusters  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=clusterinsts  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusterinsts  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=apps  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=apps  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=appinsts  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=appinsts  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=alert  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=alert  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=developerpolicy  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=developerpolicy  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=clusteranalytics  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusteranalytics  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=appanalytics  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=appanalytics  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  token=${devctbtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=clusterinsts  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=clusterinsts  permissions:5.action=manage  permissions:5.resource=apps  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=clusterinsts  permissions:5.action=manage  permissions:5.resource=apps  permissions:6.action=manage  permissions:6.resource=appinsts  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=clusterinsts  permissions:5.action=manage  permissions:5.resource=apps  permissions:6.action=manage  permissions:6.resource=appinsts  permissions:7.action=manage  permissions:7.resource=alert  token=${devctbtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=clusterinsts  permissions:5.action=manage  permissions:5.resource=apps  permissions:6.action=manage  permissions:6.resource=appinsts  permissions:7.action=manage  permissions:7.resource=alert  permissions:8.action=manage  permissions:8.resource=developerpolicy  token=${devctbtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=clusterinsts  permissions:5.action=manage  permissions:5.resource=apps  permissions:6.action=manage  permissions:6.resource=appinsts  permissions:7.action=manage  permissions:7.resource=alert  permissions:8.action=manage  permissions:8.resource=developerpolicy  permissions:9.action=manage  permissions:9.resource=clusteranalytics    token=${devctbtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=manage  permissions:3.resource=clusters  permissions:4.action=manage  permissions:4.resource=clusterinsts  permissions:5.action=manage  permissions:5.resource=apps  permissions:6.action=manage  permissions:6.resource=appinsts  permissions:7.action=manage  permissions:7.resource=alert  permissions:8.action=manage  permissions:8.resource=developerpolicy  permissions:9.action=manage  permissions:9.resource=clusteranalytics    permissions:10.action=manage  permissions:10.resource=appanalytics  token=${devctbtoken}  

# ECQ-4397
CreateApiKey - mcctl shall be able to create/show/delete oper contributor apikeys
   [Documentation]
   ...  - send CreateApiKey/ShowApiKey/DeleteApiKey via mcctl with various oper contributor parms
   ...  - verify the user ApiKey is created/shown/deleted

   [Template]  Success Create/Show/Delete User ApiKey Via mcctl
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=cloudlets  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudlets  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=cloudletpools  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudletpools  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=alert  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=alert  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=restagtbl  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=restagtbl  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=cloudletanalytics  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudletanalytics  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  token=${oprctbtoken}  
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  permissions:2.action=manage  permissions:2.resource=cloudletpools  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  permissions:2.action=manage  permissions:2.resource=cloudletpools  permissions:3.action=manage  permissions:3.resource=alert  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  permissions:2.action=manage  permissions:2.resource=cloudletpools  permissions:3.action=manage  permissions:3.resource=alert  permissions:4.action=manage  permissions:4.resource=restagtbl  token=${oprctbtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=manage  permissions:1.resource=cloudlets  permissions:2.action=manage  permissions:2.resource=cloudletpools  permissions:3.action=manage  permissions:3.resource=alert  permissions:4.action=manage  permissions:4.resource=restagtbl  permissions:5.action=manage  permissions:5.resource=cloudletanalytics  token=${oprctbtoken}

# ECQ-4398
CreateApiKey - mcctl shall be able to create/show/delete dev viewer apikeys
   [Documentation]
   ...  - send CreateApiKey/ShowApiKey/DeleteApiKey via mcctl with various dev viewer parms
   ...  - verify the user ApiKey is created/shown/deleted

   [Template]  Success Create/Show/Delete User ApiKey Via mcctl
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=flavors  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=cloudlets  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusters  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusterinsts  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=apps  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=appinsts  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=alert  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=developerpolicy  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=clusteranalytics  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=appanalytics  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  token=${devvewtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=view  permissions:3.resource=clusters  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=view  permissions:3.resource=clusters  permissions:4.action=view  permissions:4.resource=clusterinsts  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=view  permissions:3.resource=clusters  permissions:4.action=view  permissions:4.resource=clusterinsts  permissions:5.action=view  permissions:5.resource=apps  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=view  permissions:3.resource=clusters  permissions:4.action=view  permissions:4.resource=clusterinsts  permissions:5.action=view  permissions:5.resource=apps  permissions:6.action=view  permissions:6.resource=appinsts  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=view  permissions:3.resource=clusters  permissions:4.action=view  permissions:4.resource=clusterinsts  permissions:5.action=view  permissions:5.resource=apps  permissions:6.action=view  permissions:6.resource=appinsts  permissions:7.action=view  permissions:7.resource=alert  token=${devvewtoken}
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=view  permissions:3.resource=clusters  permissions:4.action=view  permissions:4.resource=clusterinsts  permissions:5.action=view  permissions:5.resource=apps  permissions:6.action=view  permissions:6.resource=appinsts  permissions:7.action=view  permissions:7.resource=alert  permissions:8.action=view  permissions:8.resource=developerpolicy  token=${devvewtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=view  permissions:3.resource=clusters  permissions:4.action=view  permissions:4.resource=clusterinsts  permissions:5.action=view  permissions:5.resource=apps  permissions:6.action=view  permissions:6.resource=appinsts  permissions:7.action=view  permissions:7.resource=alert  permissions:8.action=view  permissions:8.resource=developerpolicy  permissions:9.action=view  permissions:9.resource=clusteranalytics    token=${devvewtoken}  
      org=${devorg}   description=${devdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=flavors  permissions:2.action=view  permissions:2.resource=cloudlets  permissions:3.action=view  permissions:3.resource=clusters  permissions:4.action=view  permissions:4.resource=clusterinsts  permissions:5.action=view  permissions:5.resource=apps  permissions:6.action=view  permissions:6.resource=appinsts  permissions:7.action=view  permissions:7.resource=alert  permissions:8.action=view  permissions:8.resource=developerpolicy  permissions:9.action=view  permissions:9.resource=clusteranalytics    permissions:10.action=view  permissions:10.resource=appanalytics  token=${devvewtoken}  

# ECQ-4399
CreateApiKey - mcctl shall be able to create/show/delete oper view apikeys
   [Documentation]
   ...  - send CreateApiKey/ShowApiKey/DeleteApiKey via mcctl with various oper view parms
   ...  - verify the user ApiKey is created/shown/deleted

   [Template]  Success Create/Show/Delete User ApiKey Via mcctl
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudlets  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudletpools  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=alert  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=restagtbl  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=cloudletanalytics  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=cloudlets  token=${oprvewtoken}  
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=cloudlets  permissions:2.action=view  permissions:2.resource=cloudletpools  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=cloudlets  permissions:2.action=view  permissions:2.resource=cloudletpools  permissions:3.action=view  permissions:3.resource=alert  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=cloudlets  permissions:2.action=view  permissions:2.resource=cloudletpools  permissions:3.action=view  permissions:3.resource=alert  permissions:4.action=view  permissions:4.resource=restagtbl  token=${oprvewtoken}
      org=${oprorg}   description=${oprdescrip}   permissions:0.action=view    permissions:0.resource=users  permissions:1.action=view  permissions:1.resource=cloudlets  permissions:2.action=view  permissions:2.resource=cloudletpools  permissions:3.action=view  permissions:3.resource=alert  permissions:4.action=view  permissions:4.resource=restagtbl  permissions:5.action=view  permissions:5.resource=cloudletanalytics  token=${oprvewtoken}

# ECQ-4400
CreateApiKey - mcctl shall handle createuserapikey failures
   [Documentation]
   ...  - send Fail Create User ApiKey Via mcctl with various missing/bad parms
   ...  - verify the correct error message is received

   [Template]  Fail Create User ApiKey Via mcctl
      Error: missing required args:       token=${devmgrtoken}
      Error: missing required args:       org=            token=${devmgrtoken}
      Error: missing required args:       org=myneworg    token=${devmgrtoken}
      No permissions for specified org    org=            description=   token=${devmgrtoken}
      No permissions for specified org    org=myneworg    description=   token=${devmgrtoken}
      Invalid permission specified:       org=            description=   permissions:0.action=view  permissions:0.resource=users  token=${devmgrtoken}
      Invalid org specified               org=myneworg    description=   permissions:0.action=view  permissions:0.resource=users  token=${devmgrtoken}    # EDGECLOUD-6210
      Error: missing required args:       org=${devorg}   token=${devmgrtoken}
      No permissions for specified org    org=${devorg}   description=   token=${devmgrtoken}
      Error: missing required args:       description=${devdescrip}   token=${devmgrtoken}
      No permissions for specified org    org=${devorg}  description=${devdescrip}   token=${devmgrtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}   permissions:0.action=view  token=${devmgrtoken}
      Invalid action                      org=${devorg}  description=${devdescrip}   permissions:0.resource=users  token=${devmgrtoken}

# ECQ-4401
CreateApiKey - mcctl shall check action permission is a subset for the current user
   [Documentation]
   ...  - send Fail Create User ApiKey Via mcctl with action permissions not in the users permissions subset
   ...  - verify the correct error message is received

   [Template]  Fail Create User ApiKey Via mcctl
      Invalid permission specified:       org=${devorg}  description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users      token=${devctbtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=users      token=${devvewtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}   permissions:0.action=manage  permissions:0.resource=apps       token=${devvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=users      token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=users      token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}   permissions:0.action=manage  permissions:0.resource=cloudlets  token=${oprvewtoken}

# ECQ-4402
CreateApiKey - mcctl shall check resource permission is a allowed for the current user
   [Documentation]
   ...  - send Fail Create User ApiKey Via mcctl with resource permissions not allowed for the current user
   ...  - verify the correct error message is received

   [Template]  Fail Create User ApiKey Via mcctl
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=cloudletpools      token=${devmgrtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=restagtbl          token=${devmgrtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=cloudletanalytics  token=${devmgrtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=cloudletpools      token=${devctbtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=restagtbl          token=${devctbtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=cloudletanalytics  token=${devctbtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=cloudletpools      token=${devvewtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=restagtbl          token=${devvewtoken}
      Invalid permission specified:       org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=cloudletanalytics  token=${devvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=flavors            token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusters           token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusterinsts       token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusterflavors     token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=apps               token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=appinsts           token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=developerpolicy    token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=billing            token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusteranalytics   token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=appanalytics       token=${oprmgrtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=flavors            token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusters           token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusterinsts       token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusterflavors     token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=apps               token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=appinsts           token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=developerpolicy    token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=billing            token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusteranalytics   token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=appanalytics       token=${oprctbtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=flavors            token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusters           token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusterinsts       token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusterflavors     token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=apps               token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=appinsts           token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=developerpolicy    token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=billing            token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=clusteranalytics   token=${oprvewtoken}
      Invalid permission specified:       org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=appanalytics       token=${oprvewtoken}

# ECQ-4403
DeleteApiKey - mcctl shall handle a deleteuserapikey failure
   [Documentation]
   ...  - send Fail Delete User ApiKey Via mcctl with various missing/bad parms 
   ...  - verify the correct error message is received

   [Template]  Fail Delete User ApiKey Via mcctl
      Error: missing required args: apikeyid    token=${devmgrtoken}
      Missing API key ID                        apikeyid=         token=${devmgrtoken}
      API key ID not found                      apikeyid=xxxx     token=${devmgrtoken}        #/EDGECLOUD-6212

# 
DeleteApiKey - mcctl shall not allow a user's apikey to be deleted by another user
   [Documentation]
   ...  - send Fail Delete User ApiKey Via mcctl with various missing/bad parms 
   ...  - verify the correct error message is received

   [Template]  Fail Delete Another Users ApiKey Via mcctl
      Cannot delete other user's API key     org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=users  token1=${devmgrtoken}  token2=${oprmgrtoken}
      Cannot delete other user's API key     org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=users  token1=${oprmgrtoken}  token2=${devmgrtoken}
      Cannot delete other user's API key     org=${devorg}  description=${devdescrip}  permissions:0.action=view  permissions:0.resource=users  token1=${devvewtoken}  token2=${devmgrtoken}
      Cannot delete other user's API key     org=${oprorg}  description=${oprdescrip}  permissions:0.action=view  permissions:0.resource=users  token1=${oprvewtoken}  token2=${oprmgrtoken}



*** Keywords ***
Setup
   ${devmgrtoken}=    Login   username=${dev_manager_user_automation}       password=${dev_manager_password_automation}
   ${oprmgrtoken}=    Login   username=${op_manager_user_automation}        password=${op_manager_password_automation}
   ${devctbtoken}=    Login   username=${dev_contributor_user_automation}   password=${dev_contributor_password_automation}
   ${oprctbtoken}=    Login   username=${op_contributor_user_automation}    password=${op_contributor_password_automation}
   ${devvewtoken}=    Login   username=${dev_viewer_user_automation}        password=${dev_viewer_password_automation}
   ${oprvewtoken}=    Login   username=${op_viewer_user_automation}         password=${op_viewer_password_automation}
   
   Set Suite Variable   ${devmgrtoken}
   Set Suite Variable   ${oprmgrtoken}
   Set Suite Variable   ${devctbtoken}
   Set Suite Variable   ${oprctbtoken}
   Set Suite Variable   ${devvewtoken}
   Set Suite Variable   ${oprvewtoken}


Success Create/Show/Delete User ApiKey Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}
   ${token}=   Set Variable   ${parms_copy['token']}
   Remove From Dictionary  ${parms_copy}  token
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${create}=  Run mcctl  user createuserapikey ${parmss}   token=${token}
   Should Contain   ${create}    ApiKey
   Should Contain   ${create}    Id
   ${apikeyparms}=   Set Variable   apikeyid=${create['Id']}
   ${show}=    Run mcctl  user showuserapikey ${apikeyparms}   token=${token}
   Should Be Equal As Strings   ${show[0]['Id']}   ${create['Id']}
   Run mcctl  user deleteuserapikey ${apikeyparms}   token=${token}
   ${show}=    Run Keyword and Expect Error  *  Run mcctl  user showuserapikey ${apikeyparms}     token=${token}
   Should Contain  ${show}  API key ID not found

Fail Create User ApiKey Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   &{parms_copy}=  Set Variable  ${parms}
   ${token}=   Set Variable   ${parms_copy['token']}
   Remove From Dictionary  ${parms_copy}  token
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${create}=  Run Keyword and Expect Error  *  Run mcctl  user createuserapikey ${parmss}   token=${token}
   Should Contain  ${create}  ${error_msg}

Fail Delete User ApiKey Via mcctl
   [Arguments]  ${error_msg}  &{parms}
	
   &{parms_copy}=  Set Variable  ${parms}
   ${token}=   Set Variable   ${parms_copy['token']}
   Remove From Dictionary  ${parms_copy}  token
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${delete}=  Run Keyword and Expect Error  *  Run mcctl  user deleteuserapikey ${parmss}   token=${token}
   Should Contain  ${delete}  ${error_msg}
   
Fail Delete Another Users ApiKey Via mcctl
   [Arguments]  ${error_msg}  &{parms}
	
   &{parms_copy}=   Set Variable   ${parms}
   ${usertoken}=    Set Variable   ${parms_copy['token1']}
   ${othertoken}=   Set Variable   ${parms_copy['token2']}
   Remove From Dictionary  ${parms_copy}  token1
   Remove From Dictionary  ${parms_copy}  token2
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${create}=  Run mcctl  user createuserapikey ${parmss}   token=${usertoken}
   Should Contain   ${create}    ApiKey
   Should Contain   ${create}    Id
   ${apikeyparms}=   Set Variable   apikeyid=${create['Id']}
   ${show}=    Run mcctl  user showuserapikey ${apikeyparms}   token=${usertoken}
   Should Be Equal As Strings   ${show[0]['Id']}   ${create['Id']}
   ${delete}=  Run Keyword and Expect Error  *  Run mcctl  user deleteuserapikey ${apikeyparms}   token=${othertoken}
   Should Contain  ${delete}  ${error_msg}
   Run mcctl  user deleteuserapikey ${apikeyparms}   token=${usertoken}
   ${show}=    Run Keyword and Expect Error  *  Run mcctl  user showuserapikey ${apikeyparms}     token=${usertoken}
   Should Contain  ${show}  API key ID not found
