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

def call() {
    dir('go/src/github.com/mobiledgex/edge-cloud-infra/ansible') {
        echo 'defrag'
        def export_vars = 'export GITHUB_USER=andya072071;export GITHUB_TOKEN=16a8cf8e79fad4a98bba2e59544d8faf78fca71d;export VAULT_ROLE_ID="22c16b60-1ac5-4a32-cc07-05037475a717";export VAULT_SECRET_ID="67c96872-878e-9442-4440-ff76ce65cea5";export VAULT_ADDR=https://vault-qa.mobiledgex.net;'
        sh export_vars + 'vault login -method=github token="$GITHUB_TOKEN";vault kv get -field=value secret/ansible/common/kubeconfigs/us | base64 --decode >$HOME/kubeconfig.qa-us;export KUBECONFIG=$HOME/kubeconfig.qa-us;kubectl config use-context teleport.mobiledgex.net;kubectl exec -it mex-etcd-0 -- sh -c "ETCDCTL_API=3 etcdctl --endpoints=http://mex-etcd-0.mex-etcd:2379,http://mex-etcd-1.mex-etcd:2379,http://mex-etcd-2.mex-etcd:2379 defrag"'
        sh export_vars + 'vault login -method=github token="$GITHUB_TOKEN";vault kv get -field=value secret/ansible/common/kubeconfigs/eu | base64 --decode >$HOME/kubeconfig.qa-eu;export KUBECONFIG=$HOME/kubeconfig.qa-eu;kubectl config use-context teleport.mobiledgex.net;kubectl exec -it mex-etcd-0 -- sh -c "ETCDCTL_API=3 etcdctl --endpoints=http://mex-etcd-0.mex-etcd:2379,http://mex-etcd-1.mex-etcd:2379,http://mex-etcd-2.mex-etcd:2379 defrag"'
    }
}

