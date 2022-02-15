def mc_tests(cycle) {
    try {
        if(params.RunMCTests == true) {
            slackMessage.good('Starting MC Failed tests')
            build job: 'runMcTestcases', parameters: [
                string(name: 'SlaveNode', value: params.SlaveNodeMasterController),
                string(name: 'Project', value: params.Project),
                string(name: 'Cycle', value: cycle),
                string(name: 'MasterController', value: params.MasterController),
                string(name: 'TestTarget', value: 'MasterController'),
                string(name: 'VariableFile', value: params.VariableFile),
                string(name: 'TestTimeout', value: params.TestTimeoutMasterController),
                booleanParam(name: 'RunFailedOnly', value: params.RunFailedOnly)]

            slackMessage.good('Finished MC Failed tests with pass')
        } else {
            slackMessage.good('Skipping MC Failed tests')
        }
    } catch(e) {
        slackMessage.fail('Finished MC Failed tests with failures')
    }
}

def controller_tests(cycle) {
    try {
        if(params.RunControllerTests == true) {
            slackMessage.good('Starting Controller Failed tests')
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
            slackMessage.good('Finished Controller Failed tests with pass')
        } else {
            slackMessage.good('Skipping Controller Failed tests')
        }
    } catch(e) {
        slackMessage.fail('Finished Controller Failed tests with failures')
    }
}

def dme_tests(cycle) {
    try {
        if(params.RunDMETests == true) {
            slackMessage.good('Starting DME Failed tests')
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
            slackMessage.good('Finished DME Failed tests with pass')
        } else {
            slackMessage.good('Skipping DME Failed tests')
        }
    } catch(e) {
        slackMessage.fail('Finished DME Failed tests with failures')
    }
}



def call(cycle) {
    stage('DME Tests') { dme_tests(cycle) }
    stage('Controller Tests') { controller_tests(cycle) }
    stage('MC Tests') { mc_tests(cycle) }
}
