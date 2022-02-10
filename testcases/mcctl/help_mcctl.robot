*** Settings ***
Documentation  mcctl help

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Timeout  10m

*** Variables ***
${version}=  latest

*** Test Cases ***
# ECQ-2854
Mcctl - mcctl commands shall not contain a dash
    [Documentation]
    ...  - iterate thru all mcctl commands
    ...  - verify no commands contain a dash

    ${t}=  Run mcctl  parms=-h  output_format=${None}  version=${version}

    @{toplevel_cmds}=  Get Help Commands  ${t}

    FOR  ${c}  IN  @{toplevel_cmds}
        Log To Console  Verifying ${c}
        ${h}=  Run Keyword And Expect Error  *  Run mcctl  parms=${c} -h  output_format=${None}  version=${version}
        Should Contain  ${h}  Usage: mcctl ${c}
        Should Not Contain  ${c}  -

        ${bool}=  Run Keyword and Return Status  Should Contain  ${h}  Available Commands
        IF  ${bool}
            @{sub_cmds}=  Get Help Commands  ${h}
            FOR  ${s}  IN  @{sub_cmds}
                Log To Console  Verifying ${c} ${s}
                ${hs}=  Run Keyword And Expect Error  *  Run mcctl  parms=${c} ${s} -h  output_format=${None}  version=${version}
                Should Contain  ${hs}  Usage: mcctl ${c} ${s}
                Should Not Contain  ${s}  -
            END
       END
    END
 
*** Keywords ***
Get Help Commands
    [Arguments]  ${output}

    ${output}=  Replace String  ${output}  \\n  \n
    ${commands_match}=  Get Lines Matching Regexp  ${output}  pattern=^\\s{2}[a-z]  partial_match=${True}
    ${commands_split}=  Split To Lines  ${commands_match}

    @{commands}=  Create List
    FOR  ${c}  IN  @{commands_split}
        @{command}=  Split String  ${c}
        Append To List  ${commands}  ${command[0]}
    END

    [Return]  ${commands} 
