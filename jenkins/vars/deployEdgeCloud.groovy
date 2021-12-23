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
    }
}

