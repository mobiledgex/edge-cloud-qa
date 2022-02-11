def call() {
    parallel {
        stage('SDK Tests') {
            when { expression { params.runSDKTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'SDK tests failed') {
                    script { slackMessage.good('Starting SDK tests') }
                    build job: 'runSdkTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeSDK),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'TestTarget', value: 'SDK'),
                        string(name: 'TestTimeout', value: params.TestTimeoutSDK),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run SDK tests failed"
                        slackMessage.fail('Finished SDK tests with failures')
                    }
                }
                success {
                    script {
                        echo "run SDK tests passed"
                        slackMessage.good('Finished SDK tests with pass')
                    }
                }
            }
        }
        stage('DME Tests') {
            when { expression { params.runDMETests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'DME tests failed') {
                    script { slackMessage.good('Starting DME tests') }
                    build job: 'runDmeTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeDME),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'Controller', value: params.Controller),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'DME', value: params.DME),
                        string(name: 'DMERest', value: params.DMERest),
                        string(name: 'DMERestCert', value: params.DMERestCert),
                        string(name: 'TestTarget', value: 'DME'),
                        string(name: 'VariableFile', value: params.VariableFile),
                        string(name: 'TestTimeout', value: params.TestTimeoutDME),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run DNE tests failed"
                        slackMessage.fail('Finished DME tests with failures')
                    }
                }
                success {
                    script {
                        echo "run DME tests passed"
                        slackMessage.good('Finished DME tests with pass')
                    }
                }
            }
        }
        stage('Controller Tests') {
            when { expression { params.runControllerTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Controller tests failed') {
                    script { slackMessage.good('Starting Controller Tests') }
                    build job: 'runControllerTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeController),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'Controller', value: params.Controller),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'DME', value: params.DME),
                        string(name: 'DMERest', value: params.DMERest),
                        string(name: 'DMERestCert', value: params.DMERestCert),
                        string(name: 'TestTarget', value: 'Controller'),
                        string(name: 'VariableFile', value: params.VariableFile),
                        string(name: 'TestTimeout', value: params.TestTimeoutController),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run Controller tests failed"
                        slackMessage.fail('Finished Controller tests with failures')
                    }
                }
                success {
                    script {
                        echo "run Controller tests passed"
                        slackMessage.good('Finished Controller tests with pass')
                    }
                }
            }
        }

        stage('MasterController Tests') {
            when { expression { params.runMCTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'MC tests failed') {
                    script { slackMessage.good('Starting MasterController tests') }
                    build job: 'runMcTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeMasterController),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'TestTarget', value: 'MasterController'),
                        string(name: 'VariableFile', value: params.VariableFile),
                        string(name: 'TestTimeout', value: params.TestTimeoutMasterController),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run MasterController tests failed"
                        slackMessage.fail('Finished MasterController tests with failures')
                    }
                }
                success {
                    script {
                        echo "run MasterController tests passed"
                        slackMessage.good('Finished MasterController tests with pass')
                    }
                }
            }
        }
        stage('FRM Tests') {
            when { expression { params.runFRMTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'FRM tests failed') {
                    script { slackMessage.good('Starting FRM tests') }
                    build job: 'runFrmTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeFRM),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'MasterControllerFederation', value: params.MasterControllerFederation),
                        string(name: 'MasterControllerFederationPassword', value: params.MasterControllerFederationPassword),
                        string(name: 'TestTarget', value: 'FRM'),
                        string(name: 'VariableFile', value: params.VariableFile),
                        string(name: 'TestTimeout', value: params.TestTimeoutFRM),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run FRM tests failed"
                        slackMessage.fail('Finished FRM tests with failures')
                    }
                }
                success {
                    script {
                        echo "run FRM tests passed"
                        slackMessage.good('Finished FRM tests with pass')
                    }
                }
            }
        }

        stage('Anthos Tests') {
            when { expression { params.runAnthosTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Anthos tests failed') {
                    script { slackMessage.good('Starting Anthos tests') }
                    build job: 'runCrmTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeAnthos),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'Controller', value: params.Controller),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'DME', value: params.DME),
                        string(name: 'DMERest', value: params.DMERest),
                        string(name: 'DMERestCert', value: params.DMERestCert),
                        string(name: 'TestTarget', value: 'Anthos'),
                        string(name: 'VariableFile', value: params.VariableFile),
                        string(name: 'CRMPool', value: params.CRMPoolAnthos),
                        string(name: 'NumberParallelExecutions', value: params.NumberParallelExecutionsAnthos),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run Anthos tests failed"
                        slackMessage.fail('Finished Anthos tests with failures')
                    }
                }
                success {
                    script {
                        echo "run Anthos tests passed"
                        slackMessage.good('Finished Anthos tests with pass')
                    }
                }
            }
        }
        stage('Vsphere Tests') {
            when { expression { params.runVsphereTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Vsphere tests failed') {
                    script { slackMessage.good('Starting Vsphere tests') }
                    build job: 'runCrmTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeVsphere),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'Controller', value: params.Controller),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'DME', value: params.DME),
                        string(name: 'DMERest', value: params.DMERest),
                        string(name: 'DMERestCert', value: params.DMERestCert),
                        string(name: 'TestTarget', value: 'Vsphere'),
                        string(name: 'VariableFile', value: params.VariableFile),
                        string(name: 'CRMPool', value: params.CRMPoolVsphere),
                        string(name: 'NumberParallelExecutions', value: params.NumberParallelExecutionsVsphere),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run Vsphere tests failed"
                        slackMessage.fail('Finished Vsphere tests with failures')
                    }
                }
                success {
                    script {
                        echo "run Vsphere tests passed"
                        slackMessage.good('Finished Vsphere tests with pass')
                    }
                }
            }
        }
        stage('VCD Tests') {
            when { expression { params.runVCDTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'VCD tests failed') {
                    script { slackMessage.good('Starting VCD tests') }
                    build job: 'runCrmTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeVCD),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'Controller', value: params.Controller),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'DME', value: params.DME),
                        string(name: 'DMERest', value: params.DMERest),
                        string(name: 'DMERestCert', value: params.DMERestCert),
                        string(name: 'TestTarget', value: 'VCD'),
                        string(name: 'VariableFile', value: params.VariableFile),
                        string(name: 'CRMPool', value: params.CRMPoolVCD),
                        string(name: 'NumberParallelExecutions', value: params.NumberParallelExecutionsVCD),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run VCD tests failed"
                        slackMessage.fail('Finished VCD tests with failures')
                    }
                }
                success {
                    script {
                        echo "run VCD tests passed"
                        slackMessage.good('Finished VCD tests with pass')
                    }
                }
            }
        }
        stage('Openstack Tests') {
            when { expression { params.runOpenstackTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Openstack tests failed') {
                    script { slackMessage.good('Starting Openstack tests') }
                    build job: 'runCrmTestcases', parameters: [
                        string(name: 'SlaveNode', value: params.SlaveNodeOpenstack),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Cycle', value: cycle),
                        string(name: 'Controller', value: params.Controller),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'DME', value: params.DME),
                        string(name: 'DMERest', value: params.DMERest),
                        string(name: 'DMERestCert', value: params.DMERestCert),
                        string(name: 'TestTarget', value: 'Openstack'),
                        string(name: 'VariableFile', value: params.VariableFile),
                        string(name: 'CRMPool', value: params.CRMPoolOpenstack),
                        string(name: 'NumberParallelExecutions', value: params.NumberParallelExecutionsOpenstack),
                        booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]
                }
            }
            post {
                failure {
                    script {
                        echo "run Openstack tests failed"
                        slackMessage.fail('Finished Openstack tests with failures')
                    }
                }
                success {
                    script {
                        echo "run Openstack tests passed"
                        slackMessage.good('Finished Openstack tests with pass')
                    }
                }
            }
        }
        stage('Scans') {
            when { expression { params.runScanTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Scans failed') {
                    script { slackMessage.good('Starting scan tests') }
                    build job: 'runScans', parameters: [
                        string(name: 'Cycle', value: cycle),
                        string(name: 'SlaveNode', value: params.SlaveNodeScans)
                        ]
                }
            }
            post {
                failure {
                    script {
                        echo "run scan tests failed"
                        slackMessage.fail('Finished scan tests with failures')
                    }
                }
                success {
                    script {
                        echo "run scan tests passed"
                        slackMessage.good('Finished scan tests with pass')
                    }
                }
            }
        }
        stage('Console') {
            when { expression { params.runConsoleTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Console tests failed') {
                script { slackMessage.good('Starting Console tests') }
                    build job: 'runConsoleTestcases', parameters: [
                        string(name: 'Cycle', value: cycle),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Console', value: params.Console),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'TestTarget', value: 'WebUI'),
                        string(name: 'SlaveNode', value: params.SlaveNodeConsole)
                        ]
                }
            }
            post {
                failure {
                    script {
                        echo "run console tests failed"
                        slackMessage.fail('Finished Console tests with failures')
                    }
                }
                success {
                    script {
                        echo "run console tests passed"
                        slackMessage.good('Finished Console tests with pass')
                    }
                }
            }
        }

        stage('Metrics') {
            when { expression { params.runMetricsTests == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Metrics tests failed') {
                    script { slackMessage.good('Starting Metrics tests') }
                    build job: 'runMetricsTestcases', parameters: [
                        string(name: 'Cycle', value: cycle),
                        string(name: 'Project', value: params.Project),
                        string(name: 'Console', value: params.Console),
                        string(name: 'MasterController', value: params.MasterController),
                        string(name: 'TestTarget', value: 'Metrics'),
                        string(name: 'SlaveNode', value: params.SlaveNodeMetrics)
                        ]
                }
            }
            post {
                failure {
                    script {
                        echo "run console tests failed"
                        slackMessage.fail('Finished Console tests with failures')
                    }
                }
                success {
                    script {
                        echo "run console tests passed"
                        slackMessage.good('Finished Console tests with pass')
                    }
                }
            }
        }
    }
}

