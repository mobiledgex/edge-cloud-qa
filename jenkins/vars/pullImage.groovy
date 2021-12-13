def call(dateValue) {
    sh 'docker system prune -af'  //remove all docker stuff without prompting
    sh 'docker pull harbor.mobiledgex.net/mobiledgex/edge-cloud:latest'
    sh 'docker run --rm harbor.mobiledgex.net/mobiledgex/edge-cloud:' + dateValue + ' version'
}
