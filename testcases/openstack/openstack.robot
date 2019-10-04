*** Settings ***
Documentation  Test Openstack

#Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}

*** Variables ***
${qcow_centos_openstack_image}  server_ping_threaded_centos7

*** Test Cases ***
Get Images
    [Documentation]
    ...  get images

    ${image_list}=  Get Openstack Image List  ${qcow_centos_openstack_image}
    Should Be Equal  ${image_list[0]['Name']}   ${qcow_centos_openstack_image}
    Should Be Equal  ${image_list[0]['Status']}   active 

Get Limits
    [Documentation]
    ...  get limits

    ${limits}=  Get Openstack limits
    Should Be Equal As Integers  ${limits['maxTotalVolumeGigabytes']}  5000                  # disk size
    Should Be Equal As Integers  ${limits['totalGigabytesUsed']}       100                 # disk used
    Should Be Equal As Integers  ${limits['maxTotalRAMSize']}          1024                 # ram size

Get Servers
    [Documentation]
    ...  get servers

    ${servers}=  Get Openstack Server List
    #log to console  ${servers}
    log to console  ${servers[0]['Image']}
    #Should Be Equal As Integers  ${limits['maxTotalVolumeGigabytes']}  5000                  # disk size
    #Should Be Equal As Integers  ${limits['totalGigabytesUsed']}       100                 # disk used
    #Should Be Equal As Integers  ${limits['maxTotalRAMSize']}          1024                 # ram size

Get Flavor list
    [Documentation]
    ...  get flavors

    ${flavors}=  Get Flavor List
    #Log to console  ${flavors}	

    Flavor Should Exist  flavors=${flavors}  ram=40960  disk=80  cpu=16 
