*** Settings ***
Documentation   Sort Clusters
#Region descending not working
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
Web UI - user shall be able to sort cluster instances by cluster name
   [Documentation]
   ...  Show all cluster instances
   ...  Sort by cluster name
   ...  Get all clusters from WS
   ...  Verify all clusters are sorted properly

   Open Cluster Instances

   #
   # sort ascending
   #
   @{ws_asc}=  Show All Cluster Instances  sort_field=cluster_name  sort_order=ascending
   ${num_clusters_ws_asc}=     Get Length  ${ws_asc}

   Sort Clusters By Cluster Name
	
   @{table_rows_asc}=  Get Table Data
   ${num_clusters_table_asc}=  Get Length  ${table_rows_asc}

   ${counter}=  Set Variable  0
   FOR  ${row}  IN  @{ws_asc}
      Log To Console  ${row}
      Log To Console  ${table_rows_asc[${counter}]}
      Should Be Equal  ${row['data']['region']}  ${table_rows_asc[${counter}][0]}
      Should Be Equal  ${row['data']['key']['cluster_key']['name']}  ${table_rows_asc[${counter}][1]}
      Should Be Equal  ${row['data']['key']['organization']}  ${table_rows_asc[${counter}][2]}
      Should Be Equal  ${row['data']['key']['cloudlet_key']['organization']}  ${table_rows_asc[${counter}][3]}
      ${counter}=  Evaluate  ${counter} + 1
   END
	
   Should Be Equal  ${num_clusters_ws_asc}  ${num_clusters_table_asc}


   #
   # sort descending
   #
   @{ws_desc}=  Show All Cluster Instances  sort_field=cluster_name  sort_order=descending
   ${num_clusters_ws_desc}=     Get Length  ${ws_desc}

   Sort Clusters By Cluster Name
	
   @{table_rows_desc}=  Get Table Data
   ${num_clusters_table_desc}=  Get Length  ${table_rows_desc}

   ${counter}=  Set Variable  0
   FOR  ${row}  IN  @{ws_desc}
      Log To Console  ${row}
      Log To Console  ${table_rows_desc[${counter}]}
      Should Be Equal  ${row['data']['region']}  ${table_rows_desc[${counter}][0]}
      Should Be Equal  ${row['data']['key']['cluster_key']['name']}  ${table_rows_desc[${counter}][1]}
      Should Be Equal  ${row['data']['key']['organization']}  ${table_rows_desc[${counter}][2]}
      Should Be Equal  ${row['data']['key']['cloudlet_key']['organization']}  ${table_rows_desc[${counter}][3]}
      ${counter}=  Evaluate  ${counter} + 1
   END
	
   Should Be Equal  ${num_clusters_ws_desc}  ${num_clusters_table_desc}

Web UI - user shall be able to sort clusters by region
   [Documentation]
   ...  Show US clusters
   ...  Sort by cluster name
   ...  Get US clusters from WS
   ...  Verify all clusters are sorted properly

   Open Cluster Instances

   #
   # sort ascending
   #
   @{ws_asc}=  Show All Cluster Instances  sort_field=region  sort_order=ascending
   ${num_clusters_ws_asc}=     Get Length  ${ws_asc}

   Sort Clusters By Region
	
   @{table_rows_asc}=  Get Table Data
   ${num_clusters_table_asc}=  Get Length  ${table_rows_asc}

   ${counter}=  Set Variable  0
   FOR  ${row}  IN  @{ws_asc}
      Log To Console  ${row}
      Log To Console  ${table_rows_asc[${counter}]}
      Should Be Equal  ${row['data']['region']}  ${table_rows_asc[${counter}][0]}
      Should Be Equal  ${row['data']['key']['cluster_key']['name']}  ${table_rows_asc[${counter}][1]}
      Should Be Equal  ${row['data']['key']['organization']}  ${table_rows_asc[${counter}][2]}
      Should Be Equal  ${row['data']['key']['cloudlet_key']['organization']}  ${table_rows_asc[${counter}][3]}
      ${counter}=  Evaluate  ${counter} + 1
   END
	
   Should Be Equal  ${num_clusters_ws_asc}  ${num_clusters_table_asc}


   #
   # sort descending
   #
   @{ws_desc}=  Show All Cluster Instances  sort_field=region  sort_order=descending
   ${num_clusters_ws_desc}=     Get Length  ${ws_desc}

   Sort Clusters By Region
	
   @{table_rows_desc}=  Get Table Data
   ${num_clusters_table_desc}=  Get Length  ${table_rows_desc}

   ${counter}=  Set Variable  0
   FOR  ${row}  IN  @{ws_desc}
      Log To Console  ${row}
      Log To Console  ${table_rows_desc[${counter}]}
      Should Be Equal  ${row['data']['region']}  ${table_rows_desc[${counter}][0]}
      Should Be Equal  ${row['data']['key']['cluster_key']['name']}  ${table_rows_desc[${counter}][1]}
      Should Be Equal  ${row['data']['key']['organization']}  ${table_rows_desc[${counter}][2]}
      Should Be Equal  ${row['data']['key']['cloudlet_key']['organization']}  ${table_rows_desc[${counter}][3]}
      ${counter}=  Evaluate  ${counter} + 1
   END
	
   Should Be Equal  ${num_clusters_ws_desc}  ${num_clusters_table_desc}



*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning
