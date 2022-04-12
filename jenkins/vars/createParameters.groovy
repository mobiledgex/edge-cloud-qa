// Copyright 2022 MobiledgeX, Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

def call() {
    return [
        string(name: 'BuildDate', defaultValue: 'today', description: 'YYYY-MM-DD or "today"')
        string(name: 'Project', defaultValue: 'ECQ')
        string(name: 'Version', defaultValue: 'CirrusR3.1')
        string(name: 'MasterController', defaultValue: 'console-qa.mobiledgex.net:443')
        string(name: 'MasterControllerFederation', defaultValue: 'console-dev.mobiledgex.net:443')
        string(name: 'MasterControllerFederationPassword', defaultValue: 'mexadmin123')
        string(name: 'Controller', defaultValue: 'mexplat-qa-us.ctrl.mobiledgex.net:55001')
        string(name: 'DME', defaultValue: 'us-qa.dme.mobiledgex.net:50051')
        string(name: 'DMERest', defaultValue: 'us-qa.dme.mobiledgex.net:38001')
        string(name: 'DMERestCert', defaultValue: '')
        string(name: 'Console', defaultValue: 'https://console-qa.mobiledgex.net')
        string(name: 'CRMPoolOpenstack', defaultValue: '{"cloudlet_name_crm":[{"cloudlet":"automationBonnCloudlet","operator":"TDG","region":"US","physical_name":"bonn"},{"cloudlet":"packet-qaregression","operator":"packet","region":"US","physical_name":"packet2"}]}')
        string(name: 'CRMPoolAnthos', defaultValue: '{"cloudlet_name_crm":[{"cloudlet":"qa-anthos","operator":"packet","region":"US","physical_name":"qa-anthos"}]}')
        string(name: 'CRMPoolVCD', defaultValue: '{"cloudlet_name_crm":[{"cloudlet":"automationDallasCloudlet","operator":"packet","region":"US","physical_name":"qa2-lab"}]}')
        string(name: 'CRMPoolVsphere', defaultValue: '{"cloudlet_name_crm":[{"cloudlet":"DFWVMW2","operator":"packet","region":"US","physical_name":"dfw2"}]}')
        string(name: 'NumberParallelExecutionsOpenstack', defaultValue: '2')
        string(name: 'NumberParallelExecutionsAnthos', defaultValue: '2')
        string(name: 'NumberParallelExecutionsVCD', defaultValue: '2')
        string(name: 'NumberParallelExecutionsVsphere', defaultValue: '2')
        string(name: 'VariableFile', defaultValue: 'automation_variables.py')
        string(name: 'InfluxDB', defaultValue: 'notset')
        string(name: 'OpenStackEnv', defaultValue: 'notset')
        string(name: 'CommitVersion', defaultValue: 'master')
        booleanParam(name: 'RunFailedOnly', defaultValue: false)
        string(name: 'SlaveNodeSDK', defaultValue: 'jenkinsSlave1')
        string(name: 'SlaveNodeDME', defaultValue: 'jenkinsSlave1')
        string(name: 'SlaveNodeController', defaultValue: 'jenkinsSlave1')
        string(name: 'SlaveNodeMasterController', defaultValue: 'jenkinsSlave1')
        string(name: 'SlaveNodeScans', defaultValue: 'jenkinsSlave1')
        string(name: 'SlaveNodeOpenstack', defaultValue: 'jenkinsGcpSlave1')
        string(name: 'SlaveNodeVCD', defaultValue: 'jenkinsGcpSlave2')
        string(name: 'SlaveNodeVsphere', defaultValue: 'jenkinsSlave2')
        string(name: 'SlaveNodeAnthos', defaultValue: 'jenkinsSlave1')
        string(name: 'SlaveNodeConsole', defaultValue: 'jenkinsWindowsSelenium')
        string(name: 'SlaveNodeMetrics', defaultValue: 'jenkinsSlave1')
        string(name: 'SlaveNodeFRM', defaultValue: 'jenkinsSlave1')
        string(name: 'TestTimeoutSDK', defaultValue: '5m')
        string(name: 'TestTimeoutController', defaultValue: '4m')
        string(name: 'TestTimeoutMasterController', defaultValue: '4m')
        string(name: 'TestTimeoutDME', defaultValue: '2m')
        string(name: 'TestTimeoutFRM', defaultValue: '2m')
        booleanParam(name: 'RunDeploy', defaultValue: true)
        booleanParam(name: 'RunControllerTests', defaultValue: true)
        booleanParam(name: 'RunMCTests', defaultValue: true)
        booleanParam(name: 'RunDMETests', defaultValue: true)
        booleanParam(name: 'RunSDKTests', defaultValue: true)
        booleanParam(name: 'RunOpenstackTests', defaultValue: true)
        booleanParam(name: 'RunVCDTests', defaultValue: true)
        booleanParam(name: 'RunVsphereTests', defaultValue: true)
        booleanParam(name: 'RunAnthosTests', defaultValue: true)
        booleanParam(name: 'RunMetricsTests', defaultValue: true)
        booleanParam(name: 'RunFRMTests', defaultValue: true)
        booleanParam(name: 'RunScanTests', defaultValue: true)
        booleanParam(name: 'RunConsoleTests', defaultValue: true)
        booleanParam(name: 'RunPerformanceTests', defaultValue: true)
        booleanParam(name: 'RunFailedTests', defaultValue: true)
        //choice(name: 'Platform', choices: ['SDK', 'Controller', 'DME', 'Openstack', 'VCD', 'Vshpere', 'Anthos'], description: '')
        //string(name: 'Area', defaultValue: 'flavor')
        ),
    ]
}
