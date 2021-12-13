*** Settings ***
Documentation   Sort cloudlets

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
	
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           15 min
	
*** Test Cases ***
WebUI - user shall be able to sort cloudlets by cloudlet name
   [Documentation]
   ...  Show all cloudlets
   ...  sort by cloudlet name
   ...  Get all cloudlets from WS
   ...  Verify all cloudlets are sorted properly

   Open Cloudlets

   #
   # sort ascending
   #
   @{ws_asc}=  Show All Cloudlets  sort_field=cloudlet_name  sort_order=ascending
   ${num_cloudlets_ws_asc}=     Get Length  ${ws_asc}

   Sort Cloudlets By Cloudlet Name
	
   @{table_rows_asc}=  Get Table Data
   ${num_cloudlets_table_asc}=  Get Length  ${table_rows_asc}

   ${counter}=  Set Variable  0
   : FOR  ${row}  IN  @{ws_asc}
   \  Log To Console  ${row}
   \  Log To Console  ${table_rows_asc[${counter}]}
   \  Should Be Equal  ${row['data']['region']}  ${table_rows_asc[${counter}][1]}
   \  Should Be Equal  ${row['data']['key']['name']}  ${table_rows_asc[${counter}][2]}
   \  Should Be Equal  ${row['data']['key']['organization']}  ${table_rows_asc[${counter}][3]}
#   \  ${location}=  Catenate  SEPARATOR=\n  Latitude : ${row['data']['location']['latitude']}  Longitude : ${row['data']['location']['longitude']}
#   \  Should Be Equal  ${location}  ${table_rows_asc[${counter}][3]}
   \  ${counter}=  Evaluate  ${counter} + 1
	
   Should Be Equal  ${num_cloudlets_ws_asc}  ${num_cloudlets_table_asc}


   #
   # sort descending
   #
   @{ws_desc}=  Show All Cloudlets  sort_field=cloudlet_name  sort_order=descending
   ${num_cloudlets_ws_desc}=     Get Length  ${ws_desc}

   Sort Cloudlets By Cloudlet Name
	
   @{table_rows_desc}=  Get Table Data
   ${num_cloudlets_table_desc}=  Get Length  ${table_rows_desc}

   ${counter}=  Set Variable  0
   : FOR  ${row}  IN  @{ws_desc}
   \  Log To Console  ${row}
   \  Log To Console  ${table_rows_desc[${counter}]}
   \  Should Be Equal  ${row['data']['region']}  ${table_rows_desc[${counter}][1]}
   \  Should Be Equal  ${row['data']['key']['name']}  ${table_rows_desc[${counter}][2]}
   \  Should Be Equal  ${row['data']['key']['organization']}  ${table_rows_desc[${counter}][3]}
#   \  ${location}=  Catenate  SEPARATOR=\n  Latitude : ${row['data']['location']['latitude']}  Longitude : ${row['data']['location']['longitude']}
#   \  Should Be Equal  ${location}  ${table_rows_desc[${counter}][3]}
   \  ${counter}=  Evaluate  ${counter} + 1
	
   Should Be Equal  ${num_cloudlets_ws_desc}  ${num_cloudlets_table_desc}

WebUI - user shall be able to sort cloudlets by region
   [Documentation]
   ...  Show US cloudlets
   ...  sort by cloudlet name
   ...  Get US cloudlets from WS
   ...  Verify all cloudlets are sorted properly

   # EDGECLOUD-1106 Mex Console - Cloudlet sorts should use Clouldet Name as the secondary sort.
   
   Open Cloudlets

   #
   # sort ascending
   #
   @{ws_asc}=  Show All Cloudlets  sort_field=region  sort_order=ascending
   ${num_cloudlets_ws_asc}=     Get Length  ${ws_asc}

   Sort Cloudlets By Region
	
   @{table_rows_asc}=  Get Table Data
   ${num_cloudlets_table_asc}=  Get Length  ${table_rows_asc}

   ${counter}=  Set Variable  0
   : FOR  ${row}  IN  @{ws_asc}
   \  Log To Console  ${row}
   \  Log To Console  ${table_rows_asc[${counter}]}
   \  Should Be Equal  ${row['data']['region']}  ${table_rows_asc[${counter}][1]}
   \  Should Be Equal  ${row['data']['key']['name']}  ${table_rows_asc[${counter}][2]}
   \  Should Be Equal  ${row['data']['key']['organization']}  ${table_rows_asc[${counter}][3]}
#   \  ${location}=  Catenate  SEPARATOR=\n  Latitude : ${row['data']['location']['latitude']}  Longitude : ${row['data']['location']['longitude']}
#   \  Should Be Equal  ${location}  ${table_rows_asc[${counter}][3]}
   \  ${counter}=  Evaluate  ${counter} + 1
	
   Should Be Equal  ${num_cloudlets_ws_asc}  ${num_cloudlets_table_asc}


   #
   # sort descending
   #
   @{ws_desc}=  Show All Cloudlets  sort_field=region  sort_order=descending
   ${num_cloudlets_ws_desc}=     Get Length  ${ws_desc}

   Sort Cloudlets By Region
	
   @{table_rows_desc}=  Get Table Data
   ${num_cloudlets_table_desc}=  Get Length  ${table_rows_desc}

   ${counter}=  Set Variable  0
   : FOR  ${row}  IN  @{ws_desc}
   \  Log To Console  ${row}
   \  Log To Console  ${table_rows_desc[${counter}]}
   \  Should Be Equal  ${row['data']['region']}  ${table_rows_desc[${counter}][1]}
   \  Should Be Equal  ${row['data']['key']['name']}  ${table_rows_desc[${counter}][2]}
   \  Should Be Equal  ${row['data']['key']['organization']}  ${table_rows_desc[${counter}][3]}
#   \  ${location}=  Catenate  SEPARATOR=\n  Latitude : ${row['data']['location']['latitude']}  Longitude : ${row['data']['location']['longitude']}
#   \  Should Be Equal  ${location}  ${table_rows_desc[${counter}][3]}
   \  ${counter}=  Evaluate  ${counter} + 1
	
   Should Be Equal  ${num_cloudlets_ws_desc}  ${num_cloudlets_table_desc}



*** Keywords ***
Setup
    #create some flavors
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning
