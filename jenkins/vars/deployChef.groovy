import groovy.transform.Field

@Field gitcred = '79b116ea-d7ac-4d6c-928d-49b79e5f9bef'

def call() {
    dir('go/src/github.com/mobiledgex/edge-cloud-infra') {
        sh 'rm -rf $WORKSPACE/go/src/github.com/mobiledgex/edge-cloud-infra/*'
        checkout([$class: 'GitSCM',
            branches: [[name: 'master']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [
                [$class: 'SparseCheckoutPaths',  sparseCheckoutPaths:[[$class:'SparseCheckoutPath', path:'chef/*'],
                [$class:'SparseCheckoutPath', path:'ansible/*']]]
            ],
            submoduleCfg: [],
            userRemoteConfigs: [[credentialsId: gitcred,
            url: 'https://github.com/mobiledgex/edge-cloud-infra.git']]])
    }
}
