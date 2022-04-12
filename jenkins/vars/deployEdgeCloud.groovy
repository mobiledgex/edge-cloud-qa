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

def call(dateValue) {
    dir('go/src/github.com/mobiledgex/edge-cloud-infra/ansible') {
        echo "deploy build resutl ${currentBuild.result}"
        echo 'deploy'
        // fix known_hosts file since recreating the server causes a mismatch in the file
        sh 'ssh-keygen -f "/home/jenkins/.ssh/known_hosts" -R "automationbonncloudlet.tdg.mobiledgex.net"'
        sh 'ssh-keygen -f "/home/jenkins/.ssh/known_hosts" -R "automationhamburgcloudlet.tdg.mobiledgex.net"'

        sh 'export GITHUB_USER=andya072071;export GITHUB_TOKEN=16a8cf8e79fad4a98bba2e59544d8faf78fca71d;export VAULT_ROLE_ID="22c16b60-1ac5-4a32-cc07-05037475a717";export VAULT_SECRET_ID="67c96872-878e-9442-4440-ff76ce65cea5";./deploy.sh -V ' + dateValue + ' qa'
        //sh 'docker system prune -af'  //remove all docker stuff without prompting

        sleep 60  // wait for all pods to come up

        def export_vars = 'export GITHUB_USER=andya072071;export GITHUB_TOKEN=16a8cf8e79fad4a98bba2e59544d8faf78fca71d;export VAULT_ROLE_ID="22c16b60-1ac5-4a32-cc07-05037475a717";export VAULT_SECRET_ID="67c96872-878e-9442-4440-ff76ce65cea5";export VAULT_ADDR=https://vault-qa.mobiledgex.net;'

        def kubectl_setup = export_vars + 'vault login -method=github token="$GITHUB_TOKEN";vault kv get -field=value secret/ansible/common/kubeconfigs/us | base64 --decode >$HOME/kubeconfig.qa-us;export KUBECONFIG=$HOME/kubeconfig.qa-us;kubectl config use-context teleport.mobiledgex.net;'
        sh kubectl_setup + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'99.74.212.184\'/32"}]\''  // andy
        sh kubectl_setup + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'47.186.99.201\'/32"}]\''  // leon
        sh kubectl_setup + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'76.184.227.212\'/32"}]\''   // tom
        sh kubectl_setup + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'40.122.108.233\'/32"}]\''   // jenkinslave1
        sh kubectl_setup + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'35.222.155.38\'/32"}]\''   // jenkinsgcplave

        def kubectl_setup2 = export_vars + 'vault login -method=github token="$GITHUB_TOKEN";vault kv get -field=value secret/ansible/common/kubeconfigs/eu | base64 --decode >$HOME/kubeconfig.qa-eu;export KUBECONFIG=$HOME/kubeconfig.qa-eu;kubectl config use-context teleport.mobiledgex.net;'
        sh kubectl_setup2 + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'99.74.212.184\'/32"}]\''  // andy
        sh kubectl_setup2 + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'47.186.99.201\'/32"}]\''  // leon
        sh kubectl_setup2 + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'76.184.227.212\'/32"}]\''   // tom
        sh kubectl_setup2 + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'40.122.108.233\'/32"}]\''   // jenkinslave1
        sh kubectl_setup2 + 'kubectl patch service monitoring-influxdb --type=json -p \'[{"op":"add", "path":"/spec/loadBalancerSourceRanges/-", "value":"\'35.222.155.38\'/32"}]\''   // jenkinsgcplave
    }
}

