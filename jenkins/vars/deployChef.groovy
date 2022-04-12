// Copyright 2022 MobiledgeX, Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import groovy.transform.Field

@Field gitcred = '79b116ea-d7ac-4d6c-928d-49b79e5f9bef'

def call(dateValue) {
    dir('go/src/github.com/mobiledgex/edge-cloud-infra') {
        sh '[[ -d $WORKSPACE/go/src/github.com/mobiledgex/edge-cloud-infra ]] && rm -rf $WORKSPACE/go/src/github.com/mobiledgex/edge-cloud-infra/*'
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

    dir('go/src/github.com/mobiledgex/edge-cloud-infra/chef/policyfiles') {
        sh "echo \"override['qa']['edgeCloudVersion'] = '" + dateValue + "'\" >> docker_crm.rb && rm -f docker_crm.lock.json && chef install docker_crm.rb "
    }
}
