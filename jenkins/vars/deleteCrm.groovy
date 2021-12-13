def openstack() {
    echo "openstack delete start build result ${currentBuild.result}"
    echo "delete openstack"
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'delete openstack failed') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated, CRM, DeleteCloudlet'), 
            string(name: 'Project', value: params.Project), 
            string(name: 'Cycle', value: cycle), 
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'Openstack'),
            string(name: 'VariableFile', value: params.VariableFile), 
            string(name: 'CRMPoolOpenstack', value: ''),
            string(name: 'NumberParallelExecutions', value: '10')]
    }
}

def anthos() {
    echo "anthos delete start build result ${currentBuild.result}"
    echo "delete anthos"
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'delete anthos failed') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated, CRM, DeleteCloudlet'), 
            string(name: 'Project', value: params.Project), 
            string(name: 'Cycle', value: cycle), 
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'Anthos'),
            string(name: 'VariableFile', value: params.VariableFile), 
            string(name: 'NumberParallelExecutions', value: '10')]
    }
}

def fake() {
    echo "fake delete start build result ${currentBuild.result}"
    echo "delete fake"
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'delete fake failed') {
        build job: 'runTestcases', parameters: [
            string(name: 'Components', value: 'Automated, CRM, DeleteCloudlet'), 
            string(name: 'Project', value: params.Project), 
            string(name: 'Cycle', value: cycle), 
            string(name: 'MasterController', value: params.MasterController),
            string(name: 'TestTarget', value: 'Controller'),
            string(name: 'VariableFile', value: params.VariableFile), 
            string(name: 'NumberParallelExecutions', value: '10')]
    }
}

