def call(cycle) {
    stage('MC') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated'),
            string(name: 'Project', value: params.Project),
            string(name: 'Cycle', value: cycle),
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'MasterController'),
            string(name: 'VariableFile', value: params.VariableFile),
            string(name: 'NumberParallelExecutions', value: '1')]
    }

    stage('Controller') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated'),
            string(name: 'Project', value: params.Project),
            string(name: 'Cycle', value: cycle),
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'Controller'),
            string(name: 'VariableFile', value: params.VariableFile),
            string(name: 'NumberParallelExecutions', value: '1')]
    }

    stage('DME') {
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

