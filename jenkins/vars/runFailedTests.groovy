def call(cycle) {
    stage('MC') {
        when { expression { params.runMCTests == true } }
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Rerun MC tests failed') {
            build job: 'runMcTestcases', parameters: [
                string(name: 'SlaveNode', value: params.SlaveNodeMasterController),
                string(name: 'Project', value: params.Project),
                string(name: 'Cycle', value: cycle),
                string(name: 'MasterController', value: params.MasterController),
                string(name: 'TestTarget', value: 'MasterController'),
                string(name: 'VariableFile', value: params.VariableFile),
                string(name: 'TestTimeout', value: params.TestTimeoutMasterController),
                booleanParam(name: 'RunFailedOnly', value: '1')]
        }
    }

    stage('Controller') {
        when { expression { params.runControllerTests == true } }
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Rerun Controller tests failed') {
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
                booleanParam(name: 'RunFailedOnly', value: '1')]
        }
    }

    stage('DME') {
        when { expression { params.runDMETests == true } }
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Rerun DME tests failed') {
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
                booleanParam(name: 'RunFailedOnly', value: '1')]
        }
    }
}

