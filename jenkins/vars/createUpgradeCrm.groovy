def openstack(cycle) {
    print('create openstack ')
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'create openstack failed') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated, CRM, CreateCloudlet'), 
            string(name: 'Project', value: params.Project), 
            string(name: 'Cycle', value: cycle), 
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'Openstack'),
            string(name: 'VariableFile', value: params.VariableFile), 
            string(name: 'NumberParallelExecutions', value: '10')]
    }
}

def anthos(cycle) {
    print('create anthos ')
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'create anthos failed') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated, CRM, CreateCloudlet'), 
            string(name: 'Project', value: params.Project), 
            string(name: 'Cycle', value: cycle), 
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'Anthos'),
            string(name: 'VariableFile', value: params.VariableFile), 
            string(name: 'NumberParallelExecutions', value: '10')]
    }
}

def fake(cycle) {
    print('create fake ')
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'create fake failed') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated, CRM, CreateCloudlet'), 
            string(name: 'Project', value: params.Project), 
            string(name: 'Cycle', value: cycle), 
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'Controller'),
            string(name: 'VariableFile', value: params.VariableFile), 
            string(name: 'NumberParallelExecutions', value: '10')]
    }
}

def upgrade(cycle, dateValue) {
    print('upgrade cloudlets')
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'upgrade CRM failed') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated, CRM, UpgradeCloudlet'),
            string(name: 'Project', value: params.Project),
            string(name: 'Cycle', value: cycle),
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'Openstack'),
            string(name: 'VariableFile', value: params.VariableFile),
            string(name: 'CRMUpgradeVersion', value: dateValue),
            string(name: 'NumberParallelExecutions', value: '10')]
    }
}

