### GetFqdnList Testcases
* GetFqdnList request shall return 10 apps - getFqdnList_10app.robot
* GetFqdnList request shall return 0 apps - getFqdnList_0app.robot
* GetFqdnList request shall return 1 app - getFqdnList_1app.robot
* GetFqdnList request for apps with permits_platform_apps=False shall return 0 apps - getFqdnList_0appPermitFalse.robot
* GetFqdnList request for apps with no permits_platform_apps shall return 0 apps - getFqdnList_0appPermitNone.robot
* GetFqdnList request shall only return apps with permits_platform_apps=True - getFqdnList_permitMixture.robot
* getFqdnList with various cookie errors - getFqdnList_cookieError.robot
* getFqdnList for non-samsung app should fail - getFqdnList_nonSamsung.robot
