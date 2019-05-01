*** Settings ***
Documentation  SSH access should be blocked

Library  Process
Library  String
	
Test Timeout  30 minutes

*** Variables ***
${cloudlet_name_openstack}  automationBonnCloudlet
${operator_name_openstack}  TDG
${mobiledgex_domain}        mobiledgex.net

*** Test Cases ***
Openstack rootlb ssh access should be protected
    [Documentation]
    ...  attempt to ssh to rootlb on openstack
    ...  verify ssh access is publickey only

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${login}=  Catenate  SEPARATOR=@  test  ${rootlb}
	
    ${result}=  Run Process  ssh  -oBatchMode\=true  ${login}  shell=True  stderr=STDOUT  #stdout=andy.out

    Should Contain  ${result.stdout}  Permission denied (publickey)
