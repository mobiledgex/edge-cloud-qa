*** Settings ***
Documentation  Resource Management mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${operator}=  packet
${cloudlet}=  packet-qaregression
${version}=  latest

*** Test Cases ***
# ECQ-3335
GetCloudletResourceUsage - mcctl shall handle failures
   [Documentation]
   ...  - send GetCloudletResourceUsage via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail GetCloudletResourceUsage Via mcctl

      # missing arguments
      Error: missing required args: cloudlet-org cloudlet
      Error: missing required args: cloudlet  cloudlet-org=${operator}
      Error: missing required args: cloudlet-org  cloudlet=${cloudlet}

      # invalid values
      Error: Bad Request (400), Specified Cloudlet not found  cloudlet=${cloudlet}  cloudlet-org=x
      Error: Bad Request (400), Specified Cloudlet not found  cloudlet=x  cloudlet-org=${operator}

# ECQ-3336
GetCloudletResourceQuotaProps - mcctl shall handle failures
   [Documentation]
   ...  - send GetCloudletResourceQuotaProps via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail GetCloudletResourceQuotaProps Via mcctl

      # missing arguments
      Error: missing required args: platformtype
      
      # invalid values
      # Unable to parse "platformtype" value "x" as int: invalid syntax  platformtype=x
      Error: parsing arg "platformtype\=x" failed: unable to parse "x" as int: invalid syntax  platformtype=x

# ECQ-3337
CreateCloudlet with resource quotas - mcctl shall handle failures
   [Documentation]
   ...  - send CreateCloudlet via mcctl with various error cases for resource quotas
   ...  - verify proper error is received

   [Template]  Fail CreateCloudlet Via mcctl

      # invalid values
      Error: parsing arg "resourcequotas:0.value\=-1" failed: unable to parse "-1" as uint: invalid syntax  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10 numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=Disk  resourcequotas:0.value=-1

      Error: OK (200), Invalid quota name: Dis, valid names are Instances,Floating IPs,RAM,vCPUs,GPUs  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=Dis  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=90

      #Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for Disk, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=Disk  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for Instances, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=Instances  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for Floating IPs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name="Floating IPs"  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for RAM, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=RAM  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for vCPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=vCPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for GPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=GPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource alert threshold 101 specified, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  defaultresourcealertthreshold=101
      
      #Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for Disk, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=Disk  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for Instances, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=Instances  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for Floating IPs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name="Floating IPs"  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for RAM, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=RAM  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for vCPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=vCPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for GPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  resourcequotas:0.name=GPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource alert threshold -1 specified, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  location.latitude=10  location.longitude=10  numdynamicips=254  platformtype=PlatformTypeOpenstack  physicalname=packet2  defaultresourcealertthreshold=-1

# ECQ-3338
UpdateCloudlet with resource quotas - mcctl shall handle failures for PlatformTypeFake
   [Documentation]
   ...  - send UpdateCloudlet via mcctl with various error cases for resource quotas
   ...  - verify proper error is received

   [Setup]  Update Setup  PlatformTypeFake
   [Teardown]  Update Teardown

   [Template]  Fail UpdateCloudlet Via mcctl
      Error: Bad Request (400), Invalid quota name: Disk, valid names are  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=90

      #Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for Disk, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=160 resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for External IPs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name="External IPs"  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for RAM, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=RAM  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for vCPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=vCPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for GPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=GPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource alert threshold 101 specified, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  defaultresourcealertthreshold=101

      #Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for Disk, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for External IPs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name="External IPs"  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for RAM, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=RAM  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for vCPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=vCPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for GPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=GPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource alert threshold -1 specified, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  defaultresourcealertthreshold=-1

# ECQ-3339
UpdateCloudlet with resource quotas - mcctl shall handle failures for PlatformTypeOpenstack
   [Documentation]
   ...  - send UpdateCloudlet via mcctl with various error cases for resource quotas
   ...  - verify proper error is received

   [Setup]  Update Setup  PlatformTypeOpenstack
   [Teardown]  Update Teardown

   [Template]  Fail UpdateCloudlet Via mcctl
      Error: Bad Request (400), Invalid quota name: Disk, valid names are  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=90

      #Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for Disk, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=160 resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for Instances, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Instances  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for Floating IPs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name="Floating IPs"  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for RAM, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=RAM  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for vCPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=vCPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource quota alert threshold 101 specified for GPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=GPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=101
      Error: Bad Request (400), Invalid resource alert threshold 101 specified, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  defaultresourcealertthreshold=101

      #Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for Disk, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for Instances, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Instances  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for Floating IPs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name="Floating IPs"  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for RAM, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=RAM  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for vCPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=vCPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource quota alert threshold -1 specified for GPUs, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=GPUs  resourcequotas:0.value=160  resourcequotas:0.alertthreshold=-1
      Error: Bad Request (400), Invalid resource alert threshold -1 specified, valid threshold is in the range of 0 to 100  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  defaultresourcealertthreshold=-1

# ECQ-3340
UpdateCloudlet with resource quotas - mcctl shall handle failures when quotamaxvalue is greater than inframaxvalue for PlatformTypeFake
   [Documentation]
   ...  - send UpdateCloudlet via mcctl for all resource quotas with quotamaxvalue greater than inframaxvalue
   ...  - verify proper error is received

   [Setup]  Update Setup  PlatformTypeFake
   [Teardown]  Update Teardown

   [Template]  Fail UpdateCloudlet Via mcctl
      #Error: Bad Request (400), Resource quota Disk exceeded max supported value: ${disk_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=${disk_quota_value}  resourcequotas:0.alertthreshold=90
      Error: Bad Request (400), Resource quota External IPs exceeded max supported value: ${external_ips_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name="External IPs"  resourcequotas:0.value=${external_ips_quota_value}  resourcequotas:0.alertthreshold=90
      Error: Bad Request (400), Resource quota RAM exceeded max supported value: ${ram_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=RAM  resourcequotas:0.value=${ram_quota_value}  resourcequotas:0.alertthreshold=90
      Error: Bad Request (400), Resource quota vCPUs exceeded max supported value: ${vcpus_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=vCPUs  resourcequotas:0.value=${vcpus_quota_value}  resourcequotas:0.alertthreshold=90

# ECQ-3341
UpdateCloudlet with resource quotas - mcctl shall handle failures when quotamaxvalue is greater than inframaxvalue for PlatformTypeOpenstack
   [Documentation]
   ...  - send UpdateCloudlet via mcctl for all resource quotas with quotamaxvalue greater than inframaxvalue
   ...  - verify proper error is received

   [Setup]  Update Setup  PlatformTypeOpenstack
   [Teardown]  Update Teardown

   [Template]  Fail UpdateCloudlet Via mcctl
      #Error: Bad Request (400), Resource quota Disk exceeded max supported value: ${disk_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=${disk_quota_value}  resourcequotas:0.alertthreshold=90
      Error: Bad Request (400), Resource quota Floating IPs exceeded max supported value: ${floating_ips_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name="Floating IPs"  resourcequotas:0.value=${floating_ips_quota_value}  resourcequotas:0.alertthreshold=90
      Error: Bad Request (400), Resource quota RAM exceeded max supported value: ${ram_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=RAM  resourcequotas:0.value=${ram_quota_value}  resourcequotas:0.alertthreshold=90
      Error: Bad Request (400), Resource quota vCPUs exceeded max supported value: ${vcpus_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=vCPUs  resourcequotas:0.value=${vcpus_quota_value}  resourcequotas:0.alertthreshold=90
      Error: Bad Request (400), Resource quota Instances exceeded max supported value: ${instances_max_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Instances  resourcequotas:0.value=${instances_quota_value}  resourcequotas:0.alertthreshold=90

# ECQ-3342
UpdateCloudlet with resource quotas - mcctl shall handle failures when quotamaxvalue is lesser than currently used value for PlatformTypeFake
   [Documentation]
   ...  - send UpdateCloudlet via mcctl for all resource quotas with quotamaxvalue lesser than currently used value
   ...  - verify proper error is received

   [Setup]  Update Setup  PlatformTypeFake
   [Teardown]  Update Teardown

   [Template]  Fail UpdateCloudlet Via mcctl
      #Error: Bad Request (400), Resource quota value for Disk is less than currently used value. Should be atleast ${disk_used_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=${disk_updated_value}
      Error: Bad Request (400), Resource quota value for RAM is less than currently used value. Should be atleast ${ram_used_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=RAM  resourcequotas:0.value=${ram_updated_value}
      Error: Bad Request (400), Resource quota value for vCPUs is less than currently used value. Should be atleast ${vcpus_used_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=vCPUs  resourcequotas:0.value=${vcpus_updated_value}
      Error: Bad Request (400), Resource quota value for External IPs is less than currently used value. Should be atleast ${external_ips_used_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name="External IPs"  resourcequotas:0.value=${external_ips_updated_value}

# ECQ-3343
UpdateCloudlet with resource quotas - mcctl shall handle failures when quotamaxvalue is lesser than currently used value for PlatformTypeOpenstack
   [Documentation]
   ...  - send UpdateCloudlet via mcctl for all resource quotas with quotamaxvalue lesser than currently used value
   ...  - verify proper error is received

   [Setup]  Update Setup  PlatformTypeOpenstack
   [Teardown]  Update Teardown

   [Template]  Fail UpdateCloudlet Via mcctl
      #Error: Bad Request (400), Resource quota value for Disk is less than currently used value. Should be atleast ${disk_used_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Disk  resourcequotas:0.value=${disk_updated_value}
      Error: Bad Request (400), Resource quota value for RAM is less than currently used value. Should be atleast ${ram_used_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=RAM  resourcequotas:0.value=${ram_updated_value}
      Error: Bad Request (400), Resource quota value for vCPUs is less than currently used value. Should be atleast ${vcpus_used_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=vCPUs  resourcequotas:0.value=${vcpus_updated_value}
      Error: Bad Request (400), Resource quota value for Instances is less than currently used value. Should be atleast ${instances_used_value}  cloudlet-org=${operator}  cloudlet=${cloudlet_name}  resourcequotas:0.name=Instances  resourcequotas:0.value=${instances_updated_value}

# ECQ-4044
Metrics Cloudletusage - mcctl shall handle failures
   [Documentation]
   ...  - send cloudletusage metrics via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Metrics CloudletUsage Via mcctl

      # missing arguments
      Error: missing required args: selector
      Error: Bad Request (400), Cloudlet details must be present  selector=resourceusage
      Error: Bad Request (400), Cloudlet details must be present  selector=flavorusage
      Error: Bad Request (400), Cloudlet details must be present  cloudlet=automationSunnydaleCloudlet selector=flavorusage

      # invalid values
      Error: Bad Request (400), Cloudlet does not exist  cloudlet-org=x selector=resourceusage
      Error: Bad Request (400), Invalid cloudletusage selector: x, must be one of "resourceusage", "flavorusage"  selector=x cloudlet-org=${operator_name_openstack}
      Error: parsing arg "starttime\=x" failed: unable to parse "x" as time: invalid format, valid values are RFC3339 format, i.e. "2006-01-02T15:04:05Z07:00"      selector=resourceusage cloudlet-org=${operator_name_openstack} starttime=x
      Error: parsing arg "endtime\=x" failed: unable to parse "x" as time: invalid format, valid values are RFC3339 format, i.e. "2006-01-02T15:04:05Z07:00"        selector=resourceusage cloudlet-org=${operator_name_openstack} endtime=x
      Error: parsing arg "startage\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc         selector=resourceusage cloudlet-org=${operator_name_openstack} startage=x
      Error: parsing arg "endage\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc           selector=resourceusage cloudlet-org=${operator_name_openstack} endage=x
      Error: parsing arg "limit\=x" failed: unable to parse "x" as int: invalid syntax                                                               selector=resourceusage cloudlet-org=${operator_name_openstack} limit=x
      Error: parsing arg "numsamples\=x" failed: unable to parse "x" as int: invalid syntax                                                          selector=resourceusage cloudlet-org=${operator_name_openstack} numsamples=x

*** Keywords ***
Setup
   ${cloudlet_name}=  Get Default Cloudlet Name

   Set Suite Variable  ${cloudlet_name}

Fail Metrics CloudletUsage Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  metrics cloudletusage region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail GetCloudletResourceUsage Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudlet getresourceusage region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail GetCloudletResourceQuotaProps Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudlet getresourcequotaprops region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail CreateCloudlet Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}
   &{parms_copy}=  Set Variable  ${parms}
   Log To Console  ${parms_copy}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   Remove From Dictionary  ${parms_copy}  deploymentmanifest
   Remove From Dictionary  ${parms_copy}  resourcequotas:0.value
   Remove From Dictionary  ${parms_copy}  resourcequotas:0.alertthreshold
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudlet create region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

   ${show}=  Run mcctl  cloudlet show region=${region} ${parmss_modify}  version=${version}
   Should Be Empty  ${show}

Fail UpdateCloudlet Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudlet update region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Update Setup
   [Arguments]   ${platform_type}

   Run Keyword If  '${platform_type}' == 'PlatformTypeFake'  Run mcctl  cloudlet create region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} location.latitude=10 location.longitude=10 numdynamicips=254 platformtype=${platform_type}
   ...  ELSE  Run mcctl  cloudlet create region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} location.latitude=10 location.longitude=10 numdynamicips=254 platformtype=${platform_type} physicalname=packet2

   ${cloudlet_resource_usage}=  Run mcctl  cloudlet getresourceusage region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator}
   Log To Console  ${cloudlet_resource_usage}

   Run Keyword If  '${platform_type}' == 'PlatformTypeFake'  Setup PlatformTypeFake  ${cloudlet_resource_usage}
   ...  ELSE  Setup PlatformTypeOpenstack  ${cloudlet_resource_usage} 

Setup PlatformTypeFake
   [Arguments]   ${cloudlet_resource_usage}

   ${ram_max_value}=  Set Variable  ${cloudlet_resource_usage['info'][3]['infra_max_value']}
   ${vcpus_max_value}=  Set Variable  ${cloudlet_resource_usage['info'][4]['infra_max_value']}
   ${external_ips_max_value}=  Set Variable  ${cloudlet_resource_usage['info'][0]['infra_max_value']}

   ${ram_used_value}=  Set Variable  ${cloudlet_resource_usage['info'][3]['value']}
   ${vcpus_used_value}=  Set Variable  ${cloudlet_resource_usage['info'][4]['value']}
   ${external_ips_used_value}=  Set Variable  ${cloudlet_resource_usage['info'][0]['value']}
   
   ${ram_quota_value}=  Evaluate  ${ram_max_value}+1
   ${vcpus_quota_value}=  Evaluate  ${vcpus_max_value}+1
   ${external_ips_quota_value}=  Evaluate  ${external_ips_max_value}+1
   ${ram_updated_value}=  Evaluate  ${ram_used_value}-1
   ${vcpus_updated_value}=  Evaluate  ${vcpus_used_value}-1
   ${external_ips_updated_value}=  Evaluate  ${external_ips_used_value}-1

   Set Suite Variable  ${ram_max_value}
   Set Suite Variable  ${vcpus_max_value}
   Set Suite Variable  ${external_ips_max_value}
   Set Suite Variable  ${ram_quota_value}
   Set Suite Variable  ${vcpus_quota_value}
   Set Suite Variable  ${external_ips_quota_value}
   Set Suite Variable  ${ram_updated_value}
   Set Suite Variable  ${vcpus_updated_value}
   Set Suite Variable  ${external_ips_updated_value}
   Set Suite Variable  ${ram_used_value}
   Set Suite Variable  ${vcpus_used_value}
   Set Suite Variable  ${external_ips_used_value}

Setup PlatformTypeOpenstack
   [Arguments]   ${cloudlet_resource_usage}

   ${ram_max_value}=  Set Variable  ${cloudlet_resource_usage['info'][4]['infra_max_value']}
   ${vcpus_max_value}=  Set Variable  ${cloudlet_resource_usage['info'][5]['infra_max_value']}
   ${floating_ips_max_value}=  Set Variable  ${cloudlet_resource_usage['info'][1]['infra_max_value']}
   ${instances_max_value}=  Set Variable  ${cloudlet_resource_usage['info'][3]['infra_max_value']}

   ${ram_used_value}=  Set Variable  ${cloudlet_resource_usage['info'][4]['value']}
   ${vcpus_used_value}=  Set Variable  ${cloudlet_resource_usage['info'][5]['value']}
   ${instances_used_value}=  Set Variable  ${cloudlet_resource_usage['info'][3]['value']}

   ${ram_quota_value}=  Evaluate  ${ram_max_value}+1
   ${vcpus_quota_value}=  Evaluate  ${vcpus_max_value}+1
   ${floating_ips_quota_value}=  Evaluate  ${floating_ips_max_value}+1
   ${instances_quota_value}=  Evaluate  ${instances_max_value}+1
   ${ram_updated_value}=  Evaluate  ${ram_used_value}-1
   ${vcpus_updated_value}=  Evaluate  ${vcpus_used_value}-1
   ${instances_updated_value}=  Evaluate  ${instances_used_value}-1

   Set Suite Variable  ${ram_max_value}
   Set Suite Variable  ${vcpus_max_value}
   Set Suite Variable  ${floating_ips_max_value}
   Set Suite Variable  ${instances_max_value}
   Set Suite Variable  ${ram_quota_value}
   Set Suite Variable  ${vcpus_quota_value}
   Set Suite Variable  ${floating_ips_quota_value}
   Set Suite Variable  ${instances_quota_value}
   Set Suite Variable  ${ram_used_value}
   Set Suite Variable  ${vcpus_used_value}
   Set Suite Variable  ${instances_used_value}
   Set Suite Variable  ${ram_updated_value}
   Set Suite Variable  ${vcpus_updated_value}
   Set Suite Variable  ${instances_updated_value}  

Update Teardown
   Run mcctl  cloudlet delete region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator}

