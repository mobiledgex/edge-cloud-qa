*** Settings ***
Documentation  Test Openstack

Library  OperatingSystem
Library  json
Library  Collections


Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}

*** Variables ***
${qcow_centos_openstack_image}  server_ping_threaded_centos7

*** Test Cases ***

Server Stress
 [Documentation]
   ...  Deploy and delete n number of server
   ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
    ${results}=  Stress Server  ${data_as_json}
#    Log  ${results}
   ${outcome}=  Get Variable Value  ${results["create"]}
   :FOR   ${item}   IN  @{outcome}
   Log  ${item}
     Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${item["result"]}"  ${item["cmd"]}
 END
  ${outcome}=  Get Variable Value  ${results["server"]}
    :FOR   ${item}   IN  @{outcome}
     Log  ${item}
      Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${item["result"]}"  ${item["cmd"]}
  END
    ${outcome}=  Get Variable Value  ${results["delete"]}
    :FOR   ${item}   IN  @{outcome}
     Log  ${item}
      Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${item["result"]}"  ${item["cmd"]}
   END


Deploy Test Infrastructure
  [Documentation]
    ...  Deploy and delete test infrastructure
    ${data_as_string} =    Get File    cloudlet_verification.json
   ${data_as_json} =    json.loads    ${data_as_string}
    ${results}=  Deploy Test Infrastructure  ${data_as_json}
   Log  ${results}

   ${outcome}=  Get Variable Value  ${results["create"]}
    :FOR   ${item}   IN  @{outcome}
      Log  ${item}
       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${item["result"]}"  ${item["cmd"]}
    END

    ${outcome}=  Get Variable Value  ${results["delete"]}
    :FOR   ${item}   IN  @{outcome}
     Log  ${item}
      Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${item["result"]}"  ${item["cmd"]}
   END


Get limits
   [Documentation]
    ...  get limits
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
    ${results}=  Get Openstack Limits  ${data_as_json} 
    :FOR   ${key}   IN  @{results.keys()}
      Log  ${key}
       ${subResult}=  Get Variable Value  ${results["${key}"]}
       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END
    Log  ${results}

Check limits
    [Documentation]
    ...  check limits
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
    ${results}=  Check Openstack Limits  ${data_as_json} 
    :FOR   ${key}   IN  @{results.keys()}
#      Log  ${key}
       ${subResult}=  Get Variable Value  ${results["${key}"]}
       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END


Get Server
   [Documentation]
    ...  get server
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
 
    ${results}=  Get Openstack Server List  ${data_as_json}
   :FOR   ${key}   IN  @{results.keys()}
       Log  ${key}
      ${subResult}=  Get Variable Value  ${results["${key}"]}
       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
   END


Get Image
    [Documentation]
    ...  get image
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
 
    ${results}=  Get Openstack Image List  ${data_as_json}
    log to console  ${server_list}
    :FOR   ${key}   IN  @{results.keys()}
        Log  ${key}
        ${subResult}=  Get Variable Value  ${results["${key}"]}
       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END

Get Network
   [Documentation]
    ...  get network
   ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
 
    ${results}=  Get Openstack Network List  ${data_as_json}
#    log to console  ${server_list}
   :FOR   ${key}   IN  @{results.keys()}
        Log  ${key}
        ${subResult}=  Get Variable Value  ${results["${key}"]}
       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END

Get Subnet
    [Documentation]
    ...  get subnet
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
 
    ${results}=  Get Openstack Subnet List  ${data_as_json}
    log to console  ${server_list}
    :FOR   ${key}   IN  @{results.keys()}
        Log  ${key}
        ${subResult}=  Get Variable Value  ${results["${key}"]}
        Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
   END

Get Router
    [Documentation]
    ...  get router
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
 
    ${results}=  Get Openstack Router List  ${data_as_json}
#    log to console  ${server_list}
    :FOR   ${key}   IN  @{results.keys()}
        Log  ${key}
        ${subResult}=  Get Variable Value  ${results["${key}"]}
        Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END

Get FlavorList
   [Documentation]
   ...  get FlavorList
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
 
    ${results}=  Get Openstack Flavor List  ${data_as_json}
#    log to console  ${server_list}
    :FOR   ${key}   IN  @{results.keys()}
        Log  ${key}
        ${subResult}=  Get Variable Value  ${results["${key}"]}
        Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END

Check FlavorList
  [Documentation]
  ...  check FlavorList
   ${data_as_string} =    Get File    cloudlet_verification.json
   ${data_as_json} =    json.loads    ${data_as_string}

    ${results}=  Check Openstack Flavor List  ${data_as_json}
#    log to console  ${results}
    :FOR   ${key}   IN  @{results.keys()}
       Log  ${key}
        ${subResult}=  Get Variable Value  ${results["${key}"]}
        Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
   END

Get Security List
   [Documentation]
  ...  get Security List
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}

    ${results}=  Get Openstack Security List  ${data_as_json}
    log to console  ${server_list}
   :FOR   ${key}   IN  @{results.keys()}
#        Log  ${key}
       ${subResult}=  Get Variable Value  ${results["${key}"]}
       Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
   END

Get Security Rule List
   [Documentation]
   ...  get Security Rule List
    ${data_as_string} =    Get File    cloudlet_verification.json
    ${data_as_json} =    json.loads    ${data_as_string}
 
    ${results}=  Get Openstack Security Group Rule List  ${data_as_json}
#    log to console  ${server_list}
    :FOR   ${key}   IN  @{results.keys()}
        Log  ${key}
        ${subResult}=  Get Variable Value  ${results["${key}"]}
        Run keyword And Continue On Failure  Should Be Equal As Strings  "PASS"  "${subResult["result"]}"  ${subResult["comment"]}
    END
