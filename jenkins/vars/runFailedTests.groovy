def call(cycle) {
//    stages {
        stage('Run MC Failed Tests') {
            build job: 'runTestcases', parameters: [
                string(name: 'Components', value: 'Automated'),
                string(name: 'Project', value: params.Project),
                string(name: 'Cycle', value: cycle),
                string(name: 'MasterController', value: params.MasterController),
                string(name: 'TestTarget', value: 'MasterController'),
                string(name: 'VariableFile', value: params.VariableFile),
                string(name: 'NumberParallelExecutions', value: '1')]
        }
//    }
}

