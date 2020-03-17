*** Settings ***
Documentation  Test Openstack

Library  OperatingSystem
Library  json
Library  Collections

Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}

*** Variables ***

*** Test Cases ***

Clean Up Landscape
    [Documentation]
    ...                    Clean Up
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   CleanUpSpace
    Log                    ${results}

    ${outcome}=    Get Variable Value    ${results["create"]}
    :FOR    ${item}    IN    @{outcome}
    Log                                    ${item}
    Run keyword And Continue On Failure    Should Be Equal As Strings    "PASS"    "${item["result"]}"    ${item["cmd"]}
    END

    ${outcome}=    Get Variable Value    ${results["delete"]}
    :FOR    ${item}    IN    @{outcome}
    Log                                    ${item}
    Run keyword And Continue On Failure    Should Be Equal As Strings    "PASS"    "${item["result"]}"    ${item["cmd"]}
    END
