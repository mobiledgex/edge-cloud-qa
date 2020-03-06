*** Settings ***
Documentation  Openstack Verification

Library  OperatingSystem
Library  json
Library  Collections

Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}

*** Variables ***

*** Test Cases ***

Clean Up Landscape Before Testing
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

Test Image Create/List/Delete
    [Documentation]
    ...                    Test Image Create/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   TestImage
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


Test Flavor Create/List/Delete
    [Documentation]
    ...                    Test Flavor Create/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   TestFlavors
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


Test Security Group Create/List/Delete
    [Documentation]
    ...                    Test Security Group Create/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   TestSecurityGroup
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

Test Network Create/List/Delete
    [Documentation]
    ...                    Test Network Create/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   TestNetwork
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

Test Subnet Create/List/Delete
    [Documentation]
    ...                    Test Subnet Create/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   TestSubnet
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

Test Router Create/List/Delete
    [Documentation]
    ...                    Test Router Create/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   TestRouter
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

Test Router Port Create/List/Delete
    [Documentation]
    ...                    Test Router Port Create/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   TestRouterPorts
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

Test Router Port Create/Set/List/Delete
    [Documentation]
    ...                    Test Router Port Create/Set/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   TestRouterPortsAndSet
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


Test Server Create/List/Delete
    [Documentation]
    ...                    Test Server Create/List/Delete
    ${data_as_string} =    Get File                                 cloudlet_verification.json
    ${data_as_json} =      json.loads                               ${data_as_string}
    ${results}=            Deploy Test Infrastructure               ${data_as_json}   serverTest
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

Clean Up Landscape After Testing
    [Documentation]
    ...                    Clean Up Landscape After Testing
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


