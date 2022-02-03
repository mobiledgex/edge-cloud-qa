def call(cycle) {
    stage('MC') {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Rerun MC tests failed') {
            build job: 'runTestcases', parameters: [
                string(name: 'Components', value: 'Automated'),
                string(name: 'Project', value: params.Project),
                string(name: 'Cycle', value: cycle),
                string(name: 'MasterController', value: params.MasterController),
                string(name: 'TestTarget', value: 'MasterController'),
                string(name: 'VariableFile', value: params.VariableFile),
                string(name: 'NumberParallelExecutions', value: '1')]
        }
    }

    stage('Controller') {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Rerun Controller tests failed') {
            build job: 'runTestcases', parameters: [
                string(name: 'Components', value: 'Automated'),
                string(name: 'Project', value: params.Project),
                string(name: 'Cycle', value: cycle),
                string(name: 'MasterController', value: params.MasterController),
                string(name: 'TestTarget', value: 'Controller'),
                string(name: 'VariableFile', value: params.VariableFile),
                string(name: 'NumberParallelExecutions', value: '1')]
        }
    }

    stage('DME') {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'Rerun DME tests failed') {
            build job: 'runTestcases', parameters: [
                string(name: 'Components', value: 'Automated'),
                string(name: 'Project', value: params.Project),
                string(name: 'Cycle', value: cycle),
                string(name: 'MasterController', value: params.MasterController),
                string(name: 'TestTarget', value: 'DME'),
                string(name: 'VariableFile', value: params.VariableFile),
                string(name: 'NumberParallelExecutions', value: '1')]
        }
    }
}

