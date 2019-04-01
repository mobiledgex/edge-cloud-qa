*** Settings ***
Documentation	Start DME Failures

Library		MexProcess

*** Variables ***
${dme_api_address}  127.0.0.1:65101
${cloudlet_name}  automationBonncloudlet
${operator_name}  tdg

*** Test Cases ***
DME shall fail to start when cert is not found 
      Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  certificate=xx
      DME Log File Should Contain  get TLS Credentials 

DME shall fail to start without cloudlet name
      Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}  operator_name=${operator_name}
      DME Log File Should Contain  Invalid cloudletKey

DME shall fail to start without cloudlet operator name
      Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}  cloudlet_name=${cloudlet_name} 
      DME Log File Should Contain   Invalid cloudletKey

DME shall fail to start without cloudletKey parm
      Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}
      DME Log File Should Contain  cloudletKey not specified

DME shall fail to start with invalid cloudletKey
      Run Keyword and Expect Error  *  Start DME  carrier=${cloudlet_name}  cloudlet_key=xx
      DME Log File Should Contain  Failed to parse cloudletKey

DME shall fail to start without carrier parm
      Run Keyword and Expect Error  *  Start DME  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  certificate=xx
      DME Log File Should Contain  carrier not specified  timeout=10

