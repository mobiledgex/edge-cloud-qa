*** Settings ***
Documentation  Test Openstack

Library  OperatingSystem
# Import Python Library
Library  json
Library  Collections


#Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}

*** Variables ***
${qcow_centos_openstack_image}  server_ping_threaded_centos7

*** Test Cases ***

#Get limits
#    [Documentation]
#    ...  get limits
#    ${data_as_string} =    Get File    limits.json
#    ${data_as_json} =    json.loads    ${data_as_string}
#    ${results}=  Get Openstack Limits  ${data_as_json} 
#    :FOR   ${key}   IN  @{results.keys()}
#       Log  ${key}
#       ${subResult}=  Get Variable Value  ${results["${key}"]}
#       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
#    END

#Get Server
#    [Documentation]
#    ...  get server
#    ${data_as_string} =    Get File    limits.json
#    ${data_as_json} =    json.loads    ${data_as_string}
# 
#    ${results}=  Get Openstack Server List  ${data_as_json}
#    :FOR   ${key}   IN  @{results.keys()}
#       Log  ${key}
#       ${subResult}=  Get Variable Value  ${results["${key}"]}
#        Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
#   END


#Get Image
#    [Documentation]
#    ...  get image
#    ${data_as_string} =    Get File    limits.json
#    ${data_as_json} =    json.loads    ${data_as_string}
# 
#    ${results}=  Get Openstack Image List  ${data_as_json}
#    log to console  ${server_list}
#    :FOR   ${key}   IN  @{results.keys()}
#        Log  ${key}
#        ${subResult}=  Get Variable Value  ${results["${key}"]}
#       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
#    END

Get Network
    [Documentation]
    ...  get network
    ${data_as_string} =    Get File    limits.json
    ${data_as_json} =    json.loads    ${data_as_string}
 
    ${results}=  Get Openstack Network List  ${data_as_json}
#    log to console  ${server_list}
    :FOR   ${key}   IN  @{results.keys()}
        Log  ${key}
        ${subResult}=  Get Variable Value  ${results["${key}"]}
        Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END
