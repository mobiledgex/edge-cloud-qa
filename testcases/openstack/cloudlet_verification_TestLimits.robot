*** Settings ***
Documentation  Test Openstack

Library  OperatingSystem
Library  json
Library  Collections

Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}

*** Variables ***

*** Test Cases ***

Check Againts Required Limits
    [Documentation]
    ...  Check Limits
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
    ${results}=  Check Openstack Limits  ${data_as_json} 
    :FOR   ${key}   IN  @{results.keys()}
#      Log  ${key}
       ${subResult}=  Get Variable Value  ${results["${key}"]}
       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END

