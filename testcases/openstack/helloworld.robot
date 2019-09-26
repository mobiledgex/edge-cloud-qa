*** Settings ***
Documentation  Hello World

*** Variables ***
${hello_world_variable}=  Hello World

*** Test Cases ***
Print Hello World to the console
    [Documentation]
    ...  This will print hello world to the console
    ...  It will also verify the hello_world_variable is correct 

    Log To Console  I am printing Hello World to the console
    Should Be Equal  ${hello_world_variable}   Hello World 
