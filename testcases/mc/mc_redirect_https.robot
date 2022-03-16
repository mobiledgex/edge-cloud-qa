*** Settings ***
Documentation   MasterController http redirect
	
Library  RequestsLibrary

*** Variables ***
${address}=  console-qa.mobiledgex.net

${url}=      http://${address}
${url_api}=  http://${address}/api

${url_https}=      https://${address}/
${url_api_https}=  https://${address}/api
	
*** Test Cases ***
# ECQ-4426
MC - HTTP requests shall redirect to HTTPS
    [Documentation]
    ...  - send http request to console
    ...  - verify it redirects to https

    # post baseurl
    ${resp_post}=  Post  ${url}  allow_redirects=${False}
    Status Should Be  301  ${resp_post}
    Should Be Equal  ${resp_post.headers['location']}  ${url_https}

    # get to baseurl
    ${resp_get}=  Get  ${url}  allow_redirects=${False}
    Status Should Be  301  ${resp_get}
    Should Be Equal  ${resp_get.headers['location']}  ${url_https}

    # post to baseurl/api
    ${resp_post_api}=  Post  ${url_api}  allow_redirects=${False}
    Status Should Be  301  ${resp_post_api}
    Should Be Equal  ${resp_post_api.headers['location']}  ${url_api_https}

    # get to baseurl/api
    ${resp_get_api}=  Get  ${url_api}  allow_redirects=${False}
    Status Should Be  301  ${resp_get_api}
    Should Be Equal  ${resp_get_api.headers['location']}  ${url_api_https}

    # post baseurl/
    ${resp_post}=  Post  ${url}/  allow_redirects=${False}
    Status Should Be  301  ${resp_post}
    Should Be Equal  ${resp_post.headers['location']}  ${url_https}

    # get to baseurl/
    ${resp_get}=  Get  ${url}/  allow_redirects=${False}
    Status Should Be  301  ${resp_get}
    Should Be Equal  ${resp_get.headers['location']}  ${url_https}

    # post to baseurl/api/
    ${resp_post_api}=  Post  ${url_api}/  allow_redirects=${False}
    Status Should Be  301  ${resp_post_api}
    Should Be Equal  ${resp_post_api.headers['location']}  ${url_api_https}/

    # get to baseurl/api/
    ${resp_get_api}=  Get  ${url_api}/  allow_redirects=${False}
    Status Should Be  301  ${resp_get_api}
    Should Be Equal  ${resp_get_api.headers['location']}  ${url_api_https}/

