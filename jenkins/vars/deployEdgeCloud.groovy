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

        // defrag etcd
        //sh 'kubectl config use-context mexplat-qa-us;kubectl exec -it mex-etcd-0 -- sh -c "ETCDCTL_API=3 etcdctl --endpoints=http://mex-etcd-0.mex-etcd:2379,http://mex-etcd-1.mex-etcd:2379,http://mex-etcd-2.mex-etcd:2379 defrag"'
        //sh 'kubectl config use-context mexplat-qa-eu;kubectl exec -it mex-etcd-0 -- sh -c "ETCDCTL_API=3 etcdctl --endpoints=http://mex-etcd-0.mex-etcd:2379,http://mex-etcd-1.mex-etcd:2379,http://mex-etcd-2.mex-etcd:2379 defrag"'
        sh 'export VAULT_ADDR=https://vault-qa.mobiledgex.net;vault login -method=github token="$GITHUB_TOKEN";vault kv get -field=value secret/ansible/common/kubeconfigs/us | base64 --decode >$HOME/kubeconfig.qa-us;export KUBECONFIG=$HOME/kubeconfig.qa-us;kubectl config use-context teleport.mobiledgex.net;kubectl exec -it mex-etcd-0 -- sh -c "ETCDCTL_API=3 etcdctl --endpoints=http://mex-etcd-0.mex-etcd:2379,http://mex-etcd-1.mex-etcd:2379,http://mex-etcd-2.mex-etcd:2379 defrag"'
        sh 'export VAULT_ADDR=https://vault-qa.mobiledgex.net;vault login -method=github token="$GITHUB_TOKEN";vault kv get -field=value secret/ansible/common/kubeconfigs/eu | base64 --decode >$HOME/kubeconfig.qa-eu;export KUBECONFIG=$HOME/kubeconfig.qa-eu;kubectl config use-context teleport.mobiledgex.net;kubectl exec -it mex-etcd-0 -- sh -c "ETCDCTL_API=3 etcdctl --endpoints=http://mex-etcd-0.mex-etcd:2379,http://mex-etcd-1.mex-etcd:2379,http://mex-etcd-2.mex-etcd:2379 defrag"'

    }
}

