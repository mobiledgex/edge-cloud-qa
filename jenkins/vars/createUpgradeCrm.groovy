import groovy.transform.Field

@Field gitcred = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

def openstack(cycle) {
    print('create openstack ')
    build job: 'runTestcases', parameters: [
        string(name: 'Components', value: 'Automated, CRM, CreateCloudlet'), 
        string(name: 'Project', value: params.Project), 
        string(name: 'Cycle', value: cycle), 
        string(name: 'MasterController', value: params.MasterController),
        string(name: 'TestTarget', value: 'Openstack'),
        string(name: 'VariableFile', value: params.VariableFile), 
        string(name: 'NumberParallelExecutions', value: '10')]
}

def anthos(cycle) {
    print('create anthos ')
    build job: 'runTestcases', parameters: [
        string(name: 'Components', value: 'Automated, CRM, CreateCloudlet'), 
        string(name: 'Project', value: params.Project), 
        string(name: 'Cycle', value: cycle), 
        string(name: 'MasterController', value: params.MasterController),
        string(name: 'TestTarget', value: 'Anthos'),
        string(name: 'VariableFile', value: params.VariableFile), 
        string(name: 'NumberParallelExecutions', value: '10')]
}

def fake(cycle) {
    print('create fake ')
    build job: 'runTestcases', parameters: [
        string(name: 'Components', value: 'Automated, CRM, CreateCloudlet'), 
        string(name: 'Project', value: params.Project), 
        string(name: 'Cycle', value: cycle), 
        string(name: 'MasterController', value: params.MasterController),
        string(name: 'TestTarget', value: 'Controller'),
        string(name: 'VariableFile', value: params.VariableFile), 
        string(name: 'NumberParallelExecutions', value: '10')]
}

def upgrade(cycle, dateValue) {
    print('upgrade cloudlets')
    dir('go/src/github.com/mobiledgex/edge-cloud-infra') {
        sh 'rm -rf $WORKSPACE/go/src/github.com/mobiledgex/edge-cloud-infra/*'
        checkout([$class: 'GitSCM',
            branches: [[name: 'master']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [
                [$class: 'SparseCheckoutPaths',  sparseCheckoutPaths:[[$class:'SparseCheckoutPath', path:'chef/*']
                ]]
            ],
            submoduleCfg: [],
            userRemoteConfigs: [[credentialsId: gitcred,
            url: 'https://github.com/mobiledgex/edge-cloud-infra.git']]])
    }

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

