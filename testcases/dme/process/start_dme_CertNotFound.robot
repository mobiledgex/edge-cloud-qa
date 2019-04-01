*** Settings ***
Documentation	Start DME Failures

Library		MexProcess

*** Variables ***
${dme_api_address}  127.0.0.1:65101
${cloudlet_name}  automationBonncloudlet
${operator_name}  tdg

*** Test Cases ***
DME shall fail to start when cert is not found 
   [Documentation]
   ...  Start DME with a cert that doesnt exist
   ...  Verify proper error shows in log

   Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  certificate=xx
   DME Log File Should Contain  get TLS Credentials 

DME shall fail to start without cloudlet name
   [Documentation]
   ...  Start DME without cloudlet name in cloudletKey
   ...  Verify proper error shows in log

   Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}  operator_name=${operator_name}
   DME Log File Should Contain  Invalid cloudletKey

DME shall fail to start without cloudlet operator name
   [Documentation]
   ...  Start DME without operator name in cloudletKey
   ...  Verify proper error shows in log

   Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}  cloudlet_name=${cloudlet_name} 
   DME Log File Should Contain   Invalid cloudletKey

DME shall fail to start without cloudletKey parm
   [Documentation]
   ...  Start DME without cloudletKey parm
   ...  Verify proper error shows in log

   Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}
   DME Log File Should Contain  cloudletKey not specified

DME shall fail to start with invalid cloudletKey
   [Documentation]
   ...  Start DME with invalid json cloudletKey parm
   ...  Verify proper error shows in log

   Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}  cloudlet_key=xx
   DME Log File Should Contain  Failed to parse cloudletKey

DME shall fail to start without carrier parm
   [Documentation]
   ...  Start DME without operator parm
   ...  Verify proper error shows in log

   Run Keyword and Expect Error  *  Start DME  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
   DME Log File Should Contain  carrier not specified  timeout=10

