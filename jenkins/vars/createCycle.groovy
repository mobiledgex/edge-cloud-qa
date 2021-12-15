import groovy.transform.Field

@Field gitcred = '79b116ea-d7ac-4d6c-928d-49b79e5f9bef'

def call(cycle) {
    dir('go/src/github.com/mobiledgex') {
        checkout([$class: 'GitSCM',
            branches: [[name: 'master']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [
                [$class: 'SparseCheckoutPaths',  sparseCheckoutPaths:[
                [$class:'SparseCheckoutPath', path:'jenkins/*'],
                [$class:'SparseCheckoutPath', path:'modules/*'],
                ]]
            ],
            submoduleCfg: [],
            userRemoteConfigs: [[credentialsId: gitcred,
            url: 'https://github.com/mobiledgex/edge-cloud-qa.git']]])
    }

    dir('go/src/github.com/mobiledgex/jenkins') {
        def add_pre = 'export PYTHONPATH=$WORKSPACE/go/src/github.com/mobiledgex/modules;./createCycleAddTestcases.py --version ' + params.Version + ' --project ' + params.Project + ' --cycle ' + cycle

        sh add_pre
    }
}

